From: Joy Latten <latten@austin.ibm.com>
Subject: [PATCH 1/1] additional change to ipsec audit
Date: Thu, 30 Nov 2006 15:50:43 -0600
Message-ID: <200611302150.kAULoh8o008591@faith.austin.ibm.com>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	jmorris@namei.org, sgrubb@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:22944 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S967942AbWK3WEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 17:04:15 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kAUM4Ex1018892
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 17:04:14 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAUM4EHm240428
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 17:04:14 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAUM4Dxh019524
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 17:04:14 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry! Sign off included this time. 

This patch disables auditing in ipsec when CONFIG_AUDITSYSCALL is
disabled in the kernel. 

This patch also includes a bug fix for xfrm_state.c as a result of
original ipsec audit patch.

regards,
Joy

Signed-off-by: Joy Latten latten@austin.ibm.com

---------------------------------------------------------------------------
diff -urpN linux-2.6.18-patch/include/net/xfrm.h linux-2.6.18-patch.2/include/net/xfrm.h
--- linux-2.6.18-patch/include/net/xfrm.h	2006-11-27 12:29:11.000000000 -0600
+++ linux-2.6.18-patch.2/include/net/xfrm.h	2006-11-28 13:26:49.000000000 -0600
@@ -395,8 +395,13 @@ struct xfrm_audit
 	uid_t	loginuid;
 	u32	secid;
 };
-void xfrm_audit_log(uid_t auid, u32 secid, int type, int result,
+
+#ifdef CONFIG_AUDITSYSCALL
+extern void xfrm_audit_log(uid_t auid, u32 secid, int type, int result,
 		    struct xfrm_policy *xp, struct xfrm_state *x);
+#else
+#define xfrm_audit_log(a,s,t,r,p,x) do { ; } while (0)
+#endif /* CONFIG_AUDITSYSCALL */
 
 static inline void xfrm_pol_hold(struct xfrm_policy *policy)
 {
diff -urpN linux-2.6.18-patch/net/xfrm/xfrm_policy.c linux-2.6.18-patch.2/net/xfrm/xfrm_policy.c
--- linux-2.6.18-patch/net/xfrm/xfrm_policy.c	2006-11-27 12:29:33.000000000 -0600
+++ linux-2.6.18-patch.2/net/xfrm/xfrm_policy.c	2006-11-28 14:51:09.000000000 -0600
@@ -1955,6 +1955,7 @@ int xfrm_bundle_ok(struct xfrm_policy *p
 
 EXPORT_SYMBOL(xfrm_bundle_ok);
 
+#ifdef CONFIG_AUDITSYSCALL
 /* Audit addition and deletion of SAs and ipsec policy */
 
 void xfrm_audit_log(uid_t auid, u32 sid, int type, int result,
@@ -2063,6 +2064,7 @@ void xfrm_audit_log(uid_t auid, u32 sid,
 }
 
 EXPORT_SYMBOL(xfrm_audit_log);
+#endif /* CONFIG_AUDITSYSCALL */
 
 int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 {
diff -urpN linux-2.6.18-patch/net/xfrm/xfrm_state.c linux-2.6.18-patch.2/net/xfrm/xfrm_state.c
--- linux-2.6.18-patch/net/xfrm/xfrm_state.c	2006-11-27 12:29:33.000000000 -0600
+++ linux-2.6.18-patch.2/net/xfrm/xfrm_state.c	2006-11-28 12:58:56.000000000 -0600
@@ -407,7 +407,6 @@ restart:
 				xfrm_state_hold(x);
 				spin_unlock_bh(&xfrm_state_lock);
 
-				xfrm_state_delete(x);
 				err = xfrm_state_delete(x);
 				xfrm_audit_log(audit_info->loginuid,
 					       audit_info->secid,
