From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 5/6] r8169: add hw start helpers for the 8168 and the 8101
Date: Sun, 17 Aug 2008 18:29:29 +0200
Message-ID: <20080817162929.GF18690@electric-eye.fr.zoreil.com>
References: <20080817162330.GA18690@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41330 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751445AbYHQQa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 12:30:28 -0400
Content-Disposition: inline
In-Reply-To: <20080817162330.GA18690@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit triggers three 'defined but not used' warnings but
I prefer avoiding to tie these helpers to a specific change in
the hw start sequences of the 8168 or of the 8101.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   96 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 96 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 600540e..f4ad9ff 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -526,6 +526,11 @@ static int mdio_read(void __iomem *ioaddr, int reg_addr)
 	return value;
 }
 
+static void mdio_patch(void __iomem *ioaddr, int reg_addr, int value)
+{
+	mdio_write(ioaddr, reg_addr, mdio_read(ioaddr, reg_addr) | value);
+}
+
 static void rtl_mdio_write(struct net_device *dev, int phy_id, int location,
 			   int val)
 {
@@ -543,6 +548,72 @@ static int rtl_mdio_read(struct net_device *dev, int phy_id, int location)
 	return mdio_read(ioaddr, location);
 }
 
+static void rtl_ephy_write(void __iomem *ioaddr, int reg_addr, int value)
+{
+	unsigned int i;
+
+	RTL_W32(EPHYAR, EPHYAR_WRITE_CMD | (value & EPHYAR_DATA_MASK) |
+		(reg_addr & EPHYAR_REG_MASK) << EPHYAR_REG_SHIFT);
+
+	for (i = 0; i < 100; i++) {
+		if (!(RTL_R32(EPHYAR) & EPHYAR_FLAG))
+			break;
+		udelay(10);
+	}
+}
+
+static u16 rtl_ephy_read(void __iomem *ioaddr, int reg_addr)
+{
+	u16 value = 0xffff;
+	unsigned int i;
+
+	RTL_W32(EPHYAR, (reg_addr & EPHYAR_REG_MASK) << EPHYAR_REG_SHIFT);
+
+	for (i = 0; i < 100; i++) {
+		if (RTL_R32(EPHYAR) & EPHYAR_FLAG) {
+			value = RTL_R32(EPHYAR) & EPHYAR_DATA_MASK;
+			break;
+		}
+		udelay(10);
+	}
+
+	return value;
+}
+
+static void rtl_csi_write(void __iomem *ioaddr, int addr, int value)
+{
+	unsigned int i;
+
+	RTL_W32(CSIDR, value);
+	RTL_W32(CSIAR, CSIAR_WRITE_CMD | (addr & CSIAR_ADDR_MASK) |
+		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
+
+	for (i = 0; i < 100; i++) {
+		if (!(RTL_R32(CSIAR) & CSIAR_FLAG))
+			break;
+		udelay(10);
+	}
+}
+
+static u32 rtl_csi_read(void __iomem *ioaddr, int addr)
+{
+	u32 value = ~0x00;
+	unsigned int i;
+
+	RTL_W32(CSIAR, (addr & CSIAR_ADDR_MASK) |
+		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
+
+	for (i = 0; i < 100; i++) {
+		if (RTL_R32(CSIAR) & CSIAR_FLAG) {
+			value = RTL_R32(CSIDR);
+			break;
+		}
+		udelay(10);
+	}
+
+	return value;
+}
+
 static void rtl8169_irq_mask_and_ack(void __iomem *ioaddr)
 {
 	RTL_W16(IntrMask, 0x0000);
@@ -2114,6 +2185,31 @@ static void rtl_tx_performance_tweak(struct pci_dev *pdev, u16 force)
 	}
 }
 
+static void rtl_csi_access_enable(void __iomem *ioaddr)
+{
+	u32 csi;
+
+	csi = rtl_csi_read(ioaddr, 0x070c) & 0x00ffffff;
+	rtl_csi_write(ioaddr, 0x070c, csi | 0x27000000);
+}
+
+struct ephy_info {
+	unsigned int offset;
+	u16 mask;
+	u16 bits;
+};
+
+static void rtl_ephy_init(void __iomem *ioaddr, struct ephy_info *e, int len)
+{
+	u16 w;
+
+	while (len-- > 0) {
+		w = (rtl_ephy_read(ioaddr, e->offset) & ~e->mask) | e->bits;
+		rtl_ephy_write(ioaddr, e->offset, w);
+		e++;
+	}
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-- 
1.5.3.3

