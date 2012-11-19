From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 1/2] net: mvneta: add clk support
Date: Mon, 19 Nov 2012 15:13:15 +0100
Message-ID: <1353334396-26128-2-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1353334396-26128-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	linux-arm-kernel@lists.infradead.org
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:38241 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779Ab2KSONd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 09:13:33 -0500
In-Reply-To: <1353334396-26128-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the Armada 370/XP platform has gained proper integration with
the clock framework, we add clk support in the Marvell Armada 370/XP
Ethernet driver.

Since the existing Device Tree binding that exposes a
'clock-frequency' property has never been exposed in any stable kernel
release, we take the freedom of removing this property to replace it
with the standard 'clocks' clock pointer property.

The Device Tree binding documentation is updated accordingly.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 .../bindings/net/marvell-armada-370-neta.txt       |    4 +--
 drivers/net/ethernet/marvell/mvneta.c              |   31 +++++++++++++-------
 2 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
index c4e87f0..859a6fa 100644
--- a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
+++ b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
@@ -8,7 +8,7 @@ Required properties:
   property, a single integer).
 - phy-mode: The interface between the SoC and the PHY (a string that
   of_get_phy_mode() can understand)
-- clock-frequency: frequency of the peripheral clock of the SoC.
+- clocks: a pointer to the reference clock for this device.
 
 Example:
 
@@ -16,7 +16,7 @@ ethernet@d0070000 {
 	compatible = "marvell,armada-370-neta";
 	reg = <0xd0070000 0x2500>;
 	interrupts = <8>;
-	clock-frequency = <250000000>;
+	clocks = <&gate_clk 4>;
 	status = "okay";
 	phy = <&phy0>;
 	phy-mode = "rgmii-id";
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index a7826f0..c90382a 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -29,6 +29,7 @@
 #include <linux/of_net.h>
 #include <linux/of_address.h>
 #include <linux/phy.h>
+#include <linux/clk.h>
 
 /* Registers */
 #define MVNETA_RXQ_CONFIG_REG(q)                (0x1400 + ((q) << 2))
@@ -243,7 +244,7 @@ struct mvneta_port {
 	int weight;
 
 	/* Core clock */
-	unsigned int clk_rate_hz;
+	struct clk *clk;
 	u8 mcast_count[256];
 	u16 tx_ring_size;
 	u16 rx_ring_size;
@@ -1029,7 +1030,11 @@ static void mvneta_rx_pkts_coal_set(struct mvneta_port *pp,
 static void mvneta_rx_time_coal_set(struct mvneta_port *pp,
 				    struct mvneta_rx_queue *rxq, u32 value)
 {
-	u32 val = (pp->clk_rate_hz / 1000000) * value;
+	u32 val;
+	unsigned long clk_rate;
+
+	clk_rate = clk_get_rate(pp->clk);
+	val = (clk_rate / 1000000) * value;
 
 	mvreg_write(pp, MVNETA_RXQ_TIME_COAL_REG(rxq->id), val);
 	rxq->time_coal = value;
@@ -2670,7 +2675,7 @@ static int __devinit mvneta_probe(struct platform_device *pdev)
 	const struct mbus_dram_target_info *dram_target_info;
 	struct device_node *dn = pdev->dev.of_node;
 	struct device_node *phy_node;
-	u32 phy_addr, clk_rate_hz;
+	u32 phy_addr;
 	struct mvneta_port *pp;
 	struct net_device *dev;
 	const char *mac_addr;
@@ -2710,12 +2715,6 @@ static int __devinit mvneta_probe(struct platform_device *pdev)
 		goto err_free_irq;
 	}
 
-	if (of_property_read_u32(dn, "clock-frequency", &clk_rate_hz) != 0) {
-		dev_err(&pdev->dev, "could not read clock-frequency\n");
-		err = -EINVAL;
-		goto err_free_irq;
-	}
-
 	mac_addr = of_get_mac_address(dn);
 
 	if (!mac_addr || !is_valid_ether_addr(mac_addr))
@@ -2736,7 +2735,6 @@ static int __devinit mvneta_probe(struct platform_device *pdev)
 	clear_bit(MVNETA_F_TX_DONE_TIMER_BIT, &pp->flags);
 
 	pp->weight = MVNETA_RX_POLL_WEIGHT;
-	pp->clk_rate_hz = clk_rate_hz;
 	pp->phy_node = phy_node;
 	pp->phy_interface = phy_mode;
 
@@ -2746,6 +2744,14 @@ static int __devinit mvneta_probe(struct platform_device *pdev)
 		goto err_free_irq;
 	}
 
+	pp->clk = devm_clk_get(&pdev->dev, NULL);
+	if (IS_ERR(pp->clk)) {
+		err = PTR_ERR(pp->clk);
+		goto err_unmap;
+	}
+
+	clk_prepare_enable(pp->clk);
+
 	pp->tx_done_timer.data = (unsigned long)dev;
 
 	pp->tx_ring_size = MVNETA_MAX_TXD;
@@ -2757,7 +2763,7 @@ static int __devinit mvneta_probe(struct platform_device *pdev)
 	err = mvneta_init(pp, phy_addr);
 	if (err < 0) {
 		dev_err(&pdev->dev, "can't init eth hal\n");
-		goto err_unmap;
+		goto err_clk;
 	}
 	mvneta_port_power_up(pp, phy_mode);
 
@@ -2785,6 +2791,8 @@ static int __devinit mvneta_probe(struct platform_device *pdev)
 
 err_deinit:
 	mvneta_deinit(pp);
+err_clk:
+	clk_disable_unprepare(pp->clk);
 err_unmap:
 	iounmap(pp->base);
 err_free_irq:
@@ -2802,6 +2810,7 @@ static int __devexit mvneta_remove(struct platform_device *pdev)
 
 	unregister_netdev(dev);
 	mvneta_deinit(pp);
+	clk_disable_unprepare(pp->clk);
 	iounmap(pp->base);
 	irq_dispose_mapping(dev->irq);
 	free_netdev(dev);
-- 
1.7.9.5
