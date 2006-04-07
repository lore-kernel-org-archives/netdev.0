From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 19/21] orinoco: reduce differences between PCI drivers, create orinoco_pci.h
Date: Fri, 07 Apr 2006 04:10:57 -0400
Message-ID: <20060407081057.16107.82106.stgit@dv.roinet.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
In-Reply-To: <20060407081019.16107.67672.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

Make all Orinoco PCI drivers (orinoco_pci, orinoco_plx, orinoco_tmd and
orinoco_nortel) as similar as possible.  Use the best implementation of
error handling, the best error messages, the best comments.

Put common code to orinoco_pci.h.  For now, it's suspend and resume
functions and function for registering the network device.

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/orinoco_nortel.c |  240 +++++++++++----------------=
----
 drivers/net/wireless/orinoco_pci.c    |  144 +++---------------
 drivers/net/wireless/orinoco_pci.h    |  125 ++++++++++++++++
 drivers/net/wireless/orinoco_plx.c    |  259 +++++++++++----------------=
------
 drivers/net/wireless/orinoco_tmd.c    |  165 +++++----------------
 5 files changed, 368 insertions(+), 565 deletions(-)

diff --git a/drivers/net/wireless/orinoco_nortel.c b/drivers/net/wireless=
/orinoco_nortel.c
index 3fff013..deb22fb 100644
--- a/drivers/net/wireless/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco_nortel.c
@@ -1,5 +1,5 @@
 /* orinoco_nortel.c
- *=20
+ *
  * Driver for Prism II devices which would usually be driven by orinoco_=
cs,
  * but are connected to the PCI bus by a PCI-to-PCMCIA adapter used in
  * Nortel emobility, Symbol LA-4113 and Symbol LA-4123.
@@ -50,16 +50,11 @@ #include <linux/pci.h>
 #include <pcmcia/cisreg.h>
=20
 #include "orinoco.h"
+#include "orinoco_pci.h"
=20
 #define COR_OFFSET    (0xe0)	/* COR attribute offset of Prism2 PC card *=
/
 #define COR_VALUE     (COR_LEVEL_REQ | COR_FUNC_ENA)	/* Enable PC card w=
ith interrupt in level trigger */
=20
-
-/* Nortel specific data */
-struct nortel_pci_card {
-	unsigned long iobase1;
-	unsigned long iobase2;
-};
=20
 /*
  * Do a soft reset of the PCI card using the Configuration Option Regist=
er
@@ -69,48 +64,48 @@ struct nortel_pci_card {
  * Note bis : Don't try to access HERMES_CMD during the reset phase.
  * It just won't work !
  */
-static int nortel_pci_cor_reset(struct orinoco_private *priv)
+static int orinoco_nortel_cor_reset(struct orinoco_private *priv)
 {
-	struct nortel_pci_card *card =3D priv->card;
+	struct orinoco_pci_card *card =3D priv->card;
=20
 	/* Assert the reset until the card notice */
-	outw_p(8, card->iobase1 + 2);
-	inw(card->iobase2 + COR_OFFSET);
-	outw_p(0x80, card->iobase2 + COR_OFFSET);
+	iowrite16(8, card->bridge_io + 2);
+	ioread16(card->attr_io + COR_OFFSET);
+	iowrite16(0x80, card->attr_io + COR_OFFSET);
 	mdelay(1);
=20
 	/* Give time for the card to recover from this hard effort */
-	outw_p(0, card->iobase2 + COR_OFFSET);
-	outw_p(0, card->iobase2 + COR_OFFSET);
+	iowrite16(0, card->attr_io + COR_OFFSET);
+	iowrite16(0, card->attr_io + COR_OFFSET);
 	mdelay(1);
=20
-	/* set COR as usual */
-	outw_p(COR_VALUE, card->iobase2 + COR_OFFSET);
-	outw_p(COR_VALUE, card->iobase2 + COR_OFFSET);
+	/* Set COR as usual */
+	iowrite16(COR_VALUE, card->attr_io + COR_OFFSET);
+	iowrite16(COR_VALUE, card->attr_io + COR_OFFSET);
 	mdelay(1);
=20
-	outw_p(0x228, card->iobase1 + 2);
+	iowrite16(0x228, card->bridge_io + 2);
=20
 	return 0;
 }
