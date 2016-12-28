From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv2 net-next 11/16] net: mvpp2: handle misc PPv2.1/PPv2.2 differences
Date: Wed, 28 Dec 2016 17:46:27 +0100
Message-ID: <1482943592-12556-12-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Kumar Gala <galak@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47966 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751939AbcL1QsD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 11:48:03 -0500
In-Reply-To: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit handles a few miscellaneous differences between PPv2.1 and
PPv2.2 in different areas, where code done for PPv2.1 doesn't apply for
PPv2.2 or needs to be adjusted (getting the MAC address, disabling PHY
polling, etc.).

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 31 ++++++++++++++++++++++---------
 1 file changed, 22 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 389cc62..eb55576 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -304,6 +304,9 @@
 #define      MVPP2_GMAC_TX_FIFO_MIN_TH_MASK(v)	(((v) << 6) & \
 					MVPP2_GMAC_TX_FIFO_MIN_TH_ALL_MASK)
 
+#define MVPP22_SMI_MISC_CFG_REG			0x2a204
+#define      MVPP22_SMI_POLLING_EN		BIT(10)
+
 #define MVPP22_PORT_BASE			0x30e00
 #define MVPP22_PORT_OFFSET			0x1000
 
@@ -5823,7 +5826,7 @@ static int mvpp2_check_ringparam_valid(struct net_device *dev,
 	return 0;
 }
 
-static void mvpp2_get_mac_address(struct mvpp2_port *port, unsigned char *addr)
+static void mvpp21_get_mac_address(struct mvpp2_port *port, unsigned char *addr)
 {
 	u32 mac_addr_l, mac_addr_m, mac_addr_h;
 
@@ -6272,7 +6275,7 @@ static const struct ethtool_ops mvpp2_eth_tool_ops = {
 
 /* Driver initialization */
 
-static void mvpp2_port_power_up(struct mvpp2_port *port)
+static void mvpp21_port_power_up(struct mvpp2_port *port)
 {
 	mvpp2_port_mii_set(port);
 	mvpp2_port_periodic_xon_disable(port);
@@ -6491,7 +6494,8 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 		mac_from = "device tree";
 		ether_addr_copy(dev->dev_addr, dt_mac_addr);
 	} else {
-		mvpp2_get_mac_address(port, hw_mac_addr);
+		if (priv->hw_version == MVPP21)
+			mvpp21_get_mac_address(port, hw_mac_addr);
 		if (is_valid_ether_addr(hw_mac_addr)) {
 			mac_from = "hardware";
 			ether_addr_copy(dev->dev_addr, hw_mac_addr);
@@ -6511,7 +6515,9 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 		dev_err(&pdev->dev, "failed to init port %d\n", id);
 		goto err_free_stats;
 	}
-	mvpp2_port_power_up(port);
+
+	if (priv->hw_version == MVPP21)
+		mvpp21_port_power_up(port);
 
 	port->pcpu = alloc_percpu(struct mvpp2_port_pcpu);
 	if (!port->pcpu) {
@@ -6654,9 +6660,15 @@ static int mvpp2_init(struct platform_device *pdev, struct mvpp2 *priv)
 		mvpp2_conf_mbus_windows(dram_target_info, priv);
 
 	/* Disable HW PHY polling */
-	val = readl(priv->lms_base + MVPP2_PHY_AN_CFG0_REG);
-	val |= MVPP2_PHY_AN_STOP_SMI0_MASK;
-	writel(val, priv->lms_base + MVPP2_PHY_AN_CFG0_REG);
+	if (priv->hw_version == MVPP21) {
+		val = readl(priv->lms_base + MVPP2_PHY_AN_CFG0_REG);
+		val |= MVPP2_PHY_AN_STOP_SMI0_MASK;
+		writel(val, priv->lms_base + MVPP2_PHY_AN_CFG0_REG);
+	} else {
+		val = readl(priv->iface_base + MVPP22_SMI_MISC_CFG_REG);
+		val &= ~MVPP22_SMI_POLLING_EN;
+		writel(val, priv->iface_base + MVPP22_SMI_MISC_CFG_REG);
+	}
 
 	/* Allocate and initialize aggregated TXQs */
 	priv->aggr_txqs = devm_kcalloc(&pdev->dev, num_present_cpus(),
@@ -6681,8 +6693,9 @@ static int mvpp2_init(struct platform_device *pdev, struct mvpp2 *priv)
 	for (i = 0; i < MVPP2_MAX_PORTS; i++)
 		mvpp2_write(priv, MVPP2_ISR_RXQ_GROUP_REG(i), rxq_number);
 
-	writel(MVPP2_EXT_GLOBAL_CTRL_DEFAULT,
-	       priv->lms_base + MVPP2_MNG_EXTENDED_GLOBAL_CTRL_REG);
+	if (priv->hw_version == MVPP21)
+		writel(MVPP2_EXT_GLOBAL_CTRL_DEFAULT,
+		       priv->lms_base + MVPP2_MNG_EXTENDED_GLOBAL_CTRL_REG);
 
 	/* Allow cache snoop when transmiting packets */
 	mvpp2_write(priv, MVPP2_TX_SNOOP_REG, 0x1);
-- 
2.7.4
