From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH v2] net/sb1250: register mdio bus in probe
Date: Wed, 28 Apr 2010 21:57:01 +0200
Message-ID: <20100428195701.GA3461@Chamillionaire.breakpoint.cc>
References: <1272229348-16140-1-git-send-email-sebastian@breakpoint.cc>
 <20100427.155215.228945283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: ralf@linux-mips.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:56234 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754538Ab0D1T5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:57:04 -0400
Content-Disposition: inline
In-Reply-To: <20100427.155215.228945283.davem@davemloft.net>
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
v2: register mdio bus before registering netdev device

 drivers/net/sb1250-mac.c |   67 ++++++++++++++++++++++-----------------------
 1 files changed, 33 insertions(+), 34 deletions(-)

diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 3f882d5..b0161b4 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2256,17 +2256,36 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 
 	sc->mii_bus = mdiobus_alloc();
 	if (sc->mii_bus == NULL) {
-		sbmac_uninitctx(sc);
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto uninit_ctx;
 	}
 
+	sc->mii_bus->name = sbmac_mdio_string;
+	snprintf(sc->mii_bus->id, MII_BUS_ID_SIZE, "%x", idx);
+	sc->mii_bus->priv = sc;
+	sc->mii_bus->read = sbmac_mii_read;
+	sc->mii_bus->write = sbmac_mii_write;
+	sc->mii_bus->irq = sc->phy_irq;
+	for (i = 0; i < PHY_MAX_ADDR; ++i)
+		sc->mii_bus->irq[i] = SBMAC_PHY_INT;
+
+	sc->mii_bus->parent = &pldev->dev;
+	/*
+	 * Probe PHY address
+	 */
+	err = mdiobus_register(sc->mii_bus);
+	if (err) {
+		printk(KERN_ERR "%s: unable to register MDIO bus\n",
+		       dev->name);
+		goto free_mdio;
+	}
+	dev_set_drvdata(&pldev->dev, sc->mii_bus);
+
 	err = register_netdev(dev);
 	if (err) {
 		printk(KERN_ERR "%s.%d: unable to register netdev\n",
 		       sbmac_string, idx);
-		mdiobus_free(sc->mii_bus);
-		sbmac_uninitctx(sc);
-		return err;
+		goto unreg_mdio;
 	}
 
 	pr_info("%s.%d: registered as %s\n", sbmac_string, idx, dev->name);
@@ -2282,19 +2301,15 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 	pr_info("%s: SiByte Ethernet at 0x%08Lx, address: %pM\n",
 	       dev->name, base, eaddr);
 
-	sc->mii_bus->name = sbmac_mdio_string;
-	snprintf(sc->mii_bus->id, MII_BUS_ID_SIZE, "%x", idx);
-	sc->mii_bus->priv = sc;
-	sc->mii_bus->read = sbmac_mii_read;
-	sc->mii_bus->write = sbmac_mii_write;
-	sc->mii_bus->irq = sc->phy_irq;
-	for (i = 0; i < PHY_MAX_ADDR; ++i)
-		sc->mii_bus->irq[i] = SBMAC_PHY_INT;
-
-	sc->mii_bus->parent = &pldev->dev;
-	dev_set_drvdata(&pldev->dev, sc->mii_bus);
-
 	return 0;
+unreg_mdio:
+	mdiobus_unregister(sc->mii_bus);
+	dev_set_drvdata(&pldev->dev, NULL);
+free_mdio:
+	mdiobus_free(sc->mii_bus);
+uninit_ctx:
+	sbmac_uninitctx(sc);
+	return err;
 }
 
 
@@ -2320,16 +2335,6 @@ static int sbmac_open(struct net_device *dev)
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
@@ -2360,11 +2365,7 @@ static int sbmac_open(struct net_device *dev)
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
@@ -2553,9 +2554,6 @@ static int sbmac_close(struct net_device *dev)
 
 	phy_disconnect(sc->phy_dev);
 	sc->phy_dev = NULL;
-
-	mdiobus_unregister(sc->mii_bus);
-
 	free_irq(dev->irq, dev);
 
 	sbdma_emptyring(&(sc->sbm_txdma));
@@ -2663,6 +2661,7 @@ static int __exit sbmac_remove(struct platform_device *pldev)
 
 	unregister_netdev(dev);
 	sbmac_uninitctx(sc);
+	mdiobus_unregister(sc->mii_bus);
 	mdiobus_free(sc->mii_bus);
 	iounmap(sc->sbm_base);
 	free_netdev(dev);
-- 
1.6.6.1
