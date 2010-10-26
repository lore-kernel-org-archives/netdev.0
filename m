From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH] OF device tree: Move of_get_mac_address() to a common source file.
Date: Tue, 26 Oct 2010 15:07:13 -0700
Message-ID: <1288130833-16421-1-git-send-email-ddaney@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>,
	Michal Simek <monstr@monstr.eu>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Corey Minyard <cminyard@mvista.com>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Anatolij Gustschin <agust@denx.de>,
	John Rigby <jcrigby@gmail.com>, Wolfgang Denk <wd@denx.de>,
	Anton Vorontsov <avorontsov@mvista.com>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	Li Yang <leoli@freescale.com>,
	Sergey Matyukevich <geomatsi@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sean MacLennan <smaclennan@pikatech.com>,
	Sadanand Mutyala <Sadanand.Mutyala@xilinx.com>,
	Andres Salomon <dilinger@queued.net>,
	microblaze-ucli
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
	devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:3986 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760539Ab0JZWHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 18:07:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two identical implementations of of_get_mac_address(), one
each in arch/powerpc/kernel/prom_parse.c and
arch/microblaze/kernel/prom_parse.c.  Move this function to a new
common file of_net.{c,h} and adjust all the callers to include the new
header.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
Cc: Michal Simek <monstr@monstr.eu>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Wolfram Sang <w.sang@pengutronix.de>
Cc: Paul Mackerras <paulus@samba.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Corey Minyard <cminyard@mvista.com>
Cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>
Cc: Vitaly Bordug <vbordug@ru.mvista.com>
Cc: Anatolij Gustschin <agust@denx.de>
Cc: John Rigby <jcrigby@gmail.com>
Cc: Wolfgang Denk <wd@denx.de>
Cc: Anton Vorontsov <avorontsov@mvista.com>
Cc: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Cc: Kumar Gala <galak@kernel.crashing.org>
Cc: Li Yang <leoli@freescale.com>
Cc: Sergey Matyukevich <geomatsi@gmail.com>
Cc: Jiri Pirko <jpirko@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Sean MacLennan <smaclennan@pikatech.com>
Cc: Sadanand Mutyala <Sadanand.Mutyala@xilinx.com>
Cc: Andres Salomon <dilinger@queued.net>
Cc: microblaze-uclinux@itee.uq.edu.au
Cc: linux-kernel@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: netdev@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
---

Note: This seems to work for my MIPS/Octeon development, but has been
tested neither on powerpc nor microblaze targets.

 arch/microblaze/include/asm/prom.h  |    3 --
 arch/microblaze/kernel/prom_parse.c |   38 ---------------------------
 arch/powerpc/include/asm/prom.h     |    3 --
 arch/powerpc/kernel/prom_parse.c    |   38 ---------------------------
 arch/powerpc/sysdev/mv64x60_dev.c   |    1 +
 arch/powerpc/sysdev/tsi108_dev.c    |    1 +
 drivers/net/fs_enet/fs_enet-main.c  |    1 +
 drivers/net/gianfar.c               |    1 +
 drivers/net/ucc_geth.c              |    1 +
 drivers/net/xilinx_emaclite.c       |    1 +
 drivers/of/Kconfig                  |    3 ++
 drivers/of/Makefile                 |    1 +
 drivers/of/of_net.c                 |   48 +++++++++++++++++++++++++++++++++++
 include/linux/of_net.h              |   13 +++++++++
 14 files changed, 71 insertions(+), 82 deletions(-)
 create mode 100644 drivers/of/of_net.c
 create mode 100644 include/linux/of_net.h

diff --git a/arch/microblaze/include/asm/prom.h b/arch/microblaze/include/asm/prom.h
index 101fa09..392b3ad 100644
--- a/arch/microblaze/include/asm/prom.h
+++ b/arch/microblaze/include/asm/prom.h
@@ -63,9 +63,6 @@ extern void kdump_move_device_tree(void);
 /* CPU OF node matching */
 struct device_node *of_get_cpu_node(int cpu, unsigned int *thread);
 
