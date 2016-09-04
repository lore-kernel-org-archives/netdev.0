From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH v3] net: macb: initialize checksum when using checksum offloading
Date: Sun,  4 Sep 2016 18:09:47 +0200
Message-ID: <1473005387-24917-1-git-send-email-helmut.buchsbaum@gmail.com>
References: <1472479045-8814-2-git-send-email-helmut.buchsbaum@gmail.com>
Cc: tom@herbertland.com, Michal Simek <michal.simek@xilinx.com>,
        netdev@vger.kernel.org,
        Cyrille Pitchen <cyrille.pitchen@atmel.com>,
        Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: David Miller <davem@davemloft.net>,
        Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36329 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754325AbcIDQLu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2016 12:11:50 -0400
Received: by mail-wm0-f68.google.com with SMTP id l65so2028930wmf.3
        for <netdev@vger.kernel.org>; Sun, 04 Sep 2016 09:10:35 -0700 (PDT)
In-Reply-To: <1472479045-8814-2-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm still struggling to get this fix right..

Changes since v2:
 - do not blindly modify SKB contents according to Dave's legitimate
   objection

Changes since v1:
 - dropped disabling HW checksum offload for Zynq
 - initialize checksum similar to net/ethernet/freescale/fec_main.c

-- >8 --
MACB/GEM needs the checksum field initialized to 0 to get correct
results on transmit in all cases, e.g. on Zynq, UDP packets with
payload <= 2 otherwise contain a wrong checksums.

Signed-off-by: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 89c0cfa..d954a97 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1323,6 +1323,24 @@ dma_error:
 	return 0;
 }
 
+static inline int macb_clear_csum(struct sk_buff *skb)
+{
+	/* no change for packets without checksum offloading */
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
+
+	/* make sure we can modify the header */
+	if (unlikely(skb_cow_head(skb, 0)))
+		return -1;
+
+	/* initialize checksum field
+	 * This is required - at least for Zynq, which otherwise calculates
+	 * wrong UDP header checksums for UDP packets with UDP data len <=2
+	 */
+	*(__sum16 *)(skb_checksum_start(skb) + skb->csum_offset) = 0;
+	return 0;
+}
+
 static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	u16 queue_index = skb_get_queue_mapping(skb);
@@ -1362,6 +1380,11 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
+	if (macb_clear_csum(skb)) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
 	/* Map socket buffer for DMA transfer */
 	if (!macb_tx_map(bp, queue, skb)) {
 		dev_kfree_skb_any(skb);
-- 
2.1.4
