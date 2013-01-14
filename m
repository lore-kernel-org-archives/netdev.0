From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH 2/2] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Mon, 14 Jan 2013 12:12:19 -0500
Message-ID: <20130114171219.31874.44991.stgit@localhost>
References: <20130114170837.31874.78897.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Paris <eparis@parisplace.org>,
	Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20130114170837.31874.78897.stgit@localhost>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch corrects some problems with LSM/SELinux that were introduced
with the multiqueue patchset.  The problem stems from the fact that the
multiqueue work changed the relationship between the tun device and its
associated socket; before the socket persisted for the life of the
device, however after the multiqueue changes the socket only persisted
for the life of the userspace connection (fd open).  For non-persistent
devices this is not an issue, but for persistent devices this can cause
the tun device to lose its SELinux label.

We correct this problem by adding an opaque LSM security blob to the
tun device struct which allows us to have the LSM security state, e.g.
SELinux labeling information, persist for the lifetime of the tun
device.  In the process we tweak the LSM hooks to work with this new
approach to TUN device/socket labeling and introduce a new LSM hook,
security_tun_dev_attach_queue(), to approve requests to attach to a
TUN queue via TUNSETQUEUE.

The SELinux code has been adjusted to match the new LSM hooks, the
other LSMs do not make use of the LSM TUN controls.  This patch makes
use of the recently added "tun_socket:attach_queue" permission to
restrict access to the TUNSETQUEUE operation.  On older SELinux
policies which do not define the "tun_socket:attach_queue" permission
the access control decision for TUNSETQUEUE will be handled according
to the SELinux policy's unknown permission setting.

Signed-off-by: Paul Moore <pmoore@redhat.com>
Acked-by: Eric Paris <eparis@parisplace.org>
Tested-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c                 |   23 +++++++++++---
 include/linux/security.h          |   59 +++++++++++++++++++++++++++++--------
 security/capability.c             |   24 +++++++++++++--
 security/security.c               |   28 ++++++++++++++----
 security/selinux/hooks.c          |   50 ++++++++++++++++++++++++-------
 security/selinux/include/objsec.h |    4 +++
 6 files changed, 151 insertions(+), 37 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index af372d0..c81680d 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -185,6 +185,7 @@ struct tun_struct {
 	unsigned long ageing_time;
 	unsigned int numdisabled;
 	struct list_head disabled;
+	void *security;
 };
 
 static inline u32 tun_hashfn(u32 rxhash)
@@ -490,6 +491,10 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 	struct tun_file *tfile = file->private_data;
 	int err;
 
+	err = security_tun_dev_attach(tfile->socket.sk, tun->security);
+	if (err < 0)
+		goto out;
+
 	err = -EINVAL;
 	if (rtnl_dereference(tfile->tun))
 		goto out;
@@ -1373,6 +1378,7 @@ static void tun_free_netdev(struct net_device *dev)
 
 	BUG_ON(!(list_empty(&tun->disabled)));
 	tun_flow_uninit(tun);
+	security_tun_dev_free_security(tun->security);
 	free_netdev(dev);
 }
 
@@ -1562,7 +1568,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 		if (tun_not_capable(tun))
 			return -EPERM;
-		err = security_tun_dev_attach(tfile->socket.sk);
+		err = security_tun_dev_open(tun->security);
 		if (err < 0)
 			return err;
 
@@ -1619,7 +1625,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 		spin_lock_init(&tun->lock);
 
-		security_tun_dev_post_create(&tfile->sk);
+		err = security_tun_dev_alloc_security(&tun->security);
+		if (err < 0)
+			goto err_free_dev;
 
 		tun_net_init(dev);
 
