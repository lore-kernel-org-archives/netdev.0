From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/5] net: systemport: add suspend and resume support
Date: Tue,  1 Jul 2014 21:08:38 -0700
Message-ID: <1404274120-5717-4-git-send-email-f.fainelli@gmail.com>
References: <1404274120-5717-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:50367 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbaGBEJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:09:11 -0400
Received: by mail-qc0-f174.google.com with SMTP id x13so9252181qcv.33
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:09:10 -0700 (PDT)
In-Reply-To: <1404274120-5717-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the hardware recommended suspend/resume procedure for
SYSTEMPORT. We leverage the previous factoring work such that we can
logically break all suspend/resume operations into disctint RX and TX
code paths.

When the system enters S3, we will loose all register contents, so
make sure that we correctly re-program all the hardware and software
views of the RX & TX rings as well.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 164 ++++++++++++++++++++++++++++-
 1 file changed, 160 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 8f6ab266b178..9dabcfbfc23a 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1311,11 +1311,19 @@ static void bcm_sysport_netif_start(struct net_device *dev)
 	netif_tx_start_all_queues(dev);
 }
 
+static void rbuf_init(struct bcm_sysport_priv *priv)
+{
+	u32 reg;
+
+	reg = rbuf_readl(priv, RBUF_CONTROL);
+	reg |= RBUF_4B_ALGN | RBUF_RSB_EN;
+	rbuf_writel(priv, reg, RBUF_CONTROL);
+}
+
 static int bcm_sysport_open(struct net_device *dev)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
 	unsigned int i;
-	u32 reg;
 	int ret;
 
 	/* Reset UniMAC */
@@ -1332,9 +1340,7 @@ static int bcm_sysport_open(struct net_device *dev)
 	umac_enable_set(priv, CMD_RX_EN | CMD_TX_EN, 0);
 
 	/* Enable RBUF 2bytes alignment and Receive Status Block */
-	reg = rbuf_readl(priv, RBUF_CONTROL);
-	reg |= RBUF_4B_ALGN | RBUF_RSB_EN;
-	rbuf_writel(priv, reg, RBUF_CONTROL);
+	rbuf_init(priv);
 
 	/* Set maximum frame length */
 	umac_writel(priv, UMAC_MAX_MTU_SIZE, UMAC_MAX_FRAME_LEN);
@@ -1640,6 +1646,155 @@ static int bcm_sysport_remove(struct platform_device *pdev)
 	return 0;
 }
 
