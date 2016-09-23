From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 10/11] xfrm: Add xfrm_replay_overflow functions for offloading
Date: Fri, 23 Sep 2016 09:53:47 +0200
Message-ID: <1474617228-26103-11-git-send-email-steffen.klassert@secunet.com>
References: <1474617228-26103-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>,
        "Boris Pismenny" <borisp@mellanox.com>,
        Ariel Levkovich <lariel@mellanox.com>,
        "Hay, Joshua A" <joshua.a.hay@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:46014 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758597AbcIWHyI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:54:08 -0400
In-Reply-To: <1474617228-26103-1-git-send-email-steffen.klassert@secunet.com>
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
 net/xfrm/xfrm_replay.c | 103 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 101 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
index 20e68a3..401d4a9 100644
--- a/net/xfrm/xfrm_replay.c
+++ b/net/xfrm/xfrm_replay.c
@@ -559,6 +559,83 @@ static void xfrm_replay_advance_esn(struct xfrm_state *x, __be32 net_seq)
 		x->repl->notify(x, XFRM_REPLAY_UPDATE);
 }
 
+static int xfrm_replay_overflow_offload(struct xfrm_state *x, struct sk_buff *skb)
+{
+	int err = 0;
+	struct net *net = xs_net(x);
+	struct sec_path *sp = skb->sp;
+	__u32 oseq = x->replay.oseq;
+
+	if (!sp)
+		return xfrm_replay_overflow(x, skb);
+
+	if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
+		if (!skb_is_gso(skb)) {
+			XFRM_SKB_CB(skb)->seq.output.low = ++oseq;
+			sp->seq.low = oseq;
+		} else {
+			XFRM_SKB_CB(skb)->seq.output.low = oseq + 1;
+			sp->seq.low = oseq + 1;
+			oseq += skb_shinfo(skb)->gso_segs;
+		}
+
+		XFRM_SKB_CB(skb)->seq.output.hi = 0;
+		sp->seq.hi = 0;
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
+	struct sec_path *sp = skb->sp;
+	struct xfrm_replay_state_esn *replay_esn = x->replay_esn;
+	struct net *net = xs_net(x);
+	__u32 oseq = replay_esn->oseq;
+
+	if (!sp)
+		return xfrm_replay_overflow_bmp(x, skb);
+
+	if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
+		if (!skb_is_gso(skb)) {
+			XFRM_SKB_CB(skb)->seq.output.low = ++oseq;
+			sp->seq.low = oseq;
+		} else {
+			XFRM_SKB_CB(skb)->seq.output.low = oseq + 1;
+			sp->seq.low = oseq + 1;
+			oseq += skb_shinfo(skb)->gso_segs;
+		}
+
+		XFRM_SKB_CB(skb)->seq.output.hi = 0;
+		sp->seq.hi = 0;
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
 static const struct xfrm_replay xfrm_replay_legacy = {
 	.advance	= xfrm_replay_advance,
 	.check		= xfrm_replay_check,
@@ -567,6 +644,14 @@ static const struct xfrm_replay xfrm_replay_legacy = {
 	.overflow	= xfrm_replay_overflow,
 };
 
+static const struct xfrm_replay xfrm_replay_offload_legacy = {
+	.advance	= xfrm_replay_advance,
+	.check		= xfrm_replay_check,
+	.recheck	= xfrm_replay_check,
+	.notify		= xfrm_replay_notify,
+	.overflow	= xfrm_replay_overflow_offload,
+};
+
 static const struct xfrm_replay xfrm_replay_bmp = {
 	.advance	= xfrm_replay_advance_bmp,
 	.check		= xfrm_replay_check_bmp,
@@ -575,6 +660,14 @@ static const struct xfrm_replay xfrm_replay_bmp = {
 	.overflow	= xfrm_replay_overflow_bmp,
 };
 
+static const struct xfrm_replay xfrm_replay_offload = {
+	.advance	= xfrm_replay_advance_bmp,
+	.check		= xfrm_replay_check_bmp,
+	.recheck	= xfrm_replay_check_bmp,
+	.notify		= xfrm_replay_notify_bmp,
+	.overflow	= xfrm_replay_overflow_offload_bmp,
+};
+
 static const struct xfrm_replay xfrm_replay_esn = {
 	.advance	= xfrm_replay_advance_esn,
 	.check		= xfrm_replay_check_esn,
@@ -596,10 +689,16 @@ int xfrm_init_replay(struct xfrm_state *x)
 			if (replay_esn->replay_window == 0)
 				return -EINVAL;
 			x->repl = &xfrm_replay_esn;
-		} else
+		} else if (x->xso.offload_handle) {
+			x->repl = &xfrm_replay_offload;
+		} else {
 			x->repl = &xfrm_replay_bmp;
-	} else
+		}
+	} else if (x->xso.offload_handle) {
+		x->repl = &xfrm_replay_offload_legacy;
+	} else {
 		x->repl = &xfrm_replay_legacy;
+	}
 
 	return 0;
 }
-- 
1.9.1
