From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 4/6] r8169: phy init for the 8169scd
Date: Tue, 11 Aug 2009 07:44:19 +0200
Message-ID: <20090811054419.GE16446@electric-eye.fr.zoreil.com>
References: <20090811054039.GA16446@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edward_hsu@realtek.com.tw, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60962 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751677AbZHKLyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 07:54:06 -0400
Content-Disposition: inline
In-Reply-To: <20090811054039.GA16446@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Synced with Realtek's 6.011.00 r8169 driver.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c     |   68 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/pci_ids.h |    2 +
 2 files changed, 70 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 8672288..4470fef 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1389,6 +1389,71 @@ static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
+static void rtl8169scd_hw_phy_config_quirk(struct rtl8169_private *tp,
+					   void __iomem *ioaddr)
+{
+	struct pci_dev *pdev = tp->pci_dev;
+	u16 vendor_id, device_id;
+
+	pci_read_config_word(pdev, PCI_SUBSYSTEM_VENDOR_ID, &vendor_id);
+	pci_read_config_word(pdev, PCI_SUBSYSTEM_ID, &device_id);
+
+	if ((vendor_id != PCI_VENDOR_ID_GIGABYTE) || (device_id != 0xe000))
+		return;
+
+	mdio_write(ioaddr, 0x1f, 0x0001);
+	mdio_write(ioaddr, 0x10, 0xf01b);
+	mdio_write(ioaddr, 0x1f, 0x0000);
+}
+
+static void rtl8169scd_hw_phy_config(struct rtl8169_private *tp,
+				     void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x04, 0x0000 },
+		{ 0x03, 0x00a1 },
+		{ 0x02, 0x0008 },
+		{ 0x01, 0x0120 },
+		{ 0x00, 0x1000 },
+		{ 0x04, 0x0800 },
+		{ 0x04, 0x9000 },
+		{ 0x03, 0x802f },
+		{ 0x02, 0x4f02 },
+		{ 0x01, 0x0409 },
+		{ 0x00, 0xf099 },
+		{ 0x04, 0x9800 },
+		{ 0x04, 0xa000 },
+		{ 0x03, 0xdf01 },
+		{ 0x02, 0xdf20 },
+		{ 0x01, 0xff95 },
+		{ 0x00, 0xba00 },
+		{ 0x04, 0xa800 },
+		{ 0x04, 0xf000 },
+		{ 0x03, 0xdf01 },
+		{ 0x02, 0xdf20 },
+		{ 0x01, 0x101a },
+		{ 0x00, 0xa0ff },
+		{ 0x04, 0xf800 },
+		{ 0x04, 0x0000 },
+		{ 0x1f, 0x0000 },
+
+		{ 0x1f, 0x0001 },
+		{ 0x10, 0xf41b },
+		{ 0x14, 0xfb54 },
+		{ 0x18, 0xf5c7 },
+		{ 0x1f, 0x0000 },
+
+		{ 0x1f, 0x0001 },
+		{ 0x17, 0x0cc0 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	rtl8169scd_hw_phy_config_quirk(tp, ioaddr);
+}
+
 static void rtl8169sce_hw_phy_config(void __iomem *ioaddr)
 {
 	struct phy_reg phy_reg_init[] = {
@@ -1681,6 +1746,9 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_04:
 		rtl8169sb_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_05:
+		rtl8169scd_hw_phy_config(tp, ioaddr);
+		break;
 	case RTL_GIGA_MAC_VER_06:
 		rtl8169sce_hw_phy_config(ioaddr);
 		break;
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 73b46b6..fdc3110 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1984,6 +1984,8 @@
 
 #define PCI_VENDOR_ID_SAMSUNG		0x144d
 
+#define PCI_VENDOR_ID_GIGABYTE		0x1458
+
 #define PCI_VENDOR_ID_AMBIT		0x1468
 
 #define PCI_VENDOR_ID_MYRICOM		0x14c1
-- 
1.6.2.5

