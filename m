From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: [PATCH] 3c59x ethtool: provide NIC-specific stats
Date: Wed, 19 Jan 2005 09:31:02 +0100
Message-ID: <20050119083102.GD24947@gareth.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

With this patch get_ethtool_stats() provides the NIC-specific extra stats. 

Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>

--- vanilla-2.6.11-rc1/drivers/net/3c59x.c	Wed Jan 12 11:56:16 2005
+++ linux-2.6.11-rc1/drivers/net/3c59x.c	Tue Jan 18 20:17:26 2005
@@ -752,6 +752,12 @@
 /* Chip features we care about in vp->capabilities, read from the EEPROM. */
 enum ChipCaps { CapBusMaster=0x20, CapPwrMgmt=0x2000 };
 
+struct vortex_extra_stats {      
+        unsigned long tx_deferred;        
+        unsigned long tx_multiple_collisions;     
+        unsigned long rx_bad_ssd; 
+};
+
 struct vortex_private {
 	/* The Rx and Tx rings should be quad-word-aligned. */
 	struct boom_rx_desc* rx_ring;
@@ -763,7 +769,8 @@
 	struct sk_buff* tx_skbuff[TX_RING_SIZE];
 	unsigned int cur_rx, cur_tx;		/* The next free ring entry */
 	unsigned int dirty_rx, dirty_tx;	/* The ring entries to be free()ed. */
-	struct net_device_stats stats;
+	struct net_device_stats stats;		/* Generic stats */
+	struct vortex_extra_stats xstats;	/* NIC-specific extra stats */
 	struct sk_buff *tx_skb;				/* Packet being eaten by bus master ctrl.  */
 	dma_addr_t tx_skb_dma;				/* Allocated DMA address for bus master ctrl DMA.   */
 
@@ -854,18 +861,13 @@
 static struct {
 	const char str[ETH_GSTRING_LEN];
 } ethtool_stats_keys[] = {
-	{ "rx_packets" },
-	{ "tx_packets" },
-	{ "rx_bytes" },
-	{ "tx_bytes" },
-	{ "collisions" },
-	{ "tx_carrier_errors" },
-	{ "tx_heartbeat_errors" },
-	{ "tx_window_errors" },
+	{ "tx_deferred" },
+	{ "tx_multiple_collisions" },
+	{ "rx_bad_ssd" },
 };
 
 /* number of ETHTOOL_GSTATS u64's */
-#define VORTEX_NUM_STATS      8
+#define VORTEX_NUM_STATS     3 
 
 static int vortex_probe1(struct device *gendev, long ioaddr, int irq,
 				   int chip_idx, int card_idx);
@@ -2871,23 +2873,23 @@
 	/* Switch to the stats window, and read everything. */
 	EL3WINDOW(6);
 	vp->stats.tx_carrier_errors		+= inb(ioaddr + 0);
-	vp->stats.tx_heartbeat_errors	+= inb(ioaddr + 1);
-	/* Multiple collisions. */		inb(ioaddr + 2);
+	vp->stats.tx_heartbeat_errors		+= inb(ioaddr + 1);
 	vp->stats.collisions			+= inb(ioaddr + 3);
 	vp->stats.tx_window_errors		+= inb(ioaddr + 4);
 	vp->stats.rx_fifo_errors		+= inb(ioaddr + 5);
 	vp->stats.tx_packets			+= inb(ioaddr + 6);
 	vp->stats.tx_packets			+= (inb(ioaddr + 9)&0x30) << 4;
-	/* Rx packets	*/				inb(ioaddr + 7);   /* Must read to clear */
-	/* Tx deferrals */				inb(ioaddr + 8);
+	/* Rx packets	*/			inb(ioaddr + 7);   /* Must read to clear */
 	/* Don't bother with register 9, an extension of registers 6&7.
 	   If we do use the 6&7 values the atomic update assumption above
 	   is invalid. */
-	vp->stats.rx_bytes += inw(ioaddr + 10);
-	vp->stats.tx_bytes += inw(ioaddr + 12);
-	/* New: On the Vortex we must also clear the BadSSD counter. */
+	vp->stats.rx_bytes 			+= inw(ioaddr + 10);
+	vp->stats.tx_bytes 			+= inw(ioaddr + 12);
+	/* Extra stats for get_ethtool_stats() */
+	vp->xstats.tx_multiple_collisions	+= inb(ioaddr + 2);
+	vp->xstats.tx_deferred			+= inb(ioaddr + 8);
 	EL3WINDOW(4);
-	inb(ioaddr + 12);
+	vp->xstats.rx_bad_ssd			+= inb(ioaddr + 12);
 
 	{
 		u8 up = inb(ioaddr + 13);
@@ -2980,14 +2982,9 @@
 	update_stats(dev->base_addr, dev);
 	spin_unlock_irqrestore(&vp->lock, flags);
 
-	data[0] = vp->stats.rx_packets;
-	data[1] = vp->stats.tx_packets;
-	data[2] = vp->stats.rx_bytes;
-	data[3] = vp->stats.tx_bytes;
-	data[4] = vp->stats.collisions;
-	data[5] = vp->stats.tx_carrier_errors;
-	data[6] = vp->stats.tx_heartbeat_errors;
-	data[7] = vp->stats.tx_window_errors;
+	data[0] = vp->xstats.tx_deferred;
+	data[1] = vp->xstats.tx_multiple_collisions;
+	data[2] = vp->xstats.rx_bad_ssd;
 }
 
 
