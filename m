From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 57/77] wavelan: convert to internal net_device_stats
Date: Fri, 20 Mar 2009 22:36:24 -0700
Message-ID: <20090321053716.884788530@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=wavelan-stats.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>


--- a/drivers/net/wireless/wavelan_cs.c	2009-03-20 16:59:43.049838921 -0700
+++ b/drivers/net/wireless/wavelan_cs.c	2009-03-20 17:03:26.637026504 -0700
@@ -1352,21 +1352,6 @@ wv_init_info(struct net_device *	dev)
  * or wireless extensions
  */
 
-/*------------------------------------------------------------------*/
-/*
- * Get the current ethernet statistics. This may be called with the
- * card open or closed.
- * Used when the user read /proc/net/dev
- */
-static en_stats	*
-wavelan_get_stats(struct net_device *	dev)
-{
-#ifdef DEBUG_IOCTL_TRACE
-  printk(KERN_DEBUG "%s: <>wavelan_get_stats()\n", dev->name);
-#endif
-
-  return(&((net_local *)netdev_priv(dev))->stats);
-}
 
 /*------------------------------------------------------------------*/
 /*
@@ -2817,7 +2802,7 @@ wv_packet_read(struct net_device *		dev,
       printk(KERN_INFO "%s: wv_packet_read(): could not alloc_skb(%d, GFP_ATOMIC)\n",
 	     dev->name, sksize);
 #endif
-      lp->stats.rx_dropped++;
+      dev->stats.rx_dropped++;
       /*
        * Not only do we want to return here, but we also need to drop the
        * packet on the floor to clear the interrupt.
@@ -2877,8 +2862,8 @@ wv_packet_read(struct net_device *		dev,
   netif_rx(skb);
 
   /* Keep stats up to date */
-  lp->stats.rx_packets++;
-  lp->stats.rx_bytes += sksize;
+  dev->stats.rx_packets++;
+  dev->stats.rx_bytes += sksize;
 
 #ifdef DEBUG_RX_TRACE
   printk(KERN_DEBUG "%s: <-wv_packet_read()\n", dev->name);
