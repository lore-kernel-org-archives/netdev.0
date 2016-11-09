From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V5 6/9] liquidio CN23XX: device states
Date: Wed, 9 Nov 2016 15:13:49 -0800
Message-ID: <1478733232-15739-7-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1478733232-15739-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0081.outbound.protection.outlook.com ([104.47.32.81]:54484
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754749AbcKIXOg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 18:14:36 -0500
In-Reply-To: <1478733232-15739-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleaned up resource leaks during destroy resources by
introducing more device states.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 33 ++++++++++++++++------
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  6 +++-
 .../net/ethernet/cavium/liquidio/octeon_device.h   | 29 ++++++++++---------
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 13 +++++----
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |  8 ++++--
 .../net/ethernet/cavium/liquidio/request_manager.c |  6 +++-
 6 files changed, 64 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 6e435db..eb46ffa 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -770,6 +770,7 @@ static void delete_glists(struct lio *lio)
 	}
 
 	kfree((void *)lio->glist);
+	kfree((void *)lio->glist_lock);
 }
 
 /**
@@ -1329,6 +1330,7 @@ static int liquidio_watchdog(void *param)
 		complete(&first_stage);
 
 	if (octeon_device_init(oct_dev)) {
+		complete(&hs->init);
 		liquidio_remove(pdev);
 		return -ENOMEM;
 	}
@@ -1353,7 +1355,15 @@ static int liquidio_watchdog(void *param)
 			oct_dev->watchdog_task = kthread_create(
 			    liquidio_watchdog, oct_dev,
 			    "liowd/%02hhx:%02hhx.%hhx", bus, device, function);
-			wake_up_process(oct_dev->watchdog_task);
+			if (!IS_ERR(oct_dev->watchdog_task)) {
+				wake_up_process(oct_dev->watchdog_task);
+			} else {
+				oct_dev->watchdog_task = NULL;
+				dev_err(&oct_dev->pci_dev->dev,
+					"failed to create kernel_thread\n");
+				liquidio_remove(pdev);
+				return -1;
+			}
 		}
 	}
 
@@ -1417,6 +1427,8 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 		if (lio_wait_for_oq_pkts(oct))
 			dev_err(&oct->pci_dev->dev, "OQ had pending packets\n");
 
+	/* fallthrough */
+	case OCT_DEV_INTR_SET_DONE:
 		/* Disable interrupts  */
 		oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
 
@@ -1443,6 +1455,8 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 				pci_disable_msi(oct->pci_dev);
 		}
 
+	/* fallthrough */
+	case OCT_DEV_MSIX_ALLOC_VECTOR_DONE:
 		if (OCTEON_CN23XX_PF(oct))
 			octeon_free_ioq_vector(oct);
 
@@ -1508,10 +1522,13 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 		octeon_unmap_pci_barx(oct, 1);
 
 		/* fallthrough */
-	case OCT_DEV_BEGIN_STATE:
+	case OCT_DEV_PCI_ENABLE_DONE:
+		pci_clear_master(oct->pci_dev);
 		/* Disable the device, releasing the PCI INT */
 		pci_disable_device(oct->pci_dev);
 
+		/* fallthrough */
+	case OCT_DEV_BEGIN_STATE:
 		/* Nothing to be done here either */
 		break;
 	}                       /* end switch (oct->status) */
@@ -1781,6 +1798,7 @@ static int octeon_pci_os_setup(struct octeon_device *oct)
 
 	if (dma_set_mask_and_coherent(&oct->pci_dev->dev, DMA_BIT_MASK(64))) {
 		dev_err(&oct->pci_dev->dev, "Unexpected DMA device capability\n");
+		pci_disable_device(oct->pci_dev);
 		return 1;
 	}
 
@@ -4434,6 +4452,8 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 	if (octeon_pci_os_setup(octeon_dev))
 		return 1;
 
