From: Serge Hallyn <serge@hallyn.com>
Subject: [PATCH 8/9] protect cap_netlink_recv from user namespaces
Date: Tue, 18 Oct 2011 21:54:57 +0000
Message-ID: <1318974898-21431-9-git-send-email-serge@hallyn.com>
References: <1318974898-21431-1-git-send-email-serge@hallyn.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, oleg@redhat.com,
	richard@nod.at, mikevs@xs4all.net, segoon@openwall.com,
	gregkh@suse.de, dhowells@redhat.com, eparis@redhat.com,
	"Serge E. Hallyn" <serge.hallyn@canonical.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318974898-21431-1-git-send-email-serge@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Serge E. Hallyn" <serge.hallyn@canonical.com>

cap_netlink_recv() was granting privilege if a capability is in
current_cap(), regardless of the user namespace.  Fix that by
targeting the capability check against the user namespace which
owns the skb.

Caller passes the user ns down because sock_net is static inline defined in
net/sock.h, which we'd rather not #include at the cap_netlink_recv function.

Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: netdev@vger.kernel.org
---
 drivers/scsi/scsi_netlink.c     |    3 ++-
 include/linux/security.h        |   14 +++++++++-----
 kernel/audit.c                  |    6 ++++--
 net/core/rtnetlink.c            |    3 ++-
 net/decnet/netfilter/dn_rtmsg.c |    3 ++-
 net/ipv4/netfilter/ip_queue.c   |    3 ++-
 net/ipv6/netfilter/ip6_queue.c  |    3 ++-
 net/netfilter/nfnetlink.c       |    2 +-
 net/netlink/genetlink.c         |    2 +-
 net/xfrm/xfrm_user.c            |    2 +-
 security/commoncap.c            |    6 ++----
 security/security.c             |    4 ++--
 security/selinux/hooks.c        |    5 +++--
 13 files changed, 33 insertions(+), 23 deletions(-)

diff --git a/drivers/scsi/scsi_netlink.c b/drivers/scsi/scsi_netlink.c
index 26a8a45..0aa2e57 100644
--- a/drivers/scsi/scsi_netlink.c
+++ b/drivers/scsi/scsi_netlink.c
@@ -111,7 +111,8 @@ scsi_nl_rcv_msg(struct sk_buff *skb)
 			goto next_msg;
 		}
 
-		if (security_netlink_recv(skb, CAP_SYS_ADMIN)) {
+		if (security_netlink_recv(skb, CAP_SYS_ADMIN,
+					  sock_net(skb->sk)->user_ns)) {
 			err = -EPERM;
 			goto next_msg;
 		}
diff --git a/include/linux/security.h b/include/linux/security.h
index ebd2a53..cfa1f47 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -95,7 +95,8 @@ struct xfrm_user_sec_ctx;
 struct seq_file;
 
 extern int cap_netlink_send(struct sock *sk, struct sk_buff *skb);
-extern int cap_netlink_recv(struct sk_buff *skb, int cap);
+extern int cap_netlink_recv(struct sk_buff *skb, int cap,
+			    struct user_namespace *ns);
 
 void reset_security_ops(void);
 
@@ -797,6 +798,7 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	@skb.
  *	@skb contains the sk_buff structure for the netlink message.
  *	@cap indicates the capability required
+ *	@ns is the user namespace which owns skb
  *	Return 0 if permission is granted.
  *
  * Security hooks for Unix domain networking.
@@ -1557,7 +1559,8 @@ struct security_operations {
 			  struct sembuf *sops, unsigned nsops, int alter);
 
 	int (*netlink_send) (struct sock *sk, struct sk_buff *skb);
-	int (*netlink_recv) (struct sk_buff *skb, int cap);
+	int (*netlink_recv) (struct sk_buff *skb, int cap,
+			     struct user_namespace *ns);
 
 	void (*d_instantiate) (struct dentry *dentry, struct inode *inode);
 
@@ -1806,7 +1809,7 @@ void security_d_instantiate(struct dentry *dentry, struct inode *inode);
 int security_getprocattr(struct task_struct *p, char *name, char **value);
 int security_setprocattr(struct task_struct *p, char *name, void *value, size_t size);
 int security_netlink_send(struct sock *sk, struct sk_buff *skb);
-int security_netlink_recv(struct sk_buff *skb, int cap);
+int security_netlink_recv(struct sk_buff *skb, int cap, struct user_namespace *ns);
 int security_secid_to_secctx(u32 secid, char **secdata, u32 *seclen);
 int security_secctx_to_secid(const char *secdata, u32 seclen, u32 *secid);
 void security_release_secctx(char *secdata, u32 seclen);
@@ -2498,9 +2501,10 @@ static inline int security_netlink_send(struct sock *sk, struct sk_buff *skb)
 	return cap_netlink_send(sk, skb);
 }
 
-static inline int security_netlink_recv(struct sk_buff *skb, int cap)
+static inline int security_netlink_recv(struct sk_buff *skb, int cap,
+					struct user_namespace *ns)
 {
-	return cap_netlink_recv(skb, cap);
+	return cap_netlink_recv(skb, cap, ns);
 }
 
 static inline int security_secid_to_secctx(u32 secid, char **secdata, u32 *seclen)
diff --git a/kernel/audit.c b/kernel/audit.c
index 0a1355c..48144c4 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -601,13 +601,15 @@ static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
 	case AUDIT_TTY_SET:
 	case AUDIT_TRIM:
 	case AUDIT_MAKE_EQUIV:
-		if (security_netlink_recv(skb, CAP_AUDIT_CONTROL))
+		if (security_netlink_recv(skb, CAP_AUDIT_CONTROL,
+					  sock_net(skb->sk)->user_ns))
 			err = -EPERM;
 		break;
 	case AUDIT_USER:
 	case AUDIT_FIRST_USER_MSG ... AUDIT_LAST_USER_MSG:
 	case AUDIT_FIRST_USER_MSG2 ... AUDIT_LAST_USER_MSG2:
-		if (security_netlink_recv(skb, CAP_AUDIT_WRITE))
+		if (security_netlink_recv(skb, CAP_AUDIT_WRITE,
+					  sock_net(skb->sk)->user_ns))
 			err = -EPERM;
 		break;
 	default:  /* bad msg */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 99d9e95..4a444de 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1931,7 +1931,8 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	sz_idx = type>>2;
 	kind = type&3;
 
-	if (kind != 2 && security_netlink_recv(skb, CAP_NET_ADMIN))
+	if (kind != 2 && security_netlink_recv(skb, CAP_NET_ADMIN,
+					       net->user_ns))
 		return -EPERM;
 
 	if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index 69975e0..2d052ab 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -108,7 +108,8 @@ static inline void dnrmg_receive_user_skb(struct sk_buff *skb)
 	if (nlh->nlmsg_len < sizeof(*nlh) || skb->len < nlh->nlmsg_len)
 		return;
 
-	if (security_netlink_recv(skb, CAP_NET_ADMIN))
+	if (security_netlink_recv(skb, CAP_NET_ADMIN,
+	    sock_net(skb->sk)->user_ns))
 		RCV_SKB_FAIL(-EPERM);
 
 	/* Eventually we might send routing messages too */
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index e59aabd..d20bede 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -430,7 +430,8 @@ __ipq_rcv_skb(struct sk_buff *skb)
 	if (type <= IPQM_BASE)
 		return;
 
-	if (security_netlink_recv(skb, CAP_NET_ADMIN))
+	if (security_netlink_recv(skb, CAP_NET_ADMIN,
+				  sock_net(skb->sk)->user_ns))
 		RCV_SKB_FAIL(-EPERM);
 
 	spin_lock_bh(&queue_lock);
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index e63c397..09db01c 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -431,7 +431,8 @@ __ipq_rcv_skb(struct sk_buff *skb)
 	if (type <= IPQM_BASE)
 		return;
 
-	if (security_netlink_recv(skb, CAP_NET_ADMIN))
+	if (security_netlink_recv(skb, CAP_NET_ADMIN,
+				  sock_net(skb->sk)->user_ns))
 		RCV_SKB_FAIL(-EPERM);
 
 	spin_lock_bh(&queue_lock);
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 1905976..bcaff9d 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -130,7 +130,7 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	const struct nfnetlink_subsystem *ss;
 	int type, err;
 
-	if (security_netlink_recv(skb, CAP_NET_ADMIN))
+	if (security_netlink_recv(skb, CAP_NET_ADMIN, net->user_ns))
 		return -EPERM;
 
 	/* All the messages must at least contain nfgenmsg */
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 482fa57..00a101c 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -516,7 +516,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EOPNOTSUPP;
 
 	if ((ops->flags & GENL_ADMIN_PERM) &&
-	    security_netlink_recv(skb, CAP_NET_ADMIN))
+	    security_netlink_recv(skb, CAP_NET_ADMIN, net->user_ns))
 		return -EPERM;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 0256b8a..1808e1e 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2290,7 +2290,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	link = &xfrm_dispatch[type];
 
 	/* All operations require privileges, even GET */
-	if (security_netlink_recv(skb, CAP_NET_ADMIN))
+	if (security_netlink_recv(skb, CAP_NET_ADMIN, net->user_ns))
 		return -EPERM;
 
 	if ((type == (XFRM_MSG_GETSA - XFRM_MSG_BASE) ||
diff --git a/security/commoncap.c b/security/commoncap.c
index a93b3b7..1e48e6a 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -56,11 +56,9 @@ int cap_netlink_send(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
-int cap_netlink_recv(struct sk_buff *skb, int cap)
+int cap_netlink_recv(struct sk_buff *skb, int cap, struct user_namespace *ns)
 {
-	if (!cap_raised(current_cap(), cap))
-		return -EPERM;
-	return 0;
+	return security_capable(ns, current_cred(), cap);
 }
 EXPORT_SYMBOL(cap_netlink_recv);
 
diff --git a/security/security.c b/security/security.c
index 0e4fccf..0a1453e 100644
--- a/security/security.c
+++ b/security/security.c
@@ -941,9 +941,9 @@ int security_netlink_send(struct sock *sk, struct sk_buff *skb)
 	return security_ops->netlink_send(sk, skb);
 }
 
-int security_netlink_recv(struct sk_buff *skb, int cap)
+int security_netlink_recv(struct sk_buff *skb, int cap, struct user_namespace *ns)
 {
-	return security_ops->netlink_recv(skb, cap);
+	return security_ops->netlink_recv(skb, cap, ns);
 }
 EXPORT_SYMBOL(security_netlink_recv);
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 266a229..fe290bb 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4723,13 +4723,14 @@ static int selinux_netlink_send(struct sock *sk, struct sk_buff *skb)
 	return selinux_nlmsg_perm(sk, skb);
 }
 
-static int selinux_netlink_recv(struct sk_buff *skb, int capability)
+static int selinux_netlink_recv(struct sk_buff *skb, int capability,
+				struct user_namespace *ns)
 {
 	int err;
 	struct common_audit_data ad;
 	u32 sid;
 
-	err = cap_netlink_recv(skb, capability);
+	err = cap_netlink_recv(skb, capability, ns);
 	if (err)
 		return err;
 
-- 
1.7.5.4
