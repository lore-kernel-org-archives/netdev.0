From: Joy Latten <latten@austin.ibm.com>
Subject: [PATCH] make xfrm_audit_log more generic
Date: Thu, 19 Jul 2007 17:42:47 -0500
Message-ID: <200707192242.l6JMglVk029578@faith.austin.ibm.com>
Cc: davem@davemloft.net, linux-audit@redhat.com, sgrubb@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:37469 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752194AbXGSWoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 18:44:46 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6JMij0D020607
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 18:44:45 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6JMijoX265344
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 16:44:45 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6JMii5d012731
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 16:44:45 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch modifies xfrm_audit_log() such that it 
can accomodate auditing other ipsec events
besides add/delete of an SA or SPD entry. 

This is a small change to accomodate updating 
ipsec protocol to RFCs 4301, 4302 and 4303 which
require auditing some ipsec events if auditing
is available. Please let me know if ok.

I tested with selinux/labeled-ipsec/plain-ipsec and plain ipsec
without selinux. Also compiled and tested with auditing disabled.

Regards,
Joy

Signed-off-by: Joy Latten <latten@austin.ibm.com>
 

diff -urpN linux-2.6.22/include/linux/audit.h linux-2.6.22.patch/include/linux/audit.h
--- linux-2.6.22/include/linux/audit.h	2007-07-19 13:17:22.000000000 -0500
+++ linux-2.6.22.patch/include/linux/audit.h	2007-07-19 13:21:29.000000000 -0500
@@ -108,10 +108,7 @@
 #define AUDIT_MAC_CIPSOV4_DEL	1408	/* NetLabel: del CIPSOv4 DOI entry */
 #define AUDIT_MAC_MAP_ADD	1409	/* NetLabel: add LSM domain mapping */
 #define AUDIT_MAC_MAP_DEL	1410	/* NetLabel: del LSM domain mapping */
-#define AUDIT_MAC_IPSEC_ADDSA	1411	/* Add a XFRM state */
-#define AUDIT_MAC_IPSEC_DELSA	1412	/* Delete a XFRM state */
-#define AUDIT_MAC_IPSEC_ADDSPD	1413	/* Add a XFRM policy */
-#define AUDIT_MAC_IPSEC_DELSPD	1414	/* Delete a XFRM policy */
+#define AUDIT_MAC_IPSEC_EVENT	1411	/* Audit IPSec events */
 
 #define AUDIT_FIRST_KERN_ANOM_MSG   1700
 #define AUDIT_LAST_KERN_ANOM_MSG    1799
diff -urpN linux-2.6.22/include/net/xfrm.h linux-2.6.22.patch/include/net/xfrm.h
--- linux-2.6.22/include/net/xfrm.h	2007-07-19 13:17:22.000000000 -0500
+++ linux-2.6.22.patch/include/net/xfrm.h	2007-07-19 13:21:29.000000000 -0500
@@ -427,9 +427,11 @@ struct xfrm_audit
 
 #ifdef CONFIG_AUDITSYSCALL
 extern void xfrm_audit_log(uid_t auid, u32 secid, int type, int result,
-		    struct xfrm_policy *xp, struct xfrm_state *x);
+			   u16 family, xfrm_address_t saddr, 
+			   xfrm_address_t daddr, __be32 spi, __be32 flowid, 
+			   struct xfrm_sec_ctx *sctx, char *buf);
 #else
-#define xfrm_audit_log(a,s,t,r,p,x) do { ; } while (0)
+#define xfrm_audit_log(a,i,t,r,f,s,d,p,l,c,b) do { ; } while (0)
 #endif /* CONFIG_AUDITSYSCALL */
 
 static inline void xfrm_pol_hold(struct xfrm_policy *policy)
diff -urpN linux-2.6.22/net/key/af_key.c linux-2.6.22.patch/net/key/af_key.c
--- linux-2.6.22/net/key/af_key.c	2007-07-08 18:32:17.000000000 -0500
+++ linux-2.6.22.patch/net/key/af_key.c	2007-07-19 13:21:30.000000000 -0500
@@ -1459,7 +1459,9 @@ static int pfkey_add(struct sock *sk, st
 		err = xfrm_state_update(x);
 
 	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_ADDSA, err ? 0 : 1, NULL, x);
