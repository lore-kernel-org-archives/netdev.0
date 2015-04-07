From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 5/6] via-rhine: kiss rx_head_desc goodbye.
Date: Wed,  8 Apr 2015 00:40:52 +0200
Message-ID: <6f2fb49eb6b37ff18c753634a7d57effdd671f3b.1428445141.git.romieu@fr.zoreil.com>
References: <cover.1428445141.git.romieu@fr.zoreil.com>
Cc: "Nix" <nix@esperi.org.uk>, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, "Bjarke Istrup Pedersen" <gurligebis@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54404 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753205AbbDGWlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 18:41:03 -0400
In-Reply-To: <cover.1428445141.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1428445141.git.romieu@fr.zoreil.com>
References: <cover.1428445141.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It duplicates cur_rx.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 8d322bb..fede9fc 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -472,7 +472,6 @@ struct rhine_private {
 
 	/* Frequently used values: keep some adjacent for cache effect. */
 	u32 quirks;
-	struct rx_desc *rx_head_desc;
 	unsigned int cur_rx;
 	unsigned int cur_tx, dirty_tx;
 	unsigned int rx_buf_sz;		/* Based on MTU+slack. */
@@ -1244,7 +1243,6 @@ static void rhine_reset_rbufs(struct rhine_private *rp)
 	int i;
 
 	rp->cur_rx = 0;
-	rp->rx_head_desc = rp->rx_ring;
 
 	for (i = 0; i < RX_RING_SIZE; i++)
 		rp->rx_ring[i].rx_status = cpu_to_le32(DescOwn);
@@ -2000,15 +1998,15 @@ static int rhine_rx(struct net_device *dev, int limit)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	struct device *hwdev = dev->dev.parent;
-	int count;
 	int entry = rp->cur_rx % RX_RING_SIZE;
+	int count;
 
 	netif_dbg(rp, rx_status, dev, "%s(), entry %d status %08x\n", __func__,
-		  entry, le32_to_cpu(rp->rx_head_desc->rx_status));
+		  entry, le32_to_cpu(rp->rx_ring[entry].rx_status));
 
 	/* If EOP is set on the next entry, it's a new packet. Send it up. */
 	for (count = 0; count < limit; ++count) {
-		struct rx_desc *desc = rp->rx_head_desc;
+		struct rx_desc *desc = rp->rx_ring + entry;
 		u32 desc_status = le32_to_cpu(desc->rx_status);
 		u32 desc_length = le32_to_cpu(desc->desc_length);
 		int data_size = desc_status >> 16;
@@ -2026,10 +2024,6 @@ static int rhine_rx(struct net_device *dev, int limit)
 	"entry %#x length %d status %08x!\n",
 					    entry, data_size,
 					    desc_status);
-				netdev_warn(dev,
-					    "Oversized Ethernet frame %p vs %p\n",
-					    rp->rx_head_desc,
-					    &rp->rx_ring[entry]);
 				dev->stats.rx_length_errors++;
 			} else if (desc_status & RxErr) {
 				/* There was a error. */
@@ -2110,7 +2104,6 @@ static int rhine_rx(struct net_device *dev, int limit)
 give_descriptor_to_nic:
 		desc->rx_status = cpu_to_le32(DescOwn);
 		entry = (++rp->cur_rx) % RX_RING_SIZE;
-		rp->rx_head_desc = &rp->rx_ring[entry];
 	}
 
 	return count;
-- 
2.1.0
