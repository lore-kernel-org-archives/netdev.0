From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 2/6] r8169: mdio_ops signature change.
Date: Tue, 10 Jul 2012 00:44:06 +0200
Message-ID: <24192210a57a24a45b29dc3519dc42e073ea7b0a.1341872752.git.romieu@fr.zoreil.com>
References: <cover.1341872752.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59232 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261Ab2GIW4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 18:56:38 -0400
In-Reply-To: <cover.1341872752.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1341872752.git.romieu@fr.zoreil.com>
References: <cover.1341872752.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Further changes need more context down in the call stack.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |   46 +++++++++++++++++++---------------
 1 file changed, 26 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7afc593..5360f6d 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -728,8 +728,8 @@ struct rtl8169_private {
 	u16 event_slow;
 
 	struct mdio_ops {
-		void (*write)(void __iomem *, int, int);
-		int (*read)(void __iomem *, int);
+		void (*write)(struct rtl8169_private *, int, int);
+		int (*read)(struct rtl8169_private *, int);
 	} mdio_ops;
 
 	struct pll_power_ops {
@@ -919,11 +919,12 @@ static int r8168dp_check_dash(struct rtl8169_private *tp)
 	return (ocp_read(tp, 0x0f, reg) & 0x00008000) ? 1 : 0;
 }
 
-static void r8169_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
+static void r8169_mdio_write(struct rtl8169_private *tp, int reg, int value)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i;
 
-	RTL_W32(PHYAR, 0x80000000 | (reg_addr & 0x1f) << 16 | (value & 0xffff));
+	RTL_W32(PHYAR, 0x80000000 | (reg & 0x1f) << 16 | (value & 0xffff));
 
 	for (i = 20; i > 0; i--) {
 		/*
@@ -941,11 +942,12 @@ static void r8169_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
 	udelay(20);
 }
 
-static int r8169_mdio_read(void __iomem *ioaddr, int reg_addr)
+static int r8169_mdio_read(struct rtl8169_private *tp, int reg)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i, value = -1;
 
-	RTL_W32(PHYAR, 0x0 | (reg_addr & 0x1f) << 16);
+	RTL_W32(PHYAR, 0x0 | (reg & 0x1f) << 16);
 
 	for (i = 20; i > 0; i--) {
 		/*
@@ -967,12 +969,12 @@ static int r8169_mdio_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
-static void r8168dp_1_mdio_access(void __iomem *ioaddr, int reg_addr, u32 data)
+static void r8168dp_1_mdio_access(struct rtl8169_private *tp, int reg, u32 data)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i;
 
-	RTL_W32(OCPDR, data |
-		((reg_addr & OCPDR_REG_MASK) << OCPDR_GPHY_REG_SHIFT));
+	RTL_W32(OCPDR, data | ((reg & OCPDR_REG_MASK) << OCPDR_GPHY_REG_SHIFT));
 	RTL_W32(OCPAR, OCPAR_GPHY_WRITE_CMD);
 	RTL_W32(EPHY_RXER_NUM, 0);
 
@@ -983,17 +985,18 @@ static void r8168dp_1_mdio_access(void __iomem *ioaddr, int reg_addr, u32 data)
 	}
 }
 
-static void r8168dp_1_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
+static void r8168dp_1_mdio_write(struct rtl8169_private *tp, int reg, int value)
 {
-	r8168dp_1_mdio_access(ioaddr, reg_addr, OCPDR_WRITE_CMD |
-		(value & OCPDR_DATA_MASK));
+	r8168dp_1_mdio_access(tp, reg,
+			      OCPDR_WRITE_CMD | (value & OCPDR_DATA_MASK));
 }
 
-static int r8168dp_1_mdio_read(void __iomem *ioaddr, int reg_addr)
+static int r8168dp_1_mdio_read(struct rtl8169_private *tp, int reg)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i;
 
-	r8168dp_1_mdio_access(ioaddr, reg_addr, OCPDR_READ_CMD);
+	r8168dp_1_mdio_access(tp, reg, OCPDR_READ_CMD);
 
 	mdelay(1);
 	RTL_W32(OCPAR, OCPAR_GPHY_READ_CMD);
@@ -1020,22 +1023,25 @@ static void r8168dp_2_mdio_stop(void __iomem *ioaddr)
 	RTL_W32(0xd0, RTL_R32(0xd0) | R8168DP_1_MDIO_ACCESS_BIT);
 }
 
-static void r8168dp_2_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
+static void r8168dp_2_mdio_write(struct rtl8169_private *tp, int reg, int value)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+
 	r8168dp_2_mdio_start(ioaddr);
 
-	r8169_mdio_write(ioaddr, reg_addr, value);
+	r8169_mdio_write(tp, reg, value);
 
 	r8168dp_2_mdio_stop(ioaddr);
 }
 
-static int r8168dp_2_mdio_read(void __iomem *ioaddr, int reg_addr)
+static int r8168dp_2_mdio_read(struct rtl8169_private *tp, int reg)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	int value;
 
 	r8168dp_2_mdio_start(ioaddr);
 
-	value = r8169_mdio_read(ioaddr, reg_addr);
+	value = r8169_mdio_read(tp, reg);
 
 	r8168dp_2_mdio_stop(ioaddr);
 
@@ -1044,12 +1050,12 @@ static int r8168dp_2_mdio_read(void __iomem *ioaddr, int reg_addr)
 
 static void rtl_writephy(struct rtl8169_private *tp, int location, u32 val)
 {
-	tp->mdio_ops.write(tp->mmio_addr, location, val);
+	tp->mdio_ops.write(tp, location, val);
 }
 
 static int rtl_readphy(struct rtl8169_private *tp, int location)
 {
-	return tp->mdio_ops.read(tp->mmio_addr, location);
+	return tp->mdio_ops.read(tp, location);
 }
 
 static void rtl_patchphy(struct rtl8169_private *tp, int reg_addr, int value)
-- 
1.7.10.4