+		       AUDIT_MAC_IPSEC_EVENT, err ? 0 : 1, 
+		       x->props.family, x->props.saddr, x->id.daddr, 
+		       x->id.spi, 0, x->security, "SAD add");
 
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
@@ -1513,7 +1515,10 @@ static int pfkey_delete(struct sock *sk,
 	km_state_notify(x, &c);
 out:
 	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_DELSA, err ? 0 : 1, NULL, x);
+		       AUDIT_MAC_IPSEC_EVENT, err ? 0 : 1, x->props.family,
+		       x->props.saddr, x->id.daddr, x->id.spi, 0,
+		       x->security, "SAD delete");
+
 	xfrm_state_put(x);
 
 	return err;
@@ -2266,7 +2271,9 @@ static int pfkey_spdadd(struct sock *sk,
 				 hdr->sadb_msg_type != SADB_X_SPDUPDATE);
 
 	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_ADDSPD, err ? 0 : 1, xp, NULL);
+		       AUDIT_MAC_IPSEC_EVENT, err ? 0 : 1, 
+		       xp->selector.family, xp->selector.saddr,
+		       xp->selector.daddr, 0, 0, xp->security, "SPD add");
 
 	if (err)
 		goto out;
@@ -2350,7 +2357,9 @@ static int pfkey_spddelete(struct sock *
 		return -ENOENT;
 
 	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
+		       AUDIT_MAC_IPSEC_EVENT, err ? 0 : 1,
+		       xp->selector.family, xp->selector.saddr,
+		       xp->selector.daddr, 0, 0, xp->security, "SPD delete");
 
 	if (err)
 		goto out;
@@ -2611,7 +2620,10 @@ static int pfkey_spdget(struct sock *sk,
 
 	if (delete) {
 		xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-			       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
+			       AUDIT_MAC_IPSEC_EVENT, err ? 0 : 1, 
+			       xp->selector.family, xp->selector.saddr,
+			       xp->selector.daddr, 0, 0, xp->security,
+			       "SPD delete");
 
 		if (err)
 			goto out;
diff -urpN linux-2.6.22/net/xfrm/xfrm_policy.c linux-2.6.22.patch/net/xfrm/xfrm_policy.c
--- linux-2.6.22/net/xfrm/xfrm_policy.c	2007-07-19 13:17:23.000000000 -0500
+++ linux-2.6.22.patch/net/xfrm/xfrm_policy.c	2007-07-19 13:21:30.000000000 -0500
@@ -853,8 +853,11 @@ xfrm_policy_flush_secctx_check(u8 type, 
 			if (err) {
 				xfrm_audit_log(audit_info->loginuid,
 					       audit_info->secid,
-					       AUDIT_MAC_IPSEC_DELSPD, 0,
-					       pol, NULL);
+					       AUDIT_MAC_IPSEC_EVENT, 0,
+					       pol->selector.family, 
+					       pol->selector.saddr, 
+					       pol->selector.daddr, 0, 0,
+					       pol->security, "SPD delete");
 				return err;
 			}
                 }
@@ -868,8 +871,12 @@ xfrm_policy_flush_secctx_check(u8 type, 
 				if (err) {
 					xfrm_audit_log(audit_info->loginuid,
 						       audit_info->secid,
-						       AUDIT_MAC_IPSEC_DELSPD,
-						       0, pol, NULL);
+						       AUDIT_MAC_IPSEC_EVENT,
+						       0, pol->selector.family, 
+						       pol->selector.saddr, 
+						       pol->selector.daddr, 
+						       0, 0, pol->security, 
+						       "SPD delete");
 					return err;
 				}
 			}
