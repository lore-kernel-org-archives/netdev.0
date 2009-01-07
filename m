From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 29/42] uli526x: convert devices to new API
Date: Tue, 06 Jan 2009 16:33:45 -0800
Message-ID: <20090107003348.590315627@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52741 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757819AbZAGA7R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:59:17 -0500
Content-Disposition: inline; filename=tulip-uli.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to net_device_ops and internal net_device_stats

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tulip/uli526x.c	2009-01-06 16:08:31.181361709 -0800
+++ b/drivers/net/tulip/uli526x.c	2009-01-06 16:13:50.845109956 -0800
@@ -168,9 +168,6 @@ struct uli526x_board_info {
 	u8 wait_reset;			/* Hardware failed, need to reset */
 	struct timer_list timer;
 
-	/* System defined statistic counter */
-	struct net_device_stats stats;
-
 	/* Driver defined statistic counter */
 	unsigned long tx_fifo_underrun;
 	unsigned long tx_loss_carrier;
@@ -220,7 +217,6 @@ static int mode = 8;
 static int uli526x_open(struct net_device *);
 static int uli526x_start_xmit(struct sk_buff *, struct net_device *);
 static int uli526x_stop(struct net_device *);
-static struct net_device_stats * uli526x_get_stats(struct net_device *);
 static void uli526x_set_filter_mode(struct net_device *);
 static const struct ethtool_ops netdev_ethtool_ops;
 static u16 read_srom_word(long, int);
@@ -251,6 +247,19 @@ static void uli526x_set_phyxcer(struct u
 
 /* ULI526X network board routine ---------------------------- */
 
+static const struct net_device_ops netdev_ops = {
+	.ndo_open		= uli526x_open,
+	.ndo_stop		= uli526x_stop,
+	.ndo_start_xmit		= uli526x_start_xmit,
+	.ndo_set_multicast_list = uli526x_set_filter_mode,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller 	= uli526x_poll,
+#endif
+};
+
 /*
  *	Search ULI526X board, allocate space and register it
  */
@@ -335,15 +344,9 @@ static int __devinit uli526x_init_one (s
 	pci_set_drvdata(pdev, dev);
 
 	/* Register some necessary functions */
-	dev->open = &uli526x_open;
-	dev->hard_start_xmit = &uli526x_start_xmit;
-	dev->stop = &uli526x_stop;
-	dev->get_stats = &uli526x_get_stats;
-	dev->set_multicast_list = &uli526x_set_filter_mode;
+	dev->netdev_ops = &netdev_ops;
 	dev->ethtool_ops = &netdev_ethtool_ops;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = &uli526x_poll;
-#endif
+
 	spin_lock_init(&db->lock);
 
 
@@ -733,7 +736,8 @@ static void uli526x_poll(struct net_devi
  *	Free TX resource after TX complete
  */
 
-static void uli526x_free_tx_pkt(struct net_device *dev, struct uli526x_board_info * db)
+static void uli526x_free_tx_pkt(struct net_device *dev,
+				struct uli526x_board_info * db)
 {
 	struct tx_desc *txptr;
 	u32 tdes0;
@@ -747,15 +751,15 @@ static void uli526x_free_tx_pkt(struct n
 
 		/* A packet sent completed */
 		db->tx_packet_cnt--;
-		db->stats.tx_packets++;
+		dev->stats.tx_packets++;
 
 		/* Transmit statistic counter */
 		if ( tdes0 != 0x7fffffff ) {
 			/* printk(DRV_NAME ": tdes0=%x\n", tdes0); */
-			db->stats.collisions += (tdes0 >> 3) & 0xf;
-			db->stats.tx_bytes += le32_to_cpu(txptr->tdes1) & 0x7ff;
+			dev->stats.collisions += (tdes0 >> 3) & 0xf;
+			dev->stats.tx_bytes += le32_to_cpu(txptr->tdes1) & 0x7ff;
 			if (tdes0 & TDES0_ERR_MASK) {
-				db->stats.tx_errors++;
+				dev->stats.tx_errors++;
 				if (tdes0 & 0x0002) {	/* UnderRun */
 					db->tx_fifo_underrun++;
 					if ( !(db->cr6_data & CR6_SFT) ) {
@@ -825,13 +829,13 @@ static void uli526x_rx_packet(struct net
 			if (rdes0 & 0x8000) {
 				/* This is a error packet */
 				//printk(DRV_NAME ": rdes0: %lx\n", rdes0);
-				db->stats.rx_errors++;
+				dev->stats.rx_errors++;
 				if (rdes0 & 1)
-					db->stats.rx_fifo_errors++;
+					dev->stats.rx_fifo_errors++;
 				if (rdes0 & 2)
-					db->stats.rx_crc_errors++;
+					dev->stats.rx_crc_errors++;
 				if (rdes0 & 0x80)
-					db->stats.rx_length_errors++;
+					dev->stats.rx_length_errors++;
 			}
 
 			if ( !(rdes0 & 0x8000) ||
@@ -854,8 +858,8 @@ static void uli526x_rx_packet(struct net
 
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
-				db->stats.rx_packets++;
-				db->stats.rx_bytes += rxlen;
+				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += rxlen;
 
 			} else {
 				/* Reuse SKB buffer when the packet is error */
@@ -872,19 +876,6 @@ static void uli526x_rx_packet(struct net
 
 
 /*
- *	Get statistics from driver.
- */
-
-static struct net_device_stats * uli526x_get_stats(struct net_device *dev)
-{
-	struct uli526x_board_info *db = netdev_priv(dev);
-
-	ULI526X_DBUG(0, "uli526x_get_stats", 0);
-	return &db->stats;
-}
-
-
-/*
  * Set ULI526X multicast address
  */
 

-- 

