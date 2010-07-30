From: Joe Perches <joe@perches.com>
Subject: [PATCH V2 net-next 2/3] drivers/net/bfin_mac.c: Use pr_<level>,
 netdev_<level>
Date: Thu, 29 Jul 2010 18:44:37 -0700
Message-ID: <1280454277.21777.3.camel@Joe-Laptop.home>
References: <cover.1280447281.git.joe@perches.com>
	 <61ca890fdbff3397e15328685ba6d86eaabf8fec.1280447281.git.joe@perches.com>
	 <AANLkTi=jTj7g7STZCTYYBsw5zmij3jmEedBoEnZE4TgW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Hennerich <michael.hennerich@analog.com>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=jTj7g7STZCTYYBsw5zmij3jmEedBoEnZE4TgW@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add and use pr_fmt, pr_<level> and netdev_<level>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bfin_mac.c |   64 +++++++++++++++++++++++------------------------
 1 files changed, 31 insertions(+), 33 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 0b032a5..7543b07 100644
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
@@ -195,8 +197,7 @@ static int desc_list_init(void)
 		/* allocate a new skb for next time receive */
 		new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
 		if (!new_skb) {
-			printk(KERN_NOTICE DRV_NAME
-			       ": init: low on mem - packet dropped\n");
+			pr_notice("init: low on mem - packet dropped\n");
 			goto init_error;
 		}
 		skb_reserve(new_skb, NET_IP_ALIGN);
@@ -247,7 +248,7 @@ static int desc_list_init(void)
 
 init_error:
 	desc_list_free();
-	printk(KERN_ERR DRV_NAME ": kmalloc failed\n");
+	pr_err("kmalloc failed\n");
 	return -ENOMEM;
 }
 
@@ -264,12 +265,11 @@ static int bfin_mdio_poll(void)
 
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
@@ -357,9 +357,9 @@ static void bfin_mac_adjust_link(struct net_device *dev)
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
@@ -383,7 +383,7 @@ static void bfin_mac_adjust_link(struct net_device *dev)
 	if (new_state) {
 		u32 opmode = bfin_read_EMAC_OPMODE();
 		phy_print_status(phydev);
-		pr_debug("EMAC_OPMODE = 0x%08x\n", opmode);
+		netdev_dbg(dev, "EMAC_OPMODE = 0x%08x\n", opmode);
 	}
 
 	spin_unlock_irqrestore(&lp->lock, flags);
@@ -424,8 +424,7 @@ static int mii_probe(struct net_device *dev)
 
 	/* now we are supposed to have a proper phydev to attach to... */
 	if (!phydev) {
-		printk(KERN_INFO "%s: Don't found any phy device at all\n",
-			dev->name);
+		netdev_info(dev, "No PHY device found\n");
 		return -ENODEV;
 	}
 
@@ -438,7 +437,7 @@ static int mii_probe(struct net_device *dev)
 #endif
 
 	if (IS_ERR(phydev)) {
-		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
+		netdev_err(dev, "Could not attach to PHY\n");
 		return PTR_ERR(phydev);
 	}
 
@@ -460,11 +459,11 @@ static int mii_probe(struct net_device *dev)
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
@@ -636,8 +635,9 @@ static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
 	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
 		return -EFAULT;
 
-	pr_debug("%s config flag:0x%x, tx_type:0x%x, rx_filter:0x%x\n",
-		 __func__, config.flags, config.tx_type, config.rx_filter);
+	netdev_dbg(netdev,
+		   "%s config flag:0x%x, tx_type:0x%x, rx_filter:0x%x\n",
+		   __func__, config.flags, config.tx_type, config.rx_filter);
 
 	/* reserved for future extensions */
 	if (config.flags)
@@ -833,8 +833,8 @@ static void bfin_tx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
 		       (--timeout_cnt))
 			udelay(1);
 		if (timeout_cnt == 0)
-			printk(KERN_ERR DRV_NAME
-					": fails to timestamp the TX packet\n");
+			netdev_err(netdev,
+				   "failed to timestamp the TX packet\n");
 		else {
 			struct skb_shared_hwtstamps shhwtstamps;
 			u64 ns;
@@ -1091,8 +1091,7 @@ static void bfin_mac_rx(struct net_device *dev)
 	 * we which case we simply drop the packet
 	 */
 	if (current_rx_ptr->status.status_word & RX_ERROR_MASK) {
-		printk(KERN_NOTICE DRV_NAME
-		       ": rx: receive error - packet dropped\n");
+		netdev_notice(dev, "rx: receive error - packet dropped\n");
 		dev->stats.rx_dropped++;
 		goto out;
 	}
@@ -1102,8 +1101,7 @@ static void bfin_mac_rx(struct net_device *dev)
 
 	new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
 	if (!new_skb) {
-		printk(KERN_NOTICE DRV_NAME
-		       ": rx: low on mem - packet dropped\n");
+		netdev_notice(dev, "rx: low on mem - packet dropped\n");
 		dev->stats.rx_dropped++;
 		goto out;
 	}
@@ -1226,7 +1224,7 @@ static int bfin_mac_enable(void)
 	int ret;
 	u32 opmode;
 
-	pr_debug("%s: %s\n", DRV_NAME, __func__);
+	pr_debug("%s\n", __func__);
 
 	/* Set RX DMA */
 	bfin_write_DMA1_NEXT_DESC_PTR(&(rx_list_head->desc_a));
@@ -1268,7 +1266,7 @@ static void bfin_mac_timeout(struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 
-	pr_debug("%s: %s\n", dev->name, __func__);
+	netdev_dbg(dev, "%s\n", __func__);
 
 	bfin_mac_disable();
 
@@ -1335,7 +1333,7 @@ static void bfin_mac_set_multicast_list(struct net_device *dev)
 	u32 sysctl;
 
 	if (dev->flags & IFF_PROMISC) {
-		printk(KERN_INFO "%s: set to promisc mode\n", dev->name);
+		netdev_info(dev, "set to promisc mode\n");
 		sysctl = bfin_read_EMAC_OPMODE();
 		sysctl |= PR;
 		bfin_write_EMAC_OPMODE(sysctl);
@@ -1389,7 +1387,7 @@ static int bfin_mac_open(struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 	int ret;
-	pr_debug("%s: %s\n", dev->name, __func__);
+	netdev_dbg(dev, "%s\n", __func__);
 
 	/*
 	 * Check that the address is valid.  If its not, refuse
@@ -1397,7 +1395,7 @@ static int bfin_mac_open(struct net_device *dev)
 	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
 	 */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		printk(KERN_WARNING DRV_NAME ": no valid ethernet hw addr\n");
+		netdev_warn(dev, "no valid ethernet hw addr\n");
 		return -EINVAL;
 	}
 
@@ -1415,7 +1413,7 @@ static int bfin_mac_open(struct net_device *dev)
 	ret = bfin_mac_enable();
 	if (ret)
 		return ret;
-	pr_debug("hardware init finished\n");
+	netdev_dbg(dev, "hardware init finished\n");
 
 	netif_start_queue(dev);
 	netif_carrier_on(dev);
@@ -1431,7 +1429,7 @@ static int bfin_mac_open(struct net_device *dev)
 static int bfin_mac_close(struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
-	pr_debug("%s: %s\n", dev->name, __func__);
+	netdev_dbg(dev, "%s\n", __func__);
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
-- 
1.7.2.19.g9a302
