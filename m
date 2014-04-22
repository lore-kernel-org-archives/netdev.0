From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] xfrm: Remove useless secid field from xfrm_audit.
Date: Tue, 22 Apr 2014 21:48:30 +0900
Message-ID: <201404222148.JCD13571.QLFFJMtHOSFVOO@I-love.SAKURA.ne.jp>
References: <201404190100.IJG17653.VOSHJMtFQFOLOF@I-love.SAKURA.ne.jp>
	<20140422120256.GT32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmlatten@linux.vnet.ibm.com, herbert@gondor.apana.org.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:12104 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbaDVMtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 08:49:25 -0400
In-Reply-To: <20140422120256.GT32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steffen Klassert wrote:
> On Sat, Apr 19, 2014 at 01:00:27AM +0900, Tetsuo Handa wrote:
> > If I didn't miss something, we don't need to pass secid to
> > xfrm_audit_helper_usrinfo() because audit_log_task_context() will
> > obtain secid from current thread's context.
> 
> Yes, looks like that.
> 
> Applied to the ipsec-next tree.
> 
> Thanks!
> 

Wow. I raced with your commit. I was making V2 patch because it seemed
to me that

  struct xfrm_audit {
  	u32     secid;
  	kuid_t  loginuid;
  	unsigned int sessionid;
  };

can be packed as "bool" and replace "kuid_t auid, unsigned int ses, u32 secid"
arguments with single bool argument.

I subtracted your commit from my V2 patch. Would you check below one?
----------
>From 225dcb015abbad724cb4b6bda837e0132eb7b2dc Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 22 Apr 2014 21:34:34 +0900
Subject: [PATCH] xfrm: Remove useless xfrm_audit struct.

Commit f1370cc4 "xfrm: Remove useless secid field from xfrm_audit." changed
"struct xfrm_audit" to have either
{ audit_get_loginuid(current) / audit_get_sessionid(current) } or
{ INVALID_UID / -1 } pair.

This means that we can represent "struct xfrm_audit" as "bool".
This patch replaces "struct xfrm_audit" argument with "bool".

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/net/xfrm.h     |   42 +++++++++++++++++++-----------------------
 net/key/af_key.c       |   30 +++++++-----------------------
 net/xfrm/xfrm_policy.c |   40 ++++++++++++++--------------------------
 net/xfrm/xfrm_state.c  |   34 ++++++++++++----------------------
 net/xfrm/xfrm_user.c   |   38 ++++++++------------------------------
 5 files changed, 60 insertions(+), 124 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 882889e..721e9c3 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -691,12 +691,6 @@ struct xfrm_spi_skb_cb {
 
 #define XFRM_SPI_SKB_CB(__skb) ((struct xfrm_spi_skb_cb *)&((__skb)->cb[0]))
 
-/* Audit Information */
-struct xfrm_audit {
-	kuid_t	loginuid;
-	unsigned int sessionid;
-};
-
 #ifdef CONFIG_AUDITSYSCALL
 static inline struct audit_buffer *xfrm_audit_start(const char *op)
 {
@@ -712,22 +706,24 @@ static inline struct audit_buffer *xfrm_audit_start(const char *op)
 	return audit_buf;
 }
 
-static inline void xfrm_audit_helper_usrinfo(kuid_t auid, unsigned int ses,
+static inline void xfrm_audit_helper_usrinfo(bool task_valid,
 					     struct audit_buffer *audit_buf)
 {
-	audit_log_format(audit_buf, " auid=%u ses=%u",
-			 from_kuid(&init_user_ns, auid), ses);
+	const unsigned int auid = from_kuid(&init_user_ns, task_valid ?
+					    audit_get_loginuid(current) :
+					    INVALID_UID);
+	const unsigned int ses = task_valid ? audit_get_sessionid(current) :
+		(unsigned int) -1;
+
+	audit_log_format(audit_buf, " auid=%u ses=%u", auid, ses);
 	audit_log_task_context(audit_buf);
 }
 
-void xfrm_audit_policy_add(struct xfrm_policy *xp, int result, kuid_t auid,
-			   unsigned int ses);
-void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result, kuid_t auid,
-			      unsigned int ses);
-void xfrm_audit_state_add(struct xfrm_state *x, int result, kuid_t auid,
-			  unsigned int ses);
-void xfrm_audit_state_delete(struct xfrm_state *x, int result, kuid_t auid,
-			     unsigned int ses);
+void xfrm_audit_policy_add(struct xfrm_policy *xp, int result, bool task_valid);
+void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
+			      bool task_valid);
+void xfrm_audit_state_add(struct xfrm_state *x, int result, bool task_valid);
+void xfrm_audit_state_delete(struct xfrm_state *x, int result, bool task_valid);
 void xfrm_audit_state_replay_overflow(struct xfrm_state *x,
 				      struct sk_buff *skb);
 void xfrm_audit_state_replay(struct xfrm_state *x, struct sk_buff *skb,
@@ -740,22 +736,22 @@ void xfrm_audit_state_icvfail(struct xfrm_state *x, struct sk_buff *skb,
 #else
 
 static inline void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
-				  kuid_t auid, unsigned int ses)
+					 bool task_valid)
 {
 }
 
 static inline void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
