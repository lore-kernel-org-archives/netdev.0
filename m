From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 35/44] [XFRM]: Trace which secpath state is reject factor.
Date: Thu, 24 Aug 2006 00:02:36 +0900
Message-ID: <11563453673786-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org> <11563453663275-git-send-email-yoshfuji@linux-ipv6.org> <11563453671174-git-send-email-yoshfuji@linux-ipv6.org> <11563453674049-git-send-email-yoshfuji@linux-ipv6.org> <11563453673517-git-send-email-yoshfuji@linux-ipv6.org> <11563453674137-git-send-email-yoshfuji@linux-ipv6.org> <11563453671944-git-send-email-yoshfuji@linux-ipv6.org> <11
 563453671187-git-send-email-yoshfuji@linux-ipv6.org> <11563453672959-git-send-email-yoshfuji@linux-ipv6.org> <1156345367208-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:9609 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964950AbWHWPCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:52 -0400
To: davem@davemloft.net
In-Reply-To: <1156345367208-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

For Mobile IPv6 usage, it is required to trace which secpath state is reject
factor in order to notify it to user space (to know the address which cannot
be used route optimized communication).
Based on MIPL2 kernel patch.

This patch was also written by: Henrik Petander <petander@tcs.hut.fi>

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/xfrm.h     |    1 +
 net/xfrm/xfrm_policy.c |   55 ++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 49 insertions(+), 7 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bf6daaa..276884f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -274,6 +274,7 @@ #define XFRM_TYPE_NON_FRAGMENT	1
 	void			(*destructor)(struct xfrm_state *);
 	int			(*input)(struct xfrm_state *, struct sk_buff *skb);
 	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
+	int			(*reject)(struct xfrm_state *, struct sk_buff *, struct flowi *);
 	int			(*hdr_offset)(struct xfrm_state *, struct sk_buff *, u8 **);
 	xfrm_address_t		*(*local_addr)(struct xfrm_state *, xfrm_address_t *);
 	xfrm_address_t		*(*remote_addr)(struct xfrm_state *, xfrm_address_t *);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index c009d6f..7b446a9 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -988,6 +988,23 @@ error:
 }
 EXPORT_SYMBOL(xfrm_lookup);
 
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
+
 /* When skb is transformed back to its "native" form, we have to
  * check policy restrictions. At the moment we make this in maximally
  * stupid way. Shame on me. :-) Of course, connected sockets must
@@ -1010,6 +1027,13 @@ xfrm_state_ok(struct xfrm_tmpl *tmpl, st
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
@@ -1024,8 +1048,11 @@ xfrm_policy_ok(struct xfrm_tmpl *tmpl, s
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
@@ -1046,11 +1073,14 @@ xfrm_decode_session(struct sk_buff *skb,
 }
 EXPORT_SYMBOL(xfrm_decode_session);
 
-static inline int secpath_has_nontransport(struct sec_path *sp, int k)
+static inline int secpath_has_nontransport(struct sec_path *sp, int k, int *idxp)
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
@@ -1062,6 +1092,8 @@ int __xfrm_policy_check(struct sock *sk,
 	struct xfrm_policy *pol;
 	struct flowi fl;
 	u8 fl_dir = policy_to_flow_dir(dir);
+	int xerr_idx = -1;
+	int *xerr_idxp = &xerr_idx;
 
 	if (xfrm_decode_session(skb, &fl, family) < 0)
 		return 0;
@@ -1086,8 +1118,13 @@ int __xfrm_policy_check(struct sock *sk,
 		pol = flow_cache_lookup(&fl, family, fl_dir,
 					xfrm_policy_lookup);
 
-	if (!pol)
-		return !skb->sp || !secpath_has_nontransport(skb->sp, 0);
+	if (!pol) {
+		if (skb->sp && secpath_has_nontransport(skb->sp, 0, xerr_idxp)) {
+			xfrm_secpath_reject(xerr_idx, skb, &fl);
+			return 0;
+		}
+		return 1;
+	}
 
 	pol->curlft.use_time = (unsigned long)xtime.tv_sec;
 
@@ -1107,11 +1144,14 @@ int __xfrm_policy_check(struct sock *sk,
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
 
-		if (secpath_has_nontransport(sp, k))
+		if (secpath_has_nontransport(sp, k, xerr_idxp))
 			goto reject;
 
 		xfrm_pol_put(pol);
@@ -1119,6 +1159,7 @@ int __xfrm_policy_check(struct sock *sk,
 	}
 
 reject:
+	xfrm_secpath_reject(xerr_idx, skb, &fl);
 	xfrm_pol_put(pol);
 	return 0;
 }
-- 
1.4.0

