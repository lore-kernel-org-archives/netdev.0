From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 07/12] r8169: remove the media option
Date: Thu, 26 Apr 2007 23:48:44 +0200
Message-ID: <20070426214844.GH7344@electric-eye.fr.zoreil.com>
References: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58577 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755174AbXDZVwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 17:52:09 -0400
Content-Disposition: inline
In-Reply-To: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It has been documented as deprecated:
- in MODULE_PARM_DESC since may 2005 ;
- at the top of the source file and in printk since june 2004.

Good bye.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com>
---
 drivers/net/r8169.c |   72 +++-----------------------------------------------
 1 files changed, 5 insertions(+), 67 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index adc4d3d..7a44de2 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -8,19 +8,6 @@
  May 20 2002	- Add link status force-mode and TBI mode support.
 	2004	- Massive updates. See kernel SCM system for details.
 =========================================================================
-  1. [DEPRECATED: use ethtool instead] The media can be forced in 5 modes.
-	 Command: 'insmod r8169 media = SET_MEDIA'
-	 Ex:	  'insmod r8169 media = 0x04' will force PHY to operate in 100Mpbs Half-duplex.
-
-	 SET_MEDIA can be:
- 		_10_Half	= 0x01
- 		_10_Full	= 0x02
- 		_100_Half	= 0x04
- 		_100_Full	= 0x08
- 		_1000_Full	= 0x10
-
-  2. Support TBI mode.
-=========================================================================
 VERSION 1.1	<2002/10/4>
 
 	The bit4:0 of MII register 4 is called "selector field", and have to be
@@ -108,11 +95,6 @@ VERSION 2.2LK	<2005/01/25>
 #define rtl8169_rx_quota(count, quota)	count
 #endif
 
-/* media options */
-#define MAX_UNITS 8
-static int media[MAX_UNITS] = { -1, -1, -1, -1, -1, -1, -1, -1 };
-static int num_media = 0;
-
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
 static const int max_interrupt_work = 20;
 
@@ -364,13 +346,6 @@ enum RTL8169_register_content {
 	LinkStatus = 0x02,
 	FullDup = 0x01,
 
-	/* _MediaType */
-	_10_Half = 0x01,
-	_10_Full = 0x02,
-	_100_Half = 0x04,
-	_100_Full = 0x08,
-	_1000_Full = 0x10,
-
 	/* _TBICSRBit */
 	TBILinkOK = 0x02000000,
 
@@ -472,8 +447,6 @@ struct rtl8169_private {
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
-module_param_array(media, int, &num_media, 0);
-MODULE_PARM_DESC(media, "force phy operation. Deprecated by ethtool (8).");
 module_param(rx_copybreak, int, 0);
 MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
 module_param(use_dac, int, 0);
@@ -601,38 +574,6 @@ static void rtl8169_check_link_status(struct net_device *dev,
 	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
-static void rtl8169_link_option(int idx, u8 *autoneg, u16 *speed, u8 *duplex)
-{
-	struct {
-		u16 speed;
-		u8 duplex;
-		u8 autoneg;
-		u8 media;
-	} link_settings[] = {
-		{ SPEED_10,	DUPLEX_HALF, AUTONEG_DISABLE,	_10_Half },
-		{ SPEED_10,	DUPLEX_FULL, AUTONEG_DISABLE,	_10_Full },
-		{ SPEED_100,	DUPLEX_HALF, AUTONEG_DISABLE,	_100_Half },
-		{ SPEED_100,	DUPLEX_FULL, AUTONEG_DISABLE,	_100_Full },
-		{ SPEED_1000,	DUPLEX_FULL, AUTONEG_DISABLE,	_1000_Full },
-		/* Make TBI happy */
-		{ SPEED_1000,	DUPLEX_FULL, AUTONEG_ENABLE,	0xff }
-	}, *p;
-	unsigned char option;
-
-	option = ((idx < MAX_UNITS) && (idx >= 0)) ? media[idx] : 0xff;
-
-	if ((option != 0xff) && !idx && netif_msg_drv(&debug))
-		printk(KERN_WARNING PFX "media option is deprecated.\n");
-
-	for (p = link_settings; p->media != 0xff; p++) {
-		if (p->media == option)
-			break;
-	}
-	*autoneg = p->autoneg;
-	*speed = p->speed;
-	*duplex = p->duplex;
-}
-
 static void rtl8169_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1435,11 +1376,6 @@ static void rtl8169_phy_reset(struct net_device *dev,
 static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	static int board_idx = -1;
-	u8 autoneg, duplex;
-	u16 speed;
-
-	board_idx++;
 
 	rtl8169_hw_phy_config(dev);
 
@@ -1458,11 +1394,13 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 		mdio_write(ioaddr, 0x0b, 0x0000); //w 0x0b 15 0 0
 	}
 
-	rtl8169_link_option(board_idx, &autoneg, &speed, &duplex);
-
 	rtl8169_phy_reset(dev, tp);
 
-	rtl8169_set_speed(dev, autoneg, speed, duplex);
+	/*
+	 * rtl8169_set_speed_xmii takes good care of the Fast Ethernet
+	 * only 8101. Don't panic.
+	 */
+	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL);
 
 	if ((RTL_R8(PHYstatus) & TBI_Enable) && netif_msg_link(tp))
 		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);
-- 
1.4.4.2
