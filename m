From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 3/3] mlsxfrm: Various fixes
Date: Tue, 07 Nov 2006 11:17:14 -0600
Message-ID: <4550BF9A.3040002@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:12567 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1751661AbWKGRRb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 12:17:31 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the selection of an SA for an outgoing packet to be at the same
context as the originating socket/flow. This eliminates the SELinux
policy's ability to use/sendto SAs with contexts other than the socket's.

With this patch applied, the SELinux policy will require one or more of the
following for a socket to be able to communicate with/without SAs:

1. To enable a socket to communicate without using labeled-IPSec SAs:

allow socket_t unlabeled_t:association { sendto recvfrom }

2. To enable a socket to communicate with labeled-IPSec SAs:

allow socket_t self:association { sendto };
allow socket_t peer_sa_t:association { recvfrom };

Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h            |   19 -----
 net/xfrm/xfrm_policy.c              |    3 
 security/dummy.c                    |    7 -
 security/selinux/hooks.c            |   26 ++++--
 security/selinux/include/security.h |    2 
 security/selinux/include/xfrm.h     |    7 -
 security/selinux/ss/services.c      |   44 +++++++++++
 security/selinux/xfrm.c             |   97 ++++++++++++--------------
 8 files changed, 112 insertions(+), 93 deletions(-)

--- net-2.6.xfrm2/include/linux/security.h	2006-10-25 12:26:20.000000000 -0500
+++ net-2.6/include/linux/security.h	2006-11-01 11:22:17.000000000 -0600
@@ -886,11 +886,6 @@ struct request_sock;
  *	@xp contains the policy to check for a match.
  *	@fl contains the flow to check for a match.
  *	Return 1 if there is a match.
- * @xfrm_flow_state_match:
- *	@fl contains the flow key to match.
- *	@xfrm points to the xfrm_state to match.
- *	@xp points to the xfrm_policy to match.
- *	Return 1 if there is a match.
  * @xfrm_decode_session:
  *	@skb points to skb to decode.
  *	@secid points to the flow key secid to set.
@@ -1388,8 +1383,6 @@ struct security_operations {
 	int (*xfrm_policy_lookup)(struct xfrm_policy *xp, u32 fl_secid, u8 dir);
 	int (*xfrm_state_pol_flow_match)(struct xfrm_state *x,
 			struct xfrm_policy *xp, struct flowi *fl);
-	int (*xfrm_flow_state_match)(struct flowi *fl, struct xfrm_state *xfrm,
-			struct xfrm_policy *xp);
 	int (*xfrm_decode_session)(struct sk_buff *skb, u32 *secid, int ckall);
 #endif	/* CONFIG_SECURITY_NETWORK_XFRM */
 
@@ -3186,12 +3179,6 @@ static inline int security_xfrm_state_po
 	return security_ops->xfrm_state_pol_flow_match(x, xp, fl);
 }
 
-static inline int security_xfrm_flow_state_match(struct flowi *fl,
-			struct xfrm_state *xfrm, struct xfrm_policy *xp)
-{
-	return security_ops->xfrm_flow_state_match(fl, xfrm, xp);
-}
-
 static inline int security_xfrm_decode_session(struct sk_buff *skb, u32 *secid)
 {
 	return security_ops->xfrm_decode_session(skb, secid, 1);
@@ -3255,12 +3242,6 @@ static inline int security_xfrm_state_po
 	return 1;
 }
 
-static inline int security_xfrm_flow_state_match(struct flowi *fl,
-			struct xfrm_state *xfrm, struct xfrm_policy *xp)
-{
-	return 1;
-}
-
 static inline int security_xfrm_decode_session(struct sk_buff *skb, u32 *secid)
 {
 	return 0;
--- net-2.6.xfrm2/net/xfrm/xfrm_policy.c	2006-11-01 11:25:39.000000000 -0600
+++ net-2.6/net/xfrm/xfrm_policy.c	2006-11-01 12:10:23.000000000 -0600
@@ -1894,7 +1894,8 @@ int xfrm_bundle_ok(struct xfrm_policy *p
 
 		if (fl && !xfrm_selector_match(&dst->xfrm->sel, fl, family))
 			return 0;
-		if (fl && !security_xfrm_flow_state_match(fl, dst->xfrm, pol))
+		if (fl && pol &&
+		    !security_xfrm_state_pol_flow_match(dst->xfrm, pol, fl))
 			return 0;
 		if (dst->xfrm->km.state != XFRM_STATE_VALID)
 			return 0;
--- net-2.6.xfrm2/security/dummy.c	2006-10-25 12:23:47.000000000 -0500
+++ net-2.6/security/dummy.c	2006-11-01 11:22:34.000000000 -0600
@@ -886,12 +886,6 @@ static int dummy_xfrm_state_pol_flow_mat
 	return 1;
 }
 
-static int dummy_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm,
-				struct xfrm_policy *xp)
-{
-	return 1;
-}
-
 static int dummy_xfrm_decode_session(struct sk_buff *skb, u32 *fl, int ckall)
 {
 	return 0;
@@ -1126,7 +1120,6 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, xfrm_state_delete_security);
 	set_to_dummy_if_null(ops, xfrm_policy_lookup);
 	set_to_dummy_if_null(ops, xfrm_state_pol_flow_match);
