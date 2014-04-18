From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] xfrm: Remove useless secid field from xfrm_audit.
Date: Sat, 19 Apr 2014 01:00:27 +0900
Message-ID: <201404190100.IJG17653.VOSHJMtFQFOLOF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: jmlatten@linux.vnet.ibm.com, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:41353 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329AbaDRQBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2014 12:01:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 049fe797638a75b902b5c7bb845f6320bc0b47f6 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 18 Apr 2014 16:23:46 +0900
Subject: [PATCH] xfrm: Remove useless secid field from xfrm_audit.

It seems to me that commit ab5f5e8b "[XFRM]: xfrm audit calls" is doing
something strange at xfrm_audit_helper_usrinfo().
If secid != 0 && security_secid_to_secctx(secid) != 0, the caller calls
audit_log_task_context() which basically does
secid != 0 && security_secid_to_secctx(secid) == 0 case
except that secid is obtained from current thread's context.

Oh, what happens if secid passed to xfrm_audit_helper_usrinfo() was
obtained from other thread's context? It might audit current thread's
context rather than other thread's context if security_secid_to_secctx()
in xfrm_audit_helper_usrinfo() failed for some reason.

Then, are all the caller of xfrm_audit_helper_usrinfo() passing either
secid obtained from current thread's context or secid == 0?
It seems to me that they are.

If I didn't miss something, we don't need to pass secid to
xfrm_audit_helper_usrinfo() because audit_log_task_context() will
obtain secid from current thread's context.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/net/xfrm.h     |   29 ++++++++++-------------------
 net/key/af_key.c       |   12 +++++-------
 net/xfrm/xfrm_policy.c |   22 ++++++++--------------
 net/xfrm/xfrm_state.c  |   17 +++++++----------
 net/xfrm/xfrm_user.c   |   27 ++++++---------------------
 5 files changed, 36 insertions(+), 71 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 116e9c7..882889e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -693,7 +693,6 @@ struct xfrm_spi_skb_cb {
 
 /* Audit Information */
 struct xfrm_audit {
-	u32	secid;
 	kuid_t	loginuid;
 	unsigned int sessionid;
 };
@@ -713,30 +712,22 @@ static inline struct audit_buffer *xfrm_audit_start(const char *op)
 	return audit_buf;
 }
 
-static inline void xfrm_audit_helper_usrinfo(kuid_t auid, unsigned int ses, u32 secid,
+static inline void xfrm_audit_helper_usrinfo(kuid_t auid, unsigned int ses,
 					     struct audit_buffer *audit_buf)
 {
-	char *secctx;
-	u32 secctx_len;
-
 	audit_log_format(audit_buf, " auid=%u ses=%u",
 			 from_kuid(&init_user_ns, auid), ses);
-	if (secid != 0 &&
-	    security_secid_to_secctx(secid, &secctx, &secctx_len) == 0) {
-		audit_log_format(audit_buf, " subj=%s", secctx);
-		security_release_secctx(secctx, secctx_len);
-	} else
-		audit_log_task_context(audit_buf);
+	audit_log_task_context(audit_buf);
 }
 
 void xfrm_audit_policy_add(struct xfrm_policy *xp, int result, kuid_t auid,
-			   unsigned int ses, u32 secid);
+			   unsigned int ses);
 void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result, kuid_t auid,
-			      unsigned int ses, u32 secid);
+			      unsigned int ses);
 void xfrm_audit_state_add(struct xfrm_state *x, int result, kuid_t auid,
-			  unsigned int ses, u32 secid);
+			  unsigned int ses);
 void xfrm_audit_state_delete(struct xfrm_state *x, int result, kuid_t auid,
-			     unsigned int ses, u32 secid);
+			     unsigned int ses);
 void xfrm_audit_state_replay_overflow(struct xfrm_state *x,
 				      struct sk_buff *skb);
 void xfrm_audit_state_replay(struct xfrm_state *x, struct sk_buff *skb,
@@ -749,22 +740,22 @@ void xfrm_audit_state_icvfail(struct xfrm_state *x, struct sk_buff *skb,
 #else
 
 static inline void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
-				  kuid_t auid, unsigned int ses, u32 secid)
+				  kuid_t auid, unsigned int ses)
 {
 }
 
 static inline void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
-				  kuid_t auid, unsigned int ses, u32 secid)
+				  kuid_t auid, unsigned int ses)
 {
 }
 
 static inline void xfrm_audit_state_add(struct xfrm_state *x, int result,
-				 kuid_t auid, unsigned int ses, u32 secid)
+				 kuid_t auid, unsigned int ses)
 {
 }
 
 static inline void xfrm_audit_state_delete(struct xfrm_state *x, int result,
-				    kuid_t auid, unsigned int ses, u32 secid)
+				    kuid_t auid, unsigned int ses)
 {
 }
 
