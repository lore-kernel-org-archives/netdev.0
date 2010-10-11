From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2x: dont use netdev_alloc_skb()
Date: Tue, 12 Oct 2010 01:03:30 +0200
Message-ID: <1286838210.30423.128.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39661 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306Ab0JKXDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 19:03:51 -0400
Received: by wwj40 with SMTP id 40so4300486wwj.1
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 16:03:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_alloc_skb() is a very wrong interface, really.

We should remove/deprecate it.

For multi queue devices, it makes more sense to allocate skb on local
node of the cpu handling RX interrupts. This allow each cpu to
manipulate its own slub/slab queues/structures without doing expensive
cross-node business.

For non multi queue devices, IRQ affinity should be set so that a cpu
close to the device services interrupts. Even if not set, using
dev_alloc_skb() is faster.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c     |   11 +++++------
 drivers/net/bnx2x/bnx2x_cmn.h     |    2 +-
 drivers/net/bnx2x/bnx2x_ethtool.c |    2 +-
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 97ef674..0561bd9 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -335,7 +335,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	struct sw_rx_bd *rx_buf = &fp->tpa_pool[queue];
 	struct sk_buff *skb = rx_buf->skb;
 	/* alloc new skb */
-	struct sk_buff *new_skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+	struct sk_buff *new_skb = dev_alloc_skb(bp->rx_buf_size);
 
 	/* Unmap skb in the pool anyway, as we are going to change
 	   pool entry status to BNX2X_TPA_STOP even if new skb allocation
@@ -576,8 +576,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 			    (len <= RX_COPY_THRESH)) {
 				struct sk_buff *new_skb;
 
-				new_skb = netdev_alloc_skb(bp->dev,
-							   len + pad);
+				new_skb = dev_alloc_skb(len + pad);
 				if (new_skb == NULL) {
 					DP(NETIF_MSG_RX_ERR,
 					   "ERROR  packet dropped "
@@ -587,9 +586,9 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 				}
 
 				/* aligned copy */
-				skb_copy_from_linear_data_offset(skb, pad,
-						    new_skb->data + pad, len);
 				skb_reserve(new_skb, pad);
+				skb_copy_from_linear_data_offset(skb, pad,
+						    new_skb->data, len);
 				skb_put(new_skb, len);
 
 				bnx2x_reuse_rx_skb(fp, bd_cons, bd_prod);
@@ -841,7 +840,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 		if (!fp->disable_tpa) {
 			for (i = 0; i < max_agg_queues; i++) {
 				fp->tpa_pool[i].skb =
-				   netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+				   dev_alloc_skb(bp->rx_buf_size);
 				if (!fp->tpa_pool[i].skb) {
 					BNX2X_ERR("Failed to allocate TPA "
 						  "skb pool for queue[%d] - "
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 7f52cec..f422cfc 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -833,7 +833,7 @@ static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
 	struct eth_rx_bd *rx_bd = &fp->rx_desc_ring[index];
 	dma_addr_t mapping;
 
-	skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+	skb = dev_alloc_skb(bp->rx_buf_size);
 	if (unlikely(skb == NULL))
 		return -ENOMEM;
 
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 54fe061..5224daa 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1430,7 +1430,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	/* prepare the loopback packet */
 	pkt_size = (((bp->dev->mtu < ETH_MAX_PACKET_SIZE) ?
 		     bp->dev->mtu : ETH_MAX_PACKET_SIZE) + ETH_HLEN);
-	skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
+	skb = dev_alloc_skb(bp->rx_buf_size);
 	if (!skb) {
 		rc = -ENOMEM;
 		goto test_loopback_exit;