-/* Get the MAC address */
-extern const void *of_get_mac_address(struct device_node *np);
-
 /**
  * of_irq_map_pci - Resolve the interrupt for a PCI device
  * @pdev:	the device whose interrupt is to be resolved
diff --git a/arch/microblaze/kernel/prom_parse.c b/arch/microblaze/kernel/prom_parse.c
index 99d9b61..9ae24f4 100644
--- a/arch/microblaze/kernel/prom_parse.c
+++ b/arch/microblaze/kernel/prom_parse.c
@@ -110,41 +110,3 @@ void of_parse_dma_window(struct device_node *dn, const void *dma_window_prop,
 	cells = prop ? *(u32 *)prop : of_n_size_cells(dn);
 	*size = of_read_number(dma_window, cells);
 }
-
-/**
- * Search the device tree for the best MAC address to use.  'mac-address' is
- * checked first, because that is supposed to contain to "most recent" MAC
- * address. If that isn't set, then 'local-mac-address' is checked next,
- * because that is the default address.  If that isn't set, then the obsolete
- * 'address' is checked, just in case we're using an old device tree.
- *
- * Note that the 'address' property is supposed to contain a virtual address of
- * the register set, but some DTS files have redefined that property to be the
- * MAC address.
- *
- * All-zero MAC addresses are rejected, because those could be properties that
- * exist in the device tree, but were not set by U-Boot.  For example, the
- * DTS could define 'mac-address' and 'local-mac-address', with zero MAC
- * addresses.  Some older U-Boots only initialized 'local-mac-address'.  In
- * this case, the real MAC is in 'local-mac-address', and 'mac-address' exists
- * but is all zeros.
-*/
-const void *of_get_mac_address(struct device_node *np)
-{
-	struct property *pp;
-
-	pp = of_find_property(np, "mac-address", NULL);
-	if (pp && (pp->length == 6) && is_valid_ether_addr(pp->value))
-		return pp->value;
-
-	pp = of_find_property(np, "local-mac-address", NULL);
-	if (pp && (pp->length == 6) && is_valid_ether_addr(pp->value))
-		return pp->value;
-
-	pp = of_find_property(np, "address", NULL);
-	if (pp && (pp->length == 6) && is_valid_ether_addr(pp->value))
-		return pp->value;
-
-	return NULL;
-}
-EXPORT_SYMBOL(of_get_mac_address);
diff --git a/arch/powerpc/include/asm/prom.h b/arch/powerpc/include/asm/prom.h
index ae26f2e..98264bf 100644
--- a/arch/powerpc/include/asm/prom.h
+++ b/arch/powerpc/include/asm/prom.h
@@ -63,9 +63,6 @@ struct device_node *of_get_cpu_node(int cpu, unsigned int *thread);
 /* cache lookup */
 struct device_node *of_find_next_cache_node(struct device_node *np);
 
-/* Get the MAC address */
-extern const void *of_get_mac_address(struct device_node *np);
-
 #ifdef CONFIG_NUMA
 extern int of_node_to_nid(struct device_node *device);
 #else
diff --git a/arch/powerpc/kernel/prom_parse.c b/arch/powerpc/kernel/prom_parse.c
index 88334af..c2b7a07 100644
--- a/arch/powerpc/kernel/prom_parse.c
+++ b/arch/powerpc/kernel/prom_parse.c
@@ -117,41 +117,3 @@ void of_parse_dma_window(struct device_node *dn, const void *dma_window_prop,
 	cells = prop ? *(u32 *)prop : of_n_size_cells(dn);
 	*size = of_read_number(dma_window, cells);
 }
-
-/**
- * Search the device tree for the best MAC address to use.  'mac-address' is
- * checked first, because that is supposed to contain to "most recent" MAC
- * address. If that isn't set, then 'local-mac-address' is checked next,
- * because that is the default address.  If that isn't set, then the obsolete
- * 'address' is checked, just in case we're using an old device tree.
- *
- * Note that the 'address' property is supposed to contain a virtual address of
- * the register set, but some DTS files have redefined that property to be the
- * MAC address.
- *
- * All-zero MAC addresses are rejected, because those could be properties that
- * exist in the device tree, but were not set by U-Boot.  For example, the
- * DTS could define 'mac-address' and 'local-mac-address', with zero MAC
- * addresses.  Some older U-Boots only initialized 'local-mac-address'.  In
- * this case, the real MAC is in 'local-mac-address', and 'mac-address' exists
- * but is all zeros.
-*/
-const void *of_get_mac_address(struct device_node *np)
-{
-	struct property *pp;
-
-	pp = of_find_property(np, "mac-address", NULL);
-	if (pp && (pp->length == 6) && is_valid_ether_addr(pp->value))
-		return pp->value;
-
-	pp = of_find_property(np, "local-mac-address", NULL);
-	if (pp && (pp->length == 6) && is_valid_ether_addr(pp->value))
-		return pp->value;
-
-	pp = of_find_property(np, "address", NULL);
-	if (pp && (pp->length == 6) && is_valid_ether_addr(pp->value))
-		return pp->value;
-
-	return NULL;
-}
-EXPORT_SYMBOL(of_get_mac_address);
diff --git a/arch/powerpc/sysdev/mv64x60_dev.c b/arch/powerpc/sysdev/mv64x60_dev.c
index 1398bc4..feaee40 100644
--- a/arch/powerpc/sysdev/mv64x60_dev.c
+++ b/arch/powerpc/sysdev/mv64x60_dev.c
@@ -16,6 +16,7 @@
 #include <linux/mv643xx.h>
 #include <linux/platform_device.h>
 #include <linux/of_platform.h>
+#include <linux/of_net.h>
 #include <linux/dma-mapping.h>
 
 #include <asm/prom.h>
diff --git a/arch/powerpc/sysdev/tsi108_dev.c b/arch/powerpc/sysdev/tsi108_dev.c
index d4d15aa..c2d675b 100644
--- a/arch/powerpc/sysdev/tsi108_dev.c
+++ b/arch/powerpc/sysdev/tsi108_dev.c
@@ -19,6 +19,7 @@
 #include <linux/module.h>
 #include <linux/device.h>
 #include <linux/platform_device.h>
