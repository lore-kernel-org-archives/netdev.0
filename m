From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: dont update dev->trans_start in 10GB drivers
Date: Thu, 28 May 2009 07:26:37 +0200
Message-ID: <4A1E208D.2020106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60868 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbZE1F0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 01:26:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Followup of commits 9d21493b4beb8f918ba248032fefa393074a5e2b
and 08baf561083bc27a953aa087dd8a664bb2b88e8e
(net: tx scalability works : trans_start)
(net: txq_trans_update() helper)

Now that core network takes care of trans_start updates, dont do it
in drivers themselves, if possible. Multi queue drivers can
avoid one cache miss (on dev->trans_start) in their start_xmit()
handler.

Exceptions are NETIF_F_LLTX drivers (vxge & tehuti)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/benet/be_main.c          |    2 --
 drivers/net/bnx2x_main.c             |    1 -
 drivers/net/chelsio/sge.c            |    1 -
 drivers/net/cxgb3/sge.c              |    1 -
 drivers/net/enic/enic_main.c         |    2 --
 drivers/net/ixgb/ixgb_main.c         |    1 -
 drivers/net/ixgbe/ixgbe_main.c       |    1 -
 drivers/net/mlx4/en_tx.c             |    1 -
 drivers/net/myri10ge/myri10ge.c      |    1 -
 drivers/net/netxen/netxen_nic_main.c |    1 -
 drivers/net/qlge/qlge_main.c         |    1 -
 drivers/net/s2io.c                   |    1 -
 drivers/net/sfc/selftest.c           |    1 +
 drivers/net/sfc/tx.c                 |    7 -------
 drivers/net/tehuti.c                 |    5 +++--
 drivers/net/vxge/vxge-main.c         |    6 ++++--
 16 files changed, 8 insertions(+), 25 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index ae2f6b5..5f17d80 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -478,8 +478,6 @@ static int be_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	be_txq_notify(&adapter->ctrl, txq->id, wrb_cnt);
 
-	netdev->trans_start = jiffies;
-
 	be_tx_stats_update(adapter, wrb_cnt, copied, stopped);
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index e01539c..fbf1352 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -10617,7 +10617,6 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	mmiowb();
 
 	fp->tx_bd_prod += nbd;
-	dev->trans_start = jiffies;
 
 	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3)) {
 		/* We want bnx2x_tx_int to "see" the updated tx_bd_prod
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 5e97a1a..3711d64 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1879,7 +1879,6 @@ int t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		cpl->vlan_valid = 0;
 
 send:
-	dev->trans_start = jiffies;
 	ret = t1_sge_tx(skb, adapter, 0, dev);
 
 	/* If transmit busy, and we reallocated skb's due to headroom limit,
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 73d569e..49e64af 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1286,7 +1286,6 @@ int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (vlan_tx_tag_present(skb) && pi->vlan_grp)
 		qs->port_stats[SGE_PSTAT_VLANINS]++;
 
-	dev->trans_start = jiffies;
 	spin_unlock(&q->lock);
 
 	/*
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 9080f07..8005b60 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -661,8 +661,6 @@ static int enic_hard_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	if (vnic_wq_desc_avail(wq) < MAX_SKB_FRAGS + 1)
 		netif_stop_queue(netdev);
 
-	netdev->trans_start = jiffies;
-
 	spin_unlock_irqrestore(&enic->wq_lock[0], flags);
 
 	return NETDEV_TX_OK;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 04cb81a..6eb7f37 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1488,7 +1488,6 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	if (count) {
 		ixgb_tx_queue(adapter, count, vlan_id, tx_flags);
-		netdev->trans_start = jiffies;
 		/* Make sure there is space in the ring for the next send. */
 		ixgb_maybe_stop_tx(netdev, &adapter->tx_ring, DESC_NEEDED);
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index dff1da8..924aa5e 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4863,7 +4863,6 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (count) {
 		ixgbe_tx_queue(adapter, tx_ring, tx_flags, count, skb->len,
 		               hdr_len);
-		netdev->trans_start = jiffies;
 		ixgbe_maybe_stop_tx(netdev, tx_ring, DESC_NEEDED);
 
 	} else {
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index ac6fc49..1c83a96 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -819,7 +819,6 @@ int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Ring doorbell! */
 	wmb();
 	writel(ring->doorbell_qpn, mdev->uar_map + MLX4_SEND_DOORBELL);
-	dev->trans_start = jiffies;
 
 	/* Poll CQ here */
 	mlx4_en_xmit_poll(priv, tx_ind);
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 7e28b46..c9a30d3 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -2892,7 +2892,6 @@ again:
 		tx->stop_queue++;
 		netif_tx_stop_queue(netdev_queue);
 	}
-	dev->trans_start = jiffies;
 	return 0;
 
 abort_linearize:
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 50477f5..98737ef 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1496,7 +1496,6 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	netxen_nic_update_cmd_producer(adapter, tx_ring, producer);
 
 	adapter->stats.xmitcalled++;
-	netdev->trans_start = jiffies;
 
 	return NETDEV_TX_OK;
 
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c92ced2..0b0778d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2108,7 +2108,6 @@ static int qlge_send(struct sk_buff *skb, struct net_device *ndev)
 	wmb();
 
 	ql_write_db_reg(tx_ring->prod_idx, tx_ring->prod_idx_db_reg);
-	ndev->trans_start = jiffies;
 	QPRINTK(qdev, TX_QUEUED, DEBUG, "tx queued, slot %d, len %d\n",
 		tx_ring->prod_idx, skb->len);
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 80562ea..2bc73ed 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -4299,7 +4299,6 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 		s2io_stop_tx_queue(sp, fifo->fifo_no);
 	}
 	mac_control->stats_info->sw_stat.mem_allocated += skb->truesize;
