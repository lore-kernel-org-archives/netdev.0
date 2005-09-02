From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 7/8] orinoco: New driver - orinoco_nortel.
Date: Thu, 01 Sep 2005 20:08:56 -0400
Message-ID: <1125619736.29016.8.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

diff-tree dce61aef99ceb57370b70222dc34d788666c0ac3 (from ceb6695092be8dcdfe2dec6ee5097d613011489d)
Author: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Date:   Thu Sep 1 15:50:55 2005 -0400

    New driver - orinoco_nortel.
    
    This is a driver for Nortel emobility PCI adaptors, which consist of an
    Orinoco compatible PCMCIA card and a simple PCI-to-PCMCIA bridge.  The
    driver initializes the device and uses Orinoco core driver for actual
    wireless networking.

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -203,10 +203,19 @@ config TMD_HERMES
 	  orinoco) driver when used in TMD7160 based PCI adaptors.  These
 	  adaptors are not a full PCMCIA controller but act as a more limited
 	  PCI <-> PCMCIA bridge.  Several vendors sell such adaptors so that
 	  802.11b PCMCIA cards can be used in desktop machines.
 
+config NORTEL_HERMES
+	tristate "Nortel emobility PCI adaptor support"
+	depends on PCI && HERMES
+	help
+	  Enable support for PCMCIA cards supported by the "Hermes" (aka
+	  orinoco) driver when used in Nortel emobility PCI adaptors.  These
+	  adaptors are not full PCMCIA controllers, but act as a more limited
+	  PCI <-> PCMCIA bridge.
+
 config PCI_HERMES
 	tristate "Prism 2.5 PCI 802.11b adaptor support"
 	depends on PCI && HERMES
 	help
 	  Enable support for PCI and mini-PCI 802.11b wireless NICs based on
diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -16,10 +16,11 @@ obj-$(CONFIG_HERMES)		+= orinoco.o herme
 obj-$(CONFIG_PCMCIA_HERMES)	+= orinoco_cs.o
 obj-$(CONFIG_APPLE_AIRPORT)	+= airport.o
 obj-$(CONFIG_PLX_HERMES)	+= orinoco_plx.o
 obj-$(CONFIG_PCI_HERMES)	+= orinoco_pci.o
 obj-$(CONFIG_TMD_HERMES)	+= orinoco_tmd.o
+obj-$(CONFIG_NORTEL_HERMES)	+= orinoco_nortel.o
 
 obj-$(CONFIG_AIRO)		+= airo.o
 obj-$(CONFIG_AIRO_CS)		+= airo_cs.o airo.o
 
 obj-$(CONFIG_ATMEL)             += atmel.o
