From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40evf: refactor shutdown code
Date: Tue, 13 Jan 2015 03:33:20 -0800
Message-ID: <1421148811-9763-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421148811-9763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41319 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752227AbbAMLdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 06:33:35 -0500
In-Reply-To: <1421148811-9763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

If the VF driver is running in the host, the shutdown code is completely
broken. We cannot wait in our down routine for the PF to respond to our
requests, as its admin queue task will never run while we hold the lock.

Instead, we schedule operations, then let the watchdog take care of
shutting things down. If the driver is being removed, then wait in the
remove routine until the watchdog is done before continuing.

Change-ID: I93a58d17389e8d6b58f21e430b56ed7b4590b2c5
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 29 ++++++++++++++++++++-----
 1 file changed, 23 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index f8f1d26..5a2ed90 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -958,6 +958,12 @@ void i40evf_down(struct i40evf_adapter *adapter)
 	if (adapter->state == __I40EVF_DOWN)
 		return;
 
+	while (test_and_set_bit(__I40EVF_IN_CRITICAL_TASK,
+				&adapter->crit_section))
+		usleep_range(500, 1000);
+
+	i40evf_irq_disable(adapter);
+
 	/* remove all MAC filters */
 	list_for_each_entry(f, &adapter->mac_filter_list, list) {
 		f->remove = true;
@@ -968,22 +974,27 @@ void i40evf_down(struct i40evf_adapter *adapter)
 	}
 	if (!(adapter->flags & I40EVF_FLAG_PF_COMMS_FAILED) &&
 	    adapter->state != __I40EVF_RESETTING) {
-		adapter->aq_required |= I40EVF_FLAG_AQ_DEL_MAC_FILTER;
+		/* cancel any current operation */
+		adapter->current_op = I40E_VIRTCHNL_OP_UNKNOWN;
+		adapter->aq_pending = 0;
+		/* Schedule operations to close down the HW. Don't wait
+		 * here for this to complete. The watchdog is still running
+		 * and it will take care of this.
+		 */
+		adapter->aq_required = I40EVF_FLAG_AQ_DEL_MAC_FILTER;
 		adapter->aq_required |= I40EVF_FLAG_AQ_DEL_VLAN_FILTER;
-		/* disable receives */
 		adapter->aq_required |= I40EVF_FLAG_AQ_DISABLE_QUEUES;
-		mod_timer_pending(&adapter->watchdog_timer, jiffies + 1);
-		msleep(20);
 	}
 	netif_tx_disable(netdev);
 
 	netif_tx_stop_all_queues(netdev);
 
-	i40evf_irq_disable(adapter);
-
 	i40evf_napi_disable_all(adapter);
 
+	msleep(20);
+
 	netif_carrier_off(netdev);
+	clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
 }
 
 /**
@@ -2409,6 +2420,7 @@ static void i40evf_remove(struct pci_dev *pdev)
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 	struct i40evf_mac_filter *f, *ftmp;
 	struct i40e_hw *hw = &adapter->hw;
+	int count = 50;
 
 	cancel_delayed_work_sync(&adapter->init_task);
 	cancel_work_sync(&adapter->reset_task);
@@ -2417,6 +2429,11 @@ static void i40evf_remove(struct pci_dev *pdev)
 		unregister_netdev(netdev);
 		adapter->netdev_registered = false;
 	}
+	while (count-- && adapter->aq_required)
+		msleep(50);
+
+	if (count < 0)
+		dev_err(&pdev->dev, "Timed out waiting for PF driver.\n");
 	adapter->state = __I40EVF_REMOVE;
 
 	if (adapter->msix_entries) {
-- 
1.9.3
