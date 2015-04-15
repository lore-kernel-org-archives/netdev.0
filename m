From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] i40evf: remove aq_pending
Date: Tue, 14 Apr 2015 21:51:41 -0700
Message-ID: <1429073511-27664-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44768 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932478AbbDOEwB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 00:52:01 -0400
In-Reply-To: <1429073511-27664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The aq_pending field in the adapter structure is actually redundant with
the current_op field. Remove the aq_pending field and expunge all traces
of it from the official record. This simplifies the code significantly,
especially in the virtual channel completion routine.

Change-ID: Ib2957c8c19882bd0cecc6fcd133912c24b46a1ff
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  1 -
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  7 +---
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 42 ++++++----------------
 3 files changed, 12 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 34c8565..1b98c25 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -225,7 +225,6 @@ struct i40evf_adapter {
 #define I40E_FLAG_RX_CSUM_ENABLED                I40EVF_FLAG_RX_CSUM_ENABLED
 	/* flags for admin queue service task */
 	u32 aq_required;
-	u32 aq_pending;
 #define I40EVF_FLAG_AQ_ENABLE_QUEUES		(u32)(1)
 #define I40EVF_FLAG_AQ_DISABLE_QUEUES		(u32)(1 << 1)
 #define I40EVF_FLAG_AQ_ADD_MAC_FILTER		(u32)(1 << 2)
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index a31bfd1..7c53aca 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1008,7 +1008,6 @@ void i40evf_down(struct i40evf_adapter *adapter)
 	    adapter->state != __I40EVF_RESETTING) {
 		/* cancel any current operation */
 		adapter->current_op = I40E_VIRTCHNL_OP_UNKNOWN;
-		adapter->aq_pending = 0;
 		/* Schedule operations to close down the HW. Don't wait
 		 * here for this to complete. The watchdog is still running
 		 * and it will take care of this.
@@ -1335,7 +1334,6 @@ static void i40evf_watchdog_task(struct work_struct *work)
 			 */
 			return;
 		}
-		adapter->aq_pending = 0;
 		adapter->aq_required = 0;
 		adapter->current_op = I40E_VIRTCHNL_OP_UNKNOWN;
 		goto watchdog_done;
@@ -1355,7 +1353,6 @@ static void i40evf_watchdog_task(struct work_struct *work)
 		adapter->flags |= I40EVF_FLAG_RESET_PENDING;
 		dev_err(&adapter->pdev->dev, "Hardware reset detected\n");
 		schedule_work(&adapter->reset_task);
-		adapter->aq_pending = 0;
 		adapter->aq_required = 0;
 		adapter->current_op = I40E_VIRTCHNL_OP_UNKNOWN;
 		goto watchdog_done;
@@ -1364,7 +1361,7 @@ static void i40evf_watchdog_task(struct work_struct *work)
 	/* Process admin queue tasks. After init, everything gets done
 	 * here so we don't race on the admin queue.
 	 */
-	if (adapter->aq_pending) {
+	if (adapter->current_op) {
 		if (!i40evf_asq_done(hw)) {
 			dev_dbg(&adapter->pdev->dev, "Admin queue timeout\n");
 			i40evf_send_api_ver(adapter);
@@ -2249,7 +2246,6 @@ static void i40evf_shutdown(struct pci_dev *pdev)
 	/* Prevent the watchdog from running. */
 	adapter->state = __I40EVF_REMOVE;
 	adapter->aq_required = 0;
-	adapter->aq_pending = 0;
 
 #ifdef CONFIG_PM
 	pci_save_state(pdev);
@@ -2467,7 +2463,6 @@ static void i40evf_remove(struct pci_dev *pdev)
 	/* Shut down all the garbage mashers on the detention level */
 	adapter->state = __I40EVF_REMOVE;
 	adapter->aq_required = 0;
-	adapter->aq_pending = 0;
 	i40evf_request_reset(adapter);
 	msleep(20);
 	/* If the FW isn't responding, kick it once, but only once. */
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 4240a49..61e0905 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -250,7 +250,6 @@ void i40evf_configure_queues(struct i40evf_adapter *adapter)
 		vqpi++;
 	}
 
-	adapter->aq_pending |= I40EVF_FLAG_AQ_CONFIGURE_QUEUES;
 	adapter->aq_required &= ~I40EVF_FLAG_AQ_CONFIGURE_QUEUES;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_CONFIG_VSI_QUEUES,
 			   (u8 *)vqci, len);
@@ -277,7 +276,6 @@ void i40evf_enable_queues(struct i40evf_adapter *adapter)
 	vqs.vsi_id = adapter->vsi_res->vsi_id;
 	vqs.tx_queues = (1 << adapter->num_active_queues) - 1;
 	vqs.rx_queues = vqs.tx_queues;
-	adapter->aq_pending |= I40EVF_FLAG_AQ_ENABLE_QUEUES;
 	adapter->aq_required &= ~I40EVF_FLAG_AQ_ENABLE_QUEUES;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_ENABLE_QUEUES,
 			   (u8 *)&vqs, sizeof(vqs));
@@ -303,7 +301,6 @@ void i40evf_disable_queues(struct i40evf_adapter *adapter)
 	vqs.vsi_id = adapter->vsi_res->vsi_id;
 	vqs.tx_queues = (1 << adapter->num_active_queues) - 1;
 	vqs.rx_queues = vqs.tx_queues;
-	adapter->aq_pending |= I40EVF_FLAG_AQ_DISABLE_QUEUES;
 	adapter->aq_required &= ~I40EVF_FLAG_AQ_DISABLE_QUEUES;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_DISABLE_QUEUES,
 			   (u8 *)&vqs, sizeof(vqs));
