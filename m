From: Paul Moore <pmoore@redhat.com>
Subject: [RFC PATCH 2/2] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Thu, 29 Nov 2012 17:06:37 -0500
Message-ID: <20121129220637.30020.9980.stgit@sifl>
References: <20121129215724.30020.69464.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20121129215724.30020.69464.stgit@sifl>
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
device.

Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 drivers/net/tun.c                 |   13 ++++++++---
 include/linux/security.h          |   37 ++++++++++++++++++++++-----------
 security/capability.c             |   14 +++++++++---
 security/security.c               |   22 ++++++++++++-------
 security/selinux/hooks.c          |   42 +++++++++++++++++++++++--------------
 security/selinux/include/objsec.h |    4 ++++
 6 files changed, 88 insertions(+), 44 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 877ffe2..85cc924 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -182,6 +182,7 @@ struct tun_struct {
 	struct hlist_head flows[TUN_NUM_FLOW_ENTRIES];
 	struct timer_list flow_gc_timer;
 	unsigned long ageing_time;
+	void *security;
 };
 
 static inline u32 tun_hashfn(u32 rxhash)
@@ -465,6 +466,10 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 	struct tun_file *tfile = file->private_data;
 	int err;
 
+	err = security_tun_dev_attach(tfile->socket.sk, tun->security);
+	if (err < 0)
+		goto out;
+
 	err = -EINVAL;
 	if (rcu_dereference_protected(tfile->tun, lockdep_rtnl_is_held()))
 		goto out;
@@ -1365,6 +1370,7 @@ static void tun_free_netdev(struct net_device *dev)
 	struct tun_struct *tun = netdev_priv(dev);
 
 	tun_flow_uninit(tun);
+	security_tun_dev_free_security(tun->security);
 	free_netdev(dev);
 }
 
@@ -1548,9 +1554,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 		if (tun_not_capable(tun))
 			return -EPERM;
-		err = security_tun_dev_attach(tfile->socket.sk);
-		if (err < 0)
-			return err;
 
 		err = tun_attach(tun, file);
 		if (err < 0)
@@ -1601,7 +1604,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 
 		spin_lock_init(&tun->lock);
 
-		security_tun_dev_post_create(&tfile->sk);
+		err = security_tun_dev_alloc_security(&tun->security);
+		if (err < 0)
+			goto err_free_dev;
 
 		tun_net_init(dev);
 
diff --git a/include/linux/security.h b/include/linux/security.h
index 05e88bd..260e151 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -983,17 +983,23 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
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
  * @tun_dev_attach:
  *	Check permissions prior to attaching to a persistent TUN device.  This
  *	hook can also be used by the module to update any security state
  *	associated with the TUN device's sock structure.
  *	@sk contains the existing sock structure.
+ *	@security pointer to the TUN device's security structure.
  *
  * Security hooks for XFRM operations.
  *
@@ -1613,9 +1619,10 @@ struct security_operations {
 	void (*secmark_refcount_inc) (void);
 	void (*secmark_refcount_dec) (void);
 	void (*req_classify_flow) (const struct request_sock *req, struct flowi *fl);
-	int (*tun_dev_create)(void);
-	void (*tun_dev_post_create)(struct sock *sk);
-	int (*tun_dev_attach)(struct sock *sk);
+	int (*tun_dev_alloc_security) (void **security);
+	void (*tun_dev_free_security) (void *security);
+	int (*tun_dev_create) (void);
+	int (*tun_dev_attach) (struct sock *sk, void *security);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -2553,9 +2560,10 @@ void security_inet_conn_established(struct sock *sk,
 int security_secmark_relabel_packet(u32 secid);
 void security_secmark_refcount_inc(void);
 void security_secmark_refcount_dec(void);
+int security_tun_dev_alloc_security(void **security);
+void security_tun_dev_free_security(void *security);
 int security_tun_dev_create(void);
-void security_tun_dev_post_create(struct sock *sk);
-int security_tun_dev_attach(struct sock *sk);
+int security_tun_dev_attach(struct sock *sk, void *security);
 
 #else	/* CONFIG_SECURITY_NETWORK */
 static inline int security_unix_stream_connect(struct sock *sock,
@@ -2720,16 +2728,21 @@ static inline void security_secmark_refcount_dec(void)
 {
 }
 
-static inline int security_tun_dev_create(void)
+static inline int security_tun_dev_alloc_security(void **security)
 {
 	return 0;
 }
 
-static inline void security_tun_dev_post_create(struct sock *sk)
+static inline void security_tun_dev_free_security(void *security)
 {
 }
 
-static inline int security_tun_dev_attach(struct sock *sk)
+static inline int security_tun_dev_create(void)
+{
+	return 0;
+}
+
+static inline int security_tun_dev_attach(struct sock *sk, void *security)
 {
 	return 0;
 }
diff --git a/security/capability.c b/security/capability.c
index b14a30c..fd6e2dc 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -704,16 +704,21 @@ static void cap_req_classify_flow(const struct request_sock *req,
 {
 }
 
-static int cap_tun_dev_create(void)
+static int cap_tun_dev_alloc_security(void **security)
 {
 	return 0;
 }
 
-static void cap_tun_dev_post_create(struct sock *sk)
+static void cap_tun_dev_free_security(void *security)
+{
+}
+
+static int cap_tun_dev_create(void)
 {
+	return 0;
 }
 
-static int cap_tun_dev_attach(struct sock *sk)
+static int cap_tun_dev_attach(struct sock *sk, void *security)
 {
 	return 0;
 }
@@ -1044,8 +1049,9 @@ void __init security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, secmark_refcount_inc);
 	set_to_cap_if_null(ops, secmark_refcount_dec);
 	set_to_cap_if_null(ops, req_classify_flow);
+	set_to_cap_if_null(ops, tun_dev_alloc_security);
+	set_to_cap_if_null(ops, tun_dev_free_security);
 	set_to_cap_if_null(ops, tun_dev_create);
-	set_to_cap_if_null(ops, tun_dev_post_create);
 	set_to_cap_if_null(ops, tun_dev_attach);
 #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
diff --git a/security/security.c b/security/security.c
index 8dcd4ae..613ad36 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1244,21 +1244,27 @@ void security_secmark_refcount_dec(void)
 }
 EXPORT_SYMBOL(security_secmark_refcount_dec);
 
-int security_tun_dev_create(void)
+int security_tun_dev_alloc_security(void **security)
 {
-	return security_ops->tun_dev_create();
+	return security_ops->tun_dev_alloc_security(security);
 }
-EXPORT_SYMBOL(security_tun_dev_create);
+EXPORT_SYMBOL(security_tun_dev_alloc_security);
 
-void security_tun_dev_post_create(struct sock *sk)
+void security_tun_dev_free_security(void *security)
 {
-	return security_ops->tun_dev_post_create(sk);
+	security_ops->tun_dev_free_security(security);
 }
-EXPORT_SYMBOL(security_tun_dev_post_create);
+EXPORT_SYMBOL(security_tun_dev_free_security);
+
+int security_tun_dev_create(void)
+{
+	return security_ops->tun_dev_create();
+}
+EXPORT_SYMBOL(security_tun_dev_create);
 
-int security_tun_dev_attach(struct sock *sk)
+int security_tun_dev_attach(struct sock *sk, void *security)
 {
-	return security_ops->tun_dev_attach(sk);
+	return security_ops->tun_dev_attach(sk, security);
 }
 EXPORT_SYMBOL(security_tun_dev_attach);
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 61a5336..67b3423 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4414,40 +4414,49 @@ static int selinux_tun_dev_create(void)
 			    NULL);
 }
 
