From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 1/7 2.6.28] cxgb3 - reset the adapter on fatal error
Date: Wed, 08 Oct 2008 17:33:57 -0700
Message-ID: <20081009003356.13282.25797.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:24395 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818AbYJIAeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 20:34:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

when a fatal error occurs, bring ports down, reset the chip,
and bring ports back up.

Factorize code used for both EEH and fatal error recovery.
Fix timer usage when bringing up/resetting sge queue sets.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h    |    1 
 drivers/net/cxgb3/common.h     |    1 
 drivers/net/cxgb3/cxgb3_main.c |  164 +++++++++++++++++++++++++++-------------
 drivers/net/cxgb3/sge.c        |    9 +-
 drivers/net/cxgb3/t3_hw.c      |    4 -
 5 files changed, 119 insertions(+), 60 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index e9da285..02dd69b 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -240,6 +240,7 @@ struct adapter {
 	unsigned int check_task_cnt;
 	struct delayed_work adap_check_task;
 	struct work_struct ext_intr_handler_task;
+	struct work_struct fatal_error_handler_task;
 
 	struct dentry *debugfs_root;
 
diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 9ecf8a6..d6dbcd4 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -698,6 +698,7 @@ int t3_check_fw_version(struct adapter *adapter, int *must_load);
 int t3_init_hw(struct adapter *adapter, u32 fw_params);
 void mac_prep(struct cmac *mac, struct adapter *adapter, int index);
 void early_hw_init(struct adapter *adapter, const struct adapter_info *ai);
+int t3_reset_adapter(struct adapter *adapter);
 int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
 		    int reset);
 int t3_replay_prep_adapter(struct adapter *adapter);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index d355c82..0e51d49 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -892,6 +892,13 @@ static int cxgb_up(struct adapter *adap)
 				goto out;
 		}
 
+		/*
+		 * Clear interrupts now to catch errors if t3_init_hw fails.
+		 * We clear them again later as initialization may trigger
+		 * conditions that can interrupt.
+		 */
+		t3_intr_clear(adap);
+
 		err = t3_init_hw(adap, 0);
 		if (err)
 			goto out;
@@ -1101,9 +1108,9 @@ static int cxgb_close(struct net_device *dev)
 	netif_carrier_off(dev);
 	t3_mac_disable(&pi->mac, MAC_DIRECTION_TX | MAC_DIRECTION_RX);
 
-	spin_lock(&adapter->work_lock);	/* sync with update task */
+	spin_lock_irq(&adapter->work_lock);	/* sync with update task */
 	clear_bit(pi->port_id, &adapter->open_device_map);
