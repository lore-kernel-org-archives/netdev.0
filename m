From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: dont update dev->trans_start
Date: Thu, 28 May 2009 12:00:41 +0200
Message-ID: <4A1E60C9.80103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52487 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757983AbZE1KAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 06:00:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Second round of drivers for Gb cards (and NIU one I forgot in the 10GB round)

Now that core network takes care of trans_start updates, dont do it
in drivers themselves, if possible. Drivers can avoid one cache miss
(on dev->trans_start) in their start_xmit() handler.

Exceptions are NETIF_F_LLTX drivers

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/acenic.c           |    1 -
 drivers/net/atl1c/atl1c_main.c |    1 -
 drivers/net/atl1e/atl1e_main.c |    2 +-
 drivers/net/atlx/atl1.c        |    1 -
 drivers/net/bnx2.c             |    1 -
 drivers/net/dl2k.c             |    8 +++-----
 drivers/net/e1000/e1000_main.c |    1 -
 drivers/net/e1000e/netdev.c    |    1 -
 drivers/net/hamachi.c          |    3 +--
 drivers/net/igb/igb_main.c     |    1 -
 drivers/net/igbvf/netdev.c     |    1 -
 drivers/net/jme.c              |    1 -
 drivers/net/niu.c              |    2 --
 drivers/net/ns83820.c          |    6 ++----
 drivers/net/qla3xxx.c          |    1 -
 drivers/net/r8169.c            |    2 --
 drivers/net/sis190.c           |    2 --
 drivers/net/skge.c             |    2 --
 drivers/net/sky2.c             |    1 -
 drivers/net/tg3.c              |    8 ++------
 drivers/net/yellowfin.c        |    3 +--
 21 files changed, 10 insertions(+), 39 deletions(-)

diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 57bc715..08419ee 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -2573,7 +2573,6 @@ restart:
 			netif_wake_queue(dev);
 	}
 
-	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 
 overflow:
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index fc1092b..ac76136 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -2113,7 +2113,6 @@ static int atl1c_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	atl1c_tx_map(adapter, skb, tpd, type);
 	atl1c_tx_queue(adapter, skb, tpd, type);
 
-	netdev->trans_start = jiffies;
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index c271b75..a01383d 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1893,7 +1893,7 @@ static int atl1e_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	atl1e_tx_map(adapter, skb, tpd);
 	atl1e_tx_queue(adapter, tpd_req, tpd);
 
-	netdev->trans_start = jiffies;
+	netdev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 13f0bdc..fccfbf2 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2431,7 +2431,6 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	atl1_tx_queue(adapter, count, ptpd);
 	atl1_update_mailbox(adapter);
 	mmiowb();
-	netdev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index c37acc1..83ee0f5 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6211,7 +6211,6 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	mmiowb();
 
 	txr->tx_prod = prod;
-	dev->trans_start = jiffies;
 
 	if (unlikely(bnx2_tx_avail(bp, txr) <= MAX_SKB_FRAGS)) {
 		netif_tx_stop_queue(txq);
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index 4a1b554..895d721 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -539,7 +539,7 @@ rio_tx_timeout (struct net_device *dev)
 		dev->name, readl (ioaddr + TxStatus));
 	rio_free_tx(dev, 0);
 	dev->if_port = 0;
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 }
 
  /* allocate and initialize Tx and Rx descriptors */
@@ -610,7 +610,7 @@ start_xmit (struct sk_buff *skb, struct net_device *dev)
 
 	if (np->link_status == 0) {	/* Link Down */
 		dev_kfree_skb(skb);
-		return 0;
+		return NETDEV_TX_OK;
 	}
 	ioaddr = dev->base_addr;
 	entry = np->cur_tx % TX_RING_SIZE;
@@ -665,9 +665,7 @@ start_xmit (struct sk_buff *skb, struct net_device *dev)
 		writel (0, dev->base_addr + TFDListPtr1);
 	}
 