@@ -911,7 +918,11 @@ int xfrm_policy_flush(u8 type, struct xf
 			write_unlock_bh(&xfrm_policy_lock);
 
 			xfrm_audit_log(audit_info->loginuid, audit_info->secid,
-				       AUDIT_MAC_IPSEC_DELSPD, 1, pol, NULL);
+				       AUDIT_MAC_IPSEC_EVENT, 1, 
+				       pol->selector.family,
+				       pol->selector.saddr,
+				       pol->selector.daddr, 0, 0,
+				       pol->security, "SPD delete");
 
 			xfrm_policy_kill(pol);
 			killed++;
@@ -933,8 +944,11 @@ int xfrm_policy_flush(u8 type, struct xf
 
 				xfrm_audit_log(audit_info->loginuid,
 					       audit_info->secid,
-					       AUDIT_MAC_IPSEC_DELSPD, 1,
-					       pol, NULL);
+					       AUDIT_MAC_IPSEC_EVENT, 1,
+					       pol->selector.family,
+					       pol->selector.saddr,
+					       pol->selector.daddr, 0, 0,
+					       pol->security, "SPD delete");
 
 				xfrm_policy_kill(pol);
 				killed++;
@@ -2154,44 +2168,23 @@ EXPORT_SYMBOL(xfrm_bundle_ok);
 /* Audit addition and deletion of SAs and ipsec policy */
 
 void xfrm_audit_log(uid_t auid, u32 sid, int type, int result,
-		    struct xfrm_policy *xp, struct xfrm_state *x)
+                    u16 family, xfrm_address_t saddr, xfrm_address_t daddr,
+                    __be32 spi, __be32 flowlabel, struct xfrm_sec_ctx *sctx,
+                    char *buf)
 {
-
 	char *secctx;
 	u32 secctx_len;
-	struct xfrm_sec_ctx *sctx = NULL;
 	struct audit_buffer *audit_buf;
-	int family;
 	extern int audit_enabled;
 
 	if (audit_enabled == 0)
 		return;
 
-	BUG_ON((type == AUDIT_MAC_IPSEC_ADDSA ||
-		type == AUDIT_MAC_IPSEC_DELSA) && !x);
-	BUG_ON((type == AUDIT_MAC_IPSEC_ADDSPD ||
-		type == AUDIT_MAC_IPSEC_DELSPD) && !xp);
-
 	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC, type);
 	if (audit_buf == NULL)
 		return;
 
-	switch(type) {
-	case AUDIT_MAC_IPSEC_ADDSA:
-		audit_log_format(audit_buf, "SAD add: auid=%u", auid);
-		break;
-	case AUDIT_MAC_IPSEC_DELSA:
-		audit_log_format(audit_buf, "SAD delete: auid=%u", auid);
-		break;
-	case AUDIT_MAC_IPSEC_ADDSPD:
-		audit_log_format(audit_buf, "SPD add: auid=%u", auid);
-		break;
-	case AUDIT_MAC_IPSEC_DELSPD:
-		audit_log_format(audit_buf, "SPD delete: auid=%u", auid);
-		break;
-	default:
-		return;
-	}
+	audit_log_format(audit_buf, "%s: auid=%u", buf, auid);
 
 	if (sid != 0 &&
 		security_secid_to_secctx(sid, &secctx, &secctx_len) == 0)