diff --git a/net/key/af_key.c b/net/key/af_key.c
index f3c8307..d66ff72 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1478,7 +1478,7 @@ static int pfkey_add(struct sock *sk, struct sk_buff *skb, const struct sadb_msg
 
 	xfrm_audit_state_add(x, err ? 0 : 1,
 			     audit_get_loginuid(current),
-			     audit_get_sessionid(current), 0);
+			     audit_get_sessionid(current));
 
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
@@ -1534,7 +1534,7 @@ static int pfkey_delete(struct sock *sk, struct sk_buff *skb, const struct sadb_
 out:
 	xfrm_audit_state_delete(x, err ? 0 : 1,
 				audit_get_loginuid(current),
-				audit_get_sessionid(current), 0);
+				audit_get_sessionid(current));
 	xfrm_state_put(x);
 
 	return err;
@@ -1735,7 +1735,6 @@ static int pfkey_flush(struct sock *sk, struct sk_buff *skb, const struct sadb_m
 
 	audit_info.loginuid = audit_get_loginuid(current);
 	audit_info.sessionid = audit_get_sessionid(current);
-	audit_info.secid = 0;
 	err = xfrm_state_flush(net, proto, &audit_info);
 	err2 = unicast_flush_resp(sk, hdr);
 	if (err || err2) {
@@ -2290,7 +2289,7 @@ static int pfkey_spdadd(struct sock *sk, struct sk_buff *skb, const struct sadb_
 
 	xfrm_audit_policy_add(xp, err ? 0 : 1,
 			      audit_get_loginuid(current),
-			      audit_get_sessionid(current), 0);
+			      audit_get_sessionid(current));
 
 	if (err)
 		goto out;
@@ -2374,7 +2373,7 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, const struct sa
 
 	xfrm_audit_policy_delete(xp, err ? 0 : 1,
 				 audit_get_loginuid(current),
-				 audit_get_sessionid(current), 0);
+				 audit_get_sessionid(current));
 
 	if (err)
 		goto out;
@@ -2624,7 +2623,7 @@ static int pfkey_spdget(struct sock *sk, struct sk_buff *skb, const struct sadb_
 	if (delete) {
 		xfrm_audit_policy_delete(xp, err ? 0 : 1,
 				audit_get_loginuid(current),
-				audit_get_sessionid(current), 0);
+				audit_get_sessionid(current));
 
 		if (err)
 			goto out;
@@ -2738,7 +2737,6 @@ static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, const struct sad
 
 	audit_info.loginuid = audit_get_loginuid(current);
 	audit_info.sessionid = audit_get_sessionid(current);
-	audit_info.secid = 0;
 	err = xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, &audit_info);
 	err2 = unicast_flush_resp(sk, hdr);
 	if (err || err2) {
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index c08fbd1..bd001b7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -785,8 +785,7 @@ xfrm_policy_flush_secctx_check(struct net *net, u8 type, struct xfrm_audit *audi
 			if (err) {
 				xfrm_audit_policy_delete(pol, 0,
 							 audit_info->loginuid,
-							 audit_info->sessionid,
-							 audit_info->secid);
+							 audit_info->sessionid);
 				return err;
 			}
 		}
@@ -801,8 +800,7 @@ xfrm_policy_flush_secctx_check(struct net *net, u8 type, struct xfrm_audit *audi
 				if (err) {
 					xfrm_audit_policy_delete(pol, 0,
 							audit_info->loginuid,
-							audit_info->sessionid,
-							audit_info->secid);
+							audit_info->sessionid);
 					return err;
 				}
 			}
@@ -842,8 +840,7 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 			cnt++;
 
 			xfrm_audit_policy_delete(pol, 1, audit_info->loginuid,
-						 audit_info->sessionid,
-						 audit_info->secid);
+						 audit_info->sessionid);
 
 			xfrm_policy_kill(pol);
 
@@ -864,8 +861,7 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 
 				xfrm_audit_policy_delete(pol, 1,
 							 audit_info->loginuid,
-							 audit_info->sessionid,
-							 audit_info->secid);
+							 audit_info->sessionid);
 				xfrm_policy_kill(pol);
 
 				write_lock_bh(&net->xfrm.xfrm_policy_lock);
@@ -2870,12 +2866,10 @@ static void xfrm_policy_fini(struct net *net)
 #ifdef CONFIG_XFRM_SUB_POLICY
 	audit_info.loginuid = INVALID_UID;
 	audit_info.sessionid = (unsigned int)-1;
