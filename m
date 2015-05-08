From: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
Subject: [V3 PATCH 1/5] ACPI / scan: Parse _CCA and setup device coherency
Date: Thu, 7 May 2015 19:37:12 -0500
Message-ID: <1431045436-8690-2-git-send-email-Suravee.Suthikulpanit@amd.com>
References: <1431045436-8690-1-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: al.stone@linaro.org, linaro-acpi@lists.linaro.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, leo.duran@amd.com,
 hanjun.guo@linaro.org, Suravee
 Suthikulpanit <Suravee.Suthikulpanit@amd.com>, msalter@redhat.com,
 grant.likely@linaro.org, linux-arm-kernel@lists.infradead.org,
 linux-crypto@vger.kernel.org
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <catalin.marinas@arm.com>,
 <will.deacon@arm.com>, <thomas.lendacky@amd.com>,
 <herbert@gondor.apana.org.au>, <davem@davemloft.net>, <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1431045436-8690-1-git-send-email-Suravee.Suthikulpanit@amd.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch implements support for ACPI _CCA object, which is introduced in
ACPIv5.1, can be used for specifying device DMA coherency attribute.

The parsing logic traverses device namespace to parse coherency
information, and stores it in acpi_device_flags. Then uses it to call
arch_setup_dma_ops() when creating each device enumerated in DSDT
during ACPI scan.

This patch also introduces acpi_dma_is_coherent(), which provides
an interface for device drivers to check the coherency information
similarly to the of_dma_is_coherent().

Signed-off-by: Mark Salter <msalter@redhat.com>
Signed-off-by: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
---
 drivers/acpi/Kconfig         |  6 ++++++
 drivers/acpi/acpi_platform.c | 10 +++++++---
 drivers/acpi/scan.c          | 42 ++++++++++++++++++++++++++++++++++++++++++
 include/acpi/acpi_bus.h      | 32 +++++++++++++++++++++++++++++++-
 include/linux/acpi.h         | 10 ++++++++++
 5 files changed, 96 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index ab2cbb5..7822149 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -54,6 +54,12 @@ config ACPI_GENERIC_GSI
 config ACPI_SYSTEM_POWER_STATES_SUPPORT
 	bool
 
+config ACPI_CCA_REQUIRED
+	bool
+
+config ARM64_SUPPORT_ACPI_CCA_ZERO
+	bool
+
 config ACPI_SLEEP
 	bool
 	depends on SUSPEND || HIBERNATION
diff --git a/drivers/acpi/acpi_platform.c b/drivers/acpi/acpi_platform.c
index 4bf7559..a084ea0 100644
--- a/drivers/acpi/acpi_platform.c
+++ b/drivers/acpi/acpi_platform.c
@@ -103,14 +103,18 @@ struct platform_device *acpi_create_platform_device(struct acpi_device *adev)
 	pdevinfo.res = resources;
 	pdevinfo.num_res = count;
 	pdevinfo.fwnode = acpi_fwnode_handle(adev);
-	pdevinfo.dma_mask = DMA_BIT_MASK(32);
+	pdevinfo.dma_mask = acpi_dma_is_supported(adev)? DMA_BIT_MASK(32): 0;
 	pdev = platform_device_register_full(&pdevinfo);
-	if (IS_ERR(pdev))
+	if (IS_ERR(pdev)) {
 		dev_err(&adev->dev, "platform device creation failed: %ld\n",
 			PTR_ERR(pdev));
-	else
+	} else {
+		if (acpi_dma_is_supported(adev))
+			arch_setup_dma_ops(&pdev->dev, 0, 0, NULL,
+					   acpi_dma_is_coherent(adev));
 		dev_dbg(&adev->dev, "created platform device %s\n",
 			dev_name(&pdev->dev));
+	}
 
 	kfree(resources);
 	return pdev;
diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
index 849b699..0976dc2 100644
--- a/drivers/acpi/scan.c
+++ b/drivers/acpi/scan.c
@@ -11,6 +11,7 @@
 #include <linux/kthread.h>
 #include <linux/dmi.h>
 #include <linux/nls.h>
+#include <linux/dma-mapping.h>
 
 #include <asm/pgtable.h>
 
@@ -2137,6 +2138,46 @@ void acpi_free_pnp_ids(struct acpi_device_pnp *pnp)
 	kfree(pnp->unique_id);
 }
 
