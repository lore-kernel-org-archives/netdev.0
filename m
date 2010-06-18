From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 3/9] cxgb4: implement EEH
Date: Fri, 18 Jun 2010 13:05:29 -0700
Message-ID: <1276891535-13967-4-git-send-email-dm@chelsio.com>
References: <1276891535-13967-1-git-send-email-dm@chelsio.com>
 <1276891535-13967-2-git-send-email-dm@chelsio.com>
 <1276891535-13967-3-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23850 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933176Ab0FRUMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 16:12:20 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5IKCJQI018644
	for <netdev@vger.kernel.org>; Fri, 18 Jun 2010 13:12:20 -0700
In-Reply-To: <1276891535-13967-3-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the pci_error_handlers methods for EEH.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4.h      |    1 +
 drivers/net/cxgb4/cxgb4_main.c |  108 +++++++++++++++++++++++++++++++++++++++-
 drivers/net/cxgb4/l2t.c        |    7 +++
 drivers/net/cxgb4/t4_hw.c      |   11 +++-
 4 files changed, 124 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index bfa1366..5e37c1e 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -650,6 +650,7 @@ void t4_intr_disable(struct adapter *adapter);
 void t4_intr_clear(struct adapter *adapter);
 int t4_slow_intr_handler(struct adapter *adapter);
 
+int t4_wait_dev_ready(struct adapter *adap);
 int t4_link_start(struct adapter *adap, unsigned int mbox, unsigned int port,
 		  struct link_config *lc);
 int t4_restart_aneg(struct adapter *adap, unsigned int mbox, unsigned int port);
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 60f6ea0..baf4f0a 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -2483,6 +2483,7 @@ static void cxgb_down(struct adapter *adapter)
 	t4_intr_disable(adapter);
 	cancel_work_sync(&adapter->tid_release_task);
 	adapter->tid_release_task_busy = false;
+	adapter->tid_release_head = NULL;
 
 	if (adapter->flags & USING_MSIX) {
 		free_msix_queue_irqs(adapter);
@@ -2907,6 +2908,108 @@ bye:	if (ret != -ETIMEDOUT && ret != -EIO)
 	return ret;
 }
 
