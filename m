From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 2.6.25 8/12][BNX2X]: fix slowpath races and locking
Date: Wed, 27 Feb 2008 14:24:56 +0200
Message-ID: <1204115096.8232.363.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, jeff@garzik.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4622 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754641AbYB0Mbu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 07:31:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2X]: fix slowpath races and locking

Fixed locking between fastpath and slowpath operations.
Corrected order of traffic disabling to prevent race when going down under traffic. 
- first have the microcode drop all incoming packets
- then do the slowpath stuff
- only then reset the MAC
Got rid of in_reset_task.
Remove_one() and friends would deference a null pointer if init_one failed. 

Signed-off-by: Eliezer Tamir <eliezert@broadcom.com>
---
 drivers/net/bnx2x.c |  213 ++++++++++++++++++++++++++++-----------------------
 drivers/net/bnx2x.h |    3 -
 2 files changed, 116 insertions(+), 100 deletions(-)

diff --git a/drivers/net/bnx2x.c b/drivers/net/bnx2x.c
index b99e3b7..d21599c 100644
--- a/drivers/net/bnx2x.c
+++ b/drivers/net/bnx2x.c
@@ -6881,14 +6881,11 @@ static void bnx2x_free_msix_irqs(struct bnx2x *bp)
 		   "state(%x)\n", i, bp->msix_table[i + 1].vector,
 		   bnx2x_fp(bp, i, state));
 
-		if (bnx2x_fp(bp, i, state) != BNX2X_FP_STATE_CLOSED) {
-
-			free_irq(bp->msix_table[i + 1].vector, &bp->fp[i]);
-			bnx2x_fp(bp, i, state) = BNX2X_FP_STATE_CLOSED;
-
-		} else
-			DP(NETIF_MSG_IFDOWN, "irq not freed\n");
+		if (bnx2x_fp(bp, i, state) != BNX2X_FP_STATE_CLOSED)
+			BNX2X_ERR("IRQ of fp #%d being freed while "
+				  "state != closed\n", i);
 
+		free_irq(bp->msix_table[i + 1].vector, &bp->fp[i]);
 	}
 
 }
@@ -6918,7 +6915,7 @@ static int bnx2x_enable_msix(struct bnx2x *bp)
 
 	if (pci_enable_msix(bp->pdev, &bp->msix_table[0],
 				     bp->num_queues + 1)){
-		BNX2X_ERR("failed to enable msix\n");
+		BNX2X_LOG("failed to enable MSI-X\n");
 		return -1;
 
 	}
@@ -6935,8 +6932,6 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 
 	int i, rc;
 
-	DP(NETIF_MSG_IFUP, "about to request sp irq\n");
-
 	rc = request_irq(bp->msix_table[0].vector, bnx2x_msix_sp_int, 0,
 			 bp->dev->name, bp->dev);
 
@@ -6951,7 +6946,8 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 				 bp->dev->name, &bp->fp[i]);
 
 		if (rc) {
-			BNX2X_ERR("request fp #%d irq failed\n", i);
+			BNX2X_ERR("request fp #%d irq failed  "
+				  "rc %d\n", i, rc);
 			bnx2x_free_msix_irqs(bp);
 			return -EBUSY;
 		}
@@ -7084,12 +7080,13 @@ static int bnx2x_setup_multi(struct bnx2x *bp, int index)
 	/* reset IGU state */
 	bnx2x_ack_sb(bp, index, CSTORM_ID, 0, IGU_INT_ENABLE, 0);
 
+	/* SETUP ramrod */
 	bp->fp[index].state = BNX2X_FP_STATE_OPENING;
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_CLIENT_SETUP, index, 0, index, 0);
 
 	/* Wait for completion */
 	return bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_OPEN, index,
-				 &(bp->fp[index].state), 1);
+				 &(bp->fp[index].state), 0);
 
 }
 
