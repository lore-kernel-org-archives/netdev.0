From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH] improved xfrm_audit_log() patch
Date: Wed, 15 Aug 2007 11:16:29 -0500
Message-ID: <200708151616.l7FGGTk9001632@faith.austin.ibm.com>
Cc: davem@davemloft.net, linux-audit@redhat.com, sgrubb@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:45208 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757720AbXHOQTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 12:19:11 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7FGJAJR008548
	for <netdev@vger.kernel.org>; Wed, 15 Aug 2007 12:19:10 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l7FGJA6V549406
	for <netdev@vger.kernel.org>; Wed, 15 Aug 2007 12:19:10 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7FGJ9tD011302
	for <netdev@vger.kernel.org>; Wed, 15 Aug 2007 12:19:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-08-07 at 18:32 -0700, David Miller wrote:
>From: Joy Latten <latten@austin.ibm.com>
>Date: Thu, 2 Aug 2007 15:56:47 -0500
>
>> @@ -426,10 +426,15 @@ struct xfrm_audit
>>  };
>>  
>>  #ifdef CONFIG_AUDITSYSCALL
>> -extern void xfrm_audit_log(uid_t auid, u32 secid, int type, int result,
>> -		    struct xfrm_policy *xp, struct xfrm_state *x);
>> +extern void xfrm_audit_log(struct xfrm_audit audit_info, int result,
>> +			   __be32 flowid, struct xfrm_policy *xp, 
>> +			   struct xfrm_state *x, char *buf);
>
>Passing audit_info as an aggregate argument puts them into
>previous argument registers, or if they are not enough it
>goes either partially of wholly onto the stack, depending
>upon architecture.
>
>In fact you've made the argument register usage worse than
>in your previous revision. :-/
>
>Perhaps you meant to pass "struct xfrm_audit *" instead?

Revised patch to pass pointer to struct xfrm_audit.
Sorry, I missed that.

Signed-off-by: Joy Latten <latten@austin.ibm.com>


diff -urpN linux-2.6.22/include/linux/audit.h linux-2.6.22.patch/include/linux/audit.h
--- linux-2.6.22/include/linux/audit.h	2007-08-14 18:13:53.000000000 -0500
+++ linux-2.6.22.patch/include/linux/audit.h	2007-08-14 19:08:42.000000000 -0500
@@ -112,6 +112,7 @@
 #define AUDIT_MAC_IPSEC_DELSA	1412	/* Delete a XFRM state */
 #define AUDIT_MAC_IPSEC_ADDSPD	1413	/* Add a XFRM policy */
 #define AUDIT_MAC_IPSEC_DELSPD	1414	/* Delete a XFRM policy */
+#define AUDIT_MAC_IPSEC_EVENT	1415	/* Audit IPSec events */
 
 #define AUDIT_FIRST_KERN_ANOM_MSG   1700
 #define AUDIT_LAST_KERN_ANOM_MSG    1799
diff -urpN linux-2.6.22/include/net/xfrm.h linux-2.6.22.patch/include/net/xfrm.h
--- linux-2.6.22/include/net/xfrm.h	2007-08-14 18:13:53.000000000 -0500
+++ linux-2.6.22.patch/include/net/xfrm.h	2007-08-14 19:08:42.000000000 -0500
@@ -426,10 +426,15 @@ struct xfrm_audit
 };
 
 #ifdef CONFIG_AUDITSYSCALL
-extern void xfrm_audit_log(uid_t auid, u32 secid, int type, int result,
-		    struct xfrm_policy *xp, struct xfrm_state *x);
+extern void xfrm_audit_log(struct xfrm_audit *audit_info, int result,
+			   __be32 flowid, struct xfrm_policy *xp, 
+			   struct xfrm_state *x, char *buf);
+
+extern void xfrm_get_auditinfo(struct sk_buff *skb, 
+			       struct xfrm_audit *audit_info);
 #else
