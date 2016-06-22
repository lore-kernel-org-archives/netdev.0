From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 06/13] liquidio: New unload state
Date: Tue, 21 Jun 2016 22:53:08 -0700
Message-ID: <1466574795-4306-7-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0070.outbound.protection.outlook.com ([65.55.169.70]:57977
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751504AbcFVFzW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 01:55:22 -0400
In-Reply-To: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds new state so that the ctrl packets are not sent
to firmware during unload time and only rx packets are allowed.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c      |  4 ++++
 drivers/net/ethernet/cavium/liquidio/octeon_device.h |  6 ++++++
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c    | 20 ++++++++++++++++++--
 .../net/ethernet/cavium/liquidio/response_manager.c  |  2 ++
 4 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 5fb1b79..4440086 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1327,6 +1327,10 @@ static int liquidio_stop_nic_module(struct octeon_device *oct)
 		return 1;
 	}
 
+	spin_lock_bh(&oct->cmd_resp_wqlock);
+	oct->cmd_resp_state = OCT_DRV_OFFLINE;
+	spin_unlock_bh(&oct->cmd_resp_wqlock);
+
 	for (i = 0; i < oct->ifcount; i++) {
 		lio = GET_LIO(oct->props[i].netdev);
 		for (j = 0; j < lio->linfo.num_rxpciq; j++)
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index abfc0d6..ceb905d 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -383,6 +383,10 @@ struct octeon_device {
 
 	struct cavium_wq dma_comp_wq;
 
+	/** Lock for dma response list */
+	spinlock_t cmd_resp_wqlock;
+	u32 cmd_resp_state;
+
 	struct cavium_wq check_db_wq[MAX_POSSIBLE_OCTEON_INSTR_QUEUES];
 
 	struct cavium_wk nic_poll_work;
@@ -392,6 +396,8 @@ struct octeon_device {
 	void *priv;
 };
 
+#define  OCT_DRV_ONLINE 1
+#define  OCT_DRV_OFFLINE 2
 #define  OCTEON_CN6XXX(oct)           ((oct->chip_id == OCTEON_CN66XX) || \
 				       (oct->chip_id == OCTEON_CN68XX))
 #define CHIP_FIELD(oct, TYPE, field)             \
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
index 7843b8a..36f1970 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
@@ -171,20 +171,36 @@ octnet_send_nic_ctrl_pkt(struct octeon_device *oct,
 	int retval;
 	struct octeon_soft_command *sc = NULL;
 
+	spin_lock_bh(&oct->cmd_resp_wqlock);
+	/* Allow only rx ctrl command to stop traffic on the chip
+	 * during offline operations
+	 */
+	if ((oct->cmd_resp_state == OCT_DRV_OFFLINE) &&
+	    (nctrl->ncmd.s.cmd != OCTNET_CMD_RX_CTL)) {
+		spin_unlock_bh(&oct->cmd_resp_wqlock);
+		dev_err(&oct->pci_dev->dev,
+			"%s cmd:%d not processed since driver offline\n",
+			__func__, nctrl->ncmd.s.cmd);
+		return -1;
+	}
+
 	sc = octnic_alloc_ctrl_pkt_sc(oct, nctrl);
 	if (!sc) {
 		dev_err(&oct->pci_dev->dev, "%s soft command alloc failed\n",
 			__func__);
+		spin_unlock_bh(&oct->cmd_resp_wqlock);
 		return -1;
 	}
 
 	retval = octeon_send_soft_command(oct, sc);
 	if (retval == IQ_SEND_FAILED) {
 		octeon_free_soft_command(oct, sc);
-		dev_err(&oct->pci_dev->dev, "%s soft command send failed status: %x\n",
-			__func__, retval);
+		dev_err(&oct->pci_dev->dev, "%s soft command:%d send failed status: %x\n",
+			__func__, nctrl->ncmd.s.cmd, retval);
+		spin_unlock_bh(&oct->cmd_resp_wqlock);
 		return -1;
 	}
 
+	spin_unlock_bh(&oct->cmd_resp_wqlock);
 	return retval;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.c b/drivers/net/ethernet/cavium/liquidio/response_manager.c
index e2e9103..c93210f 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.c
@@ -54,6 +54,7 @@ int octeon_setup_response_list(struct octeon_device *oct)
 		spin_lock_init(&oct->response_list[i].lock);
 		atomic_set(&oct->response_list[i].pending_req_count, 0);
 	}
+	spin_lock_init(&oct->cmd_resp_wqlock);
 
 	oct->dma_comp_wq.wq = alloc_workqueue("dma-comp", WQ_MEM_RECLAIM, 0);
 	if (!oct->dma_comp_wq.wq) {
@@ -64,6 +65,7 @@ int octeon_setup_response_list(struct octeon_device *oct)
 	cwq = &oct->dma_comp_wq;
 	INIT_DELAYED_WORK(&cwq->wk.work, oct_poll_req_completion);
 	cwq->wk.ctxptr = oct;
+	oct->cmd_resp_state = OCT_DRV_ONLINE;
 	queue_delayed_work(cwq->wq, &cwq->wk.work, msecs_to_jiffies(100));
 
 	return ret;
-- 
1.8.3.1
