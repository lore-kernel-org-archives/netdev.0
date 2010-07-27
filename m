From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net/bfin_mac.c: Use pr_fmt, netdev_<level>
Date: Tue, 27 Jul 2010 12:22:11 -0700
Message-ID: <1280258531.24054.10.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Michael Hennerich <michael.hennerich@analog.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2111 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308Ab0G0TWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 15:22:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And some assorted neatening for checkpatch:

	80 column reformatting (mostly comments)
	argument alignment
	couple of spelling/grammar typos corrected

Added bfin_alloc_skb to centralize allocation/dcache invalidation
Added get_mac_addr for symmetry

$ ./scripts/checkpatch.pl -f drivers/net/bfin_mac.c | grep "^total:"
total: 2 errors, 25 warnings, 1723 lines checked
$ ./scripts/checkpatch.pl -f drivers/net/bfin_mac.c | grep "^total:"
total: 0 errors, 0 warnings, 1743 lines checked

Uncompiled, untested.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bfin_mac.c |  284 ++++++++++++++++++++++++++----------------------
 1 files changed, 152 insertions(+), 132 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 012613f..46a4576 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -8,6 +8,8 @@
  * Licensed under the GPL-2 or later.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -81,6 +83,24 @@ static u16 pin_req[] = P_RMII0;
 static u16 pin_req[] = P_MII0;
 #endif
 
+static struct sk_buff *bfin_alloc_skb(void)
+{
+	/* allocate a new skb */
+	struct sk_buff *new_skb = dev_alloc_skb(PKT_BUF_SIZE + NET_IP_ALIGN);
+
+	if (!new_skb)
+		return NULL;
+
+	skb_reserve(new_skb, NET_IP_ALIGN);
+	/* Invalidate the data cache of skb->data range when it is write back
+	 * cache.  It will prevent overwriting the new data from DMA
+	 */
+	blackfin_dcache_invalidate_range((unsigned long)new_skb->head,
+					 (unsigned long)new_skb->end);
+
+	return new_skb;
+}
+
 static void desc_list_free(void)
 {
 	struct net_dma_desc_rx *r;
@@ -132,14 +152,14 @@ static int desc_list_init(void)
 #endif
 
 	tx_desc = bfin_mac_alloc(&dma_handle,
-				sizeof(struct net_dma_desc_tx) *
-				CONFIG_BFIN_TX_DESC_NUM);
+				 sizeof(struct net_dma_desc_tx) *
+				 CONFIG_BFIN_TX_DESC_NUM);
 	if (tx_desc == NULL)
 		goto init_error;
 
 	rx_desc = bfin_mac_alloc(&dma_handle,
-				sizeof(struct net_dma_desc_rx) *
-				CONFIG_BFIN_RX_DESC_NUM);
+				 sizeof(struct net_dma_desc_rx) *
+				 CONFIG_BFIN_RX_DESC_NUM);
 	if (rx_desc == NULL)
 		goto init_error;
 
@@ -192,19 +212,11 @@ static int desc_list_init(void)
 		struct dma_descriptor *a = &(r->desc_a);
 		struct dma_descriptor *b = &(r->desc_b);
 
-		/* allocate a new skb for next time receive */
-		new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
+		new_skb = bfin_alloc_skb();
 		if (!new_skb) {
-			printk(KERN_NOTICE DRV_NAME
-			       ": init: low on mem - packet dropped\n");
+			pr_notice("init: low on mem - packet dropped\n");
 			goto init_error;
 		}
-		skb_reserve(new_skb, NET_IP_ALIGN);
-		/* Invidate the data cache of skb->data range when it is write back
-		 * cache. It will prevent overwritting the new data from DMA
-		 */
-		blackfin_dcache_invalidate_range((unsigned long)new_skb->head,
-					 (unsigned long)new_skb->end);
 		r->skb = new_skb;
 
 		/*
@@ -229,8 +241,8 @@ static int desc_list_init(void)
 		 * 6 half words is desc size
 		 * large desc flow
 		 */
