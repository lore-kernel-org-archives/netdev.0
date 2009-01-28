From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/4]: net: Add skb_record_rx_queue() calls to multiqueue
 capable drivers.
Date: Tue, 27 Jan 2009 16:40:29 -0800 (PST)
Message-ID: <20090127.164029.199987043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43819
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751891AbZA1Akb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 19:40:31 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6596E35C003
	for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 16:40:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/bnx2.c              |    2 ++
 drivers/net/bnx2x_main.c        |    1 +
 drivers/net/cxgb3/sge.c         |    1 +
 drivers/net/igb/igb_main.c      |    1 +
 drivers/net/ixgbe/ixgbe_main.c  |    1 +
 drivers/net/mlx4/en_rx.c        |    1 +
 drivers/net/myri10ge/myri10ge.c |    1 +
 drivers/net/niu.c               |    1 +
 drivers/net/qlge/qlge_main.c    |    1 +
 drivers/net/s2io.c              |    1 +
 drivers/net/sfc/rx.c            |    2 ++
 11 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index fe575b9..49e0e51 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3007,6 +3007,8 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 		}
 
+		skb_record_rx_queue(skb, bnapi - &bp->bnx2_napi[0]);
+
 #ifdef BCM_VLAN
 		if (hw_vlan)
 			vlan_hwaccel_receive_skb(skb, bp->vlgrp, vtag);
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 71f81c7..88da14c 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1325,6 +1325,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 		skb->protocol = eth_type_trans(skb, bp->dev);
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		skb_record_rx_queue(skb, queue);
 
 		{
 			struct iphdr *iph;
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 8299fb5..272a016 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1937,6 +1937,7 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else
 		skb->ip_summed = CHECKSUM_NONE;
+	skb_record_rx_queue(skb, qs - &adap->sge.qs[0]);
 
 	if (unlikely(p->vlan_valid)) {
 		struct vlan_group *grp = pi->vlan_grp;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index e11043d..bd16680 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3751,6 +3751,7 @@ static void igb_receive_skb(struct igb_ring *ring, u8 status,
 	struct igb_adapter * adapter = ring->adapter;
 	bool vlan_extracted = (adapter->vlgrp && (status & E1000_RXD_STAT_VP));
 
+	skb_record_rx_queue(skb, ring->queue_index);
 	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
 		if (vlan_extracted)
 			vlan_gro_receive(&ring->napi, adapter->vlgrp,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 43980dc..fe4a4d1 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -414,6 +414,7 @@ static void ixgbe_receive_skb(struct ixgbe_q_vector *q_vector,
 	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
 	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
+	skb_record_rx_queue(skb, q_vector - &adapter->q_vector[0]);
 	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
 		if (adapter->vlgrp && is_vlan && (tag != 0))
 			vlan_gro_receive(napi, adapter->vlgrp, tag, skb);
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index ac55ebd..a4130e7 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -768,6 +768,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 
 		skb->ip_summed = ip_summed;
 		skb->protocol = eth_type_trans(skb, dev);
+		skb_record_rx_queue(skb, cq->ring);
 
 		/* Push it up the stack */
 		if (priv->vlgrp && (be32_to_cpu(cqe->vlan_my_qpn) &
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 2dacb88..aea9fda 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1324,6 +1324,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, struct myri10ge_rx_buf *rx,
 		skb_shinfo(skb)->nr_frags = 0;
 	}
 	skb->protocol = eth_type_trans(skb, dev);
+	skb_record_rx_queue(skb, ss - &mgp->ss[0]);
 
 	if (mgp->csum_flag) {
 		if ((skb->protocol == htons(ETH_P_IP)) ||
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 4a5a089..2346ca6 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3390,6 +3390,7 @@ static int niu_process_rx_pkt(struct niu *np, struct rx_ring_info *rp)
 	rp->rx_bytes += skb->len;
 
 	skb->protocol = eth_type_trans(skb, np->dev);
+	skb_record_rx_queue(skb, rp->rx_channel);
 	netif_receive_skb(skb);
 
 	return num_rcr;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 16eb9dd..4ab6e72 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1436,6 +1436,7 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 	qdev->stats.rx_packets++;
 	qdev->stats.rx_bytes += skb->len;
 	skb->protocol = eth_type_trans(skb, ndev);
+	skb_record_rx_queue(skb, rx_ring - &qdev->rx_ring[0]);
 	if (qdev->vlgrp && (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V)) {
 		QPRINTK(qdev, RX_STATUS, DEBUG,
 			"Passing a VLAN packet upstream.\n");
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 2a96a10..e0a353f 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7542,6 +7542,7 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 
 	sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
 send_up:
+	skb_record_rx_queue(skb, ring_no);
 	queue_rx_frame(skb, RXD_GET_VLAN_TAG(rxdp->Control_2));
 aggregate:
 	sp->mac_control.rings[ring_no].rx_bufs_left -= 1;
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index a0345b3..66d7fe3 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -575,6 +575,8 @@ void __efx_rx_packet(struct efx_channel *channel,
 	/* Set the SKB flags */
 	skb->ip_summed = CHECKSUM_NONE;
 
+	skb_record_rx_queue(skb, channel->channel);
+
 	/* Pass the packet up */
 	netif_receive_skb(skb);
 
-- 
1.6.1.15.g159c88

