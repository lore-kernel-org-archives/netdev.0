From: "David S. Miller" <davem@davemloft.net>
Subject: [TG3]: Add hw coalescing infrastructure.
Date: Wed, 11 May 2005 14:15:30 -0700 (PDT)
Message-ID: <20050511.141530.57445142.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok, now that we have the tagged status stuff sorted I began
to work on putting the hw mitigation bits back into the
driver.  The discussion on the DMA rw-ctrl settings is still
ongoing, but I will get back to it shortly.

This is the first step, we cache the settings in the tg3
struct and put those values into the chip via tg3_set_coalesce().

ETHTOOL_GCOALESCE is supported, setting is not.

The idea is that if we add dynamnic mitigation or ETHTOOL_SCOALESCE,
it will simply invoke this routine to program the hardware.

It seems that we should also be avoiding the HOSTCC_{R,T}XCOAL_MAXF_INT
registers when TG3_FLG2_5705_PLUS.  I didn't make that change yet, just
preserving what we were doing previously.

Another thing which occurred to me is that these settings are line
rate dependant.  For example, the 20 usec value is for gigabit.
So we may wish to adjust the values we use based upon the negotiated
line speed.   But that's a future refinement that can wait.

I think with the removal of that I/O readback done by the tagged
status changes, and this coalescing stuff below, the SGI NUMA
performance should be significantly higher.

Comments?

Signed-off-by: David S. Miller <davem@davemloft.net>

--- 1/drivers/net/tg3.c.~1~	2005-05-11 11:46:11.000000000 -0700
+++ 2/drivers/net/tg3.c	2005-05-11 13:47:17.000000000 -0700
@@ -2507,7 +2507,7 @@ static int tg3_setup_phy(struct tg3 *tp,
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
 		if (netif_carrier_ok(tp->dev)) {
 			tw32(HOSTCC_STAT_COAL_TICKS,
-			     DEFAULT_STAT_COAL_TICKS);
+			     tp->coal.stats_block_coalesce_usecs);
 		} else {
 			tw32(HOSTCC_STAT_COAL_TICKS, 0);
 		}
@@ -5094,6 +5094,22 @@ static void tg3_set_bdinfo(struct tg3 *t
 }
 
 static void __tg3_set_rx_mode(struct net_device *);
+static void tg3_set_coalesce(struct tg3 *tp, struct ethtool_coalesce *ec)
+{
+	tw32(HOSTCC_RXCOL_TICKS, ec->rx_coalesce_usecs);
+	tw32(HOSTCC_TXCOL_TICKS, ec->tx_coalesce_usecs);
+	tw32(HOSTCC_RXMAX_FRAMES, ec->rx_max_coalesced_frames);
+	tw32(HOSTCC_TXMAX_FRAMES, ec->tx_max_coalesced_frames);
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
+		tw32(HOSTCC_RXCOAL_TICK_INT, ec->rx_coalesce_usecs_irq);
+		tw32(HOSTCC_TXCOAL_TICK_INT, ec->tx_coalesce_usecs_irq);
+	}
+	tw32(HOSTCC_RXCOAL_MAXF_INT, ec->rx_max_coalesced_frames_irq);
+	tw32(HOSTCC_TXCOAL_MAXF_INT, ec->tx_max_coalesced_frames_irq);
+	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
+		tw32(HOSTCC_STAT_COAL_TICKS,
+		     ec->stats_block_coalesce_usecs);
+}
 
 /* tp->lock is held. */
 static int tg3_reset_hw(struct tg3 *tp)
@@ -5416,16 +5432,7 @@ static int tg3_reset_hw(struct tg3 *tp)
 		udelay(10);
 	}
 