=20
-static int nortel_pci_hw_init(struct nortel_pci_card *card)
+static int orinoco_nortel_hw_init(struct orinoco_pci_card *card)
 {
 	int i;
 	u32 reg;
=20
-	/* setup bridge */
-	if (inw(card->iobase1) & 1) {
+	/* Setup bridge */
+	if (ioread16(card->bridge_io) & 1) {
 		printk(KERN_ERR PFX "brg1 answer1 wrong\n");
 		return -EBUSY;
 	}
-	outw_p(0x118, card->iobase1 + 2);
-	outw_p(0x108, card->iobase1 + 2);
+	iowrite16(0x118, card->bridge_io + 2);
+	iowrite16(0x108, card->bridge_io + 2);
 	mdelay(30);
-	outw_p(0x8, card->iobase1 + 2);
+	iowrite16(0x8, card->bridge_io + 2);
 	for (i =3D 0; i < 30; i++) {
 		mdelay(30);
-		if (inw(card->iobase1) & 0x10) {
+		if (ioread16(card->bridge_io) & 0x10) {
 			break;
 		}
 	}
@@ -118,42 +113,42 @@ static int nortel_pci_hw_init(struct nor
 		printk(KERN_ERR PFX "brg1 timed out\n");
 		return -EBUSY;
 	}
-	if (inw(card->iobase2 + 0xe0) & 1) {
+	if (ioread16(card->attr_io + COR_OFFSET) & 1) {
 		printk(KERN_ERR PFX "brg2 answer1 wrong\n");
 		return -EBUSY;
 	}
-	if (inw(card->iobase2 + 0xe2) & 1) {
+	if (ioread16(card->attr_io + COR_OFFSET + 2) & 1) {
 		printk(KERN_ERR PFX "brg2 answer2 wrong\n");
 		return -EBUSY;
 	}
-	if (inw(card->iobase2 + 0xe4) & 1) {
+	if (ioread16(card->attr_io + COR_OFFSET + 4) & 1) {
 		printk(KERN_ERR PFX "brg2 answer3 wrong\n");
 		return -EBUSY;
 	}
=20
-	/* set the PCMCIA COR-Register */
-	outw_p(COR_VALUE, card->iobase2 + COR_OFFSET);
+	/* Set the PCMCIA COR-Register */
+	iowrite16(COR_VALUE, card->attr_io + COR_OFFSET);
 	mdelay(1);
-	reg =3D inw(card->iobase2 + COR_OFFSET);
+	reg =3D ioread16(card->attr_io + COR_OFFSET);
 	if (reg !=3D COR_VALUE) {
 		printk(KERN_ERR PFX "Error setting COR value (reg=3D%x)\n",
 		       reg);
 		return -EBUSY;
 	}
=20
-	/* set leds */
-	outw_p(1, card->iobase1 + 10);
+	/* Set LEDs */
+	iowrite16(1, card->bridge_io + 10);
 	return 0;
 }
=20
-static int nortel_pci_init_one(struct pci_dev *pdev,
-			       const struct pci_device_id *ent)
+static int orinoco_nortel_init_one(struct pci_dev *pdev,
+				   const struct pci_device_id *ent)
 {
 	int err;
 	struct orinoco_private *priv;
-	struct nortel_pci_card *card;
+	struct orinoco_pci_card *card;
 	struct net_device *dev;
-	void __iomem *iomem;
+	void __iomem *hermes_io, *bridge_io, *attr_io;
=20
 	err =3D pci_enable_device(pdev);
 	if (err) {
@@ -162,19 +157,34 @@ static int nortel_pci_init_one(struct pc
 	}
=20
 	err =3D pci_request_regions(pdev, DRIVER_NAME);
-	if (err !=3D 0) {
+	if (err) {
 		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
 		goto fail_resources;
 	}
=20
-	iomem =3D pci_iomap(pdev, 2, 0);
-	if (!iomem) {
-		err =3D -ENOMEM;
-		goto fail_map_io;
+	bridge_io =3D pci_iomap(pdev, 0, 0);
+	if (!bridge_io) {
+		printk(KERN_ERR PFX "Cannot map bridge registers\n");
+		err =3D -EIO;
+		goto fail_map_bridge;
+	}
+
+	attr_io =3D pci_iomap(pdev, 1, 0);
+	if (!attr_io) {
+		printk(KERN_ERR PFX "Cannot map PCMCIA attributes\n");
+		err =3D -EIO;
+		goto fail_map_attr;
+	}
+
+	hermes_io =3D pci_iomap(pdev, 2, 0);
+	if (!hermes_io) {
+		printk(KERN_ERR PFX "Cannot map chipset registers\n");
+		err =3D -EIO;
+		goto fail_map_hermes;
 	}
=20
 	/* Allocate network device */
-	dev =3D alloc_orinocodev(sizeof(*card), nortel_pci_cor_reset);
+	dev =3D alloc_orinocodev(sizeof(*card), orinoco_nortel_cor_reset);
 	if (!dev) {
 		printk(KERN_ERR PFX "Cannot allocate network device\n");
 		err =3D -ENOMEM;
@@ -183,16 +193,12 @@ static int nortel_pci_init_one(struct pc
=20
 	priv =3D netdev_priv(dev);
 	card =3D priv->card;
-	card->iobase1 =3D pci_resource_start(pdev, 0);
-	card->iobase2 =3D pci_resource_start(pdev, 1);
-	dev->base_addr =3D pci_resource_start(pdev, 2);
+	card->bridge_io =3D bridge_io;
+	card->attr_io =3D attr_io;
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
-
-	hermes_struct_init(&priv->hw, iomem, HERMES_16BIT_REGSPACING);
=20
-	printk(KERN_DEBUG PFX "Detected Nortel PCI device at %s irq:%d, "
-	       "io addr:0x%lx\n", pci_name(pdev), pdev->irq, dev->base_addr);
+	hermes_struct_init(&priv->hw, hermes_io, HERMES_16BIT_REGSPACING);
=20
 	err =3D request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
 			  dev->name, dev);
@@ -201,21 +207,20 @@ static int nortel_pci_init_one(struct pc
 		err =3D -EBUSY;
 		goto fail_irq;
 	}
-	dev->irq =3D pdev->irq;
+	orinoco_pci_setup_netdev(dev, pdev, 2);
=20
-	err =3D nortel_pci_hw_init(card);
+	err =3D orinoco_nortel_hw_init(card);
 	if (err) {
 		printk(KERN_ERR PFX "Hardware initialization failed\n");
 		goto fail;
 	}
=20
-	err =3D nortel_pci_cor_reset(priv);
+	err =3D orinoco_nortel_cor_reset(priv);
 	if (err) {
 		printk(KERN_ERR PFX "Initial reset failed\n");
 		goto fail;
 	}
=20
-
 	err =3D register_netdev(dev);
 	if (err) {
 		printk(KERN_ERR PFX "Cannot register network device\n");
@@ -234,9 +239,15 @@ static int nortel_pci_init_one(struct pc
 	free_orinocodev(dev);
=20
  fail_alloc:
-	pci_iounmap(pdev, iomem);
+	pci_iounmap(pdev, hermes_io);
+
+ fail_map_hermes:
+	pci_iounmap(pdev, attr_io);
+
+ fail_map_attr:
+	pci_iounmap(pdev, bridge_io);
=20
- fail_map_io:
+ fail_map_bridge:
 	pci_release_regions(pdev);
=20
  fail_resources:
@@ -245,103 +256,27 @@ static int nortel_pci_init_one(struct pc
 	return err;
 }
=20
-static void __devexit nortel_pci_remove_one(struct pci_dev *pdev)
+static void __devexit orinoco_nortel_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev =3D pci_get_drvdata(pdev);
 	struct orinoco_private *priv =3D netdev_priv(dev);
-	struct nortel_pci_card *card =3D priv->card;
+	struct orinoco_pci_card *card =3D priv->card;
=20
-	/* clear leds */
-	outw_p(0, card->iobase1 + 10);
+	/* Clear LEDs */
+	iowrite16(0, card->bridge_io + 10);
=20
 	unregister_netdev(dev);
 	free_irq(dev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
 	free_orinocodev(dev);
 	pci_iounmap(pdev, priv->hw.iobase);
+	pci_iounmap(pdev, card->attr_io);
+	pci_iounmap(pdev, card->bridge_io);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-}
-
-static int orinoco_nortel_suspend(struct pci_dev *pdev, pm_message_t sta=
te)
-{
-	struct net_device *dev =3D pci_get_drvdata(pdev);
-	struct orinoco_private *priv =3D netdev_priv(dev);
-	unsigned long flags;
-	int err;
-
-	err =3D orinoco_lock(priv, &flags);
-	if (err) {
-		printk(KERN_ERR "%s: cannot lock hardware for suspend\n",
-		       dev->name);
-		return err;
-	}
-
-	err =3D __orinoco_down(dev);
-	if (err)
-		printk(KERN_WARNING "%s: error %d bringing interface down "
-		       "for suspend\n", dev->name, err);
-=09
-	netif_device_detach(dev);
-
-	priv->hw_unavailable++;
-=09
-	orinoco_unlock(priv, &flags);
-
-	free_irq(pdev->irq, dev);
-	pci_save_state(pdev);
-	pci_disable_device(pdev);
-	pci_set_power_state(pdev, PCI_D3hot);
-
-	return 0;
-}
-
-static int orinoco_nortel_resume(struct pci_dev *pdev)
-{
-	struct net_device *dev =3D pci_get_drvdata(pdev);
-	struct orinoco_private *priv =3D netdev_priv(dev);
-	unsigned long flags;
-	int err;
-
-	pci_set_power_state(pdev, 0);
-	pci_enable_device(pdev);
-	pci_restore_state(pdev);
-
-	err =3D request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
-			  dev->name, dev);
-	if (err) {
-		printk(KERN_ERR "%s: cannot re-allocate IRQ on resume\n",
-		       dev->name);
-		pci_disable_device(pdev);
-		return -EBUSY;
-	}
-
-	err =3D orinoco_reinit_firmware(dev);
-	if (err) {
-		printk(KERN_ERR "%s: error %d re-initializing firmware "
-		       "on resume\n", dev->name, err);
-		return err;
-	}
-
-	spin_lock_irqsave(&priv->lock, flags);
-
-	netif_device_attach(dev);
-
-	priv->hw_unavailable--;
-
-	if (priv->open && (! priv->hw_unavailable)) {
-		err =3D __orinoco_up(dev);
-		if (err)
-			printk(KERN_ERR "%s: Error %d restarting card on resume\n",
-			       dev->name, err);
-	}
-=09
-	spin_unlock_irqrestore(&priv->lock, flags);
-
-	return 0;
 }
=20
-static struct pci_device_id nortel_pci_id_table[] =3D {
+static struct pci_device_id orinoco_nortel_id_table[] =3D {
 	/* Nortel emobility PCI */
 	{0x126c, 0x8030, PCI_ANY_ID, PCI_ANY_ID,},
 	/* Symbol LA-4123 PCI */
@@ -349,15 +284,15 @@ static struct pci_device_id nortel_pci_i
 	{0,},
 };
=20
-MODULE_DEVICE_TABLE(pci, nortel_pci_id_table);
+MODULE_DEVICE_TABLE(pci, orinoco_nortel_id_table);
=20
-static struct pci_driver nortel_pci_driver =3D {
+static struct pci_driver orinoco_nortel_driver =3D {
 	.name		=3D DRIVER_NAME,
-	.id_table	=3D nortel_pci_id_table,
-	.probe		=3D nortel_pci_init_one,
-	.remove		=3D __devexit_p(nortel_pci_remove_one),
-	.suspend	=3D orinoco_nortel_suspend,
-	.resume		=3D orinoco_nortel_resume,
+	.id_table	=3D orinoco_nortel_id_table,
+	.probe		=3D orinoco_nortel_init_one,
+	.remove		=3D __devexit_p(orinoco_nortel_remove_one),
+	.suspend	=3D orinoco_pci_suspend,
+	.resume		=3D orinoco_pci_resume,
 };
=20
 static char version[] __initdata =3D DRIVER_NAME " " DRIVER_VERSION
@@ -367,20 +302,19 @@ MODULE_DESCRIPTION
     ("Driver for wireless LAN cards using the Nortel PCI bridge");
 MODULE_LICENSE("Dual MPL/GPL");
=20
-static int __init nortel_pci_init(void)
+static int __init orinoco_nortel_init(void)
 {
 	printk(KERN_DEBUG "%s\n", version);
-	return pci_module_init(&nortel_pci_driver);
+	return pci_module_init(&orinoco_nortel_driver);
 }
=20
-static void __exit nortel_pci_exit(void)
+static void __exit orinoco_nortel_exit(void)
 {
-	pci_unregister_driver(&nortel_pci_driver);
-	ssleep(1);
+	pci_unregister_driver(&orinoco_nortel_driver);
 }
=20
-module_init(nortel_pci_init);
-module_exit(nortel_pci_exit);
+module_init(orinoco_nortel_init);
+module_exit(orinoco_nortel_exit);
=20
 /*
  * Local variables:
diff --git a/drivers/net/wireless/orinoco_pci.c b/drivers/net/wireless/or=
inoco_pci.c
index 75df90f..41efac2 100644
--- a/drivers/net/wireless/orinoco_pci.c
+++ b/drivers/net/wireless/orinoco_pci.c
@@ -100,6 +100,7 @@ #include <linux/delay.h>
 #include <linux/pci.h>
=20
 #include "orinoco.h"
+#include "orinoco_pci.h"
=20
 /* All the magic there is from wlan-ng */
 /* Magic offset of the reset register of the PCI card */
@@ -113,11 +114,6 @@ #define HERMES_PCI_COR_ONT	(250)		/* ms=20
 #define HERMES_PCI_COR_OFFT	(500)		/* ms */
 #define HERMES_PCI_COR_BUSYT	(500)		/* ms */
=20
-/* Orinoco PCI specific data */
-struct orinoco_pci_card {
-	void __iomem *pci_ioaddr;
-};
-
 /*
  * Do a soft reset of the PCI card using the Configuration Option Regist=
er
  * We need this to get going...
@@ -131,12 +127,11 @@ struct orinoco_pci_card {
  * Note bis : Don't try to access HERMES_CMD during the reset phase.
  * It just won't work !
  */
-static int
-orinoco_pci_cor_reset(struct orinoco_private *priv)
+static int orinoco_pci_cor_reset(struct orinoco_private *priv)
 {
 	hermes_t *hw =3D &priv->hw;
-	unsigned long	timeout;
-	u16	reg;
+	unsigned long timeout;
+	u16 reg;
=20
 	/* Assert the reset until the card notice */
 	hermes_write_regn(hw, PCI_COR, HERMES_PCI_COR_MASK);
@@ -163,17 +158,14 @@ orinoco_pci_cor_reset(struct orinoco_pri
 	return 0;
 }
=20
-/*
- * Initialise a card. Mostly similar to PLX code.
- */
 static int orinoco_pci_init_one(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
-	int err =3D 0;
-	void __iomem *pci_ioaddr =3D NULL;
-	struct orinoco_private *priv =3D NULL;
+	int err;
+	struct orinoco_private *priv;
 	struct orinoco_pci_card *card;
-	struct net_device *dev =3D NULL;
+	struct net_device *dev;
+	void __iomem *hermes_io;
=20
 	err =3D pci_enable_device(pdev);
 	if (err) {
@@ -182,39 +174,33 @@ static int orinoco_pci_init_one(struct p
 	}
=20
 	err =3D pci_request_regions(pdev, DRIVER_NAME);
-	if (err !=3D 0) {
+	if (err) {
 		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
 		goto fail_resources;
 	}
=20
-	/* Resource 0 is mapped to the hermes registers */
-	pci_ioaddr =3D pci_iomap(pdev, 0, 0);
-	if (!pci_ioaddr) {
+	hermes_io =3D pci_iomap(pdev, 0, 0);
+	if (!hermes_io) {
+		printk(KERN_ERR PFX "Cannot remap chipset registers\n");
 		err =3D -EIO;
-		printk(KERN_ERR PFX "Cannot remap hardware registers\n");
-		goto fail_map;
+		goto fail_map_hermes;
 	}
=20
 	/* Allocate network device */
 	dev =3D alloc_orinocodev(sizeof(*card), orinoco_pci_cor_reset);
-	if (! dev) {
+	if (!dev) {
+		printk(KERN_ERR PFX "Cannot allocate network device\n");
 		err =3D -ENOMEM;
 		goto fail_alloc;
 	}
=20
 	priv =3D netdev_priv(dev);
 	card =3D priv->card;
-	card->pci_ioaddr =3D pci_ioaddr;
-	dev->mem_start =3D pci_resource_start(pdev, 0);
-	dev->mem_end =3D dev->mem_start + pci_resource_len(pdev, 0) - 1;
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
=20
-	hermes_struct_init(&priv->hw, pci_ioaddr, HERMES_32BIT_REGSPACING);
+	hermes_struct_init(&priv->hw, hermes_io, HERMES_32BIT_REGSPACING);
=20
-	printk(KERN_DEBUG PFX "Detected device %s, mem:0x%lx-0x%lx, irq %d\n",
-	       pci_name(pdev), dev->mem_start, dev->mem_end, pdev->irq);
-
 	err =3D request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
 			  dev->name, dev);
 	if (err) {
@@ -222,9 +208,8 @@ static int orinoco_pci_init_one(struct p
 		err =3D -EBUSY;
 		goto fail_irq;
 	}
-	dev->irq =3D pdev->irq;
+	orinoco_pci_setup_netdev(dev, pdev, 0);
=20
-	/* Perform a COR reset to start the card */
 	err =3D orinoco_pci_cor_reset(priv);
 	if (err) {
 		printk(KERN_ERR PFX "Initial reset failed\n");
@@ -233,7 +218,7 @@ static int orinoco_pci_init_one(struct p
=20
 	err =3D register_netdev(dev);
 	if (err) {
-		printk(KERN_ERR PFX "Failed to register net device\n");
+		printk(KERN_ERR PFX "Cannot register network device\n");
 		goto fail;
 	}
=20
@@ -249,9 +234,9 @@ static int orinoco_pci_init_one(struct p
 	free_orinocodev(dev);
=20
  fail_alloc:
-	iounmap(pci_ioaddr);
+	pci_iounmap(pdev, hermes_io);
=20
- fail_map:
+ fail_map_hermes:
 	pci_release_regions(pdev);
=20
  fail_resources:
@@ -264,98 +249,17 @@ static void __devexit orinoco_pci_remove
 {
 	struct net_device *dev =3D pci_get_drvdata(pdev);
 	struct orinoco_private *priv =3D netdev_priv(dev);
-	struct orinoco_pci_card *card =3D priv->card;
=20
 	unregister_netdev(dev);
 	free_irq(dev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
 	free_orinocodev(dev);
-	iounmap(card->pci_ioaddr);
+	pci_iounmap(pdev, priv->hw.iobase);
 	pci_release_regions(pdev);
-	pci_disable_device(pdev);
-}
-
-static int orinoco_pci_suspend(struct pci_dev *pdev, pm_message_t state)
-{
-	struct net_device *dev =3D pci_get_drvdata(pdev);
-	struct orinoco_private *priv =3D netdev_priv(dev);
-	unsigned long flags;
-	int err;
-=09
-
-	err =3D orinoco_lock(priv, &flags);
-	if (err) {
-		printk(KERN_ERR "%s: hw_unavailable on orinoco_pci_suspend\n",
-		       dev->name);
-		return err;
-	}
-
-	err =3D __orinoco_down(dev);
-	if (err)
-		printk(KERN_WARNING "%s: orinoco_pci_suspend(): Error %d downing inter=
face\n",
-		       dev->name, err);
-=09
-	netif_device_detach(dev);
-
-	priv->hw_unavailable++;
-=09
-	orinoco_unlock(priv, &flags);
-
-	free_irq(pdev->irq, dev);
-	pci_save_state(pdev);
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, PCI_D3hot);
-
-	return 0;
-}
-
-static int orinoco_pci_resume(struct pci_dev *pdev)
-{
-	struct net_device *dev =3D pci_get_drvdata(pdev);
-	struct orinoco_private *priv =3D netdev_priv(dev);
-	unsigned long flags;
-	int err;
-
-	printk(KERN_DEBUG "%s: Orinoco-PCI waking up\n", dev->name);
-
-	pci_set_power_state(pdev, 0);
-	pci_enable_device(pdev);
-	pci_restore_state(pdev);
-
-	err =3D request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
-			  dev->name, dev);
-	if (err) {
-		printk(KERN_ERR "%s: Cannot re-allocate IRQ\n", dev->name);
-		pci_disable_device(pdev);
-		return -EBUSY;
-	}
-
-	err =3D orinoco_reinit_firmware(dev);
-	if (err) {
-		printk(KERN_ERR "%s: Error %d re-initializing firmware on orinoco_pci_=
resume()\n",
-		       dev->name, err);
-		return err;
-	}
-
-	spin_lock_irqsave(&priv->lock, flags);
-
-	netif_device_attach(dev);
-
-	priv->hw_unavailable--;
-
-	if (priv->open && (! priv->hw_unavailable)) {
-		err =3D __orinoco_up(dev);
-		if (err)
-			printk(KERN_ERR "%s: Error %d restarting card on orinoco_pci_resume()=
\n",
-			       dev->name, err);
-	}
-=09
-	spin_unlock_irqrestore(&priv->lock, flags);
-
-	return 0;
 }
=20
-static struct pci_device_id orinoco_pci_pci_id_table[] =3D {
+static struct pci_device_id orinoco_pci_id_table[] =3D {
 	/* Intersil Prism 3 */
 	{0x1260, 0x3872, PCI_ANY_ID, PCI_ANY_ID,},
 	/* Intersil Prism 2.5 */
@@ -365,11 +269,11 @@ static struct pci_device_id orinoco_pci_
 	{0,},
 };
=20
-MODULE_DEVICE_TABLE(pci, orinoco_pci_pci_id_table);
+MODULE_DEVICE_TABLE(pci, orinoco_pci_id_table);
=20
 static struct pci_driver orinoco_pci_driver =3D {
 	.name		=3D DRIVER_NAME,
-	.id_table	=3D orinoco_pci_pci_id_table,
+	.id_table	=3D orinoco_pci_id_table,
 	.probe		=3D orinoco_pci_init_one,
 	.remove		=3D __devexit_p(orinoco_pci_remove_one),
 	.suspend	=3D orinoco_pci_suspend,
diff --git a/drivers/net/wireless/orinoco_pci.h b/drivers/net/wireless/or=
inoco_pci.h
new file mode 100644
index 0000000..b05a9a5
--- /dev/null
+++ b/drivers/net/wireless/orinoco_pci.h
@@ -0,0 +1,125 @@
+/* orinoco_pci.h
+ *=20
+ * Common code for all Orinoco drivers for PCI devices, including
+ * both native PCI and PCMCIA-to-PCI bridges.
+ *
+ * Copyright (C) 2005, Pavel Roskin.
+ * See orinoco.c for license.
+ */
+
+#ifndef _ORINOCO_PCI_H
+#define _ORINOCO_PCI_H
+
+#include <linux/netdevice.h>
+
+/* Driver specific data */
+struct orinoco_pci_card {
+	void __iomem *bridge_io;
+	void __iomem *attr_io;
+};
+
+/* Set base address or memory range of the network device based on
+ * the PCI device it's using.  Specify BAR of the "main" resource.
+ * To be used after request_irq().  */
+static inline void orinoco_pci_setup_netdev(struct net_device *dev,
+					    struct pci_dev *pdev, int bar)
+{
+	char *range_type;
+	unsigned long start =3D pci_resource_start(pdev, bar);
+	unsigned long len =3D pci_resource_len(pdev, bar);
+	unsigned long flags =3D pci_resource_flags(pdev, bar);
+	unsigned long end =3D start + len - 1;
+
+	dev->irq =3D pdev->irq;
+	if (flags & IORESOURCE_IO) {
+		dev->base_addr =3D start;
+		range_type =3D "ports";
+	} else {
+		dev->mem_start =3D start;
+		dev->mem_end =3D end;
+		range_type =3D "memory";
+	}
+
+	printk(KERN_DEBUG PFX "%s: irq %d, %s 0x%lx-0x%lx\n",
+	       pci_name(pdev), pdev->irq, range_type, start, end);
+}
+
+static int orinoco_pci_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct orinoco_private *priv =3D netdev_priv(dev);
+	unsigned long flags;
+	int err;
+
+	err =3D orinoco_lock(priv, &flags);
+	if (err) {
+		printk(KERN_ERR "%s: cannot lock hardware for suspend\n",
+		       dev->name);
+		return err;
+	}
+
+	err =3D __orinoco_down(dev);
+	if (err)
+		printk(KERN_WARNING "%s: error %d bringing interface down "
+		       "for suspend\n", dev->name, err);
+=09
+	netif_device_detach(dev);
+
+	priv->hw_unavailable++;
+=09
+	orinoco_unlock(priv, &flags);
+
+	free_irq(pdev->irq, dev);
+	pci_save_state(pdev);
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
+
+	return 0;
+}
+
+static int orinoco_pci_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev =3D pci_get_drvdata(pdev);
+	struct orinoco_private *priv =3D netdev_priv(dev);
+	unsigned long flags;
+	int err;
+
+	pci_set_power_state(pdev, 0);
+	pci_enable_device(pdev);
+	pci_restore_state(pdev);
+
+	err =3D request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
+			  dev->name, dev);
+	if (err) {
+		printk(KERN_ERR "%s: cannot re-allocate IRQ on resume\n",
+		       dev->name);
+		pci_disable_device(pdev);
+		return -EBUSY;
+	}
+
+	err =3D orinoco_reinit_firmware(dev);
+	if (err) {
+		printk(KERN_ERR "%s: error %d re-initializing firmware "
+		       "on resume\n", dev->name, err);
+		return err;
+	}
+
+	spin_lock_irqsave(&priv->lock, flags);
+
+	netif_device_attach(dev);
+
+	priv->hw_unavailable--;
+
+	if (priv->open && (! priv->hw_unavailable)) {
+		err =3D __orinoco_up(dev);
+		if (err)
+			printk(KERN_ERR "%s: Error %d restarting card on resume\n",
+			       dev->name, err);
+	}
+=09
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return 0;
+}
+
+#endif /* _ORINOCO_PCI_H */
diff --git a/drivers/net/wireless/orinoco_plx.c b/drivers/net/wireless/or=
inoco_plx.c
index 3fe7a2f..c00388e 100644
--- a/drivers/net/wireless/orinoco_plx.c
+++ b/drivers/net/wireless/orinoco_plx.c
@@ -33,7 +33,7 @@
=20
  * Caution: this is experimental and probably buggy.  For success and
  * failure reports for different cards and adaptors, see
- * orinoco_plx_pci_id_table near the end of the file.  If you have a
+ * orinoco_plx_id_table near the end of the file.  If you have a
  * card we don't have the PCI id for, and looks like it should work,
  * drop me mail with the id and "it works"/"it doesn't work".
  *
@@ -125,6 +125,7 @@ #include <linux/pci.h>
 #include <pcmcia/cisreg.h>
=20
 #include "orinoco.h"
+#include "orinoco_pci.h"
=20
 #define COR_OFFSET	(0x3e0)	/* COR attribute offset of Prism2 PC card */
 #define COR_VALUE	(COR_LEVEL_REQ | COR_FUNC_ENA) /* Enable PC card with =
interrupt in level trigger */
@@ -134,30 +135,20 @@ #define PLX_RESET_TIME	(500)	/* millisec
 #define PLX_INTCSR		0x4c /* Interrupt Control & Status Register */
 #define PLX_INTCSR_INTEN	(1<<6) /* Interrupt Enable bit */
=20
-static const u8 cis_magic[] =3D {
-	0x01, 0x03, 0x00, 0x00, 0xff, 0x17, 0x04, 0x67
-};
-
-/* Orinoco PLX specific data */
-struct orinoco_plx_card {
-	void __iomem *attr_mem;
-};
-
 /*
  * Do a soft reset of the card using the Configuration Option Register
  */
 static int orinoco_plx_cor_reset(struct orinoco_private *priv)
 {
 	hermes_t *hw =3D &priv->hw;
-	struct orinoco_plx_card *card =3D priv->card;
-	u8 __iomem *attr_mem =3D card->attr_mem;
+	struct orinoco_pci_card *card =3D priv->card;
 	unsigned long timeout;
 	u16 reg;
=20
-	writeb(COR_VALUE | COR_RESET, attr_mem + COR_OFFSET);
+	iowrite8(COR_VALUE | COR_RESET, card->attr_io + COR_OFFSET);
 	mdelay(1);
=20
-	writeb(COR_VALUE, attr_mem + COR_OFFSET);
+	iowrite8(COR_VALUE, card->attr_io + COR_OFFSET);
 	mdelay(1);
=20
 	/* Just in case, wait more until the card is no longer busy */
@@ -168,7 +159,7 @@ static int orinoco_plx_cor_reset(struct=20
 		reg =3D hermes_read_regn(hw, CMD);
 	}
=20
-	/* Did we timeout ? */
+	/* Still busy? */
 	if (reg & HERMES_CMD_BUSY) {
 		printk(KERN_ERR PFX "Busy timeout\n");
 		return -ETIMEDOUT;
@@ -176,21 +167,56 @@ static int orinoco_plx_cor_reset(struct=20
=20
 	return 0;
 }
+
+static int orinoco_plx_hw_init(struct orinoco_pci_card *card)
+{
+	int i;
+	u32 csr_reg;
+	static const u8 cis_magic[] =3D {
+		0x01, 0x03, 0x00, 0x00, 0xff, 0x17, 0x04, 0x67
+	};
+
+	printk(KERN_DEBUG PFX "CIS: ");
+	for (i =3D 0; i < 16; i++) {
+		printk("%02X:", ioread8(card->attr_io + (i << 1)));
+	}
+	printk("\n");
+
+	/* Verify whether a supported PC card is present */
+	/* FIXME: we probably need to be smarted about this */
+	for (i =3D 0; i < sizeof(cis_magic); i++) {
+		if (cis_magic[i] !=3D ioread8(card->attr_io + (i << 1))) {
+			printk(KERN_ERR PFX "The CIS value of Prism2 PC "
+			       "card is unexpected\n");
+			return -ENODEV;
+		}
+	}
+
+	/* bjoern: We need to tell the card to enable interrupts, in
+	   case the serial eprom didn't do this already.  See the
+	   PLX9052 data book, p8-1 and 8-24 for reference. */
+	csr_reg =3D ioread32(card->bridge_io + PLX_INTCSR);
+	if (!(csr_reg & PLX_INTCSR_INTEN)) {
+		csr_reg |=3D PLX_INTCSR_INTEN;
+		iowrite32(csr_reg, card->bridge_io + PLX_INTCSR);
+		csr_reg =3D ioread32(card->bridge_io + PLX_INTCSR);
+		if (!(csr_reg & PLX_INTCSR_INTEN)) {
+			printk(KERN_ERR PFX "Cannot enable interrupts\n");
+			return -EIO;
+		}
+	}
=20
+	return 0;
+}
=20
 static int orinoco_plx_init_one(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
-	int err =3D 0;
-	u8 __iomem *attr_mem =3D NULL;
-	u32 csr_reg, plx_addr;
-	struct orinoco_private *priv =3D NULL;
-	struct orinoco_plx_card *card;
-	unsigned long pccard_ioaddr =3D 0;
-	unsigned long pccard_iolen =3D 0;
-	struct net_device *dev =3D NULL;
-	void __iomem *mem;
-	int i;
+	int err;
+	struct orinoco_private *priv;
+	struct orinoco_pci_card *card;
+	struct net_device *dev;
+	void __iomem *hermes_io, *attr_io, *bridge_io;
=20
 	err =3D pci_enable_device(pdev);
 	if (err) {
@@ -199,30 +225,30 @@ static int orinoco_plx_init_one(struct p
 	}
=20
 	err =3D pci_request_regions(pdev, DRIVER_NAME);
-	if (err !=3D 0) {
+	if (err) {
 		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
 		goto fail_resources;
 	}
=20
-	/* Resource 1 is mapped to PLX-specific registers */
-	plx_addr =3D pci_resource_start(pdev, 1);
+	bridge_io =3D pci_iomap(pdev, 1, 0);
+	if (!bridge_io) {
+		printk(KERN_ERR PFX "Cannot map bridge registers\n");
+		err =3D -EIO;
+		goto fail_map_bridge;
+	}
=20
-	/* Resource 2 is mapped to the PCMCIA attribute memory */
-	attr_mem =3D ioremap(pci_resource_start(pdev, 2),
-			   pci_resource_len(pdev, 2));
-	if (!attr_mem) {
-		printk(KERN_ERR PFX "Cannot remap PCMCIA space\n");
+	attr_io =3D pci_iomap(pdev, 2, 0);
+	if (!attr_io) {
+		printk(KERN_ERR PFX "Cannot map PCMCIA attributes\n");
+		err =3D -EIO;
 		goto fail_map_attr;
 	}
=20
-	/* Resource 3 is mapped to the PCMCIA I/O address space */
-	pccard_ioaddr =3D pci_resource_start(pdev, 3);
-	pccard_iolen =3D pci_resource_len(pdev, 3);
-
-	mem =3D pci_iomap(pdev, 3, 0);
-	if (!mem) {
-		err =3D -ENOMEM;
-		goto fail_map_io;
+	hermes_io =3D pci_iomap(pdev, 3, 0);
+	if (!hermes_io) {
+		printk(KERN_ERR PFX "Cannot map chipset registers\n");
+		err =3D -EIO;
+		goto fail_map_hermes;
 	}
=20
 	/* Allocate network device */
@@ -235,16 +261,12 @@ static int orinoco_plx_init_one(struct p
=20
 	priv =3D netdev_priv(dev);
 	card =3D priv->card;
-	card->attr_mem =3D attr_mem;
-	dev->base_addr =3D pccard_ioaddr;
+	card->bridge_io =3D bridge_io;
+	card->attr_io =3D attr_io;
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
-
-	hermes_struct_init(&priv->hw, mem, HERMES_16BIT_REGSPACING);
=20
-	printk(KERN_DEBUG PFX "Detected Orinoco/Prism2 PLX device "
-	       "at %s irq:%d, io addr:0x%lx\n", pci_name(pdev), pdev->irq,
-	       pccard_ioaddr);
+	hermes_struct_init(&priv->hw, hermes_io, HERMES_16BIT_REGSPACING);
=20
 	err =3D request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
 			  dev->name, dev);
@@ -253,45 +275,20 @@ static int orinoco_plx_init_one(struct p
 		err =3D -EBUSY;
 		goto fail_irq;
 	}
-	dev->irq =3D pdev->irq;
+	orinoco_pci_setup_netdev(dev, pdev, 2);
=20
-	/* bjoern: We need to tell the card to enable interrupts, in
-	   case the serial eprom didn't do this already.  See the
-	   PLX9052 data book, p8-1 and 8-24 for reference. */
-	csr_reg =3D inl(plx_addr + PLX_INTCSR);
-	if (!(csr_reg & PLX_INTCSR_INTEN)) {
-		csr_reg |=3D PLX_INTCSR_INTEN;
-		outl(csr_reg, plx_addr + PLX_INTCSR);
-		csr_reg =3D inl(plx_addr + PLX_INTCSR);
-		if (!(csr_reg & PLX_INTCSR_INTEN)) {
-			printk(KERN_ERR PFX "Cannot enable interrupts\n");
-			goto fail;
-		}
+	err =3D orinoco_plx_hw_init(card);
+	if (err) {
+		printk(KERN_ERR PFX "Hardware initialization failed\n");
+		goto fail;
 	}
=20
 	err =3D orinoco_plx_cor_reset(priv);
 	if (err) {
 		printk(KERN_ERR PFX "Initial reset failed\n");
 		goto fail;
-	}
-
-	printk(KERN_DEBUG PFX "CIS: ");
-	for (i =3D 0; i < 16; i++) {
-		printk("%02X:", readb(attr_mem + 2*i));
 	}
-	printk("\n");
=20
-	/* Verify whether a supported PC card is present */
-	/* FIXME: we probably need to be smarted about this */
-	for (i =3D 0; i < sizeof(cis_magic); i++) {
-		if (cis_magic[i] !=3D readb(attr_mem +2*i)) {
-			printk(KERN_ERR PFX "The CIS value of Prism2 PC "
-			       "card is unexpected\n");
-			err =3D -EIO;
-			goto fail;
-		}
-	}
-
 	err =3D register_netdev(dev);
 	if (err) {
 		printk(KERN_ERR PFX "Cannot register network device\n");
@@ -310,12 +307,15 @@ static int orinoco_plx_init_one(struct p
 	free_orinocodev(dev);
=20
  fail_alloc:
-	pci_iounmap(pdev, mem);
+	pci_iounmap(pdev, hermes_io);
=20
- fail_map_io:
-	iounmap(attr_mem);
+ fail_map_hermes:
+	pci_iounmap(pdev, attr_io);
=20
  fail_map_attr:
+	pci_iounmap(pdev, bridge_io);
+
+ fail_map_bridge:
 	pci_release_regions(pdev);
=20
  fail_resources:
@@ -328,100 +328,20 @@ static void __devexit orinoco_plx_remove
 {
 	struct net_device *dev =3D pci_get_drvdata(pdev);
 	struct orinoco_private *priv =3D netdev_priv(dev);
-	struct orinoco_plx_card *card =3D priv->card;
-	u8 __iomem *attr_mem =3D card->attr_mem;
-
-	BUG_ON(! dev);
+	struct orinoco_pci_card *card =3D priv->card;
=20
 	unregister_netdev(dev);
 	free_irq(dev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
 	free_orinocodev(dev);
 	pci_iounmap(pdev, priv->hw.iobase);
-	iounmap(attr_mem);
+	pci_iounmap(pdev, card->attr_io);
+	pci_iounmap(pdev, card->bridge_io);
 	pci_release_regions(pdev);
-	pci_disable_device(pdev);
-}
-
-static int orinoco_plx_suspend(struct pci_dev *pdev, pm_message_t state)
-{
-	struct net_device *dev =3D pci_get_drvdata(pdev);
-	struct orinoco_private *priv =3D netdev_priv(dev);
-	unsigned long flags;
-	int err;
-
-	err =3D orinoco_lock(priv, &flags);
-	if (err) {
-		printk(KERN_ERR "%s: cannot lock hardware for suspend\n",
-		       dev->name);
-		return err;
-	}
-
-	err =3D __orinoco_down(dev);
-	if (err)
-		printk(KERN_WARNING "%s: error %d bringing interface down "
-		       "for suspend\n", dev->name, err);
-=09
-	netif_device_detach(dev);
-
-	priv->hw_unavailable++;
-=09
-	orinoco_unlock(priv, &flags);
-
-	free_irq(pdev->irq, dev);
-	pci_save_state(pdev);
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, PCI_D3hot);
-
-	return 0;
-}
-
-static int orinoco_plx_resume(struct pci_dev *pdev)
-{
-	struct net_device *dev =3D pci_get_drvdata(pdev);
-	struct orinoco_private *priv =3D netdev_priv(dev);
-	unsigned long flags;
-	int err;
-
-	pci_set_power_state(pdev, 0);
-	pci_enable_device(pdev);
-	pci_restore_state(pdev);
-
-	err =3D request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
-			  dev->name, dev);
-	if (err) {
-		printk(KERN_ERR "%s: cannot re-allocate IRQ on resume\n",
-		       dev->name);
-		pci_disable_device(pdev);
-		return -EBUSY;
-	}
-
-	err =3D orinoco_reinit_firmware(dev);
-	if (err) {
-		printk(KERN_ERR "%s: error %d re-initializing firmware "
-		       "on resume\n", dev->name, err);
-		return err;
-	}
-
-	spin_lock_irqsave(&priv->lock, flags);
-
-	netif_device_attach(dev);
-
-	priv->hw_unavailable--;
-
-	if (priv->open && (! priv->hw_unavailable)) {
-		err =3D __orinoco_up(dev);
-		if (err)
-			printk(KERN_ERR "%s: Error %d restarting card on resume\n",
-			       dev->name, err);
-	}
-=09
-	spin_unlock_irqrestore(&priv->lock, flags);
-
-	return 0;
 }
=20
-static struct pci_device_id orinoco_plx_pci_id_table[] =3D {
+static struct pci_device_id orinoco_plx_id_table[] =3D {
 	{0x111a, 0x1023, PCI_ANY_ID, PCI_ANY_ID,},	/* Siemens SpeedStream SS102=
3 */
 	{0x1385, 0x4100, PCI_ANY_ID, PCI_ANY_ID,},	/* Netgear MA301 */
 	{0x15e8, 0x0130, PCI_ANY_ID, PCI_ANY_ID,},	/* Correga  - does this work=
? */
@@ -439,15 +359,15 @@ static struct pci_device_id orinoco_plx_
 	{0,},
 };
=20
-MODULE_DEVICE_TABLE(pci, orinoco_plx_pci_id_table);
+MODULE_DEVICE_TABLE(pci, orinoco_plx_id_table);
=20
 static struct pci_driver orinoco_plx_driver =3D {
 	.name		=3D DRIVER_NAME,
-	.id_table	=3D orinoco_plx_pci_id_table,
+	.id_table	=3D orinoco_plx_id_table,
 	.probe		=3D orinoco_plx_init_one,
 	.remove		=3D __devexit_p(orinoco_plx_remove_one),
-	.suspend	=3D orinoco_plx_suspend,
-	.resume		=3D orinoco_plx_resume,
+	.suspend	=3D orinoco_pci_suspend,
+	.resume		=3D orinoco_pci_resume,
 };
=20
 static char version[] __initdata =3D DRIVER_NAME " " DRIVER_VERSION
@@ -467,7 +387,6 @@ static int __init orinoco_plx_init(void)
 static void __exit orinoco_plx_exit(void)
 {
 	pci_unregister_driver(&orinoco_plx_driver);
-	ssleep(1);
 }
=20
 module_init(orinoco_plx_init);
diff --git a/drivers/net/wireless/orinoco_tmd.c b/drivers/net/wireless/or=
inoco_tmd.c
index b74807d..438fe54 100644
--- a/drivers/net/wireless/orinoco_tmd.c
+++ b/drivers/net/wireless/orinoco_tmd.c
@@ -1,5 +1,5 @@
 /* orinoco_tmd.c
- *=20
+ *
  * Driver for Prism II devices which would usually be driven by orinoco_=
cs,
  * but are connected to the PCI bus by a TMD7160.=20
  *
@@ -29,14 +29,14 @@
=20
  * Caution: this is experimental and probably buggy.  For success and
  * failure reports for different cards and adaptors, see
- * orinoco_tmd_pci_id_table near the end of the file.  If you have a
+ * orinoco_tmd_id_table near the end of the file.  If you have a
  * card we don't have the PCI id for, and looks like it should work,
  * drop me mail with the id and "it works"/"it doesn't work".
  *
  * Note: if everything gets detected fine but it doesn't actually send
- * or receive packets, your first port of call should probably be to  =20
+ * or receive packets, your first port of call should probably be to
  * try newer firmware in the card.  Especially if you're doing Ad-Hoc
- * modes
+ * modes.
  *
  * The actual driving is done by orinoco.c, this is just resource
  * allocation stuff.
@@ -61,16 +61,11 @@ #include <linux/pci.h>
 #include <pcmcia/cisreg.h>
=20
 #include "orinoco.h"
+#include "orinoco_pci.h"
=20
 #define COR_VALUE	(COR_LEVEL_REQ | COR_FUNC_ENA) /* Enable PC card with =
interrupt in level trigger */
 #define COR_RESET     (0x80)	/* reset bit in the COR register */
 #define TMD_RESET_TIME	(500)	/* milliseconds */
-
-/* Orinoco TMD specific data */
-struct orinoco_tmd_card {
-	u32 tmd_io;
-};
-
=20
 /*
  * Do a soft reset of the card using the Configuration Option Register
@@ -78,15 +73,14 @@ struct orinoco_tmd_card {
 static int orinoco_tmd_cor_reset(struct orinoco_private *priv)
 {
 	hermes_t *hw =3D &priv->hw;
-	struct orinoco_tmd_card *card =3D priv->card;
-	u32 addr =3D card->tmd_io;
+	struct orinoco_pci_card *card =3D priv->card;
 	unsigned long timeout;
 	u16 reg;
=20
-	outb(COR_VALUE | COR_RESET, addr);
+	iowrite8(COR_VALUE | COR_RESET, card->bridge_io);
 	mdelay(1);
=20
-	outb(COR_VALUE, addr);
+	iowrite8(COR_VALUE, card->bridge_io);
 	mdelay(1);
=20
 	/* Just in case, wait more until the card is no longer busy */
@@ -97,7 +91,7 @@ static int orinoco_tmd_cor_reset(struct=20
 		reg =3D hermes_read_regn(hw, CMD);
 	}
=20
-	/* Did we timeout ? */
+	/* Still busy? */
 	if (reg & HERMES_CMD_BUSY) {
 		printk(KERN_ERR PFX "Busy timeout\n");
 		return -ETIMEDOUT;
@@ -110,11 +104,11 @@ static int orinoco_tmd_cor_reset(struct=20
 static int orinoco_tmd_init_one(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
-	int err =3D 0;
-	struct orinoco_private *priv =3D NULL;
-	struct orinoco_tmd_card *card;
-	struct net_device *dev =3D NULL;
-	void __iomem *mem;
+	int err;
+	struct orinoco_private *priv;
+	struct orinoco_pci_card *card;
+	struct net_device *dev;
+	void __iomem *hermes_io, *bridge_io;
=20
 	err =3D pci_enable_device(pdev);
 	if (err) {
@@ -123,20 +117,28 @@ static int orinoco_tmd_init_one(struct p
 	}
=20
 	err =3D pci_request_regions(pdev, DRIVER_NAME);
-	if (err !=3D 0) {
+	if (err) {
 		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
 		goto fail_resources;
 	}
=20
-	mem =3D pci_iomap(pdev, 2, 0);
-	if (! mem) {
-		err =3D -ENOMEM;
-		goto fail_iomap;
+	bridge_io =3D pci_iomap(pdev, 1, 0);
+	if (!bridge_io) {
+		printk(KERN_ERR PFX "Cannot map bridge registers\n");
+		err =3D -EIO;
+		goto fail_map_bridge;
 	}
=20
+	hermes_io =3D pci_iomap(pdev, 2, 0);
+	if (!hermes_io) {
+		printk(KERN_ERR PFX "Cannot map chipset registers\n");
+		err =3D -EIO;
+		goto fail_map_hermes;
+	}
+
 	/* Allocate network device */
 	dev =3D alloc_orinocodev(sizeof(*card), orinoco_tmd_cor_reset);
-	if (! dev) {
+	if (!dev) {
 		printk(KERN_ERR PFX "Cannot allocate network device\n");
 		err =3D -ENOMEM;
 		goto fail_alloc;
@@ -144,16 +146,11 @@ static int orinoco_tmd_init_one(struct p
=20
 	priv =3D netdev_priv(dev);
 	card =3D priv->card;
-	card->tmd_io =3D pci_resource_start(pdev, 1);
-	dev->base_addr =3D pci_resource_start(pdev, 2);
+	card->bridge_io =3D bridge_io;
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
-
-	hermes_struct_init(&priv->hw, mem, HERMES_16BIT_REGSPACING);
=20
-	printk(KERN_DEBUG PFX "Detected Orinoco/Prism2 TMD device "
-	       "at %s irq:%d, io addr:0x%lx\n", pci_name(pdev), pdev->irq,
-	       dev->base_addr);
+	hermes_struct_init(&priv->hw, hermes_io, HERMES_16BIT_REGSPACING);
=20
 	err =3D request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
 			  dev->name, dev);
@@ -162,7 +159,7 @@ static int orinoco_tmd_init_one(struct p
 		err =3D -EBUSY;
 		goto fail_irq;
 	}
-	dev->irq =3D pdev->irq;
+	orinoco_pci_setup_netdev(dev, pdev, 2);
=20
 	err =3D orinoco_tmd_cor_reset(priv);
 	if (err) {
@@ -188,9 +185,12 @@ static int orinoco_tmd_init_one(struct p
 	free_orinocodev(dev);
=20
  fail_alloc:
-	pci_iounmap(pdev, mem);
+	pci_iounmap(pdev, hermes_io);
=20
- fail_iomap:
+ fail_map_hermes:
+	pci_iounmap(pdev, bridge_io);
+
+ fail_map_bridge:
 	pci_release_regions(pdev);
=20
  fail_resources:
@@ -203,110 +203,32 @@ static void __devexit orinoco_tmd_remove
 {
 	struct net_device *dev =3D pci_get_drvdata(pdev);
 	struct orinoco_private *priv =3D dev->priv;
-
-	BUG_ON(! dev);
+	struct orinoco_pci_card *card =3D priv->card;
=20
 	unregister_netdev(dev);
 	free_irq(dev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
 	free_orinocodev(dev);
 	pci_iounmap(pdev, priv->hw.iobase);
+	pci_iounmap(pdev, card->bridge_io);
 	pci_release_regions(pdev);
-	pci_disable_device(pdev);
-}
-
-static int orinoco_tmd_suspend(struct pci_dev *pdev, pm_message_t state)
-{
-	struct net_device *dev =3D pci_get_drvdata(pdev);
-	struct orinoco_private *priv =3D netdev_priv(dev);
-	unsigned long flags;
-	int err;
-
-	err =3D orinoco_lock(priv, &flags);
-	if (err) {
-		printk(KERN_ERR "%s: cannot lock hardware for suspend\n",
-		       dev->name);
-		return err;
-	}
-
-	err =3D __orinoco_down(dev);
-	if (err)
-		printk(KERN_WARNING "%s: error %d bringing interface down "
-		       "for suspend\n", dev->name, err);
-=09
-	netif_device_detach(dev);
-
-	priv->hw_unavailable++;
-=09
-	orinoco_unlock(priv, &flags);
-
-	free_irq(pdev->irq, dev);
-	pci_save_state(pdev);
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, PCI_D3hot);
-
-	return 0;
-}
-
-static int orinoco_tmd_resume(struct pci_dev *pdev)
-{
-	struct net_device *dev =3D pci_get_drvdata(pdev);
-	struct orinoco_private *priv =3D netdev_priv(dev);
-	unsigned long flags;
-	int err;
-
-	pci_set_power_state(pdev, 0);
-	pci_enable_device(pdev);
-	pci_restore_state(pdev);
-
-	err =3D request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
-			  dev->name, dev);
-	if (err) {
-		printk(KERN_ERR "%s: cannot re-allocate IRQ on resume\n",
-		       dev->name);
-		pci_disable_device(pdev);
-		return -EBUSY;
-	}
-
-	err =3D orinoco_reinit_firmware(dev);
-	if (err) {
-		printk(KERN_ERR "%s: error %d re-initializing firmware "
-		       "on resume\n", dev->name, err);
-		return err;
-	}
-
-	spin_lock_irqsave(&priv->lock, flags);
-
-	netif_device_attach(dev);
-
-	priv->hw_unavailable--;
-
-	if (priv->open && (! priv->hw_unavailable)) {
-		err =3D __orinoco_up(dev);
-		if (err)
-			printk(KERN_ERR "%s: Error %d restarting card on resume\n",
-			       dev->name, err);
-	}
-=09
-	spin_unlock_irqrestore(&priv->lock, flags);
-
-	return 0;
 }
=20
-static struct pci_device_id orinoco_tmd_pci_id_table[] =3D {
+static struct pci_device_id orinoco_tmd_id_table[] =3D {
 	{0x15e8, 0x0131, PCI_ANY_ID, PCI_ANY_ID,},      /* NDC and OEMs, e.g. p=
heecom */
 	{0,},
 };
=20
-MODULE_DEVICE_TABLE(pci, orinoco_tmd_pci_id_table);
+MODULE_DEVICE_TABLE(pci, orinoco_tmd_id_table);
=20
 static struct pci_driver orinoco_tmd_driver =3D {
 	.name		=3D DRIVER_NAME,
-	.id_table	=3D orinoco_tmd_pci_id_table,
+	.id_table	=3D orinoco_tmd_id_table,
 	.probe		=3D orinoco_tmd_init_one,
 	.remove		=3D __devexit_p(orinoco_tmd_remove_one),
-	.suspend	=3D orinoco_tmd_suspend,
-	.resume		=3D orinoco_tmd_resume,
+	.suspend	=3D orinoco_pci_suspend,
+	.resume		=3D orinoco_pci_resume,
 };
=20
 static char version[] __initdata =3D DRIVER_NAME " " DRIVER_VERSION
@@ -324,7 +246,6 @@ static int __init orinoco_tmd_init(void)
 static void __exit orinoco_tmd_exit(void)
 {
 	pci_unregister_driver(&orinoco_tmd_driver);
-	ssleep(1);
 }
=20
 module_init(orinoco_tmd_init);



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