-		b->config = DMAEN | WNR | WDSIZE_32 | DI_EN |
-				NDSIZE_6 | DMAFLOW_LARGE;
+		b->config = (DMAEN | WNR | WDSIZE_32 | DI_EN |
+			     NDSIZE_6 | DMAFLOW_LARGE);
 		b->start_addr = (unsigned long)(&(r->status));
 		b->x_count = 0;
 
@@ -246,7 +258,7 @@ static int desc_list_init(void)
 
 init_error:
 	desc_list_free();
-	printk(KERN_ERR DRV_NAME ": kmalloc failed\n");
+	pr_err("kmalloc failed\n");
 	return -ENOMEM;
 }
 
@@ -263,12 +275,11 @@ static int bfin_mdio_poll(void)
 
 	/* poll the STABUSY bit */
 	while ((bfin_read_EMAC_STAADD()) & STABUSY) {
-		udelay(1);
 		if (timeout_cnt-- < 0) {
-			printk(KERN_ERR DRV_NAME
-			": wait MDC/MDIO transaction to complete timeout\n");
+			pr_err("wait MDC/MDIO transaction to complete timeout\n");
 			return -ETIMEDOUT;
 		}
+		udelay(1);
 	}
 
 	return 0;
@@ -284,15 +295,15 @@ static int bfin_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 		return ret;
 
 	/* read mode */
-	bfin_write_EMAC_STAADD(SET_PHYAD((u16) phy_addr) |
+	bfin_write_EMAC_STAADD((SET_PHYAD((u16) phy_addr) |
 				SET_REGAD((u16) regnum) |
-				STABUSY);
+				STABUSY));
 
 	ret = bfin_mdio_poll();
 	if (ret)
 		return ret;
 
-	return (int) bfin_read_EMAC_STADAT();
+	return (int)bfin_read_EMAC_STADAT();
 }
 
 /* Write an off-chip register in a PHY through the MDC/MDIO port */
@@ -308,10 +319,10 @@ static int bfin_mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
 	bfin_write_EMAC_STADAT((u32) value);
 
 	/* write mode */
-	bfin_write_EMAC_STAADD(SET_PHYAD((u16) phy_addr) |
+	bfin_write_EMAC_STAADD((SET_PHYAD((u16) phy_addr) |
 				SET_REGAD((u16) regnum) |
 				STAOP |
-				STABUSY);
+				STABUSY));
 
 	return bfin_mdio_poll();
 }
@@ -356,9 +367,9 @@ static void bfin_mac_adjust_link(struct net_device *dev)
 				opmode &= ~(RMII_10);
 				break;
 			default:
-				printk(KERN_WARNING
-					"%s: Ack!  Speed (%d) is not 10/100!\n",
-					DRV_NAME, phydev->speed);
+				netdev_warn(dev,
+					    "Ack!  Speed (%d) is not 10/100!\n",
+					    phydev->speed);
 				break;
 			}
 			bfin_write_EMAC_OPMODE(opmode);
@@ -382,7 +393,7 @@ static void bfin_mac_adjust_link(struct net_device *dev)
 	if (new_state) {
 		u32 opmode = bfin_read_EMAC_OPMODE();
 		phy_print_status(phydev);
-		pr_debug("EMAC_OPMODE = 0x%08x\n", opmode);
+		netdev_dbg(dev, "EMAC_OPMODE = 0x%08x\n", opmode);
 	}
 
 	spin_unlock_irqrestore(&lp->lock, flags);
@@ -421,35 +432,35 @@ static int mii_probe(struct net_device *dev)
 		break; /* found it */
 	}
 
