From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/7] [IPSEC]: Move xfrm_state_check into xfrm_output.c
Date: Mon, 08 Oct 2007 19:29:41 +0800
Message-ID: <E1Ieqnt-0000oB-00@gondolin.me.apana.org.au>
References: <20071008112818.GA3010@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1734 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752993AbXJHL3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 07:29:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Move xfrm_state_check into xfrm_output.c

The functions xfrm_state_check and xfrm_state_check_space are only used by
the output code in xfrm_output.c so we can move them over.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h     |    1 -
 net/xfrm/xfrm_output.c |   22 ++++++++++++++++++++++
 net/xfrm/xfrm_state.c  |   23 -----------------------
 3 files changed, 22 insertions(+), 24 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f5147dd..bb91934 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1013,7 +1013,6 @@ extern void xfrm_spd_getinfo(struct xfrmk_spdinfo *si);
 extern int xfrm_replay_check(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_notify(struct xfrm_state *x, int event);
-extern int xfrm_state_check(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm_state_mtu(struct xfrm_state *x, int mtu);
 extern int xfrm_init_state(struct xfrm_state *x);
 extern int xfrm_output(struct sk_buff *skb);
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 75f289b..5b1c978 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -18,6 +18,28 @@
 #include <net/dst.h>
 #include <net/xfrm.h>
 
+static int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int nhead = x->props.header_len + LL_RESERVED_SPACE(skb->dst->dev)
+		- skb_headroom(skb);
+
+	if (nhead > 0)
+		return pskb_expand_head(skb, nhead, 0, GFP_ATOMIC);
+
+	/* Check tail too... */
+	return 0;
+}
+
+static int xfrm_state_check(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err = xfrm_state_check_expire(x);
+	if (err < 0)
+		goto err;
+	err = xfrm_state_check_space(x, skb);
+err:
+	return err;
+}
+
 int xfrm_output(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 15734ad..0ecec34 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1152,29 +1152,6 @@ int xfrm_state_check_expire(struct xfrm_state *x)
 }
 EXPORT_SYMBOL(xfrm_state_check_expire);
 
-static int xfrm_state_check_space(struct xfrm_state *x, struct sk_buff *skb)
-{
-	int nhead = x->props.header_len + LL_RESERVED_SPACE(skb->dst->dev)
-		- skb_headroom(skb);
-
-	if (nhead > 0)
-		return pskb_expand_head(skb, nhead, 0, GFP_ATOMIC);
-
-	/* Check tail too... */
-	return 0;
-}
-
-int xfrm_state_check(struct xfrm_state *x, struct sk_buff *skb)
-{
-	int err = xfrm_state_check_expire(x);
-	if (err < 0)
-		goto err;
-	err = xfrm_state_check_space(x, skb);
-err:
-	return err;
-}
-EXPORT_SYMBOL(xfrm_state_check);
-
 struct xfrm_state *
 xfrm_state_lookup(xfrm_address_t *daddr, __be32 spi, u8 proto,
 		  unsigned short family)
