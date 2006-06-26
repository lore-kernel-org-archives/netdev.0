From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: [patch 1/1] netlink:  encapsulate eff_cap usage within security
	framework
Date: Mon, 26 Jun 2006 13:19:05 -0400
Message-ID: <1151342346.5264.45.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Darrel Goeddel <dgoeddel@trustedcs.com>,
	Chris Wright <chrisw@sous-sol.org>,
	James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mummy.ncsc.mil ([144.51.88.129]:40093 "EHLO jazzhorn.ncsc.mil")
	by vger.kernel.org with ESMTP id S1751135AbWFZRQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 13:16:28 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Darrel Goeddel <dgoeddel@trustedcs.com>

This patch encapsulates the usage of eff_cap (in netlink_skb_params) within
the security framework by extending security_netlink_recv to include a required
capability parameter and converting all direct usage of eff_caps outside
of the lsm modules to use the interface.  It also updates the SELinux
implementation of the security_netlink_send and security_netlink_recv
hooks to take advantage of the sid in the netlink_skb_params struct.
This also enables SELinux to perform auditing of netlink capability checks.
Please apply, for 2.6.18 if possible.

Signed-off-by: Darrel Goeddel <dgoeddel@trustedcs.com>
Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
Acked-by:  James Morris <jmorris@namei.org>

---

 include/linux/security.h        |   13 +++++++------
 kernel/audit.c                  |    8 ++++----
 net/core/rtnetlink.c            |    2 +-
 net/decnet/netfilter/dn_rtmsg.c |    2 +-
 net/ipv4/netfilter/ip_queue.c   |    2 +-
 net/ipv6/netfilter/ip6_queue.c  |    2 +-
 net/netfilter/nfnetlink.c       |    2 +-
 net/netlink/genetlink.c         |    2 +-
 net/xfrm/xfrm_user.c            |    2 +-
 security/commoncap.c            |    4 ++--
 security/dummy.c                |    4 ++--
 security/selinux/hooks.c        |   26 +++++++++++++-------------
 12 files changed, 35 insertions(+), 34 deletions(-)

diff -X /home/sds/dontdiff -rup linux-2.6.17-git10/include/linux/security.h linux-2.6.17-git10-ss2/include/linux/security.h
--- linux-2.6.17-git10/include/linux/security.h	2006-06-26 09:34:30.000000000 -0400
+++ linux-2.6.17-git10-ss2/include/linux/security.h	2006-06-26 09:50:59.000000000 -0400
@@ -67,7 +67,7 @@ struct xfrm_state;
 struct xfrm_user_sec_ctx;
 
 extern int cap_netlink_send(struct sock *sk, struct sk_buff *skb);
-extern int cap_netlink_recv(struct sk_buff *skb);
+extern int cap_netlink_recv(struct sk_buff *skb, int cap);
 
 /*
  * Values used in the task_security_ops calls
@@ -656,6 +656,7 @@ struct swap_info_struct;
  *	Check permission before processing the received netlink message in
  *	@skb.
  *	@skb contains the sk_buff structure for the netlink message.
+ *	@cap indicates the capability required
  *	Return 0 if permission is granted.
  *
  * Security hooks for Unix domain networking.
@@ -1265,7 +1266,7 @@ struct security_operations {
 			  struct sembuf * sops, unsigned nsops, int alter);
 
 	int (*netlink_send) (struct sock * sk, struct sk_buff * skb);
-	int (*netlink_recv) (struct sk_buff * skb);
+	int (*netlink_recv) (struct sk_buff * skb, int cap);
 
 	/* allow module stacking */
 	int (*register_security) (const char *name,
@@ -2031,9 +2032,9 @@ static inline int security_netlink_send(
 	return security_ops->netlink_send(sk, skb);
 }
 
-static inline int security_netlink_recv(struct sk_buff * skb)
+static inline int security_netlink_recv(struct sk_buff * skb, int cap)
 {
-	return security_ops->netlink_recv(skb);
+	return security_ops->netlink_recv(skb, cap);
 }
 
 /* prototypes */
@@ -2669,9 +2670,9 @@ static inline int security_netlink_send 
 	return cap_netlink_send (sk, skb);
 }
 
