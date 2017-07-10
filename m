From: Marc Duponcheel <marc@offline.be>
Subject: Re: meson-gxbb-p200 4.12.0 network TCP transfer stalls
Date: Tue, 11 Jul 2017 01:48:45 +0200
Message-ID: <20170710234845.GA24423@offline.be>
References: <20170708005542.GA20515@offline.be>
Reply-To: Marc Duponcheel <marc@offline.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Duponcheel <marc@offline.be>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.offline.be ([79.132.231.86]:51920 "EHLO mail.offline.be"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754952AbdGJXlH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Jul 2017 19:41:07 -0400
Content-Disposition: inline
In-Reply-To: <20170708005542.GA20515@offline.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 FYI

I changed 4.12.0 drivers/net/phy/realtek.c RTL8211F code to equal the
3.14.29 amlogic/ethernet/phy/am_realtek.c code and now the networking
works without TCP stalls.

I don't say below patch should be considered mainstream (as maybe some
4.12.0 rtl8211f_config_init code should not be removed) but sure
someone could figure out what best patch is...

 --
# diff -U2 realtek.c.orig realtek.c
--- realtek.c.orig	2017-07-03 01:07:02.000000000 +0200
+++ realtek.c	2017-07-11 01:32:20.273445023 +0200
@@ -94,28 +94,27 @@
 }
 
+#define RTL8211F_MMD_CTRL       0x0D
+#define RTL8211F_MMD_DATA       0x0E
+#define RTL8211E_INER_LINK_STAT 0x10
+
 static int rtl8211f_config_init(struct phy_device *phydev)
 {
-	int ret;
-	u16 reg;
-
-	ret = genphy_config_init(phydev);
-	if (ret < 0)
-		return ret;
-
-	phy_write(phydev, RTL8211F_PAGE_SELECT, 0xd08);
-	reg = phy_read(phydev, 0x11);
-
-	/* enable TX-delay for rgmii-id and rgmii-txid, otherwise disable it */
-	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID ||
-	    phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
-		reg |= RTL8211F_TX_DELAY;
-	else
-		reg &= ~RTL8211F_TX_DELAY;
-
-	phy_write(phydev, 0x11, reg);
-	/* restore to default page 0 */
-	phy_write(phydev, RTL8211F_PAGE_SELECT, 0x0);
-
+	int val;
+/* we want to disable eee */
+	phy_write(phydev, RTL8211F_MMD_CTRL, 0x7);
+	phy_write(phydev, RTL8211F_MMD_DATA, 0x3c);
+	phy_write(phydev, RTL8211F_MMD_CTRL, 0x4007);
+	phy_write(phydev, RTL8211F_MMD_DATA, 0x0);
+/* disable 1000m adv*/
+	val = phy_read(phydev, 0x9);
+	phy_write(phydev, 0x9, val&(~(1<<9)));
+/* rx reg 21 bit 3 tx reg 17 bit 8 */
+/*
+	phy_write(phydev, 0x1f, 0xd08);
+	val =  phy_read(phydev, 0x15);
+	phy_write(phydev, 0x15,val| 1<<21);
+ */
 	return 0;
+/* Enable Auto Power Saving mode */
 }
 
@@ -167,6 +166,6 @@
 		.name		= "RTL8211F Gigabit Ethernet",
 		.phy_id_mask	= 0x001fffff,
-		.features	= PHY_GBIT_FEATURES,
-		.flags		= PHY_HAS_INTERRUPT,
+		.features	= PHY_GBIT_FEATURES | SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+		.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
 		.config_aneg	= &genphy_config_aneg,
 --


On 2017 Jul 08, Marc Duponcheel wrote:
> Hi all
> 
> Similar to 'crow'
> 
> ARM GLX Khadas VIM Pro - Ethernet detected as only 10Mbps and stalled after some traffic
> 
> I also have the situation where copying large file over LAN stalls.
> 
> 3.14.29 performance is good 4.12.0 performance not
> 
> 
>  Perhaps one must compare 3.14.29 am_realtek.c and realtek.c with 4.12.0 realtek.c
> 
> 
>  thanks

have a nice day
