From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 6/9] liquidio CN23XX: init VF softcommand queues
Date: Sun, 27 Nov 2016 20:51:39 -0800
Message-ID: <1480308702-6261-7-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1480308702-6261-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-dm3nam03on0082.outbound.protection.outlook.com ([104.47.41.82]:58144
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754122AbcK1Ewf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 23:52:35 -0500
In-Reply-To: <1480308702-6261-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for initializing softcommand, dispatch and
instructions queues for VF.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 74 +++++++++++++++++++++-
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  5 ++
 .../net/ethernet/cavium/liquidio/request_manager.c |  7 ++
 3 files changed, 84 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 43a5373..d02f1dd 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -140,18 +140,51 @@ static void octeon_pci_flr(struct octeon_device *oct)
  */
 static void octeon_destroy_resources(struct octeon_device *oct)
 {
+	int i;
+
 	switch (atomic_read(&oct->status)) {
+	case OCT_DEV_IN_RESET:
+	case OCT_DEV_DROQ_INIT_DONE:
+		mdelay(100);
+		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
+			if (!(oct->io_qmask.oq & BIT_ULL(i)))
+				continue;
+			octeon_delete_droq(oct, i);
+		}
+
+		/* fallthrough */
+	case OCT_DEV_RESP_LIST_INIT_DONE:
+		octeon_delete_response_list(oct);
+
+		/* fallthrough */
+	case OCT_DEV_INSTR_QUEUE_INIT_DONE:
+		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
+			if (!(oct->io_qmask.iq & BIT_ULL(i)))
+				continue;
+			octeon_delete_instr_queue(oct, i);
+		}
+
+		/* fallthrough */
+	case OCT_DEV_SC_BUFF_POOL_INIT_DONE:
+		octeon_free_sc_buffer_pool(oct);
+
+		/* fallthrough */
+	case OCT_DEV_DISPATCH_INIT_DONE:
+		octeon_delete_dispatch_list(oct);
+		cancel_delayed_work_sync(&oct->nic_poll_work.work);
+
+		/* fallthrough */
 	case OCT_DEV_PCI_MAP_DONE:
 		octeon_unmap_pci_barx(oct, 0);
 		octeon_unmap_pci_barx(oct, 1);
 
-	/* fallthrough */
+		/* fallthrough */
 	case OCT_DEV_PCI_ENABLE_DONE:
 		pci_clear_master(oct->pci_dev);
 		/* Disable the device, releasing the PCI INT */
 		pci_disable_device(oct->pci_dev);
 
-	/* fallthrough */
+		/* fallthrough */
 	case OCT_DEV_BEGIN_STATE:
 		/* Nothing to be done here either */
 		break;
@@ -236,6 +269,14 @@ static int octeon_device_init(struct octeon_device *oct)
 
 	atomic_set(&oct->status, OCT_DEV_PCI_MAP_DONE);
 
+	/* Initialize the dispatch mechanism used to push packets arriving on
+	 * Octeon Output queues.
+	 */
+	if (octeon_init_dispatch_list(oct))
+		return 1;
+
+	atomic_set(&oct->status, OCT_DEV_DISPATCH_INIT_DONE);
+
 	if (octeon_set_io_queues_off(oct)) {
 		dev_err(&oct->pci_dev->dev, "setting io queues off failed\n");
 		return 1;
@@ -246,6 +287,35 @@ static int octeon_device_init(struct octeon_device *oct)
 		return 1;
 	}
 
+	/* Initialize soft command buffer pool */
+	if (octeon_setup_sc_buffer_pool(oct)) {
+		dev_err(&oct->pci_dev->dev, "sc buffer pool allocation failed\n");
+		return 1;
+	}
+	atomic_set(&oct->status, OCT_DEV_SC_BUFF_POOL_INIT_DONE);
+
+	/* Setup the data structures that manage this Octeon's Input queues. */
+	if (octeon_setup_instr_queues(oct)) {
+		dev_err(&oct->pci_dev->dev, "instruction queue initialization failed\n");
+		return 1;
+	}
+	atomic_set(&oct->status, OCT_DEV_INSTR_QUEUE_INIT_DONE);
+
+	/* Initialize lists to manage the requests of different types that
+	 * arrive from user & kernel applications for this octeon device.
+	 */
+	if (octeon_setup_response_list(oct)) {
+		dev_err(&oct->pci_dev->dev, "Response list allocation failed\n");
+		return 1;
+	}
+	atomic_set(&oct->status, OCT_DEV_RESP_LIST_INIT_DONE);
+
+	if (octeon_setup_output_queues(oct)) {
+		dev_err(&oct->pci_dev->dev, "Output queue initialization failed\n");
+		return 1;
+	}
+	atomic_set(&oct->status, OCT_DEV_DROQ_INIT_DONE);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index f2cfafd..8af08d4 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -797,6 +797,8 @@ int octeon_setup_instr_queues(struct octeon_device *oct)
 			CFG_GET_NUM_DEF_TX_DESCS(CHIP_CONF(oct, cn6xxx));
 	else if (OCTEON_CN23XX_PF(oct))
 		num_descs = CFG_GET_NUM_DEF_TX_DESCS(CHIP_CONF(oct, cn23xx_pf));
+	else if (OCTEON_CN23XX_VF(oct))
+		num_descs = CFG_GET_NUM_DEF_TX_DESCS(CHIP_CONF(oct, cn23xx_vf));
 
 	oct->num_iqs = 0;
 
@@ -842,6 +844,9 @@ int octeon_setup_output_queues(struct octeon_device *oct)
 	} else if (OCTEON_CN23XX_PF(oct)) {
 		num_descs = CFG_GET_NUM_DEF_RX_DESCS(CHIP_CONF(oct, cn23xx_pf));
 		desc_size = CFG_GET_DEF_RX_BUF_SIZE(CHIP_CONF(oct, cn23xx_pf));
+	} else if (OCTEON_CN23XX_VF(oct)) {
+		num_descs = CFG_GET_NUM_DEF_RX_DESCS(CHIP_CONF(oct, cn23xx_vf));
+		desc_size = CFG_GET_DEF_RX_BUF_SIZE(CHIP_CONF(oct, cn23xx_vf));
 	}
 	oct->num_oqs = 0;
 	oct->droq[0] = vmalloc_node(sizeof(*oct->droq[0]), numa_node);
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 0e10e2a..ea2b7e4 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -28,6 +28,7 @@
 #include "octeon_network.h"
 #include "cn66xx_device.h"
 #include "cn23xx_pf_device.h"