-	set_to_dummy_if_null(ops, xfrm_flow_state_match);
 	set_to_dummy_if_null(ops, xfrm_decode_session);
 #endif	/* CONFIG_SECURITY_NETWORK_XFRM */
 #ifdef CONFIG_KEYS
--- net-2.6.xfrm2/security/selinux/include/xfrm.h	2006-11-07 09:49:24.000000000 -0600
+++ net-2.6/security/selinux/include/xfrm.h	2006-11-07 10:03:20.000000000 -0600
@@ -19,9 +19,6 @@ int selinux_xfrm_state_delete(struct xfr
 int selinux_xfrm_policy_lookup(struct xfrm_policy *xp, u32 fl_secid, u8 dir);
 int selinux_xfrm_state_pol_flow_match(struct xfrm_state *x,
 			struct xfrm_policy *xp, struct flowi *fl);
-int selinux_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm,
-			struct xfrm_policy *xp);
-
 
 /*
  * Extract the security blob from the sock (it's actually on the socket)
@@ -38,7 +35,7 @@ static inline struct inode_security_stru
 int selinux_xfrm_sock_rcv_skb(u32 sid, struct sk_buff *skb,
 			struct avc_audit_data *ad);
 int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb,
-			struct avc_audit_data *ad);
+			struct avc_audit_data *ad, u8 proto);
 u32 selinux_socket_getpeer_dgram(struct sk_buff *skb);
 int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall);
 #else
@@ -49,7 +46,7 @@ static inline int selinux_xfrm_sock_rcv_
 }
 
 static inline int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb,
-			struct avc_audit_data *ad)
+			struct avc_audit_data *ad, u8 proto)
 {
 	return 0;
 }
--- net-2.6.xfrm2/security/selinux/include/security.h	2006-10-26 10:24:38.000000000 -0500
+++ net-2.6/security/selinux/include/security.h	2006-10-26 10:26:40.000000000 -0500
@@ -85,6 +85,8 @@ int security_validate_transition(u32 old
 
 int security_sid_mls_copy(u32 sid, u32 mls_sid, u32 *new_sid);
 
+int security_sid_compare(u32 sid1, u32 sid2);
+
 #define SECURITY_FS_USE_XATTR		1 /* use xattr */
 #define SECURITY_FS_USE_TRANS		2 /* use transition SIDs, e.g. devpts/tmpfs */
 #define SECURITY_FS_USE_TASK		3 /* use task SIDs, e.g. pipefs/sockfs */
--- net-2.6.xfrm2/security/selinux/hooks.c	2006-11-07 09:51:10.000000000 -0600
+++ net-2.6/security/selinux/hooks.c	2006-11-06 10:35:41.000000000 -0600
@@ -2888,7 +2888,8 @@ static void selinux_task_to_inode(struct
 }
 
 /* Returns error only if unable to parse addresses */
