From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] i40evf: Move some i40evf_reset_task code to separate function
Date: Tue,  1 Nov 2016 15:35:14 -0700
Message-ID: <a93a0a56a25a4f5357e548af6e535f4d5e06ea74.1478039638.git.joe@perches.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The i40evf_reset_task function is a couple hundred lines and it has
a separable block that disables vf.  Move that block to a new
i40evf_disable_vf function to shorten i40evf_reset_task a bit.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 86 +++++++++++++------------
 1 file changed, 44 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index db36744c6691..4cd3a47d888f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1693,6 +1693,49 @@ static void i40evf_watchdog_task(struct work_struct *work)
 	schedule_work(&adapter->adminq_task);
 }
 
+static void i40evf_disable_vf(struct i40evf_adapter *adapter)
+{
+	struct i40evf_mac_filter *f, *ftmp;
+	struct i40evf_vlan_filter *fv, *fvtmp;
+
+	adapter->flags |= I40EVF_FLAG_PF_COMMS_FAILED;
+
+	if (netif_running(adapter->netdev)) {
+		set_bit(__I40E_DOWN, &adapter->vsi.state);
+		netif_carrier_off(adapter->netdev);
+		netif_tx_disable(adapter->netdev);
+		adapter->link_up = false;
+		i40evf_napi_disable_all(adapter);
+		i40evf_irq_disable(adapter);
+		i40evf_free_traffic_irqs(adapter);
+		i40evf_free_all_tx_resources(adapter);
+		i40evf_free_all_rx_resources(adapter);
+	}
+
+	/* Delete all of the filters, both MAC and VLAN. */
+	list_for_each_entry_safe(f, ftmp, &adapter->mac_filter_list, list) {
+		list_del(&f->list);
+		kfree(f);
+	}
+
+	list_for_each_entry_safe(fv, fvtmp, &adapter->vlan_filter_list, list) {
+		list_del(&fv->list);
+		kfree(fv);
+	}
+
+	i40evf_free_misc_irq(adapter);
+	i40evf_reset_interrupt_capability(adapter);
+	i40evf_free_queues(adapter);
+	i40evf_free_q_vectors(adapter);
+	kfree(adapter->vf_res);
+	i40evf_shutdown_adminq(&adapter->hw);
+	adapter->netdev->flags &= ~IFF_UP;
+	clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
+	adapter->flags &= ~I40EVF_FLAG_RESET_PENDING;
+	adapter->state = __I40EVF_DOWN;
+	dev_info(&adapter->pdev->dev, "Reset task did not complete, VF disabled\n");
+}
+
 #define I40EVF_RESET_WAIT_MS 10
 #define I40EVF_RESET_WAIT_COUNT 500
 /**
@@ -1758,50 +1801,9 @@ static void i40evf_reset_task(struct work_struct *work)
 	pci_set_master(adapter->pdev);
 
 	if (i == I40EVF_RESET_WAIT_COUNT) {
-		struct i40evf_mac_filter *ftmp;
-		struct i40evf_vlan_filter *fv, *fvtmp;
-
-		/* reset never finished */
 		dev_err(&adapter->pdev->dev, "Reset never finished (%x)\n",
 			reg_val);
-		adapter->flags |= I40EVF_FLAG_PF_COMMS_FAILED;
-
-		if (netif_running(adapter->netdev)) {
-			set_bit(__I40E_DOWN, &adapter->vsi.state);
-			netif_carrier_off(netdev);
-			netif_tx_disable(netdev);
-			adapter->link_up = false;
-			i40evf_napi_disable_all(adapter);
-			i40evf_irq_disable(adapter);
-			i40evf_free_traffic_irqs(adapter);
-			i40evf_free_all_tx_resources(adapter);
-			i40evf_free_all_rx_resources(adapter);
-		}
-
-		/* Delete all of the filters, both MAC and VLAN. */
-		list_for_each_entry_safe(f, ftmp, &adapter->mac_filter_list,
-					 list) {
-			list_del(&f->list);
-			kfree(f);
-		}
-
-		list_for_each_entry_safe(fv, fvtmp, &adapter->vlan_filter_list,
-					 list) {
-			list_del(&fv->list);
-			kfree(fv);
-		}
-
-		i40evf_free_misc_irq(adapter);
-		i40evf_reset_interrupt_capability(adapter);
-		i40evf_free_queues(adapter);
-		i40evf_free_q_vectors(adapter);
-		kfree(adapter->vf_res);
-		i40evf_shutdown_adminq(hw);
-		adapter->netdev->flags &= ~IFF_UP;
-		clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
-		adapter->flags &= ~I40EVF_FLAG_RESET_PENDING;
-		adapter->state = __I40EVF_DOWN;
-		dev_info(&adapter->pdev->dev, "Reset task did not complete, VF disabled\n");
+		i40evf_disable_vf(adapter);
 		return; /* Do not attempt to reinit. It's dead, Jim. */
 	}
 
-- 
2.10.0.rc2.1.g053435c
