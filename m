From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 15/26] et131x: fold the diet config into the other code
Date: Tue, 25 Aug 2009 15:59:59 +0100
Message-ID: <20090825145953.16176.60453.stgit@localhost.localdomain>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:47799 "EHLO
	bob.linux.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755351AbZHYPFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 11:05:20 -0400
In-Reply-To: <20090825145619.16176.68780.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No point having a file just for that

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/staging/et131x/Makefile         |    1=20
 drivers/staging/et131x/et131x_config.c  |  183 -----------------------=
--------
 drivers/staging/et131x/et131x_initpci.c |   86 +++++++++++++++
 3 files changed, 86 insertions(+), 184 deletions(-)


diff --git a/drivers/staging/et131x/Makefile b/drivers/staging/et131x/M=
akefile
index 3ad571d..3ddbc64 100644
--- a/drivers/staging/et131x/Makefile
+++ b/drivers/staging/et131x/Makefile
@@ -11,7 +11,6 @@ et131x-objs :=3D	et1310_eeprom.o \
 		et1310_pm.o \
 		et1310_rx.o \
 		et1310_tx.o \
-		et131x_config.o \
 		et131x_debug.o \
 		et131x_initpci.o \
 		et131x_isr.o \
diff --git a/drivers/staging/et131x/et131x_config.c b/drivers/staging/e=
t131x/et131x_config.c
index cde727d..e69de29 100644
--- a/drivers/staging/et131x/et131x_config.c
+++ b/drivers/staging/et131x/et131x_config.c
@@ -1,183 +0,0 @@
-/*
- * Agere Systems Inc.
- * 10/100/1000 Base-T Ethernet Driver for the ET1301 and ET131x series=
 MACs
- *
- * Copyright =C2=A9 2005 Agere Systems Inc.
- * All rights reserved.
- *   http://www.agere.com
- *
- *--------------------------------------------------------------------=
----------
- *
- * et131x_config.c - Handles parsing of configuration data during
- *                   initialization.
- *
- *--------------------------------------------------------------------=
----------
- *
- * SOFTWARE LICENSE
- *
- * This software is provided subject to the following terms and condit=
ions,
- * which you should read carefully before using the software.  Using t=
his
- * software indicates your acceptance of these terms and conditions.  =
If you do
- * not agree with these terms and conditions, do not use the software.
- *
- * Copyright =C2=A9 2005 Agere Systems Inc.
- * All rights reserved.
- *
- * Redistribution and use in source or binary forms, with or without
- * modifications, are permitted provided that the following conditions=
 are met:
- *
- * . Redistributions of source code must retain the above copyright no=
tice, this
- *    list of conditions and the following Disclaimer as comments in t=
he code as
- *    well as in the documentation and/or other materials provided wit=
h the
- *    distribution.
- *
- * . Redistributions in binary form must reproduce the above copyright=
 notice,
- *    this list of conditions and the following Disclaimer in the docu=
mentation
- *    and/or other materials provided with the distribution.
- *
- * . Neither the name of Agere Systems Inc. nor the names of the contr=
ibutors
- *    may be used to endorse or promote products derived from this sof=
tware
- *    without specific prior written permission.
- *
- * Disclaimer
- *
- * THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRAN=
TIES,
- * INCLUDING, BUT NOT LIMITED TO, INFRINGEMENT AND THE IMPLIED WARRANT=
IES OF
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED=
=2E  ANY
- * USE, MODIFICATION OR DISTRIBUTION OF THIS SOFTWARE IS SOLELY AT THE=
 USERS OWN
- * RISK. IN NO EVENT SHALL AGERE SYSTEMS INC. OR CONTRIBUTORS BE LIABL=
E FOR ANY
- * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL =
DAMAGES
- * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR =
SERVICES;
- * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CA=
USED AND
- * ON ANY THEORY OF LIABILITY, INCLUDING, BUT NOT LIMITED TO, CONTRACT=
, STRICT
- * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN A=
NY WAY OUT
- * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF =
SUCH
- * DAMAGE.
- *
- */
-
-#include "et131x_version.h"
-#include "et131x_debug.h"
-#include "et131x_defs.h"
-
-#include <linux/init.h>
-#include <linux/module.h>
-#include <linux/types.h>
-#include <linux/kernel.h>
-
-#include <linux/sched.h>
-#include <linux/ptrace.h>
-#include <linux/slab.h>
-#include <linux/ctype.h>
-#include <linux/string.h>
-#include <linux/timer.h>
-#include <linux/interrupt.h>
-#include <linux/in.h>
-#include <linux/delay.h>
-#include <linux/io.h>
-#include <linux/bitops.h>
-#include <linux/pci.h>
-#include <asm/system.h>
-
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/skbuff.h>
-#include <linux/if_arp.h>
-#include <linux/ioport.h>
-
-#include "et1310_phy.h"
-#include "et1310_pm.h"
-#include "et1310_jagcore.h"
-
-#include "et131x_adapter.h"
-#include "et131x_initpci.h"
-#include "et131x_config.h"
-
-#include "et1310_tx.h"
-
-/* Data for debugging facilities */
-#ifdef CONFIG_ET131X_DEBUG
-extern dbg_info_t *et131x_dbginfo;
-#endif /* CONFIG_ET131X_DEBUG */
-
-/* Defines for Parameter Default/Min/Max vaules */
-#define PARM_SPEED_DUPLEX_MIN   0
-#define PARM_SPEED_DUPLEX_MAX   5
-
-/* Module parameter for disabling NMI
- * et131x_nmi_disable :
- * Disable NMI (0-2) [0]
- *  0 :
- *  1 :
- *  2 :
- */
-static u32 et131x_nmi_disable;	/* 0-2 */
-module_param(et131x_nmi_disable, uint, 0);
-MODULE_PARM_DESC(et131x_nmi_disable, "Disable NMI (0-2) [0]");
-
-/* Module parameter for manual speed setting
- * Set Link speed and dublex manually (0-5)  [0]
- *  1 : 10Mb   Half-Duplex
- *  2 : 10Mb   Full-Duplex
- *  3 : 100Mb  Half-Duplex
- *  4 : 100Mb  Full-Duplex
- *  5 : 1000Mb Full-Duplex
- *  0 : Auto Speed Auto Duplex // default
- */
-static u32 et131x_speed_set;
-module_param(et131x_speed_set, uint, 0);
-MODULE_PARM_DESC(et131x_speed_set,
-		"Set Link speed and dublex manually (0-5)  [0] \n  1 : 10Mb   Half-D=
uplex \n  2 : 10Mb   Full-Duplex \n  3 : 100Mb  Half-Duplex \n  4 : 100=
Mb  Full-Duplex \n  5 : 1000Mb Full-Duplex \n 0 : Auto Speed Auto Duble=
x");
-
-/**
- * et131x_config_parse
- * @etdev: pointer to the private adapter struct
- *
- * Parses a configuration from some location (module parameters, for e=
xample)
- * into the private adapter struct. This really has no sensible analog=
y in
- * Linux as sysfs parameters are dynamic. Several things that were hee=
 could
- * go into sysfs, but other stuff like speed handling is part of the m=
ii
- * interfaces/ethtool.
- */
-void et131x_config_parse(struct et131x_adapter *etdev)
-{
-	static const u8 default_mac[] =3D { 0x00, 0x05, 0x3d, 0x00, 0x02, 0x0=
0 };
-	static const u8 duplex[] =3D { 0, 1, 2, 1, 2, 2 };
-	static const u16 speed[] =3D { 0, 10, 10, 100, 100, 1000 };
-
-	DBG_ENTER(et131x_dbginfo);
-
-	if (et131x_speed_set < PARM_SPEED_DUPLEX_MIN ||
-	    et131x_speed_set > PARM_SPEED_DUPLEX_MAX) {
-	    	dev_warn(&etdev->pdev->dev, "invalid speed setting ignored.\n");
-	    	et131x_speed_set =3D 0;
-	}
-	else if (et131x_speed_set)
-		DBG_VERBOSE(et131x_dbginfo, "Speed set manually to : %d \n",
-			    et131x_speed_set);
-
-	etdev->SpeedDuplex =3D et131x_speed_set;
-	etdev->RegistryJumboPacket =3D 1514;	/* 1514-9216 */
-
-	etdev->RegistryNMIDisable =3D et131x_nmi_disable;
-
-	/* Set the MAC address to a default */
-	memcpy(etdev->CurrentAddress, default_mac, ETH_ALEN);
-
-	/* Decode SpeedDuplex
-	 *
-	 * Set up as if we are auto negotiating always and then change if we
-	 * go into force mode
-	 *
-	 * If we are the 10/100 device, and gigabit is somehow requested then
-	 * knock it down to 100 full.
-	 */
-	if (etdev->pdev->device =3D=3D ET131X_PCI_DEVICE_ID_FAST &&
-	    etdev->SpeedDuplex =3D=3D 5)
-		etdev->SpeedDuplex =3D 4;
-
-	etdev->AiForceSpeed =3D speed[etdev->SpeedDuplex];
-	etdev->AiForceDpx =3D duplex[etdev->SpeedDuplex];	/* Auto FDX */
-
-	DBG_LEAVE(et131x_dbginfo);
-}
diff --git a/drivers/staging/et131x/et131x_initpci.c b/drivers/staging/=
et131x/et131x_initpci.c
index c489090..34737d1 100644
--- a/drivers/staging/et131x/et131x_initpci.c
+++ b/drivers/staging/et131x/et131x_initpci.c
@@ -140,6 +140,37 @@ static dbg_info_t et131x_info =3D { DRIVER_NAME_EX=
T, 0, 0 };
 dbg_info_t *et131x_dbginfo =3D &et131x_info;
 #endif /* CONFIG_ET131X_DEBUG */
=20
+/* Defines for Parameter Default/Min/Max vaules */
+#define PARM_SPEED_DUPLEX_MIN   0
+#define PARM_SPEED_DUPLEX_MAX   5
+
+/* Module parameter for disabling NMI
+ * et131x_nmi_disable :
+ * Disable NMI (0-2) [0]
+ *  0 :
+ *  1 :
+ *  2 :
+ */
+static u32 et131x_nmi_disable;	/* 0-2 */
+module_param(et131x_nmi_disable, uint, 0);
+MODULE_PARM_DESC(et131x_nmi_disable, "Disable NMI (0-2) [0]");
+
+/* Module parameter for manual speed setting
+ * Set Link speed and dublex manually (0-5)  [0]
+ *  1 : 10Mb   Half-Duplex
+ *  2 : 10Mb   Full-Duplex
+ *  3 : 100Mb  Half-Duplex
+ *  4 : 100Mb  Full-Duplex
+ *  5 : 1000Mb Full-Duplex
+ *  0 : Auto Speed Auto Duplex // default
+ */
+static u32 et131x_speed_set;
+module_param(et131x_speed_set, uint, 0);
+MODULE_PARM_DESC(et131x_speed_set,
+		"Set Link speed and dublex manually (0-5)  [0] \n  1 : 10Mb   Half-D=
uplex \n  2 : 10Mb   Full-Duplex \n  3 : 100Mb  Half-Duplex \n  4 : 100=
Mb  Full-Duplex \n  5 : 1000Mb Full-Duplex \n 0 : Auto Speed Auto Duble=
x");
+
+
+
 static struct pci_device_id et131x_pci_table[] __devinitdata =3D {
 	{ET131X_PCI_VENDOR_ID, ET131X_PCI_DEVICE_ID_GIG, PCI_ANY_ID,
 	 PCI_ANY_ID, 0, 0, 0UL},
@@ -202,6 +233,12 @@ int et131x_init_module(void)
 	DBG_ENTER(et131x_dbginfo);
 	DBG_PRINT("%s\n", DRIVER_INFO);
=20
+	if (et131x_speed_set < PARM_SPEED_DUPLEX_MIN ||
+	    et131x_speed_set > PARM_SPEED_DUPLEX_MAX) {
+	    	printk(KERN_WARNING "et131x: invalid speed setting ignored.\n");
+	    	et131x_speed_set =3D 0;
+	}
+
 	result =3D pci_register_driver(&et131x_driver);
=20
 	DBG_LEAVE(et131x_dbginfo);
@@ -750,6 +787,55 @@ void __devexit et131x_pci_remove(struct pci_dev *p=
dev)
 }
=20
 /**
+ * et131x_config_parse
+ * @etdev: pointer to the private adapter struct
+ *
+ * Parses a configuration from some location (module parameters, for e=
xample)
+ * into the private adapter struct. This really has no sensible analog=
y in
+ * Linux as sysfs parameters are dynamic. Several things that were hee=
 could
+ * go into sysfs, but other stuff like speed handling is part of the m=
ii
+ * interfaces/ethtool.
+ */
+void et131x_config_parse(struct et131x_adapter *etdev)
+{
+	static const u8 default_mac[] =3D { 0x00, 0x05, 0x3d, 0x00, 0x02, 0x0=
0 };
+	static const u8 duplex[] =3D { 0, 1, 2, 1, 2, 2 };
+	static const u16 speed[] =3D { 0, 10, 10, 100, 100, 1000 };
+
+	DBG_ENTER(et131x_dbginfo);
+
+	if (et131x_speed_set)
+		DBG_VERBOSE(et131x_dbginfo, "Speed set manually to : %d \n",
+			    et131x_speed_set);
+
+	etdev->SpeedDuplex =3D et131x_speed_set;
+	etdev->RegistryJumboPacket =3D 1514;	/* 1514-9216 */
+
+	etdev->RegistryNMIDisable =3D et131x_nmi_disable;
+
+	/* Set the MAC address to a default */
+	memcpy(etdev->CurrentAddress, default_mac, ETH_ALEN);
+
+	/* Decode SpeedDuplex
+	 *
+	 * Set up as if we are auto negotiating always and then change if we
+	 * go into force mode
+	 *
+	 * If we are the 10/100 device, and gigabit is somehow requested then
+	 * knock it down to 100 full.
+	 */
+	if (etdev->pdev->device =3D=3D ET131X_PCI_DEVICE_ID_FAST &&
+	    etdev->SpeedDuplex =3D=3D 5)
+		etdev->SpeedDuplex =3D 4;
+
+	etdev->AiForceSpeed =3D speed[etdev->SpeedDuplex];
+	etdev->AiForceDpx =3D duplex[etdev->SpeedDuplex];	/* Auto FDX */
+
+	DBG_LEAVE(et131x_dbginfo);
+}
+
+
+/**
  * et131x_pci_setup - Perform device initialization
  * @pdev: a pointer to the device's pci_dev structure
  * @ent: this device's entry in the pci_device_id table

