From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH] r8169: read MAC address from EEPROM on init
Date: Thu, 18 Sep 2008 15:46:10 +0200
Message-ID: <48D25BA2.6070008@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58056 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753030AbYIRNto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 09:49:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the problem when MAC address is set by ifconfig or by
ip link commands and this address is stored in the device after
reboot. The power-off is needed to get right MAC address.
This is problem when Xen daemon is running because it renames the device
name from ethX to pethX and sets its MAC address to FE:FF:FF:FF:FF:FF.
After reboot the device is still using FE:FF:FF:FF:FF:FF.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/r8169.c |   80 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 79 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index befc927..b09a4ec 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1910,6 +1910,81 @@ static void rtl_disable_msi(struct pci_dev *pdev, struct rtl8169_private *tp)
 	}
 }

+static int rtl_eeprom_read(struct pci_dev *pdev, int cap, int addr, u32 *val)
+{
+	int ret, count = 100;
+	u16 status = 0;
+	u32 value;
+
+	ret = pci_write_config_word(pdev, cap + PCI_VPD_ADDR, addr);
+	if (ret < 0)
+		return ret;
+
+	do {
+		udelay(10);
+		ret = pci_read_config_word(pdev, cap + PCI_VPD_ADDR, &status);
+		if (ret < 0)
+			return ret;
+	} while (!(status & PCI_VPD_ADDR_F) && --count);
+
+	if (!(status & PCI_VPD_ADDR_F))
+		return -ETIMEDOUT;
+
+	ret = pci_read_config_dword(pdev, cap + PCI_VPD_DATA, &value);
+	if (ret < 0)
+		return ret;
+
+	*val = cpu_to_le32(value);
+
+	return 0;
+}
+
+static void rtl_init_mac_address(struct rtl8169_private *tp,
+				 void __iomem *ioaddr)
+{
+	u8 cfg1;
+	int vpd_cap;
+	u32 low, high;
+
+	cfg1 = RTL_R8(Config1);
+	if (!(cfg1  & VPD)) {
+		dprintk("VPD access not enabled, enabling\n");
+		RTL_W8(Cfg9346, Cfg9346_Unlock);
+		RTL_W8(Config1, cfg1 | VPD);
+		RTL_W8(Cfg9346, Cfg9346_Lock);
+	}
+
+	vpd_cap = pci_find_capability(tp->pci_dev, PCI_CAP_ID_VPD);
+	if (!vpd_cap)
+		return;
+
+	/* MAC address is stored in EEPROM at offset 0x0e
+	 * Realtek says: "The VPD address does not have to be a DWORD-aligned
+	 * address as defined in the PCI 2.2 Specifications, but the VPD data
+	 * is always consecutive 4-byte data starting from the VPD address
+	 * specified."
+	 */
+	if (rtl_eeprom_read(tp->pci_dev, vpd_cap, 0x000e, &low) < 0 ||
+	    rtl_eeprom_read(tp->pci_dev, vpd_cap, 0x0012, &high) < 0) {
+		dprintk("Reading MAC address from EEPROM failed\n");
+		return;
+	}
+
+	/* Mask hi-word */
+	high &= 0xffff;
+
+	dprintk("MAC address found in EEPROM: "
+		"%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n",
+		((u8*)&low)[0], ((u8*)&low)[1], ((u8*)&low)[2],
+		((u8*)&low)[3], ((u8*)&high)[0], ((u8*)&high)[1]);
+
+	/* Write MAC address */
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+	RTL_W32(MAC0, low);
+	RTL_W32(MAC4, high);
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+}
+
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -2079,7 +2154,10 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev->do_ioctl = rtl8169_ioctl;
 	}

-	/* Get MAC address.  FIXME: read EEPROM */
+	/* Read MAC address from EEPROM */
+	rtl_init_mac_address(tp, ioaddr);
+
+	/* Get MAC address */
 	for (i = 0; i < MAC_ADDR_LEN; i++)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
-- 
1.5.4.3
