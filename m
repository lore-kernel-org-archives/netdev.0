From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/1] r8169: revert "read MAC address from EEPROM on init"
Date: Sun, 26 Oct 2008 17:02:49 +0100
Message-ID: <20081026160249.GA25443@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alistair John Strachan <alistair@devzero.co.uk>,
	Ivan Vecera <ivecera@redhat.com>,
	Chuck Ebbert <cebbert@redhat.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Petr Vandrovec <petr@vandrovec.name>,
	Plamen Petrov <pvp-lsts@fs.ru.acad.bg>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	=?iso-8859-1?Q?J=2EA=2E_Magall=F3n?= <jamagallon@ono.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	Simon Arlott <simon@fire.lp0.eu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:53148 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755108AbYJZQKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 12:10:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 7bf6bf4803df1adc927f585168d2135fb019c698.

The code has both a short existence and an increasing track
of failures despite some work to amend it for -rc1. It is not
just a matter of reading the eeprom: sometimes the eeprom is
read correctly, then the mac address is not written correctly
back into the mac registers.

Some chipsets seem to work reliably but it is not clear at
this point if the code can simply be made to work on a
per-chipset basis and post -rc1 is not the place where I want
to experiment these things.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   88 ---------------------------------------------------
 1 files changed, 0 insertions(+), 88 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 2b4e975..4b7cb38 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1915,92 +1915,6 @@ static void rtl_disable_msi(struct pci_dev *pdev, struct rtl8169_private *tp)
 	}
 }
 
-static int rtl_eeprom_read(struct pci_dev *pdev, int cap, int addr, __le32 *val)
-{
-	int ret, count = 100;
-	u16 status = 0;
-	u32 value;
-
-	ret = pci_write_config_word(pdev, cap + PCI_VPD_ADDR, addr);
-	if (ret < 0)
-		return ret;
-
-	do {
-		udelay(10);
-		ret = pci_read_config_word(pdev, cap + PCI_VPD_ADDR, &status);
-		if (ret < 0)
-			return ret;
-	} while (!(status & PCI_VPD_ADDR_F) && --count);
-
-	if (!(status & PCI_VPD_ADDR_F))
-		return -ETIMEDOUT;
-
-	ret = pci_read_config_dword(pdev, cap + PCI_VPD_DATA, &value);
-	if (ret < 0)
-		return ret;
-
-	*val = cpu_to_le32(value);
-
-	return 0;
-}
-
-static void rtl_init_mac_address(struct rtl8169_private *tp,
-				 void __iomem *ioaddr)
-{
-	struct pci_dev *pdev = tp->pci_dev;
-	int vpd_cap;
-	__le32 sig;
-	u8 mac[8];
-	u8 cfg1;
-
-	cfg1 = RTL_R8(Config1);
-	if (!(cfg1  & VPD)) {
-		if (netif_msg_probe(tp))
-			dev_info(&pdev->dev, "VPD access disabled, enabling\n");
-		RTL_W8(Cfg9346, Cfg9346_Unlock);
-		RTL_W8(Config1, cfg1 | VPD);
-		RTL_W8(Cfg9346, Cfg9346_Lock);
-	}
-
-	vpd_cap = pci_find_capability(pdev, PCI_CAP_ID_VPD);
-	if (!vpd_cap)
-		return;
-
-	if (rtl_eeprom_read(pdev, vpd_cap, RTL_EEPROM_SIG_ADDR, &sig) < 0)
-		return;
-
-	if ((sig & RTL_EEPROM_SIG_MASK) != RTL_EEPROM_SIG) {
-		dev_info(&pdev->dev, "Missing EEPROM signature: %08x\n", sig);
-		return;
-	}
-
-	/*
-	 * MAC address is stored in EEPROM at offset 0x0e
-	 * Realtek says: "The VPD address does not have to be a DWORD-aligned
-	 * address as defined in the PCI 2.2 Specifications, but the VPD data
-	 * is always consecutive 4-byte data starting from the VPD address
-	 * specified."
-	 */
-	if (rtl_eeprom_read(pdev, vpd_cap, 0x000e, (__le32*)&mac[0]) < 0 ||
-	    rtl_eeprom_read(pdev, vpd_cap, 0x0012, (__le32*)&mac[4]) < 0) {
-		if (netif_msg_probe(tp)) {
-			dev_warn(&pdev->dev,
-				 "reading MAC address from EEPROM failed\n");
-		}
-		return;
-	}
-
-	if (netif_msg_probe(tp)) {
-		DECLARE_MAC_BUF(buf);
-
-		dev_info(&pdev->dev, "MAC address found in EEPROM: %s\n",
-			 print_mac(buf, mac));
-	}
-
-	if (is_valid_ether_addr(mac))
-		rtl_rar_set(tp, mac);
-}
-
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -2178,8 +2092,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	tp->mmio_addr = ioaddr;
 
-	rtl_init_mac_address(tp, ioaddr);
-
 	/* Get MAC address */
 	for (i = 0; i < MAC_ADDR_LEN; i++)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
-- 
1.5.3.3

