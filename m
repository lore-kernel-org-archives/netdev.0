From: Joy Latten <latten@austin.ibm.com>
Subject: [PATCH]: xfrm audit calls
Date: Tue, 11 Sep 2007 19:03:14 -0500
Message-ID: <200709120003.l8C03E4G004949@faith.austin.ibm.com>
Cc: davem@davemloft.net, linux-audit@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:39584 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753671AbXILAGj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 20:06:39 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8C06crA023430
	for <netdev@vger.kernel.org>; Tue, 11 Sep 2007 20:06:38 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8C06crI515160
	for <netdev@vger.kernel.org>; Tue, 11 Sep 2007 20:06:38 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8C06ctK004179
	for <netdev@vger.kernel.org>; Tue, 11 Sep 2007 20:06:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch modifies the current ipsec audit layer
by breaking it up into purpose driven audit calls.

So far, the only audit calls made are when add/delete
an SA/policy. It had been discussed to give each 
key manager it's own calls to do this, but I found
there to be much redundnacy since they did the exact 
same things, except for how they got auid and sid, so I 
combined them. The below audit calls can be made by any 
key manager. Hopefully, this is ok.

I compiled and tested with CONFIG_AUDITSYSCALLS on and off.

Regards,
Joy Latten

Signed-off-by: Joy Latten <latten@austin.ibm.com>

diff -urpN linux-2.6.22/include/linux/audit.h linux-2.6.22-rc6/include/linux/audit.h
--- linux-2.6.22/include/linux/audit.h	2007-09-11 13:59:49.000000000 -0500
+++ linux-2.6.22-rc6/include/linux/audit.h	2007-09-11 14:10:57.000000000 -0500
@@ -108,10 +108,11 @@
 #define AUDIT_MAC_CIPSOV4_DEL	1408	/* NetLabel: del CIPSOv4 DOI entry */
 #define AUDIT_MAC_MAP_ADD	1409	/* NetLabel: add LSM domain mapping */
 #define AUDIT_MAC_MAP_DEL	1410	/* NetLabel: del LSM domain mapping */
-#define AUDIT_MAC_IPSEC_ADDSA	1411	/* Add a XFRM state */
-#define AUDIT_MAC_IPSEC_DELSA	1412	/* Delete a XFRM state */
-#define AUDIT_MAC_IPSEC_ADDSPD	1413	/* Add a XFRM policy */
-#define AUDIT_MAC_IPSEC_DELSPD	1414	/* Delete a XFRM policy */
+#define AUDIT_MAC_IPSEC_ADDSA	1411	/* Not used */
+#define AUDIT_MAC_IPSEC_DELSA	1412	/* Not used  */
+#define AUDIT_MAC_IPSEC_ADDSPD	1413	/* Not used */
+#define AUDIT_MAC_IPSEC_DELSPD	1414	/* Not used */
+#define AUDIT_MAC_IPSEC_EVENT	1415	/* Audit an IPSec event */
 
 #define AUDIT_FIRST_KERN_ANOM_MSG   1700
 #define AUDIT_LAST_KERN_ANOM_MSG    1799
diff -urpN linux-2.6.22/include/net/xfrm.h linux-2.6.22-rc6/include/net/xfrm.h
--- linux-2.6.22/include/net/xfrm.h	2007-09-11 13:59:49.000000000 -0500
+++ linux-2.6.22-rc6/include/net/xfrm.h	2007-09-11 14:10:57.000000000 -0500
@@ -12,6 +12,7 @@
 #include <linux/ipsec.h>
 #include <linux/in6.h>
 #include <linux/mutex.h>
+#include <linux/audit.h>
 
 #include <net/sock.h>
 #include <net/dst.h>
