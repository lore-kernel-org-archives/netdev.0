From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 10/16] xfrm: Add xfrm_replay_overflow functions for offloading
Date: Thu, 20 Apr 2017 10:55:09 +0200
Message-ID: <1492678515-14347-11-git-send-email-steffen.klassert@secunet.com>
References: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51630 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S943313AbdDTI53 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 04:57:29 -0400
In-Reply-To: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds functions that handles IPsec sequence
numbers for GSO segments and TSO offloading. We need
to calculate and update the sequence numbers based
on the segments that GSO/TSO will generate. We need
this to keep software and hardware sequence number
counter in sync.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_replay.c | 159 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 157 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index 20e68a3..8b23c5b 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -559,6 +559,158 @@ static void xfrm_replay_advance_esn(struct xfrm_state *x, __be32 net_seq)
 		x->repl->notify(x, XFRM_REPLAY_UPDATE);
 }
 
+#ifdef CONFIG_XFRM_OFFLOAD
+static int xfrm_replay_overflow_offload(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err = 0;
+	struct net *net = xs_net(x);
+	struct xfrm_offload *xo = xfrm_offload(skb);
+	__u32 oseq = x->replay.oseq;
+
+	if (!xo)
+		return xfrm_replay_overflow(x, skb);
+
+	if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
+		if (!skb_is_gso(skb)) {
+			XFRM_SKB_CB(skb)->seq.output.low = ++oseq;
+			xo->seq.low = oseq;
+		} else {
+			XFRM_SKB_CB(skb)->seq.output.low = oseq + 1;
+			xo->seq.low = oseq + 1;
+			oseq += skb_shinfo(skb)->gso_segs;
+		}
+
+		XFRM_SKB_CB(skb)->seq.output.hi = 0;
+		xo->seq.hi = 0;
+		if (unlikely(oseq < x->replay.oseq)) {
+			xfrm_audit_state_replay_overflow(x, skb);
+			err = -EOVERFLOW;
+
+			return err;
+		}
+
+		x->replay.oseq = oseq;
+
+		if (xfrm_aevent_is_on(net))
+			x->repl->notify(x, XFRM_REPLAY_UPDATE);
+	}
+
+	return err;
+}
+
+static int xfrm_replay_overflow_offload_bmp(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err = 0;
+	struct xfrm_offload *xo = xfrm_offload(skb);
+	struct xfrm_replay_state_esn *replay_esn = x->replay_esn;
+	struct net *net = xs_net(x);
+	__u32 oseq = replay_esn->oseq;
+
+	if (!xo)
+		return xfrm_replay_overflow_bmp(x, skb);
+
+	if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
+		if (!skb_is_gso(skb)) {
+			XFRM_SKB_CB(skb)->seq.output.low = ++oseq;
+			xo->seq.low = oseq;
+		} else {
+			XFRM_SKB_CB(skb)->seq.output.low = oseq + 1;
+			xo->seq.low = oseq + 1;
+			oseq += skb_shinfo(skb)->gso_segs;
+		}
+
+		XFRM_SKB_CB(skb)->seq.output.hi = 0;
+		xo->seq.hi = 0;
+		if (unlikely(oseq < replay_esn->oseq)) {
+			xfrm_audit_state_replay_overflow(x, skb);
+			err = -EOVERFLOW;
+
+			return err;
+		} else {
+			replay_esn->oseq = oseq;
+		}
+
+		if (xfrm_aevent_is_on(net))
+			x->repl->notify(x, XFRM_REPLAY_UPDATE);
+	}
+
+	return err;
+}
+
+static int xfrm_replay_overflow_offload_esn(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err = 0;
+	struct xfrm_offload *xo = xfrm_offload(skb);
+	struct xfrm_replay_state_esn *replay_esn = x->replay_esn;
+	struct net *net = xs_net(x);
+	__u32 oseq = replay_esn->oseq;
+	__u32 oseq_hi = replay_esn->oseq_hi;
+
+	if (!xo)
+		return xfrm_replay_overflow_esn(x, skb);
+
+	if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
+		if (!skb_is_gso(skb)) {
+			XFRM_SKB_CB(skb)->seq.output.low = ++oseq;
+			XFRM_SKB_CB(skb)->seq.output.hi = oseq_hi;
+			xo->seq.low = oseq;
+			xo->seq.hi = oseq_hi;
+		} else {
+			XFRM_SKB_CB(skb)->seq.output.low = oseq + 1;
+			XFRM_SKB_CB(skb)->seq.output.hi = oseq_hi;
+			xo->seq.low = oseq = oseq + 1;
+			xo->seq.hi = oseq_hi;
+			oseq += skb_shinfo(skb)->gso_segs;
+		}
+
+		if (unlikely(oseq < replay_esn->oseq)) {
+			XFRM_SKB_CB(skb)->seq.output.hi = ++oseq_hi;
+			xo->seq.hi = oseq_hi;
+
+			if (replay_esn->oseq_hi == 0) {
+				replay_esn->oseq--;
+				replay_esn->oseq_hi--;
+				xfrm_audit_state_replay_overflow(x, skb);
+				err = -EOVERFLOW;
+
+				return err;
+			}
+		}
+
+		replay_esn->oseq = oseq;
+		replay_esn->oseq_hi = oseq_hi;
+
+		if (xfrm_aevent_is_on(net))
+			x->repl->notify(x, XFRM_REPLAY_UPDATE);
+	}
+
+	return err;
+}
+
+static const struct xfrm_replay xfrm_replay_legacy = {
+	.advance	= xfrm_replay_advance,
+	.check		= xfrm_replay_check,
+	.recheck	= xfrm_replay_check,
+	.notify		= xfrm_replay_notify,
+	.overflow	= xfrm_replay_overflow_offload,
+};
+
+static const struct xfrm_replay xfrm_replay_bmp = {
+	.advance	= xfrm_replay_advance_bmp,
+	.check		= xfrm_replay_check_bmp,
+	.recheck	= xfrm_replay_check_bmp,
+	.notify		= xfrm_replay_notify_bmp,
+	.overflow	= xfrm_replay_overflow_offload_bmp,
+};
+
+static const struct xfrm_replay xfrm_replay_esn = {
+	.advance	= xfrm_replay_advance_esn,
+	.check		= xfrm_replay_check_esn,
+	.recheck	= xfrm_replay_recheck_esn,
+	.notify		= xfrm_replay_notify_esn,
+	.overflow	= xfrm_replay_overflow_offload_esn,
+};
+#else
 static const struct xfrm_replay xfrm_replay_legacy = {
 	.advance	= xfrm_replay_advance,
 	.check		= xfrm_replay_check,
@@ -582,6 +734,7 @@ static const struct xfrm_replay xfrm_replay_esn = {
 	.notify		= xfrm_replay_notify_esn,
 	.overflow	= xfrm_replay_overflow_esn,
 };
+#endif
 
 int xfrm_init_replay(struct xfrm_state *x)
 {
@@ -596,10 +749,12 @@ int xfrm_init_replay(struct xfrm_state *x)
 			if (replay_esn->replay_window == 0)
 				return -EINVAL;
 			x->repl = &xfrm_replay_esn;
-		} else
+		} else {
 			x->repl = &xfrm_replay_bmp;
-	} else
+		}
+	} else {
 		x->repl = &xfrm_replay_legacy;
+	}
 
 	return 0;
 }
-- 
2.7.4
