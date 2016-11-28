From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 9/9] liquidio CN23XX: VF init and destroy
Date: Sun, 27 Nov 2016 20:51:42 -0800
Message-ID: <1480308702-6261-10-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-dm3nam03on0089.outbound.protection.outlook.com ([104.47.41.89]:13344
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754122AbcK1Ewv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 23:52:51 -0500
In-Reply-To: <1480308702-6261-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for VF initialization and destroy resources.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_vf_device.h    |   2 +
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 106 +++++++++++++++++++++
 2 files changed, 108 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
index 8590bdb..6715df3 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
@@ -36,6 +36,8 @@ struct octeon_cn23xx_vf {
 
 #define CN23XX_MAILBOX_MSGPARAM_SIZE		6
 
+#define MAX_VF_IP_OP_PENDING_PKT_COUNT		100
+
 void cn23xx_vf_ask_pf_to_do_flr(struct octeon_device *oct);
 
 int cn23xx_octeon_pfvf_handshake(struct octeon_device *oct);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 337285b..2493bf5 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -41,6 +41,60 @@ struct octeon_device_priv {
 static void liquidio_vf_remove(struct pci_dev *pdev);
 static int octeon_device_init(struct octeon_device *oct);
 
+static int lio_wait_for_oq_pkts(struct octeon_device *oct)
+{
+	struct octeon_device_priv *oct_priv =
+	    (struct octeon_device_priv *)oct->priv;
+	int retry = MAX_VF_IP_OP_PENDING_PKT_COUNT;
+	int pkt_cnt = 0, pending_pkts;
+	int i;
+
+	do {
+		pending_pkts = 0;
+
+		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
+			if (!(oct->io_qmask.oq & BIT_ULL(i)))
+				continue;
+			pkt_cnt += octeon_droq_check_hw_for_pkts(oct->droq[i]);
+		}
+		if (pkt_cnt > 0) {
+			pending_pkts += pkt_cnt;
+			tasklet_schedule(&oct_priv->droq_tasklet);
+		}
+		pkt_cnt = 0;
+		schedule_timeout_uninterruptible(1);
+
+	} while (retry-- && pending_pkts);
+
+	return pkt_cnt;
+}
+
+/**
+ * \brief wait for all pending requests to complete
+ * @param oct Pointer to Octeon device
+ *
+ * Called during shutdown sequence
+ */
+static int wait_for_pending_requests(struct octeon_device *oct)
+{
+	int i, pcount = 0;
+
+	for (i = 0; i < MAX_VF_IP_OP_PENDING_PKT_COUNT; i++) {
+		pcount = atomic_read(
+		    &oct->response_list[OCTEON_ORDERED_SC_LIST]
+			 .pending_req_count);
+		if (pcount)
+			schedule_timeout_uninterruptible(HZ / 10);
+		else
+			break;
+	}
+
+	if (pcount)
+		return 1;
+
+	return 0;
+}
+
 static const struct pci_device_id liquidio_vf_pci_tbl[] = {
 	{
 		PCI_VENDOR_ID_CAVIUM, OCTEON_CN23XX_VF_VID,
@@ -257,6 +311,35 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 	int i;
 
 	switch (atomic_read(&oct->status)) {
+	case OCT_DEV_RUNNING:
+	case OCT_DEV_CORE_OK:
+		/* No more instructions will be forwarded. */
+		atomic_set(&oct->status, OCT_DEV_IN_RESET);
+
+		dev_dbg(&oct->pci_dev->dev, "Device state is now %s\n",
+			lio_get_state_string(&oct->status));
+
+		schedule_timeout_uninterruptible(HZ / 10);
+
+		/* fallthrough */
+	case OCT_DEV_HOST_OK:
+		/* fallthrough */
+	case OCT_DEV_IO_QUEUES_DONE:
+		if (wait_for_pending_requests(oct))
+			dev_err(&oct->pci_dev->dev, "There were pending requests\n");
+
+		if (lio_wait_for_instr_fetch(oct))
+			dev_err(&oct->pci_dev->dev, "IQ had pending instructions\n");
+
+		/* Disable the input and output queues now. No more packets will
+		 * arrive from Octeon, but we should wait for all packet
+		 * processing to finish.
+		 */
+		oct->fn_list.disable_io_queues(oct);
+
+		if (lio_wait_for_oq_pkts(oct))
+			dev_err(&oct->pci_dev->dev, "OQ had pending packets\n");
+
 	case OCT_DEV_INTR_SET_DONE:
 		/* Disable interrupts  */
 		oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
@@ -395,6 +478,7 @@ static int octeon_pci_os_setup(struct octeon_device *oct)
 static int octeon_device_init(struct octeon_device *oct)
 {
 	u32 rev_id;
+	int j;
 
 	atomic_set(&oct->status, OCT_DEV_BEGIN_STATE);
 
@@ -488,6 +572,28 @@ static int octeon_device_init(struct octeon_device *oct)
 
 	atomic_set(&oct->status, OCT_DEV_INTR_SET_DONE);
 
+	/* Enable the input and output queues for this Octeon device */
+	if (oct->fn_list.enable_io_queues(oct)) {
+		dev_err(&oct->pci_dev->dev, "enabling io queues failed\n");
+		return 1;
+	}
+
+	atomic_set(&oct->status, OCT_DEV_IO_QUEUES_DONE);
+
+	atomic_set(&oct->status, OCT_DEV_HOST_OK);
+
+	/* Send Credit for Octeon Output queues. Credits are always sent after
+	 * the output queue is enabled.
+	 */
+	for (j = 0; j < oct->num_oqs; j++)
+		writel(oct->droq[j]->max_count, oct->droq[j]->pkts_credit_reg);
+
+	/* Packets can start arriving on the output queues from this point. */
+
+	atomic_set(&oct->status, OCT_DEV_CORE_OK);
+
+	atomic_set(&oct->status, OCT_DEV_RUNNING);
+
 	return 0;
 }
 
-- 
1.8.3.1
