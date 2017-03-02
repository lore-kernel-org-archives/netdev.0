From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: [PATCH v6 3/6] 6lowpan: iphc: override l2 packet information
Date: Thu,  2 Mar 2017 15:23:32 +0200
Message-ID: <20170302132335.21192-4-luiz.dentz@gmail.com>
References: <20170302132335.21192-1-luiz.dentz@gmail.com>
Cc: patrik.flykt@linux.intel.com, aar@pengutronix.de,
        jukka.rissanen@linux.intel.com, linux-wpan@vger.kernel.org,
        netdev@vger.kernel.org
To: linux-bluetooth@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33672 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752618AbdCBNcB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 08:32:01 -0500
In-Reply-To: <20170302132335.21192-1-luiz.dentz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <aar@pengutronix.de>

The skb->pkt_type need to be set by L2, but on 6LoWPAN there exists L2
e.g. BTLE which doesn't has multicast addressing. If it's a multicast or
not is detected by IPHC headers multicast bit. The IPv6 layer will
evaluate this pkt_type, so we force set this type while uncompressing.
Should be okay for 802.15.4 as well.

Signed-off-by: Alexander Aring <aar@pengutronix.de>
Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>
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
