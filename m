From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: fix a race between PCI probe and dev_open
Date: Wed, 31 Jan 2007 22:34:28 +0100
Message-ID: <20070131213428.GA17534@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	jgarzik@pobox.com, Bernhard Walle <bwalle@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:55303 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161047AbXAaVhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 16:37:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Call chain:
-> rtl8169_init_one
   -> register_netdev                  (dev_open starts to race...)
   -> rtl8169_init_phy
      -> rtl8169_set_speed
         -> tp->set_speed
         -> mod_timer(&tp->timer, ...) (if netif_running() is true)

As netif_running() is true just before dev->open() is issued and the
timer is initialized during dev->open, mod_timer() meets an uninitialized
tp->timer and oopses.

rtl8169_init_phy is only used on rtl8169_init_one so it's fine to never
ask it to activate the timer: the racing dev->open will do it anyway.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Bernhard Walle <bwalle@suse.de>
---
 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 577babd..3fc0611 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1448,7 +1448,7 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 
 	rtl8169_phy_reset(dev, tp);
 
-	rtl8169_set_speed(dev, autoneg, speed, duplex);
+	tp->set_speed(dev, autoneg, speed, duplex);
 
 	if ((RTL_R8(PHYstatus) & TBI_Enable) && netif_msg_link(tp))
 		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);
-- 
1.4.4.4

