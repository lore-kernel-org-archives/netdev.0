From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH net-next-2.6] be2net: implement EEH pci error recovery
 handlers
Date: Mon, 15 Feb 2010 12:52:01 +0530
Message-ID: <20100215072201.GA22277@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:45780 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754544Ab0BOHWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 02:22:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code has been tested on IBM pSeries server.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be.h      |    1 +
 drivers/net/benet/be_cmds.c |   23 +++++++++-
 drivers/net/benet/be_main.c |  103 ++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 125 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index b39b385..5038c16 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -265,6 +265,7 @@ struct be_adapter {
 	u32 if_handle;		/* Used to configure filtering */
 	u32 pmac_id;		/* MAC addr handle used by BE card */
 
+	bool eeh_err;
 	bool link_up;
 	u32 port_num;
 	bool promiscuous;
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index d1a0e5e..3397ee3 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -167,7 +167,14 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 	u32 ready;
 
 	do {
-		ready = ioread32(db) & MPU_MAILBOX_DB_RDY_MASK;
+		ready = ioread32(db);
+		if (ready == 0xffffffff) {
+			dev_err(&adapter->pdev->dev,
+				"pci slot disconnected\n");
+			return -1;
+		}
+
+		ready &= MPU_MAILBOX_DB_RDY_MASK;
 		if (ready)
 			break;
 
@@ -198,6 +205,11 @@ static int be_mbox_notify_wait(struct be_adapter *adapter)
 	struct be_mcc_mailbox *mbox = mbox_mem->va;
 	struct be_mcc_compl *compl = &mbox->compl;
 
+	/* wait for ready to be set */
+	status = be_mbox_db_ready_wait(adapter, db);
+	if (status != 0)
+		return status;
+
 	val |= MPU_MAILBOX_DB_HI_MASK;
 	/* at bits 2 - 31 place mbox dma addr msb bits 34 - 63 */
 	val |= (upper_32_bits(mbox_mem->dma) >> 2) << 2;
@@ -396,6 +408,9 @@ int be_cmd_fw_clean(struct be_adapter *adapter)
 	u8 *wrb;
 	int status;
 
+	if (adapter->eeh_err)
+		return -EIO;
+
 	spin_lock(&adapter->mbox_lock);
 
 	wrb = (u8 *)wrb_from_mbox(adapter);
@@ -768,6 +783,9 @@ int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 	u8 subsys = 0, opcode = 0;
 	int status;
 
+	if (adapter->eeh_err)
+		return -EIO;
+
 	spin_lock(&adapter->mbox_lock);
 
 	wrb = wrb_from_mbox(adapter);
@@ -856,6 +874,9 @@ int be_cmd_if_destroy(struct be_adapter *adapter, u32 interface_id)
 	struct be_cmd_req_if_destroy *req;
 	int status;
 
+	if (adapter->eeh_err)
+		return -EIO;
+
 	spin_lock(&adapter->mbox_lock);
 
 	wrb = wrb_from_mbox(adapter);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 92c55f6..cbfaa3f 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -68,6 +68,9 @@ static void be_intr_set(struct be_adapter *adapter, bool enable)
 	u32 reg = ioread32(addr);
 	u32 enabled = reg & MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK;
 
+	if (adapter->eeh_err)
+		return;
+
 	if (!enabled && enable)
 		reg |= MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK;
 	else if (enabled && !enable)
@@ -99,6 +102,10 @@ static void be_eq_notify(struct be_adapter *adapter, u16 qid,
 {
 	u32 val = 0;
 	val |= qid & DB_EQ_RING_ID_MASK;
+
+	if (adapter->eeh_err)
+		return;
+
 	if (arm)
 		val |= 1 << DB_EQ_REARM_SHIFT;
 	if (clear_int)
@@ -112,6 +119,10 @@ void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm, u16 num_popped)
 {
 	u32 val = 0;
 	val |= qid & DB_CQ_RING_ID_MASK;
+
+	if (adapter->eeh_err)
+		return;
+
 	if (arm)
 		val |= 1 << DB_CQ_REARM_SHIFT;
 	val |= num_popped << DB_CQ_NUM_POPPED_SHIFT;
@@ -2154,6 +2165,7 @@ static int be_ctrl_init(struct be_adapter *adapter)
 	spin_lock_init(&adapter->mcc_lock);
 	spin_lock_init(&adapter->mcc_cq_lock);
 
+	pci_save_state(adapter->pdev);
 	return 0;
 
 free_mbox:
@@ -2417,13 +2429,102 @@ static int be_resume(struct pci_dev *pdev)
 	return 0;
 }
 
+static pci_ers_result_t be_eeh_err_detected(struct pci_dev *pdev,
+				pci_channel_state_t state)
+{
+	struct be_adapter *adapter = pci_get_drvdata(pdev);
+	struct net_device *netdev =  adapter->netdev;
+
+	dev_err(&adapter->pdev->dev, "EEH error detected\n");
+
+	adapter->eeh_err = true;
+
+	netif_device_detach(netdev);
+
+	if (netif_running(netdev)) {
+		rtnl_lock();
+		be_close(netdev);
+		rtnl_unlock();
+	}
+	be_clear(adapter);
+
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
+	pci_disable_device(pdev);
+
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+static pci_ers_result_t be_eeh_reset(struct pci_dev *pdev)
+{
+	struct be_adapter *adapter = pci_get_drvdata(pdev);
+	int status;
+
+	dev_info(&adapter->pdev->dev, "EEH reset\n");
+	adapter->eeh_err = false;
+
+	status = pci_enable_device(pdev);
+	if (status)
+		return PCI_ERS_RESULT_DISCONNECT;
+
+	pci_set_master(pdev);
+	pci_set_power_state(pdev, 0);
+	pci_restore_state(pdev);
+
+	/* Check if card is ok and fw is ready */
+	status = be_cmd_POST(adapter);
+	if (status)
+		return PCI_ERS_RESULT_DISCONNECT;
+
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+static void be_eeh_resume(struct pci_dev *pdev)
+{
+	int status = 0;
+	struct be_adapter *adapter = pci_get_drvdata(pdev);
+	struct net_device *netdev =  adapter->netdev;
+
+	dev_info(&adapter->pdev->dev, "EEH resume\n");
+
+	pci_save_state(pdev);
+
+	/* tell fw we're ready to fire cmds */
+	status = be_cmd_fw_init(adapter);
+	if (status)
+		goto err;
+
+	status = be_setup(adapter);
+	if (status)
+		goto err;
+
+	if (netif_running(netdev)) {
+		status = be_open(netdev);
+		if (status)
+			goto err;
+	}
+	netif_device_attach(netdev);
+	return;
+err:
+	dev_err(&adapter->pdev->dev, "EEH resume failed\n");
+	return;
+}
+
+static struct pci_error_handlers be_eeh_handlers = {
+	.error_detected = be_eeh_err_detected,
+	.slot_reset = be_eeh_reset,
+	.resume = be_eeh_resume,
+};
+
 static struct pci_driver be_driver = {
 	.name = DRV_NAME,
 	.id_table = be_dev_ids,
 	.probe = be_probe,
 	.remove = be_remove,
 	.suspend = be_suspend,
-	.resume = be_resume
+	.resume = be_resume,
+	.err_handler = &be_eeh_handlers
 };
 
 static int __init be_init_module(void)
-- 
1.6.3.3