@@ -7099,8 +7096,8 @@ static void bnx2x_set_rx_mode(struct net_device *dev);
 
 static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 {
-	int rc;
-	int i = 0;
+	u32 load_code;
+	int i;
 
 	bp->state = BNX2X_STATE_OPENING_WAIT4_LOAD;
 
@@ -7110,12 +7107,17 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 	   initialized, otherwise - not.
 	*/
 	if (!nomcp) {
-		rc = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ);
-		if (rc == FW_MSG_CODE_DRV_LOAD_REFUSED) {
+		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ);
+		if (!load_code) {
+			BNX2X_ERR("MCP response failure, unloading\n");
+			return -EBUSY;
+		}
+		if (load_code == FW_MSG_CODE_DRV_LOAD_REFUSED) {
+			BNX2X_ERR("MCP refused load request, unloading\n");
 			return -EBUSY; /* other port in diagnostic mode */
 		}
 	} else {
-		rc = FW_MSG_CODE_DRV_LOAD_COMMON;
+		load_code = FW_MSG_CODE_DRV_LOAD_COMMON;
 	}
 
 	/* if we can't use msix we only need one fp,
@@ -7153,13 +7155,13 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 		if (bp->flags & USING_MSIX_FLAG) {
 			if (bnx2x_req_msix_irqs(bp)) {
 				pci_disable_msix(bp->pdev);
-				goto out_error;
+				goto load_error;
 			}
 
 		} else {
 			if (bnx2x_req_irq(bp)) {
 				BNX2X_ERR("IRQ request failed, aborting\n");
-				goto out_error;
+				goto load_error;
 			}
 		}
 	}
@@ -7170,9 +7172,10 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 
 
 	/* Initialize HW */
-	if (bnx2x_function_init(bp, (rc == FW_MSG_CODE_DRV_LOAD_COMMON))) {
+	if (bnx2x_function_init(bp,
+				(load_code == FW_MSG_CODE_DRV_LOAD_COMMON))) {
 		BNX2X_ERR("HW init failed, aborting\n");
-		goto out_error;
+		goto load_error;
 	}
 
 
@@ -7184,11 +7187,10 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 
 	/* Send LOAD_DONE command to MCP */
 	if (!nomcp) {
-		rc = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE);
-		DP(NETIF_MSG_IFUP, "rc = 0x%x\n", rc);
-		if (!rc) {
+		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE);
+		if (!load_code) {
 			BNX2X_ERR("MCP response failure, unloading\n");
-			goto int_disable;
+			goto load_int_disable;
 		}
 	}
 
@@ -7200,11 +7202,11 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 		napi_enable(&bnx2x_fp(bp, i, napi));
 
 	if (bnx2x_setup_leading(bp))
-		goto stop_netif;
+		goto load_stop_netif;
 
 	for_each_nondefault_queue(bp, i)
 		if (bnx2x_setup_multi(bp, i))
-			goto stop_netif;
+			goto load_stop_netif;
 
 	bnx2x_set_mac_addr(bp);
 
@@ -7228,42 +7230,24 @@ static int bnx2x_nic_load(struct bnx2x *bp, int req_irq)
 
 	return 0;
 
-stop_netif:
+load_stop_netif:
 	for_each_queue(bp, i)
 		napi_disable(&bnx2x_fp(bp, i, napi));
 
-int_disable:
+load_int_disable:
 	bnx2x_int_disable_sync(bp);
 
 	bnx2x_free_skbs(bp);
 	bnx2x_free_irq(bp);
 
-out_error:
+load_error:
 	bnx2x_free_mem(bp);
 
 	/* TBD we really need to reset the chip
 	   if we want to recover from this */
-	return rc;
+	return -EBUSY;
 }
 
-static void bnx2x_netif_stop(struct bnx2x *bp)
-{
-	int i;
-
-	bp->rx_mode = BNX2X_RX_MODE_NONE;
-	bnx2x_set_storm_rx_mode(bp);
-
-	bnx2x_int_disable_sync(bp);
-	bnx2x_link_reset(bp);
-
-	for_each_queue(bp, i)
-		napi_disable(&bnx2x_fp(bp, i, napi));
-
-	if (netif_running(bp->dev)) {
-		netif_tx_disable(bp->dev);
-		bp->dev->trans_start = jiffies; /* prevent tx timeout */
-	}
-}
 
 static void bnx2x_reset_chip(struct bnx2x *bp, u32 reset_code)
 {
@@ -7354,7 +7338,7 @@ static void bnx2x_stop_leading(struct bnx2x *bp)
 
 	dsb_sp_prod_idx = *bp->dsb_sp_prod;
 
-	/* Send CFC_DELETE ramrod */
+	/* Send PORT_DELETE ramrod */
 	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_PORT_DEL, 0, 0, 0, 1);
 
 	/* Wait for completion to arrive on default status block
@@ -7375,35 +7359,48 @@ static void bnx2x_stop_leading(struct bnx2x *bp)
 }
 
 
-static int bnx2x_nic_unload(struct bnx2x *bp, int fre_irq)
+static int bnx2x_nic_unload(struct bnx2x *bp, int free_irq)
 {
 	u32 reset_code = 0;
-	int rc;
-	int i;
+	int i, timeout;
 
 	bp->state = BNX2X_STATE_CLOSING_WAIT4_HALT;
 
-	/* Calling flush_scheduled_work() may deadlock because
-	 * linkwatch_event() may be on the workqueue and it will try to get
-	 * the rtnl_lock which we are holding.
-	 */
+	del_timer_sync(&bp->timer);
 
