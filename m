From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 10/23] [PATCH] [XFRM]: Trace which secpath state is reject factor.
Date: Sat, 29 Jul 2006 18:30:29 +0900
Message-ID: <11541654291610-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:20867 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S932602AbWG2Jaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:30 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For Mobile IPv6 usage, it is required to trace which secpath state is reject
factor in order to notify it to user space (to know the address which cannot
be used route optimized communication).
Based on MIPL2 kernel patch.
---
 include/net/xfrm.h     |    3 ++
 net/xfrm/xfrm_policy.c |   67 +++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 63 insertions(+), 7 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 46f8616..8dcf6cd 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -272,6 +272,9 @@ #define XFRM_TYPE_NON_FRAGMENT	1
 	void			(*destructor)(struct xfrm_state *);
 	int			(*input)(struct xfrm_state *, struct sk_buff *skb);
 	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
+#ifdef CONFIG_XFRM_ADVANCED
+	int			(*reject)(struct xfrm_state *, struct sk_buff *skb, struct flowi *);
+#endif
 	int			(*place_find)(struct xfrm_state *, struct sk_buff *, u8 **);
 	xfrm_address_t		*(*local_addr)(struct xfrm_state *, xfrm_address_t *);
 	xfrm_address_t		*(*remote_addr)(struct xfrm_state *, xfrm_address_t *);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index d143381..1663ffa 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -911,6 +911,31 @@ error:
 }
 EXPORT_SYMBOL(xfrm_lookup);
 
+#ifdef CONFIG_XFRM_ADVANCED
+static inline int
+xfrm_secpath_reject(int idx, struct sk_buff *skb, struct flowi *fl)
+{
+	struct xfrm_state *x;
+	int err;
+
+	if (!skb->sp || idx < 0 || idx >= skb->sp->len)
+		return 0;
+	x = skb->sp->xvec[idx];
+	if (!x->type->reject)
+		return 0;
+	xfrm_state_hold(x);
+	err = x->type->reject(x, skb, fl);
+	xfrm_state_put(x);
+	return err;
+}
+#else
+static inline int
+xfrm_secpath_reject(int idx, struct sk_buff *skb, struct flowi *fl)
+{
+	return 0;
+}
+#endif
+
 /* When skb is transformed back to its "native" form, we have to
  * check policy restrictions. At the moment we make this in maximally
  * stupid way. Shame on me. :-) Of course, connected sockets must
@@ -932,6 +957,13 @@ xfrm_state_ok(struct xfrm_tmpl *tmpl, st
 		  xfrm_state_addr_cmp(tmpl, x, family));
 }
 
+/*
+ * 0 or more than 0 is returned when validation is succeeded (either bypass
+ * because of optional transport mode, or next index of the mathced secpath
+ * state with the template.
+ * -1 is returned when no matching template is found.
+ * Otherwise "-2 - errored_index" is returned.
+ */
 static inline int
 xfrm_policy_ok(struct xfrm_tmpl *tmpl, struct sec_path *sp, int start,
 	       unsigned short family)
@@ -946,8 +978,11 @@ xfrm_policy_ok(struct xfrm_tmpl *tmpl, s
 	for (; idx < sp->len; idx++) {
 		if (xfrm_state_ok(tmpl, sp->xvec[idx], family))
 			return ++idx;
-		if (sp->xvec[idx]->props.mode != XFRM_MODE_TRANSPORT)
+		if (sp->xvec[idx]->props.mode != XFRM_MODE_TRANSPORT) {
+			if (start == -1)
+				start = -2-idx;
 			break;
+		}
 	}
 	return start;
 }
@@ -966,11 +1001,14 @@ xfrm_decode_session(struct sk_buff *skb,
 }
 EXPORT_SYMBOL(xfrm_decode_session);
 
-static inline int secpath_has_tunnel(struct sec_path *sp, int k)
+static inline int secpath_has_tunnel(struct sec_path *sp, int k, int *idxp)
 {
 	for (; k < sp->len; k++) {
-		if (sp->xvec[k]->props.mode != XFRM_MODE_TRANSPORT)
+		if (sp->xvec[k]->props.mode != XFRM_MODE_TRANSPORT) {
+			if (idxp)
+				*idxp = k;
 			return 1;
+		}
 	}
 
 	return 0;
@@ -983,6 +1021,12 @@ int __xfrm_policy_check(struct sock *sk,
 	struct flowi fl;
 	u8 fl_dir = policy_to_flow_dir(dir);
 	u32 sk_sid;
+	int xerr_idx = -1;
+#ifdef CONFIG_XFRM_ADVANCED
+	int *xerr_idxp = &xerr_idx;
+#else
+	int *xerr_idxp = NULL;
+#endif
 
 	if (xfrm_decode_session(skb, &fl, family) < 0)
 		return 0;
@@ -1009,8 +1053,13 @@ int __xfrm_policy_check(struct sock *sk,
 		pol = flow_cache_lookup(&fl, sk_sid, family, fl_dir,
 					xfrm_policy_lookup);
 
-	if (!pol)
-		return !skb->sp || !secpath_has_tunnel(skb->sp, 0);
+	if (!pol) {
+		if (skb->sp && secpath_has_tunnel(skb->sp, 0, xerr_idxp)) {
+			xfrm_secpath_reject(xerr_idx, skb, &fl);
+			return 0;
+		}
+		return 1;
+	}
 
 	pol->curlft.use_time = (unsigned long)xtime.tv_sec;
 
@@ -1030,11 +1079,14 @@ int __xfrm_policy_check(struct sock *sk,
 		 */
 		for (i = pol->xfrm_nr-1, k = 0; i >= 0; i--) {
 			k = xfrm_policy_ok(pol->xfrm_vec+i, sp, k, family);
-			if (k < 0)
+			if (k < 0) {
+				if (k < -1 && xerr_idxp)
+					*xerr_idxp = -(2+k);
 				goto reject;
+			}
 		}
 
-		if (secpath_has_tunnel(sp, k))
+		if (secpath_has_tunnel(sp, k, xerr_idxp))
 			goto reject;
 
 		xfrm_pol_put(pol);
@@ -1042,6 +1094,7 @@ int __xfrm_policy_check(struct sock *sk,
 	}
 
 reject:
+	xfrm_secpath_reject(xerr_idx, skb, &fl);
 	xfrm_pol_put(pol);
 	return 0;
 }
-- 
1.4.1