@@ -354,7 +351,6 @@ void i40evf_map_queues(struct i40evf_adapter *adapter)
 	vimi->vecmap[v_idx].txq_map = 0;
 	vimi->vecmap[v_idx].rxq_map = 0;
 
-	adapter->aq_pending |= I40EVF_FLAG_AQ_MAP_VECTORS;
 	adapter->aq_required &= ~I40EVF_FLAG_AQ_MAP_VECTORS;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_CONFIG_IRQ_MAP,
 			   (u8 *)vimi, len);
@@ -415,7 +411,6 @@ void i40evf_add_ether_addrs(struct i40evf_adapter *adapter)
 			f->add = false;
 		}
 	}
-	adapter->aq_pending |= I40EVF_FLAG_AQ_ADD_MAC_FILTER;
 	adapter->aq_required &= ~I40EVF_FLAG_AQ_ADD_MAC_FILTER;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_ADD_ETHER_ADDRESS,
 			   (u8 *)veal, len);
@@ -476,7 +471,6 @@ void i40evf_del_ether_addrs(struct i40evf_adapter *adapter)
 			kfree(f);
 		}
 	}
-	adapter->aq_pending |= I40EVF_FLAG_AQ_DEL_MAC_FILTER;
 	adapter->aq_required &= ~I40EVF_FLAG_AQ_DEL_MAC_FILTER;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_DEL_ETHER_ADDRESS,
 			   (u8 *)veal, len);
@@ -537,7 +531,6 @@ void i40evf_add_vlans(struct i40evf_adapter *adapter)
 			f->add = false;
 		}
 	}
-	adapter->aq_pending |= I40EVF_FLAG_AQ_ADD_VLAN_FILTER;
 	adapter->aq_required &= ~I40EVF_FLAG_AQ_ADD_VLAN_FILTER;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_ADD_VLAN, (u8 *)vvfl, len);
 	kfree(vvfl);
@@ -598,7 +591,6 @@ void i40evf_del_vlans(struct i40evf_adapter *adapter)
 			kfree(f);
 		}
 	}
-	adapter->aq_pending |= I40EVF_FLAG_AQ_DEL_VLAN_FILTER;
 	adapter->aq_required &= ~I40EVF_FLAG_AQ_DEL_VLAN_FILTER;
 	i40evf_send_pf_msg(adapter, I40E_VIRTCHNL_OP_DEL_VLAN, (u8 *)vvfl, len);
 	kfree(vvfl);
@@ -720,9 +712,6 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 			__func__, v_retval, v_opcode);
 	}
 	switch (v_opcode) {
-	case I40E_VIRTCHNL_OP_VERSION:
-		/* no action, but also not an error */
-		break;
 	case I40E_VIRTCHNL_OP_GET_STATS: {
 		struct i40e_eth_stats *stats =
 			(struct i40e_eth_stats *)msg;
@@ -740,39 +729,30 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 		adapter->current_stats = *stats;
 		}
 		break;
-	case I40E_VIRTCHNL_OP_ADD_ETHER_ADDRESS:
-		adapter->aq_pending &= ~(I40EVF_FLAG_AQ_ADD_MAC_FILTER);
-		break;
-	case I40E_VIRTCHNL_OP_DEL_ETHER_ADDRESS:
-		adapter->aq_pending &= ~(I40EVF_FLAG_AQ_DEL_MAC_FILTER);
-		break;
-	case I40E_VIRTCHNL_OP_ADD_VLAN:
-		adapter->aq_pending &= ~(I40EVF_FLAG_AQ_ADD_VLAN_FILTER);
-		break;
-	case I40E_VIRTCHNL_OP_DEL_VLAN:
-		adapter->aq_pending &= ~(I40EVF_FLAG_AQ_DEL_VLAN_FILTER);
-		break;
 	case I40E_VIRTCHNL_OP_ENABLE_QUEUES:
-		adapter->aq_pending &= ~(I40EVF_FLAG_AQ_ENABLE_QUEUES);
 		/* enable transmits */
 		i40evf_irq_enable(adapter, true);
 		netif_tx_start_all_queues(adapter->netdev);
 		netif_carrier_on(adapter->netdev);
 		break;
 	case I40E_VIRTCHNL_OP_DISABLE_QUEUES:
-		adapter->aq_pending &= ~(I40EVF_FLAG_AQ_DISABLE_QUEUES);
 		i40evf_free_all_tx_resources(adapter);
 		i40evf_free_all_rx_resources(adapter);
 		break;
-	case I40E_VIRTCHNL_OP_CONFIG_VSI_QUEUES:
-		adapter->aq_pending &= ~(I40EVF_FLAG_AQ_CONFIGURE_QUEUES);
-		break;
+	case I40E_VIRTCHNL_OP_VERSION:
+	case I40E_VIRTCHNL_OP_GET_VF_RESOURCES:
 	case I40E_VIRTCHNL_OP_CONFIG_IRQ_MAP:
-		adapter->aq_pending &= ~(I40EVF_FLAG_AQ_MAP_VECTORS);
+		/* Don't display an error if we get these out of sequence.
+		 * If the firmware needed to get kicked, we'll get these and
+		 * it's no problem.
+		 */
+		if (v_opcode != adapter->current_op)
+			return;
 		break;
 	default:
-		dev_info(&adapter->pdev->dev, "Received unexpected message %d from PF\n",
-			 v_opcode);
+		if (v_opcode != adapter->current_op)
+			dev_warn(&adapter->pdev->dev, "Expected response %d from PF, received %d\n",
+				 adapter->current_op, v_opcode);
 		break;
 	} /* switch v_opcode */
 	adapter->current_op = I40E_VIRTCHNL_OP_UNKNOWN;
-- 
1.9.3