+#include "cn23xx_vf_device.h"
 
 struct iq_post_status {
 	int status;
@@ -68,6 +69,9 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 		conf = &(CFG_GET_IQ_CFG(CHIP_CONF(oct, cn6xxx)));
 	else if (OCTEON_CN23XX_PF(oct))
 		conf = &(CFG_GET_IQ_CFG(CHIP_CONF(oct, cn23xx_pf)));
+	else if (OCTEON_CN23XX_VF(oct))
+		conf = &(CFG_GET_IQ_CFG(CHIP_CONF(oct, cn23xx_vf)));
+
 	if (!conf) {
 		dev_err(&oct->pci_dev->dev, "Unsupported Chip %x\n",
 			oct->chip_id);
@@ -183,6 +187,9 @@ int octeon_delete_instr_queue(struct octeon_device *oct, u32 iq_no)
 	else if (OCTEON_CN23XX_PF(oct))
 		desc_size =
 		    CFG_GET_IQ_INSTR_TYPE(CHIP_CONF(oct, cn23xx_pf));
+	else if (OCTEON_CN23XX_VF(oct))
+		desc_size =
+		    CFG_GET_IQ_INSTR_TYPE(CHIP_CONF(oct, cn23xx_vf));
 
 	vfree(iq->request_list);
 
-- 
1.8.3.1