-	/* now we are supposed to have a proper phydev, to attach to... */
+	/* now we are supposed to have a proper phydev to attach to... */
 	if (!phydev) {
-		printk(KERN_INFO "%s: Don't found any phy device at all\n",
-			dev->name);
+		netdev_info(dev, "No PHY device found\n");
 		return -ENODEV;
 	}
 
 #if defined(CONFIG_BFIN_MAC_RMII)
 	phydev = phy_connect(dev, dev_name(&phydev->dev), &bfin_mac_adjust_link,
-			0, PHY_INTERFACE_MODE_RMII);
+			     0, PHY_INTERFACE_MODE_RMII);
 #else
 	phydev = phy_connect(dev, dev_name(&phydev->dev), &bfin_mac_adjust_link,
-			0, PHY_INTERFACE_MODE_MII);
+			     0, PHY_INTERFACE_MODE_MII);
 #endif
 
 	if (IS_ERR(phydev)) {
-		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
+		netdev_err(dev, "Could not attach to PHY\n");
 		return PTR_ERR(phydev);
 	}
 
 	/* mask with MAC supported features */
-	phydev->supported &= (SUPPORTED_10baseT_Half
-			      | SUPPORTED_10baseT_Full
-			      | SUPPORTED_100baseT_Half
-			      | SUPPORTED_100baseT_Full
-			      | SUPPORTED_Autoneg
-			      | SUPPORTED_Pause | SUPPORTED_Asym_Pause
-			      | SUPPORTED_MII
-			      | SUPPORTED_TP);
+	phydev->supported &= (SUPPORTED_10baseT_Half |
+			      SUPPORTED_10baseT_Full |
+			      SUPPORTED_100baseT_Half |
+			      SUPPORTED_100baseT_Full |
+			      SUPPORTED_Autoneg |
+			      SUPPORTED_Pause |
+			      SUPPORTED_Asym_Pause |
+			      SUPPORTED_MII |
+			      SUPPORTED_TP);
 
 	phydev->advertising = phydev->supported;
 
@@ -458,11 +469,11 @@ static int mii_probe(struct net_device *dev)
 	lp->old_duplex = -1;
 	lp->phydev = phydev;
 
-	printk(KERN_INFO "%s: attached PHY driver [%s] "
-	       "(mii_bus:phy_addr=%s, irq=%d, mdc_clk=%dHz(mdc_div=%d)"
-	       "@sclk=%dMHz)\n",
-	       DRV_NAME, phydev->drv->name, dev_name(&phydev->dev), phydev->irq,
-	       MDC_CLK, mdc_div, sclk/1000000);
+	netdev_info(dev, "attached PHY driver [%s] "
+		    "(mii_bus:phy_addr=%s, irq=%d, mdc_clk=%dHz(mdc_div=%d)"
+		    "@sclk=%dMHz)\n",
+		    phydev->drv->name, dev_name(&phydev->dev), phydev->irq,
+		    MDC_CLK, mdc_div, sclk/1000000);
 
 	return 0;
 }
@@ -514,7 +525,7 @@ static void bfin_mac_ethtool_getdrvinfo(struct net_device *dev,
 }
 
 static void bfin_mac_ethtool_getwol(struct net_device *dev,
-	struct ethtool_wolinfo *wolinfo)
+				    struct ethtool_wolinfo *wolinfo)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 
@@ -523,7 +534,7 @@ static void bfin_mac_ethtool_getwol(struct net_device *dev,
 }
 
 static int bfin_mac_ethtool_setwol(struct net_device *dev,
-	struct ethtool_wolinfo *wolinfo)
+				   struct ethtool_wolinfo *wolinfo)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 	int rc;
@@ -599,10 +610,20 @@ void setup_system_regs(struct net_device *dev)
 	bfin_write_DMA1_Y_MODIFY(0);
 }
 