@@ -1789,10 +1797,14 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
 
 	if (ifr->ifr_flags & IFF_ATTACH_QUEUE) {
 		tun = tfile->detached;
-		if (!tun)
+		if (!tun) {
 			ret = -EINVAL;
-		else
-			ret = tun_attach(tun, file);
+			goto unlock;
+		}
+		ret = security_tun_dev_attach_queue(tun->security);
+		if (ret < 0)
+			goto unlock;
+		ret = tun_attach(tun, file);
 	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE) {
 		tun = rtnl_dereference(tfile->tun);
 		if (!tun || !(tun->flags & TUN_TAP_MQ))
@@ -1802,6 +1814,7 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
 	} else
 		ret = -EINVAL;
 
+unlock:
 	rtnl_unlock();
 	return ret;
 }
diff --git a/include/linux/security.h b/include/linux/security.h
index 0f6afc6..eee7478 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -989,17 +989,29 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	tells the LSM to decrement the number of secmark labeling rules loaded
  * @req_classify_flow:
  *	Sets the flow's sid to the openreq sid.
+ * @tun_dev_alloc_security:
+ *	This hook allows a module to allocate a security structure for a TUN
+ *	device.
+ *	@security pointer to a security structure pointer.
+ *	Returns a zero on success, negative values on failure.
+ * @tun_dev_free_security:
+ *	This hook allows a module to free the security structure for a TUN
+ *	device.
+ *	@security pointer to the TUN device's security structure
  * @tun_dev_create:
  *	Check permissions prior to creating a new TUN device.
- * @tun_dev_post_create:
- *	This hook allows a module to update or allocate a per-socket security
- *	structure.
- *	@sk contains the newly created sock structure.
+ * @tun_dev_attach_queue:
+ *	Check permissions prior to attaching to a TUN device queue.
+ *	@security pointer to the TUN device's security structure.
  * @tun_dev_attach:
- *	Check permissions prior to attaching to a persistent TUN device.  This
- *	hook can also be used by the module to update any security state
+ *	This hook can be used by the module to update any security state
  *	associated with the TUN device's sock structure.
  *	@sk contains the existing sock structure.
+ *	@security pointer to the TUN device's security structure.
+ * @tun_dev_open:
+ *	This hook can be used by the module to update any security state
+ *	associated with the TUN device's security structure.
+ *	@security pointer to the TUN devices's security structure.
  *
  * Security hooks for XFRM operations.
  *
