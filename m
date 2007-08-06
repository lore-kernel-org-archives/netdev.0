From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 0/2] r8169: pull request for 'r8169-for-jeff-20070806' branch
Date: Tue, 7 Aug 2007 00:16:12 +0200
Message-ID: <20070806221612.GA23302@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38002 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759592AbXHFWVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 18:21:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from branch 'r8169-for-jeff-20070806' in repository

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git r8169-for-jeff-20070806

to get the changes below.

Distance from 'upstream-fixes' (c196d80f994ef4ffefd5a7c62e3f42bd75d538bc)
-------------------------------------------------------------------------

313b0305b5a1e7e0fb39383befbf79558ce68a9c
2584fbc3a61897de5eddd56b39a4fa9cd074eca2

Diffstat
--------

 drivers/net/r8169.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

Shortlog
--------

Francois Romieu (1):
      r8169: avoid needless NAPI poll scheduling

Roger So (1):
      r8169: PHY power-on fix

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index bb6896a..631e55d 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -725,6 +725,12 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 	auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
+	if (tp->mac_version == RTL_GIGA_MAC_VER_12) {
+		/* Vendor specific (0x1f) and reserved (0x0e) MII registers. */
+		mdio_write(ioaddr, 0x1f, 0x0000);
+		mdio_write(ioaddr, 0x0e, 0x0000);
+	}
+
 	tp->phy_auto_nego_reg = auto_nego;
 	tp->phy_1000_ctrl_reg = giga_ctrl;
 
@@ -2761,14 +2767,16 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			rtl8169_check_link_status(dev, tp, ioaddr);
 
 #ifdef CONFIG_R8169_NAPI
-		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
-		tp->intr_mask = ~tp->napi_event;
-
-		if (likely(netif_rx_schedule_prep(dev)))
-			__netif_rx_schedule(dev);
-		else if (netif_msg_intr(tp)) {
-			printk(KERN_INFO "%s: interrupt %04x taken in poll\n",
-			       dev->name, status);
+		if (status & tp->napi_event) {
+			RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
+			tp->intr_mask = ~tp->napi_event;
+
+			if (likely(netif_rx_schedule_prep(dev)))
+				__netif_rx_schedule(dev);
+			else if (netif_msg_intr(tp)) {
+				printk(KERN_INFO "%s: interrupt %04x in poll\n",
+				       dev->name, status);
+			}
 		}
 		break;
 #else
-- 
Ueimor