-				  kuid_t auid, unsigned int ses)
+					    bool task_valid)
 {
 }
 
 static inline void xfrm_audit_state_add(struct xfrm_state *x, int result,
-				 kuid_t auid, unsigned int ses)
+					bool task_valid)
 {
 }
 
 static inline void xfrm_audit_state_delete(struct xfrm_state *x, int result,
-				    kuid_t auid, unsigned int ses)
+					   bool task_valid)
 {
 }
 
@@ -1499,7 +1495,7 @@ struct xfrmk_spdinfo {
 
 struct xfrm_state *xfrm_find_acq_byseq(struct net *net, u32 mark, u32 seq);
 int xfrm_state_delete(struct xfrm_state *x);
-int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info);
+int xfrm_state_flush(struct net *net, u8 proto, bool task_valid);
 void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si);
 void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si);
 u32 xfrm_replay_seqhi(struct xfrm_state *x, __be32 net_seq);
@@ -1594,7 +1590,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(struct net *net, u32 mark,
 					  int *err);
 struct xfrm_policy *xfrm_policy_byid(struct net *net, u32 mark, u8, int dir,
 				     u32 id, int delete, int *err);
-int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info);
+int xfrm_policy_flush(struct net *net, u8 type, bool task_valid);
 u32 xfrm_get_acqseq(void);
 int verify_spi_info(u8 proto, u32 min, u32 max);
 int xfrm_alloc_spi(struct xfrm_state *x, u32 minspi, u32 maxspi);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index d66ff72..b47f8e5 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1476,9 +1476,7 @@ static int pfkey_add(struct sock *sk, struct sk_buff *skb, const struct sadb_msg
 	else
 		err = xfrm_state_update(x);
 
-	xfrm_audit_state_add(x, err ? 0 : 1,
-			     audit_get_loginuid(current),
-			     audit_get_sessionid(current));
+	xfrm_audit_state_add(x, err ? 0 : 1, true);
 
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
@@ -1532,9 +1530,7 @@ static int pfkey_delete(struct sock *sk, struct sk_buff *skb, const struct sadb_
 	c.event = XFRM_MSG_DELSA;
 	km_state_notify(x, &c);
 out:
-	xfrm_audit_state_delete(x, err ? 0 : 1,
-				audit_get_loginuid(current),
-				audit_get_sessionid(current));
+	xfrm_audit_state_delete(x, err ? 0 : 1, true);
 	xfrm_state_put(x);
 
 	return err;
@@ -1726,16 +1722,13 @@ static int pfkey_flush(struct sock *sk, struct sk_buff *skb, const struct sadb_m
 	struct net *net = sock_net(sk);
 	unsigned int proto;
 	struct km_event c;
-	struct xfrm_audit audit_info;
 	int err, err2;
 
 	proto = pfkey_satype2proto(hdr->sadb_msg_satype);
 	if (proto == 0)
 		return -EINVAL;
 
-	audit_info.loginuid = audit_get_loginuid(current);
-	audit_info.sessionid = audit_get_sessionid(current);
-	err = xfrm_state_flush(net, proto, &audit_info);
+	err = xfrm_state_flush(net, proto, true);
 	err2 = unicast_flush_resp(sk, hdr);
 	if (err || err2) {
 		if (err == -ESRCH) /* empty table - go quietly */
@@ -2287,9 +2280,7 @@ static int pfkey_spdadd(struct sock *sk, struct sk_buff *skb, const struct sadb_
 	err = xfrm_policy_insert(pol->sadb_x_policy_dir-1, xp,
 				 hdr->sadb_msg_type != SADB_X_SPDUPDATE);
 
-	xfrm_audit_policy_add(xp, err ? 0 : 1,
-			      audit_get_loginuid(current),
-			      audit_get_sessionid(current));
+	xfrm_audit_policy_add(xp, err ? 0 : 1, true);
 
 	if (err)
 		goto out;
@@ -2371,9 +2362,7 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, const struct sa
 	if (xp == NULL)
 		return -ENOENT;
 
-	xfrm_audit_policy_delete(xp, err ? 0 : 1,
-				 audit_get_loginuid(current),
-				 audit_get_sessionid(current));
+	xfrm_audit_policy_delete(xp, err ? 0 : 1, true);
 
 	if (err)
 		goto out;
@@ -2621,9 +2610,7 @@ static int pfkey_spdget(struct sock *sk, struct sk_buff *skb, const struct sadb_
 		return -ENOENT;
 
 	if (delete) {
-		xfrm_audit_policy_delete(xp, err ? 0 : 1,
-				audit_get_loginuid(current),
-				audit_get_sessionid(current));
+		xfrm_audit_policy_delete(xp, err ? 0 : 1, true);
 
 		if (err)
 			goto out;
@@ -2732,12 +2719,9 @@ static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, const struct sad
 {
 	struct net *net = sock_net(sk);
 	struct km_event c;
-	struct xfrm_audit audit_info;
 	int err, err2;
 
-	audit_info.loginuid = audit_get_loginuid(current);
-	audit_info.sessionid = audit_get_sessionid(current);
-	err = xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, &audit_info);
+	err = xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, true);
 	err2 = unicast_flush_resp(sk, hdr);
 	if (err || err2) {
 		if (err == -ESRCH) /* empty table - old silent behavior */
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index bd001b7..375267d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -769,7 +769,7 @@ EXPORT_SYMBOL(xfrm_policy_byid);
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 static inline int
-xfrm_policy_flush_secctx_check(struct net *net, u8 type, struct xfrm_audit *audit_info)
+xfrm_policy_flush_secctx_check(struct net *net, u8 type, bool task_valid)
 {
 	int dir, err = 0;
 
@@ -783,9 +783,7 @@ xfrm_policy_flush_secctx_check(struct net *net, u8 type, struct xfrm_audit *audi
 				continue;
 			err = security_xfrm_policy_delete(pol->security);
 			if (err) {
-				xfrm_audit_policy_delete(pol, 0,
-							 audit_info->loginuid,
-							 audit_info->sessionid);
+				xfrm_audit_policy_delete(pol, 0, task_valid);
 				return err;
 			}
 		}
@@ -799,8 +797,7 @@ xfrm_policy_flush_secctx_check(struct net *net, u8 type, struct xfrm_audit *audi
 								pol->security);
 				if (err) {
 					xfrm_audit_policy_delete(pol, 0,
-							audit_info->loginuid,
-							audit_info->sessionid);
+								 task_valid);
 					return err;
 				}
 			}
@@ -810,19 +807,19 @@ xfrm_policy_flush_secctx_check(struct net *net, u8 type, struct xfrm_audit *audi
 }
 #else
 static inline int
-xfrm_policy_flush_secctx_check(struct net *net, u8 type, struct xfrm_audit *audit_info)
+xfrm_policy_flush_secctx_check(struct net *net, u8 type, bool task_valid)
 {
 	return 0;
 }
 #endif
 
-int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
+int xfrm_policy_flush(struct net *net, u8 type, bool task_valid)
 {
 	int dir, err = 0, cnt = 0;
 
 	write_lock_bh(&net->xfrm.xfrm_policy_lock);
 
-	err = xfrm_policy_flush_secctx_check(net, type, audit_info);
+	err = xfrm_policy_flush_secctx_check(net, type, task_valid);
 	if (err)
 		goto out;
 
@@ -839,8 +836,7 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 			write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 			cnt++;
 
-			xfrm_audit_policy_delete(pol, 1, audit_info->loginuid,
-						 audit_info->sessionid);
+			xfrm_audit_policy_delete(pol, 1, task_valid);
 
 			xfrm_policy_kill(pol);
 
@@ -859,9 +855,7 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
 				write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 				cnt++;
 
-				xfrm_audit_policy_delete(pol, 1,
-							 audit_info->loginuid,
-							 audit_info->sessionid);
+				xfrm_audit_policy_delete(pol, 1, task_valid);
 				xfrm_policy_kill(pol);
 
 				write_lock_bh(&net->xfrm.xfrm_policy_lock);
@@ -2858,19 +2852,14 @@ out_byidx:
 
 static void xfrm_policy_fini(struct net *net)
 {
-	struct xfrm_audit audit_info;
 	unsigned int sz;
 	int dir;
 
 	flush_work(&net->xfrm.policy_hash_work);
 #ifdef CONFIG_XFRM_SUB_POLICY
-	audit_info.loginuid = INVALID_UID;
-	audit_info.sessionid = (unsigned int)-1;
-	xfrm_policy_flush(net, XFRM_POLICY_TYPE_SUB, &audit_info);
+	xfrm_policy_flush(net, XFRM_POLICY_TYPE_SUB, false);
 #endif
-	audit_info.loginuid = INVALID_UID;
-	audit_info.sessionid = (unsigned int)-1;
-	xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, &audit_info);
+	xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, false);
 
 	WARN_ON(!list_empty(&net->xfrm.policy_all));
 
@@ -2985,15 +2974,14 @@ static void xfrm_audit_common_policyinfo(struct xfrm_policy *xp,
 	}
 }
 
-void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
-			   kuid_t auid, unsigned int sessionid)
+void xfrm_audit_policy_add(struct xfrm_policy *xp, int result, bool task_valid)
 {
 	struct audit_buffer *audit_buf;
 
 	audit_buf = xfrm_audit_start("SPD-add");
 	if (audit_buf == NULL)
 		return;
-	xfrm_audit_helper_usrinfo(auid, sessionid, audit_buf);
+	xfrm_audit_helper_usrinfo(task_valid, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
 	xfrm_audit_common_policyinfo(xp, audit_buf);
 	audit_log_end(audit_buf);
@@ -3001,14 +2989,14 @@ void xfrm_audit_policy_add(struct xfrm_policy *xp, int result,
 EXPORT_SYMBOL_GPL(xfrm_audit_policy_add);
 
 void xfrm_audit_policy_delete(struct xfrm_policy *xp, int result,
-			      kuid_t auid, unsigned int sessionid)
+			      bool task_valid)
 {
 	struct audit_buffer *audit_buf;
 
 	audit_buf = xfrm_audit_start("SPD-delete");
 	if (audit_buf == NULL)
 		return;
-	xfrm_audit_helper_usrinfo(auid, sessionid, audit_buf);
+	xfrm_audit_helper_usrinfo(task_valid, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
 	xfrm_audit_common_policyinfo(xp, audit_buf);
 	audit_log_end(audit_buf);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index d91312b..0ab5413 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -463,9 +463,7 @@ expired:
 	if (!err)
 		km_state_expired(x, 1, 0);
 
-	xfrm_audit_state_delete(x, err ? 0 : 1,
-				audit_get_loginuid(current),
-				audit_get_sessionid(current));
+	xfrm_audit_state_delete(x, err ? 0 : 1, true);
 
 out:
 	spin_unlock(&x->lock);
@@ -562,7 +560,7 @@ EXPORT_SYMBOL(xfrm_state_delete);
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 static inline int
-xfrm_state_flush_secctx_check(struct net *net, u8 proto, struct xfrm_audit *audit_info)
+xfrm_state_flush_secctx_check(struct net *net, u8 proto, bool task_valid)
 {
 	int i, err = 0;
 
@@ -572,9 +570,7 @@ xfrm_state_flush_secctx_check(struct net *net, u8 proto, struct xfrm_audit *audi
 		hlist_for_each_entry(x, net->xfrm.state_bydst+i, bydst) {
 			if (xfrm_id_proto_match(x->id.proto, proto) &&
 			   (err = security_xfrm_state_delete(x)) != 0) {
-				xfrm_audit_state_delete(x, 0,
-							audit_info->loginuid,
-							audit_info->sessionid);
+				xfrm_audit_state_delete(x, 0, task_valid);
 				return err;
 			}
 		}
@@ -584,18 +580,18 @@ xfrm_state_flush_secctx_check(struct net *net, u8 proto, struct xfrm_audit *audi
 }
 #else
 static inline int
-xfrm_state_flush_secctx_check(struct net *net, u8 proto, struct xfrm_audit *audit_info)
+xfrm_state_flush_secctx_check(struct net *net, u8 proto, bool task_valid)
 {
 	return 0;
 }
 #endif
 
-int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info)
+int xfrm_state_flush(struct net *net, u8 proto, bool task_valid)
 {
 	int i, err = 0, cnt = 0;
 
 	spin_lock_bh(&net->xfrm.xfrm_state_lock);
-	err = xfrm_state_flush_secctx_check(net, proto, audit_info);
+	err = xfrm_state_flush_secctx_check(net, proto, task_valid);
 	if (err)
 		goto out;
 
@@ -611,8 +607,7 @@ restart:
 
 				err = xfrm_state_delete(x);
 				xfrm_audit_state_delete(x, err ? 0 : 1,
-							audit_info->loginuid,
-							audit_info->sessionid);
+							task_valid);
 				xfrm_state_put(x);
 				if (!err)
 					cnt++;
@@ -2126,13 +2121,10 @@ out_bydst:
 
 void xfrm_state_fini(struct net *net)
 {
-	struct xfrm_audit audit_info;
 	unsigned int sz;
 
 	flush_work(&net->xfrm.state_hash_work);
-	audit_info.loginuid = INVALID_UID;
-	audit_info.sessionid = (unsigned int)-1;
-	xfrm_state_flush(net, IPSEC_PROTO_ANY, &audit_info);
+	xfrm_state_flush(net, IPSEC_PROTO_ANY, false);
 	flush_work(&net->xfrm.state_gc_work);
 
 	WARN_ON(!list_empty(&net->xfrm.state_all));
@@ -2195,30 +2187,28 @@ static void xfrm_audit_helper_pktinfo(struct sk_buff *skb, u16 family,
 	}
 }
 
-void xfrm_audit_state_add(struct xfrm_state *x, int result,
-			  kuid_t auid, unsigned int sessionid)
+void xfrm_audit_state_add(struct xfrm_state *x, int result, bool task_valid)
 {
 	struct audit_buffer *audit_buf;
 
 	audit_buf = xfrm_audit_start("SAD-add");
 	if (audit_buf == NULL)
 		return;
-	xfrm_audit_helper_usrinfo(auid, sessionid, audit_buf);
+	xfrm_audit_helper_usrinfo(task_valid, audit_buf);
 	xfrm_audit_helper_sainfo(x, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
 	audit_log_end(audit_buf);
 }
 EXPORT_SYMBOL_GPL(xfrm_audit_state_add);
 
-void xfrm_audit_state_delete(struct xfrm_state *x, int result,
-			     kuid_t auid, unsigned int sessionid)
+void xfrm_audit_state_delete(struct xfrm_state *x, int result, bool task_valid)
 {
 	struct audit_buffer *audit_buf;
 
 	audit_buf = xfrm_audit_start("SAD-delete");
 	if (audit_buf == NULL)
 		return;
-	xfrm_audit_helper_usrinfo(auid, sessionid, audit_buf);
+	xfrm_audit_helper_usrinfo(task_valid, audit_buf);
 	xfrm_audit_helper_sainfo(x, audit_buf);
 	audit_log_format(audit_buf, " res=%u", result);
 	audit_log_end(audit_buf);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d6409d9..3d4b4c4 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -597,8 +597,6 @@ static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_state *x;
 	int err;
 	struct km_event c;
-	kuid_t loginuid = audit_get_loginuid(current);
-	unsigned int sessionid = audit_get_sessionid(current);
 
 	err = verify_newsa_info(p, attrs);
 	if (err)
@@ -614,7 +612,7 @@ static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	else
 		err = xfrm_state_update(x);
 
-	xfrm_audit_state_add(x, err ? 0 : 1, loginuid, sessionid);
+	xfrm_audit_state_add(x, err ? 0 : 1, true);
 
 	if (err < 0) {
 		x->km.state = XFRM_STATE_DEAD;
@@ -674,8 +672,6 @@ static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	int err = -ESRCH;
 	struct km_event c;
 	struct xfrm_usersa_id *p = nlmsg_data(nlh);
-	kuid_t loginuid = audit_get_loginuid(current);
-	unsigned int sessionid = audit_get_sessionid(current);
 
 	x = xfrm_user_state_lookup(net, p, attrs, &err);
 	if (x == NULL)
@@ -700,7 +696,7 @@ static int xfrm_del_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	km_state_notify(x, &c);
 
 out:
-	xfrm_audit_state_delete(x, err ? 0 : 1, loginuid, sessionid);
+	xfrm_audit_state_delete(x, err ? 0 : 1, true);
 	xfrm_state_put(x);
 	return err;
 }
@@ -1410,8 +1406,6 @@ static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct km_event c;
 	int err;
 	int excl;
-	kuid_t loginuid = audit_get_loginuid(current);
-	unsigned int sessionid = audit_get_sessionid(current);
 
 	err = verify_newpolicy_info(p);
 	if (err)
@@ -1430,7 +1424,7 @@ static int xfrm_add_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	 * a type XFRM_MSG_UPDPOLICY - JHS */
 	excl = nlh->nlmsg_type == XFRM_MSG_NEWPOLICY;
 	err = xfrm_policy_insert(p->dir, xp, excl);
-	xfrm_audit_policy_add(xp, err ? 0 : 1, loginuid, sessionid);
+	xfrm_audit_policy_add(xp, err ? 0 : 1, true);
 
 	if (err) {
 		security_xfrm_policy_free(xp->security);
@@ -1667,10 +1661,7 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 					    NETLINK_CB(skb).portid);
 		}
 	} else {
-		kuid_t loginuid = audit_get_loginuid(current);
-		unsigned int sessionid = audit_get_sessionid(current);
-
-		xfrm_audit_policy_delete(xp, err ? 0 : 1, loginuid, sessionid);
+		xfrm_audit_policy_delete(xp, err ? 0 : 1, true);
 
 		if (err != 0)
 			goto out;
@@ -1695,12 +1686,9 @@ static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct net *net = sock_net(skb->sk);
 	struct km_event c;
 	struct xfrm_usersa_flush *p = nlmsg_data(nlh);
-	struct xfrm_audit audit_info;
 	int err;
 
-	audit_info.loginuid = audit_get_loginuid(current);
-	audit_info.sessionid = audit_get_sessionid(current);
-	err = xfrm_state_flush(net, p->proto, &audit_info);
+	err = xfrm_state_flush(net, p->proto, true);
 	if (err) {
 		if (err == -ESRCH) /* empty table */
 			return 0;
@@ -1884,15 +1872,12 @@ static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct km_event c;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err;
-	struct xfrm_audit audit_info;
 
 	err = copy_from_user_policy_type(&type, attrs);
 	if (err)
 		return err;
 
-	audit_info.loginuid = audit_get_loginuid(current);
-	audit_info.sessionid = audit_get_sessionid(current);
-	err = xfrm_policy_flush(net, type, &audit_info);
+	err = xfrm_policy_flush(net, type, true);
 	if (err) {
 		if (err == -ESRCH) /* empty table */
 			return 0;
@@ -1958,12 +1943,8 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	err = 0;
 	if (up->hard) {
-		kuid_t loginuid = audit_get_loginuid(current);
-		unsigned int sessionid = audit_get_sessionid(current);
-
 		xfrm_policy_delete(xp, p->dir);
-		xfrm_audit_policy_delete(xp, 1, loginuid, sessionid);
-
+		xfrm_audit_policy_delete(xp, 1, true);
 	} else {
 		// reset the timers here?
 		WARN(1, "Dont know what to do with soft policy expire\n");
@@ -1999,11 +1980,8 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	km_state_expired(x, ue->hard, nlh->nlmsg_pid);
 
 	if (ue->hard) {
-		kuid_t loginuid = audit_get_loginuid(current);
-		unsigned int sessionid = audit_get_sessionid(current);
-
 		__xfrm_state_delete(x);
-		xfrm_audit_state_delete(x, 1, loginuid, sessionid);
+		xfrm_audit_state_delete(x, 1, true);
 	}
 	err = 0;
 out:
-- 
1.7.9.5