@@ -2199,16 +2192,6 @@ void xfrm_audit_log(uid_t auid, u32 sid,
 	else
 		audit_log_task_context(audit_buf);
 
-	if (xp) {
-		family = xp->selector.family;
-		if (xp->security)
-			sctx = xp->security;
-	} else {
-		family = x->props.family;
-		if (x->security)
-			sctx = x->security;
-	}
-
 	if (sctx)
 		audit_log_format(audit_buf,
 				" sec_alg=%u sec_doi=%u sec_obj=%s",
@@ -2216,48 +2199,24 @@ void xfrm_audit_log(uid_t auid, u32 sid,
 
 	switch(family) {
 	case AF_INET:
-		{
-			struct in_addr saddr, daddr;
-			if (xp) {
-				saddr.s_addr = xp->selector.saddr.a4;
-				daddr.s_addr = xp->selector.daddr.a4;
-			} else {
-				saddr.s_addr = x->props.saddr.a4;
-				daddr.s_addr = x->id.daddr.a4;
-			}
-			audit_log_format(audit_buf,
-					 " src=%u.%u.%u.%u dst=%u.%u.%u.%u",
-					 NIPQUAD(saddr), NIPQUAD(daddr));
-		}
-			break;
+		audit_log_format(audit_buf,
+				 " src=" NIPQUAD_FMT " dst=" NIPQUAD_FMT,
+				 NIPQUAD(saddr.a4), NIPQUAD(daddr.a4));
+		break;
 	case AF_INET6:
-		{
-			struct in6_addr saddr6, daddr6;
-			if (xp) {
-				memcpy(&saddr6, xp->selector.saddr.a6,
-					sizeof(struct in6_addr));
-				memcpy(&daddr6, xp->selector.daddr.a6,
-					sizeof(struct in6_addr));
-			} else {
-				memcpy(&saddr6, x->props.saddr.a6,
-					sizeof(struct in6_addr));
-				memcpy(&daddr6, x->id.daddr.a6,
-					sizeof(struct in6_addr));
-			}
-			audit_log_format(audit_buf,
-					 " src=" NIP6_FMT " dst=" NIP6_FMT,
-					 NIP6(saddr6), NIP6(daddr6));
-		}
+		audit_log_format(audit_buf, " src=" NIP6_FMT " dst=" NIP6_FMT,
+				 NIP6(*((struct in6_addr *)&saddr.a6)),
+				 NIP6(*((struct in6_addr *)&daddr.a6)));
 		break;
 	}
 
-	if (x)
-		audit_log_format(audit_buf, " spi=%lu(0x%lx) protocol=%s",
-				(unsigned long)ntohl(x->id.spi),
-				(unsigned long)ntohl(x->id.spi),
-				x->id.proto == IPPROTO_AH ? "AH" :
-				(x->id.proto == IPPROTO_ESP ?
-				"ESP" : "IPCOMP"));
+	if (flowlabel)
+		audit_log_format(audit_buf, " flowlabel=%u", flowlabel);
+
+	if (spi)
+		audit_log_format(audit_buf, " spi=%lu(0x%lx)",
+				(unsigned long)ntohl(spi),
+				(unsigned long)ntohl(spi));
 
 	audit_log_format(audit_buf, " res=%u", result);
 	audit_log_end(audit_buf);
diff -urpN linux-2.6.22/net/xfrm/xfrm_state.c linux-2.6.22.patch/net/xfrm/xfrm_state.c
--- linux-2.6.22/net/xfrm/xfrm_state.c	2007-07-19 13:17:23.000000000 -0500
+++ linux-2.6.22.patch/net/xfrm/xfrm_state.c	2007-07-19 13:21:30.000000000 -0500
@@ -303,7 +303,9 @@ expired:
 		km_state_expired(x, 1, 0);
 
 	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_DELSA, err ? 0 : 1, NULL, x);
+		       AUDIT_MAC_IPSEC_EVENT, err ? 0 : 1, 
+		       x->props.family, x->props.saddr, x->id.daddr, x->id.spi,
+		       0, x->security, "SAD delete");
 
 out:
 	spin_unlock(&x->lock);
@@ -406,8 +408,10 @@ xfrm_state_flush_secctx_check(u8 proto, 
 			   (err = security_xfrm_state_delete(x)) != 0) {
 				xfrm_audit_log(audit_info->loginuid,
 					       audit_info->secid,
-					       AUDIT_MAC_IPSEC_DELSA,
-                                               0, NULL, x);
+					       AUDIT_MAC_IPSEC_EVENT, 0, 
+					       x->props.family, x->props.saddr,
+					       x->id.daddr, x->id.spi, 0,
+					       x->security, "SAD delete");
 
 				return err;
 			}