-	audit_info.secid = 0;
 	xfrm_policy_flush(net, XFRM_POLICY_TYPE_SUB, &audit_info);
 #endif
 	audit_info.loginuid = INVALID_UID;
 	audit_info.sessionid = (unsigned int)-1;
-	audit_info.secid = 0;
 	xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, &audit_info);
 
 	WARN_ON(!list_empty(&net->xfrm.policy_all));
@@ -2992,14 +2986,14 @@ static void xfrm_audit_common_policyinfo(struct xfrm_policy *xp,
 }
 
 void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
-			   kuid_t auid, unsigned int sessionid, u32 secid)
+			   kuid_t auid, unsigned int sessionid)
 {
 	struct audit_buffer *audit_buf;
 
 	audit_buf = xfrm_audit_start("SPD-add");
 	if (audit_buf == NULL)
 		return;
-	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
+	xfrm_audit_helper_usrinfo(auid, sessionid, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
 	xfrm_audit_common_policyinfo(xp, audit_buf);
 	audit_log_end(audit_buf);
@@ -3007,14 +3001,14 @@ void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
 EXPORT_SYMBOL_GPL(xfrm_audit_policy_add);
 
 void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
-			      kuid_t auid, unsigned int sessionid, u32 secid)
+			      kuid_t auid, unsigned int sessionid)
 {
 	struct audit_buffer *audit_buf;
 
 	audit_buf = xfrm_audit_start("SPD-delete");
 	if (audit_buf == NULL)
 		return;
-	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
+	xfrm_audit_helper_usrinfo(auid, sessionid, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
 	xfrm_audit_common_policyinfo(xp, audit_buf);
 	audit_log_end(audit_buf);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 8e9c781..d91312b 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -465,7 +465,7 @@ expired:
 
 	xfrm_audit_state_delete(x, err ? 0 : 1,
 				audit_get_loginuid(current),
-				audit_get_sessionid(current), 0);
+				audit_get_sessionid(current));
 
 out:
 	spin_unlock(&x->lock);
@@ -574,8 +574,7 @@ xfrm_state_flush_secctx_check(struct net *net, u8 proto, struct xfrm_audit *audi
 			   (err = security_xfrm_state_delete(x)) != 0) {
 				xfrm_audit_state_delete(x, 0,
 							audit_info->loginuid,
-							audit_info->sessionid,
-							audit_info->secid);
+							audit_info->sessionid);
 				return err;
 			}
 		}
@@ -613,8 +612,7 @@ restart:
 				err = xfrm_state_delete(x);
 				xfrm_audit_state_delete(x, err ? 0 : 1,
 							audit_info->loginuid,
-							audit_info->sessionid,
-							audit_info->secid);
+							audit_info->sessionid);
 				xfrm_state_put(x);
 				if (!err)
 					cnt++;
@@ -2134,7 +2132,6 @@ void xfrm_state_fini(struct net *net)
 	flush_work(&net->xfrm.state_hash_work);
 	audit_info.loginuid = INVALID_UID;
 	audit_info.sessionid = (unsigned int)-1;
-	audit_info.secid = 0;
 	xfrm_state_flush(net, IPSEC_PROTO_ANY, &audit_info);
 	flush_work(&net->xfrm.state_gc_work);
 
