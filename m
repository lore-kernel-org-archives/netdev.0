From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 1/1] r8169 driver: corega support
Date: Sat, 21 Oct 2006 00:44:38 +0200
Message-ID: <20061020224438.GA1794@electric-eye.fr.zoreil.com>
References: <200610202144.k9KLid8a003945@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hchacha@users.sourceforge.net, jeff@garzik.org,
	Darren Salt <linux@youmustbejoking.demon.co.uk>,
	syed.azam@hp.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:30676 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S2992527AbWJTWsp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 18:48:45 -0400
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <200610202144.k9KLid8a003945@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org <akpm@osdl.org> :
[Corega adapter support]

It's queued in the r8169 branch at:

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git r8169

I have sent Jeff a pull request for it (and I'll probably send one
more for the patch below).

Darren, can you check if the patch below fixes you link detection
issue ?

>From 6c94bf2ee2c932418bfe95d18460fb503f549659 Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 20 Oct 2006 23:10:14 +0200
Subject: [PATCH] r8169: perform a PHY reset before any other operation at boot time

Realtek's 8139/810x (0x8136) PCI-E comes with a touchy PHY.
A big heavy reset seems to calm it down.

Fix for http://bugzilla.kernel.org/show_bug.cgi?id=7378.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c2c9a86..e3d0679 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1442,6 +1442,23 @@ static void rtl8169_release_board(struct
 	free_netdev(dev);
 }
 
+static void rtl8169_phy_reset(struct net_device *dev,
+			      struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	int i;
+
+	tp->phy_reset_enable(ioaddr);
+	for (i = 0; i < 100; i++) {
+		if (!tp->phy_reset_pending(ioaddr)) {
+			printk(KERN_INFO "%s: PHY reset done.\n", dev->name);
+			break;
+		}
+		msleep(1);
+	}
+	printk(KERN_ERR "%s: PHY reset failed.\n", dev->name);
+}
+
 static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1470,6 +1487,8 @@ static void rtl8169_init_phy(struct net_
 
 	rtl8169_link_option(board_idx, &autoneg, &speed, &duplex);
 
+	rtl8169_phy_reset(dev, tp);
+
 	rtl8169_set_speed(dev, autoneg, speed, duplex);
 
 	if ((RTL_R8(PHYstatus) & TBI_Enable) && netif_msg_link(tp))
-- 
1.4.2.3

