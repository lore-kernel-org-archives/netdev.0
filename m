From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH v3] dmfe/tulip: Let dmfe handle DM910x except for SPARC
 on-board chips
Date: Thu, 07 Jan 2010 12:41:51 +0000
Message-ID: <1262868111.2377.55.camel@localhost>
References: <1262660588.26813.24.camel@localhost>
	 <20100105165817.GA13015@lackof.org>
	 <20100107.005125.202622527.davem@davemloft.net>
	 <20100107.010651.18296756.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: grundler@parisc-linux.org, brandon@ifup.org, grundler@google.com,
	tobias@ringis.se, kyle@mcmartin.ca, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:44197 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752342Ab0AGMmQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 07:42:16 -0500
In-Reply-To: <20100107.010651.18296756.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Davicom DM9100 and DM9102 chips are used on the motherboards of
some SPARC systems (supported by the tulip driver) and also in PCI
expansion cards (supported by the dmfe driver).  There is no
difference in the PCI device ids for the two different configurations,
so these drivers both claim the device ids.  However, it is possible
to distinguish the two configurations by the presence of Open Firmware
properties for them, so we do that.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
On Thu, 2010-01-07 at 01:06 -0800, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 07 Jan 2010 00:51:25 -0800 (PST)
[...]
> > Applied, thanks everyone.
> 
> Sorry, had to revert, doesn't build:
[...]

When I asked for testing on SPARC, I intended that testers should
actually build both drivers!

Here's one more try.  I added conditional inclusion of <linux/of.h> in
dmfe.c.  It has to be conditional because that header doesn't compile on
architectures without OF support.  I also added parentheses to keep the
compiler happy.

Ben.

drivers/net/tulip/Kconfig      |    4 ++++
 drivers/net/tulip/dmfe.c       |   21 +++++++++++++++++++++
 drivers/net/tulip/tulip_core.c |   32 +++++++++++++++++++++++++-------
 3 files changed, 50 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tulip/Kconfig b/drivers/net/tulip/Kconfig
index 1cc8cf4..516713f 100644
--- a/drivers/net/tulip/Kconfig
+++ b/drivers/net/tulip/Kconfig
@@ -101,6 +101,10 @@ config TULIP_NAPI_HW_MITIGATION
 
 	  If in doubt, say Y.
 
+config TULIP_DM910X
+	def_bool y
+	depends on TULIP && SPARC
+
 config DE4X5
 	tristate "Generic DECchip & DIGITAL EtherWORKS PCI/EISA"
 	depends on PCI || EISA
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index ad63621..6f44ebf 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -92,6 +92,10 @@
 #include <asm/uaccess.h>
 #include <asm/irq.h>
 
+#ifdef CONFIG_TULIP_DM910X
+#include <linux/of.h>
+#endif
+
 
 /* Board/System/Debug information/definition ---------------- */
 #define PCI_DM9132_ID   0x91321282      /* Davicom DM9132 ID */
@@ -377,6 +381,23 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	if (!printed_version++)
 		printk(version);
 
+	/*
+	 *	SPARC on-board DM910x chips should be handled by the main
+	 *	tulip driver, except for early DM9100s.
+	 */
+#ifdef CONFIG_TULIP_DM910X
+	if ((ent->driver_data == PCI_DM9100_ID && pdev->revision >= 0x30) ||
+	    ent->driver_data == PCI_DM9102_ID) {
+		struct device_node *dp = pci_device_to_OF_node(pdev);
+
+		if (dp && of_get_property(dp, "local-mac-address", NULL)) {
+			printk(KERN_INFO DRV_NAME
+			       ": skipping on-board DM910x (use tulip)\n");
+			return -ENODEV;
+		}
+	}
+#endif
+
 	/* Init network device */
 	dev = alloc_etherdev(sizeof(*db));
 	if (dev == NULL)
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 0fa3140..595777d 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -196,9 +196,13 @@ struct tulip_chip_table tulip_tbl[] = {
 	| HAS_NWAY | HAS_PCI_MWI, tulip_timer, tulip_media_task },
 
   /* DM910X */
+#ifdef CONFIG_TULIP_DM910X
   { "Davicom DM9102/DM9102A", 128, 0x0001ebef,
 	HAS_MII | HAS_MEDIA_TABLE | CSR12_IN_SROM | HAS_ACPI,
 	tulip_timer, tulip_media_task },
+#else
+  { NULL },
+#endif
 
   /* RS7112 */
   { "Conexant LANfinity", 256, 0x0001ebef,
@@ -228,8 +232,10 @@ static struct pci_device_id tulip_pci_tbl[] = {
 	{ 0x1259, 0xa120, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
 	{ 0x11F6, 0x9881, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMPEX9881 },
 	{ 0x8086, 0x0039, PCI_ANY_ID, PCI_ANY_ID, 0, 0, I21145 },
+#ifdef CONFIG_TULIP_DM910X
 	{ 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
 	{ 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
+#endif
 	{ 0x1113, 0x1216, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
 	{ 0x1113, 0x1217, PCI_ANY_ID, PCI_ANY_ID, 0, 0, MX98715 },
 	{ 0x1113, 0x9511, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
@@ -1299,18 +1305,30 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 	}
 
 	/*
-	 *	Early DM9100's need software CRC and the DMFE driver
+	 *	DM910x chips should be handled by the dmfe driver, except
+	 *	on-board chips on SPARC systems.  Also, early DM9100s need
+	 *	software CRC which only the dmfe driver supports.
 	 */
 
-	if (pdev->vendor == 0x1282 && pdev->device == 0x9100)
-	{
-		/* Read Chip revision */
-		if (pdev->revision < 0x30)
-		{
-			printk(KERN_ERR PFX "skipping early DM9100 with Crc bug (use dmfe)\n");
+#ifdef CONFIG_TULIP_DM910X
+	if (chip_idx == DM910X) {
+		struct device_node *dp;
+
+		if (pdev->vendor == 0x1282 && pdev->device == 0x9100 &&
+		    pdev->revision < 0x30) {
+			printk(KERN_INFO PFX
+			       "skipping early DM9100 with Crc bug (use dmfe)\n");
+			return -ENODEV;
+		}
+
+		dp = pci_device_to_OF_node(pdev);
+		if (!(dp && of_get_property(dp, "local-mac-address", NULL))) {
+			printk(KERN_INFO PFX
+			       "skipping DM910x expansion card (use dmfe)\n");
 			return -ENODEV;
 		}
 	}
+#endif
 
 	/*
 	 *	Looks for early PCI chipsets where people report hangs
-- 
1.6.5.7


