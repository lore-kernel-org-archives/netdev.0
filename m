From: Joachim Eastwood <manabian@gmail.com>
Subject: [net-next PATCH] net/ethernet: remove useless is_valid_ether_addr from drivers ndo_open
Date: Tue, 13 Nov 2012 22:46:39 +0100
Message-ID: <1352843199-24869-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, Joachim Eastwood <manabian@gmail.com>
To: davem@davemloft.net, pcnet32@frontier.com, nicolas.ferre@atmel.com,
	mlindner@marvell.com, shemminger@vyatta.com, nico@fluxnic.net,
	steve.glendinning@shawell.net,
	uclinux-dist-devel@blackfin.uclinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:47877 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777Ab2KMVrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 16:47:09 -0500
Received: by mail-la0-f46.google.com with SMTP id h6so5821712lag.19
        for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 13:47:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If ndo_validate_addr is set in the driver netdev core will call
this validate function before calling ndo_open. So there is no
point in doing this again in driver ndo_open function.

With this change is_valid_ether_addr will be called from the
generic eth_validate_addr function. So there should be no change
in the actual behavior.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---

Hi,

net/core/dev.c __dev_open does
 1165        if (ops->ndo_validate_addr)
 1166                ret = ops->ndo_validate_addr(dev);
 1167
 1168        if (!ret && ops->ndo_open)
 1169                ret = ops->ndo_open(dev);

so I don't see the need for a is_valid_ether_addr in
ndo_open at all or am I missing something?

ndo_validate_addr is set to eth_validate_addr in all
changed drivers.

regards
Joachim Eastwood

 drivers/net/ethernet/8390/etherh.c        |  6 ------
 drivers/net/ethernet/adi/bfin_mac.c       | 10 ----------
 drivers/net/ethernet/amd/pcnet32.c        |  6 ------
 drivers/net/ethernet/cadence/at91_ether.c |  3 ---
 drivers/net/ethernet/cadence/macb.c       |  3 ---
 drivers/net/ethernet/calxeda/xgmac.c      | 11 +----------
 drivers/net/ethernet/dnet.c               |  3 ---
 drivers/net/ethernet/i825xx/ether1.c      |  6 ------
 drivers/net/ethernet/marvell/skge.c       |  3 ---
 drivers/net/ethernet/micrel/ks8695net.c   |  3 ---
 drivers/net/ethernet/microchip/enc28j60.c |  6 ------
 drivers/net/ethernet/nxp/lpc_eth.c        |  4 +---
 drivers/net/ethernet/seeq/ether3.c        |  6 ------
 drivers/net/ethernet/smsc/smc911x.c       | 10 ----------
 drivers/net/ethernet/smsc/smc91x.c        | 10 ----------
 drivers/net/ethernet/smsc/smsc911x.c      |  5 -----
 drivers/net/ethernet/smsc/smsc9420.c      |  6 ------
 drivers/net/ethernet/wiznet/w5100.c       |  2 --
 drivers/net/ethernet/wiznet/w5300.c       |  2 --
 19 files changed, 2 insertions(+), 103 deletions(-)

diff --git a/drivers/net/ethernet/8390/etherh.c b/drivers/net/ethernet/8390/etherh.c
index 8322c54..6414e84 100644
--- a/drivers/net/ethernet/8390/etherh.c
+++ b/drivers/net/ethernet/8390/etherh.c
@@ -463,12 +463,6 @@ etherh_open(struct net_device *dev)
 {
 	struct ei_device *ei_local = netdev_priv(dev);
 
-	if (!is_valid_ether_addr(dev->dev_addr)) {
-		printk(KERN_WARNING "%s: invalid ethernet MAC address\n",
-			dev->name);
-		return -EINVAL;
-	}
-
 	if (request_irq(dev->irq, __ei_interrupt, 0, dev->name, dev))
 		return -EAGAIN;
 
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index f1c458d..3dd0349 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1531,16 +1531,6 @@ static int bfin_mac_open(struct net_device *dev)
 	int ret;
 	pr_debug("%s: %s\n", dev->name, __func__);
 
-	/*
-	 * Check that the address is valid.  If its not, refuse
-	 * to bring the device up.  The user must specify an
-	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
-	 */
-	if (!is_valid_ether_addr(dev->dev_addr)) {
-		netdev_warn(dev, "no valid ethernet hw addr\n");
-		return -EINVAL;
-	}
-
 	/* initial rx and tx list */
 	ret = desc_list_init(dev);
 	if (ret)
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 86b6d8e..967fe28 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -2013,11 +2013,6 @@ static int pcnet32_open(struct net_device *dev)
 	}
 
 	spin_lock_irqsave(&lp->lock, flags);
-	/* Check for a valid station address */
-	if (!is_valid_ether_addr(dev->dev_addr)) {
-		rc = -EINVAL;
-		goto err_free_irq;
-	}
 
 	/* Reset the PCNET32 */
 	lp->a->reset(ioaddr);