@@ -446,8 +450,11 @@ restart:
 				err = xfrm_state_delete(x);
 				xfrm_audit_log(audit_info->loginuid,
 					       audit_info->secid,
-					       AUDIT_MAC_IPSEC_DELSA,
-					       err ? 0 : 1, NULL, x);
+					       AUDIT_MAC_IPSEC_EVENT, 
+					       err ? 0 : 1, x->props.family,
+					       x->props.saddr, x->id.daddr,
+					       x->id.spi, 0, x->security,
+					       "SAD delete");
 				xfrm_state_put(x);
 
 				spin_lock_bh(&xfrm_state_lock);
diff -urpN linux-2.6.22/net/xfrm/xfrm_user.c linux-2.6.22.patch/net/xfrm/xfrm_user.c
--- linux-2.6.22/net/xfrm/xfrm_user.c	2007-07-08 18:32:17.000000000 -0500
+++ linux-2.6.22.patch/net/xfrm/xfrm_user.c	2007-07-19 13:21:30.000000000 -0500
@@ -456,7 +456,9 @@ static int xfrm_add_sa(struct sk_buff *s
 		err = xfrm_state_update(x);
 
 	xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-		       AUDIT_MAC_IPSEC_ADDSA, err ? 0 : 1, NULL, x);
+		       AUDIT_MAC_IPSEC_EVENT, err ? 0 : 1, 
+		       x->props.family, x->props.saddr, x->id.daddr, 
+		       x->id.spi, 0, x->security, "SAD add");
 
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
@@ -539,7 +541,9 @@ static int xfrm_del_sa(struct sk_buff *s
 
 out:
 	xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-		       AUDIT_MAC_IPSEC_DELSA, err ? 0 : 1, NULL, x);
+		       AUDIT_MAC_IPSEC_EVENT, err ? 0 : 1, 
+		       x->props.family, x->props.saddr, x->id.daddr, 
+		       x->id.spi, 0, x->security, "SAD delete");
 	xfrm_state_put(x);
 	return err;
 }
@@ -1149,7 +1153,9 @@ static int xfrm_add_policy(struct sk_buf
 	excl = nlh->nlmsg_type == XFRM_MSG_NEWPOLICY;
 	err = xfrm_policy_insert(p->dir, xp, excl);
 	xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-		       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
+		       AUDIT_MAC_IPSEC_EVENT, err ? 0 : 1, 
+		       xp->selector.family, xp->selector.saddr, 
+		       xp->selector.daddr, 0, 0, xp->security, "SPD delete");
 
 	if (err) {
 		security_xfrm_policy_free(xp);
@@ -1395,7 +1401,10 @@ static int xfrm_get_policy(struct sk_buf
 		}
 	} else {
 		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-			       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
+			       AUDIT_MAC_IPSEC_EVENT, err ? 0 : 1, 
+			       xp->selector.family, xp->selector.saddr,
+			       xp->selector.daddr, 0, 0, xp->security,
+			       "SPD delete");
 
 		if (err != 0)
 			goto out;
@@ -1644,8 +1653,9 @@ static int xfrm_add_pol_expire(struct sk
 	if (up->hard) {
 		xfrm_policy_delete(xp, p->dir);
 		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-				AUDIT_MAC_IPSEC_DELSPD, 1, xp, NULL);
-
+			       AUDIT_MAC_IPSEC_EVENT, 1, xp->selector.family,
+			       xp->selector.saddr, xp->selector.daddr, 0, 0,
+			       xp->security, "SPD delete");
 	} else {
 		// reset the timers here?
 		printk("Dont know what to do with soft policy expire\n");
@@ -1680,7 +1690,9 @@ static int xfrm_add_sa_expire(struct sk_
 	if (ue->hard) {
 		__xfrm_state_delete(x);
 		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-			       AUDIT_MAC_IPSEC_DELSA, 1, NULL, x);
+			       AUDIT_MAC_IPSEC_EVENT, 1, x->props.family,
+			       x->props.saddr, x->id.daddr, x->id.spi, 0,
+			       x->security, "SAD delete");
 	}
 	err = 0;
 out:
