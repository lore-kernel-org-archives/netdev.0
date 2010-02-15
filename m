From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] niu.c: Use pr_<level>, netdev_<level> and
 netif_<level> macros
Date: Sun, 14 Feb 2010 16:47:09 -0800
Message-ID: <1266194829.16721.940.camel@Joe-Laptop.home>
References: <cover.1265751023.git.joe@perches.com>
	 <20100212.123129.163263355.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1038 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753229Ab0BOArL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Feb 2010 19:47:11 -0500
In-Reply-To: <20100212.123129.163263355.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-02-12 at 12:31 -0800, David Miller wrote:
> I really like these changes, feel free to make a pass of niu.[ch] making it
> use these things :-)

OK David, here you go.

I'm not sure of the conversions of:
	dev_<level>(np->device,...
to
	netdev_<level>(np->dev,...

It compiles, but dunno if it's correct (no hw to test)

Remove #define PFX
Add pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Convert printks to pr_<level>
Convert printks without levels to pr_cont
Convert pr_<level> with np->dev to netdev_<level>
Convert dev_<level> to netdev_<level>
Convert niudbg to netif_printk
Convert niuinfo, niuwarn macros to netif_<level>(priv, type, dev...
Coalesce long formats
Convert embedded function names to "%s", __func__
Always use "%s()..." when __func__ is printed

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/niu.c |  703 +++++++++++++++++++++++-----------------------------
 1 files changed, 311 insertions(+), 392 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 7b52d97..347788f 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3,6 +3,8 @@
  * Copyright (C) 2007, 2008 David S. Miller (davem@davemloft.net)
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/pci.h>
@@ -33,7 +35,6 @@
 #include "niu.h"
 
 #define DRV_MODULE_NAME		"niu"
-#define PFX DRV_MODULE_NAME	": "
 #define DRV_MODULE_VERSION	"1.0"
 #define DRV_MODULE_RELDATE	"Nov 14, 2008"
 
@@ -89,21 +90,6 @@ static int debug = -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "NIU debug level");
 
-#define niudbg(TYPE, f, a...) \
-do {	if ((np)->msg_enable & NETIF_MSG_##TYPE) \
-		printk(KERN_DEBUG PFX f, ## a); \
-} while (0)
-
-#define niuinfo(TYPE, f, a...) \
-do {	if ((np)->msg_enable & NETIF_MSG_##TYPE) \
-		printk(KERN_INFO PFX f, ## a); \
-} while (0)
-
-#define niuwarn(TYPE, f, a...) \
-do {	if ((np)->msg_enable & NETIF_MSG_##TYPE) \
-		printk(KERN_WARNING PFX f, ## a); \
-} while (0)
-
 #define niu_lock_parent(np, flags) \
 	spin_lock_irqsave(&np->parent->lock, flags)
 #define niu_unlock_parent(np, flags) \
@@ -135,10 +121,9 @@ static int __niu_set_and_wait_clear_mac(struct niu *np, unsigned long reg,
 	nw64_mac(reg, bits);
 	err = __niu_wait_bits_clear_mac(np, reg, bits, limit, delay);
 	if (err)
-		dev_err(np->device, PFX "%s: bits (%llx) of register %s "
-			"would not clear, val[%llx]\n",
-			np->dev->name, (unsigned long long) bits, reg_name,
-			(unsigned long long) nr64_mac(reg));
+		netdev_err(np->dev, "bits (%llx) of register %s would not clear, val[%llx]\n",
+			   (unsigned long long)bits, reg_name,
+			   (unsigned long long)nr64_mac(reg));
 	return err;
 }
 
@@ -175,10 +160,9 @@ static int __niu_set_and_wait_clear_ipp(struct niu *np, unsigned long reg,
 
 	err = __niu_wait_bits_clear_ipp(np, reg, bits, limit, delay);
 	if (err)
-		dev_err(np->device, PFX "%s: bits (%llx) of register %s "
-			"would not clear, val[%llx]\n",
-			np->dev->name, (unsigned long long) bits, reg_name,
-			(unsigned long long) nr64_ipp(reg));
+		netdev_err(np->dev, "bits (%llx) of register %s would not clear, val[%llx]\n",
+			   (unsigned long long)bits, reg_name,
+			   (unsigned long long)nr64_ipp(reg));
 	return err;
 }
 
@@ -216,10 +200,9 @@ static int __niu_set_and_wait_clear(struct niu *np, unsigned long reg,
 	nw64(reg, bits);
 	err = __niu_wait_bits_clear(np, reg, bits, limit, delay);
 	if (err)
-		dev_err(np->device, PFX "%s: bits (%llx) of register %s "
-			"would not clear, val[%llx]\n",
-			np->dev->name, (unsigned long long) bits, reg_name,
-			(unsigned long long) nr64(reg));
+		netdev_err(np->dev, "bits (%llx) of register %s would not clear, val[%llx]\n",
+			   (unsigned long long)bits, reg_name,
+			   (unsigned long long)nr64(reg));
 	return err;
 }
 
@@ -475,9 +458,8 @@ static int serdes_init_niu_1g_serdes(struct niu *np)
 	err = mdio_write(np, np->port, NIU_ESR2_DEV_ADDR,
 			 ESR2_TI_PLL_CFG_L, pll_cfg);
 	if (err) {
-		dev_err(np->device, PFX "NIU Port %d "
-			"serdes_init_niu_1g_serdes: "
-			"mdio write to ESR2_TI_PLL_CFG_L failed", np->port);
+		netdev_err(np->dev, "NIU Port %d %s() mdio write to ESR2_TI_PLL_CFG_L failed\n",
+			   np->port, __func__);
 		return err;
 	}
 
@@ -486,9 +468,8 @@ static int serdes_init_niu_1g_serdes(struct niu *np)
 	err = mdio_write(np, np->port, NIU_ESR2_DEV_ADDR,
 			 ESR2_TI_PLL_STS_L, pll_sts);
 	if (err) {
-		dev_err(np->device, PFX "NIU Port %d "
-			"serdes_init_niu_1g_serdes: "
-			"mdio write to ESR2_TI_PLL_STS_L failed", np->port);
+		netdev_err(np->dev, "NIU Port %d %s() mdio write to ESR2_TI_PLL_STS_L failed\n",
+			   np->port, __func__);
 		return err;
 	}
 
@@ -531,8 +512,8 @@ static int serdes_init_niu_1g_serdes(struct niu *np)
 	}
 
 	if ((sig & mask) != val) {
-		dev_err(np->device, PFX "Port %u signal bits [%08x] are not "
-			"[%08x]\n", np->port, (int) (sig & mask), (int) val);
+		netdev_err(np->dev, "Port %u signal bits [%08x] are not [%08x]\n",
+			   np->port, (int)(sig & mask), (int)val);
 		return -ENODEV;
 	}
 
@@ -569,9 +550,8 @@ static int serdes_init_niu_10g_serdes(struct niu *np)
 	err = mdio_write(np, np->port, NIU_ESR2_DEV_ADDR,
 			 ESR2_TI_PLL_CFG_L, pll_cfg & 0xffff);
 	if (err) {
-		dev_err(np->device, PFX "NIU Port %d "
-			"serdes_init_niu_10g_serdes: "
-			"mdio write to ESR2_TI_PLL_CFG_L failed", np->port);
+		netdev_err(np->dev, "NIU Port %d %s() mdio write to ESR2_TI_PLL_CFG_L failed\n",
+			   np->port, __func__);
 		return err;
 	}
 
@@ -580,9 +560,8 @@ static int serdes_init_niu_10g_serdes(struct niu *np)
 	err = mdio_write(np, np->port, NIU_ESR2_DEV_ADDR,
 			 ESR2_TI_PLL_STS_L, pll_sts & 0xffff);
 	if (err) {
-		dev_err(np->device, PFX "NIU Port %d "
-			"serdes_init_niu_10g_serdes: "
-			"mdio write to ESR2_TI_PLL_STS_L failed", np->port);
+		netdev_err(np->dev, "NIU Port %d %s() mdio write to ESR2_TI_PLL_STS_L failed\n",
+			   np->port, __func__);
 		return err;
 	}
 
@@ -639,9 +618,8 @@ static int serdes_init_niu_10g_serdes(struct niu *np)
 	}
 
 	if ((sig & mask) != val) {
-		pr_info(PFX "NIU Port %u signal bits [%08x] are not "
-			"[%08x] for 10G...trying 1G\n",
-			np->port, (int) (sig & mask), (int) val);
+		pr_info("NIU Port %u signal bits [%08x] are not [%08x] for 10G...trying 1G\n",
+			np->port, (int)(sig & mask), (int)val);
 
 		/* 10G failed, try initializing at 1G */
 		err = serdes_init_niu_1g_serdes(np);
@@ -649,8 +627,8 @@ static int serdes_init_niu_10g_serdes(struct niu *np)
 			np->flags &= ~NIU_FLAGS_10G;
 			np->mac_xcvr = MAC_XCVR_PCS;
 		}  else {
-			dev_err(np->device, PFX "Port %u 10G/1G SERDES "
-				"Link Failed \n", np->port);
+			netdev_err(np->dev, "Port %u 10G/1G SERDES Link Failed\n",
+				   np->port);
 			return -ENODEV;
 		}
 	}
@@ -764,9 +742,8 @@ static int esr_reset(struct niu *np)
 	if (err)
 		return err;
 	if (reset != 0) {
-		dev_err(np->device, PFX "Port %u ESR_RESET "
-			"did not clear [%08x]\n",
-			np->port, reset);
+		netdev_err(np->dev, "Port %u ESR_RESET did not clear [%08x]\n",
+			   np->port, reset);
 		return -ENODEV;
 	}
 
@@ -890,8 +867,8 @@ static int serdes_init_10g(struct niu *np)
 			np->flags &= ~NIU_FLAGS_HOTPLUG_PHY_PRESENT;
 			return 0;
 		}
-		dev_err(np->device, PFX "Port %u signal bits [%08x] are not "
-			"[%08x]\n", np->port, (int) (sig & mask), (int) val);
+		netdev_err(np->dev, "Port %u signal bits [%08x] are not [%08x]\n",
+			   np->port, (int)(sig & mask), (int)val);
 		return -ENODEV;
 	}
 	if (np->flags & NIU_FLAGS_HOTPLUG_PHY)
@@ -1039,8 +1016,8 @@ static int serdes_init_1g_serdes(struct niu *np)
 	}
 
 	if ((sig & mask) != val) {
-		dev_err(np->device, PFX "Port %u signal bits [%08x] are not "
-			"[%08x]\n", np->port, (int) (sig & mask), (int) val);
+		netdev_err(np->dev, "Port %u signal bits [%08x] are not [%08x]\n",
+			   np->port, (int)(sig & mask), (int)val);
 		return -ENODEV;
 	}
 
@@ -1332,8 +1309,8 @@ static int bcm8704_reset(struct niu *np)
 			break;
 	}
 	if (limit < 0) {
-		dev_err(np->device, PFX "Port %u PHY will not reset "
-			"(bmcr=%04x)\n", np->port, (err & 0xffff));
+		netdev_err(np->dev, "Port %u PHY will not reset (bmcr=%04x)\n",
+			   np->port, (err & 0xffff));
 		return -ENODEV;
 	}
 	return 0;
@@ -1515,21 +1492,18 @@ static int xcvr_diag_bcm870x(struct niu *np)
 			MII_STAT1000);
 	if (err < 0)
 		return err;
-	pr_info(PFX "Port %u PMA_PMD(MII_STAT1000) [%04x]\n",
-		np->port, err);
+	pr_info("Port %u PMA_PMD(MII_STAT1000) [%04x]\n", np->port, err);
 
 	err = mdio_read(np, np->phy_addr, BCM8704_USER_DEV3_ADDR, 0x20);
 	if (err < 0)
 		return err;
-	pr_info(PFX "Port %u USER_DEV3(0x20) [%04x]\n",
-		np->port, err);
+	pr_info("Port %u USER_DEV3(0x20) [%04x]\n", np->port, err);
 
 	err = mdio_read(np, np->phy_addr, BCM8704_PHYXS_DEV_ADDR,
 			MII_NWAYTEST);
 	if (err < 0)
 		return err;
-	pr_info(PFX "Port %u PHYXS(MII_NWAYTEST) [%04x]\n",
-		np->port, err);
+	pr_info("Port %u PHYXS(MII_NWAYTEST) [%04x]\n", np->port, err);
 #endif
 
 	/* XXX dig this out it might not be so useful XXX */
@@ -1555,11 +1529,11 @@ static int xcvr_diag_bcm870x(struct niu *np)
 
 	if (analog_stat0 != 0x03fc) {
 		if ((analog_stat0 == 0x43bc) && (tx_alarm_status != 0)) {
-			pr_info(PFX "Port %u cable not connected "
-				"or bad cable.\n", np->port);
+			pr_info("Port %u cable not connected or bad cable\n",
+				np->port);
 		} else if (analog_stat0 == 0x639c) {
-			pr_info(PFX "Port %u optical module is bad "
-				"or missing.\n", np->port);
+			pr_info("Port %u optical module is bad or missing\n",
+				np->port);
 		}
 	}
 
@@ -1699,8 +1673,8 @@ static int mii_reset(struct niu *np)
 			break;
 	}
 	if (limit < 0) {
-		dev_err(np->device, PFX "Port %u MII would not reset, "
-			"bmcr[%04x]\n", np->port, err);
+		netdev_err(np->dev, "Port %u MII would not reset, bmcr[%04x]\n",
+			   np->port, err);
 		return -ENODEV;
 	}
 
@@ -1895,7 +1869,7 @@ static int mii_init_common(struct niu *np)
 		return err;
 	bmsr = err;
 
-	pr_info(PFX "Port %u after MII init bmcr[%04x] bmsr[%04x]\n",
+	pr_info("Port %u after MII init bmcr[%04x] bmsr[%04x]\n",
 		np->port, bmcr, bmsr);
 #endif
 
@@ -1948,16 +1922,12 @@ static int niu_link_status_common(struct niu *np, int link_up)
 	unsigned long flags;
 
 	if (!netif_carrier_ok(dev) && link_up) {
-		niuinfo(LINK, "%s: Link is up at %s, %s duplex\n",
-		       dev->name,
-		       (lp->active_speed == SPEED_10000 ?
-			"10Gb/sec" :
-			(lp->active_speed == SPEED_1000 ?
-			 "1Gb/sec" :
-			 (lp->active_speed == SPEED_100 ?
-			  "100Mbit/sec" : "10Mbit/sec"))),
-		       (lp->active_duplex == DUPLEX_FULL ?
-			"full" : "half"));
+		netif_info(np, link, dev, "Link is up at %s, %s duplex\n",
+			   lp->active_speed == SPEED_10000 ? "10Gb/sec" :
+			   lp->active_speed == SPEED_1000 ? "1Gb/sec" :
+			   lp->active_speed == SPEED_100 ? "100Mbit/sec" :
+			   "10Mbit/sec",
+			   lp->active_duplex == DUPLEX_FULL ? "full" : "half");
 
 		spin_lock_irqsave(&np->lock, flags);
 		niu_init_xif(np);
@@ -1966,7 +1936,7 @@ static int niu_link_status_common(struct niu *np, int link_up)
 
 		netif_carrier_on(dev);
 	} else if (netif_carrier_ok(dev) && !link_up) {
-		niuwarn(LINK, "%s: Link is down\n", dev->name);
+		netif_warn(np, link, dev, "Link is down\n");
 		spin_lock_irqsave(&np->lock, flags);
 		niu_handle_led(np, 0);
 		spin_unlock_irqrestore(&np->lock, flags);
@@ -2232,8 +2202,8 @@ static int link_status_10g_hotplug(struct niu *np, int *link_up_p)
 			} else {
 				np->flags &= ~NIU_FLAGS_HOTPLUG_PHY_PRESENT;
 				*link_up_p = 0;
-				niuwarn(LINK, "%s: Hotplug PHY Removed\n",
-					np->dev->name);
+				netif_warn(np, link, np->dev,
+					   "Hotplug PHY Removed\n");
 			}
 		}
 out:
@@ -2531,8 +2501,8 @@ static int serdes_init_10g_serdes(struct niu *np)
 			np->flags &= ~NIU_FLAGS_10G;
 			np->mac_xcvr = MAC_XCVR_PCS;
 		}  else {
-			dev_err(np->device, PFX "Port %u 10G/1G SERDES Link Failed \n",
-			 np->port);
+			netdev_err(np->dev, "Port %u 10G/1G SERDES Link Failed\n",
+				   np->port);
 			return -ENODEV;
 		}
 	}
@@ -3234,23 +3204,25 @@ static int fflp_early_init(struct niu *np)
 	parent = np->parent;
 	err = 0;
 	if (!(parent->flags & PARENT_FLGS_CLS_HWINIT)) {
-		niudbg(PROBE, "fflp_early_init: Initting hw on port %u\n",
-		       np->port);
+		netif_printk(np, probe, KERN_DEBUG, np->dev,
+			     "%s() Initting hw on port %u\n",
+			     __func__, np->port);
 		if (np->parent->plat_type != PLAT_TYPE_NIU) {
 			fflp_reset(np);
 			fflp_set_timings(np);
 			err = fflp_disable_all_partitions(np);
 			if (err) {
-				niudbg(PROBE, "fflp_disable_all_partitions "
-				       "failed, err=%d\n", err);
+				netif_printk(np, probe, KERN_DEBUG, np->dev,
+					     "fflp_disable_all_partitions failed, err=%d\n",
+					     err);
 				goto out;
 			}
 		}
 
 		err = tcam_early_init(np);
 		if (err) {
-			niudbg(PROBE, "tcam_early_init failed, err=%d\n",
-			       err);
+			netif_printk(np, probe, KERN_DEBUG, np->dev,
+				     "tcam_early_init failed, err=%d\n", err);
 			goto out;
 		}
 		fflp_llcsnap_enable(np, 1);
@@ -3260,22 +3232,24 @@ static int fflp_early_init(struct niu *np)
 
 		err = tcam_flush_all(np);
 		if (err) {
-			niudbg(PROBE, "tcam_flush_all failed, err=%d\n",
-			       err);
+			netif_printk(np, probe, KERN_DEBUG, np->dev,
+				     "tcam_flush_all failed, err=%d\n", err);
 			goto out;
 		}
 		if (np->parent->plat_type != PLAT_TYPE_NIU) {
 			err = fflp_hash_clear(np);
 			if (err) {
-				niudbg(PROBE, "fflp_hash_clear failed, "
-				       "err=%d\n", err);
+				netif_printk(np, probe, KERN_DEBUG, np->dev,
+					     "fflp_hash_clear failed, err=%d\n",
+					     err);
 				goto out;
 			}
 		}
 
 		vlan_tbl_clear(np);
 
-		niudbg(PROBE, "fflp_early_init: Success\n");
+		netif_printk(np, probe, KERN_DEBUG, np->dev,
+			     "%s() Success\n", __func__);
 		parent->flags |= PARENT_FLGS_CLS_HWINIT;
 	}
 out:
@@ -3665,8 +3639,8 @@ static void niu_tx_work(struct niu *np, struct tx_ring_info *rp)
 
 	cons = rp->cons;
 
-	niudbg(TX_DONE, "%s: niu_tx_work() pkt_cnt[%u] cons[%d]\n",
-	       np->dev->name, pkt_cnt, cons);
+	netif_printk(np, tx_done, KERN_DEBUG, np->dev,
+		     "%s() pkt_cnt[%u] cons[%d]\n", __func__, pkt_cnt, cons);
 
 	while (pkt_cnt--)
 		cons = release_tx_packet(np, rp, cons);
@@ -3714,11 +3688,12 @@ static inline void niu_sync_rx_discard_stats(struct niu *np,
 		rp->rx_errors += misc & RXMISC_COUNT;
 
 		if (unlikely(misc & RXMISC_OFLOW))
-			dev_err(np->device, "rx-%d: Counter overflow "
-				"RXMISC discard\n", rx_channel);
+			dev_err(np->device, "rx-%d: Counter overflow RXMISC discard\n",
+				rx_channel);
 
-		niudbg(RX_ERR, "%s-rx-%d: MISC drop=%u over=%u\n",
-		       np->dev->name, rx_channel, misc, misc-limit);
+		netif_printk(np, rx_err, KERN_DEBUG, np->dev,
+			     "rx-%d: MISC drop=%u over=%u\n",
+			     rx_channel, misc, misc-limit);
 	}
 
 	/* WRED (Weighted Random Early Discard) by hardware */
@@ -3728,11 +3703,11 @@ static inline void niu_sync_rx_discard_stats(struct niu *np,
 		rp->rx_dropped += wred & RED_DIS_CNT_COUNT;
 
 		if (unlikely(wred & RED_DIS_CNT_OFLOW))
-			dev_err(np->device, "rx-%d: Counter overflow "
-				"WRED discard\n", rx_channel);
+			dev_err(np->device, "rx-%d: Counter overflow WRED discard\n", rx_channel);
 
-		niudbg(RX_ERR, "%s-rx-%d: WRED drop=%u over=%u\n",
-		       np->dev->name, rx_channel, wred, wred-limit);
+		netif_printk(np, rx_err, KERN_DEBUG, np->dev,
+			     "rx-%d: WRED drop=%u over=%u\n",
+			     rx_channel, wred, wred-limit);
 	}
 }
 
@@ -3753,8 +3728,9 @@ static int niu_rx_work(struct napi_struct *napi, struct niu *np,
 	mbox->rx_dma_ctl_stat = 0;
 	mbox->rcrstat_a = 0;
 
-	niudbg(RX_STATUS, "%s: niu_rx_work(chan[%d]), stat[%llx] qlen=%d\n",
-	       np->dev->name, rp->rx_channel, (unsigned long long) stat, qlen);
+	netif_printk(np, rx_status, KERN_DEBUG, np->dev,
+		     "%s(chan[%d]), stat[%llx] qlen=%d\n",
+		     __func__, rp->rx_channel, (unsigned long long)stat, qlen);
 
 	rcr_done = work_done = 0;
 	qlen = min(qlen, budget);
@@ -3791,8 +3767,8 @@ static int niu_poll_core(struct niu *np, struct niu_ldg *lp, int budget)
 	u32 rx_vec = (v0 & 0xffffffff);
 	int i, work_done = 0;
 
-	niudbg(INTR, "%s: niu_poll_core() v0[%016llx]\n",
-	       np->dev->name, (unsigned long long) v0);
+	netif_printk(np, intr, KERN_DEBUG, np->dev,
+		     "%s() v0[%016llx]\n", __func__, (unsigned long long)v0);
 
 	for (i = 0; i < np->num_tx_rings; i++) {
 		struct tx_ring_info *rp = &np->tx_rings[i];
@@ -3837,39 +3813,38 @@ static int niu_poll(struct napi_struct *napi, int budget)
 static void niu_log_rxchan_errors(struct niu *np, struct rx_ring_info *rp,
 				  u64 stat)
 {
-	dev_err(np->device, PFX "%s: RX channel %u errors ( ",
-		np->dev->name, rp->rx_channel);
+	netdev_err(np->dev, "RX channel %u errors ( ", rp->rx_channel);
 
 	if (stat & RX_DMA_CTL_STAT_RBR_TMOUT)
-		printk("RBR_TMOUT ");
+		pr_cont("RBR_TMOUT ");
 	if (stat & RX_DMA_CTL_STAT_RSP_CNT_ERR)
-		printk("RSP_CNT ");
+		pr_cont("RSP_CNT ");
 	if (stat & RX_DMA_CTL_STAT_BYTE_EN_BUS)
-		printk("BYTE_EN_BUS ");
+		pr_cont("BYTE_EN_BUS ");
 	if (stat & RX_DMA_CTL_STAT_RSP_DAT_ERR)
-		printk("RSP_DAT ");
+		pr_cont("RSP_DAT ");
 	if (stat & RX_DMA_CTL_STAT_RCR_ACK_ERR)
-		printk("RCR_ACK ");
+		pr_cont("RCR_ACK ");
 	if (stat & RX_DMA_CTL_STAT_RCR_SHA_PAR)
-		printk("RCR_SHA_PAR ");
+		pr_cont("RCR_SHA_PAR ");
 	if (stat & RX_DMA_CTL_STAT_RBR_PRE_PAR)
-		printk("RBR_PRE_PAR ");
+		pr_cont("RBR_PRE_PAR ");
 	if (stat & RX_DMA_CTL_STAT_CONFIG_ERR)
-		printk("CONFIG ");
+		pr_cont("CONFIG ");
 	if (stat & RX_DMA_CTL_STAT_RCRINCON)
-		printk("RCRINCON ");
+		pr_cont("RCRINCON ");
 	if (stat & RX_DMA_CTL_STAT_RCRFULL)
-		printk("RCRFULL ");
+		pr_cont("RCRFULL ");
 	if (stat & RX_DMA_CTL_STAT_RBRFULL)
-		printk("RBRFULL ");
+		pr_cont("RBRFULL ");
 	if (stat & RX_DMA_CTL_STAT_RBRLOGPAGE)
-		printk("RBRLOGPAGE ");
+		pr_cont("RBRLOGPAGE ");
 	if (stat & RX_DMA_CTL_STAT_CFIGLOGPAGE)
-		printk("CFIGLOGPAGE ");
+		pr_cont("CFIGLOGPAGE ");
 	if (stat & RX_DMA_CTL_STAT_DC_FIFO_ERR)
-		printk("DC_FIDO ");
+		pr_cont("DC_FIDO ");
 
-	printk(")\n");
+	pr_cont(")\n");
 }
 
 static int niu_rx_error(struct niu *np, struct rx_ring_info *rp)
@@ -3883,9 +3858,9 @@ static int niu_rx_error(struct niu *np, struct rx_ring_info *rp)
 		err = -EINVAL;
 
 	if (err) {
-		dev_err(np->device, PFX "%s: RX channel %u error, stat[%llx]\n",
-			np->dev->name, rp->rx_channel,
-			(unsigned long long) stat);
+		netdev_err(np->dev, "RX channel %u error, stat[%llx]\n",
+			   rp->rx_channel,
+			   (unsigned long long) stat);
 
 		niu_log_rxchan_errors(np, rp, stat);
 	}
@@ -3899,27 +3874,26 @@ static int niu_rx_error(struct niu *np, struct rx_ring_info *rp)
 static void niu_log_txchan_errors(struct niu *np, struct tx_ring_info *rp,
 				  u64 cs)
 {
-	dev_err(np->device, PFX "%s: TX channel %u errors ( ",
-		np->dev->name, rp->tx_channel);
+	netdev_err(np->dev, "TX channel %u errors ( ", rp->tx_channel);
 
 	if (cs & TX_CS_MBOX_ERR)
-		printk("MBOX ");
+		pr_cont("MBOX ");
 	if (cs & TX_CS_PKT_SIZE_ERR)
-		printk("PKT_SIZE ");
+		pr_cont("PKT_SIZE ");
 	if (cs & TX_CS_TX_RING_OFLOW)
-		printk("TX_RING_OFLOW ");
+		pr_cont("TX_RING_OFLOW ");
 	if (cs & TX_CS_PREF_BUF_PAR_ERR)
-		printk("PREF_BUF_PAR ");
+		pr_cont("PREF_BUF_PAR ");
 	if (cs & TX_CS_NACK_PREF)
-		printk("NACK_PREF ");
+		pr_cont("NACK_PREF ");
 	if (cs & TX_CS_NACK_PKT_RD)
-		printk("NACK_PKT_RD ");
+		pr_cont("NACK_PKT_RD ");
 	if (cs & TX_CS_CONF_PART_ERR)
-		printk("CONF_PART ");
+		pr_cont("CONF_PART ");
 	if (cs & TX_CS_PKT_PRT_ERR)
-		printk("PKT_PTR ");
+		pr_cont("PKT_PTR ");
 
-	printk(")\n");
+	pr_cont(")\n");
 }
 
 static int niu_tx_error(struct niu *np, struct tx_ring_info *rp)
@@ -3930,12 +3904,11 @@ static int niu_tx_error(struct niu *np, struct tx_ring_info *rp)
 	logh = nr64(TX_RNG_ERR_LOGH(rp->tx_channel));
 	logl = nr64(TX_RNG_ERR_LOGL(rp->tx_channel));
 
-	dev_err(np->device, PFX "%s: TX channel %u error, "
-		"cs[%llx] logh[%llx] logl[%llx]\n",
-		np->dev->name, rp->tx_channel,
-		(unsigned long long) cs,
-		(unsigned long long) logh,
-		(unsigned long long) logl);
+	netdev_err(np->dev, "TX channel %u error, cs[%llx] logh[%llx] logl[%llx]\n",
+		   rp->tx_channel,
+		   (unsigned long long)cs,
+		   (unsigned long long)logh,
+		   (unsigned long long)logl);
 
 	niu_log_txchan_errors(np, rp, cs);
 
@@ -3954,9 +3927,8 @@ static int niu_mif_interrupt(struct niu *np)
 			phy_mdint = 1;
 	}
 
-	dev_err(np->device, PFX "%s: MIF interrupt, "
-		"stat[%llx] phy_mdint(%d)\n",
-		np->dev->name, (unsigned long long) mif_status, phy_mdint);
+	netdev_err(np->dev, "MIF interrupt, stat[%llx] phy_mdint(%d)\n",
+		   (unsigned long long)mif_status, phy_mdint);
 
 	return -ENODEV;
 }