+/* EEH callbacks */
+
+static pci_ers_result_t eeh_err_detected(struct pci_dev *pdev,
+					 pci_channel_state_t state)
+{
+	int i;
+	struct adapter *adap = pci_get_drvdata(pdev);
+
+	if (!adap)
+		goto out;
+
+	rtnl_lock();
+	adap->flags &= ~FW_OK;
+	notify_ulds(adap, CXGB4_STATE_START_RECOVERY);
+	for_each_port(adap, i) {
+		struct net_device *dev = adap->port[i];
+
+		netif_device_detach(dev);
+		netif_carrier_off(dev);
+	}
+	if (adap->flags & FULL_INIT_DONE)
+		cxgb_down(adap);
+	rtnl_unlock();
+	pci_disable_device(pdev);
+out:	return state == pci_channel_io_perm_failure ?
+		PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_NEED_RESET;
+}
+
+static pci_ers_result_t eeh_slot_reset(struct pci_dev *pdev)
+{
+	int i, ret;
+	struct fw_caps_config_cmd c;
+	struct adapter *adap = pci_get_drvdata(pdev);
+
+	if (!adap) {
+		pci_restore_state(pdev);
+		pci_save_state(pdev);
+		return PCI_ERS_RESULT_RECOVERED;
+	}
+
+	if (pci_enable_device(pdev)) {
+		dev_err(&pdev->dev, "cannot reenable PCI device after reset\n");
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+
+	pci_set_master(pdev);
+	pci_restore_state(pdev);
+	pci_save_state(pdev);
+	pci_cleanup_aer_uncorrect_error_status(pdev);
+
+	if (t4_wait_dev_ready(adap) < 0)
+		return PCI_ERS_RESULT_DISCONNECT;
+	if (t4_fw_hello(adap, 0, 0, MASTER_MUST, NULL))
+		return PCI_ERS_RESULT_DISCONNECT;
+	adap->flags |= FW_OK;
+	if (adap_init1(adap, &c))
+		return PCI_ERS_RESULT_DISCONNECT;
+
+	for_each_port(adap, i) {
+		struct port_info *p = adap2pinfo(adap, i);
+
+		ret = t4_alloc_vi(adap, 0, p->tx_chan, 0, 0, 1, NULL, NULL);
+		if (ret < 0)
+			return PCI_ERS_RESULT_DISCONNECT;
+		p->viid = ret;
+		p->xact_addr_filt = -1;
+	}
+
+	t4_load_mtus(adap, adap->params.mtus, adap->params.a_wnd,
+		     adap->params.b_wnd);
+	if (cxgb_up(adap))
+		return PCI_ERS_RESULT_DISCONNECT;
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+static void eeh_resume(struct pci_dev *pdev)
+{
+	int i;
+	struct adapter *adap = pci_get_drvdata(pdev);
+
+	if (!adap)
+		return;
+
+	rtnl_lock();
+	for_each_port(adap, i) {
+		struct net_device *dev = adap->port[i];
+
+		if (netif_running(dev)) {
+			link_start(dev);
+			cxgb_set_rxmode(dev);
+		}
+		netif_device_attach(dev);
+	}
+	rtnl_unlock();
+}
+
+static struct pci_error_handlers cxgb4_eeh = {
+	.error_detected = eeh_err_detected,
+	.slot_reset     = eeh_slot_reset,
+	.resume         = eeh_resume,
+};
+
 static inline bool is_10g_port(const struct link_config *lc)
 {
 	return (lc->supported & FW_PORT_CAP_SPEED_10G) != 0;
@@ -3154,8 +3257,10 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 	/* We control everything through PF 0 */
 	func = PCI_FUNC(pdev->devfn);
-	if (func > 0)
+	if (func > 0) {
+		pci_save_state(pdev);        /* to restore SR-IOV later */
 		goto sriov;
+	}
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -3396,6 +3501,7 @@ static struct pci_driver cxgb4_driver = {
 	.id_table = cxgb4_pci_tbl,
 	.probe    = init_one,
 	.remove   = __devexit_p(remove_one),
+	.err_handler = &cxgb4_eeh,
 };
 
 static int __init cxgb4_init_module(void)
diff --git a/drivers/net/cxgb4/l2t.c b/drivers/net/cxgb4/l2t.c
index 9f96724..5b990d2 100644
--- a/drivers/net/cxgb4/l2t.c
+++ b/drivers/net/cxgb4/l2t.c
@@ -310,6 +310,13 @@ static void t4_l2e_free(struct l2t_entry *e)
 			neigh_release(e->neigh);
 			e->neigh = NULL;
 		}
+		while (e->arpq_head) {
+			struct sk_buff *skb = e->arpq_head;
+
+			e->arpq_head = skb->next;
+			kfree(skb);
+		}
+		e->arpq_tail = NULL;
 	}
 	spin_unlock_bh(&e->lock);
 
diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index 5c81c55..0c8a84a 100644
--- a/drivers/net/cxgb4/t4_hw.c
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -221,6 +221,13 @@ int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
 	if ((size & 15) || size > MBOX_LEN)
 		return -EINVAL;
 
+	/*
+	 * If the device is off-line, as in EEH, commands will time out.
+	 * Fail them early so we don't waste time waiting.
+	 */
+	if (adap->pdev->error_state != pci_channel_io_normal)
+		return -EIO;
+
 	v = MBOWNER_GET(t4_read_reg(adap, ctl_reg));
 	for (i = 0; v == MBOX_OWNER_NONE && i < 3; i++)
 		v = MBOWNER_GET(t4_read_reg(adap, ctl_reg));
@@ -3045,7 +3052,7 @@ static void __devinit init_link_config(struct link_config *lc,
 	}
 }
 
-static int __devinit wait_dev_ready(struct adapter *adap)
+int t4_wait_dev_ready(struct adapter *adap)
 {
 	if (t4_read_reg(adap, PL_WHOAMI) != 0xffffffff)
 		return 0;
@@ -3093,7 +3100,7 @@ int __devinit t4_prep_adapter(struct adapter *adapter)
 {
 	int ret;
 
-	ret = wait_dev_ready(adapter);
+	ret = t4_wait_dev_ready(adapter);
 	if (ret < 0)
 		return ret;
 
-- 
1.5.4