+#include <linux/of_net.h>
 #include <asm/tsi108.h>
 
 #include <asm/system.h>
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index d6e3111..acba64b 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -40,6 +40,7 @@
 #include <linux/of_mdio.h>
 #include <linux/of_platform.h>
 #include <linux/of_gpio.h>
+#include <linux/of_net.h>
 
 #include <linux/vmalloc.h>
 #include <asm/pgtable.h>
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 4f7c3f3..773909b 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -95,6 +95,7 @@
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
 #include <linux/of.h>
+#include <linux/of_net.h>
 
 #include "gianfar.h"
 #include "fsl_pq_mdio.h"
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index a4c3f57..f7e370f 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -28,6 +28,7 @@
 #include <linux/phy.h>
 #include <linux/workqueue.h>
 #include <linux/of_mdio.h>
+#include <linux/of_net.h>
 #include <linux/of_platform.h>
 
 #include <asm/uaccess.h>
diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index ecbbb68..527e1ea 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -24,6 +24,7 @@
 #include <linux/of_device.h>
 #include <linux/of_platform.h>
 #include <linux/of_mdio.h>
+#include <linux/of_net.h>
 #include <linux/phy.h>
 
 #define DRIVER_NAME "xilinx_emaclite"
diff --git a/drivers/of/Kconfig b/drivers/of/Kconfig
index aa675eb..8184778 100644
--- a/drivers/of/Kconfig
+++ b/drivers/of/Kconfig
@@ -61,4 +61,7 @@ config OF_MDIO
 	help
 	  OpenFirmware MDIO bus (Ethernet PHY) accessors
 
+config OF_NET
+	def_bool y
+
 endmenu # OF
diff --git a/drivers/of/Makefile b/drivers/of/Makefile
index 7888155..6854ced 100644
--- a/drivers/of/Makefile
+++ b/drivers/of/Makefile
@@ -8,3 +8,4 @@ obj-$(CONFIG_OF_GPIO)   += gpio.o
 obj-$(CONFIG_OF_I2C)	+= of_i2c.o
 obj-$(CONFIG_OF_SPI)	+= of_spi.o
 obj-$(CONFIG_OF_MDIO)	+= of_mdio.o
+obj-$(CONFIG_OF_NET)	+= of_net.o
diff --git a/drivers/of/of_net.c b/drivers/of/of_net.c
new file mode 100644
index 0000000..86f334a
--- /dev/null
+++ b/drivers/of/of_net.c
@@ -0,0 +1,48 @@
+/*
+ * OF helpers for network devices.
+ *
+ * This file is released under the GPLv2
+ *
+ * Initially copied out of arch/powerpc/kernel/prom_parse.c
+ */
+#include <linux/etherdevice.h>
+#include <linux/kernel.h>
+#include <linux/of_net.h>
+
+/**
+ * Search the device tree for the best MAC address to use.  'mac-address' is
+ * checked first, because that is supposed to contain to "most recent" MAC
+ * address. If that isn't set, then 'local-mac-address' is checked next,
+ * because that is the default address.  If that isn't set, then the obsolete
+ * 'address' is checked, just in case we're using an old device tree.
+ *
+ * Note that the 'address' property is supposed to contain a virtual address of
+ * the register set, but some DTS files have redefined that property to be the
+ * MAC address.
+ *
+ * All-zero MAC addresses are rejected, because those could be properties that
+ * exist in the device tree, but were not set by U-Boot.  For example, the
+ * DTS could define 'mac-address' and 'local-mac-address', with zero MAC
+ * addresses.  Some older U-Boots only initialized 'local-mac-address'.  In
+ * this case, the real MAC is in 'local-mac-address', and 'mac-address' exists
+ * but is all zeros.
+*/
+const void *of_get_mac_address(struct device_node *np)
+{
+	struct property *pp;
+
+	pp = of_find_property(np, "mac-address", NULL);
+	if (pp && (pp->length == 6) && is_valid_ether_addr(pp->value))
+		return pp->value;
+
+	pp = of_find_property(np, "local-mac-address", NULL);
+	if (pp && (pp->length == 6) && is_valid_ether_addr(pp->value))
+		return pp->value;
+
+	pp = of_find_property(np, "address", NULL);
+	if (pp && (pp->length == 6) && is_valid_ether_addr(pp->value))
+		return pp->value;
+
+	return NULL;
+}
+EXPORT_SYMBOL(of_get_mac_address);
diff --git a/include/linux/of_net.h b/include/linux/of_net.h
new file mode 100644
index 0000000..7c773ec
--- /dev/null
+++ b/include/linux/of_net.h
@@ -0,0 +1,13 @@
+/*
+ * OF helpers for network devices.
+ *
+ * This file is released under the GPLv2
+ */
+
+#ifndef __LINUX_OF_NET_H
+#define __LINUX_OF_NET_H
+
+#include <linux/of.h>
+const void *of_get_mac_address(struct device_node *np);
+
+#endif /* __LINUX_OF_NET_H */
-- 
1.7.2.3

