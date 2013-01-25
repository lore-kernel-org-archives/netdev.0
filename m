From: Florian Fainelli <florian@openwrt.org>
Subject: [RFC PATCH 4/4] net: mvmdio: add getter and setter for PHY addresses
Date: Fri, 25 Jan 2013 11:06:49 +0100
Message-ID: <1359108409-4378-5-git-send-email-florian@openwrt.org>
References: <1359108409-4378-1-git-send-email-florian@openwrt.org>
Cc: linux-arm-kernel@lists.infradead.org, ian.molton@codethink.co.uk,
	jason@lakedaemon.net, andrew@lunn.ch, arnd@arndb.de,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com,
	Florian Fainelli <florian@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:40913 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756128Ab3AYKJj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 05:09:39 -0500
In-Reply-To: <1359108409-4378-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds orion_mdio_{set,get}_phy_addr(.., port_number, phy_addr)
which is a feature available in this MDIO driver to monitor a particular
PHY address. This brings mvmdio one step closer to what is used in
mv643x_eth.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/marvell/mvmdio.c |   29 +++++++++++++++++++++++++++++
 include/linux/marvell_mvmdio.h        |   10 ++++++++++
 2 files changed, 39 insertions(+)
 create mode 100644 include/linux/marvell_mvmdio.h

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index bdd9047..09e2470 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -32,7 +32,9 @@
 #include <linux/delay.h>
 #include <linux/sched.h>
 #include <linux/wait.h>
+#include <linux/marvell_mvmdio.h>
 
+#define MVMDIO_PHY_ADDR			   0x0000
 #define MVMDIO_SMI_REG			   0x0004
 #define MVMDIO_SMI_DATA_SHIFT              0
 #define MVMDIO_SMI_PHY_ADDR_SHIFT          16
@@ -188,6 +190,33 @@ static irqreturn_t orion_mdio_err_irq(int irq, void *dev_id)
 	return IRQ_NONE;
 }
 
+void orion_mdio_phy_addr_set(struct platform_device *pdev,
+				int port_num, int phy_addr)
+{
+	struct orion_mdio_dev *dev =
+		platform_get_drvdata(pdev);
+	int addr_shift = 5 * port_num;
+	u32 data;
+
+	data = readl(dev->regs + MVMDIO_PHY_ADDR);
+	data &= ~(0x1f << addr_shift);
+	data |= (phy_addr & 0x1f) << addr_shift;
+	writel(data, dev->regs + MVMDIO_PHY_ADDR);
+}
+EXPORT_SYMBOL(orion_mdio_phy_addr_set);
+
+int orion_mdio_phy_addr_get(struct platform_device *pdev, int port_num)
+{
+	struct orion_mdio_dev *dev =
+		platform_get_drvdata(pdev);
+	unsigned int data;
+
+	data = readl(dev->regs + MVMDIO_PHY_ADDR);
+
+	return (data >> (5 * port_num)) & 0x1f;
+}
+EXPORT_SYMBOL(orion_mdio_phy_addr_get);
+
 static int orion_mdio_probe(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
diff --git a/include/linux/marvell_mvmdio.h b/include/linux/marvell_mvmdio.h
new file mode 100644
index 0000000..c2dfec4
--- /dev/null
+++ b/include/linux/marvell_mvmdio.h
@@ -0,0 +1,10 @@
+#ifndef _MARVELL_MVMDIO_H
+#define _MARVELL_MVMDIO_H
+
+#include <linux/platform_device.h>
+
+void orion_mdio_phy_addr_set(struct platform_device *pdev,
+				int port_num, int phy_addr);
+int orion_mdio_phy_addr_get(struct platform_device *pdev, int port_num);
+
+#endif /* _MARVELL_MVMDIO_H */
-- 
1.7.10.4
