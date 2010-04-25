From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH 1/2] net/sb1250: register mdio bus in probe
Date: Sun, 25 Apr 2010 23:02:27 +0200
Message-ID: <1272229348-16140-1-git-send-email-sebastian@breakpoint.cc>
Cc: netdev@vger.kernel.org,
	Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:57839 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751232Ab0DYVCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 17:02:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"ifconfig eth0 up && ifconfig eth0 down" triggers:
| kobject (a8000000cfa5a480): tried to init an initialized object, something is seriously wrong.
| Call Trace:
| [<ffffffff8010aabc>] dump_stack+0x8/0x34
| [<ffffffff80293128>] kobject_init+0xe8/0xf0
| [<ffffffff802d922c>] device_initialize+0x2c/0x98
| [<ffffffff802d9cfc>] device_register+0x14/0x28
| [<ffffffff80312cd4>] mdiobus_register+0xdc/0x1e0
| [<ffffffff80314cf0>] sbmac_open+0x58/0x220
| [<ffffffff803519bc>] __dev_open+0x11c/0x180
| [<ffffffff8034d578>] __dev_change_flags+0x120/0x180
| [<ffffffff80351848>] dev_change_flags+0x20/0x78
| [<ffffffff803a753c>] devinet_ioctl+0x7cc/0x820
| [<ffffffff80339ac8>] sock_do_ioctl+0x38/0x90
| [<ffffffff8033a258>] compat_sock_ioctl_trans+0x408/0x1030
| [<ffffffff8033af30>] compat_sock_ioctl+0xb0/0xd0
| [<ffffffff80208b08>] compat_sys_ioctl+0xa0/0x18b8
| [<ffffffff80102f94>] handle_sys+0x114/0x130
|
| sb1250-mac-mdio: probed

mdiobus_register() calls device_register() which initializes the kobj of
the device. mdiobus_unregister() calls only device_del() so we have one
reference left. That one is leaving with mdiobus_free() which is only
called on remove.
Since I don't see any reason why mdiobus_register()/mdiobus_unregister()
should happen in ->open()/->close() I move them to probe & exit.

Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
---
 drivers/net/sb1250-mac.c |   41 +++++++++++++++++++----------------------
 1 files changed, 19 insertions(+), 22 deletions(-)

diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 9944e5d..d162862 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2353,17 +2353,15 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 
 	sc->mii_bus = mdiobus_alloc();
 	if (sc->mii_bus == NULL) {
-		sbmac_uninitctx(sc);
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto uninit_ctx;
 	}
 
 	err = register_netdev(dev);
 	if (err) {
 		printk(KERN_ERR "%s.%d: unable to register netdev\n",
 		       sbmac_string, idx);
-		mdiobus_free(sc->mii_bus);
-		sbmac_uninitctx(sc);
-		return err;
+		goto free_mdio;
 	}
 
 	pr_info("%s.%d: registered as %s\n", sbmac_string, idx, dev->name);
@@ -2389,9 +2387,23 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 		sc->mii_bus->irq[i] = SBMAC_PHY_INT;
 
 	sc->mii_bus->parent = &pldev->dev;
+	/*
+	 * Probe PHY address
+	 */
+	err = mdiobus_register(sc->mii_bus);
+	if (err) {
+		printk(KERN_ERR "%s: unable to register MDIO bus\n",
+		       dev->name);
+		goto free_mdio;
+	}
 	dev_set_drvdata(&pldev->dev, sc->mii_bus);
-
 	return 0;
+
+free_mdio:
+	mdiobus_free(sc->mii_bus);
+uninit_ctx:
+	sbmac_uninitctx(sc);
+	return err;
 }
 
 
@@ -2417,16 +2429,6 @@ static int sbmac_open(struct net_device *dev)
 		goto out_err;
 	}
 
-	/*
-	 * Probe PHY address
-	 */
-	err = mdiobus_register(sc->mii_bus);
-	if (err) {
-		printk(KERN_ERR "%s: unable to register MDIO bus\n",
-		       dev->name);
-		goto out_unirq;
-	}
-
 	sc->sbm_speed = sbmac_speed_none;
 	sc->sbm_duplex = sbmac_duplex_none;
 	sc->sbm_fc = sbmac_fc_none;
@@ -2457,11 +2459,7 @@ static int sbmac_open(struct net_device *dev)
 	return 0;
 
 out_unregister:
-	mdiobus_unregister(sc->mii_bus);
-
-out_unirq:
 	free_irq(dev->irq, dev);
-
 out_err:
 	return err;
 }
@@ -2651,8 +2649,6 @@ static int sbmac_close(struct net_device *dev)
 	phy_disconnect(sc->phy_dev);
 	sc->phy_dev = NULL;
 
-	mdiobus_unregister(sc->mii_bus);
-
 	free_irq(dev->irq, dev);
 
 	sbdma_emptyring(&(sc->sbm_txdma));
@@ -2760,6 +2756,7 @@ static int __exit sbmac_remove(struct platform_device *pldev)
 
 	unregister_netdev(dev);
 	sbmac_uninitctx(sc);
+	mdiobus_unregister(sc->mii_bus);
 	mdiobus_free(sc->mii_bus);
 	iounmap(sc->sbm_base);
 	free_netdev(dev);
-- 
1.6.6.1