-static void selinux_tun_dev_post_create(struct sock *sk)
+static int selinux_tun_dev_alloc_security(void **security)
 {
-	struct sk_security_struct *sksec = sk->sk_security;
+	struct tun_security_struct *tunsec;
 
-	/* we don't currently perform any NetLabel based labeling here and it
-	 * isn't clear that we would want to do so anyway; while we could apply
-	 * labeling without the support of the TUN user the resulting labeled
-	 * traffic from the other end of the connection would almost certainly
-	 * cause confusion to the TUN user that had no idea network labeling
-	 * protocols were being used */
+	tunsec = kzalloc(sizeof(*tunsec), GFP_KERNEL);
+	if (!tunsec)
+		return -ENOMEM;
+	tunsec->sid = current_sid();
 
-	/* see the comments in selinux_tun_dev_create() about why we don't use
-	 * the sockcreate SID here */
+	*security = tunsec;
+	return 0;
+}
 
-	sksec->sid = current_sid();
-	sksec->sclass = SECCLASS_TUN_SOCKET;
+static void selinux_tun_dev_free_security(void *security)
+{
+	kfree(security);
 }
 
-static int selinux_tun_dev_attach(struct sock *sk)
+static int selinux_tun_dev_attach(struct sock *sk, void *security)
 {
+	struct tun_security_struct *tunsec = security;
 	struct sk_security_struct *sksec = sk->sk_security;
 	u32 sid = current_sid();
 	int err;
 
+	/* we don't currently perform any NetLabel based labeling here and it
+	 * isn't clear that we would want to do so anyway; while we could apply
+	 * labeling without the support of the TUN user the resulting labeled
+	 * traffic from the other end of the connection would almost certainly
+	 * cause confusion to the TUN user that had no idea network labeling
+	 * protocols were being used */
+
 	err = avc_has_perm(sid, sksec->sid, SECCLASS_TUN_SOCKET,
 			   TUN_SOCKET__RELABELFROM, NULL);
 	if (err)
 		return err;
-	err = avc_has_perm(sid, sid, SECCLASS_TUN_SOCKET,
+	err = avc_has_perm(sid, tunsec->sid, SECCLASS_TUN_SOCKET,
 			   TUN_SOCKET__RELABELTO, NULL);
 	if (err)
 		return err;
 
-	sksec->sid = sid;
+	sksec->sid = tunsec->sid;
+	sksec->sclass = SECCLASS_TUN_SOCKET;
 
 	return 0;
 }
@@ -5642,8 +5651,9 @@ static struct security_operations selinux_ops = {
 	.secmark_refcount_inc =		selinux_secmark_refcount_inc,
 	.secmark_refcount_dec =		selinux_secmark_refcount_dec,
 	.req_classify_flow =		selinux_req_classify_flow,
+	.tun_dev_alloc_security =	selinux_tun_dev_alloc_security,
+	.tun_dev_free_security =	selinux_tun_dev_free_security,
 	.tun_dev_create =		selinux_tun_dev_create,
-	.tun_dev_post_create = 		selinux_tun_dev_post_create,
 	.tun_dev_attach =		selinux_tun_dev_attach,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
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

