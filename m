From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PULL REQUEST] net-fixes: IXP4xx
Date: Sat, 09 May 2009 19:50:00 +0200
Message-ID: <m33abeupx3.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:36035 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974AbZEIRuD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 13:50:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Please pull - a couple of fixes for 2.6.30:

The following changes since commit be8be9eccbf2d908a7e56b3f7a71105cd88d=
a06b:
  Simon Horman (1):
        ipvs: Fix IPv4 FWMARK virtual services

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git net=
-fixes

Krzysztof Ha=B3asa (2):
      IXP4xx: use "ENODEV" instead of "ENOSYS" in module initialization=
=2E
         (now modutils don't complain about missing module support, sam=
e
         as c101 and n2 changes months ago).

      IXP4xx: complete Ethernet netdev setup before calling
         register_netdev() (recently spotted by Lubomir Rintel and
         Andreas Mohr).

 arch/arm/mach-ixp4xx/ixp4xx_npe.c |    2 +-
 drivers/net/arm/ixp4xx_eth.c      |   31 ++++++++++++++++-------------=
--
 drivers/net/wan/ixp4xx_hss.c      |    4 ++--
 3 files changed, 19 insertions(+), 18 deletions(-)

Thanks.

I'm attaching the diff as well.
--=20
Krzysztof Halasa

diff --git a/arch/arm/mach-ixp4xx/ixp4xx_npe.c b/arch/arm/mach-ixp4xx/i=
xp4xx_npe.c
index 2523102..7bb8e77 100644
--- a/arch/arm/mach-ixp4xx/ixp4xx_npe.c
+++ b/arch/arm/mach-ixp4xx/ixp4xx_npe.c
@@ -714,7 +714,7 @@ static int __init npe_init_module(void)
 	}
=20
 	if (!found)
-		return -ENOSYS;
+		return -ENODEV;
 	return 0;
 }
=20
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.=
c
index 448487e..a740053 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -338,12 +338,12 @@ static int ixp4xx_mdio_register(void)
 	if (cpu_is_ixp43x()) {
 		/* IXP43x lacks NPE-B and uses NPE-C for MII PHY access */
 		if (!(ixp4xx_read_feature_bits() & IXP4XX_FEATURE_NPEC_ETH))
-			return -ENOSYS;
+			return -ENODEV;
 		mdio_regs =3D (struct eth_regs __iomem *)IXP4XX_EthC_BASE_VIRT;
 	} else {
 		/* All MII PHY accesses use NPE-B Ethernet registers */
 		if (!(ixp4xx_read_feature_bits() & IXP4XX_FEATURE_NPEB_ETH0))
-			return -ENOSYS;
+			return -ENODEV;
 		mdio_regs =3D (struct eth_regs __iomem *)IXP4XX_EthB_BASE_VIRT;
 	}
=20
@@ -1174,7 +1174,7 @@ static int __devinit eth_init_one(struct platform=
_device *pdev)
 		regs_phys  =3D IXP4XX_EthC_BASE_PHYS;
 		break;
 	default:
-		err =3D -ENOSYS;
+		err =3D -ENODEV;
 		goto err_free;
 	}
=20
@@ -1189,15 +1189,10 @@ static int __devinit eth_init_one(struct platfo=
rm_device *pdev)
 		goto err_free;
 	}
=20
-	if (register_netdev(dev)) {
-		err =3D -EIO;
-		goto err_npe_rel;
-	}
-
 	port->mem_res =3D request_mem_region(regs_phys, REGS_SIZE, dev->name)=
;
 	if (!port->mem_res) {
 		err =3D -EBUSY;
-		goto err_unreg;
+		goto err_npe_rel;
 	}
=20
 	port->plat =3D plat;
@@ -1215,20 +1210,25 @@ static int __devinit eth_init_one(struct platfo=
rm_device *pdev)
 	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, "0", plat->phy);
 	port->phydev =3D phy_connect(dev, phy_id, &ixp4xx_adjust_link, 0,
 				   PHY_INTERFACE_MODE_MII);
-	if (IS_ERR(port->phydev)) {
-		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
-		return PTR_ERR(port->phydev);
-	}
+	if ((err =3D IS_ERR(port->phydev)))
+		goto err_free_mem;
=20
 	port->phydev->irq =3D PHY_POLL;
=20
+	if ((err =3D register_netdev(dev)))
+		goto err_phy_dis;
+
 	printk(KERN_INFO "%s: MII PHY %i on %s\n", dev->name, plat->phy,
 	       npe_name(port->npe));
=20
 	return 0;
=20
-err_unreg:
-	unregister_netdev(dev);
+err_phy_dis:
+	phy_disconnect(port->phydev);
+err_free_mem:
+	npe_port_tab[NPE_ID(port->id)] =3D NULL;
+	platform_set_drvdata(pdev, NULL);
+	release_resource(port->mem_res);
 err_npe_rel:
 	npe_release(port->npe);
 err_free:
@@ -1242,6 +1242,7 @@ static int __devexit eth_remove_one(struct platfo=
rm_device *pdev)
 	struct port *port =3D netdev_priv(dev);
=20
 	unregister_netdev(dev);
+	phy_disconnect(port->phydev);
 	npe_port_tab[NPE_ID(port->id)] =3D NULL;
 	platform_set_drvdata(pdev, NULL);
 	npe_release(port->npe);
diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.=
c
index 3bf7d3f..765a7f5 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -1249,7 +1249,7 @@ static int __devinit hss_init_one(struct platform=
_device *pdev)
 		return -ENOMEM;
=20
 	if ((port->npe =3D npe_request(0)) =3D=3D NULL) {
-		err =3D -ENOSYS;
+		err =3D -ENODEV;
 		goto err_free;
 	}
=20
@@ -1311,7 +1311,7 @@ static int __init hss_init_module(void)
 	if ((ixp4xx_read_feature_bits() &
 	     (IXP4XX_FEATURE_HDLC | IXP4XX_FEATURE_HSS)) !=3D
 	    (IXP4XX_FEATURE_HDLC | IXP4XX_FEATURE_HSS))
-		return -ENOSYS;
+		return -ENODEV;
=20
 	spin_lock_init(&npe_lock);
=20
