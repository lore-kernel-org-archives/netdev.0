From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Tue, 25 Jan 2005 22:47:25 +0100
Message-ID: <20050125214725.GA6093@electric-eye.fr.zoreil.com>
References: <41A0F0D5.9050702@phekda.gotadsl.co.uk> <20041121205814.GA22460@electric-eye.fr.zoreil.com> <41A24F35.5080106@phekda.gotadsl.co.uk> <20041122213008.GA9618@electric-eye.fr.zoreil.com> <41D2844E.5070204@phekda.gotadsl.co.uk> <20041229235203.GA5465@electric-eye.fr.zoreil.com> <41F250D1.8000207@phekda.gotadsl.co.uk> <41F26FD1.2060407@phekda.gotadsl.co.uk> <20050122230156.GC24461@electric-eye.fr.zoreil.com> <41F3F632.3060800@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
Content-Disposition: inline
In-Reply-To: <41F3F632.3060800@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

  could you give the patch below some testing ?

Any post-LLTX-revert 2.6.11-rc2-bk should do.

Merge of Realtek's code
- code dedicated to a new phy (spotted by Richard Dawe);
- C+ register fiddling seems required for both RTL_GIGA_MAC_VER_{D/E};
- apart from being reserved, register at address 0xe2 is named 'IntrMitigate';
- bump version number.
  A bunch of people do not use the vanilla kernel module simply because
  Realtek's driver has a higher revision number. This is not an issue per
  se but their driver is buggy due to some partial merge of in-kernel code.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Richard Dawe <rich@phekda.gotadsl.co.uk>

diff -puN drivers/net/r8169.c~r8169-360 drivers/net/r8169.c
--- linux-2.6.11-rc1-bk8/drivers/net/r8169.c~r8169-360	2005-01-25 21:31:58.299916327 +0100
+++ linux-2.6.11-rc1-bk8-fr/drivers/net/r8169.c	2005-01-25 22:25:56.106368294 +0100
@@ -41,6 +41,13 @@ VERSION 1.6LK	<2004/04/14>
 	- Suspend/resume
 	- Endianness
 	- Misc Rx/Tx bugs
+
+VERSION 2.2LK	<2005/01/25>
+
+	- RX csum, TX csum/SG, TSO
+	- VLAN
+	- baby (< 7200) Jumbo frames support
+	- Merge of Realtek's version 2.2 (new phy)
 */
 
 #include <linux/module.h>
@@ -61,7 +68,7 @@ VERSION 1.6LK	<2004/04/14>
 
 #include <asm/io.h>
 
-#define RTL8169_VERSION "1.6LK"
+#define RTL8169_VERSION "2.2LK"
 #define MODULENAME "r8169"
 #define PFX MODULENAME ": "
 
@@ -148,6 +155,7 @@ enum phy_version {
 	RTL_GIGA_PHY_VER_E = 0x05, /* PHY Reg 0x03 bit0-3 == 0x0000 */
 	RTL_GIGA_PHY_VER_F = 0x06, /* PHY Reg 0x03 bit0-3 == 0x0001 */
 	RTL_GIGA_PHY_VER_G = 0x07, /* PHY Reg 0x03 bit0-3 == 0x0002 */
+	RTL_GIGA_PHY_VER_H = 0x08, /* PHY Reg 0x03 bit0-3 == 0x0003 */
 };
 
 
@@ -161,7 +169,8 @@ const static struct {
 } rtl_chip_info[] = {
 	_R("RTL8169",		RTL_GIGA_MAC_VER_B, 0xff7e1880),
 	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_D, 0xff7e1880),
-	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_E, 0xff7e1880)
+	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_E, 0xff7e1880),
+	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_X, 0xff7e1880),
 };
 #undef _R
 