+static void acpi_init_coherency(struct acpi_device *adev)
+{
+	unsigned long long cca = 0;
+	acpi_status status;
+	struct acpi_device *parent = adev->parent;
+	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
+
+	if (parent && parent->flags.cca_seen) {
+		/*
+		 * From ACPI spec, OSPM will ignore _CCA if an ancestor
+		 * already saw one.
+		 */
+		adev->flags.cca_seen = 1;
+		cca = acpi_dma_is_coherent(parent);
+	} else {
+		status = acpi_evaluate_integer(adev->handle, "_CCA",
+					       NULL, &cca);
+		if (ACPI_SUCCESS(status)) {
+			adev->flags.cca_seen = 1;
+		} else if (!IS_ENABLED(CONFIG_ACPI_CCA_REQUIRED)) {
+			/*
+			 * If architecture does not specify that _CCA is
+			 * required for DMA-able devices (e.g. x86),
+			 * we default to _CCA=1.
+			 */
+			cca = 1;
+		} else {
+			acpi_get_name(adev->handle, ACPI_FULL_PATHNAME, &buffer);
+			pr_debug("ACPI device %s is missing _CCA.\n",
+				(char *) buffer.pointer);
+			kfree(buffer.pointer);
+		}
+	}
+
+	adev->flags.is_coherent = cca;
+	if (acpi_dma_is_supported(adev))
+		arch_setup_dma_ops(&adev->dev, 0, 0, NULL,
+				   acpi_dma_is_coherent(adev));
+}
+
 void acpi_init_device_object(struct acpi_device *device, acpi_handle handle,
 			     int type, unsigned long long sta)
 {
@@ -2155,6 +2196,7 @@ void acpi_init_device_object(struct acpi_device *device, acpi_handle handle,
 	device->flags.visited = false;
 	device_initialize(&device->dev);
 	dev_set_uevent_suppress(&device->dev, true);
+	acpi_init_coherency(device);
 }
 
 void acpi_device_add_finalize(struct acpi_device *device)
diff --git a/include/acpi/acpi_bus.h b/include/acpi/acpi_bus.h
index 8de4fa9..17fb630 100644
--- a/include/acpi/acpi_bus.h
+++ b/include/acpi/acpi_bus.h
@@ -208,7 +208,9 @@ struct acpi_device_flags {
 	u32 visited:1;
 	u32 hotplug_notify:1;
 	u32 is_dock_station:1;
-	u32 reserved:23;
+	u32 is_coherent:1;
+	u32 cca_seen:1;
+	u32 reserved:21;
 };
 
 /* File System */
@@ -380,6 +382,34 @@ struct acpi_device {
 	void (*remove)(struct acpi_device *);
 };
 
+static inline bool acpi_dma_is_supported(struct acpi_device *adev)
+{
+	/**
+	 * Currently, we mainly support _CCA=1 (i.e. is_coherent=1)
+	 * This should be equivalent to specifyig dma-coherent for
+	 * a device in OF.
+	 *
+	 * For the case when _CCA=0 (i.e. is_coherent=0 && cca_seen=1),
+	 * we would rely on arch-specific cache maintenance for
+	 * non-coherence DMA operations if architecture specifies
+	 * _XXX_SUPPORT_CCA_ZERO. Otherwise, we do not support
+	 * DMA on this device and fallback to arch-specific default
+	 * handling.
+	 *
+	 * For the case when _CCA is missing (i.e. cca_seen=0) but
+	 * platform specifies ACPI_CCA_REQUIRED, we do not support DMA,
+	 * and fallback to arch-specific default handling.
+	 */
+	return adev && (adev->flags.is_coherent ||
+			(adev->flags.cca_seen &&
+			 IS_ENABLED(CONFIG_ARM64_SUPPORT_ACPI_CCA_ZERO)));
+}
+
+static inline bool acpi_dma_is_coherent(struct acpi_device *adev)
+{
+	return adev && adev->flags.is_coherent;
+}
+
 static inline bool is_acpi_node(struct fwnode_handle *fwnode)
 {
 	return fwnode && fwnode->type == FWNODE_ACPI;
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index b10c4a6..baccf3b 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -583,6 +583,16 @@ static inline int acpi_device_modalias(struct device *dev,
 	return -ENODEV;
 }
 
+static inline bool acpi_dma_is_supported(struct acpi_device *adev)
+{
+	return false;
+}
+
+static inline bool acpi_dma_is_coherent(struct acpi_device *adev)
+{
+	return false;
+}
+
 #define ACPI_PTR(_ptr)	(NULL)
 
 #endif	/* !CONFIG_ACPI */
-- 
2.1.0
