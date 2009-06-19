From: Ivan Vecera <ivecera@redhat.com>
Subject: 3rd attempt to initialize MAC address on r8169
Date: Fri, 19 Jun 2009 09:21:25 +0200
Message-ID: <4A3B3C75.5090200@redhat.com>
References: <200903092029.n29KT1DS004531@harpo.it.uu.se> <20090313201511.GA27827@electric-eye.fr.zoreil.com> <9e246b4d0903131921k6fba9b04ge945c2902d4117d0@mail.gmail.com> <18875.38673.270977.133982@pilspetsen.it.uu.se> <20090315100953.GA16632@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>,
	Mikael Pettersson <mikpe@it.uu.se>,
	Tim Durack <tdurack@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34893 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751865AbZFSHVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2009 03:21:33 -0400
In-Reply-To: <20090315100953.GA16632@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu napsal(a):
> Mikael Pettersson <mikpe@it.uu.se> :
> [...]
>> May I suggest that 6709fe9a27e43a4931938fe0d7f2cc5edef31386 is reverted
>> until this regression is debugged and fixed?
> 
> Yes.
> 
Hello guys,
I made 3rd attempt to enable the ability to initialize r8169's MAC address
on initialization. The proposed patch below works for all my Realtek devices,
but you had some issues with the previous one. Could you please test it on your
devices? I would like to close finally this long term issue.

Thanks,
Ivan

---
 drivers/net/r8169.c |   94 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 92 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3b19e0c..60c8811 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -80,9 +80,9 @@ static const int multicast_filter_limit = 32;
 #define RTL8169_TX_TIMEOUT	(6*HZ)
 #define RTL8169_PHY_TIMEOUT	(10*HZ)
 
-#define RTL_EEPROM_SIG		cpu_to_le32(0x8129)
-#define RTL_EEPROM_SIG_MASK	cpu_to_le32(0xffff)
+#define RTL_EEPROM_SIG		0x8129
 #define RTL_EEPROM_SIG_ADDR	0x0000
+#define RTL_EEPROM_MAC_ADDR	0x0007
 
 /* write/read MMIO register */
 #define RTL_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
@@ -292,6 +292,11 @@ enum rtl_register_content {
 	/* Cfg9346Bits */
 	Cfg9346_Lock	= 0x00,
 	Cfg9346_Unlock	= 0xc0,
+	Cfg9346_Program	= 0x88,		/* Programming mode */
+	Cfg9346_EECS	= 0x08,		/* Chip select */
+	Cfg9346_EESK	= 0x04,		/* Serial data clock */
+	Cfg9346_EEDI	= 0x02,		/* Data input */
+	Cfg9346_EEDO	= 0x01,		/* Data output */
 
 	/* rx_mode_bits */
 	AcceptErr	= 0x20,
@@ -304,6 +309,7 @@ enum rtl_register_content {
 	/* RxConfigBits */
 	RxCfgFIFOShift	= 13,
 	RxCfgDMAShift	=  8,
+	RxCfg9356SEL	=  6, 		/* EEPROM type: 0 = 9346, 1 = 9356 */
 
 	/* TxConfigBits */
 	TxInterFrameGapShift = 24,
@@ -1962,6 +1968,88 @@ static const struct net_device_ops rtl8169_netdev_ops = {
 
 };
 
+/* delay between EEPROM clock transitions - force out buffered PCI writes. */
+#define RTL_EEPROM_DELAY()	(void)RTL_R8(Cfg9346)
+#define RTL_EEPROM_READ_CMD	6
+
+/* read 16bit word stored in EEPROM. EEPROM is addressed by words. */
+static u16 rtl_eeprom_read(void __iomem *ioaddr, int addr)
+{
+	int read_cmd, addr_len, i;
+	u16 result = 0;
+
+	/* check for EEPROM address size (in bits) */
+	addr_len = (RTL_R32(RxConfig) & (1 << RxCfg9356SEL)) ? 8 : 6;
+	read_cmd = addr | (RTL_EEPROM_READ_CMD << addr_len);
+
+	/* enter programming mode */
+	RTL_W8(Cfg9346, Cfg9346_Program & ~Cfg9346_EECS);
+	RTL_W8(Cfg9346, Cfg9346_Program);
+	RTL_EEPROM_DELAY();
+
+	/* shift out read command and requested address */
+	for (i = 4 + addr_len; i >= 0; i--) {
+		int val = (read_cmd & (1 << i)) ? Cfg9346_EEDI : 0;
+		RTL_W8(Cfg9346, Cfg9346_Program | val);
+		RTL_EEPROM_DELAY();
+		RTL_W8(Cfg9346, Cfg9346_Program | val | Cfg9346_EESK);
+		RTL_EEPROM_DELAY();
+	}
+	RTL_W8(Cfg9346, Cfg9346_Program);
+	RTL_EEPROM_DELAY();
+
+	/* read back 16bit value */
+	for (i = 16; i > 0; i--) {
+		RTL_W8(Cfg9346, Cfg9346_Program | Cfg9346_EESK);
+		RTL_EEPROM_DELAY();
+
+		result <<= 1;
+		result |= (RTL_R8 (Cfg9346) & Cfg9346_EEDO) ? 1 : 0;
+
+		RTL_W8(Cfg9346, Cfg9346_Program);
+		RTL_EEPROM_DELAY();
+	}
+
+	/* leave programming mode - lock configuration */
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+	RTL_EEPROM_DELAY();
+
+	return result;
+}
+
+static void rtl_init_mac_address(struct rtl8169_private *tp,
+				 void __iomem *ioaddr)
+{
+	struct pci_dev *pdev = tp->pci_dev;
+	int i;
+	u16 x;
+	u8 mac[8];
+
+	/* read EEPROM signature */
+	x = rtl_eeprom_read(ioaddr, RTL_EEPROM_SIG_ADDR);
+	if (x != RTL_EEPROM_SIG) {
+		dev_info(&pdev->dev, "Missing EEPROM signature: %04x\n", x);
+		return;
+	}
+
+	/* read MAC address */
+	for (i = 0; i < 3; i++) {
+		x = rtl_eeprom_read(ioaddr, RTL_EEPROM_MAC_ADDR + i);
+		mac[i*2] = x & 0xff;
+		mac[i*2+1] = x >> 8;
+	}
+
+	if (netif_msg_probe(tp)) {
+		DECLARE_MAC_BUF(buf);
+
+		dev_info(&pdev->dev, "MAC address found in EEPROM: %s\n",
+			 print_mac(buf, mac));
+	}
+
+	if (is_valid_ether_addr(mac))
+		rtl_rar_set(tp, mac);
+}
+
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -2141,6 +2229,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	tp->mmio_addr = ioaddr;
 
+	rtl_init_mac_address(tp, ioaddr);
+
 	/* Get MAC address */
 	for (i = 0; i < MAC_ADDR_LEN; i++)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
-- 
1.6.0.4