+/* Grab the MAC address in the MAC */
+static void get_mac_addr(u8 *mac_addr)
+{
+	__le32 addr_hi = cpu_to_le32(bfin_read_EMAC_ADDRLO());
+	__le16 addr_low = cpu_to_le16((u16)bfin_read_EMAC_ADDRHI());
+
+	memcpy(mac_addr, &addr_hi, 4);
+	memcpy(mac_addr + 4, &addr_low, 2);
+}
+
 static void setup_mac_addr(u8 *mac_addr)
 {
-	u32 addr_low = le32_to_cpu(*(__le32 *) & mac_addr[0]);
-	u16 addr_hi = le16_to_cpu(*(__le16 *) & mac_addr[4]);
+	u32 addr_low = le32_to_cpu(*(__le32 *)&mac_addr[0]);
+	u16 addr_hi = le16_to_cpu(*(__le16 *)&mac_addr[4]);
 
 	/* this depends on a little-endian machine */
 	bfin_write_EMAC_ADDRLO(addr_low);
@@ -612,6 +633,7 @@ static void setup_mac_addr(u8 *mac_addr)
 static int bfin_mac_set_mac_address(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
+
 	if (netif_running(dev))
 		return -EBUSY;
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
@@ -623,7 +645,7 @@ static int bfin_mac_set_mac_address(struct net_device *dev, void *p)
 #define bfin_mac_hwtstamp_is_none(cfg) ((cfg) == HWTSTAMP_FILTER_NONE)
 
 static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
-		struct ifreq *ifr, int cmd)
+				   struct ifreq *ifr, int cmd)
 {
 	struct hwtstamp_config config;
 	struct bfin_mac_local *lp = netdev_priv(netdev);
@@ -633,15 +655,15 @@ static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
 	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
 		return -EFAULT;
 
-	pr_debug("%s config flag:0x%x, tx_type:0x%x, rx_filter:0x%x\n",
-			__func__, config.flags, config.tx_type, config.rx_filter);
+	netdev_dbg("%s config flag:0x%x, tx_type:0x%x, rx_filter:0x%x\n",
+		   __func__, config.flags, config.tx_type, config.rx_filter);
 
 	/* reserved for future extensions */
 	if (config.flags)
 		return -EINVAL;
 
 	if ((config.tx_type != HWTSTAMP_TX_OFF) &&
-			(config.tx_type != HWTSTAMP_TX_ON))
+	    (config.tx_type != HWTSTAMP_TX_ON))
 		return -ERANGE;
 
 	ptpctl = bfin_read_EMAC_PTP_CTL();
@@ -658,7 +680,8 @@ static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
 	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
 		/*
-		 * Clear the five comparison mask bits (bits[12:8]) in EMAC_PTP_CTL)
+		 * Clear the five comparison mask bits
+		 * (bits[12:8] in EMAC_PTP_CTL)
 		 * to enable all the field matches.
 		 */
 		ptpctl &= ~0x1F00;
@@ -694,8 +717,8 @@ static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
 		ptpctl &= ~0x1F00;
 		bfin_write_EMAC_PTP_CTL(ptpctl);
 		/*
-		 * Keep the default values of the EMAC_PTP_FOFF register, except set
-		 * the PTPCOF field to 0x2A.
+		 * Keep the default values of the EMAC_PTP_FOFF register,
+		 * except set the PTPCOF field to 0x2A.
 		 */
 		ptpfoff = 0x2A24170C;
 		bfin_write_EMAC_PTP_FOFF(ptpfoff);
@@ -720,20 +743,20 @@ static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
 	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
 		/*
-		 * Clear bits 8 and 12 of the EMAC_PTP_CTL register to enable only the
-		 * EFTM and PTPCM field comparison.
+		 * Clear bits 8 and 12 of the EMAC_PTP_CTL register to enable
+		 * only the EFTM and PTPCM field comparison.
 		 */
 		ptpctl &= ~0x1100;
 		bfin_write_EMAC_PTP_CTL(ptpctl);
 		/*
-		 * Keep the default values of all the fields of the EMAC_PTP_FOFF
-		 * register, except set the PTPCOF field to 0x0E.
+		 * Keep the default values of all the fields of the
+		 * EMAC_PTP_FOFF register, except set the PTPCOF field to 0x0E.
 		 */
 		ptpfoff = 0x0E24170C;
 		bfin_write_EMAC_PTP_FOFF(ptpfoff);
 		/*
-		 * Program bits [15:0] of the EMAC_PTP_FV1 register to 0x88F7, which
-		 * corresponds to PTP messages on the MAC layer.
+		 * Program bits [15:0] of the EMAC_PTP_FV1 register to 0x88F7,
+		 * which corresponds to PTP messages on the MAC layer.
 		 */
 		ptpfv1 = 0x110488F7;
 		bfin_write_EMAC_PTP_FV1(ptpfv1);