@@ -2980,13 +2965,13 @@ wv_packet_rcv(struct net_device *	dev)
       /* Check status */
       if((status & RX_RCV_OK) != RX_RCV_OK)
 	{
-	  lp->stats.rx_errors++;
+	  dev->stats.rx_errors++;
 	  if(status & RX_NO_SFD)
-	    lp->stats.rx_frame_errors++;
+	    dev->stats.rx_frame_errors++;
 	  if(status & RX_CRC_ERR)
-	    lp->stats.rx_crc_errors++;
+	    dev->stats.rx_crc_errors++;
 	  if(status & RX_OVRRUN)
-	    lp->stats.rx_over_errors++;
+	    dev->stats.rx_over_errors++;
 
 #ifdef DEBUG_RX_FAIL
 	  printk(KERN_DEBUG "%s: wv_packet_rcv(): packet not received ok, status = 0x%x\n",
@@ -3073,7 +3058,7 @@ wv_packet_write(struct net_device *	dev,
   dev->trans_start = jiffies;
 
   /* Keep stats up to date */
-  lp->stats.tx_bytes += length;
+  dev->stats.tx_bytes += length;
 
   spin_unlock_irqrestore(&lp->spinlock, flags);
 
@@ -4106,7 +4091,7 @@ wavelan_interrupt(int		irq,
 	      printk(KERN_INFO "%s: wv_interrupt(): receive buffer overflow\n",
 		     dev->name);
 #endif
-	      lp->stats.rx_over_errors++;
+	      dev->stats.rx_over_errors++;
 	      lp->overrunning = 1;
       	    }
 
@@ -4155,7 +4140,7 @@ wavelan_interrupt(int		irq,
 	  /* Check for possible errors */
 	  if((tx_status & TX_OK) != TX_OK)
 	    {
-	      lp->stats.tx_errors++;
+	      dev->stats.tx_errors++;
 
 	      if(tx_status & TX_FRTL)
 		{
@@ -4170,14 +4155,14 @@ wavelan_interrupt(int		irq,
 		  printk(KERN_DEBUG "%s: wv_interrupt(): DMA underrun\n",
 			 dev->name);
 #endif
-		  lp->stats.tx_aborted_errors++;
+		  dev->stats.tx_aborted_errors++;
 		}
 	      if(tx_status & TX_LOST_CTS)
 		{
 #ifdef DEBUG_TX_FAIL
 		  printk(KERN_DEBUG "%s: wv_interrupt(): no CTS\n", dev->name);
 #endif
-		  lp->stats.tx_carrier_errors++;
+		  dev->stats.tx_carrier_errors++;
 		}
 	      if(tx_status & TX_LOST_CRS)
 		{
@@ -4185,14 +4170,14 @@ wavelan_interrupt(int		irq,
 		  printk(KERN_DEBUG "%s: wv_interrupt(): no carrier\n",
 			 dev->name);
 #endif
-		  lp->stats.tx_carrier_errors++;
+		  dev->stats.tx_carrier_errors++;
 		}
 	      if(tx_status & TX_HRT_BEAT)
 		{
 #ifdef DEBUG_TX_FAIL
 		  printk(KERN_DEBUG "%s: wv_interrupt(): heart beat\n", dev->name);
 #endif
-		  lp->stats.tx_heartbeat_errors++;
+		  dev->stats.tx_heartbeat_errors++;
 		}
 	      if(tx_status & TX_DEFER)
 		{
@@ -4216,14 +4201,14 @@ wavelan_interrupt(int		irq,
 #endif
 		      if(!(tx_status & TX_NCOL_MASK))
 			{
-			  lp->stats.collisions += 0x10;
+			  dev->stats.collisions += 0x10;
 			}
 		    }
 		}
 	    }	/* if(!(tx_status & TX_OK)) */
 
-	  lp->stats.collisions += (tx_status & TX_NCOL_MASK);
-	  lp->stats.tx_packets++;
+	  dev->stats.collisions += (tx_status & TX_NCOL_MASK);
+	  dev->stats.tx_packets++;
 
 	  netif_wake_queue(dev);
 	  outb(CR0_INT_ACK | OP0_NOP, LCCR(base));	/* Acknowledge the interrupt */
@@ -4514,7 +4499,6 @@ wavelan_probe(struct pcmcia_device *p_de
   dev->open = &wavelan_open;
   dev->stop = &wavelan_close;
   dev->hard_start_xmit = &wavelan_packet_xmit;
-  dev->get_stats = &wavelan_get_stats;
   dev->set_multicast_list = &wavelan_set_multicast_list;
 #ifdef SET_MAC_ADDRESS
   dev->set_mac_address = &wavelan_set_mac_address;
--- a/drivers/net/wireless/wavelan_cs.p.h	2009-03-20 17:02:30.295089835 -0700
+++ b/drivers/net/wireless/wavelan_cs.p.h	2009-03-20 17:03:17.387027572 -0700
@@ -576,7 +576,6 @@ struct wavepoint_table
 /****************************** TYPES ******************************/
 
 /* Shortcuts */
-typedef struct net_device_stats	en_stats;
 typedef struct iw_statistics	iw_stats;
 typedef struct iw_quality	iw_qual;
 typedef struct iw_freq		iw_freq;
@@ -592,8 +591,6 @@ typedef u_char		mac_addr[WAVELAN_ADDR_SI
  * For each network interface, Linux keep data in two structure. "device"
  * keep the generic data (same format for everybody) and "net_local" keep
  * the additional specific data.
- * Note that some of this specific data is in fact generic (en_stats, for
- * example).
  */
 struct net_local
 {
@@ -601,7 +598,6 @@ struct net_local
   struct net_device *	dev;		/* Reverse link... */
   spinlock_t	spinlock;	/* Serialize access to the hardware (SMP) */
   struct pcmcia_device *	link;		/* pcmcia structure */
-  en_stats	stats;		/* Ethernet interface statistics */
   int		nresets;	/* Number of hw resets */
   u_char	configured;	/* If it is configured */
   u_char	reconfig_82593;	/* Need to reconfigure the controller */
@@ -694,8 +690,6 @@ static void
 static void
 	wv_init_info(struct net_device *);	/* display startup info */
 /* ------------------- IOCTL, STATS & RECONFIG ------------------- */
-static en_stats	*
-	wavelan_get_stats(struct net_device *);	/* Give stats /proc/net/dev */
 static iw_stats *
 	wavelan_get_wireless_stats(struct net_device *);
 /* ----------------------- PACKET RECEPTION ----------------------- */

-- 

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
