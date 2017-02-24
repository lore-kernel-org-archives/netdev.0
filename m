From: Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v5 3/6] 6lowpan: iphc: override l2 packet information
Date: Fri, 24 Feb 2017 14:14:37 +0200
Message-ID: <20170224121440.32269-4-luiz.dentz@gmail.com>
References: <20170224121440.32269-1-luiz.dentz@gmail.com>
Cc: patrik.flykt-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
        stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org, aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
        linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170224121440.32269-1-luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

The skb->pkt_type need to be set by L2, but on 6LoWPAN there exists L2
e.g. BTLE which doesn't has multicast addressing. If it's a multicast or
not is detected by IPHC headers multicast bit. The IPv6 layer will
evaluate this pkt_type, so we force set this type while uncompressing.
Should be okay for 802.15.4 as well.

Signed-off-by: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Reviewed-by: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
---
 net/6lowpan/iphc.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/6lowpan/iphc.c b/net/6lowpan/iphc.c
index 79f1fa2..fb5f6fa 100644
--- a/net/6lowpan/iphc.c
+++ b/net/6lowpan/iphc.c
@@ -666,6 +666,8 @@ int lowpan_header_decompress(struct sk_buff *skb, const struct net_device *dev,
 
 	switch (iphc1 & (LOWPAN_IPHC_M | LOWPAN_IPHC_DAC)) {
 	case LOWPAN_IPHC_M | LOWPAN_IPHC_DAC:
+		skb->pkt_type = PACKET_BROADCAST;
+
 		spin_lock_bh(&lowpan_dev(dev)->ctx.lock);
 		ci = lowpan_iphc_ctx_get_by_id(dev, LOWPAN_IPHC_CID_DCI(cid));
 		if (!ci) {
@@ -681,11 +683,15 @@ int lowpan_header_decompress(struct sk_buff *skb, const struct net_device *dev,
 		spin_unlock_bh(&lowpan_dev(dev)->ctx.lock);
 		break;
 	case LOWPAN_IPHC_M:
+		skb->pkt_type = PACKET_BROADCAST;
+
 		/* multicast */
 		err = lowpan_uncompress_multicast_daddr(skb, &hdr.daddr,
 							iphc1 & LOWPAN_IPHC_DAM_MASK);
 		break;
 	case LOWPAN_IPHC_DAC:
+		skb->pkt_type = PACKET_HOST;
+
 		spin_lock_bh(&lowpan_dev(dev)->ctx.lock);
 		ci = lowpan_iphc_ctx_get_by_id(dev, LOWPAN_IPHC_CID_DCI(cid));
 		if (!ci) {
@@ -701,6 +707,8 @@ int lowpan_header_decompress(struct sk_buff *skb, const struct net_device *dev,
 		spin_unlock_bh(&lowpan_dev(dev)->ctx.lock);
 		break;
 	default:
+		skb->pkt_type = PACKET_HOST;
+
 		err = lowpan_iphc_uncompress_addr(skb, dev, &hdr.daddr,
 						  iphc1 & LOWPAN_IPHC_DAM_MASK,
 						  daddr);
-- 
2.9.3
