From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 14/15] i40evf: fix memory leak on unused interfaces
Date: Wed, 30 Jul 2014 17:32:10 -0700
Message-ID: <1406766731-4209-15-git-send-email-aaron.f.brown@intel.com>
References: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:24424 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756068AbaGaA2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 20:28:23 -0400
In-Reply-To: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the driver is loaded and then unloaded before the interface is
brought up, then it will allocate a MAC filter entry and never free it.
To fix this, on unload, run through the mac filter list and free all the
entries. We also do this during reset recovery when the driver cannot
contact the PF and needs to shut down completely.

Change-ID: I15fabd67eb4a1bfc57605a7db60d0b5d819839db
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 0c4f7baf..e5679d8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1527,6 +1527,9 @@ static void i40evf_reset_task(struct work_struct *work)
 			msleep(I40EVF_RESET_WAIT_MS);
 	}
 	if (i == I40EVF_RESET_WAIT_COUNT) {
+		struct i40evf_mac_filter *f, *ftmp;
+		struct i40evf_vlan_filter *fv, *fvtmp;
+
 		/* reset never finished */
 		dev_err(&adapter->pdev->dev, "Reset never finished (%x)\n",
 			rstat_val);
@@ -1539,6 +1542,19 @@ static void i40evf_reset_task(struct work_struct *work)
 			i40evf_free_all_tx_resources(adapter);
 			i40evf_free_all_rx_resources(adapter);
 		}
+
+		/* Delete all of the filters, both MAC and VLAN. */
+		list_for_each_entry_safe(f, ftmp, &adapter->mac_filter_list,
+					 list) {
+			list_del(&f->list);
+			kfree(f);
+		}
+		list_for_each_entry_safe(fv, fvtmp, &adapter->vlan_filter_list,
+					 list) {
+			list_del(&fv->list);
+			kfree(fv);
+		}
+
 		i40evf_free_misc_irq(adapter);
 		i40evf_reset_interrupt_capability(adapter);
 		i40evf_free_queues(adapter);
@@ -2415,6 +2431,7 @@ static void i40evf_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
+	struct i40evf_mac_filter *f, *ftmp;
 	struct i40e_hw *hw = &adapter->hw;
 
 	cancel_delayed_work_sync(&adapter->init_task);
@@ -2446,6 +2463,13 @@ static void i40evf_remove(struct pci_dev *pdev)
 
 	i40evf_free_queues(adapter);
 	kfree(adapter->vf_res);
+	/* If we got removed before an up/down sequence, we've got a filter
+	 * hanging out there that we need to get rid of.
+	 */
+	list_for_each_entry_safe(f, ftmp, &adapter->mac_filter_list, list) {
+		list_del(&f->list);
+		kfree(f);
+	}
 
 	free_netdev(netdev);
 
-- 
1.9.3