-	spin_unlock(&adapter->work_lock);
+	spin_unlock_irq(&adapter->work_lock);
 
 	if (!(adapter->open_device_map & PORT_MASK))
 		cancel_rearming_delayed_workqueue(cxgb3_wq,
@@ -2356,10 +2363,10 @@ static void t3_adap_check_task(struct work_struct *work)
 		check_t3b2_mac(adapter);
 
 	/* Schedule the next check update if any port is active. */
-	spin_lock(&adapter->work_lock);
+	spin_lock_irq(&adapter->work_lock);
 	if (adapter->open_device_map & PORT_MASK)
 		schedule_chk_task(adapter);
-	spin_unlock(&adapter->work_lock);
+	spin_unlock_irq(&adapter->work_lock);
 }
 
 /*
@@ -2404,6 +2411,96 @@ void t3_os_ext_intr_handler(struct adapter *adapter)
 	spin_unlock(&adapter->work_lock);
 }
 
+static int t3_adapter_error(struct adapter *adapter, int reset)
+{
+	int i, ret = 0;
+
+	/* Stop all ports */
+	for_each_port(adapter, i) {
+		struct net_device *netdev = adapter->port[i];
+
+		if (netif_running(netdev))
+			cxgb_close(netdev);
+	}
+
+	if (is_offload(adapter) &&
+	    test_bit(OFFLOAD_DEVMAP_BIT, &adapter->open_device_map))
+		offload_close(&adapter->tdev);
+
+	/* Stop SGE timers */
+	t3_stop_sge_timers(adapter);
+
+	adapter->flags &= ~FULL_INIT_DONE;
+
+	if (reset)
+		ret = t3_reset_adapter(adapter);
+
+	pci_disable_device(adapter->pdev);
+
+	return ret;
+}
+
+static int t3_reenable_adapter(struct adapter *adapter)
+{
+	if (pci_enable_device(adapter->pdev)) {
+		dev_err(&adapter->pdev->dev,
+			"Cannot re-enable PCI device after reset.\n");
+		goto err;
+	}
+	pci_set_master(adapter->pdev);
+	pci_restore_state(adapter->pdev);
+
+	/* Free sge resources */
+	t3_free_sge_resources(adapter);
+
+	if (t3_replay_prep_adapter(adapter))
+		goto err;
+
+	return 0;
+err:
+	return -1;
+}
+
+static void t3_resume_ports(struct adapter *adapter)
+{
+	int i;
+
+	/* Restart the ports */
+	for_each_port(adapter, i) {
+		struct net_device *netdev = adapter->port[i];
+
+		if (netif_running(netdev)) {
+			if (cxgb_open(netdev)) {
+				dev_err(&adapter->pdev->dev,
+					"can't bring device back up"
+					" after reset\n");
+				continue;
+			}
+		}
+	}
+}
+
+/*
+ * processes a fatal error.
+ * Bring the ports down, reset the chip, bring the ports back up.
+ */
+static void fatal_error_task(struct work_struct *work)
+{
+	struct adapter *adapter = container_of(work, struct adapter,
+					       fatal_error_handler_task);
+	int err = 0;
+
+	rtnl_lock();
+	err = t3_adapter_error(adapter, 1);
+	if (!err)
+		err = t3_reenable_adapter(adapter);
+	if (!err)
+		t3_resume_ports(adapter);
+
+	CH_ALERT(adapter, "adapter reset %s\n", err ? "failed" : "succeeded");
+	rtnl_unlock();
+}
+
 void t3_fatal_err(struct adapter *adapter)
 {
 	unsigned int fw_status[4];
@@ -2414,7 +2511,11 @@ void t3_fatal_err(struct adapter *adapter)
 		t3_write_reg(adapter, A_XGM_RX_CTRL, 0);
 		t3_write_reg(adapter, XGM_REG(A_XGM_TX_CTRL, 1), 0);
 		t3_write_reg(adapter, XGM_REG(A_XGM_RX_CTRL, 1), 0);
+
+		spin_lock(&adapter->work_lock);
 		t3_intr_disable(adapter);
+		queue_work(cxgb3_wq, &adapter->fatal_error_handler_task);
+		spin_unlock(&adapter->work_lock);
 	}
 	CH_ALERT(adapter, "encountered fatal error, operation suspended\n");
 	if (!t3_cim_ctl_blk_read(adapter, 0xa0, 4, fw_status))