@@ -2220,7 +2215,6 @@ err_free_ring:
 	 */
 	lp->a->write_bcr(ioaddr, 20, 4);
 
-err_free_irq:
 	spin_unlock_irqrestore(&lp->lock, flags);
 	free_irq(dev->irq, dev);
 	return rc;
diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index e7a476c..716cc01 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -97,9 +97,6 @@ static int at91ether_open(struct net_device *dev)
 	u32 ctl;
 	int ret;
 
-	if (!is_valid_ether_addr(dev->dev_addr))
-		return -EADDRNOTAVAIL;
-
 	/* Clear internal statistics */
 	ctl = macb_readl(lp, NCR);
 	macb_writel(lp, NCR, ctl | MACB_BIT(CLRSTAT));
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 1fac769..f33107f 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1200,9 +1200,6 @@ static int macb_open(struct net_device *dev)
 	if (!bp->phy_dev)
 		return -EAGAIN;
 
-	if (!is_valid_ether_addr(dev->dev_addr))
-		return -EADDRNOTAVAIL;
-
 	err = macb_alloc_consistent(bp);
 	if (err) {
 		netdev_err(dev, "Unable to allocate DMA memory (error %d)\n",
diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index b407043..8bafe9d 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -992,16 +992,6 @@ static int xgmac_open(struct net_device *dev)
 	struct xgmac_priv *priv = netdev_priv(dev);
 	void __iomem *ioaddr = priv->base;
 
-	/* Check that the MAC address is valid.  If its not, refuse
-	 * to bring the device up. The user must specify an
-	 * address using the following linux command:
-	 *      ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx  */
-	if (!is_valid_ether_addr(dev->dev_addr)) {
-		eth_hw_addr_random(dev);
-		netdev_dbg(priv->dev, "generated random MAC address %pM\n",
-			dev->dev_addr);
-	}
-
 	memset(&priv->xstats, 0, sizeof(struct xgmac_extra_stats));
 
 	/* Initialize the XGMAC and descriptors */
@@ -1499,6 +1489,7 @@ static const struct net_device_ops xgmac_netdev_ops = {
 	.ndo_poll_controller = xgmac_poll_controller,
 #endif
 	.ndo_set_mac_address = xgmac_set_mac_address,
+	.ndo_validate_addr = eth_validate_addr,
 	.ndo_set_features = xgmac_set_features,
 };
 
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 290b26f..feb5095 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -664,9 +664,6 @@ static int dnet_open(struct net_device *dev)
 	if (!bp->phy_dev)
 		return -EAGAIN;
 
-	if (!is_valid_ether_addr(dev->dev_addr))
-		return -EADDRNOTAVAIL;
-
 	napi_enable(&bp->napi);
 	dnet_init_hw(bp);
 
diff --git a/drivers/net/ethernet/i825xx/ether1.c b/drivers/net/ethernet/i825xx/ether1.c
index 067db3f..7b9609d 100644
--- a/drivers/net/ethernet/i825xx/ether1.c
+++ b/drivers/net/ethernet/i825xx/ether1.c
@@ -638,12 +638,6 @@ ether1_txalloc (struct net_device *dev, int size)
 static int
 ether1_open (struct net_device *dev)
 {
-	if (!is_valid_ether_addr(dev->dev_addr)) {
-		printk(KERN_WARNING "%s: invalid ethernet MAC address\n",
-			dev->name);
-		return -EINVAL;
-	}
-
 	if (request_irq(dev->irq, ether1_interrupt, 0, "ether1", dev))
 		return -EAGAIN;
 
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index d19a143..ce8d053 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -2524,9 +2524,6 @@ static int skge_up(struct net_device *dev)
 	size_t rx_size, tx_size;
 	int err;
 
-	if (!is_valid_ether_addr(dev->dev_addr))
-		return -EINVAL;
-
 	netif_info(skge, ifup, skge->netdev, "enabling interface\n");
 
 	if (dev->mtu > RX_BUF_SIZE)
diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index dccae1d..e62c312 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -1249,9 +1249,6 @@ ks8695_open(struct net_device *ndev)
 	struct ks8695_priv *ksp = netdev_priv(ndev);
 	int ret;
 
-	if (!is_valid_ether_addr(ndev->dev_addr))
-		return -EADDRNOTAVAIL;
-
 	ks8695_reset(ksp);
 
 	ks8695_update_mac(ksp);
diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 6118bda..306e609 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -1352,12 +1352,6 @@ static int enc28j60_net_open(struct net_device *dev)
 	if (netif_msg_drv(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 
-	if (!is_valid_ether_addr(dev->dev_addr)) {
-		if (netif_msg_ifup(priv))
-			dev_err(&dev->dev, "invalid MAC address %pM\n",
-				dev->dev_addr);
-		return -EADDRNOTAVAIL;
-	}
 	/* Reset the hardware here (and take it out of low power mode) */
 	enc28j60_lowpower(priv, false);
 	enc28j60_hw_disable(priv);
diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index af8b414..db6e101 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1219,9 +1219,6 @@ static int lpc_eth_open(struct net_device *ndev)
 	if (netif_msg_ifup(pldat))
 		dev_dbg(&pldat->pdev->dev, "enabling %s\n", ndev->name);
 
-	if (!is_valid_ether_addr(ndev->dev_addr))
-		return -EADDRNOTAVAIL;
-
 	__lpc_eth_clock_enable(pldat, true);
 
 	/* Reset and initialize */
@@ -1301,6 +1298,7 @@ static const struct net_device_ops lpc_netdev_ops = {
 	.ndo_set_rx_mode	= lpc_eth_set_multicast_list,
 	.ndo_do_ioctl		= lpc_eth_ioctl,
 	.ndo_set_mac_address	= lpc_set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 };
 
diff --git a/drivers/net/ethernet/seeq/ether3.c b/drivers/net/ethernet/seeq/ether3.c
index 6a40dd0..72a0174 100644
--- a/drivers/net/ethernet/seeq/ether3.c
+++ b/drivers/net/ethernet/seeq/ether3.c
@@ -399,12 +399,6 @@ ether3_probe_bus_16(struct net_device *dev, int val)
 static int
 ether3_open(struct net_device *dev)
 {
-	if (!is_valid_ether_addr(dev->dev_addr)) {
-		printk(KERN_WARNING "%s: invalid ethernet MAC address\n",
-			dev->name);
-		return -EINVAL;
-	}
-
 	if (request_irq(dev->irq, ether3_interrupt, 0, "ether3", dev))
 		return -EAGAIN;
 
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 8d15f7a..990f574 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -1400,16 +1400,6 @@ smc911x_open(struct net_device *dev)
 
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
-	/*
-	 * Check that the address is valid.  If its not, refuse
-	 * to bring the device up.	 The user must specify an
-	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
-	 */
-	if (!is_valid_ether_addr(dev->dev_addr)) {
-		PRINTK("%s: no valid ethernet hw addr\n", __func__);
-		return -EINVAL;
-	}
-
 	/* reset the hardware */
 	smc911x_reset(dev);
 
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 318adc9..f516e5a 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -1474,16 +1474,6 @@ smc_open(struct net_device *dev)
 
 	DBG(2, "%s: %s\n", dev->name, __func__);
 
-	/*
-	 * Check that the address is valid.  If its not, refuse
-	 * to bring the device up.  The user must specify an
-	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
-	 */
-	if (!is_valid_ether_addr(dev->dev_addr)) {
-		PRINTK("%s: no valid ethernet hw addr\n", __func__);
-		return -EINVAL;
-	}
-
 	/* Setup the default Register Modes */
 	lp->tcr_cur_mode = TCR_DEFAULT;
 	lp->rcr_cur_mode = RCR_DEFAULT;
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 62d1baf..a088c4f 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1463,11 +1463,6 @@ static int smsc911x_open(struct net_device *dev)
 		return -EAGAIN;
 	}
 
-	if (!is_valid_ether_addr(dev->dev_addr)) {
-		SMSC_WARN(pdata, hw, "dev_addr is not a valid MAC address");
-		return -EADDRNOTAVAIL;
-	}
-
 	/* Reset the LAN911x */
 	if (smsc911x_soft_reset(pdata)) {
 		SMSC_WARN(pdata, hw, "soft reset failed");
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 1fcd914e..25dd288 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1341,12 +1341,6 @@ static int smsc9420_open(struct net_device *dev)
 	unsigned long flags;
 	int result = 0, timeout;
 
-	if (!is_valid_ether_addr(dev->dev_addr)) {
-		smsc_warn(IFUP, "dev_addr is not a valid MAC address");
-		result = -EADDRNOTAVAIL;
-		goto out_0;
-	}
-
 	netif_carrier_off(dev);
 
 	/* disable, mask and acknowledge all interrupts */
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 2c08bf6..7daf92e 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -580,8 +580,6 @@ static int w5100_open(struct net_device *ndev)
 	struct w5100_priv *priv = netdev_priv(ndev);
 
 	netif_info(priv, ifup, ndev, "enabling\n");
-	if (!is_valid_ether_addr(ndev->dev_addr))
-		return -EINVAL;
 	w5100_hw_start(priv);
 	napi_enable(&priv->napi);
 	netif_start_queue(ndev);
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 88943d9..bd9eec6 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -500,8 +500,6 @@ static int w5300_open(struct net_device *ndev)
 	struct w5300_priv *priv = netdev_priv(ndev);
 
 	netif_info(priv, ifup, ndev, "enabling\n");
-	if (!is_valid_ether_addr(ndev->dev_addr))
-		return -EINVAL;
 	w5300_hw_start(priv);
 	napi_enable(&priv->napi);
 	netif_start_queue(ndev);
-- 
1.8.0
