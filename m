From: Sebastian Siewior <bigeasy@linutronix.de>
Subject: [PATCH / RFC] net: fix locking in ibm_newemac
Date: Wed, 13 Aug 2008 20:29:57 +0200
Message-ID: <20080813182957.GA12612@www.tglx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Valentine Barshak <vbarshak@ru.mvista.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:58705 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952AbYHMSge (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 14:36:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

|PPC 4xx OCP EMAC driver, version 3.54
|MAL v2 /plb/mcmal, 2 TX channels, 2 RX channels
|RGMII /plb/opb/emac-rgmii@ef600b00 initialized with MDIO support
|/plb/opb/emac-rgmii@ef600b00: input 0 in RGMII mode
|BUG: spinlock bad magic on CPU#0, swapper/1
| lock: cf81632c, .magic: 00000000, .owner: <none>/-1, .owner_cpu: 0
|Call Trace:
|[cf82bc70] [c00071c4] show_stack+0x34/0x194 (unreliable)
|[cf82bca0] [c0136d5c] spin_bug+0x8c/0xd0
|[cf82bcc0] [c0136f64] _raw_spin_lock+0x94/0x16c
|[cf82bcf0] [c023b528] _spin_lock_bh+0x20/0x34
|[cf82bd10] [c01d04a8] dev_mc_add+0x2c/0x84
|[cf82bd30] [c0166f80] emac_configure+0x2a8/0x55c
|[cf82bd60] [c02418bc] emac_probe+0xc24/0x105c
|[cf82be40] [c01bb504] of_platform_device_probe+0x58/0x80
|[cf82be60] [c016057c] driver_probe_device+0xb8/0x1ec
|[cf82be80] [c0160734] __driver_attach+0x84/0x88
|[cf82bea0] [c015fa4c] bus_for_each_dev+0x5c/0x98
|[cf82bed0] [c0160384] driver_attach+0x24/0x34
|[cf82bee0] [c01600b4] bus_add_driver+0x1d8/0x24c
|[cf82bf00] [c0160944] driver_register+0x5c/0x158
|[cf82bf20] [c01bb3dc] of_register_driver+0x54/0x70
|[cf82bf30] [c030ba8c] emac_init+0x1c8/0x208
|[cf82bf60] [c02f4184] kernel_init+0x84/0x27c
|[cf82bff0] [c000e594] kernel_thread+0x44/0x60

The fix is to defer phy init until netdevice is registered / initialized.

Signed-off-by: Sebastian Siewior <bigeasy@linutronix.de>
---
Noticed with spinlock debug enabled & 40x/kilauea_defconfig on a kilaue
board. With this patch, the board boots via NFS root, no problems were
noticed so far

 drivers/net/ibm_newemac/core.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index babc79a..c4130e1 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2751,11 +2751,6 @@ static int __devinit emac_probe(struct of_device *ofdev,
 	dev->stop_timeout = STOP_TIMEOUT_100;
 	INIT_DELAYED_WORK(&dev->link_work, emac_link_timer);
 
-	/* Find PHY if any */
-	err = emac_init_phy(dev);
-	if (err != 0)
-		goto err_detach_tah;
-
 	/* Fill in the driver function table */
 	ndev->open = &emac_open;
 	if (dev->tah_dev)
@@ -2785,6 +2780,11 @@ static int __devinit emac_probe(struct of_device *ofdev,
 		goto err_detach_tah;
 	}
 
+	/* Find PHY if any */
+	err = emac_init_phy(dev);
+	if (err != 0)
+		goto err_detach_tah;
+
 	/* Set our drvdata last as we don't want them visible until we are
 	 * fully initialized
 	 */
-- 
1.5.5.2

