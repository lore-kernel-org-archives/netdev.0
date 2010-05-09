From: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 01/11] netdev: bfin_mac: add support
	for IEEE 1588 PTP
Date: Sun,  9 May 2010 06:18:47 -0400
Message-ID: <1273400337-26501-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org,
        Barry Song <barry.song-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://blackfin.uclinux.org/mailman/options/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Barry Song <barry.song-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>

Newer on-chip MAC peripherals support IEEE 1588 PTP in the hardware, so
extend the driver to support this functionality.

Signed-off-by: Barry Song <barry.song-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/Kconfig    |    7 +
 drivers/net/bfin_mac.c |  341 +++++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/bfin_mac.h |   15 ++
 3 files changed, 362 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 7b832c7..ac536b9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -887,6 +887,13 @@ config BFIN_MAC_RMII
 	help
 	  Use Reduced PHY MII Interface
 
+config BFIN_MAC_USE_HWSTAMP
+	bool "Use IEEE 1588 hwstamp"
+	depends on BFIN_MAC && BF518
+	default y
+	help
+	  To support the IEEE 1588 Precision Time Protocol (PTP), select y here
+
 config SMC9194
 	tristate "SMC 9194 support"
 	depends on NET_VENDOR_SMC && (ISA || MAC && BROKEN)
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 587f93c..6a9519f 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -33,6 +33,7 @@
 #include <asm/dma.h>
 #include <linux/dma-mapping.h>
 
+#include <asm/div64.h>
 #include <asm/dpmc.h>
 #include <asm/blackfin.h>
 #include <asm/cacheflush.h>