@@ -421,15 +422,46 @@ extern unsigned int xfrm_policy_count[XF
 /* Audit Information */
 struct xfrm_audit
 {
-	uid_t	loginuid;
+	u32	loginuid;
 	u32	secid;
 };
 
 #ifdef CONFIG_AUDITSYSCALL
-extern void xfrm_audit_log(uid_t auid, u32 secid, int type, int result,
-		    struct xfrm_policy *xp, struct xfrm_state *x);
+static inline struct audit_buffer *xfrm_audit_start(u32 auid, u32 sid)
+{
+	struct audit_buffer *audit_buf = NULL;
+	char *secctx;
+	u32 secctx_len;
+
+	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC,
+			      AUDIT_MAC_IPSEC_EVENT);
+	if (audit_buf == NULL)
+		return NULL;
+
+	audit_log_format(audit_buf, "auid=%u", auid);
+
+	if (sid != 0 &&
+	    security_secid_to_secctx(sid, &secctx, &secctx_len) == 0) {
+		audit_log_format(audit_buf, " subj=%s", secctx);
+		security_release_secctx(secctx, secctx_len);
+	} else
+		audit_log_task_context(audit_buf);
+	return audit_buf;
+}
+
+extern void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,  
+				  u32 auid, u32 sid);
+extern void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,  
+				  u32 auid, u32 sid);
+extern void xfrm_audit_state_add(struct xfrm_state *x, int result,  
+				 u32 auid, u32 sid);
+extern void xfrm_audit_state_delete(struct xfrm_state *x, int result,
+				    u32 auid, u32 sid);
 #else
-#define xfrm_audit_log(a,s,t,r,p,x) do { ; } while (0)
+#define xfrm_audit_policy_add(x, r, a, s)	do { ; } while (0)
+#define xfrm_audit_policy_delete(x, r, a, s)	do { ; } while (0)
+#define xfrm_audit_state_add(x, r, a, s)	do { ; } while (0)
+#define xfrm_audit_state_delete(x, r, a, s)	do { ; } while (0)
 #endif /* CONFIG_AUDITSYSCALL */
 
 static inline void xfrm_pol_hold(struct xfrm_policy *policy)
diff -urpN linux-2.6.22/net/key/af_key.c linux-2.6.22-rc6/net/key/af_key.c
--- linux-2.6.22/net/key/af_key.c	2007-09-11 13:59:52.000000000 -0500
+++ linux-2.6.22-rc6/net/key/af_key.c	2007-09-11 14:10:58.000000000 -0500
@@ -27,7 +27,6 @@
 #include <linux/proc_fs.h>
 #include <linux/init.h>
 #include <net/xfrm.h>
-#include <linux/audit.h>
 
 #include <net/sock.h>
 
@@ -1461,8 +1460,8 @@ static int pfkey_add(struct sock *sk, st
 	else
 		err = xfrm_state_update(x);
 
-	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_ADDSA, err ? 0 : 1, NULL, x);
+	xfrm_audit_state_add(x, err ? 0 : 1, 
+			     audit_get_loginuid(current->audit_context), 0);
 
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
@@ -1515,8 +1514,8 @@ static int pfkey_delete(struct sock *sk,
 	c.event = XFRM_MSG_DELSA;
 	km_state_notify(x, &c);
 out:
-	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_DELSA, err ? 0 : 1, NULL, x);
+	xfrm_audit_state_delete(x, err ? 0 : 1, 
+			       audit_get_loginuid(current->audit_context), 0);
 	xfrm_state_put(x);
 
 	return err;
@@ -2268,8 +2267,8 @@ static int pfkey_spdadd(struct sock *sk,
 	err = xfrm_policy_insert(pol->sadb_x_policy_dir-1, xp,
 				 hdr->sadb_msg_type != SADB_X_SPDUPDATE);
 
-	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_ADDSPD, err ? 0 : 1, xp, NULL);
+	xfrm_audit_policy_add(xp, err ? 0 : 1,
+			     audit_get_loginuid(current->audit_context), 0);
 
 	if (err)
 		goto out;
