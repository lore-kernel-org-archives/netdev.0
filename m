From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [net-next-2.6 04/08] r8169: 8168DP specific MII registers access methods.
Date: Mon, 3 Jan 2011 00:37:04 +0100
Message-ID: <20110102233704.GE5780@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Ben Hutchings <benh@debian.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51694 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532Ab1ABXhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jan 2011 18:37:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adapted from version 8.019.00 of Realtek's r8168 driver.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   83 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 81 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f9d8ff0..7f6fd12 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -277,6 +277,20 @@ enum rtl8168_8101_registers {
 #define	EFUSEAR_DATA_MASK		0xff
 };
 
+enum rtl8168_registers {
+	EPHY_RXER_NUM		= 0x7c,
+	OCPDR			= 0xb0,	/* OCP GPHY access */
+#define OCPDR_WRITE_CMD			0x80000000
+#define OCPDR_READ_CMD			0x00000000
+#define OCPDR_REG_MASK			0xff
+#define OCPDR_GPHY_REG_SHIFT		12
+#define OCPDR_DATA_MASK			0xffff
+	OCPAR			= 0xb4,
+#define OCPAR_FLAG			0x80000000
+#define OCPAR_GPHY_WRITE_CMD		0x8000f060
+#define OCPAR_GPHY_READ_CMD		0x0000f060
+};
+
 enum rtl_register_content {
 	/* InterruptStatusBits */
 	SYSErr		= 0x8000,
@@ -500,6 +514,12 @@ struct rtl8169_private {
 #ifdef CONFIG_R8169_VLAN
 	struct vlan_group *vlgrp;
 #endif
+
+	struct mdio_ops {
+		void (*write)(void __iomem *, int, int);
+		int (*read)(void __iomem *, int);
+	} mdio_ops;
+
 	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
 	int (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(struct rtl8169_private *tp);
@@ -595,14 +615,55 @@ static int r8169_mdio_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
+static void r8168dp_1_mdio_access(void __iomem *ioaddr, int reg_addr, u32 data)
+{
+	int i;
+
+	RTL_W32(OCPDR, data |
+		((reg_addr & OCPDR_REG_MASK) << OCPDR_GPHY_REG_SHIFT));
+	RTL_W32(OCPAR, OCPAR_GPHY_WRITE_CMD);
+	RTL_W32(EPHY_RXER_NUM, 0);
+
+	for (i = 0; i < 100; i++) {
+		mdelay(1);
+		if (!(RTL_R32(OCPAR) & OCPAR_FLAG))
+			break;
+	}
+}
+
+static void r8168dp_1_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
+{
+	r8168dp_1_mdio_access(ioaddr, reg_addr, OCPDR_WRITE_CMD |
+		(value & OCPDR_DATA_MASK));
+}
+
+static int r8168dp_1_mdio_read(void __iomem *ioaddr, int reg_addr)
+{
+	int i;
+
+	r8168dp_1_mdio_access(ioaddr, reg_addr, OCPDR_READ_CMD);
+
+	mdelay(1);
+	RTL_W32(OCPAR, OCPAR_GPHY_READ_CMD);
+	RTL_W32(EPHY_RXER_NUM, 0);
+
+	for (i = 0; i < 100; i++) {
+		mdelay(1);
+		if (RTL_R32(OCPAR) & OCPAR_FLAG)
+			break;
+	}
+
+	return RTL_R32(OCPDR) & OCPDR_DATA_MASK;
+}
+
 static void rtl_writephy(struct rtl8169_private *tp, int location, u32 val)
 {
-	r8169_mdio_write(tp->mmio_addr, location, val);
+	tp->mdio_ops.write(tp->mmio_addr, location, val);
 }
 
 static int rtl_readphy(struct rtl8169_private *tp, int location)
 {
-	return r8169_mdio_read(tp->mmio_addr, location);
+	return tp->mdio_ops.read(tp->mmio_addr, location);
 }
 
 static void rtl_patchphy(struct rtl8169_private *tp, int reg_addr, int value)
@@ -2474,6 +2535,22 @@ static const struct net_device_ops rtl8169_netdev_ops = {
 
 };
 
+static void __devinit rtl_init_mdio_ops(struct rtl8169_private *tp)
+{
+	struct mdio_ops *ops = &tp->mdio_ops;
+
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_27:
+		ops->write	= r8168dp_1_mdio_write;
+		ops->read	= r8168dp_1_mdio_read;
+		break;
+	default:
+		ops->write	= r8169_mdio_write;
+		ops->read	= r8169_mdio_read;
+		break;
+	}
+}
+
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -2592,6 +2669,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, ioaddr);
 
+	rtl_init_mdio_ops(tp);
+
 	/* Use appropriate default if unknown */
 	if (tp->mac_version == RTL_GIGA_MAC_NONE) {
 		netif_notice(tp, probe, dev,
-- 
1.7.3.4