-static int selinux_parse_skb_ipv4(struct sk_buff *skb, struct avc_audit_data *ad)
+static int selinux_parse_skb_ipv4(struct sk_buff *skb,
+			struct avc_audit_data *ad, u8 *proto)
 {
 	int offset, ihlen, ret = -EINVAL;
 	struct iphdr _iph, *ih;
@@ -2906,6 +2907,9 @@ static int selinux_parse_skb_ipv4(struct
 	ad->u.net.v4info.daddr = ih->daddr;
 	ret = 0;
 
+	if (proto)
+		*proto = ih->protocol;
+
 	switch (ih->protocol) {
         case IPPROTO_TCP: {
         	struct tcphdr _tcph, *th;
@@ -2949,7 +2953,8 @@ out:
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 
 /* Returns error only if unable to parse addresses */
-static int selinux_parse_skb_ipv6(struct sk_buff *skb, struct avc_audit_data *ad)
+static int selinux_parse_skb_ipv6(struct sk_buff *skb,
+			struct avc_audit_data *ad, u8 *proto)
 {
 	u8 nexthdr;
 	int ret = -EINVAL, offset;
@@ -2970,6 +2975,9 @@ static int selinux_parse_skb_ipv6(struct
 	if (offset < 0)
 		goto out;
 
+	if (proto)
+		*proto = nexthdr;
+
 	switch (nexthdr) {
 	case IPPROTO_TCP: {
         	struct tcphdr _tcph, *th;
@@ -3006,13 +3014,13 @@ out:
 #endif /* IPV6 */
 
 static int selinux_parse_skb(struct sk_buff *skb, struct avc_audit_data *ad,
-			     char **addrp, int *len, int src)
+			     char **addrp, int *len, int src, u8 *proto)
 {
 	int ret = 0;
 
 	switch (ad->u.net.family) {
 	case PF_INET:
-		ret = selinux_parse_skb_ipv4(skb, ad);
+		ret = selinux_parse_skb_ipv4(skb, ad, proto);
 		if (ret || !addrp)
 			break;
 		*len = 4;
@@ -3022,7 +3030,7 @@ static int selinux_parse_skb(struct sk_b
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case PF_INET6:
-		ret = selinux_parse_skb_ipv6(skb, ad);
+		ret = selinux_parse_skb_ipv6(skb, ad, proto);
 		if (ret || !addrp)
 			break;
 		*len = 16;
@@ -3487,7 +3495,7 @@ static int selinux_socket_sock_rcv_skb(s
 	ad.u.net.netif = skb->dev ? skb->dev->name : "[unknown]";
 	ad.u.net.family = family;
 
-	err = selinux_parse_skb(skb, &ad, &addrp, &len, 1);
+	err = selinux_parse_skb(skb, &ad, &addrp, &len, 1, NULL);
 	if (err)
 		goto out;
 
@@ -3813,6 +3821,7 @@ static unsigned int selinux_ip_postroute
 	struct avc_audit_data ad;
 	struct net_device *dev = (struct net_device *)out;
 	struct sk_security_struct *sksec;
+	u8 proto;
 
 	sk = skb->sk;
 	if (!sk)
@@ -3824,7 +3833,7 @@ static unsigned int selinux_ip_postroute
 	ad.u.net.netif = dev->name;
 	ad.u.net.family = family;
 
-	err = selinux_parse_skb(skb, &ad, &addrp, &len, 0);
+	err = selinux_parse_skb(skb, &ad, &addrp, &len, 0, &proto);
 	if (err)
 		goto out;
 
@@ -3838,7 +3847,7 @@ static unsigned int selinux_ip_postroute
 	if (err)
 		goto out;
 
-	err = selinux_xfrm_postroute_last(sksec->sid, skb, &ad);
+	err = selinux_xfrm_postroute_last(sksec->sid, skb, &ad, proto);
 out:
 	return err ? NF_DROP : NF_ACCEPT;
 }
@@ -4757,7 +4766,6 @@ static struct security_operations selinu
 	.xfrm_state_delete_security =	selinux_xfrm_state_delete,
 	.xfrm_policy_lookup = 		selinux_xfrm_policy_lookup,
 	.xfrm_state_pol_flow_match =	selinux_xfrm_state_pol_flow_match,
-	.xfrm_flow_state_match =	selinux_xfrm_flow_state_match,
 	.xfrm_decode_session =		selinux_xfrm_decode_session,
 #endif
 
--- net-2.6.xfrm2/security/selinux/xfrm.c	2006-11-07 09:49:47.000000000 -0600
+++ net-2.6/security/selinux/xfrm.c	2006-11-06 10:32:28.000000000 -0600
@@ -115,71 +115,41 @@ int selinux_xfrm_state_pol_flow_match(st
 			struct flowi *fl)
 {
 	u32 state_sid;
-	u32 pol_sid;
-	int err;
+	int rc;
 
-	if (xp->security) {
-		if (!x->security)
-			/* unlabeled SA and labeled policy can't match */
-			return 0;
-		else
-			state_sid = x->security->ctx_sid;
-		pol_sid = xp->security->ctx_sid;
-	} else
+	if (!xp->security)
 		if (x->security)
 			/* unlabeled policy and labeled SA can't match */
 			return 0;
 		else
 			/* unlabeled policy and unlabeled SA match all flows */
 			return 1;
-
-	err = avc_has_perm(state_sid, pol_sid, SECCLASS_ASSOCIATION,
-			  ASSOCIATION__POLMATCH,
-			  NULL);
-
-	if (err)
-		return 0;
-
-	err = avc_has_perm(fl->secid, state_sid, SECCLASS_ASSOCIATION,
-			  ASSOCIATION__SENDTO,
-			  NULL)? 0:1;
-
-	return err;
-}
-
-/*
- * LSM hook implementation that authorizes that a particular outgoing flow
- * can use a given security association.
- */
-
-int selinux_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm,
-				  struct xfrm_policy *xp)
-{
-	int rc = 0;
-	u32 sel_sid = SECINITSID_UNLABELED;
-	struct xfrm_sec_ctx *ctx;
-
-	if (!xp->security)
-		if (!xfrm->security)
-			return 1;
-		else
-			return 0;
 	else
-		if (!xfrm->security)
+		if (!x->security)
+			/* unlabeled SA and labeled policy can't match */
 			return 0;
+		else
+			if (!selinux_authorizable_xfrm(x))
+				/* Not a SELinux-labeled SA */
+				return 0;
 
-	/* Context sid is either set to label or ANY_ASSOC */
-	if ((ctx = xfrm->security)) {
-		if (!selinux_authorizable_ctx(ctx))
-			return 0;
+	state_sid = x->security->ctx_sid;
 
-		sel_sid = ctx->ctx_sid;
-	}
+	rc = security_sid_compare(fl->secid, state_sid);
+	if (!rc)
+		return 0;
 
-	rc = avc_has_perm(fl->secid, sel_sid, SECCLASS_ASSOCIATION,
+	rc = avc_has_perm(fl->secid, state_sid, SECCLASS_ASSOCIATION,
 			  ASSOCIATION__SENDTO,
 			  NULL)? 0:1;
 
+	/*
+	 * We don't need a separate SA Vs. policy polmatch check
+	 * since the SA is now of the same label as the flow and
+	 * a flow Vs. policy polmatch check had already happened
+	 * in selinux_xfrm_policy_lookup() above.
+	 */
+
 	return rc;
 }
 
@@ -480,6 +450,13 @@ int selinux_xfrm_sock_rcv_skb(u32 isec_s
 		}
 	}
 
+	/*
+	 * This check even when there's no association involved is
+	 * intended, according to Trent Jaeger, to make sure a
+	 * process can't engage in non-ipsec communication unless
+	 * explicitly allowed by policy.
+	 */
+
 	rc = avc_has_perm(isec_sid, sel_sid, SECCLASS_ASSOCIATION,
 			  ASSOCIATION__RECVFROM, ad);
 
@@ -491,10 +468,10 @@ int selinux_xfrm_sock_rcv_skb(u32 isec_s
  * If we have no security association, then we need to determine
  * whether the socket is allowed to send to an unlabelled destination.
  * If we do have a authorizable security association, then it has already been
- * checked in xfrm_policy_lookup hook.
+ * checked in the selinux_xfrm_state_pol_flow_match hook above.
  */
 int selinux_xfrm_postroute_last(u32 isec_sid, struct sk_buff *skb,
-					struct avc_audit_data *ad)
+					struct avc_audit_data *ad, u8 proto)
 {
 	struct dst_entry *dst;
 	int rc = 0;
@@ -513,6 +490,22 @@ int selinux_xfrm_postroute_last(u32 isec
 		}
 	}
 
+	switch (proto) {
+	case IPPROTO_AH:
+	case IPPROTO_ESP:
+	case IPPROTO_COMP:
+		goto out;
+	default:
+		break;
+	}
+
+	/*
+	 * This check even when there's no association involved is
+	 * intended, according to Trent Jaeger, to make sure a
+	 * process can't engage in non-ipsec communication unless
+	 * explicitly allowed by policy.
+	 */
+
 	rc = avc_has_perm(isec_sid, SECINITSID_UNLABELED, SECCLASS_ASSOCIATION,
 			  ASSOCIATION__SENDTO, ad);
 out:
--- net-2.6.xfrm2/security/selinux/ss/services.c	2006-10-26 09:32:20.000000000 -0500
+++ net-2.6/security/selinux/ss/services.c	2006-10-26 10:55:38.000000000 -0500
@@ -1897,6 +1897,50 @@ out:
 	return rc;
 }
 
+/*
+ * security_sid_compare() - compares two given sid contexts.
+ * Returns 1 if they are equal, 0 otherwise.
+ */
+int security_sid_compare(u32 sid1, u32 sid2)
+{
+	struct context *context1;
+	struct context *context2;
+	int rc;
+
+	if (!ss_initialized)
+		return 1;
+
+	if (sid1 == sid2)
+		return 1;
+	else if (sid1 > SECINITSID_NUM && sid2 > SECINITSID_NUM)
+		return 0;
+
+	/* explicit comparison in order */
+
+	POLICY_RDLOCK;
+	context1 = sidtab_search(&sidtab, sid1);
+	if (!context1) {
+		printk(KERN_ERR "security_sid_compare:  unrecognized SID "
+		       "%u\n", sid1);
+		rc = 0;
+		goto out_unlock;
+	}
+
+	context2 = sidtab_search(&sidtab, sid2);
+	if (!context2) {
+		printk(KERN_ERR "security_sid_compare:  unrecognized SID "
+		       "%u\n", sid2);
+		rc = 0;
+		goto out_unlock;
+	}
+
+	rc = context_cmp(context1, context2);
+
+out_unlock:
+	POLICY_RDUNLOCK;
+	return rc;
+}
+
 struct selinux_audit_rule {
 	u32 au_seqno;
 	struct context au_ctxt;
