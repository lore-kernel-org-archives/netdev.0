From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv3 net-next 16/22] net: mvpp2: handle misc PPv2.1/PPv2.2
 differences
Date: Tue,  7 Mar 2017 16:53:14 +0100
Message-ID: <1488902000-2658-17-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Yehuda Yitschak <yehuday@marvell.com>,
 Russell King <linux@arm.linux.org.uk>, Jason Cooper <jason@lakedaemon.net>,
 Hanna Hawa <hannah@marvell.com>, Nadav Haklai <nadavh@marvell.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
 devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Pawel Moll <pawel.moll@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Kumar Gala <galak@codeaurora.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This commit handles a few miscellaneous differences between PPv2.1 and
PPv2.2 in different areas, where code done for PPv2.1 doesn't apply for
PPv2.2 or needs to be adjusted (getting the MAC address, disabling PHY
polling, etc.).

Thanks to Russell King for providing the initial implementation of
mvpp22_port_mii_set().

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 85 ++++++++++++++++++++++++++++--------
 1 file changed, 67 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 2b4b4f0..bd7dc4b6 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -294,6 +294,22 @@
 #define      MVPP2_GMAC_TX_FIFO_MIN_TH_ALL_MASK	0x1fc0
 #define      MVPP2_GMAC_TX_FIFO_MIN_TH_MASK(v)	(((v) << 6) & \
 					MVPP2_GMAC_TX_FIFO_MIN_TH_ALL_MASK)
+#define MVPP22_GMAC_CTRL_4_REG			0x90
+#define      MVPP22_CTRL4_EXT_PIN_GMII_SEL	BIT(0)
+#define      MVPP22_CTRL4_DP_CLK_SEL		BIT(5)
+#define      MVPP22_CTRL4_SYNC_BYPASS		BIT(6)
+#define      MVPP22_CTRL4_QSGMII_BYPASS_ACTIVE	BIT(7)
+
+/* Per-port XGMAC registers. PPv2.2 only, only for GOP port 0,
+ * relative to port->base.
+ */
+#define MVPP22_XLG_CTRL3_REG			0x11c
+#define      MVPP22_XLG_CTRL3_MACMODESELECT_MASK	(7 << 13)
+#define      MVPP22_XLG_CTRL3_MACMODESELECT_GMAC	(0 << 13)
+
+/* SMI registers. PPv2.2 only, relative to priv->iface_base. */
+#define MVPP22_SMI_MISC_CFG_REG			0x1204
+#define      MVPP22_SMI_POLLING_EN		BIT(10)
 
 #define MVPP22_GMAC_BASE(port)		(0x7000 + (port) * 0x1000 + 0xe00)
 
@@ -4128,10 +4144,38 @@ static void mvpp2_interrupts_unmask(void *arg)
 
 /* Port configuration routines */
 
+static void mvpp22_port_mii_set(struct mvpp2_port *port)
+{
+	u32 val;
+
+	return;
+
+	/* Only GOP port 0 has an XLG MAC */
+	if (port->gop_id == 0) {
+		val = readl(port->base + MVPP22_XLG_CTRL3_REG);
+		val &= ~MVPP22_XLG_CTRL3_MACMODESELECT_MASK;
+		val |= MVPP22_XLG_CTRL3_MACMODESELECT_GMAC;
+		writel(val, port->base + MVPP22_XLG_CTRL3_REG);
+	}
+
+	val = readl(port->base + MVPP22_GMAC_CTRL_4_REG);
+	if (port->phy_interface == PHY_INTERFACE_MODE_RGMII)
+		val |= MVPP22_CTRL4_EXT_PIN_GMII_SEL;
+	else
+		val &= ~MVPP22_CTRL4_EXT_PIN_GMII_SEL;
+	val &= ~MVPP22_CTRL4_DP_CLK_SEL;
+	val |= MVPP22_CTRL4_SYNC_BYPASS;
+	val |= MVPP22_CTRL4_QSGMII_BYPASS_ACTIVE;
+	writel(val, port->base + MVPP22_GMAC_CTRL_4_REG);
+}
+
 static void mvpp2_port_mii_set(struct mvpp2_port *port)
 {
 	u32 val;
 
+	if (port->priv->hw_version == MVPP22)
+		mvpp22_port_mii_set(port);
+
 	val = readl(port->base + MVPP2_GMAC_CTRL_2_REG);
 
 	switch (port->phy_interface) {
@@ -5813,7 +5857,7 @@ static int mvpp2_check_ringparam_valid(struct net_device *dev,
 	return 0;
 }
 
-static void mvpp2_get_mac_address(struct mvpp2_port *port, unsigned char *addr)
+static void mvpp21_get_mac_address(struct mvpp2_port *port, unsigned char *addr)
 {
 	u32 mac_addr_l, mac_addr_m, mac_addr_h;
 
@@ -6258,16 +6302,6 @@ static const struct ethtool_ops mvpp2_eth_tool_ops = {
 	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
-/* Driver initialization */
-
-static void mvpp2_port_power_up(struct mvpp2_port *port)
-{
-	mvpp2_port_mii_set(port);
-	mvpp2_port_periodic_xon_disable(port);
-	mvpp2_port_fc_adv_enable(port);
-	mvpp2_port_reset(port);
-}
-
 /* Initialize port HW */
 static int mvpp2_port_init(struct mvpp2_port *port)
 {
@@ -6479,7 +6513,8 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 		mac_from = "device tree";
 		ether_addr_copy(dev->dev_addr, dt_mac_addr);
 	} else {
-		mvpp2_get_mac_address(port, hw_mac_addr);
+		if (priv->hw_version == MVPP21)
+			mvpp21_get_mac_address(port, hw_mac_addr);
 		if (is_valid_ether_addr(hw_mac_addr)) {
 			mac_from = "hardware";
 			ether_addr_copy(dev->dev_addr, hw_mac_addr);
@@ -6499,7 +6534,14 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 		dev_err(&pdev->dev, "failed to init port %d\n", id);
 		goto err_free_stats;
 	}
-	mvpp2_port_power_up(port);
+
+	mvpp2_port_mii_set(port);
+	mvpp2_port_periodic_xon_disable(port);
+
+	if (priv->hw_version == MVPP21)
+		mvpp2_port_fc_adv_enable(port);
+
+	mvpp2_port_reset(port);
 
 	port->pcpu = alloc_percpu(struct mvpp2_port_pcpu);
 	if (!port->pcpu) {
@@ -6642,9 +6684,15 @@ static int mvpp2_init(struct platform_device *pdev, struct mvpp2 *priv)
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
@@ -6669,8 +6717,9 @@ static int mvpp2_init(struct platform_device *pdev, struct mvpp2 *priv)
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
