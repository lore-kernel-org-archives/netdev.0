From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Sat, 22 Jan 2005 15:22:57 +0000
Message-ID: <41F26FD1.2060407@phekda.gotadsl.co.uk>
References: <41A09541.5040405@phekda.gotadsl.co.uk> <41A0F0D5.9050702@phekda.gotadsl.co.uk> <20041121205814.GA22460@electric-eye.fr.zoreil.com> <41A24F35.5080106@phekda.gotadsl.co.uk> <20041122213008.GA9618@electric-eye.fr.zoreil.com> <41D2844E.5070204@phekda.gotadsl.co.uk> <20041229235203.GA5465@electric-eye.fr.zoreil.com> <41F250D1.8000207@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090001080507050808000603"
Cc: Richard Dawe <rich@phekda.gotadsl.co.uk>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <41F250D1.8000207@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090001080507050808000603
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hello.

I've done some more investigation and I'm happy to report that I managed 
to get some decent network performance out of my laptop - 7.1Mbps.

My laptop seems to have an embedded PHY rather than the separate PHY 
that they normally come with.

The MAC config data is 0x13000000, which masked off with 0x7c800000 
gives 0x10000000, which is RTL_GIGA_MAC_VER_X. The PHY data is 0xc912, 
which masked off with 0x000f gives 0x0002, which is RTL_GIGA_PHY_VER_G.

So I looked at the latest RealTek driver for Linux (version 220) and 
that has some separate initialisation code for RTL_GIGA_MAC_VER_X 
(MCFG_METHOD_4, they call it). I ported that over to r8169.c in 
2.6.11-rc1 and it appears to work.

Attached is the patch against 2.6.11-rc1. I'm not sure if it caters to 
your tastes. Maybe you'll want to rename RTL_GIGA_MAC_VER_X. 
RTL_GIGA_PHY_VER_H is an invented version, to indicate end-of-list, like 
RTL_GIGA_PHY_VER_G was before.

I'm going to give this a good hammering now by rsync'ing about 20GB of 
data. Hopefully it'll hold up.

Bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek

--------------090001080507050808000603
Content-Type: text/plain;
 name="r8169-embedded-phy-20050122.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="r8169-embedded-phy-20050122.diff"

--- r8169.c	2005-01-12 04:00:58.000000000 +0000
+++ r8169new.c	2005-01-22 15:01:05.000000000 +0000
@@ -148,6 +148,7 @@ enum phy_version {
 	RTL_GIGA_PHY_VER_E = 0x05, /* PHY Reg 0x03 bit0-3 == 0x0000 */
 	RTL_GIGA_PHY_VER_F = 0x06, /* PHY Reg 0x03 bit0-3 == 0x0001 */
 	RTL_GIGA_PHY_VER_G = 0x07, /* PHY Reg 0x03 bit0-3 == 0x0002 */
+	RTL_GIGA_PHY_VER_H = 0x08, /* PHY Reg 0x03 bit0-3 == 0x0003 */
 };
 
 
@@ -161,7 +162,8 @@ const static struct {
 } rtl_chip_info[] = {
 	_R("RTL8169",		RTL_GIGA_MAC_VER_B, 0xff7e1880),
 	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_D, 0xff7e1880),
-	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_E, 0xff7e1880)
+	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_E, 0xff7e1880),
+	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_X, 0xff7e1880),
 };
 #undef _R
 
@@ -1001,7 +1003,7 @@ static void rtl8169_hw_phy_config(struct
 
 	if (tp->mac_version <= RTL_GIGA_MAC_VER_B)
 		return;
-	if (tp->phy_version >= RTL_GIGA_PHY_VER_F) 
+	if (tp->phy_version >= RTL_GIGA_PHY_VER_H) 
 		return;
 
 	dprintk("MAC version != 0 && PHY version == 0 or 1\n");
@@ -1009,11 +1011,25 @@ static void rtl8169_hw_phy_config(struct
 
 	/* Shazam ! */
 
-	// phy config for RTL8169s mac_version C chip
-	mdio_write(ioaddr, 31, 0x0001);			//w 31 2 0 1
-	mdio_write(ioaddr, 21, 0x1000);			//w 21 15 0 1000
-	mdio_write(ioaddr, 24, 0x65c7);			//w 24 15 0 65c7
-	rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 0);	//w 4 11 11 0
+	if (tp->mac_version == RTL_GIGA_MAC_VER_X)
+	{
+	  mdio_write(ioaddr, 0x1f, 0x0001);
+	  mdio_write(ioaddr, 0x09, 0x273a);
+	  mdio_write(ioaddr, 0x0e, 0x7bfb);
+	  mdio_write(ioaddr, 0x1b, 0x841e);
+
+	  mdio_write(ioaddr, 0x1f, 0x0002);
+	  mdio_write(ioaddr, 0x01, 0x90d0);
+	  mdio_write(ioaddr, 0x1f, 0x0000);
+	}
+	else
+	{
+	  // phy config for RTL8169s mac_version C chip
+	  mdio_write(ioaddr, 31, 0x0001);		//w 31 2 0 1
+	  mdio_write(ioaddr, 21, 0x1000);		//w 21 15 0 1000
+	  mdio_write(ioaddr, 24, 0x65c7);		//w 24 15 0 65c7
+	  rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 0);	//w 4 11 11 0
+	}
 
 	for (i = 0; i < ARRAY_SIZE(phy_magic); i++, p++) {
 		int val, pos = 4;
@@ -1037,7 +1053,7 @@ static void rtl8169_phy_timer(unsigned l
 	unsigned long timeout = RTL8169_PHY_TIMEOUT;
 
 	assert(tp->mac_version > RTL_GIGA_MAC_VER_B);
-	assert(tp->phy_version < RTL_GIGA_PHY_VER_G);
+	assert(tp->phy_version < RTL_GIGA_PHY_VER_H);
 
 	if (!(tp->phy_1000_ctrl_reg & PHY_Cap_1000_Full))
 		return;
@@ -1072,7 +1088,7 @@ static inline void rtl8169_delete_timer(
 	struct timer_list *timer = &tp->timer;
 
 	if ((tp->mac_version <= RTL_GIGA_MAC_VER_B) ||
-	    (tp->phy_version >= RTL_GIGA_PHY_VER_G))
+	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
 		return;
 
 	del_timer_sync(timer);
@@ -1084,7 +1100,7 @@ static inline void rtl8169_request_timer
 	struct timer_list *timer = &tp->timer;
 
 	if ((tp->mac_version <= RTL_GIGA_MAC_VER_B) ||
-	    (tp->phy_version >= RTL_GIGA_PHY_VER_G))
+	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
 		return;
 
 	init_timer(timer);

--------------090001080507050808000603--