@@ -791,13 +814,17 @@ static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
 		-EFAULT : 0;
 }
 
-static void bfin_dump_hwtamp(char *s, ktime_t *hw, ktime_t *ts, struct timecompare *cmp)
+static void bfin_dump_hwtamp(char *s, ktime_t *hw, ktime_t *ts,
+			     struct timecompare *cmp)
 {
 	ktime_t sys = ktime_get_real();
 
 	pr_debug("%s %s hardware:%d,%d transform system:%d,%d system:%d,%d, cmp:%lld, %lld\n",
-			__func__, s, hw->tv.sec, hw->tv.nsec, ts->tv.sec, ts->tv.nsec, sys.tv.sec,
-			sys.tv.nsec, cmp->offset, cmp->skew);
+		 __func__, s,
+		 hw->tv.sec, hw->tv.nsec,
+		 ts->tv.sec, ts->tv.nsec,
+		 sys.tv.sec, sys.tv.nsec,
+		 cmp->offset, cmp->skew);
 }
 
 static void bfin_tx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
@@ -814,16 +841,17 @@ static void bfin_tx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
 		shtx->in_progress = 1;
 
 		/*
-		 * The timestamping is done at the EMAC module's MII/RMII interface
-		 * when the module sees the Start of Frame of an event message packet. This
-		 * interface is the closest possible place to the physical Ethernet transmission
+		 * The timestamping is done at the EMAC module's MII/RMII
+		 * interface when the module sees the Start of Frame of an
+		 * event message packet. This interface is the closest
+		 * possible place to the physical Ethernet transmission
 		 * medium, providing the best timing accuracy.
 		 */
-		while ((!(bfin_read_EMAC_PTP_ISTAT() & TXTL)) && (--timeout_cnt))
+		while ((!(bfin_read_EMAC_PTP_ISTAT() & TXTL)) &&
+		       (--timeout_cnt))
 			udelay(1);
 		if (timeout_cnt == 0)
-			printk(KERN_ERR DRV_NAME
-					": fails to timestamp the TX packet\n");
+			netdev_err(dev, "failed to timestamp the TX packet\n");
 		else {
 			struct skb_shared_hwtstamps shhwtstamps;
 			u64 ns;
@@ -832,15 +860,15 @@ static void bfin_tx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
 			regval = bfin_read_EMAC_PTP_TXSNAPLO();
 			regval |= (u64)bfin_read_EMAC_PTP_TXSNAPHI() << 32;
 			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
-			ns = timecounter_cyc2time(&lp->clock,
-					regval);
+			ns = timecounter_cyc2time(&lp->clock, regval);
 			timecompare_update(&lp->compare, ns);
 			shhwtstamps.hwtstamp = ns_to_ktime(ns);
 			shhwtstamps.syststamp =
 				timecompare_transform(&lp->compare, ns);
 			skb_tstamp_tx(skb, &shhwtstamps);
 
-			bfin_dump_hwtamp("TX", &shhwtstamps.hwtstamp, &shhwtstamps.syststamp, &lp->compare);
+			bfin_dump_hwtamp("TX", &shhwtstamps.hwtstamp,
+					 &shhwtstamps.syststamp, &lp->compare);
 		}
 	}
 }
@@ -869,7 +897,8 @@ static void bfin_rx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
 	shhwtstamps->hwtstamp = ns_to_ktime(ns);
 	shhwtstamps->syststamp = timecompare_transform(&lp->compare, ns);
 