@@ -2436,26 +2537,9 @@ static pci_ers_result_t t3_io_error_detected(struct pci_dev *pdev,
 					     pci_channel_state_t state)
 {
 	struct adapter *adapter = pci_get_drvdata(pdev);
-	int i;
-
-	/* Stop all ports */
-	for_each_port(adapter, i) {
-		struct net_device *netdev = adapter->port[i];
-
-		if (netif_running(netdev))
-			cxgb_close(netdev);
-	}
-
-	if (is_offload(adapter) &&
-	    test_bit(OFFLOAD_DEVMAP_BIT, &adapter->open_device_map))
-		offload_close(&adapter->tdev);
-
-	/* Stop SGE timers */
-	t3_stop_sge_timers(adapter);
-
-	adapter->flags &= ~FULL_INIT_DONE;
+	int ret;
 
-	pci_disable_device(pdev);
+	ret = t3_adapter_error(adapter, 0);
 
 	/* Request a slot reset. */
 	return PCI_ERS_RESULT_NEED_RESET;
@@ -2471,22 +2555,9 @@ static pci_ers_result_t t3_io_slot_reset(struct pci_dev *pdev)
 {
 	struct adapter *adapter = pci_get_drvdata(pdev);
 
-	if (pci_enable_device(pdev)) {
-		dev_err(&pdev->dev,
-			"Cannot re-enable PCI device after reset.\n");
-		goto err;
-	}
-	pci_set_master(pdev);
-	pci_restore_state(pdev);
-
-	/* Free sge resources */
-	t3_free_sge_resources(adapter);
-
-	if (t3_replay_prep_adapter(adapter))
-		goto err;
+	if (!t3_reenable_adapter(adapter))
+		return PCI_ERS_RESULT_RECOVERED;
 
-	return PCI_ERS_RESULT_RECOVERED;
-err:
 	return PCI_ERS_RESULT_DISCONNECT;
 }
 
@@ -2500,22 +2571,8 @@ err:
 static void t3_io_resume(struct pci_dev *pdev)
 {
 	struct adapter *adapter = pci_get_drvdata(pdev);
-	int i;
-
-	/* Restart the ports */
-	for_each_port(adapter, i) {
-		struct net_device *netdev = adapter->port[i];
 
-		if (netif_running(netdev)) {
-			if (cxgb_open(netdev)) {
-				dev_err(&pdev->dev,
-					"can't bring device back up"
-					" after reset\n");
-				continue;
-			}
-			netif_device_attach(netdev);
-		}
-	}
+	t3_resume_ports(adapter);
 }
 
 static struct pci_error_handlers t3_err_handler = {
@@ -2664,6 +2721,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 	INIT_LIST_HEAD(&adapter->adapter_list);
 	INIT_WORK(&adapter->ext_intr_handler_task, ext_intr_task);
+	INIT_WORK(&adapter->fatal_error_handler_task, fatal_error_task);
 	INIT_DELAYED_WORK(&adapter->adap_check_task, t3_adap_check_task);
 
 	for (i = 0; i < ai->nports; ++i) {
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 7346a8e..8791941 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -351,7 +351,8 @@ static void free_rx_bufs(struct pci_dev *pdev, struct sge_fl *q)
 		pci_unmap_single(pdev, pci_unmap_addr(d, dma_addr),
 				 q->buf_size, PCI_DMA_FROMDEVICE);
 		if (q->use_pages) {
-			put_page(d->pg_chunk.page);
+			if (d->pg_chunk.page)
+				put_page(d->pg_chunk.page);
 			d->pg_chunk.page = NULL;
 		} else {
 			kfree_skb(d->skb);
@@ -583,7 +584,7 @@ static void t3_reset_qset(struct sge_qset *q)
 	memset(q->fl, 0, sizeof(struct sge_fl) * SGE_RXQ_PER_SET);
 	memset(q->txq, 0, sizeof(struct sge_txq) * SGE_TXQ_PER_SET);
 	q->txq_stopped = 0;
-	memset(&q->tx_reclaim_timer, 0, sizeof(q->tx_reclaim_timer));
+	q->tx_reclaim_timer.function = NULL; /* for t3_stop_sge_timers() */
 	kfree(q->lro_frag_tbl);
 	q->lro_nfrags = q->lro_frag_len = 0;
 }
@@ -2840,9 +2841,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	struct net_lro_mgr *lro_mgr = &q->lro_mgr;
 
 	init_qset_cntxt(q, id);
-	init_timer(&q->tx_reclaim_timer);
-	q->tx_reclaim_timer.data = (unsigned long)q;
-	q->tx_reclaim_timer.function = sge_timer_cb;
+	setup_timer(&q->tx_reclaim_timer, sge_timer_cb, (unsigned long)q);
 
 	q->fl[0].desc = alloc_ring(adapter->pdev, p->fl_size,
 				   sizeof(struct rx_desc),
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 04c0e90..33470c7 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -1221,7 +1221,7 @@ struct intr_info {
 	unsigned int mask;	/* bits to check in interrupt status */
 	const char *msg;	/* message to print or NULL */
 	short stat_idx;		/* stat counter to increment or -1 */
-	unsigned short fatal:1;	/* whether the condition reported is fatal */
+	unsigned short fatal;	/* whether the condition reported is fatal */
 };
 
 /**
@@ -3488,7 +3488,7 @@ void early_hw_init(struct adapter *adapter, const struct adapter_info *ai)
  * Older PCIe cards lose their config space during reset, PCI-X
  * ones don't.
  */
-static int t3_reset_adapter(struct adapter *adapter)
+int t3_reset_adapter(struct adapter *adapter)
 {
 	int i, save_and_restore_pcie =
 	    adapter->params.rev < T3_REV_B2 && is_pcie(adapter);