+	atomic_set(&octeon_dev->status, OCT_DEV_PCI_ENABLE_DONE);
+
 	/* Identify the Octeon type and map the BAR address space. */
 	if (octeon_chip_specific_setup(octeon_dev)) {
 		dev_err(&octeon_dev->pci_dev->dev, "Chip specific setup failed\n");
@@ -4505,9 +4525,6 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 	if (octeon_setup_instr_queues(octeon_dev)) {
 		dev_err(&octeon_dev->pci_dev->dev,
 			"instruction queue initialization failed\n");
-		/* On error, release any previously allocated queues */
-		for (j = 0; j < octeon_dev->num_iqs; j++)
-			octeon_delete_instr_queue(octeon_dev, j);
 		return 1;
 	}
 	atomic_set(&octeon_dev->status, OCT_DEV_INSTR_QUEUE_INIT_DONE);
@@ -4523,9 +4540,6 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	if (octeon_setup_output_queues(octeon_dev)) {
 		dev_err(&octeon_dev->pci_dev->dev, "Output queue initialization failed\n");
-		/* Release any previously allocated queues */
-		for (j = 0; j < octeon_dev->num_oqs; j++)
-			octeon_delete_droq(octeon_dev, j);
 		return 1;
 	}
 
@@ -4542,6 +4556,7 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 			dev_err(&octeon_dev->pci_dev->dev, "OCTEON: ioq vector allocation failed\n");
 			return 1;
 		}