@@ -2199,14 +2196,14 @@ static void xfrm_audit_helper_pktinfo(struct sk_buff *skb, u16 family,
 }
 
 void xfrm_audit_state_add(struct xfrm_state *x, int result,
-			  kuid_t auid, unsigned int sessionid, u32 secid)
+			  kuid_t auid, unsigned int sessionid)
 {
 	struct audit_buffer *audit_buf;
 
 	audit_buf = xfrm_audit_start("SAD-add");
 	if (audit_buf == NULL)
 		return;
-	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
+	xfrm_audit_helper_usrinfo(auid, sessionid, audit_buf);
 	xfrm_audit_helper_sainfo(x, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
 	audit_log_end(audit_buf);
@@ -2214,14 +2211,14 @@ void xfrm_audit_state_add(struct xfrm_state *x, int result,
 EXPORT_SYMBOL_GPL(xfrm_audit_state_add);
 
 void xfrm_audit_state_delete(struct xfrm_state *x, int result,
-			     kuid_t auid, unsigned int sessionid, u32 secid)
+			     kuid_t auid, unsigned int sessionid)
 {
 	struct audit_buffer *audit_buf;
 
 	audit_buf = xfrm_audit_start("SAD-delete");
 	if (audit_buf == NULL)
 		return;
-	xfrm_audit_helper_usrinfo(auid, sessionid, secid, audit_buf);
+	xfrm_audit_helper_usrinfo(auid, sessionid, audit_buf);
 	xfrm_audit_helper_sainfo(x, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
 	audit_log_end(audit_buf);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 8f131c1..d6409d9 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -599,7 +599,6 @@ static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct km_event c;
 	kuid_t loginuid = audit_get_loginuid(current);
 	unsigned int sessionid = audit_get_sessionid(current);
-	u32 sid;
 
 	err = verify_newsa_info(p, attrs);
 	if (err)
@@ -615,8 +614,7 @@ static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	else
 		err = xfrm_state_update(x);
 
-	security_task_getsecid(current, &sid);
-	xfrm_audit_state_add(x, err ? 0 : 1, loginuid, sessionid, sid);
+	xfrm_audit_state_add(x, err ? 0 : 1, loginuid, sessionid);
 
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
@@ -678,7 +676,6 @@ static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_usersa_id *p = nlmsg_data(nlh);
 	kuid_t loginuid = audit_get_loginuid(current);
 	unsigned int sessionid = audit_get_sessionid(current);
-	u32 sid;
 
 	x = xfrm_user_state_lookup(net, p, attrs, &err);
 	if (x == NULL)
@@ -703,8 +700,7 @@ static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	km_state_notify(x, &c);
 
 out:
-	security_task_getsecid(current, &sid);
-	xfrm_audit_state_delete(x, err ? 0 : 1, loginuid, sessionid, sid);
+	xfrm_audit_state_delete(x, err ? 0 : 1, loginuid, sessionid);
 	xfrm_state_put(x);
 	return err;
 }
@@ -1416,7 +1412,6 @@ static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	int excl;
 	kuid_t loginuid = audit_get_loginuid(current);
 	unsigned int sessionid = audit_get_sessionid(current);
-	u32 sid;
 
 	err = verify_newpolicy_info(p);
 	if (err)
@@ -1435,8 +1430,7 @@ static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	 * a type XFRM_MSG_UPDPOLICY - JHS */
 	excl = nlh->nlmsg_type == XFRM_MSG_NEWPOLICY;
 	err = xfrm_policy_insert(p->dir, xp, excl);
-	security_task_getsecid(current, &sid);
-	xfrm_audit_policy_add(xp, err ? 0 : 1, loginuid, sessionid, sid);
+	xfrm_audit_policy_add(xp, err ? 0 : 1, loginuid, sessionid);
 
 	if (err) {
 		security_xfrm_policy_free(xp->security);
@@ -1675,11 +1669,8 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	} else {
 		kuid_t loginuid = audit_get_loginuid(current);
 		unsigned int sessionid = audit_get_sessionid(current);
-		u32 sid;
 
-		security_task_getsecid(current, &sid);
-		xfrm_audit_policy_delete(xp, err ? 0 : 1, loginuid, sessionid,
-					 sid);
+		xfrm_audit_policy_delete(xp, err ? 0 : 1, loginuid, sessionid);
 
 		if (err != 0)
 			goto out;
@@ -1709,7 +1700,6 @@ static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	audit_info.loginuid = audit_get_loginuid(current);
 	audit_info.sessionid = audit_get_sessionid(current);
-	security_task_getsecid(current, &audit_info.secid);
 	err = xfrm_state_flush(net, p->proto, &audit_info);
 	if (err) {
 		if (err == -ESRCH) /* empty table */
@@ -1902,7 +1892,6 @@ static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	audit_info.loginuid = audit_get_loginuid(current);
 	audit_info.sessionid = audit_get_sessionid(current);
-	security_task_getsecid(current, &audit_info.secid);
 	err = xfrm_policy_flush(net, type, &audit_info);
 	if (err) {
 		if (err == -ESRCH) /* empty table */
@@ -1971,11 +1960,9 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (up->hard) {
 		kuid_t loginuid = audit_get_loginuid(current);
 		unsigned int sessionid = audit_get_sessionid(current);
-		u32 sid;
 
-		security_task_getsecid(current, &sid);
 		xfrm_policy_delete(xp, p->dir);
-		xfrm_audit_policy_delete(xp, 1, loginuid, sessionid, sid);
+		xfrm_audit_policy_delete(xp, 1, loginuid, sessionid);
 
 	} else {
 		// reset the timers here?
@@ -2014,11 +2001,9 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (ue->hard) {
 		kuid_t loginuid = audit_get_loginuid(current);
 		unsigned int sessionid = audit_get_sessionid(current);
-		u32 sid;
 
-		security_task_getsecid(current, &sid);
 		__xfrm_state_delete(x);
-		xfrm_audit_state_delete(x, 1, loginuid, sessionid, sid);
+		xfrm_audit_state_delete(x, 1, loginuid, sessionid);
 	}
 	err = 0;
 out:
-- 
1.7.1