@@ -2352,8 +2351,8 @@ static int pfkey_spddelete(struct sock *
 	if (xp == NULL)
 		return -ENOENT;
 
-	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
+	xfrm_audit_policy_delete(xp, err ? 0 : 1, 
+				audit_get_loginuid(current->audit_context), 0);
 
 	if (err)
 		goto out;
@@ -2613,8 +2612,8 @@ static int pfkey_spdget(struct sock *sk,
 		return -ENOENT;
 
 	if (delete) {
-		xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-			       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
+		xfrm_audit_policy_delete(xp, err ? 0 : 1, 
+				audit_get_loginuid(current->audit_context), 0);
 
 		if (err)
 			goto out;
diff -urpN linux-2.6.22/net/xfrm/xfrm_policy.c linux-2.6.22-rc6/net/xfrm/xfrm_policy.c
--- linux-2.6.22/net/xfrm/xfrm_policy.c	2007-09-11 13:59:52.000000000 -0500
+++ linux-2.6.22-rc6/net/xfrm/xfrm_policy.c	2007-09-11 14:13:05.000000000 -0500
@@ -23,7 +23,6 @@
 #include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/cache.h>
-#include <linux/audit.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
 
@@ -850,10 +849,9 @@ xfrm_policy_flush_secctx_check(u8 type, 
 				continue;
 			err = security_xfrm_policy_delete(pol);
 			if (err) {
-				xfrm_audit_log(audit_info->loginuid,
-					       audit_info->secid,
-					       AUDIT_MAC_IPSEC_DELSPD, 0,
-					       pol, NULL);
+				xfrm_audit_policy_delete(pol, 0, 
+							 audit_info->loginuid,
+							 audit_info->secid);
 				return err;
 			}
 		}
@@ -865,10 +863,9 @@ xfrm_policy_flush_secctx_check(u8 type, 
 					continue;
 				err = security_xfrm_policy_delete(pol);
 				if (err) {
-					xfrm_audit_log(audit_info->loginuid,
-						       audit_info->secid,
-						       AUDIT_MAC_IPSEC_DELSPD,
-						       0, pol, NULL);
+					xfrm_audit_policy_delete(pol, 0,  
+							audit_info->loginuid, 
+							audit_info->secid);
 					return err;
 				}
 			}
@@ -909,8 +906,8 @@ int xfrm_policy_flush(u8 type, struct xf
 			hlist_del(&pol->byidx);
 			write_unlock_bh(&xfrm_policy_lock);
 
-			xfrm_audit_log(audit_info->loginuid, audit_info->secid,
-				       AUDIT_MAC_IPSEC_DELSPD, 1, pol, NULL);
+			xfrm_audit_policy_delete(pol, 1, audit_info->loginuid,
+						 audit_info->secid);
 
 			xfrm_policy_kill(pol);
 			killed++;
@@ -930,11 +927,9 @@ int xfrm_policy_flush(u8 type, struct xf
 				hlist_del(&pol->byidx);
 				write_unlock_bh(&xfrm_policy_lock);
 
-				xfrm_audit_log(audit_info->loginuid,
-					       audit_info->secid,
-					       AUDIT_MAC_IPSEC_DELSPD, 1,
-					       pol, NULL);
-
+				xfrm_audit_policy_delete(pol, 1,
+							 audit_info->loginuid, 
+							 audit_info->secid);
 				xfrm_policy_kill(pol);
 				killed++;
 
@@ -2150,123 +2145,6 @@ int xfrm_bundle_ok(struct xfrm_policy *p
 
 EXPORT_SYMBOL(xfrm_bundle_ok);
 
-#ifdef CONFIG_AUDITSYSCALL
-/* Audit addition and deletion of SAs and ipsec policy */
-
-void xfrm_audit_log(uid_t auid, u32 sid, int type, int result,
-		    struct xfrm_policy *xp, struct xfrm_state *x)
-{
-
-	char *secctx;
-	u32 secctx_len;
-	struct xfrm_sec_ctx *sctx = NULL;
-	struct audit_buffer *audit_buf;
-	int family;
-	extern int audit_enabled;
-
-	if (audit_enabled == 0)
-		return;
-
-	BUG_ON((type == AUDIT_MAC_IPSEC_ADDSA ||
-		type == AUDIT_MAC_IPSEC_DELSA) && !x);
-	BUG_ON((type == AUDIT_MAC_IPSEC_ADDSPD ||
-		type == AUDIT_MAC_IPSEC_DELSPD) && !xp);
-
-	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC, type);
-	if (audit_buf == NULL)
-		return;
-
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
-
-	if (sid != 0 &&
-	    security_secid_to_secctx(sid, &secctx, &secctx_len) == 0) {
-		audit_log_format(audit_buf, " subj=%s", secctx);
-		security_release_secctx(secctx, secctx_len);
-	} else
-		audit_log_task_context(audit_buf);
-
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
-	if (sctx)
-		audit_log_format(audit_buf,
-				" sec_alg=%u sec_doi=%u sec_obj=%s",
-				sctx->ctx_alg, sctx->ctx_doi, sctx->ctx_str);
-
-	switch(family) {
-	case AF_INET:
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
-	case AF_INET6:
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
-		break;
-	}
-
-	if (x)
-		audit_log_format(audit_buf, " spi=%lu(0x%lx) protocol=%s",
-				(unsigned long)ntohl(x->id.spi),
-				(unsigned long)ntohl(x->id.spi),
-				x->id.proto == IPPROTO_AH ? "AH" :
-				(x->id.proto == IPPROTO_ESP ?
-				"ESP" : "IPCOMP"));
-
-	audit_log_format(audit_buf, " res=%u", result);
-	audit_log_end(audit_buf);
-}
-
-EXPORT_SYMBOL(xfrm_audit_log);
-#endif /* CONFIG_AUDITSYSCALL */
-
 int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 {
 	int err = 0;
@@ -2412,6 +2290,70 @@ void __init xfrm_init(void)
 	xfrm_input_init();
 }
 
+#ifdef CONFIG_AUDITSYSCALL
+static inline void xfrm_audit_common_policyinfo(struct xfrm_policy *xp,
+						struct audit_buffer *audit_buf)
+{
+	if (xp->security)
+		audit_log_format(audit_buf, " sec_alg=%u sec_doi=%u sec_obj=%s",
+				 xp->security->ctx_alg, xp->security->ctx_doi,
+				 xp->security->ctx_str);
+
+	switch(xp->selector.family) {
+	case AF_INET:
+		audit_log_format(audit_buf, " src=%u.%u.%u.%u dst=%u.%u.%u.%u",
+				 NIPQUAD(xp->selector.saddr.a4),
+				 NIPQUAD(xp->selector.daddr.a4));
+		break;
+	case AF_INET6:
+		{
+			struct in6_addr saddr6, daddr6;
+
+			memcpy(&saddr6, xp->selector.saddr.a6,
+				sizeof(struct in6_addr));
+			memcpy(&daddr6, xp->selector.daddr.a6,
+				sizeof(struct in6_addr));
+			audit_log_format(audit_buf,
+				" src=" NIP6_FMT " dst=" NIP6_FMT,
+				NIP6(saddr6), NIP6(daddr6));
+		}
+		break;
+	}
+}
+
+void 
+xfrm_audit_policy_add(struct xfrm_policy *xp, int result, u32 auid, u32 sid)
+{
+	struct audit_buffer *audit_buf;
+	extern int audit_enabled;
+
+	if (audit_enabled == 0)
+		return;
+	audit_buf = xfrm_audit_start(sid, auid);
+	if (audit_buf == NULL)
+		return;
+	audit_log_format(audit_buf, " op=SPD-add res=%u", result);
+	xfrm_audit_common_policyinfo(xp, audit_buf);
+	audit_log_end(audit_buf);
+}
+
+void 
+xfrm_audit_policy_delete(struct xfrm_policy *xp, int result, u32 auid, u32 sid)
+{
+	struct audit_buffer *audit_buf;
+	extern int audit_enabled;
+
+	if (audit_enabled == 0)
+		return;
+	audit_buf = xfrm_audit_start(sid, auid);
+	if (audit_buf == NULL)
+		return;
+	audit_log_format(audit_buf, " op=SPD-delete res=%u", result);
+	xfrm_audit_common_policyinfo(xp, audit_buf);
+	audit_log_end(audit_buf);
+}
+#endif
+
 #ifdef CONFIG_XFRM_MIGRATE
 static int xfrm_migrate_selector_match(struct xfrm_selector *sel_cmp,
 				       struct xfrm_selector *sel_tgt)
diff -urpN linux-2.6.22/net/xfrm/xfrm_state.c linux-2.6.22-rc6/net/xfrm/xfrm_state.c
--- linux-2.6.22/net/xfrm/xfrm_state.c	2007-09-11 13:59:52.000000000 -0500
+++ linux-2.6.22-rc6/net/xfrm/xfrm_state.c	2007-09-11 14:12:37.000000000 -0500
@@ -19,7 +19,6 @@
 #include <linux/ipsec.h>
 #include <linux/module.h>
 #include <linux/cache.h>
-#include <linux/audit.h>
 #include <asm/uaccess.h>
 
 #include "xfrm_hash.h"
@@ -301,8 +300,8 @@ expired:
 	if (!err && x->id.spi)
 		km_state_expired(x, 1, 0);
 
-	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_DELSA, err ? 0 : 1, NULL, x);
+	xfrm_audit_state_delete(x, err ? 0 : 1, 
+				audit_get_loginuid(current->audit_context), 0); 
 
 out:
 	spin_unlock(&x->lock);
@@ -403,11 +402,9 @@ xfrm_state_flush_secctx_check(u8 proto, 
 		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
 			if (xfrm_id_proto_match(x->id.proto, proto) &&
 			   (err = security_xfrm_state_delete(x)) != 0) {
-				xfrm_audit_log(audit_info->loginuid,
-					       audit_info->secid,
-					       AUDIT_MAC_IPSEC_DELSA,
-					       0, NULL, x);
-
+				xfrm_audit_state_delete(x, 0, 
+							audit_info->loginuid,
+							audit_info->secid);
 				return err;
 			}
 		}
@@ -443,10 +440,9 @@ restart:
 				spin_unlock_bh(&xfrm_state_lock);
 
 				err = xfrm_state_delete(x);
-				xfrm_audit_log(audit_info->loginuid,
-					       audit_info->secid,
-					       AUDIT_MAC_IPSEC_DELSA,
-					       err ? 0 : 1, NULL, x);
+				xfrm_audit_state_delete(x, err ? 0 : 1,
+							audit_info->loginuid, 
+							audit_info->secid);
 				xfrm_state_put(x);
 
 				spin_lock_bh(&xfrm_state_lock);
@@ -1821,3 +1817,70 @@ void __init xfrm_state_init(void)
 	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task);
 }
 
+#ifdef CONFIG_AUDITSYSCALL
+static inline void xfrm_audit_common_stateinfo(struct xfrm_state *x,
+					       struct audit_buffer *audit_buf)
+{
+	if (x->security)
+		audit_log_format(audit_buf, " sec_alg=%u sec_doi=%u sec_obj=%s",
+				 x->security->ctx_alg, x->security->ctx_doi,
+				 x->security->ctx_str);
+
+	switch(x->props.family) {
+	case AF_INET:
+		audit_log_format(audit_buf, " src=%u.%u.%u.%u dst=%u.%u.%u.%u",
+				 NIPQUAD(x->props.saddr.a4),
+				 NIPQUAD(x->id.daddr.a4));
+		break;
+	case AF_INET6:
+		{
+			struct in6_addr saddr6, daddr6;
+
+			memcpy(&saddr6, x->props.saddr.a6,
+				sizeof(struct in6_addr));
+			memcpy(&daddr6, x->id.daddr.a6,
+				sizeof(struct in6_addr));
+			audit_log_format(audit_buf,
+					 " src=" NIP6_FMT " dst=" NIP6_FMT,
+					 NIP6(saddr6), NIP6(daddr6));
+		}
+		break;
+	}
+}
+
+void 
+xfrm_audit_state_add(struct xfrm_state *x, int result, u32 auid, u32 sid)
+{
+	struct audit_buffer *audit_buf;
+	extern int audit_enabled;
+
+	if (audit_enabled == 0)
+		return;
+	audit_buf = xfrm_audit_start(sid, auid);
+	if (audit_buf == NULL)
+		return;
+	audit_log_format(audit_buf, " op=SAD-add res=%u",result);
+	xfrm_audit_common_stateinfo(x, audit_buf);
+	audit_log_format(audit_buf, " spi=%lu(0x%lx)", 
+			 (unsigned long)x->id.spi, (unsigned long)x->id.spi);
+	audit_log_end(audit_buf);
+}
+
+void 
+xfrm_audit_state_delete(struct xfrm_state *x, int result, u32 auid, u32 sid)
+{
+	struct audit_buffer *audit_buf;
+	extern int audit_enabled;
+
+	if (audit_enabled == 0)
+		return;
+	audit_buf = xfrm_audit_start(sid, auid);
+	if (audit_buf == NULL)
+		return;
+	audit_log_format(audit_buf, " op=SAD-delete res=%u",result);
+	xfrm_audit_common_stateinfo(x, audit_buf);
+	audit_log_format(audit_buf, " spi=%lu(0x%lx)", 
+			 (unsigned long)x->id.spi, (unsigned long)x->id.spi);
+	audit_log_end(audit_buf);
+}
+#endif /* CONFIG_AUDITSYSCALL */
diff -urpN linux-2.6.22/net/xfrm/xfrm_user.c linux-2.6.22-rc6/net/xfrm/xfrm_user.c
--- linux-2.6.22/net/xfrm/xfrm_user.c	2007-09-11 13:59:52.000000000 -0500
+++ linux-2.6.22-rc6/net/xfrm/xfrm_user.c	2007-09-11 14:10:58.000000000 -0500
@@ -31,7 +31,6 @@
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #include <linux/in6.h>
 #endif
-#include <linux/audit.h>
 
 static int verify_one_alg(struct rtattr **xfrma, enum xfrm_attr_type_t type)
 {
@@ -462,8 +461,8 @@ static int xfrm_add_sa(struct sk_buff *s
 	else
 		err = xfrm_state_update(x);
 
-	xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-		       AUDIT_MAC_IPSEC_ADDSA, err ? 0 : 1, NULL, x);
+	xfrm_audit_state_add(x, err ? 0 : 1, NETLINK_CB(skb).loginuid, 
+			     NETLINK_CB(skb).sid); 
 
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
@@ -545,8 +544,8 @@ static int xfrm_del_sa(struct sk_buff *s
 	km_state_notify(x, &c);
 
 out:
-	xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-		       AUDIT_MAC_IPSEC_DELSA, err ? 0 : 1, NULL, x);
+	xfrm_audit_state_delete(x, err ? 0 : 1, NETLINK_CB(skb).loginuid, 
+				NETLINK_CB(skb).sid); 
 	xfrm_state_put(x);
 	return err;
 }
@@ -1155,8 +1154,8 @@ static int xfrm_add_policy(struct sk_buf
 	 * a type XFRM_MSG_UPDPOLICY - JHS */
 	excl = nlh->nlmsg_type == XFRM_MSG_NEWPOLICY;
 	err = xfrm_policy_insert(p->dir, xp, excl);
-	xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-		       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
+	xfrm_audit_policy_add(xp, err ? 0 : 1, NETLINK_CB(skb).loginuid,
+			      NETLINK_CB(skb).sid); 
 
 	if (err) {
 		security_xfrm_policy_free(xp);
@@ -1401,8 +1400,9 @@ static int xfrm_get_policy(struct sk_buf
 					      MSG_DONTWAIT);
 		}
 	} else {
-		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-			       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
+		xfrm_audit_policy_delete(xp, err ? 0 : 1, 
+					 NETLINK_CB(skb).loginuid, 
+					 NETLINK_CB(skb).sid);
 
 		if (err != 0)
 			goto out;
@@ -1650,8 +1650,8 @@ static int xfrm_add_pol_expire(struct sk
 	err = 0;
 	if (up->hard) {
 		xfrm_policy_delete(xp, p->dir);
-		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-				AUDIT_MAC_IPSEC_DELSPD, 1, xp, NULL);
+		xfrm_audit_policy_delete(xp, 1, NETLINK_CB(skb).loginuid,
+					 NETLINK_CB(skb).sid);
 
 	} else {
 		// reset the timers here?
@@ -1686,8 +1686,8 @@ static int xfrm_add_sa_expire(struct sk_
 
 	if (ue->hard) {
 		__xfrm_state_delete(x);
-		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-			       AUDIT_MAC_IPSEC_DELSA, 1, NULL, x);
+		xfrm_audit_state_delete(x, 1, NETLINK_CB(skb).loginuid, 
+					NETLINK_CB(skb).sid);
 	}
 	err = 0;
 out:
