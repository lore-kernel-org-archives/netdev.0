From: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: [patch 13/30] wireless: convert wavelan to net_device_ops
Date: Thu, 26 Mar 2009 18:11:27 -0700
Message-ID: <20090327011255.886835267@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=wavelan.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>

---
 drivers/net/wireless/wavelan.c   |   79 +++++++++++++++++----------------------
 drivers/net/wireless/wavelan.p.h |    9 ----
 2 files changed, 37 insertions(+), 51 deletions(-)

--- a/drivers/net/wireless/wavelan.c	2009-03-21 12:37:00.000000000 -0700
+++ b/drivers/net/wireless/wavelan.c	2009-03-26 15:53:57.427387348 -0700
@@ -735,9 +735,9 @@ if (lp->tx_n_in_use > 0)
 		if (tx_status & AC_SFLD_OK) {
 			int ncollisions;
 
-			lp->stats.tx_packets++;
+			dev->stats.tx_packets++;
 			ncollisions = tx_status & AC_SFLD_MAXCOL;
-			lp->stats.collisions += ncollisions;
+			dev->stats.collisions += ncollisions;
 #ifdef DEBUG_TX_INFO
 			if (ncollisions > 0)
 				printk(KERN_DEBUG
@@ -745,9 +745,9 @@ if (lp->tx_n_in_use > 0)
 				       dev->name, ncollisions);
 #endif
 		} else {
-			lp->stats.tx_errors++;
+			dev->stats.tx_errors++;
 			if (tx_status & AC_SFLD_S10) {
-				lp->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 #ifdef DEBUG_TX_FAIL
 				printk(KERN_DEBUG
 				       "%s: wv_complete(): tx error: no CS.\n",
@@ -755,7 +755,7 @@ if (lp->tx_n_in_use > 0)
 #endif
 			}
 			if (tx_status & AC_SFLD_S9) {
-				lp->stats.tx_carrier_errors++;
+				dev->stats.tx_carrier_errors++;
 #ifdef DEBUG_TX_FAIL
 				printk(KERN_DEBUG
 				       "%s: wv_complete(): tx error: lost CTS.\n",
@@ -763,7 +763,7 @@ if (lp->tx_n_in_use > 0)
 #endif
 			}
 			if (tx_status & AC_SFLD_S8) {
-				lp->stats.tx_fifo_errors++;
+				dev->stats.tx_fifo_errors++;
 #ifdef DEBUG_TX_FAIL
 				printk(KERN_DEBUG
 				       "%s: wv_complete(): tx error: slow DMA.\n",
@@ -771,7 +771,7 @@ if (lp->tx_n_in_use > 0)
 #endif
 			}
 			if (tx_status & AC_SFLD_S6) {
-				lp->stats.tx_heartbeat_errors++;
+				dev->stats.tx_heartbeat_errors++;
 #ifdef DEBUG_TX_FAIL
 				printk(KERN_DEBUG
 				       "%s: wv_complete(): tx error: heart beat.\n",
@@ -779,7 +779,7 @@ if (lp->tx_n_in_use > 0)
 #endif
 			}
 			if (tx_status & AC_SFLD_S5) {
-				lp->stats.tx_aborted_errors++;
+				dev->stats.tx_aborted_errors++;
 #ifdef DEBUG_TX_FAIL
 				printk(KERN_DEBUG
 				       "%s: wv_complete(): tx error: too many collisions.\n",
@@ -1346,20 +1346,6 @@ static void wv_init_info(struct net_devi
  * or wireless extensions
  */
 
-/*------------------------------------------------------------------*/
-/*
- * Get the current Ethernet statistics. This may be called with the
- * card open or closed.
- * Used when the user read /proc/net/dev
- */
-static en_stats *wavelan_get_stats(struct net_device * dev)
-{
-#ifdef DEBUG_IOCTL_TRACE
-	printk(KERN_DEBUG "%s: <>wavelan_get_stats()\n", dev->name);
-#endif
-
-	return &((net_local *)netdev_priv(dev))->stats;
-}
 
 /*------------------------------------------------------------------*/
 /*
@@ -2466,7 +2452,7 @@ wv_packet_read(struct net_device * dev, 
 		       "%s: wv_packet_read(): could not alloc_skb(%d, GFP_ATOMIC).\n",
 		       dev->name, sksize);
 #endif
-		lp->stats.rx_dropped++;
+		dev->stats.rx_dropped++;
 		return;
 	}
 
@@ -2526,8 +2512,8 @@ wv_packet_read(struct net_device * dev, 
 	netif_rx(skb);
 
 	/* Keep statistics up to date */
-	lp->stats.rx_packets++;
-	lp->stats.rx_bytes += sksize;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += sksize;
 
 #ifdef DEBUG_RX_TRACE
 	printk(KERN_DEBUG "%s: <-wv_packet_read()\n", dev->name);
@@ -2608,7 +2594,7 @@ static void wv_receive(struct net_device
 #endif
 		} else {	/* If reception was no successful */
 
-			lp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 
 #ifdef DEBUG_RX_INFO
 			printk(KERN_DEBUG
@@ -2624,7 +2610,7 @@ static void wv_receive(struct net_device
 #endif
 
 			if ((fd.fd_status & FD_STATUS_S7) != 0) {
-				lp->stats.rx_length_errors++;
+				dev->stats.rx_length_errors++;
 #ifdef DEBUG_RX_FAIL
 				printk(KERN_DEBUG
 				       "%s: wv_receive(): frame too short.\n",
@@ -2633,7 +2619,7 @@ static void wv_receive(struct net_device
 			}
 
 			if ((fd.fd_status & FD_STATUS_S8) != 0) {
-				lp->stats.rx_over_errors++;
+				dev->stats.rx_over_errors++;
 #ifdef DEBUG_RX_FAIL
 				printk(KERN_DEBUG
 				       "%s: wv_receive(): rx DMA overrun.\n",
@@ -2642,7 +2628,7 @@ static void wv_receive(struct net_device
 			}
 
 			if ((fd.fd_status & FD_STATUS_S9) != 0) {
-				lp->stats.rx_fifo_errors++;
+				dev->stats.rx_fifo_errors++;
 #ifdef DEBUG_RX_FAIL
 				printk(KERN_DEBUG
 				       "%s: wv_receive(): ran out of resources.\n",
@@ -2651,7 +2637,7 @@ static void wv_receive(struct net_device
 			}
 
 			if ((fd.fd_status & FD_STATUS_S10) != 0) {
-				lp->stats.rx_frame_errors++;
+				dev->stats.rx_frame_errors++;
 #ifdef DEBUG_RX_FAIL
 				printk(KERN_DEBUG
 				       "%s: wv_receive(): alignment error.\n",
@@ -2660,7 +2646,7 @@ static void wv_receive(struct net_device
 			}
 
 			if ((fd.fd_status & FD_STATUS_S11) != 0) {
-				lp->stats.rx_crc_errors++;
+				dev->stats.rx_crc_errors++;
 #ifdef DEBUG_RX_FAIL
 				printk(KERN_DEBUG
 				       "%s: wv_receive(): CRC error.\n",
@@ -2826,7 +2812,7 @@ static int wv_packet_write(struct net_de
 	dev->trans_start = jiffies;
 
 	/* Keep stats up to date. */
-	lp->stats.tx_bytes += length;
+	dev->stats.tx_bytes += length;
 
 	if (lp->tx_first_in_use == I82586NULL)
 		lp->tx_first_in_use = txblock;
@@ -4038,6 +4024,22 @@ static int wavelan_close(struct net_devi
 	return 0;
 }
 
+static const struct net_device_ops wavelan_netdev_ops = {
+	.ndo_open 		= wavelan_open,
+	.ndo_stop 		= wavelan_close,
+	.ndo_start_xmit		= wavelan_packet_xmit,
+	.ndo_set_multicast_list = wavelan_set_multicast_list,
+        .ndo_tx_timeout		= wavelan_watchdog,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef SET_MAC_ADDRESS
+	.ndo_set_mac_address	= wavelan_set_mac_address
+#else
+	.ndo_set_mac_address 	= eth_mac_addr,
+#endif
+};
+
+
 /*------------------------------------------------------------------*/
 /*
  * Probe an I/O address, and if the WaveLAN is there configure the
@@ -4130,17 +4132,8 @@ static int __init wavelan_config(struct 
 	/* Init spinlock */
 	spin_lock_init(&lp->spinlock);
 
-	dev->open = wavelan_open;
-	dev->stop = wavelan_close;
-	dev->hard_start_xmit = wavelan_packet_xmit;
-	dev->get_stats = wavelan_get_stats;
-	dev->set_multicast_list = &wavelan_set_multicast_list;
-        dev->tx_timeout		= &wavelan_watchdog;
-        dev->watchdog_timeo	= WATCHDOG_JIFFIES;
-#ifdef SET_MAC_ADDRESS
-	dev->set_mac_address = &wavelan_set_mac_address;
-#endif				/* SET_MAC_ADDRESS */
-
+	dev->netdev_ops = &wavelan_netdev_ops;
+	dev->watchdog_timeo = WATCHDOG_JIFFIES;
 	dev->wireless_handlers = &wavelan_handler_def;
 	lp->wireless_data.spy_data = &lp->spy_data;
 	dev->wireless_data = &lp->wireless_data;
--- a/drivers/net/wireless/wavelan.p.h	2009-03-21 12:37:00.000000000 -0700
+++ b/drivers/net/wireless/wavelan.p.h	2009-03-26 15:57:19.342599616 -0700
@@ -459,11 +459,9 @@ static const char	*version	= "wavelan.c 
 /****************************** TYPES ******************************/
 
 /* Shortcuts */
-typedef struct net_device_stats	en_stats;
 typedef struct iw_statistics	iw_stats;
 typedef struct iw_quality	iw_qual;
-typedef struct iw_freq		iw_freq;
-typedef struct net_local	net_local;
+typedef struct iw_freq		iw_freq;typedef struct net_local	net_local;
 typedef struct timer_list	timer_list;
 
 /* Basic types */
@@ -475,15 +473,12 @@ typedef u_char		mac_addr[WAVELAN_ADDR_SI
  * For each network interface, Linux keeps data in two structures:  "device"
  * keeps the generic data (same format for everybody) and "net_local" keeps
  * additional specific data.
- * Note that some of this specific data is in fact generic (en_stats, for
- * example).
  */
 struct net_local
 {
   net_local *	next;		/* linked list of the devices */
   struct net_device *	dev;		/* reverse link */
   spinlock_t	spinlock;	/* Serialize access to the hardware (SMP) */
-  en_stats	stats;		/* Ethernet interface statistics */
   int		nresets;	/* number of hardware resets */
   u_char	reconfig_82586;	/* We need to reconfigure the controller. */
   u_char	promiscuous;	/* promiscuous mode */
@@ -601,8 +596,6 @@ static void
 static inline void
 	wv_init_info(struct net_device *);	/* display startup info */
 /* ------------------- IOCTL, STATS & RECONFIG ------------------- */
-static en_stats	*
-	wavelan_get_stats(struct net_device *);	/* Give stats /proc/net/dev */
 static iw_stats *
 	wavelan_get_wireless_stats(struct net_device *);
 static void


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