-	dev->trans_start = jiffies;
 	spin_unlock_irqrestore(&fifo->tx_lock, flags);
 
 	if (sp->config.intr_type == MSI_X)
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 0437957..b67ccca 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -438,6 +438,7 @@ static int efx_begin_loopback(struct efx_tx_queue *tx_queue)
 			kfree_skb(skb);
 			return -EPIPE;
 		}
+		efx->net_dev->trans_start = jiffies;
 	}
 
 	return 0;
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index d6681ed..14a1478 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -360,13 +360,6 @@ inline int efx_xmit(struct efx_nic *efx,
 
 	/* Map fragments for DMA and add to TX queue */
 	rc = efx_enqueue_skb(tx_queue, skb);
-	if (unlikely(rc != NETDEV_TX_OK))
-		goto out;
-
-	/* Update last TX timer */
-	efx->net_dev->trans_start = jiffies;
-
- out:
 	return rc;
 }
 
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 7f4a968..093807a 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1718,8 +1718,9 @@ static int bdx_tx_transmit(struct sk_buff *skb, struct net_device *ndev)
 	WRITE_REG(priv, f->m.reg_WPTR, f->m.wptr & TXF_WPTR_WR_PTR);
 
 #endif
-	ndev->trans_start = jiffies;
-
+#ifdef BDX_LLTX
+	ndev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
+#endif
 	priv->net_stats.tx_packets++;
 	priv->net_stats.tx_bytes += skb->len;
 
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index b7f08f3..6c838b3 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -677,7 +677,7 @@ vxge_xmit_compl(struct __vxge_hw_fifo *fifo_hw, void *dtr,
 	return VXGE_HW_OK;
 }
 
-/* select a vpath to trasmit the packet */
+/* select a vpath to transmit the packet */
 static u32 vxge_get_vpath_no(struct vxgedev *vdev, struct sk_buff *skb,
 	int *do_lock)
 {
@@ -992,7 +992,9 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 					VXGE_HW_FIFO_TXD_TX_CKO_UDP_EN);
 
 	vxge_hw_fifo_txdl_post(fifo_hw, dtr);
-	dev->trans_start = jiffies;
+#ifdef NETIF_F_LLTX
+	dev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
+#endif
 	spin_unlock_irqrestore(&fifo->tx_lock, flags);
 
 	VXGE_COMPLETE_VPATH_TX(fifo);
