From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: use meaningful names for IRQs
Date: Mon, 13 Mar 2017 12:58:04 -0700
Message-ID: <20170313195804.GA1796@felix2.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0060.outbound.protection.outlook.com ([104.47.33.60]:14499
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751132AbdCMT6S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 15:58:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

All IRQs owned by the PF and VF drivers share the same nondescript name
"octeon"; this makes it difficult to setup interrupt affinity.

Change the IRQ names to reflect their specific purpose:

    LiquidIO<id>-<func>-<type>-<queue pair num>

Examples:
    LiquidIO0-pf0-rxtx-3
    LiquidIO1-vf1-rxtx-0
    LiquidIO0-pf0-aux

We cannot use netdev->name for naming the IRQs because:

    1.  Early during init, the PF and VF drivers require interrupts to
        send/receive control data from the NIC firmware; so the PF and VF
        must request IRQs long before the netdev struct is registered.

    2.  The IRQ name can only be specified at the time it is requested.
        It cannot be changed after that.

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 72 ++++++++++++++++++----
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 37 +++++++++--
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  5 ++
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  3 +
 4 files changed, 101 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index be9c0e3..3c5de81 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1076,16 +1076,35 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
 	int i;
 	int num_ioq_vectors;
 	int num_alloc_ioq_vectors;
+	char *queue_irq_names = NULL;
+	char *aux_irq_name = NULL;
 
 	if (OCTEON_CN23XX_PF(oct) && oct->msix_on) {
 		oct->num_msix_irqs = oct->sriov_info.num_pf_rings;
 		/* one non ioq interrupt for handling sli_mac_pf_int_sum */
 		oct->num_msix_irqs += 1;
 
+		/* allocate storage for the names assigned to each irq */
+		oct->irq_name_storage =
+			kcalloc((MAX_IOQ_INTERRUPTS_PER_PF + 1), INTRNAMSIZ,
+				GFP_KERNEL);
+		if (!oct->irq_name_storage) {
+			dev_err(&oct->pci_dev->dev, "Irq name storage alloc failed...\n");
+			return -ENOMEM;
+		}
+
+		queue_irq_names = oct->irq_name_storage;
+		aux_irq_name = &queue_irq_names
+				[IRQ_NAME_OFF(MAX_IOQ_INTERRUPTS_PER_PF)];
+
 		oct->msix_entries = kcalloc(
 		    oct->num_msix_irqs, sizeof(struct msix_entry), GFP_KERNEL);
-		if (!oct->msix_entries)
-			return 1;
+		if (!oct->msix_entries) {
+			dev_err(&oct->pci_dev->dev, "Memory Alloc failed...\n");
+			kfree(oct->irq_name_storage);
+			oct->irq_name_storage = NULL;
+			return -ENOMEM;
+		}
 
 		msix_entries = (struct msix_entry *)oct->msix_entries;
 		/*Assumption is that pf msix vectors start from pf srn to pf to
@@ -1103,7 +1122,9 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
 			dev_err(&oct->pci_dev->dev, "unable to Allocate MSI-X interrupts\n");
 			kfree(oct->msix_entries);
 			oct->msix_entries = NULL;
-			return 1;
+			kfree(oct->irq_name_storage);
+			oct->irq_name_storage = NULL;
+			return num_alloc_ioq_vectors;
 		}
 		dev_dbg(&oct->pci_dev->dev, "OCTEON: Enough MSI-X interrupts are allocated...\n");
 
@@ -1111,9 +1132,12 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
 
 		/** For PF, there is one non-ioq interrupt handler */
 		num_ioq_vectors -= 1;
+
+		snprintf(aux_irq_name, INTRNAMSIZ,
+			 "LiquidIO%u-pf%u-aux", oct->octeon_id, oct->pf_num);
 		irqret = request_irq(msix_entries[num_ioq_vectors].vector,
-				     liquidio_legacy_intr_handler, 0, "octeon",
-				     oct);
+				     liquidio_legacy_intr_handler, 0,
+				     aux_irq_name, oct);
 		if (irqret) {
 			dev_err(&oct->pci_dev->dev,
 				"OCTEON: Request_irq failed for MSIX interrupt Error: %d\n",
@@ -1121,13 +1145,20 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
 			pci_disable_msix(oct->pci_dev);
 			kfree(oct->msix_entries);
 			oct->msix_entries = NULL;
-			return 1;
+			kfree(oct->irq_name_storage);
+			oct->irq_name_storage = NULL;
+			return irqret;
 		}
 
 		for (i = 0; i < num_ioq_vectors; i++) {
+			snprintf(&queue_irq_names[IRQ_NAME_OFF(i)], INTRNAMSIZ,
+				 "LiquidIO%u-pf%u-rxtx-%u",
+				 oct->octeon_id, oct->pf_num, i);
+
 			irqret = request_irq(msix_entries[i].vector,
 					     liquidio_msix_intr_handler, 0,
-					     "octeon", &oct->ioq_vector[i]);
+					     &queue_irq_names[IRQ_NAME_OFF(i)],
+					     &oct->ioq_vector[i]);
 			if (irqret) {
 				dev_err(&oct->pci_dev->dev,
 					"OCTEON: Request_irq failed for MSIX interrupt Error: %d\n",
@@ -1147,7 +1178,9 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
 				pci_disable_msix(oct->pci_dev);
 				kfree(oct->msix_entries);
 				oct->msix_entries = NULL;
-				return 1;
+				kfree(oct->irq_name_storage);
+				oct->irq_name_storage = NULL;
+				return irqret;
 			}
 			oct->ioq_vector[i].vector = msix_entries[i].vector;
 			/* assign the cpu mask for this msix interrupt vector */
@@ -1165,15 +1198,29 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
 		else
 			oct->flags |= LIO_FLAG_MSI_ENABLED;
 
+		/* allocate storage for the names assigned to the irq */
+		oct->irq_name_storage = kcalloc(1, INTRNAMSIZ, GFP_KERNEL);
+		if (!oct->irq_name_storage)
+			return -ENOMEM;
+
+		queue_irq_names = oct->irq_name_storage;
+
+		snprintf(&queue_irq_names[IRQ_NAME_OFF(0)], INTRNAMSIZ,
+			 "LiquidIO%u-pf%u-rxtx-%u",
+			 oct->octeon_id, oct->pf_num, 0);
+
 		irqret = request_irq(oct->pci_dev->irq,
-				     liquidio_legacy_intr_handler, IRQF_SHARED,
-				     "octeon", oct);
+				     liquidio_legacy_intr_handler,
+				     IRQF_SHARED,
+				     &queue_irq_names[IRQ_NAME_OFF(0)], oct);
 		if (irqret) {
 			if (oct->flags & LIO_FLAG_MSI_ENABLED)
 				pci_disable_msi(oct->pci_dev);
 			dev_err(&oct->pci_dev->dev, "Request IRQ failed with code: %d\n",
 				irqret);
-			return 1;
+			kfree(oct->irq_name_storage);
+			oct->irq_name_storage = NULL;
+			return irqret;
 		}
 	}
 	return 0;
@@ -1441,6 +1488,9 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 				pci_disable_msi(oct->pci_dev);
 		}
 