diff --git a/drivers/net/wireless/orinoco_nortel.c b/drivers/net/wireless/orinoco_nortel.c
new file mode 100644
--- /dev/null
+++ b/drivers/net/wireless/orinoco_nortel.c
@@ -0,0 +1,324 @@
+/* orinoco_nortel.c
+ * 
+ * Driver for Prism II devices which would usually be driven by orinoco_cs,
+ * but are connected to the PCI bus by a Nortel PCI-PCMCIA-Adapter. 
+ *
+ * Copyright (C) 2002 Tobias Hoffmann
+ *           (C) 2003 Christoph Jungegger <disdos-Bv35esvkf38b1SvskN2V4Q@public.gmane.org>
+ *
+ * Some of this code is borrowed from orinoco_plx.c
+ *	Copyright (C) 2001 Daniel Barlow
+ * Some of this code is borrowed from orinoco_pci.c 
+ *  Copyright (C) 2001 Jean Tourrilhes
+ * Some of this code is "inspired" by linux-wlan-ng-0.1.10, but nothing
+ * has been copied from it. linux-wlan-ng-0.1.10 is originally :
+ *	Copyright (C) 1999 AbsoluteValue Systems, Inc.  All Rights Reserved.
+ * 
+ * The contents of this file are subject to the Mozilla Public License
+ * Version 1.1 (the "License"); you may not use this file except in
+ * compliance with the License. You may obtain a copy of the License
+ * at http://www.mozilla.org/MPL/
+ *
+ * Software distributed under the License is distributed on an "AS IS"
+ * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
+ * the License for the specific language governing rights and
+ * limitations under the License.
+ *
+ * Alternatively, the contents of this file may be used under the
+ * terms of the GNU General Public License version 2 (the "GPL"), in
+ * which case the provisions of the GPL are applicable instead of the
+ * above.  If you wish to allow the use of your version of this file
+ * only under the terms of the GPL and not to allow others to use your
+ * version of this file under the MPL, indicate your decision by
+ * deleting the provisions above and replace them with the notice and
+ * other provisions required by the GPL.  If you do not delete the
+ * provisions above, a recipient may use your version of this file
+ * under either the MPL or the GPL.
+ */
+
+#define DRIVER_NAME "orinoco_nortel"
+#define PFX DRIVER_NAME ": "
+
+#include <linux/config.h>
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/sched.h>
+#include <linux/ptrace.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/timer.h>
+#include <linux/ioport.h>
+#include <asm/uaccess.h>
+#include <asm/io.h>
+#include <asm/system.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/etherdevice.h>
+#include <linux/list.h>
+#include <linux/pci.h>
+#include <linux/fcntl.h>
+
+#include <pcmcia/cisreg.h>
+
+#include "hermes.h"
+#include "orinoco.h"
+
+#define COR_OFFSET    (0xe0)	/* COR attribute offset of Prism2 PC card */
+#define COR_VALUE     (COR_LEVEL_REQ | COR_FUNC_ENA)	/* Enable PC card with interrupt in level trigger */
+
+
+/* Nortel specific data */
+struct nortel_pci_card {
+	unsigned long iobase1;
+	unsigned long iobase2;
+};
+
+/*
+ * Do a soft reset of the PCI card using the Configuration Option Register
+ * We need this to get going...
+ * This is the part of the code that is strongly inspired from wlan-ng
+ *
+ * Note bis : Don't try to access HERMES_CMD during the reset phase.
+ * It just won't work !
+ */
+static int nortel_pci_cor_reset(struct orinoco_private *priv)
+{
+	struct nortel_pci_card *card = priv->card;
+
+	/* Assert the reset until the card notice */
+	outw_p(8, card->iobase1 + 2);
+	inw(card->iobase2 + COR_OFFSET);
+	outw_p(0x80, card->iobase2 + COR_OFFSET);
+	mdelay(1);
+
+	/* Give time for the card to recover from this hard effort */
+	outw_p(0, card->iobase2 + COR_OFFSET);
+	outw_p(0, card->iobase2 + COR_OFFSET);
+	mdelay(1);
+
+	/* set COR as usual */
+	outw_p(COR_VALUE, card->iobase2 + COR_OFFSET);
+	outw_p(COR_VALUE, card->iobase2 + COR_OFFSET);
+	mdelay(1);
+
+	outw_p(0x228, card->iobase1 + 2);
+
+	return 0;
+}
+
+int nortel_pci_hw_init(struct nortel_pci_card *card)
+{
+	int i;
+	u32 reg;
+
+	/* setup bridge */
+	if (inw(card->iobase1) & 1) {
+		printk(KERN_ERR PFX "brg1 answer1 wrong\n");
+		return -EBUSY;
+	}
+	outw_p(0x118, card->iobase1 + 2);
+	outw_p(0x108, card->iobase1 + 2);
+	mdelay(30);
+	outw_p(0x8, card->iobase1 + 2);
+	for (i = 0; i < 30; i++) {
+		mdelay(30);
+		if (inw(card->iobase1) & 0x10) {
+			break;
+		}
+	}
+	if (i == 30) {
+		printk(KERN_ERR PFX "brg1 timed out\n");
+		return -EBUSY;
+	}
+	if (inw(card->iobase2 + 0xe0) & 1) {
+		printk(KERN_ERR PFX "brg2 answer1 wrong\n");
+		return -EBUSY;
+	}
+	if (inw(card->iobase2 + 0xe2) & 1) {
+		printk(KERN_ERR PFX "brg2 answer2 wrong\n");
+		return -EBUSY;
+	}
+	if (inw(card->iobase2 + 0xe4) & 1) {
+		printk(KERN_ERR PFX "brg2 answer3 wrong\n");
+		return -EBUSY;
+	}
+
+	/* set the PCMCIA COR-Register */
+	outw_p(COR_VALUE, card->iobase2 + COR_OFFSET);
+	mdelay(1);
+	reg = inw(card->iobase2 + COR_OFFSET);
+	if (reg != COR_VALUE) {
+		printk(KERN_ERR PFX "Error setting COR value (reg=%x)\n",
+		       reg);
+		return -EBUSY;
+	}
+
+	/* set leds */
+	outw_p(1, card->iobase1 + 10);
+	return 0;
+}
+
+static int nortel_pci_init_one(struct pci_dev *pdev,
+			       const struct pci_device_id *ent)
+{
+	int err;
+	struct orinoco_private *priv;
+	struct nortel_pci_card *card;
+	struct net_device *dev;
+	void __iomem *iomem;
+
+	err = pci_enable_device(pdev);
+	if (err) {
+		printk(KERN_ERR PFX "Cannot enable PCI device\n");
+		return err;
+	}
+
+	err = pci_request_regions(pdev, DRIVER_NAME);
+	if (err != 0) {
+		printk(KERN_ERR PFX "Cannot obtain PCI resources\n");
+		goto fail_resources;
+	}
+
+	iomem = pci_iomap(pdev, 3, 0);
+	if (!iomem) {
+		err = -ENOMEM;
+		goto fail_map_io;
+	}
+
+	/* Allocate network device */
+	dev = alloc_orinocodev(sizeof(*card), nortel_pci_cor_reset);
+	if (!dev) {
+		printk(KERN_ERR PFX "Cannot allocate network device\n");
+		err = -ENOMEM;
+		goto fail_alloc;
+	}
+
+	priv = netdev_priv(dev);
+	card = priv->card;
+	card->iobase1 = pci_resource_start(pdev, 0);
+	card->iobase2 = pci_resource_start(pdev, 1);
+	dev->base_addr = pci_resource_start(pdev, 2);
+	SET_MODULE_OWNER(dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	hermes_struct_init(&priv->hw, iomem, HERMES_16BIT_REGSPACING);
+
+	printk(KERN_DEBUG PFX "Detected Nortel PCI device at %s irq:%d, "
+	       "io addr:0x%lx\n", pci_name(pdev), pdev->irq, dev->base_addr);
+
+	err = request_irq(pdev->irq, orinoco_interrupt, SA_SHIRQ,
+			  dev->name, dev);
+	if (err) {
+		printk(KERN_ERR PFX "Cannot allocate IRQ %d\n", pdev->irq);
+		err = -EBUSY;
+		goto fail_irq;
+	}
+	dev->irq = pdev->irq;
+
+	err = nortel_pci_hw_init(card);
+	if (err) {
+		printk(KERN_ERR PFX "Hardware initialization failed\n");
+		goto fail;
+	}
+
+	err = nortel_pci_cor_reset(priv);
+	if (err) {
+		printk(KERN_ERR PFX "Initial reset failed\n");
+		goto fail;
+	}
+
+
+	err = register_netdev(dev);
+	if (err) {
+		printk(KERN_ERR PFX "Cannot register network device\n");
+		goto fail;
+	}
+
+	pci_set_drvdata(pdev, dev);
+
+	return 0;
+
+ fail:
+	free_irq(pdev->irq, dev);
+
+ fail_irq:
+	pci_set_drvdata(pdev, NULL);
+	free_orinocodev(dev);
+
+ fail_alloc:
+	pci_iounmap(pdev, iomem);
+
+ fail_map_io:
+	pci_release_regions(pdev);
+
+ fail_resources:
+	pci_disable_device(pdev);
+
+	return err;
+}
+
+static void __devexit nortel_pci_remove_one(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct orinoco_private *priv = netdev_priv(dev);
+	struct nortel_pci_card *card = priv->card;
+
+	/* clear leds */
+	outw_p(0, card->iobase1 + 10);
+
+	unregister_netdev(dev);
+	free_irq(dev->irq, dev);
+	pci_set_drvdata(pdev, NULL);
+	free_orinocodev(dev);
+	pci_iounmap(pdev, priv->hw.iobase);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+}
+
+
+static struct pci_device_id nortel_pci_id_table[] = {
+	/* Nortel emobility PCI */
+	{0x126c, 0x8030, PCI_ANY_ID, PCI_ANY_ID,},
+	{0,},
+};
+
+MODULE_DEVICE_TABLE(pci, nortel_pci_id_table);
+
+static struct pci_driver nortel_pci_driver = {
+	.name = DRIVER_NAME,
+	.id_table = nortel_pci_id_table,
+	.probe = nortel_pci_init_one,
+	.remove = __devexit_p(nortel_pci_remove_one),
+};
+
+static char version[] __initdata = DRIVER_NAME " " DRIVER_VERSION
+	" (Tobias Hoffmann & Christoph Jungegger <disdos-Bv35esvkf38b1SvskN2V4Q@public.gmane.org>)";
+MODULE_AUTHOR("Christoph Jungegger <disdos-Bv35esvkf38b1SvskN2V4Q@public.gmane.org>");
+MODULE_DESCRIPTION
+    ("Driver for wireless LAN cards using the Nortel PCI bridge");
+MODULE_LICENSE("Dual MPL/GPL");
+
+static int __init nortel_pci_init(void)
+{
+	printk(KERN_DEBUG "%s\n", version);
+	return pci_module_init(&nortel_pci_driver);
+}
+
+static void __exit nortel_pci_exit(void)
+{
+	pci_unregister_driver(&nortel_pci_driver);
+	ssleep(1);
+}
+
+module_init(nortel_pci_init);
+module_exit(nortel_pci_exit);
+
+/*
+ * Local variables:
+ *  c-indent-level: 8
+ *  c-basic-offset: 8
+ *  tab-width: 8
+ * End:
+ */


-- 
Regards,
Pavel Roskin



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