@@ -207,6 +216,7 @@ enum RTL8169_registers {
 	PHYstatus = 0x6C,
 	RxMaxSize = 0xDA,
 	CPlusCmd = 0xE0,
+	IntrMitigate = 0xE2,
 	RxDescAddrLow = 0xE4,
 	RxDescAddrHigh = 0xE8,
 	EarlyTxThres = 0xEC,
@@ -406,7 +416,7 @@ struct rtl8169_private {
 	struct work_struct task;
 };
 
-MODULE_AUTHOR("Realtek");
+MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@oss.sgi.com>");
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
 module_param_array(media, int, &num_media, 0);
 module_param(rx_copybreak, int, 0);
@@ -1001,7 +1011,7 @@ static void rtl8169_hw_phy_config(struct
 
 	if (tp->mac_version <= RTL_GIGA_MAC_VER_B)
 		return;
-	if (tp->phy_version >= RTL_GIGA_PHY_VER_F) 
+	if (tp->phy_version >= RTL_GIGA_PHY_VER_H)
 		return;
 
 	dprintk("MAC version != 0 && PHY version == 0 or 1\n");
@@ -1009,6 +1019,18 @@ static void rtl8169_hw_phy_config(struct
 
 	/* Shazam ! */
 
+	if (tp->mac_version == RTL_GIGA_MAC_VER_X) {
+		mdio_write(ioaddr, 31, 0x0001);
+		mdio_write(ioaddr,  9, 0x273a);
+		mdio_write(ioaddr, 14, 0x7bfb);
+		mdio_write(ioaddr, 27, 0x841e);
+
+		mdio_write(ioaddr, 31, 0x0002);
+		mdio_write(ioaddr,  1, 0x90d0);
+		mdio_write(ioaddr, 31, 0x0000);
+		return;
+	}
+
 	// phy config for RTL8169s mac_version C chip
 	mdio_write(ioaddr, 31, 0x0001);			//w 31 2 0 1
 	mdio_write(ioaddr, 21, 0x1000);			//w 21 15 0 1000
@@ -1037,7 +1059,7 @@ static void rtl8169_phy_timer(unsigned l
 	unsigned long timeout = RTL8169_PHY_TIMEOUT;
 
 	assert(tp->mac_version > RTL_GIGA_MAC_VER_B);
-	assert(tp->phy_version < RTL_GIGA_PHY_VER_G);
+	assert(tp->phy_version < RTL_GIGA_PHY_VER_H);
 
 	if (!(tp->phy_1000_ctrl_reg & PHY_Cap_1000_Full))
 		return;
@@ -1072,7 +1094,7 @@ static inline void rtl8169_delete_timer(
 	struct timer_list *timer = &tp->timer;
 
 	if ((tp->mac_version <= RTL_GIGA_MAC_VER_B) ||
-	    (tp->phy_version >= RTL_GIGA_PHY_VER_G))
+	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
 		return;
 
 	del_timer_sync(timer);
@@ -1084,7 +1106,7 @@ static inline void rtl8169_request_timer
 	struct timer_list *timer = &tp->timer;
 
 	if ((tp->mac_version <= RTL_GIGA_MAC_VER_B) ||
-	    (tp->phy_version >= RTL_GIGA_PHY_VER_G))
+	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
 		return;
 
 	init_timer(timer);
@@ -1562,13 +1584,20 @@ rtl8169_hw_start(struct net_device *dev)
 	tp->cp_cmd |= RTL_R16(CPlusCmd);
 	RTL_W16(CPlusCmd, tp->cp_cmd);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_D) {
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_D) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_E)) {
 		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0. "
 			"Bit-3 and bit-14 MUST be 1\n");
 		tp->cp_cmd |= (1 << 14) | PCIMulRW;
 		RTL_W16(CPlusCmd, tp->cp_cmd);
 	}
 
+	/*
+	 * Undocumented corner. Supposedly:
+	 * (TxTimer << 12) | (TxPackets << 8) | (RxTimer << 4) | RxPackets
+	 */
+	RTL_W16(IntrMitigate, 0x0000);
+
 	RTL_W32(TxDescStartAddrLow, ((u64) tp->TxPhyAddr & DMA_32BIT_MASK));
 	RTL_W32(TxDescStartAddrHigh, ((u64) tp->TxPhyAddr >> 32));
 	RTL_W32(RxDescAddrLow, ((u64) tp->RxPhyAddr & DMA_32BIT_MASK));

_