@@ -551,6 +552,309 @@ static int bfin_mac_set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
+#ifdef CONFIG_BFIN_MAC_USE_HWSTAMP
+#define bfin_mac_hwtstamp_is_none(cfg) ((cfg) == HWTSTAMP_FILTER_NONE)
+
+static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
+		struct ifreq *ifr, int cmd)
+{
+	struct hwtstamp_config config;
+	struct bfin_mac_local *lp = netdev_priv(netdev);
+	u16 ptpctl;
+	u32 ptpfv1, ptpfv2, ptpfv3, ptpfoff;
+
+	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
+		return -EFAULT;
+
+	pr_debug("%s config flag:0x%x, tx_type:0x%x, rx_filter:0x%x\n",
+			__func__, config.flags, config.tx_type, config.rx_filter);
+
+	/* reserved for future extensions */
+	if (config.flags)
+		return -EINVAL;
+
+	if ((config.tx_type != HWTSTAMP_TX_OFF) &&
+			(config.tx_type != HWTSTAMP_TX_ON))
+		return -ERANGE;
+
+	ptpctl = bfin_read_EMAC_PTP_CTL();
+
+	switch (config.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		/*
+		 * Dont allow any timestamping
+		 */
+		ptpfv3 = 0xFFFFFFFF;
+		bfin_write_EMAC_PTP_FV3(ptpfv3);
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		/*
+		 * Clear the five comparison mask bits (bits[12:8]) in EMAC_PTP_CTL)
+		 * to enable all the field matches.
+		 */
+		ptpctl &= ~0x1F00;
+		bfin_write_EMAC_PTP_CTL(ptpctl);
+		/*
+		 * Keep the default values of the EMAC_PTP_FOFF register.
+		 */
+		ptpfoff = 0x4A24170C;
+		bfin_write_EMAC_PTP_FOFF(ptpfoff);
+		/*
+		 * Keep the default values of the EMAC_PTP_FV1 and EMAC_PTP_FV2
+		 * registers.
+		 */
+		ptpfv1 = 0x11040800;
+		bfin_write_EMAC_PTP_FV1(ptpfv1);
+		ptpfv2 = 0x0140013F;
+		bfin_write_EMAC_PTP_FV2(ptpfv2);
+		/*
+		 * The default value (0xFFFC) allows the timestamping of both
+		 * received Sync messages and Delay_Req messages.
+		 */
+		ptpfv3 = 0xFFFFFFFC;
+		bfin_write_EMAC_PTP_FV3(ptpfv3);
+
+		config.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		/* Clear all five comparison mask bits (bits[12:8]) in the
+		 * EMAC_PTP_CTL register to enable all the field matches.
+		 */
+		ptpctl &= ~0x1F00;
+		bfin_write_EMAC_PTP_CTL(ptpctl);
+		/*
+		 * Keep the default values of the EMAC_PTP_FOFF register, except set
+		 * the PTPCOF field to 0x2A.
+		 */
+		ptpfoff = 0x2A24170C;
+		bfin_write_EMAC_PTP_FOFF(ptpfoff);
+		/*
+		 * Keep the default values of the EMAC_PTP_FV1 and EMAC_PTP_FV2
+		 * registers.
+		 */
+		ptpfv1 = 0x11040800;
+		bfin_write_EMAC_PTP_FV1(ptpfv1);
+		ptpfv2 = 0x0140013F;
+		bfin_write_EMAC_PTP_FV2(ptpfv2);
+		/*
+		 * To allow the timestamping of Pdelay_Req and Pdelay_Resp, set
+		 * the value to 0xFFF0.
+		 */
+		ptpfv3 = 0xFFFFFFF0;
+		bfin_write_EMAC_PTP_FV3(ptpfv3);
+
+		config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_EVENT;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+		/*
+		 * Clear bits 8 and 12 of the EMAC_PTP_CTL register to enable only the
+		 * EFTM and PTPCM field comparison.
+		 */
+		ptpctl &= ~0x1100;
+		bfin_write_EMAC_PTP_CTL(ptpctl);
+		/*
+		 * Keep the default values of all the fields of the EMAC_PTP_FOFF
+		 * register, except set the PTPCOF field to 0x0E.
+		 */
+		ptpfoff = 0x0E24170C;
+		bfin_write_EMAC_PTP_FOFF(ptpfoff);
+		/*
+		 * Program bits [15:0] of the EMAC_PTP_FV1 register to 0x88F7, which
+		 * corresponds to PTP messages on the MAC layer.
+		 */
+		ptpfv1 = 0x110488F7;
+		bfin_write_EMAC_PTP_FV1(ptpfv1);
+		ptpfv2 = 0x0140013F;
+		bfin_write_EMAC_PTP_FV2(ptpfv2);
+		/*
+		 * To allow the timestamping of Pdelay_Req and Pdelay_Resp
+		 * messages, set the value to 0xFFF0.
+		 */
+		ptpfv3 = 0xFFFFFFF0;
+		bfin_write_EMAC_PTP_FV3(ptpfv3);
+
+		config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L2_EVENT;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	if (config.tx_type == HWTSTAMP_TX_OFF &&
+	    bfin_mac_hwtstamp_is_none(config.rx_filter)) {
+		ptpctl &= ~PTP_EN;
+		bfin_write_EMAC_PTP_CTL(ptpctl);
+
+		SSYNC();
+	} else {
+		ptpctl |= PTP_EN;
+		bfin_write_EMAC_PTP_CTL(ptpctl);
+
+		/*
+		 * clear any existing timestamp
+		 */
+		bfin_read_EMAC_PTP_RXSNAPLO();
+		bfin_read_EMAC_PTP_RXSNAPHI();
+
+		bfin_read_EMAC_PTP_TXSNAPLO();
+		bfin_read_EMAC_PTP_TXSNAPHI();
+
+		/*
+		 * Set registers so that rollover occurs soon to test this.
+		 */
+		bfin_write_EMAC_PTP_TIMELO(0x00000000);
+		bfin_write_EMAC_PTP_TIMEHI(0xFF800000);
+
+		SSYNC();
+
+		lp->compare.last_update = 0;
+		timecounter_init(&lp->clock,
+				&lp->cycles,
+				ktime_to_ns(ktime_get_real()));
+		timecompare_update(&lp->compare, 0);
+	}
+
+	lp->stamp_cfg = config;
+	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
+		-EFAULT : 0;
+}
+
+static void bfin_dump_hwtamp(char *s, ktime_t *hw, ktime_t *ts, struct timecompare *cmp)
+{
+	ktime_t sys = ktime_get_real();
+
+	pr_debug("%s %s hardware:%d,%d transform system:%d,%d system:%d,%d, cmp:%lld, %lld\n",
+			__func__, s, hw->tv.sec, hw->tv.nsec, ts->tv.sec, ts->tv.nsec, sys.tv.sec,
+			sys.tv.nsec, cmp->offset, cmp->skew);
+}
+
+static void bfin_tx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
+{
+	struct bfin_mac_local *lp = netdev_priv(netdev);
+	union skb_shared_tx *shtx = skb_tx(skb);
+
+	if (shtx->hardware) {
+		int timeout_cnt = MAX_TIMEOUT_CNT;
+
+		/* When doing time stamping, keep the connection to the socket
+		 * a while longer
+		 */
+		shtx->in_progress = 1;
+
+		/*
+		 * The timestamping is done at the EMAC module's MII/RMII interface
+		 * when the module sees the Start of Frame of an event message packet. This
+		 * interface is the closest possible place to the physical Ethernet transmission
+		 * medium, providing the best timing accuracy.
+		 */
+		while ((!(bfin_read_EMAC_PTP_ISTAT() & TXTL)) && (--timeout_cnt))
+			udelay(1);
+		if (timeout_cnt == 0)
+			printk(KERN_ERR DRV_NAME
+					": fails to timestamp the TX packet\n");
+		else {
+			struct skb_shared_hwtstamps shhwtstamps;
+			u64 ns;
+			u64 regval;
+
+			regval = bfin_read_EMAC_PTP_TXSNAPLO();
+			regval |= (u64)bfin_read_EMAC_PTP_TXSNAPHI() << 32;
+			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
+			ns = timecounter_cyc2time(&lp->clock,
+					regval);
+			timecompare_update(&lp->compare, ns);
+			shhwtstamps.hwtstamp = ns_to_ktime(ns);
+			shhwtstamps.syststamp =
+				timecompare_transform(&lp->compare, ns);
+			skb_tstamp_tx(skb, &shhwtstamps);
+
+			bfin_dump_hwtamp("TX", &shhwtstamps.hwtstamp, &shhwtstamps.syststamp, &lp->compare);
+		}
+	}
+}
+
+static void bfin_rx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
+{
+	struct bfin_mac_local *lp = netdev_priv(netdev);
+	u32 valid;
+	u64 regval, ns;
+	struct skb_shared_hwtstamps *shhwtstamps;
+
+	if (bfin_mac_hwtstamp_is_none(lp->stamp_cfg.rx_filter))
+		return;
+
+	valid = bfin_read_EMAC_PTP_ISTAT() & RXEL;
+	if (!valid)
+		return;
+
+	shhwtstamps = skb_hwtstamps(skb);
+
+	regval = bfin_read_EMAC_PTP_RXSNAPLO();
+	regval |= (u64)bfin_read_EMAC_PTP_RXSNAPHI() << 32;
+	ns = timecounter_cyc2time(&lp->clock, regval);
+	timecompare_update(&lp->compare, ns);
+	memset(shhwtstamps, 0, sizeof(*shhwtstamps));
+	shhwtstamps->hwtstamp = ns_to_ktime(ns);
+	shhwtstamps->syststamp = timecompare_transform(&lp->compare, ns);
+
+	bfin_dump_hwtamp("RX", &shhwtstamps->hwtstamp, &shhwtstamps->syststamp, &lp->compare);
+}
+
+/*
+ * bfin_read_clock - read raw cycle counter (to be used by time counter)
+ */
+static cycle_t bfin_read_clock(const struct cyclecounter *tc)
+{
+	u64 stamp;
+
+	stamp =  bfin_read_EMAC_PTP_TIMELO();
+	stamp |= (u64)bfin_read_EMAC_PTP_TIMEHI() << 32ULL;
+
+	return stamp;
+}
+
+#define PTP_CLK 25000000
+
+static void bfin_mac_hwtstamp_init(struct net_device *netdev)
+{
+	struct bfin_mac_local *lp = netdev_priv(netdev);
+	u64 append;
+
+	/* Initialize hardware timer */
+	append = PTP_CLK * (1ULL << 32);
+	do_div(append, get_sclk());
+	bfin_write_EMAC_PTP_ADDEND((u32)append);
+
+	memset(&lp->cycles, 0, sizeof(lp->cycles));
+	lp->cycles.read = bfin_read_clock;
+	lp->cycles.mask = CLOCKSOURCE_MASK(64);
+	lp->cycles.mult = 1000000000 / PTP_CLK;
+	lp->cycles.shift = 0;
+
+	/* Synchronize our NIC clock against system wall clock */
+	memset(&lp->compare, 0, sizeof(lp->compare));
+	lp->compare.source = &lp->clock;
+	lp->compare.target = ktime_get_real;
+	lp->compare.num_samples = 10;
+
+	/* Initialize hwstamp config */
+	lp->stamp_cfg.rx_filter = HWTSTAMP_FILTER_NONE;
+	lp->stamp_cfg.tx_type = HWTSTAMP_TX_OFF;
+}
+
+#else
+# define bfin_mac_hwtstamp_is_none(cfg) 0
+# define bfin_mac_hwtstamp_init(dev)
+# define bfin_mac_hwtstamp_ioctl(dev, ifr, cmd) (-EOPNOTSUPP)
+# define bfin_rx_hwtstamp(dev, skb)
+# define bfin_tx_hwtstamp(dev, skb)
+#endif
+
 static void adjust_tx_list(void)
 {
 	int timeout_cnt = MAX_TIMEOUT_CNT;
@@ -608,18 +912,32 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 {
 	u16 *data;
 	u32 data_align = (unsigned long)(skb->data) & 0x3;
+	union skb_shared_tx *shtx = skb_tx(skb);
+
 	current_tx_ptr->skb = skb;
 
 	if (data_align == 0x2) {
 		/* move skb->data to current_tx_ptr payload */
 		data = (u16 *)(skb->data) - 1;
-				*data = (u16)(skb->len);
+		*data = (u16)(skb->len);
+		/*
+		 * When transmitting an Ethernet packet, the PTP_TSYNC module requires
+		 * a DMA_Length_Word field associated with the packet. The lower 12 bits
+		 * of this field are the length of the packet payload in bytes and the higher
+		 * 4 bits are the timestamping enable field.
+		 */
+		if (shtx->hardware)
+			*data |= 0x1000;
+
 		current_tx_ptr->desc_a.start_addr = (u32)data;
 		/* this is important! */
 		blackfin_dcache_flush_range((u32)data,
 				(u32)((u8 *)data + skb->len + 4));
 	} else {
 		*((u16 *)(current_tx_ptr->packet)) = (u16)(skb->len);
+		/* enable timestamping for the sent packet */
+		if (shtx->hardware)
+			*((u16 *)(current_tx_ptr->packet)) |= 0x1000;
 		memcpy((u8 *)(current_tx_ptr->packet + 2), skb->data,
 			skb->len);
 		current_tx_ptr->desc_a.start_addr =
@@ -653,6 +971,9 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 
 out:
 	adjust_tx_list();
+
+	bfin_tx_hwtstamp(dev, skb);
+
 	current_tx_ptr = current_tx_ptr->next;
 	dev->trans_start = jiffies;
 	dev->stats.tx_packets++;
@@ -664,9 +985,11 @@ static void bfin_mac_rx(struct net_device *dev)
 {
 	struct sk_buff *skb, *new_skb;
 	unsigned short len;
+	struct bfin_mac_local *lp __maybe_unused = netdev_priv(dev);
 
 	/* allocate a new skb for next time receive */
 	skb = current_rx_ptr->skb;
+
 	new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
 	if (!new_skb) {
 		printk(KERN_NOTICE DRV_NAME
@@ -691,6 +1014,9 @@ static void bfin_mac_rx(struct net_device *dev)
 					 (unsigned long)skb->tail);
 
 	skb->protocol = eth_type_trans(skb, dev);
+
+	bfin_rx_hwtstamp(dev, skb);
+
 #if defined(BFIN_MAC_CSUM_OFFLOAD)
 	skb->csum = current_rx_ptr->status.ip_payload_csum;
 	skb->ip_summed = CHECKSUM_COMPLETE;
@@ -874,6 +1200,16 @@ static void bfin_mac_set_multicast_list(struct net_device *dev)
 	}
 }
 
+static int bfin_mac_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	switch (cmd) {
+	case SIOCSHWTSTAMP:
+		return bfin_mac_hwtstamp_ioctl(netdev, ifr, cmd);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 /*
  * this puts the device in an inactive state
  */
@@ -958,6 +1294,7 @@ static const struct net_device_ops bfin_mac_netdev_ops = {
 	.ndo_set_mac_address	= bfin_mac_set_mac_address,
 	.ndo_tx_timeout		= bfin_mac_timeout,
 	.ndo_set_multicast_list	= bfin_mac_set_multicast_list,
+	.ndo_do_ioctl           = bfin_mac_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1049,6 +1386,8 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 		goto out_err_reg_ndev;
 	}
 
+	bfin_mac_hwtstamp_init(ndev);
+
 	/* now, print out the card info, in a short format.. */
 	dev_info(&pdev->dev, "%s, Version %s\n", DRV_DESC, DRV_VERSION);
 
diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
index 052b5dc..87c454f 100644
--- a/drivers/net/bfin_mac.h
+++ b/drivers/net/bfin_mac.h
@@ -7,6 +7,12 @@
  *
  * Licensed under the GPL-2 or later.
  */
+#ifndef _BFIN_MAC_H_
+#define _BFIN_MAC_H_
+
+#include <linux/net_tstamp.h>
+#include <linux/clocksource.h>
+#include <linux/timecompare.h>
 
 #define BFIN_MAC_CSUM_OFFLOAD
 
@@ -67,6 +73,15 @@ struct bfin_mac_local {
 
 	struct phy_device *phydev;
 	struct mii_bus *mii_bus;
+
+#if defined(CONFIG_BFIN_MAC_USE_HWSTAMP)
+	struct cyclecounter cycles;
+	struct timecounter clock;
+	struct timecompare compare;
+	struct hwtstamp_config stamp_cfg;
+#endif
 };
 
 extern void bfin_get_ether_addr(char *addr);
+
+#endif
-- 
1.7.1
