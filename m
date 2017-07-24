From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 03/18] net: mvpp2: set the SMI PHY address when connecting to the PHY
Date: Mon, 24 Jul 2017 15:48:33 +0200
Message-ID: <20170724134848.19330-4-antoine.tenart@free-electrons.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47330 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753476AbdGXNuD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 09:50:03 -0400
In-Reply-To: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When connecting to the PHY, explicitly set the SMI PHY address in the
controller registers to configure a given port to be connected to the
selected PHY.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 1e592abc9067..6ffff929b22a 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -359,6 +359,8 @@
 #define MVPP22_SMI_MISC_CFG_REG			0x1204
 #define     MVPP22_SMI_POLLING_EN		BIT(10)
 
+#define MVPP22_SMI_PHY_ADDR(port)		(0x120c + (port) * 0x4)
+
 #define MVPP22_GMAC_BASE(port)		(0x7000 + (port) * 0x1000 + 0xe00)
 
 #define MVPP2_CAUSE_TXQ_SENT_DESC_ALL_MASK	0xff
@@ -5939,7 +5941,9 @@ static void mvpp21_get_mac_address(struct mvpp2_port *port, unsigned char *addr)
 
 static int mvpp2_phy_connect(struct mvpp2_port *port)
 {
+	struct mvpp2 *priv = port->priv;
 	struct phy_device *phy_dev;
+	u32 phy_addr;
 
 	phy_dev = of_phy_connect(port->dev, port->phy_node, mvpp2_link_event, 0,
 				 port->phy_interface);
@@ -5954,6 +5958,16 @@ static int mvpp2_phy_connect(struct mvpp2_port *port)
 	port->duplex  = 0;
 	port->speed   = 0;
 
+	if (priv->hw_version != MVPP22)
+		return 0;
+
+	/* Set the SMI PHY address */
+	if (of_property_read_u32(port->phy_node, "reg", &phy_addr)) {
+		netdev_err(port->dev, "cannot find the PHY address\n");
+		return -EINVAL;
+	}
+
+	writel(phy_addr, priv->iface_base + MVPP22_SMI_PHY_ADDR(port->gop_id));
 	return 0;
 }
 
-- 
2.13.3
