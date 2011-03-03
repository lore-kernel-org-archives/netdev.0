From: Chris Wright <chrisw@sous-sol.org>
Subject: [RFC PATCH 3/2] security: update security_netlink_recv hook prototype
Date: Thu, 3 Mar 2011 12:26:26 -0800
Message-ID: <20110303202626.GV4988@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Chris Wright <chrisw@sous-sol.org>, netdev@vger.kernel.org,
	dm-devel@redhat.com, linux-security-module@vger.kernel.org,
	drbd-dev@lists.linbit.com, Evgeniy Polyakov <zbr@ioremap.net>,
	linux-fbdev@vger.kernel.org
To: James Morris <jmorris@namei.org>, kaber@trash.net
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We no longer need the skb in security_netlink_recv hook because the
netlink kernel receive path is synchronous.  There is no need to inspect
the netlink_skb_params.  Eliminating this makes it easy to reuse
the security_netlink_recv hook in connector callbacks.

Signed-off-by: Chris Wright <chrisw@sous-sol.org>
---
 drivers/scsi/scsi_netlink.c     |    2 +-
 include/linux/security.h        |   14 ++++++--------
 kernel/audit.c                  |    4 ++--
 net/core/rtnetlink.c            |    2 +-
 net/decnet/netfilter/dn_rtmsg.c |    2 +-
 net/ipv4/netfilter/ip_queue.c   |    2 +-
 net/ipv6/netfilter/ip6_queue.c  |    2 +-
 net/netfilter/nfnetlink.c       |    2 +-
 net/netlink/genetlink.c         |    2 +-
 net/xfrm/xfrm_user.c            |    2 +-
 security/commoncap.c            |    2 +-
 security/security.c             |    4 ++--
 security/selinux/hooks.c        |    4 ++--
 13 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/drivers/scsi/scsi_netlink.c b/drivers/scsi/scsi_netlink.c
index a2ed201..711bdc8 100644
--- a/drivers/scsi/scsi_netlink.c
+++ b/drivers/scsi/scsi_netlink.c
@@ -111,7 +111,7 @@ scsi_nl_rcv_msg(struct sk_buff *skb)
 			goto next_msg;
 		}
 
-		if (security_netlink_recv(skb, CAP_SYS_ADMIN)) {
+		if (security_netlink_recv(CAP_SYS_ADMIN)) {
 			err = -EPERM;
 			goto next_msg;
 		}
diff --git a/include/linux/security.h b/include/linux/security.h
index b2b7f97..8f10864 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -93,7 +93,7 @@ struct xfrm_user_sec_ctx;
 struct seq_file;
 
 extern int cap_netlink_send(struct sock *sk, struct sk_buff *skb);
-extern int cap_netlink_recv(struct sk_buff *skb, int cap);
+extern int cap_netlink_recv(int cap);
 
 void reset_security_ops(void);
 
@@ -784,9 +784,7 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	Return 0 if the information was successfully saved and message
  *	is allowed to be transmitted.
  * @netlink_recv:
- *	Check permission before processing the received netlink message in
- *	@skb.
- *	@skb contains the sk_buff structure for the netlink message.
+ *	Check permission before processing a received netlink message.
  *	@cap indicates the capability required
  *	Return 0 if permission is granted.
  *
@@ -1552,7 +1550,7 @@ struct security_operations {
 			  struct sembuf *sops, unsigned nsops, int alter);
 
 	int (*netlink_send) (struct sock *sk, struct sk_buff *skb);
-	int (*netlink_recv) (struct sk_buff *skb, int cap);
+	int (*netlink_recv) (int cap);
 
 	void (*d_instantiate) (struct dentry *dentry, struct inode *inode);
 
@@ -1798,7 +1796,7 @@ void security_d_instantiate(struct dentry *dentry, struct inode *inode);
 int security_getprocattr(struct task_struct *p, char *name, char **value);
 int security_setprocattr(struct task_struct *p, char *name, void *value, size_t size);
 int security_netlink_send(struct sock *sk, struct sk_buff *skb);
-int security_netlink_recv(struct sk_buff *skb, int cap);
+int security_netlink_recv(int cap);
 int security_secid_to_secctx(u32 secid, char **secdata, u32 *seclen);
 int security_secctx_to_secid(const char *secdata, u32 seclen, u32 *secid);
 void security_release_secctx(char *secdata, u32 seclen);
@@ -2493,9 +2491,9 @@ static inline int security_netlink_send(struct sock *sk, struct sk_buff *skb)
 	return cap_netlink_send(sk, skb);
 }
 
-static inline int security_netlink_recv(struct sk_buff *skb, int cap)
+static inline int security_netlink_recv(int cap)
 {
-	return cap_netlink_recv(skb, cap);
+	return cap_netlink_recv(cap);
 }
 
 static inline int security_secid_to_secctx(u32 secid, char **secdata, u32 *seclen)
diff --git a/kernel/audit.c b/kernel/audit.c
index 608347c..ed43e46 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -596,13 +596,13 @@ static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
 	case AUDIT_TTY_SET:
 	case AUDIT_TRIM:
 	case AUDIT_MAKE_EQUIV:
