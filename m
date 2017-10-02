From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40evf: Enable VF to request an alternate queue allocation
Date: Mon,  2 Oct 2017 12:48:48 -0700
Message-ID: <20171002194852.71970-12-jeffrey.t.kirsher@intel.com>
References: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:29126 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751566AbdJBTtU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 15:49:20 -0400
In-Reply-To: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

Currently the VF gets a default number of allocated queues from HW on
init and it could choose to enable or disable those allocated queues.
This makes it such that the VF can request more or less underlying
allocated queues from the PF.

First the VF negotiates the number of queues it wants that can be
supported by the PF and if successful asks for a reset.  During reset
the PF will reallocate the HW queues for the VF and will then remap the
new queues.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  4 +
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 38 ++++++++-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 94 ++++++++++++++++++++--
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 44 +++++++++-
 4 files changed, 173 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 82f69031e5cd..5982362c5643 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -102,6 +102,7 @@ struct i40e_vsi {
 #define I40E_TX_CTXTDESC(R, i) \
 	(&(((struct i40e_tx_context_desc *)((R)->desc))[i]))
 #define MAX_QUEUES 16
+#define I40EVF_MAX_REQ_QUEUES 4
 
 #define I40EVF_HKEY_ARRAY_SIZE ((I40E_VFQF_HKEY_MAX_INDEX + 1) * 4)
 #define I40EVF_HLUT_ARRAY_SIZE ((I40E_VFQF_HLUT_MAX_INDEX + 1) * 4)
@@ -200,6 +201,7 @@ struct i40evf_adapter {
 	struct list_head vlan_filter_list;
 	char misc_vector_name[IFNAMSIZ + 9];
 	int num_active_queues;
+	int num_req_queues;
 
 	/* TX */
 	struct i40e_ring *tx_rings;
@@ -235,6 +237,7 @@ struct i40evf_adapter {
 #define I40EVF_FLAG_PROMISC_ON			BIT(18)
 #define I40EVF_FLAG_ALLMULTI_ON			BIT(19)
 #define I40EVF_FLAG_LEGACY_RX			BIT(20)
+#define I40EVF_FLAG_REINIT_ITR_NEEDED		BIT(21)
 /* duplicates for common code */
 #define I40E_FLAG_DCB_ENABLED			0
 #define I40E_FLAG_RX_CSUM_ENABLED		I40EVF_FLAG_RX_CSUM_ENABLED
@@ -349,6 +352,7 @@ void i40evf_deconfigure_queues(struct i40evf_adapter *adapter);
 void i40evf_enable_queues(struct i40evf_adapter *adapter);
 void i40evf_disable_queues(struct i40evf_adapter *adapter);
 void i40evf_map_queues(struct i40evf_adapter *adapter);
+int i40evf_request_queues(struct i40evf_adapter *adapter, int num);
 void i40evf_add_ether_addrs(struct i40evf_adapter *adapter);
 void i40evf_del_ether_addrs(struct i40evf_adapter *adapter);
 void i40evf_add_vlans(struct i40evf_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 65874d6b3ab9..da006fa3fec1 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -669,7 +669,7 @@ static void i40evf_get_channels(struct net_device *netdev,
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 
 	/* Report maximum channels */
-	ch->max_combined = adapter->num_active_queues;
+	ch->max_combined = I40EVF_MAX_REQ_QUEUES;
 
 	ch->max_other = NONQ_VECS;
 	ch->other_count = NONQ_VECS;
@@ -677,6 +677,41 @@ static void i40evf_get_channels(struct net_device *netdev,
 	ch->combined_count = adapter->num_active_queues;
 }
 
+/**
+ * i40evf_set_channels: set the new channel count
+ * @netdev: network interface device structure
+ * @ch: channel information structure
+ *
+ * Negotiate a new number of channels with the PF then do a reset.  During
+ * reset we'll realloc queues and fix the RSS table.  Returns 0 on success,
+ * negative on failure.
+ **/
+static int i40evf_set_channels(struct net_device *netdev,
+			       struct ethtool_channels *ch)
+{
+	struct i40evf_adapter *adapter = netdev_priv(netdev);
+	int num_req = ch->combined_count;
+
+	if (num_req != adapter->num_active_queues &&
+	    !(adapter->vf_res->vf_cap_flags &
+	      VIRTCHNL_VF_OFFLOAD_REQ_QUEUES)) {
+		dev_info(&adapter->pdev->dev, "PF is not capable of queue negotiation.\n");
+		return -EINVAL;
+	}
+
+	/* All of these should have already been checked by ethtool before this
+	 * even gets to us, but just to be sure.
+	 */
+	if (num_req <= 0 || num_req > I40EVF_MAX_REQ_QUEUES)
+		return -EINVAL;
+
+	if (ch->rx_count || ch->tx_count || ch->other_count != NONQ_VECS)
+		return -EINVAL;
+
+	adapter->num_req_queues = num_req;
+	return i40evf_request_queues(adapter, num_req);
+}
+
 /**
  * i40evf_get_rxfh_key_size - get the RSS hash key size
  * @netdev: network interface device structure
@@ -785,6 +820,7 @@ static const struct ethtool_ops i40evf_ethtool_ops = {
 	.get_rxfh		= i40evf_get_rxfh,
 	.set_rxfh		= i40evf_set_rxfh,
 	.get_channels		= i40evf_get_channels,
+	.set_channels		= i40evf_set_channels,
 	.get_rxfh_key_size	= i40evf_get_rxfh_key_size,
 	.get_link_ksettings	= i40evf_get_link_ksettings,
 };
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 69ef6c1d5364..8c513ce84345 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1189,9 +1189,18 @@ static int i40evf_alloc_queues(struct i40evf_adapter *adapter)
 {
 	int i, num_active_queues;
 
-	num_active_queues = min_t(int,
-				  adapter->vsi_res->num_queue_pairs,
-				  (int)(num_online_cpus()));
+	/* If we're in reset reallocating queues we don't actually know yet for
+	 * certain the PF gave us the number of queues we asked for but we'll
+	 * assume it did.  Once basic reset is finished we'll confirm once we
+	 * start negotiating config with PF.
+	 */
+	if (adapter->num_req_queues)
+		num_active_queues = adapter->num_req_queues;
+	else
+		num_active_queues = min_t(int,
+					  adapter->vsi_res->num_queue_pairs,
+					  (int)(num_online_cpus()));
+
 
 	adapter->tx_rings = kcalloc(num_active_queues,
 				    sizeof(struct i40e_ring), GFP_KERNEL);
@@ -1539,6 +1548,48 @@ static void i40evf_free_rss(struct i40evf_adapter *adapter)
 	adapter->rss_lut = NULL;
 }
 
+/**
+ * i40evf_reinit_interrupt_scheme - Reallocate queues and vectors
+ * @adapter: board private structure
+ *
+ * Returns 0 on success, negative on failure
+ **/
+static int i40evf_reinit_interrupt_scheme(struct i40evf_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	int err;
+
+	if (netif_running(netdev))
+		i40evf_free_traffic_irqs(adapter);
+	i40evf_free_misc_irq(adapter);
+	i40evf_reset_interrupt_capability(adapter);
+	i40evf_free_q_vectors(adapter);
+	i40evf_free_queues(adapter);
+
+	err =  i40evf_init_interrupt_scheme(adapter);
+	if (err)
+		goto err;
+
+	netif_tx_stop_all_queues(netdev);
+
+	err = i40evf_request_misc_irq(adapter);
+	if (err)
+		goto err;
+
+	set_bit(__I40E_VSI_DOWN, adapter->vsi.state);
+
+	err = i40evf_map_rings_to_vectors(adapter);
+	if (err)
+		goto err;
+
+	if (RSS_AQ(adapter))
+		adapter->aq_required |= I40EVF_FLAG_AQ_CONFIGURE_RSS;
+	else
+		err = i40evf_init_rss(adapter);
+err:
+	return err;
+}
+
 /**
  * i40evf_watchdog_timer - Periodic call-back timer
  * @data: pointer to adapter disguised as unsigned long
@@ -1885,8 +1936,15 @@ static void i40evf_reset_task(struct work_struct *work)
 	if (err)
 		dev_info(&adapter->pdev->dev, "Failed to init adminq: %d\n",
 			 err);
+	adapter->aq_required = 0;
 
-	adapter->aq_required = I40EVF_FLAG_AQ_GET_CONFIG;
+	if (adapter->flags & I40EVF_FLAG_REINIT_ITR_NEEDED) {
+		err = i40evf_reinit_interrupt_scheme(adapter);
+		if (err)
+			goto reset_err;
+	}
+
+	adapter->aq_required |= I40EVF_FLAG_AQ_GET_CONFIG;
 	adapter->aq_required |= I40EVF_FLAG_AQ_MAP_VECTORS;
 
 	/* re-add all MAC filters */
@@ -1916,6 +1974,15 @@ static void i40evf_reset_task(struct work_struct *work)
 		if (err)
 			goto reset_err;
 
+		if (adapter->flags & I40EVF_FLAG_REINIT_ITR_NEEDED) {
+			err = i40evf_request_traffic_irqs(adapter,
+							  netdev->name);
+			if (err)
+				goto reset_err;
+
+			adapter->flags &= ~I40EVF_FLAG_REINIT_ITR_NEEDED;
+		}
+
 		i40evf_configure(adapter);
 
 		i40evf_up_complete(adapter);
@@ -2431,9 +2498,9 @@ static int i40evf_check_reset_complete(struct i40e_hw *hw)
 int i40evf_process_config(struct i40evf_adapter *adapter)
 {
 	struct virtchnl_vf_resource *vfres = adapter->vf_res;
+	int i, num_req_queues = adapter->num_req_queues;
 	struct net_device *netdev = adapter->netdev;
 	struct i40e_vsi *vsi = &adapter->vsi;
-	int i;
 	netdev_features_t hw_enc_features;
 	netdev_features_t hw_features;
 
@@ -2447,6 +2514,23 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 		return -ENODEV;
 	}
 
+	if (num_req_queues &&
+	    num_req_queues != adapter->vsi_res->num_queue_pairs) {
+		/* Problem.  The PF gave us fewer queues than what we had
+		 * negotiated in our request.  Need a reset to see if we can't
+		 * get back to a working state.
+		 */
+		dev_err(&adapter->pdev->dev,
+			"Requested %d queues, but PF only gave us %d.\n",
+			num_req_queues,
+			adapter->vsi_res->num_queue_pairs);
+		adapter->flags |= I40EVF_FLAG_REINIT_ITR_NEEDED;
+		adapter->num_req_queues = adapter->vsi_res->num_queue_pairs;
+		i40evf_schedule_reset(adapter);
+		return -ENODEV;
+	}
+	adapter->num_req_queues = 0;
+
 	hw_enc_features = NETIF_F_SG			|
 			  NETIF_F_IP_CSUM		|
 			  NETIF_F_IPV6_CSUM		|
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 2bb0fe00361f..2bb81c39d85f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -160,7 +160,8 @@ int i40evf_send_vf_config_msg(struct i40evf_adapter *adapter)
 	       VIRTCHNL_VF_OFFLOAD_WB_ON_ITR |
 	       VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2 |
 	       VIRTCHNL_VF_OFFLOAD_ENCAP |
-	       VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM;
+	       VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM |
+	       VIRTCHNL_VF_OFFLOAD_REQ_QUEUES;
 
 	adapter->current_op = VIRTCHNL_OP_GET_VF_RESOURCES;
 	adapter->aq_required &= ~I40EVF_FLAG_AQ_GET_CONFIG;
@@ -384,6 +385,32 @@ void i40evf_map_queues(struct i40evf_adapter *adapter)
 	kfree(vimi);
 }
 
+/**
+ * i40evf_request_queues
+ * @adapter: adapter structure
+ * @num: number of requested queues
+ *
+ * We get a default number of queues from the PF.  This enables us to request a
+ * different number.  Returns 0 on success, negative on failure
+ **/
+int i40evf_request_queues(struct i40evf_adapter *adapter, int num)
+{
+	struct virtchnl_vf_res_request vfres;
+
+	if (adapter->current_op != VIRTCHNL_OP_UNKNOWN) {
+		/* bail because we already have a command pending */
+		dev_err(&adapter->pdev->dev, "Cannot request queues, command %d pending\n",
+			adapter->current_op);
+		return -EBUSY;
+	}
+
+	vfres.num_queue_pairs = num;
+
+	adapter->current_op = VIRTCHNL_OP_REQUEST_QUEUES;
+	return i40evf_send_pf_msg(adapter, VIRTCHNL_OP_REQUEST_QUEUES,
+				  (u8 *)&vfres, sizeof(vfres));
+}
+
 /**
  * i40evf_add_ether_addrs
  * @adapter: adapter structure
@@ -1068,6 +1095,21 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 				 "Invalid message %d from PF\n", v_opcode);
 		}
 		break;
+	case VIRTCHNL_OP_REQUEST_QUEUES: {
+		struct virtchnl_vf_res_request *vfres =
+			(struct virtchnl_vf_res_request *)msg;
+		if (vfres->num_queue_pairs == adapter->num_req_queues) {
+			adapter->flags |= I40EVF_FLAG_REINIT_ITR_NEEDED;
+			i40evf_schedule_reset(adapter);
+		} else {
+			dev_info(&adapter->pdev->dev,
+				 "Requested %d queues, PF can support %d\n",
+				 adapter->num_req_queues,
+				 vfres->num_queue_pairs);
+			adapter->num_req_queues = 0;
+		}
+		}
+		break;
 	default:
 		if (adapter->current_op && (v_opcode != adapter->current_op))
 			dev_warn(&adapter->pdev->dev, "Expected response %d from PF, received %d\n",
-- 
2.14.2
