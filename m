From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/2] r8169: revert "r8169: read MAC address from EEPROM on
	init (2nd attempt)"
Date: Sun, 15 Mar 2009 12:10:50 +0100
Message-ID: <20090315111050.GB17800@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>, Mikael Pettersson <mikpe@it.uu.se>,
	Tim Durack <tdurack@gmail.com>, ivecera@redhat.com,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52291 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752488AbZCOLKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2009 07:10:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It fails on the following systems:
- RTL8169sc/8110sc (XID 18000000)
  reported by Tim Durack <tdurack@gmail.com> (x86)
- RTL8169sb/8110sb (XID 10000000)
  reported by Mikael Pettersson <mikpe@it.uu.se> (ARM)

The patch appeared to work on x86 for the following systems:
RTL8169sb/8110sb 10000000 PCI   (EXT)
RTL8110s         04000000 PCI   (EXT)
RTL8102e         24a00000 PCI-E (LOM)
RTL8168c/8111c   3c2000c0 PCI-E (LOM)
RTL8168b/8111b   38000000 PCI-E (LOM)
RTL8168b/8111b   38000000 PCI-E (EXT)

The patch exposes two problems:
1) while not completely wrong, mac addresses are not read correctly
   from the EEPROM
2) the MAC address registers are not correctly set

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |  114 +--------------------------------------------------
 1 files changed, 2 insertions(+), 112 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 352da2a..43fedb9 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -81,9 +81,9 @@ static const int multicast_filter_limit = 32;
 #define RTL8169_TX_TIMEOUT	(6*HZ)
 #define RTL8169_PHY_TIMEOUT	(10*HZ)
 
-#define RTL_EEPROM_SIG		0x8129
+#define RTL_EEPROM_SIG		cpu_to_le32(0x8129)
+#define RTL_EEPROM_SIG_MASK	cpu_to_le32(0xffff)
 #define RTL_EEPROM_SIG_ADDR	0x0000
-#define RTL_EEPROM_MAC_ADDR	0x0007
 
 /* write/read MMIO register */
 #define RTL_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
@@ -293,11 +293,6 @@ enum rtl_register_content {
 	/* Cfg9346Bits */
 	Cfg9346_Lock	= 0x00,
 	Cfg9346_Unlock	= 0xc0,
-	Cfg9346_Program	= 0x80,		/* Programming mode */
-	Cfg9346_EECS	= 0x08,		/* Chip select */
-	Cfg9346_EESK	= 0x04,		/* Serial data clock */
-	Cfg9346_EEDI	= 0x02,		/* Data input */
-	Cfg9346_EEDO	= 0x01,		/* Data output */
 
 	/* rx_mode_bits */
 	AcceptErr	= 0x20,
@@ -310,7 +305,6 @@ enum rtl_register_content {
 	/* RxConfigBits */
 	RxCfgFIFOShift	= 13,
 	RxCfgDMAShift	=  8,
-	RxCfg9356SEL	=  6, 		/* EEPROM type: 0 = 9346, 1 = 9356 */
 
 	/* TxConfigBits */
 	TxInterFrameGapShift = 24,
@@ -1969,108 +1963,6 @@ static const struct net_device_ops rtl8169_netdev_ops = {
 
 };
 
-/* Delay between EEPROM clock transitions. Force out buffered PCI writes. */
-#define RTL_EEPROM_DELAY()	RTL_R8(Cfg9346)
-#define RTL_EEPROM_READ_CMD	6
-
-/* read 16bit word stored in EEPROM. EEPROM is addressed by words. */
-static u16 rtl_eeprom_read(void __iomem *ioaddr, int addr)
-{
-	u16 result = 0;
-	int cmd, cmd_len, i;
-
-	/* check for EEPROM address size (in bits) */
-	if (RTL_R32(RxConfig) & (1 << RxCfg9356SEL)) {
-		/* EEPROM is 93C56 */
-		cmd_len = 3 + 8; /* 3 bits for command id and 8 for address */
-		cmd = (RTL_EEPROM_READ_CMD << 8) | (addr & 0xff);
-	} else {
-		/* EEPROM is 93C46 */
-		cmd_len = 3 + 6; /* 3 bits for command id and 6 for address */
-		cmd = (RTL_EEPROM_READ_CMD << 6) | (addr & 0x3f);
-	}
-
-	/* enter programming mode */
-	RTL_W8(Cfg9346, Cfg9346_Program | Cfg9346_EECS);
-	RTL_EEPROM_DELAY();
-
-	/* write command and requested address */
-	while (cmd_len--) {
-		u8 x = Cfg9346_Program | Cfg9346_EECS;
-
-		x |= (cmd & (1 << cmd_len)) ? Cfg9346_EEDI : 0;
-
-		/* write a bit */
-		RTL_W8(Cfg9346, x);
-		RTL_EEPROM_DELAY();
-
-		/* raise clock */
-		RTL_W8(Cfg9346, x | Cfg9346_EESK);
-		RTL_EEPROM_DELAY();
-	}
-
-	/* lower clock */
-	RTL_W8(Cfg9346, Cfg9346_Program | Cfg9346_EECS);
-	RTL_EEPROM_DELAY();
-
-	/* read back 16bit value */
-	for (i = 16; i > 0; i--) {
-		/* raise clock */
-		RTL_W8(Cfg9346, Cfg9346_Program | Cfg9346_EECS | Cfg9346_EESK);
-		RTL_EEPROM_DELAY();
-
-		result <<= 1;
-		result |= (RTL_R8(Cfg9346) & Cfg9346_EEDO) ? 1 : 0;
-
-		/* lower clock */
-		RTL_W8(Cfg9346, Cfg9346_Program | Cfg9346_EECS);
-		RTL_EEPROM_DELAY();
-	}
-
-	RTL_W8(Cfg9346, Cfg9346_Program);
-	/* leave programming mode */
-	RTL_W8(Cfg9346, Cfg9346_Lock);
-
-	return result;
-}
-
-static void rtl_init_mac_address(struct rtl8169_private *tp,
-				 void __iomem *ioaddr)
-{
-	struct pci_dev *pdev = tp->pci_dev;
-	u16 x;
-	u8 mac[8];
-
-	/* read EEPROM signature */
-	x = rtl_eeprom_read(ioaddr, RTL_EEPROM_SIG_ADDR);
-
-	if (x != RTL_EEPROM_SIG) {
-		dev_info(&pdev->dev, "Missing EEPROM signature: %04x\n", x);
-		return;
-	}
-
-	/* read MAC address */
-	x = rtl_eeprom_read(ioaddr, RTL_EEPROM_MAC_ADDR);
-	mac[0] = x & 0xff;
-	mac[1] = x >> 8;
-	x = rtl_eeprom_read(ioaddr, RTL_EEPROM_MAC_ADDR + 1);
-	mac[2] = x & 0xff;
-	mac[3] = x >> 8;
-	x = rtl_eeprom_read(ioaddr, RTL_EEPROM_MAC_ADDR + 2);
-	mac[4] = x & 0xff;
-	mac[5] = x >> 8;
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
@@ -2249,8 +2141,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	tp->mmio_addr = ioaddr;
 
-	rtl_init_mac_address(tp, ioaddr);
-
 	/* Get MAC address */
 	for (i = 0; i < MAC_ADDR_LEN; i++)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
-- 
1.6.0.6