+		kfree(oct->irq_name_storage);
+		oct->irq_name_storage = NULL;
+
 	/* fallthrough */
 	case OCT_DEV_MSIX_ALLOC_VECTOR_DONE:
 		if (OCTEON_CN23XX_PF(oct))
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 9d5e035..aeaefcb 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -750,6 +750,7 @@ liquidio_msix_intr_handler(int irq __attribute__((unused)), void *dev)
 static int octeon_setup_interrupt(struct octeon_device *oct)
 {
 	struct msix_entry *msix_entries;
+	char *queue_irq_names = NULL;
 	int num_alloc_ioq_vectors;
 	int num_ioq_vectors;
 	int irqret;
@@ -758,10 +759,25 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
 	if (oct->msix_on) {
 		oct->num_msix_irqs = oct->sriov_info.rings_per_vf;
 
+		/* allocate storage for the names assigned to each irq */
+		oct->irq_name_storage =
+			kcalloc(MAX_IOQ_INTERRUPTS_PER_VF, INTRNAMSIZ,
+				GFP_KERNEL);
+		if (!oct->irq_name_storage) {
+			dev_err(&oct->pci_dev->dev, "Irq name storage alloc failed...\n");
+			return -ENOMEM;
+		}
+
+		queue_irq_names = oct->irq_name_storage;
+
 		oct->msix_entries = kcalloc(
 		    oct->num_msix_irqs, sizeof(struct msix_entry), GFP_KERNEL);
-		if (!oct->msix_entries)
-			return 1;
+		if (!oct->msix_entries) {
+			dev_err(&oct->pci_dev->dev, "Memory Alloc failed...\n");
+			kfree(oct->irq_name_storage);
+			oct->irq_name_storage = NULL;
+			return -ENOMEM;
+		}
 
 		msix_entries = (struct msix_entry *)oct->msix_entries;
 
@@ -775,16 +791,23 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
 			dev_err(&oct->pci_dev->dev, "unable to Allocate MSI-X interrupts\n");
 			kfree(oct->msix_entries);
 			oct->msix_entries = NULL;
-			return 1;
+			kfree(oct->irq_name_storage);
+			oct->irq_name_storage = NULL;
+			return num_alloc_ioq_vectors;
 		}
 		dev_dbg(&oct->pci_dev->dev, "OCTEON: Enough MSI-X interrupts are allocated...\n");
 
 		num_ioq_vectors = oct->num_msix_irqs;
 
 		for (i = 0; i < num_ioq_vectors; i++) {
+			snprintf(&queue_irq_names[IRQ_NAME_OFF(i)], INTRNAMSIZ,
+				 "LiquidIO%u-vf%u-rxtx-%u",
+				 oct->octeon_id, oct->vf_num, i);
+
 			irqret = request_irq(msix_entries[i].vector,
 					     liquidio_msix_intr_handler, 0,
-					     "octeon", &oct->ioq_vector[i]);
+					     &queue_irq_names[IRQ_NAME_OFF(i)],
+					     &oct->ioq_vector[i]);
 			if (irqret) {
 				dev_err(&oct->pci_dev->dev,
 					"OCTEON: Request_irq failed for MSIX interrupt Error: %d\n",
@@ -800,7 +823,9 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
 				pci_disable_msix(oct->pci_dev);
 				kfree(oct->msix_entries);
 				oct->msix_entries = NULL;
-				return 1;
+				kfree(oct->irq_name_storage);
+				oct->irq_name_storage = NULL;
+				return irqret;
 			}
 			oct->ioq_vector[i].vector = msix_entries[i].vector;
 			/* assign the cpu mask for this msix interrupt vector */
@@ -945,6 +970,8 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 			pci_disable_msix(oct->pci_dev);
 			kfree(oct->msix_entries);
 			oct->msix_entries = NULL;
+			kfree(oct->irq_name_storage);
+			oct->irq_name_storage = NULL;
 		}
 		/* Soft reset the octeon device before exiting */
 		if (oct->pci_dev->reset_fn)
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 294c6f3..4a07c0a 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -100,6 +100,11 @@ enum octeon_tag_type {
 
 #define BYTES_PER_DHLEN_UNIT        8
 #define MAX_REG_CNT                 2000000U
+#define INTRNAMSIZ                  32
+#define IRQ_NAME_OFF(i)             ((i) * INTRNAMSIZ)
+#define MAX_IOQ_INTERRUPTS_PER_PF   (64 * 2)
+#define MAX_IOQ_INTERRUPTS_PER_VF   (8 * 2)
+
 
 static inline u32 incr_index(u32 index, u32 count, u32 max)
 {
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index c301a38..8c5d33e 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -517,6 +517,9 @@ struct octeon_device {
 
 	void *msix_entries;
 
+	/* when requesting IRQs, the names are stored here */
+	void *irq_name_storage;
+
 	struct octeon_sriov_info sriov_info;
 
 	struct octeon_pf_vf_hs_word pfvf_hsword;
