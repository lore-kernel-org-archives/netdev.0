From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 0/2] Pull request for 'r8169-fixes' branch
Date: Thu, 16 Oct 2008 23:45:55 +0200
Message-ID: <20081016214555.GA27208@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>,
	Martin Capitanio <c4p7n@capitanio.org>,
	Petr Vandrovec <petr@vandrovec.name>,
	Plamen Petrov <pvp-lsts@fs.ru.acad.bg>,
	=?unknown-8bit?B?Si5BLiBNYWdhbGzDs24=?= <jamagallon@ono.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:53880 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754744AbYJPVrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 17:47:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'r8169-fixes' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169-fixes

to get the changes below.

Distance from 'davem-fixes' (8fa0b315fc0c1a414da1371f1fc39523a657c192)
----------------------------------------------------------------------

4f2e025bf9881b3dfcddbebd30c3ad65a748c296
18eb1b8ec3970595a0081770f6b5e134aaa07ba3

Diffstat
--------

 drivers/net/r8169.c |   38 ++++++++++++++++++++++++++++++--------
 1 files changed, 30 insertions(+), 8 deletions(-)

Shortlog
--------

Francois Romieu (2):
      r8169: verbose mac address init
      r8169: checks against wrong mac addresse init

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c821da2..2b4e975 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -81,6 +81,10 @@ static const int multicast_filter_limit = 32;
 #define RTL8169_TX_TIMEOUT	(6*HZ)
 #define RTL8169_PHY_TIMEOUT	(10*HZ)
 
+#define RTL_EEPROM_SIG		cpu_to_le32(0x8129)
+#define RTL_EEPROM_SIG_MASK	cpu_to_le32(0xffff)
+#define RTL_EEPROM_SIG_ADDR	0x0000
+
 /* write/read MMIO register */
 #define RTL_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
 #define RTL_W16(reg, val16)	writew ((val16), ioaddr + (reg))
@@ -1944,14 +1948,15 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
 				 void __iomem *ioaddr)
 {
 	struct pci_dev *pdev = tp->pci_dev;
-	u8 cfg1;
 	int vpd_cap;
+	__le32 sig;
 	u8 mac[8];
-	DECLARE_MAC_BUF(buf);
+	u8 cfg1;
 
 	cfg1 = RTL_R8(Config1);
 	if (!(cfg1  & VPD)) {
-		dprintk("VPD access not enabled, enabling\n");
+		if (netif_msg_probe(tp))
+			dev_info(&pdev->dev, "VPD access disabled, enabling\n");
 		RTL_W8(Cfg9346, Cfg9346_Unlock);
 		RTL_W8(Config1, cfg1 | VPD);
 		RTL_W8(Cfg9346, Cfg9346_Lock);
@@ -1961,7 +1966,16 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
 	if (!vpd_cap)
 		return;
 
-	/* MAC address is stored in EEPROM at offset 0x0e
+	if (rtl_eeprom_read(pdev, vpd_cap, RTL_EEPROM_SIG_ADDR, &sig) < 0)
+		return;
+
+	if ((sig & RTL_EEPROM_SIG_MASK) != RTL_EEPROM_SIG) {
+		dev_info(&pdev->dev, "Missing EEPROM signature: %08x\n", sig);
+		return;
+	}
+
+	/*
+	 * MAC address is stored in EEPROM at offset 0x0e
 	 * Realtek says: "The VPD address does not have to be a DWORD-aligned
 	 * address as defined in the PCI 2.2 Specifications, but the VPD data
 	 * is always consecutive 4-byte data starting from the VPD address
@@ -1969,14 +1983,22 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
 	 */
 	if (rtl_eeprom_read(pdev, vpd_cap, 0x000e, (__le32*)&mac[0]) < 0 ||
 	    rtl_eeprom_read(pdev, vpd_cap, 0x0012, (__le32*)&mac[4]) < 0) {
-		dprintk("Reading MAC address from EEPROM failed\n");
+		if (netif_msg_probe(tp)) {
+			dev_warn(&pdev->dev,
+				 "reading MAC address from EEPROM failed\n");
+		}
 		return;
 	}
 
-	dprintk("MAC address found in EEPROM: %s\n", print_mac(buf, mac));
+	if (netif_msg_probe(tp)) {
+		DECLARE_MAC_BUF(buf);
+
+		dev_info(&pdev->dev, "MAC address found in EEPROM: %s\n",
+			 print_mac(buf, mac));
+	}
 
-	/* Write MAC address */
-	rtl_rar_set(tp, mac);
+	if (is_valid_ether_addr(mac))
+		rtl_rar_set(tp, mac);
 }
 
 static int __devinit
-- 
Ueimor
