From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next V2] intel: Remove unnecessary OOM messages
Date: Tue, 11 Feb 2014 17:30:52 -0800
Message-ID: <1392168652.1868.1.camel@joe-AO722>
References: <1392168397.23721.2.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0024.hostedemail.com ([216.40.44.24]:37221 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751753AbaBLBa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:30:58 -0500
In-Reply-To: <1392168397.23721.2.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't emit these as there's a generic OOM with a dump_stack()
on allocation failures.

Signed-off-by: Joe Perches <joe@perches.com>
---

With patch attached this time...

 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  5 +---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 20 ++++---------
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 35 +++++++---------------
 drivers/net/ethernet/intel/igb/igb_main.c          |  2 --
 4 files changed, 17 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index b1d7d8c..d4d0761 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1506,11 +1506,8 @@ static int i40e_add_del_fdir_ethtool(struct i40e_vsi *vsi,
 	 */
 	fd_data.raw_packet = kzalloc(I40E_FDIR_MAX_RAW_PACKET_LOOKUP,
 				     GFP_KERNEL);
-
-	if (!fd_data.raw_packet) {
-		dev_info(&pf->pdev->dev, "Could not allocate memory\n");
+	if (!fd_data.raw_packet)
 		return -ENOMEM;
-	}
 
 	fd_data.q_index = fsp->ring_cookie;
 	fd_data.flex_off = 0;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index f5caf44..5331fcb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -650,12 +650,9 @@ i40evf_vlan_filter *i40evf_add_vlan(struct i40evf_adapter *adapter, u16 vlan)
 	f = i40evf_find_vlan(adapter, vlan);
 	if (NULL == f) {
 		f = kzalloc(sizeof(*f), GFP_ATOMIC);
-		if (NULL == f) {
-			dev_info(&adapter->pdev->dev,
-				 "%s: no memory for new VLAN filter\n",
-				 __func__);
+		if (NULL == f)
 			return NULL;
-		}
+
 		f->vlan = vlan;
 
 		INIT_LIST_HEAD(&f->list);
@@ -760,8 +757,6 @@ i40evf_mac_filter *i40evf_add_filter(struct i40evf_adapter *adapter,
 	if (NULL == f) {
 		f = kzalloc(sizeof(*f), GFP_ATOMIC);
 		if (NULL == f) {
-			dev_info(&adapter->pdev->dev,
-				 "%s: no memory for new filter\n", __func__);
 			clear_bit(__I40EVF_IN_CRITICAL_TASK,
 				  &adapter->crit_section);
 			return NULL;
@@ -1507,11 +1502,9 @@ static void i40evf_adminq_task(struct work_struct *work)
 
 	event.msg_size = I40EVF_MAX_AQ_BUF_SIZE;
 	event.msg_buf = kzalloc(event.msg_size, GFP_KERNEL);
-	if (!event.msg_buf) {
-		dev_info(&adapter->pdev->dev, "%s: no memory for ARQ clean\n",
-				 __func__);
+	if (!event.msg_buf)
 		return;
-	}
+
 	v_msg = (struct i40e_virtchnl_msg *)&event.desc;
 	do {
 		ret = i40evf_clean_arq_element(hw, &event, &pending);
@@ -1902,11 +1895,8 @@ static void i40evf_init_task(struct work_struct *work)
 				(I40E_MAX_VF_VSI *
 				 sizeof(struct i40e_virtchnl_vsi_resource));
 			adapter->vf_res = kzalloc(bufsz, GFP_KERNEL);
-			if (!adapter->vf_res) {
-				dev_err(&pdev->dev, "%s: unable to allocate memory\n",
-					__func__);
+			if (!adapter->vf_res)
 				goto err;
-			}
 		}
 		err = i40evf_get_vf_config(adapter);
 		if (err == I40E_ERR_ADMIN_QUEUE_NO_WORK)
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index e6978d7..6412485 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -213,11 +213,9 @@ void i40evf_configure_queues(struct i40evf_adapter *adapter)
 	len = sizeof(struct i40e_virtchnl_vsi_queue_config_info) +
 		       (sizeof(struct i40e_virtchnl_queue_pair_info) * pairs);
 	vqci = kzalloc(len, GFP_ATOMIC);
-	if (!vqci) {
-		dev_err(&adapter->pdev->dev, "%s: unable to allocate memory\n",
-			__func__);
+	if (!vqci)
 		return;
-	}
+
 	vqci->vsi_id = adapter->vsi_res->vsi_id;
 	vqci->num_queue_pairs = pairs;
 	vqpi = vqci->qpair;
@@ -326,11 +324,8 @@ void i40evf_map_queues(struct i40evf_adapter *adapter)
 	      (adapter->num_msix_vectors *
 		sizeof(struct i40e_virtchnl_vector_map));
 	vimi = kzalloc(len, GFP_ATOMIC);
-	if (!vimi) {
-		dev_err(&adapter->pdev->dev, "%s: unable to allocate memory\n",
-			__func__);
+	if (!vimi)
 		return;
-	}
 
 	vimi->num_vectors = adapter->num_msix_vectors;
 	/* Queue vectors first */
@@ -396,11 +391,9 @@ void i40evf_add_ether_addrs(struct i40evf_adapter *adapter)
 	}
 
 	veal = kzalloc(len, GFP_ATOMIC);
-	if (!veal) {
-		dev_err(&adapter->pdev->dev, "%s: unable to allocate memory\n",
-			__func__);
+	if (!veal)
 		return;
-	}
+
 	veal->vsi_id = adapter->vsi_res->vsi_id;
 	veal->num_elements = count;
 	list_for_each_entry(f, &adapter->mac_filter_list, list) {
@@ -459,11 +452,9 @@ void i40evf_del_ether_addrs(struct i40evf_adapter *adapter)
 		len = I40EVF_MAX_AQ_BUF_SIZE;
 	}
 	veal = kzalloc(len, GFP_ATOMIC);
-	if (!veal) {
-		dev_err(&adapter->pdev->dev, "%s: unable to allocate memory\n",
-			__func__);
+	if (!veal)
 		return;
-	}
+
 	veal->vsi_id = adapter->vsi_res->vsi_id;
 	veal->num_elements = count;
 	list_for_each_entry_safe(f, ftmp, &adapter->mac_filter_list, list) {
@@ -523,11 +514,9 @@ void i40evf_add_vlans(struct i40evf_adapter *adapter)
 		len = I40EVF_MAX_AQ_BUF_SIZE;
 	}
 	vvfl = kzalloc(len, GFP_ATOMIC);
-	if (!vvfl) {
-		dev_err(&adapter->pdev->dev, "%s: unable to allocate memory\n",
-			__func__);
+	if (!vvfl)
 		return;
-	}
+
 	vvfl->vsi_id = adapter->vsi_res->vsi_id;
 	vvfl->num_elements = count;
 	list_for_each_entry(f, &adapter->vlan_filter_list, list) {
@@ -585,11 +574,9 @@ void i40evf_del_vlans(struct i40evf_adapter *adapter)
 		len = I40EVF_MAX_AQ_BUF_SIZE;
 	}
 	vvfl = kzalloc(len, GFP_ATOMIC);
-	if (!vvfl) {
-		dev_err(&adapter->pdev->dev, "%s: unable to allocate memory\n",
-			__func__);
+	if (!vvfl)
 		return;
-	}
+
 	vvfl->vsi_id = adapter->vsi_res->vsi_id;
 	vvfl->num_elements = count;
 	list_for_each_entry_safe(f, ftmp, &adapter->vlan_filter_list, list) {
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 46d31a4..235ffe4 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2665,8 +2665,6 @@ static int igb_enable_sriov(struct pci_dev *pdev, int num_vfs)
 	/* if allocation failed then we do not support SR-IOV */
 	if (!adapter->vf_data) {
 		adapter->vfs_allocated_count = 0;
-		dev_err(&pdev->dev,
-			"Unable to allocate memory for VF Data Storage\n");
 		err = -ENOMEM;
 		goto out;
 	}