+		atomic_set(&octeon_dev->status, OCT_DEV_MSIX_ALLOC_VECTOR_DONE);
 
 	} else {
 		/* The input and output queue registers were setup earlier (the
@@ -4569,6 +4584,8 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 	/* Enable Octeon device interrupts */
 	octeon_dev->fn_list.enable_interrupt(octeon_dev, OCTEON_ALL_INTR);
 
+	atomic_set(&octeon_dev->status, OCT_DEV_INTR_SET_DONE);
+
 	/* Enable the input and output queues for this Octeon device */
 	ret = octeon_dev->fn_list.enable_io_queues(octeon_dev);
 	if (ret) {
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 7f532fd..295e2ca 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -822,6 +822,7 @@ int octeon_setup_instr_queues(struct octeon_device *oct)
 	if (octeon_init_instr_queue(oct, txpciq, num_descs)) {
 		/* prevent memory leak */
 		vfree(oct->instr_queue[0]);
+		oct->instr_queue[0] = NULL;
 		return 1;
 	}
 
@@ -854,8 +855,11 @@ int octeon_setup_output_queues(struct octeon_device *oct)
 	if (!oct->droq[0])
 		return 1;
 
-	if (octeon_init_droq(oct, oq_no, num_descs, desc_size, NULL))
+	if (octeon_init_droq(oct, oq_no, num_descs, desc_size, NULL)) {
+		vfree(oct->droq[oq_no]);
+		oct->droq[oq_no] = NULL;
 		return 1;
+	}
 	oct->num_oqs++;
 
 	return 0;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 70a0d98..6c18baa 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -72,20 +72,23 @@ enum octeon_pci_swap_mode {
  *  as it is initialized.
  */
 #define    OCT_DEV_BEGIN_STATE            0x0
-#define    OCT_DEV_PCI_MAP_DONE           0x1
-#define    OCT_DEV_DISPATCH_INIT_DONE     0x2
-#define    OCT_DEV_INSTR_QUEUE_INIT_DONE  0x3
-#define    OCT_DEV_SC_BUFF_POOL_INIT_DONE 0x4
-#define    OCT_DEV_RESP_LIST_INIT_DONE    0x5
-#define    OCT_DEV_DROQ_INIT_DONE         0x6
+#define    OCT_DEV_PCI_ENABLE_DONE        0x1
+#define    OCT_DEV_PCI_MAP_DONE           0x2
+#define    OCT_DEV_DISPATCH_INIT_DONE     0x3
+#define    OCT_DEV_INSTR_QUEUE_INIT_DONE  0x4
+#define    OCT_DEV_SC_BUFF_POOL_INIT_DONE 0x5
+#define    OCT_DEV_RESP_LIST_INIT_DONE    0x6
+#define    OCT_DEV_DROQ_INIT_DONE         0x7
 #define    OCT_DEV_MBOX_SETUP_DONE        0x8
-#define    OCT_DEV_IO_QUEUES_DONE         0x9
-#define    OCT_DEV_CONSOLE_INIT_DONE      0xa
-#define    OCT_DEV_HOST_OK                0xb
-#define    OCT_DEV_CORE_OK                0xc
-#define    OCT_DEV_RUNNING                0xd
-#define    OCT_DEV_IN_RESET               0xe
-#define    OCT_DEV_STATE_INVALID          0xf
+#define    OCT_DEV_MSIX_ALLOC_VECTOR_DONE 0x9
+#define    OCT_DEV_INTR_SET_DONE          0xa
+#define    OCT_DEV_IO_QUEUES_DONE         0xb
+#define    OCT_DEV_CONSOLE_INIT_DONE      0xc
+#define    OCT_DEV_HOST_OK                0xd
+#define    OCT_DEV_CORE_OK                0xe
+#define    OCT_DEV_RUNNING                0xf
+#define    OCT_DEV_IN_RESET               0x10
+#define    OCT_DEV_STATE_INVALID          0x11
 
 #define    OCT_DEV_STATES                 OCT_DEV_STATE_INVALID
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index f60e532..886987f 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -988,7 +988,8 @@ int octeon_create_droq(struct octeon_device *oct,
 	if (!droq)
 		droq = vmalloc(sizeof(*droq));
 	if (!droq)
-		goto create_droq_fail;
+		return -1;
+
 	memset(droq, 0, sizeof(struct octeon_droq));
 
 	/*Disable the pkt o/p for this Q  */
@@ -996,7 +997,11 @@ int octeon_create_droq(struct octeon_device *oct,
 	oct->droq[q_no] = droq;
 
 	/* Initialize the Droq */
-	octeon_init_droq(oct, q_no, num_descs, desc_size, app_ctx);
+	if (octeon_init_droq(oct, q_no, num_descs, desc_size, app_ctx)) {
+		vfree(oct->droq[q_no]);
+		oct->droq[q_no] = NULL;
+		return -1;
+	}
 
 	oct->num_oqs++;
 
@@ -1009,8 +1014,4 @@ int octeon_create_droq(struct octeon_device *oct,
 	 * the same time.
 	 */
 	return 0;
-
-create_droq_fail:
-	octeon_delete_droq(oct, q_no);
-	return -ENOMEM;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
index 3cddf28..3afa61e 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_main.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
@@ -116,7 +116,7 @@ static inline int octeon_map_pci_barx(struct octeon_device *oct,
 
 	mapped_len = oct->mmio[baridx].len;
 	if (!mapped_len)
-		return 1;
+		goto err_release_region;
 
 	if (max_map_len && (mapped_len > max_map_len))
 		mapped_len = max_map_len;
@@ -132,11 +132,15 @@ static inline int octeon_map_pci_barx(struct octeon_device *oct,
 	if (!oct->mmio[baridx].hw_addr) {
 		dev_err(&oct->pci_dev->dev, "error ioremap for bar %d\n",
 			baridx);
-		return 1;
+		goto err_release_region;
 	}
 	oct->mmio[baridx].done = 1;
 
 	return 0;
+
+err_release_region:
+	pci_release_region(oct->pci_dev, baridx * 2);
+	return 1;
 }
 
 static inline void *
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 90866bb..a73560c 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -157,6 +157,8 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 						     WQ_MEM_RECLAIM,
 						     0);
 	if (!oct->check_db_wq[iq_no].wq) {
+		vfree(iq->request_list);
+		iq->request_list = NULL;
 		lio_dma_free(oct, q_size, iq->base_addr, iq->base_addr_dma);
 		dev_err(&oct->pci_dev->dev, "check db wq create failed for iq %d\n",
 			iq_no);
@@ -749,8 +751,10 @@ int octeon_setup_sc_buffer_pool(struct octeon_device *oct)
 			lio_dma_alloc(oct,
 				      SOFT_COMMAND_BUFFER_SIZE,
 					  (dma_addr_t *)&dma_addr);
-		if (!sc)
+		if (!sc) {
+			octeon_free_sc_buffer_pool(oct);
 			return 1;
+		}
 
 		sc->dma_addr = dma_addr;
 		sc->size = SOFT_COMMAND_BUFFER_SIZE;
-- 
1.8.3.1