-	bfin_dump_hwtamp("RX", &shhwtstamps->hwtstamp, &shhwtstamps->syststamp, &lp->compare);
+	bfin_dump_hwtamp("RX", &shhwtstamps->hwtstamp,
+			 &shhwtstamps->syststamp, &lp->compare);
 }
 
 /*
@@ -879,8 +908,8 @@ static cycle_t bfin_read_clock(const struct cyclecounter *tc)
 {
 	u64 stamp;
 
-	stamp =  bfin_read_EMAC_PTP_TIMELO();
-	stamp |= (u64)bfin_read_EMAC_PTP_TIMEHI() << 32ULL;
+	stamp = bfin_read_EMAC_PTP_TIMELO();
+	stamp |= ((u64)bfin_read_EMAC_PTP_TIMEHI()) << 32;
 
 	return stamp;
 }
@@ -961,7 +990,7 @@ static void tx_reclaim_skb(struct bfin_mac_local *lp)
 	}
 
 	if (current_tx_ptr->next != tx_list_head &&
-		netif_queue_stopped(lp->ndev))
+	    netif_queue_stopped(lp->ndev))
 		netif_wake_queue(lp->ndev);
 
 	if (tx_list_head != current_tx_ptr) {
@@ -974,7 +1003,7 @@ static void tx_reclaim_skb(struct bfin_mac_local *lp)
 				jiffies + TX_RECLAIM_JIFFIES;
 
 		mod_timer(&lp->tx_reclaim_timer,
-			lp->tx_reclaim_timer.expires);
+			  lp->tx_reclaim_timer.expires);
 	}
 
 	return;
@@ -985,8 +1014,7 @@ static void tx_reclaim_skb_timeout(unsigned long lp)
 	tx_reclaim_skb((struct bfin_mac_local *)lp);
 }
 
-static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
-				struct net_device *dev)
+static int bfin_mac_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 	u16 *data;
@@ -1000,10 +1028,11 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 		data = (u16 *)(skb->data) - 1;
 		*data = (u16)(skb->len);
 		/*
-		 * When transmitting an Ethernet packet, the PTP_TSYNC module requires
-		 * a DMA_Length_Word field associated with the packet. The lower 12 bits
-		 * of this field are the length of the packet payload in bytes and the higher
-		 * 4 bits are the timestamping enable field.
+		 * When transmitting an Ethernet packet, the PTP_TSYNC module
+		 * requires a DMA_Length_Word field associated with the packet.
+		 * The lower 12 bits of this field are the length of the packet
+		 * payload in bytes and the higher 4 bits are the timestamping
+		 * enable field.
 		 */
 		if (shtx->hardware)
 			*data |= 0x1000;
