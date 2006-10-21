From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 1/1] r8169 driver: corega support
Date: Sat, 21 Oct 2006 22:15:33 +0200
Message-ID: <20061021201533.GA31768@electric-eye.fr.zoreil.com>
References: <20061020224438.GA1794@electric-eye.fr.zoreil.com> <4E79505750%linux@youmustbejoking.demon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, hchacha@users.sourceforge.net, jeff@garzik.org,
	syed.azam@hp.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:56006 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1161025AbWJUUTs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Oct 2006 16:19:48 -0400
To: Darren Salt <linux@youmustbejoking.demon.co.uk>
Content-Disposition: inline
In-Reply-To: <4E79505750%linux@youmustbejoking.demon.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Darren Salt <linux@youmustbejoking.demon.co.uk> :
[...]
> It does, but the patch causes the module to report that the reset failed even
> after reporting that it's done. A fix for this is attached.

Oops. Ok with the one below ?

r8169: perform a PHY reset before any other operation at boot time

Realtek's 8139/810x (0x8136) PCI-E comes with a touchy PHY.
A big heavy reset seems to calm it down.

Fix for http://bugzilla.kernel.org/show_bug.cgi?id=7378.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Darren Salt <linux@youmustbejoking.demon.co.uk>
---
 drivers/net/r8169.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c2c9a86..03c0dc5 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1442,6 +1442,22 @@ static void rtl8169_release_board(struct
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
+		if (!tp->phy_reset_pending(ioaddr))
+			return;
+		msleep(1);
+	}
+	if (netif_msg_link(tp))
+		printk(KERN_ERR "%s: PHY reset failed.\n", dev->name);
+}
+
 static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -1470,6 +1486,8 @@ static void rtl8169_init_phy(struct net_
 
 	rtl8169_link_option(board_idx, &autoneg, &speed, &duplex);
 
+	rtl8169_phy_reset(dev, tp);
+
 	rtl8169_set_speed(dev, autoneg, speed, duplex);
 
 	if ((RTL_R8(PHYstatus) & TBI_Enable) && netif_msg_link(tp))
-- 
1.4.2.3