-	/* NETDEV WATCHDOG timer */
-	dev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static irqreturn_t
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 9a32d0c..79fe1ee 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3365,7 +3365,6 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	if (count) {
 		e1000_tx_queue(adapter, tx_ring, tx_flags, count);
-		netdev->trans_start = jiffies;
 		/* Make sure there is space in the ring for the next send. */
 		e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index ccaaee0..f012cc6 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4149,7 +4149,6 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	count = e1000_tx_map(adapter, skb, first, max_per_txd, nr_frags, mss);
 	if (count) {
 		e1000_tx_queue(adapter, tx_flags, count);
-		netdev->trans_start = jiffies;
 		/* Make sure there is space in the ring for the next send. */
 		e1000_maybe_stop_tx(netdev, MAX_SKB_FRAGS + 2);
 
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 310ee03..26151fa 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1163,7 +1163,7 @@ static void hamachi_tx_timeout(struct net_device *dev)
 	hmp->rx_ring[RX_RING_SIZE-1].status_n_length |= cpu_to_le32(DescEndRing);
 
 	/* Trigger an immediate transmit demand. */
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	hmp->stats.tx_errors++;
 
 	/* Restart the chip's Tx/Rx processes . */
@@ -1364,7 +1364,6 @@ static int hamachi_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		hmp->tx_full = 1;
 		netif_stop_queue(dev);
 	}
-	dev->trans_start = jiffies;
 
 	if (hamachi_debug > 4) {
 		printk(KERN_DEBUG "%s: Hamachi transmit frame #%d queued in slot %d.\n",
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 8e93750..958b287 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3344,7 +3344,6 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 	if (count) {
 		igb_tx_queue_adv(adapter, tx_ring, tx_flags, count,
 			         skb->len, hdr_len);
-		netdev->trans_start = jiffies;
 		/* Make sure there is space in the ring for the next send. */
 		igb_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 4);
 	} else {
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 44a8eef..5f7ba1a 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2270,7 +2270,6 @@ static int igbvf_xmit_frame_ring_adv(struct sk_buff *skb,
 	if (count) {
 		igbvf_tx_queue_adv(adapter, tx_ring, tx_flags, count,
 		                   skb->len, hdr_len);
-		netdev->trans_start = jiffies;
 		/* Make sure there is space in the ring for the next send. */
 		igbvf_maybe_stop_tx(netdev, MAX_SKB_FRAGS + 4);
 	} else {
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 621a7c0..1e3c63d 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -1939,7 +1939,6 @@ jme_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 				TXCS_SELECT_QUEUE0 |
 				TXCS_QUEUE0S |
 				TXCS_ENABLE);
-	netdev->trans_start = jiffies;
 
 	tx_dbg(jme, "xmit: %d+%d@%lu\n", idx,
 			skb_shinfo(skb)->nr_frags + 2,
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 0d9de5a..edac3a0 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6777,8 +6777,6 @@ static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			netif_tx_wake_queue(txq);
 	}
 
-	dev->trans_start = jiffies;
-
 out:
 	return NETDEV_TX_OK;
 
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index d531614..940962a 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1204,9 +1204,7 @@ again:
 	if (stopped && (dev->tx_done_idx != tx_done_idx) && start_tx_okay(dev))
 		netif_start_queue(ndev);
 
-	/* set the transmit start time to catch transmit timeouts */
-	ndev->trans_start = jiffies;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void ns83820_update_stats(struct ns83820 *dev)
@@ -1626,7 +1624,7 @@ static void ns83820_tx_watch(unsigned long data)
 		);
 #endif
 
-	if (time_after(jiffies, ndev->trans_start + 1*HZ) &&
+	if (time_after(jiffies, dev_trans_start(ndev) + 1*HZ) &&
 	    dev->tx_done_idx != dev->tx_free_idx) {
 		printk(KERN_DEBUG "%s: ns83820_tx_watch: %u %u %d\n",
 			ndev->name,
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index cadc32c..8a823ec 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2617,7 +2617,6 @@ static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
 			    &port_regs->CommonRegs.reqQProducerIndex,
 			    qdev->req_producer_index);
 
-	ndev->trans_start = jiffies;
 	if (netif_msg_tx_queued(qdev))
 		printk(KERN_DEBUG PFX "%s: tx queued, slot %d, len %d\n",
 		       ndev->name, qdev->req_producer_index, skb->len);
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0ec0605..7fa88d2 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3279,8 +3279,6 @@ static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	status = opts1 | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
 	txd->opts1 = cpu_to_le32(status);
 
-	dev->trans_start = jiffies;
-
 	tp->cur_tx += frags + 1;
 
 	smp_wmb();
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 55ccd51..13b8ca4 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1204,8 +1204,6 @@ static int sis190_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	SIS_W32(TxControl, 0x1a00 | CmdReset | CmdTxEnb);
 
-	dev->trans_start = jiffies;
-
 	dirty_tx = tp->dirty_tx;
 	if ((tp->cur_tx - NUM_TX_DESC) == dirty_tx) {
 		netif_stop_queue(dev);
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index c11cdd0..60d502e 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2837,8 +2837,6 @@ static int skge_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 	}
 
-	dev->trans_start = jiffies;
-
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a2ff9cb..6b5946f 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1690,7 +1690,6 @@ static int sky2_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 
 	sky2_put_idx(hw, txqaddr[sky2->port], sky2->tx_prod);
 
-	dev->trans_start = jiffies;
 	return NETDEV_TX_OK;
 
 mapping_unwind:
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index eb65e25..a39b534 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5194,9 +5194,7 @@ static int tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 out_unlock:
-    	mmiowb();
-
-	dev->trans_start = jiffies;
+	mmiowb();
 
 	return NETDEV_TX_OK;
 }
@@ -5407,9 +5405,7 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 	}
 
 out_unlock:
-    	mmiowb();
-
-	dev->trans_start = jiffies;
+	mmiowb();
 
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 7477ffd..3c7a505 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -717,7 +717,7 @@ static void yellowfin_tx_timeout(struct net_device *dev)
 	if (yp->cur_tx - yp->dirty_tx < TX_QUEUE_SIZE)
 		netif_wake_queue (dev);		/* Typical path */
 
-	dev->trans_start = jiffies;
+	dev->trans_start = jiffies; /* prevent tx timeout */
 	dev->stats.tx_errors++;
 }
 
@@ -876,7 +876,6 @@ static int yellowfin_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_start_queue (dev);		/* Typical path */
 	else
 		yp->tx_full = 1;
-	dev->trans_start = jiffies;
 
 	if (yellowfin_debug > 4) {
 		printk(KERN_DEBUG "%s: Yellowfin transmit frame #%d queued in slot %d.\n",