@@ -1011,7 +1040,7 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 		current_tx_ptr->desc_a.start_addr = (u32)data;
 		/* this is important! */
 		blackfin_dcache_flush_range((u32)data,
-				(u32)((u8 *)data + skb->len + 4));
+					    (u32)((u8 *)data + skb->len + 4));
 	} else {
 		*((u16 *)(current_tx_ptr->packet)) = (u16)(skb->len);
 		/* enable timestamping for the sent packet */
@@ -1063,7 +1092,8 @@ out:
 
 #define IP_HEADER_OFF  0
 #define RX_ERROR_MASK (RX_LONG | RX_ALIGN | RX_CRC | RX_LEN | \
-	RX_FRAG | RX_ADDR | RX_DMAO | RX_PHY | RX_LATE | RX_RANGE)
+		       RX_FRAG | RX_ADDR | RX_DMAO | RX_PHY | \
+		       RX_LATE | RX_RANGE)
 
 static void bfin_mac_rx(struct net_device *dev)
 {
@@ -1079,8 +1109,7 @@ static void bfin_mac_rx(struct net_device *dev)
 	 * we which case we simply drop the packet
 	 */
 	if (current_rx_ptr->status.status_word & RX_ERROR_MASK) {
-		printk(KERN_NOTICE DRV_NAME
-		       ": rx: receive error - packet dropped\n");
+		netdev_notice(dev, "rx: receive error - packet dropped\n");
 		dev->stats.rx_dropped++;
 		goto out;
 	}
@@ -1088,20 +1117,12 @@ static void bfin_mac_rx(struct net_device *dev)
 	/* allocate a new skb for next time receive */
 	skb = current_rx_ptr->skb;
 
-	new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
+	new_skb = bfin_alloc_skb();
 	if (!new_skb) {
-		printk(KERN_NOTICE DRV_NAME
-		       ": rx: low on mem - packet dropped\n");
+		netdev_notice(dev, "rx: low on mem - packet dropped\n");
 		dev->stats.rx_dropped++;
 		goto out;
 	}
-	/* reserve 2 bytes for RXDWA padding */
-	skb_reserve(new_skb, NET_IP_ALIGN);
-	/* Invidate the data cache of skb->data range when it is write back
-	 * cache. It will prevent overwritting the new data from DMA
-	 */
-	blackfin_dcache_invalidate_range((unsigned long)new_skb->head,
-					 (unsigned long)new_skb->end);
 
 	current_rx_ptr->skb = new_skb;
 	current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
@@ -1116,25 +1137,28 @@ static void bfin_mac_rx(struct net_device *dev)
 	bfin_rx_hwtstamp(dev, skb);
 
 #if defined(BFIN_MAC_CSUM_OFFLOAD)
-	/* Checksum offloading only works for IPv4 packets with the standard IP header
-	 * length of 20 bytes, because the blackfin MAC checksum calculation is
-	 * based on that assumption. We must NOT use the calculated checksum if our
-	 * IP version or header break that assumption.
+	/* Checksum offloading only works for IPv4 packets with the standard
+	 * IP header length of 20 bytes, because the blackfin MAC checksum
+	 * calculation is based on that assumption. We must NOT use the
+	 * calculated checksum if our IP version or header break that
+	 * assumption.
 	 */
 	if (skb->data[IP_HEADER_OFF] == 0x45) {
 		skb->csum = current_rx_ptr->status.ip_payload_csum;
 		/*
-		 * Deduce Ethernet FCS from hardware generated IP payload checksum.
-		 * IP checksum is based on 16-bit one's complement algorithm.
-		 * To deduce a value from checksum is equal to add its inversion.
-		 * If the IP payload len is odd, the inversed FCS should also
-		 * begin from odd address and leave first byte zero.
+		 * Deduce Ethernet FCS from hardware generated IP payload
+		 * checksum.  IP checksum is based on 16-bit one's complement
+		 * algorithm.  To deduce a value from checksum is equal to
+		 * add its inversion.  If the IP payload len is odd, the
+		 * inversed FCS should also begin from odd address and leave
+		 * first byte zero.
 		 */
 		if (skb->len % 2) {
 			fcs[0] = 0;
 			for (i = 0; i < ETH_FCS_LEN; i++)
 				fcs[i + 1] = ~skb->data[skb->len + i];
-			skb->csum = csum_partial(fcs, ETH_FCS_LEN + 1, skb->csum);
+			skb->csum = csum_partial(fcs, ETH_FCS_LEN + 1,
+						 skb->csum);
 		} else {
 			for (i = 0; i < ETH_FCS_LEN; i++)
 				fcs[i] = ~skb->data[skb->len + i];
@@ -1209,7 +1233,7 @@ static int bfin_mac_enable(void)
 	int ret;
 	u32 opmode;
 
-	pr_debug("%s: %s\n", DRV_NAME, __func__);
+	pr_debug("%s\n", __func__);
 
 	/* Set RX DMA */
 	bfin_write_DMA1_NEXT_DESC_PTR(&(rx_list_head->desc_a));
@@ -1251,7 +1275,7 @@ static void bfin_mac_timeout(struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 
-	pr_debug("%s: %s\n", dev->name, __func__);
+	netdev_dbg(dev, "%s\n", __func__);
 
 	bfin_mac_disable();
 
@@ -1318,7 +1342,7 @@ static void bfin_mac_set_multicast_list(struct net_device *dev)
 	u32 sysctl;
 
 	if (dev->flags & IFF_PROMISC) {
-		printk(KERN_INFO "%s: set to promisc mode\n", dev->name);
+		netdev_info(dev, "set to promisc mode\n");
 		sysctl = bfin_read_EMAC_OPMODE();
 		sysctl |= PR;
 		bfin_write_EMAC_OPMODE(sysctl);
@@ -1372,7 +1396,7 @@ static int bfin_mac_open(struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 	int ret;
-	pr_debug("%s: %s\n", dev->name, __func__);
+	netdev_dbg(dev, "%s\n", __func__);
 
 	/*
 	 * Check that the address is valid.  If its not, refuse
@@ -1380,7 +1404,7 @@ static int bfin_mac_open(struct net_device *dev)
 	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
 	 */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		printk(KERN_WARNING DRV_NAME ": no valid ethernet hw addr\n");
+		netdev_warn(dev, "no valid ethernet hw addr\n");
 		return -EINVAL;
 	}
 
@@ -1398,7 +1422,7 @@ static int bfin_mac_open(struct net_device *dev)
 	ret = bfin_mac_enable();
 	if (ret)
 		return ret;
-	pr_debug("hardware init finished\n");
+	netdev_dbg(dev, "hardware init finished\n");
 
 	netif_start_queue(dev);
 	netif_carrier_on(dev);
@@ -1414,7 +1438,7 @@ static int bfin_mac_open(struct net_device *dev)
 static int bfin_mac_close(struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
-	pr_debug("%s: %s\n", dev->name, __func__);
+	netdev_dbg(dev, "%s\n", __func__);
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
@@ -1464,9 +1488,7 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	lp = netdev_priv(ndev);
 	lp->ndev = ndev;
 
-	/* Grab the MAC address in the MAC */
-	*(__le32 *) (&(ndev->dev_addr[0])) = cpu_to_le32(bfin_read_EMAC_ADDRLO());
-	*(__le16 *) (&(ndev->dev_addr[4])) = cpu_to_le16((u16) bfin_read_EMAC_ADDRHI());
+	get_mac_addr(ndev->dev_addr);
 
 	/* probe mac */
 	/*todo: how to proble? which is revision_register */
@@ -1526,8 +1548,8 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 
 	/* now, enable interrupts */
 	/* register irq handler */
-	rc = request_irq(IRQ_MAC_RX, bfin_mac_interrupt,
-			IRQF_DISABLED, "EMAC_RX", ndev);
+	rc = request_irq(IRQ_MAC_RX, bfin_mac_interrupt, IRQF_DISABLED,
+			 "EMAC_RX", ndev);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot request Blackfin MAC RX IRQ!\n");
 		rc = -EBUSY;
@@ -1647,7 +1669,7 @@ static int __devinit bfin_mii_bus_probe(struct platform_device *pdev)
 	miibus->parent = &pdev->dev;
 	miibus->name = "bfin_mii_bus";
 	snprintf(miibus->id, MII_BUS_ID_SIZE, "0");
-	miibus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	miibus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
 	if (miibus->irq == NULL)
 		goto out_err_alloc;
 	for (i = 0; i < PHY_MAX_ADDR; ++i)
@@ -1674,6 +1696,7 @@ out_err_alloc:
 static int __devexit bfin_mii_bus_remove(struct platform_device *pdev)
 {
 	struct mii_bus *miibus = platform_get_drvdata(pdev);
+
 	platform_set_drvdata(pdev, NULL);
 	mdiobus_unregister(miibus);
 	kfree(miibus->irq);
@@ -1698,17 +1721,15 @@ static struct platform_driver bfin_mac_driver = {
 	.suspend = bfin_mac_suspend,
 	.driver = {
 		.name = DRV_NAME,
-		.owner	= THIS_MODULE,
+		.owner = THIS_MODULE,
 	},
 };
 
 static int __init bfin_mac_init(void)
 {
-	int ret;
-	ret = platform_driver_register(&bfin_mii_bus_driver);
-	if (!ret)
-		return platform_driver_register(&bfin_mac_driver);
-	return -ENODEV;
+	if (platform_driver_register(&bfin_mii_bus_driver))
+		return -ENODEV;
+	return platform_driver_register(&bfin_mac_driver);
 }
 
 module_init(bfin_mac_init);
@@ -1720,4 +1741,3 @@ static void __exit bfin_mac_cleanup(void)
 }
 
 module_exit(bfin_mac_cleanup);
-


