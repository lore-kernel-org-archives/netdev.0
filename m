From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 1/9] be2net: move adapter fields alloc/free code to new routines
Date: Mon, 23 Feb 2015 04:20:08 -0500
Message-ID: <1424683216-29611-2-git-send-email-sathya.perla@emulex.com>
References: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:5932 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752623AbbBWJRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 04:17:19 -0500
In-Reply-To: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The members of be_adapter struct were being allocated in two separate
routines -- be_ctrl_init() and be_stats_init(). Also, some other members
were allocated elsewhere. This patch moves the alloc/free code into
be_drv_init/cleanup() routines. The be_pci_map_bars() routine that was
called from be_ctrl_init() is now called directly from be_probe().
The new routine be_drv_init() will now be the place-holder for allocating
memory for any new be_adapter{} members in the future.
Some routines needed to be moved to provide forward definitions for their
calls.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 408 +++++++++++++---------------
 1 file changed, 195 insertions(+), 213 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c1553fb..ae8ad55 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4878,6 +4878,130 @@ static void be_netdev_init(struct net_device *netdev)
 	netdev->ethtool_ops = &be_ethtool_ops;
 }
 
+static int lancer_recover_func(struct be_adapter *adapter)
+{
+	struct device *dev = &adapter->pdev->dev;
+	int status;
+
+	status = lancer_test_and_set_rdy_state(adapter);
+	if (status)
+		goto err;
+
+	if (netif_running(adapter->netdev))
+		be_close(adapter->netdev);
+
+	be_clear(adapter);
+
+	be_clear_all_error(adapter);
+
+	status = be_setup(adapter);
+	if (status)
+		goto err;
+
+	if (netif_running(adapter->netdev)) {
+		status = be_open(adapter->netdev);
+		if (status)
+			goto err;
+	}
+
+	dev_err(dev, "Adapter recovery successful\n");
+	return 0;
+err:
+	if (status == -EAGAIN)
+		dev_err(dev, "Waiting for resource provisioning\n");
+	else
+		dev_err(dev, "Adapter recovery failed\n");
+
+	return status;
+}
+
+static void be_func_recovery_task(struct work_struct *work)
+{
+	struct be_adapter *adapter =
+		container_of(work, struct be_adapter, func_recovery_work.work);
+	int status = 0;
+
+	be_detect_error(adapter);
+
+	if (adapter->hw_error && lancer_chip(adapter)) {
+		rtnl_lock();
+		netif_device_detach(adapter->netdev);
+		rtnl_unlock();
+
+		status = lancer_recover_func(adapter);
+		if (!status)
+			netif_device_attach(adapter->netdev);
+	}
+
+	/* In Lancer, for all errors other than provisioning error (-EAGAIN),
+	 * no need to attempt further recovery.
+	 */
+	if (!status || status == -EAGAIN)
+		schedule_delayed_work(&adapter->func_recovery_work,
+				      msecs_to_jiffies(1000));
+}
+
+static void be_log_sfp_info(struct be_adapter *adapter)
+{
+	int status;
+
+	status = be_cmd_query_sfp_info(adapter);
+	if (!status) {
+		dev_err(&adapter->pdev->dev,
+			"Unqualified SFP+ detected on %c from %s part no: %s",
+			adapter->port_name, adapter->phy.vendor_name,
+			adapter->phy.vendor_pn);
+	}
+	adapter->flags &= ~BE_FLAGS_EVT_INCOMPATIBLE_SFP;
+}
+
+static void be_worker(struct work_struct *work)
+{
+	struct be_adapter *adapter =
+		container_of(work, struct be_adapter, work.work);
+	struct be_rx_obj *rxo;
+	int i;
+
+	/* when interrupts are not yet enabled, just reap any pending
+	 * mcc completions
+	 */
+	if (!netif_running(adapter->netdev)) {
+		local_bh_disable();
+		be_process_mcc(adapter);
+		local_bh_enable();
+		goto reschedule;
+	}
+
+	if (!adapter->stats_cmd_sent) {
+		if (lancer_chip(adapter))
+			lancer_cmd_get_pport_stats(adapter,
+						   &adapter->stats_cmd);
+		else
+			be_cmd_get_stats(adapter, &adapter->stats_cmd);
+	}
+
+	if (be_physfn(adapter) &&
+	    MODULO(adapter->work_counter, adapter->be_get_temp_freq) == 0)
+		be_cmd_get_die_temperature(adapter);
+
+	for_all_rx_queues(adapter, rxo, i) {
+		/* Replenish RX-queues starved due to memory
+		 * allocation failures.
+		 */
+		if (rxo->rx_post_starved)
+			be_post_rx_frags(rxo, GFP_KERNEL, MAX_RX_POST);
+	}
+
+	be_eqd_update(adapter);
+
+	if (adapter->flags & BE_FLAGS_EVT_INCOMPATIBLE_SFP)
+		be_log_sfp_info(adapter);
+
+reschedule:
+	adapter->work_counter++;
+	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
+}
+
 static void be_unmap_pci_bars(struct be_adapter *adapter)
 {
 	if (adapter->csr)
@@ -4909,6 +5033,12 @@ static int be_roce_map_pci_bars(struct be_adapter *adapter)
 static int be_map_pci_bars(struct be_adapter *adapter)
 {
 	u8 __iomem *addr;
+	u32 sli_intf;
+
+	pci_read_config_dword(adapter->pdev, SLI_INTF_REG_OFFSET, &sli_intf);
+	adapter->sli_family = (sli_intf & SLI_INTF_FAMILY_MASK) >>
+				SLI_INTF_FAMILY_SHIFT;
+	adapter->virtfn = (sli_intf & SLI_INTF_FT_MASK) ? 1 : 0;
 
 	if (BEx_chip(adapter) && be_physfn(adapter)) {
 		adapter->csr = pci_iomap(adapter->pdev, 2, 0);
@@ -4930,109 +5060,93 @@ pci_map_err:
 	return -ENOMEM;
 }
 
-static void be_ctrl_cleanup(struct be_adapter *adapter)
+static void be_drv_cleanup(struct be_adapter *adapter)
 {
 	struct be_dma_mem *mem = &adapter->mbox_mem_alloced;
-
-	be_unmap_pci_bars(adapter);
+	struct device *dev = &adapter->pdev->dev;
 
 	if (mem->va)
-		dma_free_coherent(&adapter->pdev->dev, mem->size, mem->va,
-				  mem->dma);
+		dma_free_coherent(dev, mem->size, mem->va, mem->dma);
 
 	mem = &adapter->rx_filter;
 	if (mem->va)
-		dma_free_coherent(&adapter->pdev->dev, mem->size, mem->va,
-				  mem->dma);
+		dma_free_coherent(dev, mem->size, mem->va, mem->dma);
+
+	mem = &adapter->stats_cmd;
+	if (mem->va)
+		dma_free_coherent(dev, mem->size, mem->va, mem->dma);
 }
 
-static int be_ctrl_init(struct be_adapter *adapter)
+/* Allocate and initialize various fields in be_adapter struct */
+static int be_drv_init(struct be_adapter *adapter)
 {
 	struct be_dma_mem *mbox_mem_alloc = &adapter->mbox_mem_alloced;
 	struct be_dma_mem *mbox_mem_align = &adapter->mbox_mem;
 	struct be_dma_mem *rx_filter = &adapter->rx_filter;
-	u32 sli_intf;
-	int status;
-
-	pci_read_config_dword(adapter->pdev, SLI_INTF_REG_OFFSET, &sli_intf);
-	adapter->sli_family = (sli_intf & SLI_INTF_FAMILY_MASK) >>
-				 SLI_INTF_FAMILY_SHIFT;
-	adapter->virtfn = (sli_intf & SLI_INTF_FT_MASK) ? 1 : 0;
-
-	status = be_map_pci_bars(adapter);
-	if (status)
-		goto done;
+	struct be_dma_mem *stats_cmd = &adapter->stats_cmd;
+	struct device *dev = &adapter->pdev->dev;
+	int status = 0;
 
 	mbox_mem_alloc->size = sizeof(struct be_mcc_mailbox) + 16;
-	mbox_mem_alloc->va = dma_alloc_coherent(&adapter->pdev->dev,
-						mbox_mem_alloc->size,
+	mbox_mem_alloc->va = dma_alloc_coherent(dev, mbox_mem_alloc->size,
 						&mbox_mem_alloc->dma,
 						GFP_KERNEL);
-	if (!mbox_mem_alloc->va) {
-		status = -ENOMEM;
-		goto unmap_pci_bars;
-	}
+	if (!mbox_mem_alloc->va)
+		return -ENOMEM;
+
 	mbox_mem_align->size = sizeof(struct be_mcc_mailbox);
 	mbox_mem_align->va = PTR_ALIGN(mbox_mem_alloc->va, 16);
 	mbox_mem_align->dma = PTR_ALIGN(mbox_mem_alloc->dma, 16);
 	memset(mbox_mem_align->va, 0, sizeof(struct be_mcc_mailbox));
 
 	rx_filter->size = sizeof(struct be_cmd_req_rx_filter);
-	rx_filter->va = dma_zalloc_coherent(&adapter->pdev->dev,
-					    rx_filter->size, &rx_filter->dma,
-					    GFP_KERNEL);
+	rx_filter->va = dma_zalloc_coherent(dev, rx_filter->size,
+					    &rx_filter->dma, GFP_KERNEL);
 	if (!rx_filter->va) {
 		status = -ENOMEM;
 		goto free_mbox;
 	}
 
+	if (lancer_chip(adapter))
+		stats_cmd->size = sizeof(struct lancer_cmd_req_pport_stats);
+	else if (BE2_chip(adapter))
+		stats_cmd->size = sizeof(struct be_cmd_req_get_stats_v0);
+	else if (BE3_chip(adapter))
+		stats_cmd->size = sizeof(struct be_cmd_req_get_stats_v1);
+	else
+		stats_cmd->size = sizeof(struct be_cmd_req_get_stats_v2);
+	stats_cmd->va = dma_zalloc_coherent(dev, stats_cmd->size,
+					    &stats_cmd->dma, GFP_KERNEL);
+	if (!stats_cmd->va) {
+		status = -ENOMEM;
+		goto free_rx_filter;
+	}
+
 	mutex_init(&adapter->mbox_lock);
 	spin_lock_init(&adapter->mcc_lock);
 	spin_lock_init(&adapter->mcc_cq_lock);
-
 	init_completion(&adapter->et_cmd_compl);
-	pci_save_state(adapter->pdev);
-	return 0;
-
-free_mbox:
-	dma_free_coherent(&adapter->pdev->dev, mbox_mem_alloc->size,
-			  mbox_mem_alloc->va, mbox_mem_alloc->dma);
 
-unmap_pci_bars:
-	be_unmap_pci_bars(adapter);
-
-done:
-	return status;
-}
-
-static void be_stats_cleanup(struct be_adapter *adapter)
-{
-	struct be_dma_mem *cmd = &adapter->stats_cmd;
+	pci_save_state(adapter->pdev);
 
-	if (cmd->va)
-		dma_free_coherent(&adapter->pdev->dev, cmd->size,
-				  cmd->va, cmd->dma);
-}
+	INIT_DELAYED_WORK(&adapter->work, be_worker);
+	INIT_DELAYED_WORK(&adapter->func_recovery_work, be_func_recovery_task);
 
-static int be_stats_init(struct be_adapter *adapter)
-{
-	struct be_dma_mem *cmd = &adapter->stats_cmd;
+	adapter->rx_fc = true;
+	adapter->tx_fc = true;
 
-	if (lancer_chip(adapter))
-		cmd->size = sizeof(struct lancer_cmd_req_pport_stats);
-	else if (BE2_chip(adapter))
-		cmd->size = sizeof(struct be_cmd_req_get_stats_v0);
-	else if (BE3_chip(adapter))
-		cmd->size = sizeof(struct be_cmd_req_get_stats_v1);
-	else
-		/* ALL non-BE ASICs */
-		cmd->size = sizeof(struct be_cmd_req_get_stats_v2);
+	/* Must be a power of 2 or else MODULO will BUG_ON */
+	adapter->be_get_temp_freq = 64;
+	adapter->cfg_num_qs = netif_get_num_default_rss_queues();
 
-	cmd->va = dma_zalloc_coherent(&adapter->pdev->dev, cmd->size, &cmd->dma,
-				      GFP_KERNEL);
-	if (!cmd->va)
-		return -ENOMEM;
 	return 0;
+
+free_rx_filter:
+	dma_free_coherent(dev, rx_filter->size, rx_filter->va, rx_filter->dma);
+free_mbox:
+	dma_free_coherent(dev, mbox_mem_alloc->size, mbox_mem_alloc->va,
+			  mbox_mem_alloc->dma);
+	return status;
 }
 
 static void be_remove(struct pci_dev *pdev)
@@ -5054,9 +5168,8 @@ static void be_remove(struct pci_dev *pdev)
 	/* tell fw we're done with firing cmds */
 	be_cmd_fw_clean(adapter);
 
-	be_stats_cleanup(adapter);
-
-	be_ctrl_cleanup(adapter);
+	be_unmap_pci_bars(adapter);
+	be_drv_cleanup(adapter);
 
 	pci_disable_pcie_error_reporting(pdev);
 
@@ -5074,141 +5187,15 @@ static int be_get_initial_config(struct be_adapter *adapter)
 	if (status)
 		return status;
 
-	/* Must be a power of 2 or else MODULO will BUG_ON */
-	adapter->be_get_temp_freq = 64;
-
 	if (BEx_chip(adapter)) {
 		level = be_cmd_get_fw_log_level(adapter);
 		adapter->msg_enable =
 			level <= FW_LOG_LEVEL_DEFAULT ? NETIF_MSG_HW : 0;
 	}
 
-	adapter->cfg_num_qs = netif_get_num_default_rss_queues();
-	return 0;
-}
-
-static int lancer_recover_func(struct be_adapter *adapter)
-{
-	struct device *dev = &adapter->pdev->dev;
-	int status;
-
-	status = lancer_test_and_set_rdy_state(adapter);
-	if (status)
-		goto err;
-
-	if (netif_running(adapter->netdev))
-		be_close(adapter->netdev);
-
-	be_clear(adapter);
-
-	be_clear_all_error(adapter);
-
-	status = be_setup(adapter);
-	if (status)
-		goto err;
-
-	if (netif_running(adapter->netdev)) {
-		status = be_open(adapter->netdev);
-		if (status)
-			goto err;
-	}
-
-	dev_err(dev, "Adapter recovery successful\n");
 	return 0;
-err:
-	if (status == -EAGAIN)
-		dev_err(dev, "Waiting for resource provisioning\n");
-	else
-		dev_err(dev, "Adapter recovery failed\n");
-
-	return status;
 }
 
-static void be_func_recovery_task(struct work_struct *work)
-{
-	struct be_adapter *adapter =
-		container_of(work, struct be_adapter,  func_recovery_work.work);
-	int status = 0;
-
-	be_detect_error(adapter);
-
-	if (adapter->hw_error && lancer_chip(adapter)) {
-		rtnl_lock();
-		netif_device_detach(adapter->netdev);
-		rtnl_unlock();
-
-		status = lancer_recover_func(adapter);
-		if (!status)
-			netif_device_attach(adapter->netdev);
-	}
-
-	/* In Lancer, for all errors other than provisioning error (-EAGAIN),
-	 * no need to attempt further recovery.
-	 */
-	if (!status || status == -EAGAIN)
-		schedule_delayed_work(&adapter->func_recovery_work,
-				      msecs_to_jiffies(1000));
-}
-
-static void be_log_sfp_info(struct be_adapter *adapter)
-{
-	int status;
-
-	status = be_cmd_query_sfp_info(adapter);
-	if (!status) {
-		dev_err(&adapter->pdev->dev,
-			"Unqualified SFP+ detected on %c from %s part no: %s",
-			adapter->port_name, adapter->phy.vendor_name,
-			adapter->phy.vendor_pn);
-	}
-	adapter->flags &= ~BE_FLAGS_EVT_INCOMPATIBLE_SFP;
-}
-
-static void be_worker(struct work_struct *work)
-{
-	struct be_adapter *adapter =
-		container_of(work, struct be_adapter, work.work);
-	struct be_rx_obj *rxo;
-	int i;
-
-	/* when interrupts are not yet enabled, just reap any pending
-	* mcc completions */
-	if (!netif_running(adapter->netdev)) {
-		local_bh_disable();
-		be_process_mcc(adapter);
-		local_bh_enable();
-		goto reschedule;
-	}
-
-	if (!adapter->stats_cmd_sent) {
-		if (lancer_chip(adapter))
-			lancer_cmd_get_pport_stats(adapter,
-						   &adapter->stats_cmd);
-		else
-			be_cmd_get_stats(adapter, &adapter->stats_cmd);
-	}
-
-	if (be_physfn(adapter) &&
-	    MODULO(adapter->work_counter, adapter->be_get_temp_freq) == 0)
-		be_cmd_get_die_temperature(adapter);
-
-	for_all_rx_queues(adapter, rxo, i) {
-		/* Replenish RX-queues starved due to memory
-		 * allocation failures.
-		 */
-		if (rxo->rx_post_starved)
-			be_post_rx_frags(rxo, GFP_KERNEL, MAX_RX_POST);
-	}
-
-	be_eqd_update(adapter);
-
-	if (adapter->flags & BE_FLAGS_EVT_INCOMPATIBLE_SFP)
-		be_log_sfp_info(adapter);
-
-reschedule:
-	adapter->work_counter++;
-	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
-}
 
 /* If any VFs are already enabled don't FLR the PF */
 static bool be_reset_required(struct be_adapter *adapter)
@@ -5314,21 +5301,25 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 	if (!status)
 		dev_info(&pdev->dev, "PCIe error reporting enabled\n");
 
-	status = be_ctrl_init(adapter);
+	status = be_map_pci_bars(adapter);
 	if (status)
 		goto free_netdev;
 
+	status = be_drv_init(adapter);
+	if (status)
+		goto unmap_bars;
+
 	/* sync up with fw's ready state */
 	if (be_physfn(adapter)) {
 		status = be_fw_wait_ready(adapter);
 		if (status)
-			goto ctrl_clean;
+			goto drv_cleanup;
 	}
 
 	if (be_reset_required(adapter)) {
 		status = be_cmd_reset_function(adapter);
 		if (status)
-			goto ctrl_clean;
+			goto drv_cleanup;
 
 		/* Wait for interrupts to quiesce after an FLR */
 		msleep(100);
@@ -5340,24 +5331,15 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 	/* tell fw we're ready to fire cmds */
 	status = be_cmd_fw_init(adapter);
 	if (status)
-		goto ctrl_clean;
-
-	status = be_stats_init(adapter);
-	if (status)
-		goto ctrl_clean;
+		goto drv_cleanup;
 
 	status = be_get_initial_config(adapter);
 	if (status)
-		goto stats_clean;
-
-	INIT_DELAYED_WORK(&adapter->work, be_worker);
-	INIT_DELAYED_WORK(&adapter->func_recovery_work, be_func_recovery_task);
-	adapter->rx_fc = true;
-	adapter->tx_fc = true;
+		goto drv_cleanup;
 
 	status = be_setup(adapter);
 	if (status)
-		goto stats_clean;
+		goto drv_cleanup;
 
 	be_netdev_init(netdev);
 	status = register_netdev(netdev);
@@ -5376,10 +5358,10 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 
 unsetup:
 	be_clear(adapter);
-stats_clean:
-	be_stats_cleanup(adapter);
-ctrl_clean:
-	be_ctrl_cleanup(adapter);
+drv_cleanup:
+	be_drv_cleanup(adapter);
+unmap_bars:
+	be_unmap_pci_bars(adapter);
 free_netdev:
 	free_netdev(netdev);
 rel_reg:
-- 
2.2.0