+#ifdef CONFIG_PM_SLEEP
+static int bcm_sysport_suspend(struct device *d)
+{
+	struct net_device *dev = dev_get_drvdata(d);
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	unsigned int i;
+	int ret;
+	u32 reg;
+
+	if (!netif_running(dev))
+		return 0;
+
+	bcm_sysport_netif_stop(dev);
+
+	phy_suspend(priv->phydev);
+
+	netif_device_detach(dev);
+
+	/* Disable UniMAC RX */
+	umac_enable_set(priv, CMD_RX_EN, 0);
+
+	ret = rdma_enable_set(priv, 0);
+	if (ret) {
+		netdev_err(dev, "RDMA timeout!\n");
+		return ret;
+	}
+
+	/* Disable RXCHK if enabled */
+	if (priv->rx_csum_en) {
+		reg = rxchk_readl(priv, RXCHK_CONTROL);
+		reg &= ~RXCHK_EN;
+		rxchk_writel(priv, reg, RXCHK_CONTROL);
+	}
+
+	/* Flush RX pipe */
+	topctrl_writel(priv, RX_FLUSH, RX_FLUSH_CNTL);
+
+	ret = tdma_enable_set(priv, 0);
+	if (ret) {
+		netdev_err(dev, "TDMA timeout!\n");
+		return ret;
+	}
+
+	/* Wait for a packet boundary */
+	usleep_range(2000, 3000);
+
+	umac_enable_set(priv, CMD_TX_EN, 0);
+
+	topctrl_writel(priv, TX_FLUSH, TX_FLUSH_CNTL);
+
+	/* Free RX/TX rings SW structures */
+	for (i = 0; i < dev->num_tx_queues; i++)
+		bcm_sysport_fini_tx_ring(priv, i);
+	bcm_sysport_fini_rx_ring(priv);
+
+	return 0;
+}
+
+static int bcm_sysport_resume(struct device *d)
+{
+	struct net_device *dev = dev_get_drvdata(d);
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	unsigned int i;
+	u32 reg;
+	int ret;
+
+	if (!netif_running(dev))
+		return 0;
+
+	/* Initialize both hardware and software ring */
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		ret = bcm_sysport_init_tx_ring(priv, i);
+		if (ret) {
+			netdev_err(dev, "failed to initialize TX ring %d\n",
+					i);
+			goto out_free_tx_rings;
+		}
+	}
+
+	/* Initialize linked-list */
+	tdma_writel(priv, TDMA_LL_RAM_INIT_BUSY, TDMA_STATUS);
+
+	/* Initialize RX ring */
+	ret = bcm_sysport_init_rx_ring(priv);
+	if (ret) {
+		netdev_err(dev, "failed to initialize RX ring\n");
+		goto out_free_rx_ring;
+	}
+
+	netif_device_attach(dev);
+
+	/* Enable RX interrupt and TX ring full interrupt */
+	intrl2_0_mask_clear(priv, INTRL2_0_RDMA_MBDONE | INTRL2_0_TX_RING_FULL);
+
+	/* RX pipe enable */
+	topctrl_writel(priv, 0, RX_FLUSH_CNTL);
+
+	ret = rdma_enable_set(priv, 1);
+	if (ret) {
+		netdev_err(dev, "failed to enable RDMA\n");
+		goto out_free_rx_ring;
+	}
+
+	/* Enable rxhck */
+	if (priv->rx_csum_en) {
+		reg = rxchk_readl(priv, RXCHK_CONTROL);
+		reg |= RXCHK_EN;
+		rxchk_writel(priv, reg, RXCHK_CONTROL);
+	}
+
+	rbuf_init(priv);
+
+	/* Set maximum frame length */
+	umac_writel(priv, UMAC_MAX_MTU_SIZE, UMAC_MAX_FRAME_LEN);
+
+	/* Set MAC address */
+	umac_set_hw_addr(priv, dev->dev_addr);
+
+	umac_enable_set(priv, CMD_RX_EN, 1);
+
+	/* TX pipe enable */
+	topctrl_writel(priv, 0, TX_FLUSH_CNTL);
+
+	umac_enable_set(priv, CMD_TX_EN, 1);
+
+	ret = tdma_enable_set(priv, 1);
+	if (ret) {
+		netdev_err(dev, "TDMA timeout!\n");
+		goto out_free_rx_ring;
+	}
+
+	phy_resume(priv->phydev);
+
+	bcm_sysport_netif_start(dev);
+
+	return 0;
+
+out_free_rx_ring:
+	bcm_sysport_fini_rx_ring(priv);
+out_free_tx_rings:
+	for (i = 0; i < dev->num_tx_queues; i++)
+		bcm_sysport_fini_tx_ring(priv, i);
+	return ret;
+}
+#endif
+
+static SIMPLE_DEV_PM_OPS(bcm_sysport_pm_ops,
+		bcm_sysport_suspend, bcm_sysport_resume);
+
 static const struct of_device_id bcm_sysport_of_match[] = {
 	{ .compatible = "brcm,systemport-v1.00" },
 	{ .compatible = "brcm,systemport" },
@@ -1653,6 +1808,7 @@ static struct platform_driver bcm_sysport_driver = {
 		.name = "brcm-systemport",
 		.owner = THIS_MODULE,
 		.of_match_table = bcm_sysport_of_match,
+		.pm = &bcm_sysport_pm_ops,
 	},
 };
 module_platform_driver(bcm_sysport_driver);
-- 
1.9.1
