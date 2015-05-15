From: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
Subject: [V4 PATCH 3/6] pci: Generic function for setting up PCI device DMA coherency
Date: Fri, 15 May 2015 16:23:11 -0500
Message-ID: <1431724994-21601-4-git-send-email-Suravee.Suthikulpanit@amd.com>
References: <1431724994-21601-1-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <msalter@redhat.com>, <hanjun.guo@linaro.org>,
	<al.stone@linaro.org>, <grant.likely@linaro.org>,
	<leo.duran@amd.com>, <linux-arm-kernel@lists.infradead.org>,
	<linux-acpi@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linaro-acpi@lists.linaro.org>, <netdev@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>,
	"Suravee Suthikulpanit" <Suravee.Suthikulpanit@amd.com>,
	Rob Herring <robh+dt@kernel.org>,
	Murali Karicheri <m-karicheri2@ti.com>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <bhelgaas@google.com>,
	<thomas.lendacky@amd.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>, <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431724994-21601-1-git-send-email-Suravee.Suthikulpanit@amd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch refactors of_pci_dma_configure() into a more generic
pci_dma_configure(), which can be reused by non-OF code.
Then, it adds support for setting up PCI device DMA coherency from
ACPI _CCA object that should normally be specified in the DSDT node
of its PCI host bridge..

Signed-off-by: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
CC: Bjorn Helgaas <bhelgaas@google.com>
CC: Catalin Marinas <catalin.marinas@arm.com>
CC: Rob Herring <robh+dt@kernel.org>
CC: Will Deacon <will.deacon@arm.com>
CC: Rafael J. Wysocki <rjw@rjwysocki.net>
CC: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/of/of_pci.c    | 20 --------------------
 drivers/pci/probe.c    | 35 +++++++++++++++++++++++++++++++++--
 include/linux/of_pci.h |  3 ---
 3 files changed, 33 insertions(+), 25 deletions(-)

diff --git a/drivers/of/of_pci.c b/drivers/of/of_pci.c
index 5751dc5..b66ee4e 100644
--- a/drivers/of/of_pci.c
+++ b/drivers/of/of_pci.c
@@ -117,26 +117,6 @@ int of_get_pci_domain_nr(struct device_node *node)
 }
 EXPORT_SYMBOL_GPL(of_get_pci_domain_nr);
 
-/**
- * of_pci_dma_configure - Setup DMA configuration
- * @dev: ptr to pci_dev struct of the PCI device
- *
- * Function to update PCI devices's DMA configuration using the same
- * info from the OF node of host bridge's parent (if any).
- */
-void of_pci_dma_configure(struct pci_dev *pci_dev)
-{
-	struct device *dev = &pci_dev->dev;
-	struct device *bridge = pci_get_host_bridge_device(pci_dev);
-
-	if (!bridge->parent)
-		return;
-
-	of_dma_configure(dev, bridge->parent->of_node);
-	pci_put_host_bridge_device(bridge);
-}
-EXPORT_SYMBOL_GPL(of_pci_dma_configure);
-
 #if defined(CONFIG_OF_ADDRESS)
 /**
  * of_pci_get_host_bridge_resources - Parse PCI host bridge resources from DT
diff --git a/drivers/pci/probe.c b/drivers/pci/probe.c
index 6675a7a..3c6f2e5 100644
--- a/drivers/pci/probe.c
+++ b/drivers/pci/probe.c
@@ -6,12 +6,14 @@
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/pci.h>
-#include <linux/of_pci.h>
+#include <linux/of_device.h>
 #include <linux/pci_hotplug.h>
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/cpumask.h>
 #include <linux/pci-aspm.h>
+#include <linux/acpi.h>
+#include <linux/property.h>
 #include <asm-generic/pci-bridge.h>
 #include "pci.h"
 
@@ -1508,6 +1510,35 @@ static void pci_init_capabilities(struct pci_dev *dev)
 	pci_enable_acs(dev);
 }
 
+/**
+ * pci_dma_configure - Setup DMA configuration
+ * @pci_dev: ptr to pci_dev struct of the PCI device
+ *
+ * Function to update PCI devices's DMA configuration using the same
+ * info from the OF node or ACPI node of host bridge's parent (if any).
+ */
+static void pci_dma_configure(struct pci_dev *pci_dev)
+{
+	struct device *dev = &pci_dev->dev;
+	struct device *bridge = pci_get_host_bridge_device(pci_dev);
+	struct device *host = bridge->parent;
+	struct acpi_device *adev;
+
+	if (!host)
+		return;
+
+	if (acpi_disabled) {
+		of_dma_configure(dev, host->of_node);
+	} else if (has_acpi_companion(host)) {
+		adev = acpi_node(host->fwnode);
+		if (acpi_dma_is_supported(adev))
+			arch_setup_dma_ops(dev, 0, 0, NULL,
+					   acpi_dma_is_coherent(adev));
+	}
+
+	pci_put_host_bridge_device(bridge);
+}
+
 void pci_device_add(struct pci_dev *dev, struct pci_bus *bus)
 {
 	int ret;
@@ -1521,7 +1552,7 @@ void pci_device_add(struct pci_dev *dev, struct pci_bus *bus)
 	dev->dev.dma_mask = &dev->dma_mask;
 	dev->dev.dma_parms = &dev->dma_parms;
 	dev->dev.coherent_dma_mask = 0xffffffffull;
-	of_pci_dma_configure(dev);
+	pci_dma_configure(dev);
 
 	pci_set_dma_max_seg_size(dev, 65536);
 	pci_set_dma_seg_boundary(dev, 0xffffffff);
diff --git a/include/linux/of_pci.h b/include/linux/of_pci.h
index 29fd3fe..ce0e5ab 100644
--- a/include/linux/of_pci.h
+++ b/include/linux/of_pci.h
@@ -16,7 +16,6 @@ int of_pci_get_devfn(struct device_node *np);
 int of_irq_parse_and_map_pci(const struct pci_dev *dev, u8 slot, u8 pin);
 int of_pci_parse_bus_range(struct device_node *node, struct resource *res);
 int of_get_pci_domain_nr(struct device_node *node);
-void of_pci_dma_configure(struct pci_dev *pci_dev);
 #else
 static inline int of_irq_parse_pci(const struct pci_dev *pdev, struct of_phandle_args *out_irq)
 {
@@ -51,8 +50,6 @@ of_get_pci_domain_nr(struct device_node *node)
 {
 	return -1;
 }
-
-static inline void of_pci_dma_configure(struct pci_dev *pci_dev) { }
 #endif
 
 #if defined(CONFIG_OF_ADDRESS)
-- 
2.1.0