-	while (bp->in_reset_task)
-		msleep(1);
+	bp->rx_mode = BNX2X_RX_MODE_NONE;
+	bnx2x_set_storm_rx_mode(bp);
 
-	/* Delete the timer: do it before disabling interrupts, as it
-	   may be still STAT_QUERY ramrod pending after stopping the timer */
-	del_timer_sync(&bp->timer);
+	if (netif_running(bp->dev)) {
+		netif_tx_disable(bp->dev);
+		bp->dev->trans_start = jiffies;	/* prevent tx timeout */
+	}
+
+	/* Wait until all fast path tasks complete */
+	for_each_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+
+		timeout = 1000;
+		while (bnx2x_has_work(fp) && (timeout--))
+			msleep(1);
+		if (!timeout)
+			BNX2X_ERR("timeout waiting for queue[%d]\n", i);
+	}
 
 	/* Wait until stat ramrod returns and all SP tasks complete */
-	while (bp->stat_pending && (bp->spq_left != MAX_SPQ_PENDING))
+	timeout = 1000;
+	while ((bp->stat_pending || (bp->spq_left != MAX_SPQ_PENDING)) &&
+	       (timeout--))
 		msleep(1);
 
-	/* Stop fast path, disable MAC, disable interrupts, disable napi */
-	bnx2x_netif_stop(bp);
+	for_each_queue(bp, i)
+		napi_disable(&bnx2x_fp(bp, i, napi));
+	/* Disable interrupts after Tx and Rx are disabled on stack level */
+	bnx2x_int_disable_sync(bp);
 
 	if (bp->flags & NO_WOL_FLAG)
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP;
+
 	else if (bp->wol) {
 		u32 emac_base = bp->port ? GRCBASE_EMAC0 : GRCBASE_EMAC1;
 		u8 *mac_addr = bp->dev->dev_addr;
@@ -7420,28 +7417,37 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int fre_irq)
 		EMAC_WR(EMAC_REG_EMAC_MAC_MATCH + 4, val);
 
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_EN;
+
 	} else
 		reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
 
+	/* Close multi and leading connections */
 	for_each_nondefault_queue(bp, i)
 		if (bnx2x_stop_multi(bp, i))
-			goto error;
-
+			goto unload_error;
 
 	bnx2x_stop_leading(bp);
+	if ((bp->state != BNX2X_STATE_CLOSING_WAIT4_UNLOAD) ||
+	    (bp->fp[0].state != BNX2X_FP_STATE_CLOSED)) {
+		DP(NETIF_MSG_IFDOWN, "failed to close leading properly!"
+		   "state 0x%x  fp[0].state 0x%x",
+		   bp->state, bp->fp[0].state);
+	}
+
+unload_error:
+	bnx2x_link_reset(bp);
 
-error:
 	if (!nomcp)
-		rc = bnx2x_fw_command(bp, reset_code);
+		reset_code = bnx2x_fw_command(bp, reset_code);
 	else
-		rc = FW_MSG_CODE_DRV_UNLOAD_COMMON;
+		reset_code = FW_MSG_CODE_DRV_UNLOAD_COMMON;
 
 	/* Release IRQs */
-	if (fre_irq)
+	if (free_irq)
 		bnx2x_free_irq(bp);
 
 	/* Reset the chip */
-	bnx2x_reset_chip(bp, rc);
+	bnx2x_reset_chip(bp, reset_code);
 
 	/* Report UNLOAD_DONE to MCP */
 	if (!nomcp)
@@ -7452,8 +7458,7 @@ error:
 	bnx2x_free_mem(bp);
 
 	bp->state = BNX2X_STATE_CLOSED;
-	/* Set link down */
-	bp->link_up = 0;
+
 	netif_carrier_off(bp->dev);
 
 	return 0;
@@ -9468,16 +9473,13 @@ static int bnx2x_open(struct net_device *dev)
 /* Called with rtnl_lock */
 static int bnx2x_close(struct net_device *dev)
 {
-	int rc;
 	struct bnx2x *bp = netdev_priv(dev);
 
 	/* Unload the driver, release IRQs */
-	rc = bnx2x_nic_unload(bp, 1);
-	if (rc) {
-		BNX2X_ERR("bnx2x_nic_unload failed: %d\n", rc);
-		return rc;
-	}
-	bnx2x_set_power_state(bp, PCI_D3hot);
+	bnx2x_nic_unload(bp, 1);
+
+	if (!CHIP_REV_IS_SLOW(bp))
+		bnx2x_set_power_state(bp, PCI_D3hot);
 
 	return 0;
 }
@@ -9620,14 +9622,18 @@ static void bnx2x_reset_task(struct work_struct *work)
 	if (!netif_running(bp->dev))
 		return;
 
-	bp->in_reset_task = 1;
+	rtnl_lock();
 
-	bnx2x_netif_stop(bp);
+	if (bp->state != BNX2X_STATE_OPEN) {
+		DP(NETIF_MSG_TX_ERR, "state is %x, returning\n", bp->state);
+		goto reset_task_exit;
+	}
 
 	bnx2x_nic_unload(bp, 0);
 	bnx2x_nic_load(bp, 0);
 
-	bp->in_reset_task = 0;
+reset_task_exit:
+	rtnl_unlock();
 }
 
 static int __devinit bnx2x_init_board(struct pci_dev *pdev,
@@ -9708,8 +9714,6 @@ static int __devinit bnx2x_init_board(struct pci_dev *pdev,
 
 	spin_lock_init(&bp->phy_lock);
 
-	bp->in_reset_task = 0;
-
 	INIT_WORK(&bp->reset_task, bnx2x_reset_task);
 	INIT_WORK(&bp->sp_task, bnx2x_sp_task);
 
@@ -9916,10 +9920,16 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct bnx2x *bp = netdev_priv(dev);
+	struct bnx2x *bp;
+
+	if (!dev) {
+		/* we get here if init_one() fails */
+		printk(KERN_ERR PFX "BAD net device from bnx2x_init_one\n");
+		return;
+	}
+
+	bp = netdev_priv(dev);
 
-	flush_scheduled_work();
-	/*tasklet_kill(&bp->sp_task);*/
 	unregister_netdev(dev);
 
 	if (bp->regview)
@@ -9937,34 +9947,43 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 static int bnx2x_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct bnx2x *bp = netdev_priv(dev);
-	int rc;
+	struct bnx2x *bp;
+
+	if (!dev)
+		return 0;
 
 	if (!netif_running(dev))
 		return 0;
 
-	rc = bnx2x_nic_unload(bp, 0);
-	if (!rc)
-		return rc;
+	bp = netdev_priv(dev);
+
+	bnx2x_nic_unload(bp, 0);
 
 	netif_device_detach(dev);
-	pci_save_state(pdev);
 
+	pci_save_state(pdev);
 	bnx2x_set_power_state(bp, pci_choose_state(pdev, state));
+
 	return 0;
 }
 
 static int bnx2x_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct bnx2x *bp = netdev_priv(dev);
+	struct bnx2x *bp;
 	int rc;
 
+	if (!dev) {
+		printk(KERN_ERR PFX "BAD net device from bnx2x_init_one\n");
+		return -ENODEV;
+	}
+
 	if (!netif_running(dev))
 		return 0;
 
-	pci_restore_state(pdev);
+	bp = netdev_priv(dev);
 
+	pci_restore_state(pdev);
 	bnx2x_set_power_state(bp, PCI_D0);
 	netif_device_attach(dev);
 
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index e2a36e8..6a86afb 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -545,8 +545,6 @@ struct bnx2x {
 	spinlock_t      	phy_lock;
 
 	struct work_struct      reset_task;
-	u16     		in_reset_task;
-
 	struct work_struct      sp_task;
 
 	struct timer_list       timer;
@@ -560,7 +558,6 @@ struct bnx2x {
 #define CHIP_ID(bp)     		(((bp)->chip_id) & 0xfffffff0)
 
 #define CHIP_NUM(bp)    		(((bp)->chip_id) & 0xffff0000)
-#define CHIP_NUM_5710   		0x57100000
 
 #define CHIP_REV(bp)    		(((bp)->chip_id) & 0x0000f000)
 #define CHIP_REV_Ax     		0x00000000
-- 
1.5.3.2