-	tw32(HOSTCC_RXCOL_TICKS, 0);
-	tw32(HOSTCC_TXCOL_TICKS, LOW_TXCOL_TICKS);
-	tw32(HOSTCC_RXMAX_FRAMES, 1);
-	tw32(HOSTCC_TXMAX_FRAMES, LOW_RXMAX_FRAMES);
-	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS)) {
-		tw32(HOSTCC_RXCOAL_TICK_INT, 0);
-		tw32(HOSTCC_TXCOAL_TICK_INT, 0);
-	}
-	tw32(HOSTCC_RXCOAL_MAXF_INT, 1);
-	tw32(HOSTCC_TXCOAL_MAXF_INT, 0);
+	tg3_set_coalesce(tp, &tp->coal);
 
 	/* set status block DMA address */
 	tw32(HOSTCC_STATUS_BLK_HOST_ADDR + TG3_64BIT_REG_HIGH,
@@ -5438,8 +5445,6 @@ static int tg3_reset_hw(struct tg3 *tp)
 		 * the tg3_periodic_fetch_stats call there, and
 		 * tg3_get_stats to see how this works for 5705/5750 chips.
 		 */
-		tw32(HOSTCC_STAT_COAL_TICKS,
-		     DEFAULT_STAT_COAL_TICKS);
 		tw32(HOSTCC_STATS_BLK_HOST_ADDR + TG3_64BIT_REG_HIGH,
 		     ((u64) tp->stats_mapping >> 32));
 		tw32(HOSTCC_STATS_BLK_HOST_ADDR + TG3_64BIT_REG_LOW,
@@ -7284,6 +7289,14 @@ static void tg3_vlan_rx_kill_vid(struct 
 }
 #endif
 
+static int tg3_get_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
+{
+	struct tg3 *tp = netdev_priv(dev);
+
+	memcpy(ec, &tp->coal, sizeof(*ec));
+	return 0;
+}
+
 static struct ethtool_ops tg3_ethtool_ops = {
 	.get_settings		= tg3_get_settings,
 	.set_settings		= tg3_set_settings,
@@ -7316,6 +7329,7 @@ static struct ethtool_ops tg3_ethtool_op
 	.get_strings		= tg3_get_strings,
 	.get_stats_count	= tg3_get_stats_count,
 	.get_ethtool_stats	= tg3_get_ethtool_stats,
+	.get_coalesce		= tg3_get_coalesce,
 };
 
 static void __devinit tg3_get_eeprom_size(struct tg3 *tp)
@@ -9096,6 +9110,31 @@ static struct pci_dev * __devinit tg3_fi
 	return peer;
 }
 
+static void __devinit tg3_init_coal(struct tg3 *tp)
+{
+	struct ethtool_coalesce *ec = &tp->coal;
+
+	memset(ec, 0, sizeof(*ec));
+	ec->cmd = ETHTOOL_GCOALESCE;
+	ec->rx_coalesce_usecs = LOW_RXCOL_TICKS;
+	ec->tx_coalesce_usecs = LOW_TXCOL_TICKS;
+	ec->rx_max_coalesced_frames = LOW_RXMAX_FRAMES;
+	ec->tx_max_coalesced_frames = LOW_TXMAX_FRAMES;
+	ec->rx_coalesce_usecs_irq = DEFAULT_RXCOAL_TICK_INT;
+	ec->tx_coalesce_usecs_irq = DEFAULT_TXCOAL_TICK_INT;
+	ec->rx_max_coalesced_frames_irq = DEFAULT_RXCOAL_MAXF_INT;
+	ec->tx_max_coalesced_frames_irq = DEFAULT_TXCOAL_MAXF_INT;
+	ec->stats_block_coalesce_usecs = DEFAULT_STAT_COAL_TICKS;
+
+	if (tp->coalesce_mode & (HOSTCC_MODE_CLRTICK_RXBD |
+				 HOSTCC_MODE_CLRTICK_TXBD)) {
+		ec->rx_coalesce_usecs = LOW_RXCOL_TICKS_CLRTCKS;
+		ec->rx_coalesce_usecs_irq = DEFAULT_RXCOAL_TICK_INT_CLRTCKS;
+		ec->tx_coalesce_usecs = LOW_TXCOL_TICKS_CLRTCKS;
+		ec->tx_coalesce_usecs_irq = DEFAULT_TXCOAL_TICK_INT_CLRTCKS;
+	}
+}
+
 static int __devinit tg3_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
@@ -9341,6 +9380,8 @@ static int __devinit tg3_init_one(struct
 	/* flow control autonegotiation is default behavior */
 	tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
 
+	tg3_init_coal(tp);
+
 	err = register_netdev(dev);
 	if (err) {
 		printk(KERN_ERR PFX "Cannot register net device, "
--- 1/drivers/net/tg3.h.~1~	2005-05-11 11:46:11.000000000 -0700
+++ 2/drivers/net/tg3.h	2005-05-11 13:48:14.000000000 -0700
@@ -876,10 +876,12 @@
 #define  HOSTCC_STATUS_ERROR_ATTN	 0x00000004
 #define HOSTCC_RXCOL_TICKS		0x00003c08
 #define  LOW_RXCOL_TICKS		 0x00000032
+#define  LOW_RXCOL_TICKS_CLRTCKS	 0x00000014
 #define  DEFAULT_RXCOL_TICKS		 0x00000048
 #define  HIGH_RXCOL_TICKS		 0x00000096
 #define HOSTCC_TXCOL_TICKS		0x00003c0c
 #define  LOW_TXCOL_TICKS		 0x00000096
+#define  LOW_TXCOL_TICKS_CLRTCKS	 0x00000048
 #define  DEFAULT_TXCOL_TICKS		 0x0000012c
 #define  HIGH_TXCOL_TICKS		 0x00000145
 #define HOSTCC_RXMAX_FRAMES		0x00003c10
@@ -892,8 +894,10 @@
 #define  HIGH_TXMAX_FRAMES		 0x00000052
 #define HOSTCC_RXCOAL_TICK_INT		0x00003c18
 #define  DEFAULT_RXCOAL_TICK_INT	 0x00000019
+#define  DEFAULT_RXCOAL_TICK_INT_CLRTCKS 0x00000014
 #define HOSTCC_TXCOAL_TICK_INT		0x00003c1c
 #define  DEFAULT_TXCOAL_TICK_INT	 0x00000019
+#define  DEFAULT_TXCOAL_TICK_INT_CLRTCKS 0x00000014
 #define HOSTCC_RXCOAL_MAXF_INT		0x00003c20
 #define  DEFAULT_RXCOAL_MAXF_INT	 0x00000005
 #define HOSTCC_TXCOAL_MAXF_INT		0x00003c24
@@ -2227,7 +2231,7 @@ struct tg3 {
 
 #define SST_25VF0X0_PAGE_SIZE		4098
 
-
+	struct ethtool_coalesce		coal;
 };
 
 #endif /* !(_T3_H) */