@@ -4081,41 +4053,40 @@ static int niu_mac_interrupt(struct niu *np)
 
 static void niu_log_device_error(struct niu *np, u64 stat)
 {
-	dev_err(np->device, PFX "%s: Core device errors ( ",
-		np->dev->name);
+	netdev_err(np->dev, "Core device errors ( ");
 
 	if (stat & SYS_ERR_MASK_META2)
-		printk("META2 ");
+		pr_cont("META2 ");
 	if (stat & SYS_ERR_MASK_META1)
-		printk("META1 ");
+		pr_cont("META1 ");
 	if (stat & SYS_ERR_MASK_PEU)
-		printk("PEU ");
+		pr_cont("PEU ");
 	if (stat & SYS_ERR_MASK_TXC)
-		printk("TXC ");
+		pr_cont("TXC ");
 	if (stat & SYS_ERR_MASK_RDMC)
-		printk("RDMC ");
+		pr_cont("RDMC ");
 	if (stat & SYS_ERR_MASK_TDMC)
-		printk("TDMC ");
+		pr_cont("TDMC ");
 	if (stat & SYS_ERR_MASK_ZCP)
-		printk("ZCP ");
+		pr_cont("ZCP ");
 	if (stat & SYS_ERR_MASK_FFLP)
-		printk("FFLP ");
+		pr_cont("FFLP ");
 	if (stat & SYS_ERR_MASK_IPP)
-		printk("IPP ");
+		pr_cont("IPP ");
 	if (stat & SYS_ERR_MASK_MAC)
-		printk("MAC ");
+		pr_cont("MAC ");
 	if (stat & SYS_ERR_MASK_SMX)
-		printk("SMX ");
+		pr_cont("SMX ");
 
-	printk(")\n");
+	pr_cont(")\n");
 }
 
 static int niu_device_error(struct niu *np)
 {
 	u64 stat = nr64(SYS_ERR_STAT);
 
-	dev_err(np->device, PFX "%s: Core device error, stat[%llx]\n",
-		np->dev->name, (unsigned long long) stat);
+	netdev_err(np->dev, "Core device error, stat[%llx]\n",
+		   (unsigned long long)stat);
 
 	niu_log_device_error(np, stat);
 
@@ -4197,8 +4168,8 @@ static void niu_rxchan_intr(struct niu *np, struct rx_ring_info *rp,
 		      RX_DMA_CTL_STAT_RCRTO);
 	nw64(RX_DMA_CTL_STAT(rp->rx_channel), stat_write);
 
-	niudbg(INTR, "%s: rxchan_intr stat[%llx]\n",
-	       np->dev->name, (unsigned long long) stat);
+	netif_printk(np, intr, KERN_DEBUG, np->dev,
+		     "%s() stat[%llx]\n", __func__, (unsigned long long)stat);
 }
 
 static void niu_txchan_intr(struct niu *np, struct tx_ring_info *rp,
@@ -4206,8 +4177,8 @@ static void niu_txchan_intr(struct niu *np, struct tx_ring_info *rp,
 {
 	rp->tx_cs = nr64(TX_CS(rp->tx_channel));
 
-	niudbg(INTR, "%s: txchan_intr cs[%llx]\n",
-	       np->dev->name, (unsigned long long) rp->tx_cs);
+	netif_printk(np, intr, KERN_DEBUG, np->dev,
+		     "%s() cs[%llx]\n", __func__, (unsigned long long)rp->tx_cs);
 }
 
 static void __niu_fastpath_interrupt(struct niu *np, int ldg, u64 v0)
@@ -4265,8 +4236,8 @@ static irqreturn_t niu_interrupt(int irq, void *dev_id)
 	u64 v0, v1, v2;
 
 	if (netif_msg_intr(np))
-		printk(KERN_DEBUG PFX "niu_interrupt() ldg[%p](%d) ",
-		       lp, ldg);
+		printk(KERN_DEBUG KBUILD_MODNAME ": " "%s() ldg[%p](%d)",
+		       __func__, lp, ldg);
 
 	spin_lock_irqsave(&np->lock, flags);
 
@@ -4275,11 +4246,13 @@ static irqreturn_t niu_interrupt(int irq, void *dev_id)
 	v2 = nr64(LDSV2(ldg));
 
 	if (netif_msg_intr(np))
-		printk("v0[%llx] v1[%llx] v2[%llx]\n",
+		pr_cont(" v0[%llx] v1[%llx] v2[%llx]",
 		       (unsigned long long) v0,
 		       (unsigned long long) v1,
 		       (unsigned long long) v2);
 
+	pr_cont("\n");
+
 	if (unlikely(!v0 && !v1 && !v2)) {
 		spin_unlock_irqrestore(&np->lock, flags);
 		return IRQ_NONE;
@@ -4400,8 +4373,8 @@ static int niu_alloc_rx_ring_info(struct niu *np,
 	if (!rp->mbox)
 		return -ENOMEM;
 	if ((unsigned long)rp->mbox & (64UL - 1)) {
-		dev_err(np->device, PFX "%s: Coherent alloc gives misaligned "
-			"RXDMA mailbox %p\n", np->dev->name, rp->mbox);
+		netdev_err(np->dev, "Coherent alloc gives misaligned RXDMA mailbox %p\n",
+			   rp->mbox);
 		return -EINVAL;
 	}
 
@@ -4411,8 +4384,8 @@ static int niu_alloc_rx_ring_info(struct niu *np,
 	if (!rp->rcr)
 		return -ENOMEM;
 	if ((unsigned long)rp->rcr & (64UL - 1)) {
-		dev_err(np->device, PFX "%s: Coherent alloc gives misaligned "
-			"RXDMA RCR table %p\n", np->dev->name, rp->rcr);
+		netdev_err(np->dev, "Coherent alloc gives misaligned RXDMA RCR table %p\n",
+			   rp->rcr);
 		return -EINVAL;
 	}
 	rp->rcr_table_size = MAX_RCR_RING_SIZE;
@@ -4424,8 +4397,8 @@ static int niu_alloc_rx_ring_info(struct niu *np,
 	if (!rp->rbr)
 		return -ENOMEM;
 	if ((unsigned long)rp->rbr & (64UL - 1)) {
-		dev_err(np->device, PFX "%s: Coherent alloc gives misaligned "
-			"RXDMA RBR table %p\n", np->dev->name, rp->rbr);
+		netdev_err(np->dev, "Coherent alloc gives misaligned RXDMA RBR table %p\n",
+			   rp->rbr);
 		return -EINVAL;
 	}
 	rp->rbr_table_size = MAX_RBR_RING_SIZE;
@@ -4458,8 +4431,8 @@ static int niu_alloc_tx_ring_info(struct niu *np,
 	if (!rp->mbox)
 		return -ENOMEM;
 	if ((unsigned long)rp->mbox & (64UL - 1)) {
-		dev_err(np->device, PFX "%s: Coherent alloc gives misaligned "
-			"TXDMA mailbox %p\n", np->dev->name, rp->mbox);
+		netdev_err(np->dev, "Coherent alloc gives misaligned TXDMA mailbox %p\n",
+			   rp->mbox);
 		return -EINVAL;
 	}
 
@@ -4469,8 +4442,8 @@ static int niu_alloc_tx_ring_info(struct niu *np,
 	if (!rp->descr)
 		return -ENOMEM;
 	if ((unsigned long)rp->descr & (64UL - 1)) {
-		dev_err(np->device, PFX "%s: Coherent alloc gives misaligned "
-			"TXDMA descr table %p\n", np->dev->name, rp->descr);
+		netdev_err(np->dev, "Coherent alloc gives misaligned TXDMA descr table %p\n",
+			   rp->descr);
 		return -EINVAL;
 	}
 
@@ -4726,10 +4699,8 @@ static int niu_init_one_tx_channel(struct niu *np, struct tx_ring_info *rp)
 
 	if (rp->descr_dma & ~(TX_RNG_CFIG_STADDR_BASE |
 			      TX_RNG_CFIG_STADDR)) {
-		dev_err(np->device, PFX "%s: TX ring channel %d "
-			"DMA addr (%llx) is not aligned.\n",
-			np->dev->name, channel,
-			(unsigned long long) rp->descr_dma);
+		netdev_err(np->dev, "TX ring channel %d DMA addr (%llx) is not aligned\n",
+			   channel, (unsigned long long)rp->descr_dma);
 		return -EINVAL;
 	}
 
@@ -4746,10 +4717,8 @@ static int niu_init_one_tx_channel(struct niu *np, struct tx_ring_info *rp)
 
 	if (((rp->mbox_dma >> 32) & ~TXDMA_MBH_MBADDR) ||
 	    ((u32)rp->mbox_dma & ~TXDMA_MBL_MBADDR)) {
-		dev_err(np->device, PFX "%s: TX ring channel %d "
-			"MBOX addr (%llx) is has illegal bits.\n",
-			np->dev->name, channel,
-			(unsigned long long) rp->mbox_dma);
+		netdev_err(np->dev, "TX ring channel %d MBOX addr (%llx) has invalid bits\n",
+			    channel, (unsigned long long)rp->mbox_dma);
 		return -EINVAL;
 	}
 	nw64(TXDMA_MBH(channel), rp->mbox_dma >> 32);
@@ -5146,9 +5115,8 @@ static int niu_zcp_read(struct niu *np, int index, u64 *data)
 	err = niu_wait_bits_clear(np, ZCP_RAM_ACC, ZCP_RAM_ACC_BUSY,
 				  1000, 100);
 	if (err) {
-		dev_err(np->device, PFX "%s: ZCP read busy won't clear, "
-			"ZCP_RAM_ACC[%llx]\n", np->dev->name,
-			(unsigned long long) nr64(ZCP_RAM_ACC));
+		netdev_err(np->dev, "ZCP read busy won't clear, ZCP_RAM_ACC[%llx]\n",
+			   (unsigned long long)nr64(ZCP_RAM_ACC));
 		return err;
 	}
 
@@ -5160,9 +5128,8 @@ static int niu_zcp_read(struct niu *np, int index, u64 *data)
 	err = niu_wait_bits_clear(np, ZCP_RAM_ACC, ZCP_RAM_ACC_BUSY,
 				  1000, 100);
 	if (err) {
-		dev_err(np->device, PFX "%s: ZCP read busy2 won't clear, "
-			"ZCP_RAM_ACC[%llx]\n", np->dev->name,
-			(unsigned long long) nr64(ZCP_RAM_ACC));
+		netdev_err(np->dev, "ZCP read busy2 won't clear, ZCP_RAM_ACC[%llx]\n",
+			   (unsigned long long)nr64(ZCP_RAM_ACC));
 		return err;
 	}
 
@@ -5527,8 +5494,7 @@ static int niu_reset_tx_bmac(struct niu *np)
 		udelay(100);
 	}
 	if (limit < 0) {
-		dev_err(np->device, PFX "Port %u TX BMAC would not reset, "
-			"BTXMAC_SW_RST[%llx]\n",
+		dev_err(np->device, "Port %u TX BMAC would not reset, BTXMAC_SW_RST[%llx]\n",
 			np->port,
 			(unsigned long long) nr64_mac(BTXMAC_SW_RST));
 		return -ENODEV;
@@ -5629,12 +5595,11 @@ static int niu_reset_rx_xmac(struct niu *np)
 	while (--limit >= 0) {
 		if (!(nr64_mac(XRXMAC_SW_RST) & (XRXMAC_SW_RST_REG_RS |
 						 XRXMAC_SW_RST_SOFT_RST)))
-		    break;
+			break;
 		udelay(100);
 	}
 	if (limit < 0) {
-		dev_err(np->device, PFX "Port %u RX XMAC would not reset, "
-			"XRXMAC_SW_RST[%llx]\n",
+		dev_err(np->device, "Port %u RX XMAC would not reset, XRXMAC_SW_RST[%llx]\n",
 			np->port,
 			(unsigned long long) nr64_mac(XRXMAC_SW_RST));
 		return -ENODEV;
@@ -5655,8 +5620,7 @@ static int niu_reset_rx_bmac(struct niu *np)
 		udelay(100);
 	}
 	if (limit < 0) {
-		dev_err(np->device, PFX "Port %u RX BMAC would not reset, "
-			"BRXMAC_SW_RST[%llx]\n",
+		dev_err(np->device, "Port %u RX BMAC would not reset, BRXMAC_SW_RST[%llx]\n",
 			np->port,
 			(unsigned long long) nr64_mac(BRXMAC_SW_RST));
 		return -ENODEV;
@@ -5960,11 +5924,9 @@ static void niu_disable_ipp(struct niu *np)
 	}
 	if (limit < 0 &&
 	    (rd != 0 && wr != 1)) {
-		dev_err(np->device, PFX "%s: IPP would not quiesce, "
-			"rd_ptr[%llx] wr_ptr[%llx]\n",
-			np->dev->name,
-			(unsigned long long) nr64_ipp(IPP_DFIFO_RD_PTR),
-			(unsigned long long) nr64_ipp(IPP_DFIFO_WR_PTR));
+		netdev_err(np->dev, "IPP would not quiesce, rd_ptr[%llx] wr_ptr[%llx]\n",
+			   (unsigned long long)nr64_ipp(IPP_DFIFO_RD_PTR),
+			   (unsigned long long)nr64_ipp(IPP_DFIFO_WR_PTR));
 	}
 
 	val = nr64_ipp(IPP_CFIG);
@@ -5981,12 +5943,12 @@ static int niu_init_hw(struct niu *np)
 {
 	int i, err;
 
-	niudbg(IFUP, "%s: Initialize TXC\n", np->dev->name);
+	netif_printk(np, ifup, KERN_DEBUG, np->dev, "Initialize TXC\n");
 	niu_txc_enable_port(np, 1);
 	niu_txc_port_dma_enable(np, 1);
 	niu_txc_set_imask(np, 0);
 
-	niudbg(IFUP, "%s: Initialize TX channels\n", np->dev->name);
+	netif_printk(np, ifup, KERN_DEBUG, np->dev, "Initialize TX channels\n");
 	for (i = 0; i < np->num_tx_rings; i++) {
 		struct tx_ring_info *rp = &np->tx_rings[i];
 
@@ -5995,27 +5957,27 @@ static int niu_init_hw(struct niu *np)
 			return err;
 	}
 
-	niudbg(IFUP, "%s: Initialize RX channels\n", np->dev->name);
+	netif_printk(np, ifup, KERN_DEBUG, np->dev, "Initialize RX channels\n");
 	err = niu_init_rx_channels(np);
 	if (err)
 		goto out_uninit_tx_channels;
 
-	niudbg(IFUP, "%s: Initialize classifier\n", np->dev->name);
+	netif_printk(np, ifup, KERN_DEBUG, np->dev, "Initialize classifier\n");
 	err = niu_init_classifier_hw(np);
 	if (err)
 		goto out_uninit_rx_channels;
 
-	niudbg(IFUP, "%s: Initialize ZCP\n", np->dev->name);
+	netif_printk(np, ifup, KERN_DEBUG, np->dev, "Initialize ZCP\n");
 	err = niu_init_zcp(np);
 	if (err)
 		goto out_uninit_rx_channels;
 
-	niudbg(IFUP, "%s: Initialize IPP\n", np->dev->name);
+	netif_printk(np, ifup, KERN_DEBUG, np->dev, "Initialize IPP\n");
 	err = niu_init_ipp(np);
 	if (err)
 		goto out_uninit_rx_channels;
 
-	niudbg(IFUP, "%s: Initialize MAC\n", np->dev->name);
+	netif_printk(np, ifup, KERN_DEBUG, np->dev, "Initialize MAC\n");
 	err = niu_init_mac(np);
 	if (err)
 		goto out_uninit_ipp;
@@ -6023,16 +5985,16 @@ static int niu_init_hw(struct niu *np)
 	return 0;
 
 out_uninit_ipp:
-	niudbg(IFUP, "%s: Uninit IPP\n", np->dev->name);
+	netif_printk(np, ifup, KERN_DEBUG, np->dev, "Uninit IPP\n");
 	niu_disable_ipp(np);
 
 out_uninit_rx_channels:
-	niudbg(IFUP, "%s: Uninit RX channels\n", np->dev->name);
+	netif_printk(np, ifup, KERN_DEBUG, np->dev, "Uninit RX channels\n");
 	niu_stop_rx_channels(np);
 	niu_reset_rx_channels(np);
 
 out_uninit_tx_channels:
-	niudbg(IFUP, "%s: Uninit TX channels\n", np->dev->name);
+	netif_printk(np, ifup, KERN_DEBUG, np->dev, "Uninit TX channels\n");
 	niu_stop_tx_channels(np);
 	niu_reset_tx_channels(np);
 
@@ -6041,25 +6003,25 @@ out_uninit_tx_channels:
 
 static void niu_stop_hw(struct niu *np)
 {
-	niudbg(IFDOWN, "%s: Disable interrupts\n", np->dev->name);
+	netif_printk(np, ifdown, KERN_DEBUG, np->dev, "Disable interrupts\n");
 	niu_enable_interrupts(np, 0);
 
-	niudbg(IFDOWN, "%s: Disable RX MAC\n", np->dev->name);
+	netif_printk(np, ifdown, KERN_DEBUG, np->dev, "Disable RX MAC\n");
 	niu_enable_rx_mac(np, 0);
 
-	niudbg(IFDOWN, "%s: Disable IPP\n", np->dev->name);
+	netif_printk(np, ifdown, KERN_DEBUG, np->dev, "Disable IPP\n");
 	niu_disable_ipp(np);
 
-	niudbg(IFDOWN, "%s: Stop TX channels\n", np->dev->name);
+	netif_printk(np, ifdown, KERN_DEBUG, np->dev, "Stop TX channels\n");
 	niu_stop_tx_channels(np);
 
-	niudbg(IFDOWN, "%s: Stop RX channels\n", np->dev->name);
+	netif_printk(np, ifdown, KERN_DEBUG, np->dev, "Stop RX channels\n");
 	niu_stop_rx_channels(np);
 
-	niudbg(IFDOWN, "%s: Reset TX channels\n", np->dev->name);
+	netif_printk(np, ifdown, KERN_DEBUG, np->dev, "Reset TX channels\n");
 	niu_reset_tx_channels(np);
 
-	niudbg(IFDOWN, "%s: Reset RX channels\n", np->dev->name);
+	netif_printk(np, ifdown, KERN_DEBUG, np->dev, "Reset RX channels\n");
 	niu_reset_rx_channels(np);
 }
 
@@ -6384,14 +6346,12 @@ static void niu_set_rx_mode(struct net_device *dev)
 		netdev_for_each_uc_addr(ha, dev) {
 			err = niu_set_alt_mac(np, index, ha->addr);
 			if (err)
-				printk(KERN_WARNING PFX "%s: Error %d "
-				       "adding alt mac %d\n",
-				       dev->name, err, index);
+				netdev_warn(dev, "Error %d adding alt mac %d\n",
+					    err, index);
 			err = niu_enable_alt_mac(np, index, 1);
 			if (err)
-				printk(KERN_WARNING PFX "%s: Error %d "
-				       "enabling alt mac %d\n",
-				       dev->name, err, index);
+				netdev_warn(dev, "Error %d enabling alt mac %d\n",
+					    err, index);
 
 			index++;
 		}
@@ -6404,9 +6364,8 @@ static void niu_set_rx_mode(struct net_device *dev)
 		for (i = alt_start; i < niu_num_alt_addr(np); i++) {
 			err = niu_enable_alt_mac(np, i, 0);
 			if (err)
-				printk(KERN_WARNING PFX "%s: Error %d "
-				       "disabling alt mac %d\n",
-				       dev->name, err, i);
+				netdev_warn(dev, "Error %d disabling alt mac %d\n",
+					    err, i);
 		}
 	}
 	if (dev->flags & IFF_ALLMULTI) {
@@ -6570,7 +6529,7 @@ static void niu_tx_timeout(struct net_device *dev)
 {
 	struct niu *np = netdev_priv(dev);
 
-	dev_err(np->device, PFX "%s: Transmit timed out, resetting\n",
+	dev_err(np->device, "%s: Transmit timed out, resetting\n",
 		dev->name);
 
 	schedule_work(&np->reset_task);
@@ -6672,8 +6631,7 @@ static netdev_tx_t niu_start_xmit(struct sk_buff *skb,
 
 	if (niu_tx_avail(rp) <= (skb_shinfo(skb)->nr_frags + 1)) {
 		netif_tx_stop_queue(txq);
-		dev_err(np->device, PFX "%s: BUG! Tx ring full when "
-			"queue awake!\n", dev->name);
+		dev_err(np->device, "%s: BUG! Tx ring full when queue awake!\n", dev->name);
 		rp->tx_errors++;
 		return NETDEV_TX_BUSY;
 	}
@@ -7237,8 +7195,8 @@ static int niu_get_ethtool_tcam_entry(struct niu *np,
 
 	tp = &parent->tcam[idx];
 	if (!tp->valid) {
-		pr_info(PFX "niu%d: %s entry [%d] invalid for idx[%d]\n",
-		parent->index, np->dev->name, (u16)nfc->fs.location, idx);
+		netdev_info(np->dev, "niu%d: entry [%d] invalid for idx[%d]\n",
+			    parent->index, (u16)nfc->fs.location, idx);
 		return -EINVAL;
 	}
 
@@ -7248,8 +7206,8 @@ static int niu_get_ethtool_tcam_entry(struct niu *np,
 	ret = niu_class_to_ethflow(class, &fsp->flow_type);
 
 	if (ret < 0) {
-		pr_info(PFX "niu%d: %s niu_class_to_ethflow failed\n",
-		parent->index, np->dev->name);
+		netdev_info(np->dev, "niu%d: niu_class_to_ethflow failed\n",
+			    parent->index);
 		ret = -EINVAL;
 		goto out;
 	}
@@ -7332,9 +7290,8 @@ static int niu_get_ethtool_tcam_all(struct niu *np,
 
 	if (n_entries != cnt) {
 		/* print warning, this should not happen */
-		pr_info(PFX "niu%d: %s In niu_get_ethtool_tcam_all, "
-			"n_entries[%d] != cnt[%d]!!!\n\n",
-			np->parent->index, np->dev->name, n_entries, cnt);
+		netdev_info(np->dev, "niu%d: In %s(): n_entries[%d] != cnt[%d]!!!\n",
+			    np->parent->index, __func__, n_entries, cnt);
 	}
 
 	return 0;
@@ -7561,9 +7518,8 @@ static int niu_add_ethtool_tcam_entry(struct niu *np,
 			}
 		}
 		if (!add_usr_cls) {
-			pr_info(PFX "niu%d: %s niu_add_ethtool_tcam_entry: "
-				"Could not find/insert class for pid %d\n",
-				parent->index, np->dev->name, uspec->proto);
+			netdev_info(np->dev, "niu%d: %s(): Could not find/insert class for pid %d\n",
+				    parent->index, __func__, uspec->proto);
 			ret = -EINVAL;
 			goto out;
 		}
@@ -7596,9 +7552,8 @@ static int niu_add_ethtool_tcam_entry(struct niu *np,
 	case AH_V6_FLOW:
 	case ESP_V6_FLOW:
 		/* Not yet implemented */
-		pr_info(PFX "niu%d: %s In niu_add_ethtool_tcam_entry: "
-			"flow %d for IPv6 not implemented\n\n",
-			parent->index, np->dev->name, fsp->flow_type);
+		netdev_info(np->dev, "niu%d: In %s(): flow %d for IPv6 not implemented\n",
+			    parent->index, __func__, fsp->flow_type);
 		ret = -EINVAL;
 		goto out;
 	case IP_USER_FLOW:
@@ -7607,17 +7562,15 @@ static int niu_add_ethtool_tcam_entry(struct niu *np,
 						   class);
 		} else {
 			/* Not yet implemented */
-			pr_info(PFX "niu%d: %s In niu_add_ethtool_tcam_entry: "
-			"usr flow for IPv6 not implemented\n\n",
-			parent->index, np->dev->name);
+			netdev_info(np->dev, "niu%d: In %s(): usr flow for IPv6 not implemented\n",
+				    parent->index, __func__);
 			ret = -EINVAL;
 			goto out;
 		}
 		break;
 	default:
-		pr_info(PFX "niu%d: %s In niu_add_ethtool_tcam_entry: "
-			"Unknown flow type %d\n\n",
-			parent->index, np->dev->name, fsp->flow_type);
+		netdev_info(np->dev, "niu%d: In %s(): Unknown flow type %d\n",
+			    parent->index, __func__, fsp->flow_type);
 		ret = -EINVAL;
 		goto out;
 	}
@@ -7627,10 +7580,9 @@ static int niu_add_ethtool_tcam_entry(struct niu *np,
 		tp->assoc_data = TCAM_ASSOCDATA_DISC;
 	} else {
 		if (fsp->ring_cookie >= np->num_rx_rings) {
-			pr_info(PFX "niu%d: %s In niu_add_ethtool_tcam_entry: "
-				"Invalid RX ring %lld\n\n",
-				parent->index, np->dev->name,
-				(long long) fsp->ring_cookie);
+			netdev_info(np->dev, "niu%d: In %s(): Invalid RX ring %lld\n",
+				    parent->index, __func__,
+				    (long long)fsp->ring_cookie);
 			ret = -EINVAL;
 			goto out;
 		}
@@ -7699,10 +7651,9 @@ static int niu_del_ethtool_tcam_entry(struct niu *np, u32 loc)
 			}
 		}
 		if (i == NIU_L3_PROG_CLS) {
-			pr_info(PFX "niu%d: %s In niu_del_ethtool_tcam_entry,"
-				"Usr class 0x%llx not found \n",
-				parent->index, np->dev->name,
-				(unsigned long long) class);
+			netdev_info(np->dev, "niu%d: In %s(): Usr class 0x%llx not found\n",
+				    parent->index, __func__,
+				    (unsigned long long)class);
 			ret = -EINVAL;
 			goto out;
 		}
@@ -8001,9 +7952,7 @@ static int niu_ldg_assign_ldn(struct niu *np, struct niu_parent *parent,
 		 * won't get any interrupts and that's painful to debug.
 		 */
 		if (nr64(LDG_NUM(ldn)) != ldg) {
-			dev_err(np->device, PFX "Port %u, mis-matched "
-				"LDG assignment "
-				"for ldn %d, should be %d is %llu\n",
+			dev_err(np->device, "Port %u, mis-matched LDG assignment for ldn %d, should be %d is %llu\n",
 				np->port, ldn, ldg,
 				(unsigned long long) nr64(LDG_NUM(ldn)));
 			return -EINVAL;
@@ -8056,7 +8005,7 @@ static int __devinit niu_pci_eeprom_read(struct niu *np, u32 addr)
 			break;
 	} while (limit--);
 	if (!(frame & ESPC_PIO_STAT_READ_END)) {
-		dev_err(np->device, PFX "EEPROM read timeout frame[%llx]\n",
+		dev_err(np->device, "EEPROM read timeout frame[%llx]\n",
 			(unsigned long long) frame);
 		return -ENODEV;
 	}
@@ -8071,7 +8020,7 @@ static int __devinit niu_pci_eeprom_read(struct niu *np, u32 addr)
 			break;
 	} while (limit--);
 	if (!(frame & ESPC_PIO_STAT_READ_END)) {
-		dev_err(np->device, PFX "EEPROM read timeout frame[%llx]\n",
+		dev_err(np->device, "EEPROM read timeout frame[%llx]\n",
 			(unsigned long long) frame);
 		return -ENODEV;
 	}
@@ -8152,8 +8101,9 @@ static void __devinit niu_vpd_parse_version(struct niu *np)
 	s += i + 5;
 	sscanf(s, "%d.%d", &vpd->fcode_major, &vpd->fcode_minor);
 
-	niudbg(PROBE, "VPD_SCAN: FCODE major(%d) minor(%d)\n",
-	       vpd->fcode_major, vpd->fcode_minor);
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "VPD_SCAN: FCODE major(%d) minor(%d)\n",
+		     vpd->fcode_major, vpd->fcode_minor);
 	if (vpd->fcode_major > NIU_VPD_MIN_MAJOR ||
 	    (vpd->fcode_major == NIU_VPD_MIN_MAJOR &&
 	     vpd->fcode_minor >= NIU_VPD_MIN_MINOR))
@@ -8173,8 +8123,8 @@ static int __devinit niu_pci_vpd_scan_props(struct niu *np,
 #define FOUND_MASK_PHY		0x00000020
 #define FOUND_MASK_ALL		0x0000003f
 
-	niudbg(PROBE, "VPD_SCAN: start[%x] end[%x]\n",
-	       start, end);
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "VPD_SCAN: start[%x] end[%x]\n", start, end);
 	while (start < end) {
 		int len, err, instance, type, prop_len;
 		char namebuf[64];
@@ -8228,8 +8178,7 @@ static int __devinit niu_pci_vpd_scan_props(struct niu *np,
 		}
 
 		if (max_len && prop_len > max_len) {
-			dev_err(np->device, PFX "Property '%s' length (%d) is "
-				"too long.\n", namebuf, prop_len);
+			dev_err(np->device, "Property '%s' length (%d) is too long\n", namebuf, prop_len);
 			return -EINVAL;
 		}
 
@@ -8237,8 +8186,9 @@ static int __devinit niu_pci_vpd_scan_props(struct niu *np,
 			u32 off = start + 5 + err;
 			int i;
 
-			niudbg(PROBE, "VPD_SCAN: Reading in property [%s] "
-			       "len[%d]\n", namebuf, prop_len);
+			netif_printk(np, probe, KERN_DEBUG, np->dev,
+				     "VPD_SCAN: Reading in property [%s] len[%d]\n",
+				     namebuf, prop_len);
 			for (i = 0; i < prop_len; i++)
 				*prop_buf++ = niu_pci_eeprom_read(np, off + i);
 		}
@@ -8402,8 +8352,7 @@ static void __devinit niu_pci_vpd_validate(struct niu *np)
 	u8 val8;
 
 	if (!is_valid_ether_addr(&vpd->local_mac[0])) {
-		dev_err(np->device, PFX "VPD MAC invalid, "
-			"falling back to SPROM.\n");
+		dev_err(np->device, "VPD MAC invalid, falling back to SPROM\n");
 
 		np->flags &= ~NIU_FLAGS_VPD_VALID;
 		return;
@@ -8420,14 +8369,14 @@ static void __devinit niu_pci_vpd_validate(struct niu *np)
 			np->flags &= ~NIU_FLAGS_10G;
 		}
 		if (np->flags & NIU_FLAGS_10G)
-			 np->mac_xcvr = MAC_XCVR_XPCS;
+			np->mac_xcvr = MAC_XCVR_XPCS;
 	} else if (!strcmp(np->vpd.model, NIU_FOXXY_MDL_STR)) {
 		np->flags |= (NIU_FLAGS_10G | NIU_FLAGS_FIBER |
 			      NIU_FLAGS_HOTPLUG_PHY);
 	} else if (niu_phy_type_prop_decode(np, np->vpd.phy_type)) {
-		dev_err(np->device, PFX "Illegal phy string [%s].\n",
+		dev_err(np->device, "Illegal phy string [%s]\n",
 			np->vpd.phy_type);
-		dev_err(np->device, PFX "Falling back to SPROM.\n");
+		dev_err(np->device, "Falling back to SPROM\n");
 		np->flags &= ~NIU_FLAGS_VPD_VALID;
 		return;
 	}
@@ -8455,7 +8404,8 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 
 	np->eeprom_len = len;
 
-	niudbg(PROBE, "SPROM: Image size %llu\n", (unsigned long long) val);
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "SPROM: Image size %llu\n", (unsigned long long)val);
 
 	sum = 0;
 	for (i = 0; i < len; i++) {
@@ -8465,10 +8415,10 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 		sum += (val >> 16) & 0xff;
 		sum += (val >> 24) & 0xff;
 	}
-	niudbg(PROBE, "SPROM: Checksum %x\n", (int)(sum & 0xff));
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "SPROM: Checksum %x\n", (int)(sum & 0xff));
 	if ((sum & 0xff) != 0xab) {
-		dev_err(np->device, PFX "Bad SPROM checksum "
-			"(%x, should be 0xab)\n", (int) (sum & 0xff));
+		dev_err(np->device, "Bad SPROM checksum (%x, should be 0xab)\n", (int)(sum & 0xff));
 		return -EINVAL;
 	}
 
@@ -8491,11 +8441,12 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 			ESPC_PHY_TYPE_PORT3_SHIFT;
 		break;
 	default:
-		dev_err(np->device, PFX "Bogus port number %u\n",
+		dev_err(np->device, "Bogus port number %u\n",
 			np->port);
 		return -EINVAL;
 	}
-	niudbg(PROBE, "SPROM: PHY type %x\n", val8);
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "SPROM: PHY type %x\n", val8);
 
 	switch (val8) {
 	case ESPC_PHY_TYPE_1G_COPPER:
@@ -8527,30 +8478,27 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 		break;
 
 	default:
-		dev_err(np->device, PFX "Bogus SPROM phy type %u\n", val8);
+		dev_err(np->device, "Bogus SPROM phy type %u\n", val8);
 		return -EINVAL;
 	}
 
 	val = nr64(ESPC_MAC_ADDR0);
-	niudbg(PROBE, "SPROM: MAC_ADDR0[%08llx]\n",
-	       (unsigned long long) val);
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "SPROM: MAC_ADDR0[%08llx]\n", (unsigned long long)val);
 	dev->perm_addr[0] = (val >>  0) & 0xff;
 	dev->perm_addr[1] = (val >>  8) & 0xff;
 	dev->perm_addr[2] = (val >> 16) & 0xff;
 	dev->perm_addr[3] = (val >> 24) & 0xff;
 
 	val = nr64(ESPC_MAC_ADDR1);
-	niudbg(PROBE, "SPROM: MAC_ADDR1[%08llx]\n",
-	       (unsigned long long) val);
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "SPROM: MAC_ADDR1[%08llx]\n", (unsigned long long)val);
 	dev->perm_addr[4] = (val >>  0) & 0xff;
 	dev->perm_addr[5] = (val >>  8) & 0xff;
 
 	if (!is_valid_ether_addr(&dev->perm_addr[0])) {
-		dev_err(np->device, PFX "SPROM MAC address invalid\n");
-		dev_err(np->device, PFX "[ \n");
-		for (i = 0; i < 6; i++)
-			printk("%02x ", dev->perm_addr[i]);
-		printk("]\n");
+		dev_err(np->device, "SPROM MAC address invalid [ %pM ]\n",
+			dev->perm_addr);
 		return -EINVAL;
 	}
 
@@ -8562,8 +8510,8 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 	memcpy(dev->dev_addr, dev->perm_addr, dev->addr_len);
 
 	val = nr64(ESPC_MOD_STR_LEN);
-	niudbg(PROBE, "SPROM: MOD_STR_LEN[%llu]\n",
-	       (unsigned long long) val);
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "SPROM: MOD_STR_LEN[%llu]\n", (unsigned long long)val);
 	if (val >= 8 * 4)
 		return -EINVAL;
 
@@ -8578,8 +8526,8 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 	np->vpd.model[val] = '\0';
 
 	val = nr64(ESPC_BD_MOD_STR_LEN);
-	niudbg(PROBE, "SPROM: BD_MOD_STR_LEN[%llu]\n",
-	       (unsigned long long) val);
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "SPROM: BD_MOD_STR_LEN[%llu]\n", (unsigned long long)val);
 	if (val >= 4 * 4)
 		return -EINVAL;
 
@@ -8595,8 +8543,8 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 
 	np->vpd.mac_num =
 		nr64(ESPC_NUM_PORTS_MACS) & ESPC_NUM_PORTS_MACS_VAL;
-	niudbg(PROBE, "SPROM: NUM_PORTS_MACS[%d]\n",
-	       np->vpd.mac_num);
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "SPROM: NUM_PORTS_MACS[%d]\n", np->vpd.mac_num);
 
 	return 0;
 }
@@ -8629,8 +8577,9 @@ static int __devinit niu_get_and_validate_port(struct niu *np)
 		}
 	}
 
-	niudbg(PROBE, "niu_get_and_validate_port: port[%d] num_ports[%d]\n",
-	       np->port, parent->num_ports);
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "%s() port[%d] num_ports[%d]\n",
+		     __func__, np->port, parent->num_ports);
 	if (np->port >= parent->num_ports)
 		return -ENODEV;
 
@@ -8659,14 +8608,12 @@ static int __devinit phy_record(struct niu_parent *parent,
 
 	pr_info("niu%d: Found PHY %08x type %s at phy_port %u\n",
 		parent->index, id,
-		(type == PHY_TYPE_PMA_PMD ?
-		 "PMA/PMD" :
-		 (type == PHY_TYPE_PCS ?
-		  "PCS" : "MII")),
+		type == PHY_TYPE_PMA_PMD ? "PMA/PMD" :
+		type == PHY_TYPE_PCS ? "PCS" : "MII",
 		phy_port);
 
 	if (p->cur[type] >= NIU_MAX_PORTS) {
-		printk(KERN_ERR PFX "Too many PHY ports.\n");
+		pr_err("Too many PHY ports\n");
 		return -EINVAL;
 	}
 	idx = p->cur[type];
@@ -8727,8 +8674,7 @@ static void __devinit niu_n2_divide_channels(struct niu_parent *parent)
 		parent->rxchan_per_port[i] = (16 / num_ports);
 		parent->txchan_per_port[i] = (16 / num_ports);
 
-		pr_info(PFX "niu%d: Port %u [%u RX chans] "
-			"[%u TX chans]\n",
+		pr_info("niu%d: Port %u [%u RX chans] [%u TX chans]\n",
 			parent->index, i,
 			parent->rxchan_per_port[i],
 			parent->txchan_per_port[i]);
@@ -8771,8 +8717,7 @@ static void __devinit niu_divide_channels(struct niu_parent *parent,
 			parent->rxchan_per_port[i] = rx_chans_per_1g;
 			parent->txchan_per_port[i] = tx_chans_per_1g;
 		}
-		pr_info(PFX "niu%d: Port %u [%u RX chans] "
-			"[%u TX chans]\n",
+		pr_info("niu%d: Port %u [%u RX chans] [%u TX chans]\n",
 			parent->index, i,
 			parent->rxchan_per_port[i],
 			parent->txchan_per_port[i]);
@@ -8781,23 +8726,20 @@ static void __devinit niu_divide_channels(struct niu_parent *parent,
 	}
 
 	if (tot_rx > NIU_NUM_RXCHAN) {
-		printk(KERN_ERR PFX "niu%d: Too many RX channels (%d), "
-		       "resetting to one per port.\n",
+		pr_err("niu%d: Too many RX channels (%d), resetting to one per port\n",
 		       parent->index, tot_rx);
 		for (i = 0; i < num_ports; i++)
 			parent->rxchan_per_port[i] = 1;
 	}
 	if (tot_tx > NIU_NUM_TXCHAN) {
-		printk(KERN_ERR PFX "niu%d: Too many TX channels (%d), "
-		       "resetting to one per port.\n",
+		pr_err("niu%d: Too many TX channels (%d), resetting to one per port\n",
 		       parent->index, tot_tx);
 		for (i = 0; i < num_ports; i++)
 			parent->txchan_per_port[i] = 1;
 	}
 	if (tot_rx < NIU_NUM_RXCHAN || tot_tx < NIU_NUM_TXCHAN) {
-		printk(KERN_WARNING PFX "niu%d: Driver bug, wasted channels, "
-		       "RX[%d] TX[%d]\n",
-		       parent->index, tot_rx, tot_tx);
+		pr_warning("niu%d: Driver bug, wasted channels, RX[%d] TX[%d]\n",
+			   parent->index, tot_rx, tot_tx);
 	}
 }
 
@@ -8825,18 +8767,18 @@ static void __devinit niu_divide_rdc_groups(struct niu_parent *parent,
 			struct rdc_table *rt = &tp->tables[grp];
 			int slot;
 
-			pr_info(PFX "niu%d: Port %d RDC tbl(%d) [ ",
+			pr_info("niu%d: Port %d RDC tbl(%d) [ ",
 				parent->index, i, tp->first_table_num + grp);
 			for (slot = 0; slot < NIU_RDC_TABLE_SLOTS; slot++) {
 				rt->rxdma_channel[slot] =
 					rdc_channel_base + this_channel_offset;
 
-				printk("%d ", rt->rxdma_channel[slot]);
+				pr_cont("%d ", rt->rxdma_channel[slot]);
 
 				if (++this_channel_offset == num_channels)
 					this_channel_offset = 0;
 			}
-			printk("]\n");
+			pr_cont("]\n");
 		}
 
 		parent->rdc_default[i] = rdc_channel_base;
@@ -8996,8 +8938,7 @@ static int __devinit walk_phys(struct niu *np, struct niu_parent *parent)
 			break;
 
 		default:
-			printk(KERN_ERR PFX "Unsupported port config "
-			       "10G[%d] 1G[%d]\n",
+			pr_err("Unsupported port config 10G[%d] 1G[%d]\n",
 			       num_10g, num_1g);
 			return -EINVAL;
 		}
@@ -9015,8 +8956,7 @@ static int __devinit walk_phys(struct niu *np, struct niu_parent *parent)
 	return 0;
 
 unknown_vg_1g_port:
-	printk(KERN_ERR PFX "Cannot identify platform type, 1gport=%d\n",
-	       lowest_1g);
+	pr_err("Cannot identify platform type, 1gport=%d\n", lowest_1g);
 	return -EINVAL;
 }
 
@@ -9025,8 +8965,8 @@ static int __devinit niu_probe_ports(struct niu *np)
 	struct niu_parent *parent = np->parent;
 	int err, i;
 
-	niudbg(PROBE, "niu_probe_ports(): port_phy[%08x]\n",
-	       parent->port_phy);
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "%s() port_phy[%08x]\n", __func__, parent->port_phy);
 
 	if (parent->port_phy == PORT_PHY_UNKNOWN) {
 		err = walk_phys(np, parent);
@@ -9048,8 +8988,9 @@ static int __devinit niu_classifier_swstate_init(struct niu *np)
 {
 	struct niu_classifier *cp = &np->clas;
 
-	niudbg(PROBE, "niu_classifier_swstate_init: num_tcam(%d)\n",
-	       np->parent->tcam_num_entries);
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "%s() num_tcam(%d)\n",
+		     __func__, np->parent->tcam_num_entries);
 
 	cp->tcam_top = (u16) np->port;
 	cp->tcam_sz = np->parent->tcam_num_entries / np->parent->num_ports;
@@ -9116,8 +9057,7 @@ static int __devinit niu_init_mac_ipp_pcs_base(struct niu *np)
 		break;
 
 	default:
-		dev_err(np->device, PFX "Port %u is invalid, cannot "
-			"compute MAC block offset.\n", np->port);
+		dev_err(np->device, "Port %u is invalid, cannot compute MAC block offset\n", np->port);
 		return -EINVAL;
 	}
 
@@ -9327,9 +9267,8 @@ static int __devinit niu_get_of_props(struct niu *np)
 
 	phy_type = of_get_property(dp, "phy-type", &prop_len);
 	if (!phy_type) {
-		dev_err(np->device, PFX "%s: OF node lacks "
-			"phy-type property\n",
-			dp->full_name);
+		netdev_err(dev, "%s: OF node lacks phy-type property\n",
+			   dp->full_name);
 		return -EINVAL;
 	}
 
@@ -9339,34 +9278,26 @@ static int __devinit niu_get_of_props(struct niu *np)
 	strcpy(np->vpd.phy_type, phy_type);
 
 	if (niu_phy_type_prop_decode(np, np->vpd.phy_type)) {
-		dev_err(np->device, PFX "%s: Illegal phy string [%s].\n",
-			dp->full_name, np->vpd.phy_type);
+		netdev_err(dev, "%s: Illegal phy string [%s]\n",
+			   dp->full_name, np->vpd.phy_type);
 		return -EINVAL;
 	}
 
 	mac_addr = of_get_property(dp, "local-mac-address", &prop_len);
 	if (!mac_addr) {
-		dev_err(np->device, PFX "%s: OF node lacks "
-			"local-mac-address property\n",
-			dp->full_name);
+		netdev_err(dev, "%s: OF node lacks local-mac-address property\n",
+			   dp->full_name);
 		return -EINVAL;
 	}
 	if (prop_len != dev->addr_len) {
-		dev_err(np->device, PFX "%s: OF MAC address prop len (%d) "
-			"is wrong.\n",
-			dp->full_name, prop_len);
+		netdev_err(dev, "%s: OF MAC address prop len (%d) is wrong\n",
+			   dp->full_name, prop_len);
 	}
 	memcpy(dev->perm_addr, mac_addr, dev->addr_len);
 	if (!is_valid_ether_addr(&dev->perm_addr[0])) {
-		int i;
-
-		dev_err(np->device, PFX "%s: OF MAC address is invalid\n",
-			dp->full_name);
-		dev_err(np->device, PFX "%s: [ \n",
-			dp->full_name);
-		for (i = 0; i < 6; i++)
-			printk("%02x ", dev->perm_addr[i]);
-		printk("]\n");
+		netdev_err(dev, "%s: OF MAC address is invalid\n",
+			   dp->full_name);
+		netdev_err(dev, "%s: [ %pM ]\n", dp->full_name, dev->perm_addr);
 		return -EINVAL;
 	}
 
@@ -9414,8 +9345,8 @@ static int __devinit niu_get_invariants(struct niu *np)
 
 		nw64(ESPC_PIO_EN, ESPC_PIO_EN_ENABLE);
 		offset = niu_pci_vpd_offset(np);
-		niudbg(PROBE, "niu_get_invariants: VPD offset [%08x]\n",
-		       offset);
+		netif_printk(np, probe, KERN_DEBUG, np->dev,
+			     "%s() VPD offset [%08x]\n", __func__, offset);
 		if (offset)
 			niu_pci_vpd_fetch(np, offset);
 		nw64(ESPC_PIO_EN, 0);
@@ -9575,7 +9506,8 @@ static struct niu_parent * __devinit niu_new_parent(struct niu *np,
 	struct niu_parent *p;
 	int i;
 
-	niudbg(PROBE, "niu_new_parent: Creating new parent.\n");
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "%s() Creating new parent\n", __func__);
 
 	plat_dev = platform_device_register_simple("niu", niu_parent_index,
 						   NULL, 0);
@@ -9641,8 +9573,9 @@ static struct niu_parent * __devinit niu_get_parent(struct niu *np,
 	struct niu_parent *p, *tmp;
 	int port = np->port;
 
-	niudbg(PROBE, "niu_get_parent: platform_type[%u] port[%u]\n",
-	       ptype, port);
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "%s() platform_type[%u] port[%u]\n",
+		     __func__, ptype, port);
 
 	mutex_lock(&niu_parent_lock);
 	p = NULL;
@@ -9681,7 +9614,8 @@ static void niu_put_parent(struct niu *np)
 
 	BUG_ON(!p || p->ports[port] != np);
 
-	niudbg(PROBE, "niu_put_parent: port[%u]\n", port);
+	netif_printk(np, probe, KERN_DEBUG, np->dev,
+		     "%s() port[%u]\n", __func__, port);
 
 	sprintf(port_name, "port%d", port);
 
@@ -9772,7 +9706,7 @@ static struct net_device * __devinit niu_alloc_and_init(
 
 	dev = alloc_etherdev_mq(sizeof(struct niu), NIU_NUM_TXCHAN);
 	if (!dev) {
-		dev_err(gen_dev, PFX "Etherdev alloc failed, aborting.\n");
+		dev_err(gen_dev, "Etherdev alloc failed, aborting\n");
 		return NULL;
 	}
 
@@ -9858,30 +9792,26 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		dev_err(&pdev->dev, PFX "Cannot enable PCI device, "
-			"aborting.\n");
+		dev_err(&pdev->dev, "Cannot enable PCI device, aborting\n");
 		return err;
 	}
 
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM) ||
 	    !(pci_resource_flags(pdev, 2) & IORESOURCE_MEM)) {
-		dev_err(&pdev->dev, PFX "Cannot find proper PCI device "
-			"base addresses, aborting.\n");
+		dev_err(&pdev->dev, "Cannot find proper PCI device base addresses, aborting\n");
 		err = -ENODEV;
 		goto err_out_disable_pdev;
 	}
 
 	err = pci_request_regions(pdev, DRV_MODULE_NAME);
 	if (err) {
-		dev_err(&pdev->dev, PFX "Cannot obtain PCI resources, "
-			"aborting.\n");
+		dev_err(&pdev->dev, "Cannot obtain PCI resources, aborting\n");
 		goto err_out_disable_pdev;
 	}
 
 	pos = pci_find_capability(pdev, PCI_CAP_ID_EXP);
 	if (pos <= 0) {
-		dev_err(&pdev->dev, PFX "Cannot find PCI Express capability, "
-			"aborting.\n");
+		dev_err(&pdev->dev, "Cannot find PCI Express capability, aborting\n");
 		goto err_out_free_res;
 	}
 
@@ -9920,17 +9850,14 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 		dev->features |= NETIF_F_HIGHDMA;
 		err = pci_set_consistent_dma_mask(pdev, dma_mask);
 		if (err) {
-			dev_err(&pdev->dev, PFX "Unable to obtain 44 bit "
-				"DMA for consistent allocations, "
-				"aborting.\n");
+			dev_err(&pdev->dev, "Unable to obtain 44 bit DMA for consistent allocations, aborting\n");
 			goto err_out_release_parent;
 		}
 	}
 	if (err || dma_mask == DMA_BIT_MASK(32)) {
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
-			dev_err(&pdev->dev, PFX "No usable DMA configuration, "
-				"aborting.\n");
+			dev_err(&pdev->dev, "No usable DMA configuration, aborting\n");
 			goto err_out_release_parent;
 		}
 	}
@@ -9939,8 +9866,7 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 
 	np->regs = pci_ioremap_bar(pdev, 0);
 	if (!np->regs) {
-		dev_err(&pdev->dev, PFX "Cannot map device registers, "
-			"aborting.\n");
+		dev_err(&pdev->dev, "Cannot map device registers, aborting\n");
 		err = -ENOMEM;
 		goto err_out_release_parent;
 	}
@@ -9955,15 +9881,13 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 	err = niu_get_invariants(np);
 	if (err) {
 		if (err != -ENODEV)
-			dev_err(&pdev->dev, PFX "Problem fetching invariants "
-				"of chip, aborting.\n");
+			dev_err(&pdev->dev, "Problem fetching invariants of chip, aborting\n");
 		goto err_out_iounmap;
 	}
 
 	err = register_netdev(dev);
 	if (err) {
-		dev_err(&pdev->dev, PFX "Cannot register net device, "
-			"aborting.\n");
+		dev_err(&pdev->dev, "Cannot register net device, aborting\n");
 		goto err_out_iounmap;
 	}
 
@@ -10157,7 +10081,7 @@ static int __devinit niu_of_probe(struct of_device *op,
 
 	reg = of_get_property(op->node, "reg", NULL);
 	if (!reg) {
-		dev_err(&op->dev, PFX "%s: No 'reg' property, aborting.\n",
+		dev_err(&op->dev, "%s: No 'reg' property, aborting\n",
 			op->node->full_name);
 		return -ENODEV;
 	}
@@ -10186,8 +10110,7 @@ static int __devinit niu_of_probe(struct of_device *op,
 			      resource_size(&op->resource[1]),
 			      "niu regs");
 	if (!np->regs) {
-		dev_err(&op->dev, PFX "Cannot map device registers, "
-			"aborting.\n");
+		dev_err(&op->dev, "Cannot map device registers, aborting\n");
 		err = -ENOMEM;
 		goto err_out_release_parent;
 	}
@@ -10196,8 +10119,7 @@ static int __devinit niu_of_probe(struct of_device *op,
 				    resource_size(&op->resource[2]),
 				    "niu vregs-1");
 	if (!np->vir_regs_1) {
-		dev_err(&op->dev, PFX "Cannot map device vir registers 1, "
-			"aborting.\n");
+		dev_err(&op->dev, "Cannot map device vir registers 1, aborting\n");
 		err = -ENOMEM;
 		goto err_out_iounmap;
 	}
@@ -10206,8 +10128,7 @@ static int __devinit niu_of_probe(struct of_device *op,
 				    resource_size(&op->resource[3]),
 				    "niu vregs-2");
 	if (!np->vir_regs_2) {
-		dev_err(&op->dev, PFX "Cannot map device vir registers 2, "
-			"aborting.\n");
+		dev_err(&op->dev, "Cannot map device vir registers 2, aborting\n");
 		err = -ENOMEM;
 		goto err_out_iounmap;
 	}
@@ -10217,15 +10138,13 @@ static int __devinit niu_of_probe(struct of_device *op,
 	err = niu_get_invariants(np);
 	if (err) {
 		if (err != -ENODEV)
-			dev_err(&op->dev, PFX "Problem fetching invariants "
-				"of chip, aborting.\n");
+			dev_err(&op->dev, "Problem fetching invariants of chip, aborting\n");
 		goto err_out_iounmap;
 	}
 
 	err = register_netdev(dev);
 	if (err) {
-		dev_err(&op->dev, PFX "Cannot register net device, "
-			"aborting.\n");
+		dev_err(&op->dev, "Cannot register net device, aborting\n");
 		goto err_out_iounmap;
 	}
 


