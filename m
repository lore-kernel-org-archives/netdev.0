From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH v2 net-next 5/8] bnxt_en: Add port statistics support.
Date: Mon,  7 Mar 2016 15:38:45 -0500
Message-ID: <1457383128-28645-6-git-send-email-michael.chan@broadcom.com>
References: <1457383128-28645-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:16119
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753627AbcCGUiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 15:38:50 -0500
In-Reply-To: <1457383128-28645-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gather periodic port statistics if the device is PF and link is up.  This
is triggered in bnxt_timer() every one second to request firmware to DMA
the counters.

Signed-off-by: Michael Chan <michael.chan@broadocm.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 50 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 11 ++++++-
 2 files changed, 60 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 072a12f..c5e812a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2361,6 +2361,14 @@ static void bnxt_free_stats(struct bnxt *bp)
 	u32 size, i;
 	struct pci_dev *pdev = bp->pdev;
 
+	if (bp->hw_rx_port_stats) {
+		dma_free_coherent(&pdev->dev, bp->hw_port_stats_size,
+				  bp->hw_rx_port_stats,
+				  bp->hw_rx_port_stats_map);
+		bp->hw_rx_port_stats = NULL;
+		bp->flags &= ~BNXT_FLAG_PORT_STATS;
+	}
+
 	if (!bp->bnapi)
 		return;
 
@@ -2397,6 +2405,24 @@ static int bnxt_alloc_stats(struct bnxt *bp)
 
 		cpr->hw_stats_ctx_id = INVALID_STATS_CTX_ID;
 	}
+
+	if (BNXT_PF(bp)) {
+		bp->hw_port_stats_size = sizeof(struct rx_port_stats) +
+					 sizeof(struct tx_port_stats) + 1024;
+
+		bp->hw_rx_port_stats =
+			dma_alloc_coherent(&pdev->dev, bp->hw_port_stats_size,
+					   &bp->hw_rx_port_stats_map,
+					   GFP_KERNEL);
+		if (!bp->hw_rx_port_stats)
+			return -ENOMEM;
+
+		bp->hw_tx_port_stats = (void *)(bp->hw_rx_port_stats + 1) +
+				       512;
+		bp->hw_tx_port_stats_map = bp->hw_rx_port_stats_map +
+					   sizeof(struct rx_port_stats) + 512;
+		bp->flags |= BNXT_FLAG_PORT_STATS;
+	}
 	return 0;
 }
 
@@ -3833,6 +3859,23 @@ hwrm_ver_get_exit:
 	return rc;
 }
 
+static int bnxt_hwrm_port_qstats(struct bnxt *bp)
+{
+	int rc;
+	struct bnxt_pf_info *pf = &bp->pf;
+	struct hwrm_port_qstats_input req = {0};
+
+	if (!(bp->flags & BNXT_FLAG_PORT_STATS))
+		return 0;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_PORT_QSTATS, -1, -1);
+	req.port_id = cpu_to_le16(pf->port_id);
+	req.tx_stat_host_addr = cpu_to_le64(bp->hw_tx_port_stats_map);
+	req.rx_stat_host_addr = cpu_to_le64(bp->hw_rx_port_stats_map);
+	rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	return rc;
+}
+
 static void bnxt_hwrm_free_tunnel_ports(struct bnxt *bp)
 {
 	if (bp->vxlan_port_cnt) {
@@ -5231,6 +5274,10 @@ static void bnxt_timer(unsigned long data)
 	if (atomic_read(&bp->intr_sem) != 0)
 		goto bnxt_restart_timer;
 
+	if (bp->link_info.link_up && (bp->flags & BNXT_FLAG_PORT_STATS)) {
+		set_bit(BNXT_PERIODIC_STATS_SP_EVENT, &bp->sp_event);
+		schedule_work(&bp->sp_task);
+	}
 bnxt_restart_timer:
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
 }
@@ -5282,6 +5329,9 @@ static void bnxt_sp_task(struct work_struct *work)
 		rtnl_unlock();
 	}
 
+	if (test_and_clear_bit(BNXT_PERIODIC_STATS_SP_EVENT, &bp->sp_event))
+		bnxt_hwrm_port_qstats(bp);
+
 	smp_mb__before_atomic();
 	clear_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
 }
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index c4424b6..ec04c47 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -873,6 +873,7 @@ struct bnxt {
 	#define BNXT_FLAG_MSIX_CAP	0x80
 	#define BNXT_FLAG_RFS		0x100
 	#define BNXT_FLAG_SHARED_RINGS	0x200
+	#define BNXT_FLAG_PORT_STATS	0x400
 
 	#define BNXT_FLAG_ALL_CONFIG_FEATS (BNXT_FLAG_TPA |		\
 					    BNXT_FLAG_RFS |		\
@@ -925,7 +926,7 @@ struct bnxt {
 	struct bnxt_queue_info	q_info[BNXT_MAX_QUEUE];
 
 	unsigned int		current_interval;
-#define BNXT_TIMER_INTERVAL	(HZ / 2)
+#define BNXT_TIMER_INTERVAL	HZ
 
 	struct timer_list	timer;
 
@@ -945,6 +946,13 @@ struct bnxt {
 	void			*hwrm_dbg_resp_addr;
 	dma_addr_t		hwrm_dbg_resp_dma_addr;
 #define HWRM_DBG_REG_BUF_SIZE	128
+
+	struct rx_port_stats	*hw_rx_port_stats;
+	struct tx_port_stats	*hw_tx_port_stats;
+	dma_addr_t		hw_rx_port_stats_map;
+	dma_addr_t		hw_tx_port_stats_map;
+	int			hw_port_stats_size;
+
 	int			hwrm_cmd_timeout;
 	struct mutex		hwrm_cmd_lock;	/* serialize hwrm messages */
 	struct hwrm_ver_get_output	ver_resp;
@@ -980,6 +988,7 @@ struct bnxt {
 #define BNXT_RESET_TASK_SP_EVENT	6
 #define BNXT_RST_RING_SP_EVENT		7
 #define BNXT_HWRM_PF_UNLOAD_SP_EVENT	8
+#define BNXT_PERIODIC_STATS_SP_EVENT	9
 
 	struct bnxt_pf_info	pf;
 #ifdef CONFIG_BNXT_SRIOV
-- 
1.8.3.1
