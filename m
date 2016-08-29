From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH v2 1/1] net: macb: initialize checksum when using checksum offloading
Date: Mon, 29 Aug 2016 15:57:25 +0200
Message-ID: <1472479045-8814-2-git-send-email-helmut.buchsbaum@gmail.com>
References: <1471611898-3852-2-git-send-email-helmut.buchsbaum@gmail.com>
 <1472479045-8814-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: Michal Simek <michal.simek@xilinx.com>, netdev@vger.kernel.org,
        Cyrille Pitchen <cyrille.pitchen@atmel.com>,
        Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: David Miller <davem@davemloft.net>, tom@herbertland.com,
        Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35939 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757252AbcH2N6I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 09:58:08 -0400
Received: by mail-wm0-f65.google.com with SMTP id i138so9669337wmf.3
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 06:58:07 -0700 (PDT)
In-Reply-To: <1472479045-8814-1-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MACB/GEM needs the checksum field initialized to 0 to get correct
results on transmit in all cases, e.g. on Zynq, UDP packets with
payload <= 2 otherwise contain a wrong checksums.

Signed-off-by: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 89c0cfa..de2f791 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1323,6 +1323,19 @@ dma_error:
 	return 0;
 }
 
+static inline void macb_clear_csum(struct sk_buff *skb)
+{
+	/* no change for packets without checksum offloading */
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return;
+
+	/* initialize checksum field
+	 * This is required - at least for Zynq, which otherwise calculates
+	 * wrong UDP header checksums for UDP packets with UDP data len <=2
+	 */
+	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) = 0;
+}
+
 static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	u16 queue_index = skb_get_queue_mapping(skb);
@@ -1362,6 +1375,8 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
+	macb_clear_csum(skb);
+
 	/* Map socket buffer for DMA transfer */
 	if (!macb_tx_map(bp, queue, skb)) {
 		dev_kfree_skb_any(skb);
-- 
2.1.4