@@ -1620,9 +1632,12 @@ struct security_operations {
 	void (*secmark_refcount_inc) (void);
 	void (*secmark_refcount_dec) (void);
 	void (*req_classify_flow) (const struct request_sock *req, struct flowi *fl);
-	int (*tun_dev_create)(void);
-	void (*tun_dev_post_create)(struct sock *sk);
-	int (*tun_dev_attach)(struct sock *sk);
+	int (*tun_dev_alloc_security) (void **security);
+	void (*tun_dev_free_security) (void *security);
+	int (*tun_dev_create) (void);
+	int (*tun_dev_attach_queue) (void *security);
+	int (*tun_dev_attach) (struct sock *sk, void *security);
+	int (*tun_dev_open) (void *security);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -2566,9 +2581,12 @@ void security_inet_conn_established(struct sock *sk,
 int security_secmark_relabel_packet(u32 secid);
 void security_secmark_refcount_inc(void);
 void security_secmark_refcount_dec(void);
+int security_tun_dev_alloc_security(void **security);
+void security_tun_dev_free_security(void *security);
 int security_tun_dev_create(void);
-void security_tun_dev_post_create(struct sock *sk);
-int security_tun_dev_attach(struct sock *sk);
+int security_tun_dev_attach_queue(void *security);
+int security_tun_dev_attach(struct sock *sk, void *security);
+int security_tun_dev_open(void *security);
 
 #else	/* CONFIG_SECURITY_NETWORK */
 static inline int security_unix_stream_connect(struct sock *sock,
@@ -2733,16 +2751,31 @@ static inline void security_secmark_refcount_dec(void)
 {
 }
 
+static inline int security_tun_dev_alloc_security(void **security)
+{
+	return 0;
+}
+
+static inline void security_tun_dev_free_security(void *security)
+{
+}
+
 static inline int security_tun_dev_create(void)
 {
 	return 0;
 }
 
-static inline void security_tun_dev_post_create(struct sock *sk)
+static inline int security_tun_dev_attach_queue(void *security)
+{
+	return 0;
+}
+
+static inline int security_tun_dev_attach(struct sock *sk, void *security)
 {
+	return 0;
 }
 
-static inline int security_tun_dev_attach(struct sock *sk)
+static inline int security_tun_dev_open(void *security)
 {
 	return 0;
 }
diff --git a/security/capability.c b/security/capability.c
index 0fe5a02..5797750 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -709,16 +709,31 @@ static void cap_req_classify_flow(const struct request_sock *req,
 {
 }
 
+static int cap_tun_dev_alloc_security(void **security)
+{
+	return 0;
+}
+
+static void cap_tun_dev_free_security(void *security)
+{
+}
+
 static int cap_tun_dev_create(void)
 {
 	return 0;
 }
 
-static void cap_tun_dev_post_create(struct sock *sk)
+static int cap_tun_dev_attach_queue(void *security)
+{
+	return 0;
+}
+
+static int cap_tun_dev_attach(struct sock *sk, void *security)
 {
+	return 0;
 }
 
-static int cap_tun_dev_attach(struct sock *sk)
+static int cap_tun_dev_open(void *security)
 {
 	return 0;
 }
@@ -1050,8 +1065,11 @@ void __init security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, secmark_refcount_inc);
 	set_to_cap_if_null(ops, secmark_refcount_dec);
 	set_to_cap_if_null(ops, req_classify_flow);
+	set_to_cap_if_null(ops, tun_dev_alloc_security);
+	set_to_cap_if_null(ops, tun_dev_free_security);
 	set_to_cap_if_null(ops, tun_dev_create);
-	set_to_cap_if_null(ops, tun_dev_post_create);
+	set_to_cap_if_null(ops, tun_dev_open);
+	set_to_cap_if_null(ops, tun_dev_attach_queue);
 	set_to_cap_if_null(ops, tun_dev_attach);
 #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
diff --git a/security/security.c b/security/security.c
index daa97f4..7b88c6a 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1254,24 +1254,42 @@ void security_secmark_refcount_dec(void)
 }
 EXPORT_SYMBOL(security_secmark_refcount_dec);
 
+int security_tun_dev_alloc_security(void **security)
+{
+	return security_ops->tun_dev_alloc_security(security);
+}
+EXPORT_SYMBOL(security_tun_dev_alloc_security);
+
+void security_tun_dev_free_security(void *security)
+{
+	security_ops->tun_dev_free_security(security);
+}
+EXPORT_SYMBOL(security_tun_dev_free_security);
+
 int security_tun_dev_create(void)
 {
 	return security_ops->tun_dev_create();
 }
 EXPORT_SYMBOL(security_tun_dev_create);
 
-void security_tun_dev_post_create(struct sock *sk)
+int security_tun_dev_attach_queue(void *security)
 {
-	return security_ops->tun_dev_post_create(sk);
+	return security_ops->tun_dev_attach_queue(security);
 }
-EXPORT_SYMBOL(security_tun_dev_post_create);
+EXPORT_SYMBOL(security_tun_dev_attach_queue);
 
-int security_tun_dev_attach(struct sock *sk)
+int security_tun_dev_attach(struct sock *sk, void *security)
 {
-	return security_ops->tun_dev_attach(sk);
+	return security_ops->tun_dev_attach(sk, security);
 }
 EXPORT_SYMBOL(security_tun_dev_attach);
 
+int security_tun_dev_open(void *security)
+{
+	return security_ops->tun_dev_open(security);
+}
+EXPORT_SYMBOL(security_tun_dev_open);
+
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 61a5336..ef26e96 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4399,6 +4399,24 @@ static void selinux_req_classify_flow(const struct request_sock *req,
 	fl->flowi_secid = req->secid;
 }
 
+static int selinux_tun_dev_alloc_security(void **security)
+{
+	struct tun_security_struct *tunsec;
+
+	tunsec = kzalloc(sizeof(*tunsec), GFP_KERNEL);
+	if (!tunsec)
+		return -ENOMEM;
+	tunsec->sid = current_sid();
+
+	*security = tunsec;
+	return 0;
+}
+
+static void selinux_tun_dev_free_security(void *security)
+{
+	kfree(security);
+}
+
 static int selinux_tun_dev_create(void)
 {
 	u32 sid = current_sid();
@@ -4414,8 +4432,17 @@ static int selinux_tun_dev_create(void)
 			    NULL);
 }
 
-static void selinux_tun_dev_post_create(struct sock *sk)
+static int selinux_tun_dev_attach_queue(void *security)
 {
+	struct tun_security_struct *tunsec = security;
+
+	return avc_has_perm(current_sid(), tunsec->sid, SECCLASS_TUN_SOCKET,
+			    TUN_SOCKET__ATTACH_QUEUE, NULL);
+}
+
+static int selinux_tun_dev_attach(struct sock *sk, void *security)
+{
+	struct tun_security_struct *tunsec = security;
 	struct sk_security_struct *sksec = sk->sk_security;
 
 	/* we don't currently perform any NetLabel based labeling here and it
@@ -4425,20 +4452,19 @@ static void selinux_tun_dev_post_create(struct sock *sk)
 	 * cause confusion to the TUN user that had no idea network labeling
 	 * protocols were being used */
 
-	/* see the comments in selinux_tun_dev_create() about why we don't use
-	 * the sockcreate SID here */
-
-	sksec->sid = current_sid();
+	sksec->sid = tunsec->sid;
 	sksec->sclass = SECCLASS_TUN_SOCKET;
+
+	return 0;
 }
 
-static int selinux_tun_dev_attach(struct sock *sk)
+static int selinux_tun_dev_open(void *security)
 {
-	struct sk_security_struct *sksec = sk->sk_security;
+	struct tun_security_struct *tunsec = security;
 	u32 sid = current_sid();
 	int err;
 
-	err = avc_has_perm(sid, sksec->sid, SECCLASS_TUN_SOCKET,
+	err = avc_has_perm(sid, tunsec->sid, SECCLASS_TUN_SOCKET,
 			   TUN_SOCKET__RELABELFROM, NULL);
 	if (err)
 		return err;
@@ -4446,8 +4472,7 @@ static int selinux_tun_dev_attach(struct sock *sk)
 			   TUN_SOCKET__RELABELTO, NULL);
 	if (err)
 		return err;
-
-	sksec->sid = sid;
+	tunsec->sid = sid;
 
 	return 0;
 }
@@ -5642,9 +5667,12 @@ static struct security_operations selinux_ops = {
 	.secmark_refcount_inc =		selinux_secmark_refcount_inc,
 	.secmark_refcount_dec =		selinux_secmark_refcount_dec,
 	.req_classify_flow =		selinux_req_classify_flow,
+	.tun_dev_alloc_security =	selinux_tun_dev_alloc_security,
+	.tun_dev_free_security =	selinux_tun_dev_free_security,
 	.tun_dev_create =		selinux_tun_dev_create,
-	.tun_dev_post_create = 		selinux_tun_dev_post_create,
+	.tun_dev_attach_queue =		selinux_tun_dev_attach_queue,
 	.tun_dev_attach =		selinux_tun_dev_attach,
+	.tun_dev_open =			selinux_tun_dev_open,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,
diff --git a/security/selinux/include/objsec.h b/security/selinux/include/objsec.h
index 26c7eee..aa47bca 100644
--- a/security/selinux/include/objsec.h
+++ b/security/selinux/include/objsec.h
@@ -110,6 +110,10 @@ struct sk_security_struct {
 	u16 sclass;			/* sock security class */
 };
 
+struct tun_security_struct {
+	u32 sid;			/* SID for the tun device sockets */
+};
+
 struct key_security_struct {
 	u32 sid;	/* SID of key */
 };