-		if (security_netlink_recv(skb, CAP_AUDIT_CONTROL))
+		if (security_netlink_recv(CAP_AUDIT_CONTROL))
 			err = -EPERM;
 		break;
 	case AUDIT_USER:
 	case AUDIT_FIRST_USER_MSG ... AUDIT_LAST_USER_MSG:
 	case AUDIT_FIRST_USER_MSG2 ... AUDIT_LAST_USER_MSG2:
-		if (security_netlink_recv(skb, CAP_AUDIT_WRITE))
+		if (security_netlink_recv(CAP_AUDIT_WRITE))
 			err = -EPERM;
 		break;
 	default:  /* bad msg */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2d65c6b..0d2dad5 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1819,7 +1819,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	sz_idx = type>>2;
 	kind = type&3;
 
-	if (kind != 2 && security_netlink_recv(skb, CAP_NET_ADMIN))
+	if (kind != 2 && security_netlink_recv(CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index 64a7f39..51d9707 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -108,7 +108,7 @@ static inline void dnrmg_receive_user_skb(struct sk_buff *skb)
 	if (nlh->nlmsg_len < sizeof(*nlh) || skb->len < nlh->nlmsg_len)
 		return;
 
-	if (security_netlink_recv(skb, CAP_NET_ADMIN))
+	if (security_netlink_recv(CAP_NET_ADMIN))
 		RCV_SKB_FAIL(-EPERM);
 
 	/* Eventually we might send routing messages too */
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index d2c1311..f821562 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -430,7 +430,7 @@ __ipq_rcv_skb(struct sk_buff *skb)
 	if (type <= IPQM_BASE)
 		return;
 
-	if (security_netlink_recv(skb, CAP_NET_ADMIN))
+	if (security_netlink_recv(CAP_NET_ADMIN))
 		RCV_SKB_FAIL(-EPERM);
 
 	spin_lock_bh(&queue_lock);
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 413ab07..f58cebb 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -431,7 +431,7 @@ __ipq_rcv_skb(struct sk_buff *skb)
 	if (type <= IPQM_BASE)
 		return;
 
-	if (security_netlink_recv(skb, CAP_NET_ADMIN))
+	if (security_netlink_recv(CAP_NET_ADMIN))
 		RCV_SKB_FAIL(-EPERM);
 
 	spin_lock_bh(&queue_lock);
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index b4a4532..caca5c6 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -130,7 +130,7 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	const struct nfnetlink_subsystem *ss;
 	int type, err;
 
-	if (security_netlink_recv(skb, CAP_NET_ADMIN))
+	if (security_netlink_recv(CAP_NET_ADMIN))
 		return -EPERM;
 
 	/* All the messages must at least contain nfgenmsg */
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 1781d99..8c47d8f 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -516,7 +516,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EOPNOTSUPP;
 
 	if ((ops->flags & GENL_ADMIN_PERM) &&
-	    security_netlink_recv(skb, CAP_NET_ADMIN))
+	    security_netlink_recv(CAP_NET_ADMIN))
 		return -EPERM;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 117a99e..5ad66bf 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2192,7 +2192,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	link = &xfrm_dispatch[type];
 
 	/* All operations require privileges, even GET */
-	if (security_netlink_recv(skb, CAP_NET_ADMIN))
+	if (security_netlink_recv(CAP_NET_ADMIN))
 		return -EPERM;
 
 	if ((type == (XFRM_MSG_GETSA - XFRM_MSG_BASE) ||
diff --git a/security/commoncap.c b/security/commoncap.c
index a83e607..a9eefc9 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -55,7 +55,7 @@ int cap_netlink_send(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
-int cap_netlink_recv(struct sk_buff *skb, int cap)
+int cap_netlink_recv(int cap)
 {
 	if (!cap_raised(current_cap(), cap))
 		return -EPERM;
diff --git a/security/security.c b/security/security.c
index 7b7308a..1e0879d 100644
--- a/security/security.c
+++ b/security/security.c
@@ -941,9 +941,9 @@ int security_netlink_send(struct sock *sk, struct sk_buff *skb)
 	return security_ops->netlink_send(sk, skb);
 }
 
-int security_netlink_recv(struct sk_buff *skb, int cap)
+int security_netlink_recv(int cap)
 {
-	return security_ops->netlink_recv(skb, cap);
+	return security_ops->netlink_recv(cap);
 }
 EXPORT_SYMBOL(security_netlink_recv);
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index cef42f5..a832d6b 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4665,13 +4665,13 @@ static int selinux_netlink_send(struct sock *sk, struct sk_buff *skb)
 	return selinux_nlmsg_perm(sk, skb);
 }
 
-static int selinux_netlink_recv(struct sk_buff *skb, int capability)
+static int selinux_netlink_recv(int capability)
 {
 	int err;
 	struct common_audit_data ad;
 	u32 sid;
 
-	err = cap_netlink_recv(skb, capability);
+	err = cap_netlink_recv(capability);
 	if (err)
 		return err;
 
-- 
1.7.1

