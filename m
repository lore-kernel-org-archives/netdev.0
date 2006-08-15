From: akpm@osdl.org
Subject: [patch 33/41] via-rhine: add option avoid_D3 (work around broken BIOSes)
Date: Mon, 14 Aug 2006 23:00:21 -0700
Message-ID: <200608150600.k7F60L2x012711@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, rl@hellgate.ch,
	brak@archive.org, jgarzik@pobox.com,
	tim@phipps-hutton.freeserve.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50578 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965144AbWHOGBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:01:01 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roger Luethi <rl@hellgate.ch>

It looks like broken BIOSes controlling Rhine chips will remain in use in
significant numbers; such systems fail to come up via PXE after they have
been put into D3 (power-saving) mode.

This patch adds a module option for disabling the call that puts the chip
to sleep.

Signed-off-by: Roger Luethi <rl@hellgate.ch>
Cc: Jeff Garzik <jgarzik@pobox.com>
Cc: Joerg Bashir <brak@archive.org>
Cc: Tim Phipps <tim@phipps-hutton.freeserve.co.uk>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/via-rhine.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff -puN drivers/net/via-rhine.c~via-rhine-add-option-avoid_d3-work-around-broken-bioses drivers/net/via-rhine.c
--- a/drivers/net/via-rhine.c~via-rhine-add-option-avoid_d3-work-around-broken-bioses
+++ a/drivers/net/via-rhine.c
@@ -44,6 +44,10 @@ static int max_interrupt_work = 20;
    Setting to > 1518 effectively disables this feature. */
 static int rx_copybreak;
 
+/* Work-around for broken BIOSes: they are unable to get the chip back out of
+   power state D3 so PXE booting fails. bootparam(7): via-rhine.avoid_D3=1 */
+static int avoid_D3;
+
 /*
  * In case you are looking for 'options[]' or 'full_duplex[]', they
  * are gone. Use ethtool(8) instead.
@@ -120,9 +124,11 @@ MODULE_LICENSE("GPL");
 module_param(max_interrupt_work, int, 0);
 module_param(debug, int, 0);
 module_param(rx_copybreak, int, 0);
+module_param(avoid_D3, bool, 0);
 MODULE_PARM_DESC(max_interrupt_work, "VIA Rhine maximum events handled per interrupt");
 MODULE_PARM_DESC(debug, "VIA Rhine debug level (0-7)");
 MODULE_PARM_DESC(rx_copybreak, "VIA Rhine copy breakpoint for copy-only-tiny-frames");
+MODULE_PARM_DESC(avoid_D3, "Avoid power state D3 (work-around for broken BIOSes)");
 
 /*
 		Theory of Operation
@@ -823,6 +829,9 @@ static int __devinit rhine_init_one(stru
 		}
 	}
 	rp->mii_if.phy_id = phy_id;
+	if (debug > 1 && avoid_D3)
+		printk(KERN_INFO "%s: No D3 power state at shutdown.\n",
+		       dev->name);
 
 	return 0;
 
@@ -1911,7 +1920,8 @@ static void rhine_shutdown (struct pci_d
 	}
 
 	/* Hit power state D3 (sleep) */
-	iowrite8(ioread8(ioaddr + StickyHW) | 0x03, ioaddr + StickyHW);
+	if (!avoid_D3)
+		iowrite8(ioread8(ioaddr + StickyHW) | 0x03, ioaddr + StickyHW);
 
 	/* TODO: Check use of pci_enable_wake() */
 
_