-static inline int security_netlink_recv (struct sk_buff *skb)
+static inline int security_netlink_recv (struct sk_buff *skb, int cap)
 {
-	return cap_netlink_recv (skb);
+	return cap_netlink_recv (skb, cap);
 }
 
 static inline struct dentry *securityfs_create_dir(const char *name,
diff -X /home/sds/dontdiff -rup linux-2.6.17-git10/kernel/audit.c linux-2.6.17-git10-ss2/kernel/audit.c
--- linux-2.6.17-git10/kernel/audit.c	2006-06-26 09:34:30.000000000 -0400
+++ linux-2.6.17-git10-ss2/kernel/audit.c	2006-06-26 09:50:59.000000000 -0400
@@ -445,7 +445,7 @@ void audit_send_reply(int pid, int seq, 
  * Check for appropriate CAP_AUDIT_ capabilities on incoming audit
  * control messages.
  */
-static int audit_netlink_ok(kernel_cap_t eff_cap, u16 msg_type)
+static int audit_netlink_ok(struct sk_buff *skb, u16 msg_type)
 {
 	int err = 0;
 
@@ -459,13 +459,13 @@ static int audit_netlink_ok(kernel_cap_t
 	case AUDIT_DEL:
 	case AUDIT_DEL_RULE:
 	case AUDIT_SIGNAL_INFO:
-		if (!cap_raised(eff_cap, CAP_AUDIT_CONTROL))
+		if (security_netlink_recv(skb, CAP_AUDIT_CONTROL))
 			err = -EPERM;
 		break;
 	case AUDIT_USER:
 	case AUDIT_FIRST_USER_MSG...AUDIT_LAST_USER_MSG:
 	case AUDIT_FIRST_USER_MSG2...AUDIT_LAST_USER_MSG2:
-		if (!cap_raised(eff_cap, CAP_AUDIT_WRITE))
+		if (security_netlink_recv(skb, CAP_AUDIT_WRITE))
 			err = -EPERM;
 		break;
 	default:  /* bad msg */
@@ -488,7 +488,7 @@ static int audit_receive_msg(struct sk_b
 	char			*ctx;
 	u32			len;
 
-	err = audit_netlink_ok(NETLINK_CB(skb).eff_cap, msg_type);
+	err = audit_netlink_ok(skb, msg_type);
 	if (err)
 		return err;
 
diff -X /home/sds/dontdiff -rup linux-2.6.17-git10/net/core/rtnetlink.c linux-2.6.17-git10-ss2/net/core/rtnetlink.c
--- linux-2.6.17-git10/net/core/rtnetlink.c	2006-06-26 09:34:30.000000000 -0400
+++ linux-2.6.17-git10-ss2/net/core/rtnetlink.c	2006-06-26 09:50:59.000000000 -0400
@@ -663,7 +663,7 @@ rtnetlink_rcv_msg(struct sk_buff *skb, s
 	sz_idx = type>>2;
 	kind = type&3;
 
-	if (kind != 2 && security_netlink_recv(skb)) {
+	if (kind != 2 && security_netlink_recv(skb, CAP_NET_ADMIN)) {
 		*errp = -EPERM;
 		return -1;
 	}
diff -X /home/sds/dontdiff -rup linux-2.6.17-git10/net/decnet/netfilter/dn_rtmsg.c linux-2.6.17-git10-ss2/net/decnet/netfilter/dn_rtmsg.c
--- linux-2.6.17-git10/net/decnet/netfilter/dn_rtmsg.c	2006-06-26 09:34:30.000000000 -0400
+++ linux-2.6.17-git10-ss2/net/decnet/netfilter/dn_rtmsg.c	2006-06-26 09:50:59.000000000 -0400
@@ -107,7 +107,7 @@ static inline void dnrmg_receive_user_sk
 	if (nlh->nlmsg_len < sizeof(*nlh) || skb->len < nlh->nlmsg_len)
 		return;
 
-	if (!cap_raised(NETLINK_CB(skb).eff_cap, CAP_NET_ADMIN))
+	if (security_netlink_recv(skb, CAP_NET_ADMIN))
 		RCV_SKB_FAIL(-EPERM);
 
 	/* Eventually we might send routing messages too */
diff -X /home/sds/dontdiff -rup linux-2.6.17-git10/net/ipv4/netfilter/ip_queue.c linux-2.6.17-git10-ss2/net/ipv4/netfilter/ip_queue.c
--- linux-2.6.17-git10/net/ipv4/netfilter/ip_queue.c	2006-06-26 09:34:30.000000000 -0400
+++ linux-2.6.17-git10-ss2/net/ipv4/netfilter/ip_queue.c	2006-06-26 09:50:59.000000000 -0400
@@ -507,7 +507,7 @@ ipq_rcv_skb(struct sk_buff *skb)
 	if (type <= IPQM_BASE)
 		return;
 		
-	if (security_netlink_recv(skb))
+	if (security_netlink_recv(skb, CAP_NET_ADMIN))
 		RCV_SKB_FAIL(-EPERM);
 	
 	write_lock_bh(&queue_lock);
diff -X /home/sds/dontdiff -rup linux-2.6.17-git10/net/ipv6/netfilter/ip6_queue.c linux-2.6.17-git10-ss2/net/ipv6/netfilter/ip6_queue.c
--- linux-2.6.17-git10/net/ipv6/netfilter/ip6_queue.c	2006-06-26 09:34:30.000000000 -0400
+++ linux-2.6.17-git10-ss2/net/ipv6/netfilter/ip6_queue.c	2006-06-26 09:50:59.000000000 -0400
@@ -505,7 +505,7 @@ ipq_rcv_skb(struct sk_buff *skb)
 	if (type <= IPQM_BASE)
 		return;
 	
-	if (security_netlink_recv(skb))
+	if (security_netlink_recv(skb, CAP_NET_ADMIN))
 		RCV_SKB_FAIL(-EPERM);	
 
 	write_lock_bh(&queue_lock);
diff -X /home/sds/dontdiff -rup linux-2.6.17-git10/net/netfilter/nfnetlink.c linux-2.6.17-git10-ss2/net/netfilter/nfnetlink.c
--- linux-2.6.17-git10/net/netfilter/nfnetlink.c	2006-06-26 09:34:30.000000000 -0400
+++ linux-2.6.17-git10-ss2/net/netfilter/nfnetlink.c	2006-06-26 09:50:59.000000000 -0400
@@ -229,7 +229,7 @@ static int nfnetlink_rcv_msg(struct sk_b
 		 NFNL_SUBSYS_ID(nlh->nlmsg_type),
 		 NFNL_MSG_TYPE(nlh->nlmsg_type));
 
-	if (!cap_raised(NETLINK_CB(skb).eff_cap, CAP_NET_ADMIN)) {
+	if (security_netlink_recv(skb, CAP_NET_ADMIN)) {
 		DEBUGP("missing CAP_NET_ADMIN\n");
 		*errp = -EPERM;
 		return -1;
diff -X /home/sds/dontdiff -rup linux-2.6.17-git10/net/netlink/genetlink.c linux-2.6.17-git10-ss2/net/netlink/genetlink.c
--- linux-2.6.17-git10/net/netlink/genetlink.c	2006-06-26 09:34:30.000000000 -0400
+++ linux-2.6.17-git10-ss2/net/netlink/genetlink.c	2006-06-26 09:50:59.000000000 -0400
@@ -320,7 +320,7 @@ static int genl_rcv_msg(struct sk_buff *
 		goto errout;
 	}
 
-	if ((ops->flags & GENL_ADMIN_PERM) && security_netlink_recv(skb)) {
+	if ((ops->flags & GENL_ADMIN_PERM) && security_netlink_recv(skb, CAP_NET_ADMIN)) {
 		err = -EPERM;
 		goto errout;
 	}
diff -X /home/sds/dontdiff -rup linux-2.6.17-git10/net/xfrm/xfrm_user.c linux-2.6.17-git10-ss2/net/xfrm/xfrm_user.c
--- linux-2.6.17-git10/net/xfrm/xfrm_user.c	2006-06-26 09:34:30.000000000 -0400
+++ linux-2.6.17-git10-ss2/net/xfrm/xfrm_user.c	2006-06-26 09:50:59.000000000 -0400
@@ -1435,7 +1435,7 @@ static int xfrm_user_rcv_msg(struct sk_b
 	link = &xfrm_dispatch[type];
 
 	/* All operations require privileges, even GET */
-	if (security_netlink_recv(skb)) {
+	if (security_netlink_recv(skb, CAP_NET_ADMIN)) {
 		*errp = -EPERM;
 		return -1;
 	}
diff -X /home/sds/dontdiff -rup linux-2.6.17-git10/security/commoncap.c linux-2.6.17-git10-ss2/security/commoncap.c
--- linux-2.6.17-git10/security/commoncap.c	2006-06-26 09:34:30.000000000 -0400
+++ linux-2.6.17-git10-ss2/security/commoncap.c	2006-06-26 09:50:59.000000000 -0400
@@ -33,9 +33,9 @@ int cap_netlink_send(struct sock *sk, st
 
 EXPORT_SYMBOL(cap_netlink_send);
 
-int cap_netlink_recv(struct sk_buff *skb)
+int cap_netlink_recv(struct sk_buff *skb, int cap)
 {
-	if (!cap_raised(NETLINK_CB(skb).eff_cap, CAP_NET_ADMIN))
+	if (!cap_raised(NETLINK_CB(skb).eff_cap, cap))
 		return -EPERM;
 	return 0;
 }
diff -X /home/sds/dontdiff -rup linux-2.6.17-git10/security/dummy.c linux-2.6.17-git10-ss2/security/dummy.c
--- linux-2.6.17-git10/security/dummy.c	2006-06-26 09:34:30.000000000 -0400
+++ linux-2.6.17-git10-ss2/security/dummy.c	2006-06-26 09:50:59.000000000 -0400
@@ -675,9 +675,9 @@ static int dummy_netlink_send (struct so
 	return 0;
 }
 
-static int dummy_netlink_recv (struct sk_buff *skb)
+static int dummy_netlink_recv (struct sk_buff *skb, int cap)
 {
-	if (!cap_raised (NETLINK_CB (skb).eff_cap, CAP_NET_ADMIN))
+	if (!cap_raised (NETLINK_CB (skb).eff_cap, cap))
 		return -EPERM;
 	return 0;
 }
diff -X /home/sds/dontdiff -rup linux-2.6.17-git10/security/selinux/hooks.c linux-2.6.17-git10-ss2/security/selinux/hooks.c
--- linux-2.6.17-git10/security/selinux/hooks.c	2006-06-26 10:34:54.000000000 -0400
+++ linux-2.6.17-git10-ss2/security/selinux/hooks.c	2006-06-26 09:50:59.000000000 -0400
@@ -3622,32 +3622,32 @@ static unsigned int selinux_ipv6_postrou
 
 static int selinux_netlink_send(struct sock *sk, struct sk_buff *skb)
 {
-	struct task_security_struct *tsec;
-	struct av_decision avd;
 	int err;
 
 	err = secondary_ops->netlink_send(sk, skb);
 	if (err)
 		return err;
 
-	tsec = current->security;
-
-	avd.allowed = 0;
-	avc_has_perm_noaudit(tsec->sid, tsec->sid,
-				SECCLASS_CAPABILITY, ~0, &avd);
-	cap_mask(NETLINK_CB(skb).eff_cap, avd.allowed);
-
 	if (policydb_loaded_version >= POLICYDB_VERSION_NLCLASS)
 		err = selinux_nlmsg_perm(sk, skb);
 
 	return err;
 }
 
-static int selinux_netlink_recv(struct sk_buff *skb)
+static int selinux_netlink_recv(struct sk_buff *skb, int capability)
 {
-	if (!cap_raised(NETLINK_CB(skb).eff_cap, CAP_NET_ADMIN))
-		return -EPERM;
-	return 0;
+	int err;
+	struct avc_audit_data ad;
+
+	err = secondary_ops->netlink_recv(skb, capability);
+	if (err)
+		return err;
+
+	AVC_AUDIT_DATA_INIT(&ad, CAP);
+	ad.u.cap = capability;
+
+	return avc_has_perm(NETLINK_CB(skb).sid, NETLINK_CB(skb).sid,
+	                    SECCLASS_CAPABILITY, CAP_TO_MASK(capability), &ad);
 }
 
 static int ipc_alloc_security(struct task_struct *task,

-- 
Stephen Smalley
National Security Agency