-#define xfrm_audit_log(a,s,t,r,p,x) do { ; } while (0)
+#define xfrm_audit_log(a,r,f,p,s,b) do { ; } while (0)
+#define xfrm_get_auditinfo(s, a) do { ; } while (0)
 #endif /* CONFIG_AUDITSYSCALL */
 
 static inline void xfrm_pol_hold(struct xfrm_policy *policy)
diff -urpN linux-2.6.22/net/key/af_key.c linux-2.6.22.patch/net/key/af_key.c
--- linux-2.6.22/net/key/af_key.c	2007-08-14 18:13:53.000000000 -0500
+++ linux-2.6.22.patch/net/key/af_key.c	2007-08-14 19:08:42.000000000 -0500
@@ -1450,6 +1450,7 @@ static int pfkey_add(struct sock *sk, st
 	struct xfrm_state *x;
 	int err;
 	struct km_event c;
+	struct xfrm_audit audit_info;
 
 	x = pfkey_msg2xfrm_state(hdr, ext_hdrs);
 	if (IS_ERR(x))
@@ -1461,8 +1462,8 @@ static int pfkey_add(struct sock *sk, st
 	else
 		err = xfrm_state_update(x);
 
-	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_ADDSA, err ? 0 : 1, NULL, x);
+	xfrm_get_auditinfo(0, &audit_info);
+	xfrm_audit_log(&audit_info, err ? 0 : 1, 0, 0, x, "SAD-add");
 
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
@@ -1487,6 +1488,7 @@ static int pfkey_delete(struct sock *sk,
 	struct xfrm_state *x;
 	struct km_event c;
 	int err;
+	struct xfrm_audit audit_info;
 
 	if (!ext_hdrs[SADB_EXT_SA-1] ||
 	    !present_and_same_family(ext_hdrs[SADB_EXT_ADDRESS_SRC-1],
@@ -1515,8 +1517,9 @@ static int pfkey_delete(struct sock *sk,
 	c.event = XFRM_MSG_DELSA;
 	km_state_notify(x, &c);
 out:
-	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_DELSA, err ? 0 : 1, NULL, x);
+	xfrm_get_auditinfo(0, &audit_info);
+	xfrm_audit_log(&audit_info, err ? 0 : 1, 0, 0, x, "SAD-delete");
+
 	xfrm_state_put(x);
 
 	return err;
@@ -1691,8 +1694,7 @@ static int pfkey_flush(struct sock *sk, 
 	if (proto == 0)
 		return -EINVAL;
 
-	audit_info.loginuid = audit_get_loginuid(current->audit_context);
-	audit_info.secid = 0;
+	xfrm_get_auditinfo(0, &audit_info);
 	err = xfrm_state_flush(proto, &audit_info);
 	if (err)
 		return err;
@@ -2182,6 +2184,7 @@ static int pfkey_spdadd(struct sock *sk,
 	struct xfrm_policy *xp;
 	struct km_event c;
 	struct sadb_x_sec_ctx *sec_ctx;
+	struct xfrm_audit audit_info;
 
 	if (!present_and_same_family(ext_hdrs[SADB_EXT_ADDRESS_SRC-1],
 				     ext_hdrs[SADB_EXT_ADDRESS_DST-1]) ||
@@ -2268,8 +2271,8 @@ static int pfkey_spdadd(struct sock *sk,
 	err = xfrm_policy_insert(pol->sadb_x_policy_dir-1, xp,
 				 hdr->sadb_msg_type != SADB_X_SPDUPDATE);
 
-	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_ADDSPD, err ? 0 : 1, xp, NULL);
+	xfrm_get_auditinfo(0, &audit_info);
+	xfrm_audit_log(&audit_info, err ? 0 : 1, 0, xp, 0, "SPD-add");
 
 	if (err)
 		goto out;
@@ -2301,6 +2304,7 @@ static int pfkey_spddelete(struct sock *
 	struct xfrm_selector sel;
 	struct km_event c;
 	struct sadb_x_sec_ctx *sec_ctx;
+	struct xfrm_audit audit_info;
 
 	if (!present_and_same_family(ext_hdrs[SADB_EXT_ADDRESS_SRC-1],
 				     ext_hdrs[SADB_EXT_ADDRESS_DST-1]) ||
@@ -2352,8 +2356,8 @@ static int pfkey_spddelete(struct sock *
 	if (xp == NULL)
 		return -ENOENT;
 
-	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
+	xfrm_get_auditinfo(0, &audit_info);
+	xfrm_audit_log(&audit_info, err ? 0 : 1, 0, xp, 0, "SPD-delete");
 
 	if (err)
 		goto out;
@@ -2613,8 +2617,10 @@ static int pfkey_spdget(struct sock *sk,
 		return -ENOENT;
 
 	if (delete) {
-		xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-			       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
+		struct xfrm_audit audit_info;
+	
+		xfrm_get_auditinfo(0, &audit_info);
+		xfrm_audit_log(&audit_info, err ? 0 : 1, 0, xp, 0, "SPD-delete");
 
 		if (err)
 			goto out;
@@ -2691,8 +2697,7 @@ static int pfkey_spdflush(struct sock *s
 	struct xfrm_audit audit_info;
 	int err;
 
-	audit_info.loginuid = audit_get_loginuid(current->audit_context);
-	audit_info.secid = 0;
+	xfrm_get_auditinfo(0, &audit_info);
 	err = xfrm_policy_flush(XFRM_POLICY_TYPE_MAIN, &audit_info);
 	if (err)
 		return err;
diff -urpN linux-2.6.22/net/xfrm/xfrm_policy.c linux-2.6.22.patch/net/xfrm/xfrm_policy.c
--- linux-2.6.22/net/xfrm/xfrm_policy.c	2007-08-14 18:14:51.000000000 -0500
+++ linux-2.6.22.patch/net/xfrm/xfrm_policy.c	2007-08-14 19:08:42.000000000 -0500
@@ -850,10 +850,8 @@ xfrm_policy_flush_secctx_check(u8 type, 
 				continue;
 			err = security_xfrm_policy_delete(pol);
 			if (err) {
-				xfrm_audit_log(audit_info->loginuid,
-					       audit_info->secid,
-					       AUDIT_MAC_IPSEC_DELSPD, 0,
-					       pol, NULL);
+				xfrm_audit_log(audit_info, 0, 0,
+					       pol, 0, "SPD-delete");
 				return err;
 			}
 		}
@@ -865,10 +863,8 @@ xfrm_policy_flush_secctx_check(u8 type, 
 					continue;
 				err = security_xfrm_policy_delete(pol);
 				if (err) {
-					xfrm_audit_log(audit_info->loginuid,
-						       audit_info->secid,
-						       AUDIT_MAC_IPSEC_DELSPD,
-						       0, pol, NULL);
+					xfrm_audit_log(audit_info, 0, 0,
+						       pol, 0, "SPD-delete");
 					return err;
 				}
 			}
@@ -909,8 +905,7 @@ int xfrm_policy_flush(u8 type, struct xf
 			hlist_del(&pol->byidx);
 			write_unlock_bh(&xfrm_policy_lock);
 
-			xfrm_audit_log(audit_info->loginuid, audit_info->secid,
-				       AUDIT_MAC_IPSEC_DELSPD, 1, pol, NULL);
+			xfrm_audit_log(audit_info, 1, 0, pol, 0, "SPD-delete");
 
 			xfrm_policy_kill(pol);
 			killed++;
@@ -930,10 +925,8 @@ int xfrm_policy_flush(u8 type, struct xf
 				hlist_del(&pol->byidx);
 				write_unlock_bh(&xfrm_policy_lock);
 
-				xfrm_audit_log(audit_info->loginuid,
-					       audit_info->secid,
-					       AUDIT_MAC_IPSEC_DELSPD, 1,
-					       pol, NULL);
+				xfrm_audit_log(audit_info, 1, 0, pol, 0, 
+					       "SPD-delete");
 
 				xfrm_policy_kill(pol);
 				killed++;
@@ -2151,114 +2144,88 @@ int xfrm_bundle_ok(struct xfrm_policy *p
 EXPORT_SYMBOL(xfrm_bundle_ok);
 
 #ifdef CONFIG_AUDITSYSCALL
-/* Audit addition and deletion of SAs and ipsec policy */
+/* Audit ipsec events */
 
-void xfrm_audit_log(uid_t auid, u32 sid, int type, int result,
-		    struct xfrm_policy *xp, struct xfrm_state *x)
+void xfrm_get_auditinfo(struct sk_buff *skb, struct xfrm_audit *audit_info)
 {
+	if (skb) {
+		audit_info->secid = NETLINK_CB(skb).sid;
+		audit_info->loginuid = NETLINK_CB(skb).loginuid;
+	} else {
+		audit_info->loginuid =
+			audit_get_loginuid(current->audit_context);
+		audit_info->secid = 0;
+	}
+}
+
+EXPORT_SYMBOL(xfrm_get_auditinfo);
+
+static void do_xfrm_audit_log(struct audit_buffer *audit_buf,
+			      u16 family, xfrm_address_t saddr,
+			      xfrm_address_t daddr, struct xfrm_sec_ctx *sctx,
+			      __be32 spi)
+{
+	if (sctx)
+		audit_log_format(audit_buf,
+				" sec_alg=%u sec_doi=%u sec_obj=%s",
+				sctx->ctx_alg, sctx->ctx_doi, sctx->ctx_str);
+
+	switch(family) {
+	case AF_INET:
+		audit_log_format(audit_buf,
+				 " src=" NIPQUAD_FMT " dst=" NIPQUAD_FMT,
+				 NIPQUAD(saddr.a4), NIPQUAD(daddr.a4));
+		break;
+	case AF_INET6:
+		audit_log_format(audit_buf, " src=" NIP6_FMT " dst=" NIP6_FMT,
+				 NIP6(*((struct in6_addr *)&saddr.a6)),
+				 NIP6(*((struct in6_addr *)&daddr.a6)));
+		break;
+	}
+
+	if (spi)
+		audit_log_format(audit_buf, " spi=%lu(0x%lx)",
+				(unsigned long)ntohl(spi),
+				(unsigned long)ntohl(spi));
+}
 
+void xfrm_audit_log(struct xfrm_audit *audit_info, int result,
+		    __be32 flowlabel, struct xfrm_policy *xp,
+		    struct xfrm_state *x, char *buf)
+{
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
-	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC, type);
+	audit_buf = audit_log_start(current->audit_context, GFP_ATOMIC,
+				    AUDIT_MAC_IPSEC_EVENT);
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
+	audit_log_format(audit_buf, "op=%s auid=%u", buf, audit_info->loginuid);
 
-	if (sid != 0 &&
-	    security_secid_to_secctx(sid, &secctx, &secctx_len) == 0) {
+	if (audit_info->secid != 0 &&
+		security_secid_to_secctx(audit_info->secid, &secctx,
+					 &secctx_len) == 0)
 		audit_log_format(audit_buf, " subj=%s", secctx);
-		security_release_secctx(secctx, secctx_len);
-	} else
+	else
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
+	if (xp)
+		do_xfrm_audit_log(audit_buf, xp->selector.family,
+				  xp->selector.saddr, xp->selector.daddr,
+				  xp->security, 0);
 
 	if (x)
-		audit_log_format(audit_buf, " spi=%lu(0x%lx) protocol=%s",
-				(unsigned long)ntohl(x->id.spi),
-				(unsigned long)ntohl(x->id.spi),
-				x->id.proto == IPPROTO_AH ? "AH" :
-				(x->id.proto == IPPROTO_ESP ?
-				"ESP" : "IPCOMP"));
+		do_xfrm_audit_log(audit_buf, x->props.family, x->props.saddr,
+				  x->id.daddr, x->security, x->id.spi);
+
+	if (flowlabel)
+		audit_log_format(audit_buf, " flowlabel=%u", flowlabel);
 
 	audit_log_format(audit_buf, " res=%u", result);
 	audit_log_end(audit_buf);
diff -urpN linux-2.6.22/net/xfrm/xfrm_state.c linux-2.6.22.patch/net/xfrm/xfrm_state.c
--- linux-2.6.22/net/xfrm/xfrm_state.c	2007-08-14 18:14:51.000000000 -0500
+++ linux-2.6.22.patch/net/xfrm/xfrm_state.c	2007-08-14 19:08:42.000000000 -0500
@@ -239,6 +239,7 @@ static void xfrm_timer_handler(unsigned 
 	long next = LONG_MAX;
 	int warn = 0;
 	int err = 0;
+	struct xfrm_audit audit_info;
 
 	spin_lock(&x->lock);
 	if (x->km.state == XFRM_STATE_DEAD)
@@ -301,8 +302,9 @@ expired:
 	if (!err && x->id.spi)
 		km_state_expired(x, 1, 0);
 
-	xfrm_audit_log(audit_get_loginuid(current->audit_context), 0,
-		       AUDIT_MAC_IPSEC_DELSA, err ? 0 : 1, NULL, x);
+	
+	xfrm_get_auditinfo(0, &audit_info);
+	xfrm_audit_log(&audit_info, err ? 0 : 1, 0, 0, x, "SAD-delete");
 
 out:
 	spin_unlock(&x->lock);
@@ -403,11 +405,8 @@ xfrm_state_flush_secctx_check(u8 proto, 
 		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
 			if (xfrm_id_proto_match(x->id.proto, proto) &&
 			   (err = security_xfrm_state_delete(x)) != 0) {
-				xfrm_audit_log(audit_info->loginuid,
-					       audit_info->secid,
-					       AUDIT_MAC_IPSEC_DELSA,
-					       0, NULL, x);
-
+				xfrm_audit_log(audit_info, 0, 0, 0, x,
+					       "SAD-delete");
 				return err;
 			}
 		}
@@ -443,10 +442,8 @@ restart:
 				spin_unlock_bh(&xfrm_state_lock);
 
 				err = xfrm_state_delete(x);
-				xfrm_audit_log(audit_info->loginuid,
-					       audit_info->secid,
-					       AUDIT_MAC_IPSEC_DELSA,
-					       err ? 0 : 1, NULL, x);
+				xfrm_audit_log(audit_info, err ? 0 : 1, 0,
+					       0, x, "SAD-delete");
 				xfrm_state_put(x);
 
 				spin_lock_bh(&xfrm_state_lock);
diff -urpN linux-2.6.22/net/xfrm/xfrm_user.c linux-2.6.22.patch/net/xfrm/xfrm_user.c
--- linux-2.6.22/net/xfrm/xfrm_user.c	2007-08-14 18:13:54.000000000 -0500
+++ linux-2.6.22.patch/net/xfrm/xfrm_user.c	2007-08-14 19:09:14.000000000 -0500
@@ -447,6 +447,7 @@ static int xfrm_add_sa(struct sk_buff *s
 	struct xfrm_state *x;
 	int err;
 	struct km_event c;
+	struct xfrm_audit audit_info;
 
 	err = verify_newsa_info(p, xfrma);
 	if (err)
@@ -462,8 +463,8 @@ static int xfrm_add_sa(struct sk_buff *s
 	else
 		err = xfrm_state_update(x);
 
-	xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-		       AUDIT_MAC_IPSEC_ADDSA, err ? 0 : 1, NULL, x);
+	xfrm_get_auditinfo(skb, &audit_info);
+	xfrm_audit_log(&audit_info, err ? 0 : 1, 0, 0, x, "SAD-add");
 
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
@@ -521,6 +522,7 @@ static int xfrm_del_sa(struct sk_buff *s
 	int err = -ESRCH;
 	struct km_event c;
 	struct xfrm_usersa_id *p = NLMSG_DATA(nlh);
+	struct xfrm_audit audit_info;
 
 	x = xfrm_user_state_lookup(p, xfrma, &err);
 	if (x == NULL)
@@ -545,8 +547,8 @@ static int xfrm_del_sa(struct sk_buff *s
 	km_state_notify(x, &c);
 
 out:
-	xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-		       AUDIT_MAC_IPSEC_DELSA, err ? 0 : 1, NULL, x);
+	xfrm_get_auditinfo(skb, &audit_info);
+	xfrm_audit_log(&audit_info, err ? 0 : 1, 0, 0, x, "SAD-delete");
 	xfrm_state_put(x);
 	return err;
 }
@@ -1137,6 +1139,7 @@ static int xfrm_add_policy(struct sk_buf
 	struct km_event c;
 	int err;
 	int excl;
+	struct xfrm_audit audit_info;
 
 	err = verify_newpolicy_info(p);
 	if (err)
@@ -1155,8 +1158,8 @@ static int xfrm_add_policy(struct sk_buf
 	 * a type XFRM_MSG_UPDPOLICY - JHS */
 	excl = nlh->nlmsg_type == XFRM_MSG_NEWPOLICY;
 	err = xfrm_policy_insert(p->dir, xp, excl);
-	xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-		       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
+	xfrm_get_auditinfo(skb, &audit_info);
+	xfrm_audit_log(&audit_info, err ? 0 : 1, 0, xp, 0, "SPD-add");
 
 	if (err) {
 		security_xfrm_policy_free(xp);
@@ -1401,8 +1404,11 @@ static int xfrm_get_policy(struct sk_buf
 					      MSG_DONTWAIT);
 		}
 	} else {
-		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-			       AUDIT_MAC_IPSEC_DELSPD, err ? 0 : 1, xp, NULL);
+		struct xfrm_audit audit_info;
+
+		xfrm_get_auditinfo(skb, &audit_info);
+		xfrm_audit_log(&audit_info, err ? 0 : 1, 0,
+			       xp, 0, "SPD-delete");
 
 		if (err != 0)
 			goto out;
@@ -1427,8 +1433,7 @@ static int xfrm_flush_sa(struct sk_buff 
 	struct xfrm_audit audit_info;
 	int err;
 
-	audit_info.loginuid = NETLINK_CB(skb).loginuid;
-	audit_info.secid = NETLINK_CB(skb).sid;
+	xfrm_get_auditinfo(skb, &audit_info);
 	err = xfrm_state_flush(p->proto, &audit_info);
 	if (err)
 		return err;
@@ -1590,8 +1595,7 @@ static int xfrm_flush_policy(struct sk_b
 	if (err)
 		return err;
 
-	audit_info.loginuid = NETLINK_CB(skb).loginuid;
-	audit_info.secid = NETLINK_CB(skb).sid;
+	xfrm_get_auditinfo(skb, &audit_info);
 	err = xfrm_policy_flush(type, &audit_info);
 	if (err)
 		return err;
@@ -1649,10 +1653,11 @@ static int xfrm_add_pol_expire(struct sk
 	read_unlock(&xp->lock);
 	err = 0;
 	if (up->hard) {
-		xfrm_policy_delete(xp, p->dir);
-		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-				AUDIT_MAC_IPSEC_DELSPD, 1, xp, NULL);
+		struct xfrm_audit audit_info;
 
+		xfrm_policy_delete(xp, p->dir);
+		xfrm_get_auditinfo(skb, &audit_info);
+		xfrm_audit_log(&audit_info, 1, 0, xp, 0, "SPD-delete");
 	} else {
 		// reset the timers here?
 		printk("Dont know what to do with soft policy expire\n");
@@ -1685,9 +1690,11 @@ static int xfrm_add_sa_expire(struct sk_
 	km_state_expired(x, ue->hard, current->pid);
 
 	if (ue->hard) {
+		struct xfrm_audit audit_info;
+
 		__xfrm_state_delete(x);
-		xfrm_audit_log(NETLINK_CB(skb).loginuid, NETLINK_CB(skb).sid,
-			       AUDIT_MAC_IPSEC_DELSA, 1, NULL, x);
+		xfrm_get_auditinfo(skb, &audit_info);
+		xfrm_audit_log(&audit_info, 1, 0, 0, x, "SAD-delete");
 	}
 	err = 0;
 out:
