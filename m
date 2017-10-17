From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [RFC PATCH next 2/2] i40e: add support for macvlan hardware offload
Date: Tue, 17 Oct 2017 14:18:09 -0700
Message-ID: <1508275089-430113-3-git-send-email-shannon.nelson@oracle.com>
References: <1508275089-430113-1-git-send-email-shannon.nelson@oracle.com>
Cc: netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38766 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937660AbdJQVVX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 17:21:23 -0400
In-Reply-To: <1508275089-430113-1-git-send-email-shannon.nelson@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for macvlan hardware offload (l2-fwd-offload)
feature using the XL710's macvlan-to-queue filtering machanism.  These
are most useful for supporting separate mac addresses for Container
virtualization using Docker and similar configurations.

The basic design is to partition off some of the PF's general LAN queues
outside of the standard RSS pool and use them as the offload queues.
This especially makes sense on machines with more than 64 CPUs: since
the RSS pool is limited to a maximum of 64, the queues assigned to the
remaining CPUs essentially go unused.  When on a machine with fewer than
64 CPUs, we shrink the RSS pool and use the upper queues for the offload.

If the user has added Flow Director filters, enabling of macvlan offload
is disallowed.

To use this feature, use ethtool to enable l2-fwd-offload
	ethtool -K ethX l2-fwd-offload on
When the next macvlan devices are created on ethX, the macvlan driver
will automatically attempt to setup the hardweare offload.

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |   10 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |   15 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  239 +++++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h    |    1 +
 4 files changed, 264 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index a187f53..4868ae2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -365,6 +365,10 @@ struct i40e_pf {
 	u8 atr_sample_rate;
 	bool wol_en;
 
+	u16 macvlan_hint;
+	u16 macvlan_used;
+	u16 macvlan_num;
+
 	struct hlist_head fdir_filter_list;
 	u16 fdir_pf_active_filters;
 	unsigned long fd_flush_timestamp;
@@ -712,6 +716,12 @@ struct i40e_netdev_priv {
 	struct i40e_vsi *vsi;
 };
 
+struct i40e_fwd {
+	struct net_device *vdev;
+	u16 tx_base_queue;
+	/* future expansion here might include number of queues */
+};
+
 /* struct that defines an interrupt vector */
 struct i40e_q_vector {
 	struct i40e_vsi *vsi;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index afd3ca8..e1628c1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -3817,6 +3817,13 @@ static int i40e_set_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *cmd)
 	struct i40e_pf *pf = vsi->back;
 	int ret = -EOPNOTSUPP;
 
+	if (pf->macvlan_num) {
+		dev_warn(&pf->pdev->dev,
+			 "Remove %d remaining macvlan offloads to change filter options\n",
+			 pf->macvlan_used);
+		return -EBUSY;
+	}
+
 	switch (cmd->cmd) {
 	case ETHTOOL_SRXFH:
 		ret = i40e_set_rss_hash_opt(pf, cmd);
@@ -3909,6 +3916,14 @@ static int i40e_set_channels(struct net_device *dev,
 	if (count > i40e_max_channels(vsi))
 		return -EINVAL;
 
+	/* verify that macvlan offloads are not in use */
+	if (pf->macvlan_num) {
+		dev_warn(&pf->pdev->dev,
+			 "Remove %d remaining macvlan offloads to change channel count\n",
+			 pf->macvlan_used);
+		return -EBUSY;
+	}
+
 	/* verify that the number of channels does not invalidate any current
 	 * flow director rules
 	 */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e4b8a4b..7b26c6f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9221,6 +9221,66 @@ static void i40e_clear_rss_lut(struct i40e_vsi *vsi)
 }
 
 /**
+ * i40e_fix_features - fix the proposed netdev feature flags
+ * @netdev: ptr to the netdev being adjusted
+ * @features: the feature set that the stack is suggesting
+ * Note: expects to be called while under rtnl_lock()
+ **/
+static netdev_features_t i40e_fix_features(struct net_device *netdev,
+					   netdev_features_t features)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_pf *pf = np->vsi->back;
+	struct i40e_vsi *vsi = np->vsi;
+
+	/* make sure there are queues to be used for macvlan offload */
+	if (features & NETIF_F_HW_L2FW_DOFFLOAD &&
+	    !(netdev->features & NETIF_F_HW_L2FW_DOFFLOAD)) {
+		const u8 drop = I40E_FILTER_PROGRAM_DESC_DEST_DROP_PACKET;
+		struct i40e_fdir_filter *rule;
+		struct hlist_node *node2;
+		u16 rss, unused;
+
+		/* Find a set of queues to be used for macvlan offload.
+		 * If there aren't many queues outside of the RSS set
+		 * that could be used for macvlan, try shrinking the
+		 * set to free up some queues, after checking if there
+		 * are any Flow Director rules we might break.
+		 */
+
+		rss = vsi->rss_size;
+		unused = vsi->num_queue_pairs - rss;
+		if (unused < (vsi->rss_size / 2)) {
+			rss = vsi->rss_size / 2;
+			unused = vsi->num_q_vectors - rss;
+		}
+		pf->macvlan_num = unused;
+
+		/* check the flow director rules */
+		hlist_for_each_entry_safe(rule, node2,
+					  &pf->fdir_filter_list, fdir_node) {
+			if (rule->dest_ctl != drop && rss <= rule->q_index) {
+				dev_warn(&pf->pdev->dev,
+					 "Remove user defined filter %d to enable macvlan offload\n",
+					 rule->fd_id);
+				features &= ~NETIF_F_HW_L2FW_DOFFLOAD;
+				pf->macvlan_num = 0;
+			}
+		}
+	} else if (!(features & NETIF_F_HW_L2FW_DOFFLOAD) &&
+		    netdev->features & NETIF_F_HW_L2FW_DOFFLOAD) {
+		if (pf->macvlan_used) {
+			dev_warn(&pf->pdev->dev,
+				 "Remove %d remaining macvlan offloads to disable macvlan offload\n",
+				 pf->macvlan_used);
+			features |= NETIF_F_HW_L2FW_DOFFLOAD;
+		}
+	}
+
+	return features;
+}
+
+/**
  * i40e_set_features - set the netdev feature flags
  * @netdev: ptr to the netdev being adjusted
  * @features: the feature set that the stack is suggesting
@@ -9247,6 +9307,45 @@ static int i40e_set_features(struct net_device *netdev,
 
 	need_reset = i40e_set_ntuple(pf, features);
 
+	/* keep this section last in this function as it
+	 * might take care of the need_reset for the others
+	 */
+	if (features & NETIF_F_HW_L2FW_DOFFLOAD &&
+	    !(netdev->features & NETIF_F_HW_L2FW_DOFFLOAD)) {
+		/* reserve queues for macvlan use */
+		u16 rss = vsi->num_q_vectors - pf->macvlan_num;
+
+		if (rss != vsi->rss_size) {
+			if (i40e_reconfig_rss_queues(pf, rss))
+				need_reset = false;
+		}
+
+		pf->macvlan_hint = rss;
+		pf->macvlan_used = 0;
+
+	} else if (!(features & NETIF_F_HW_L2FW_DOFFLOAD) &&
+		    netdev->features & NETIF_F_HW_L2FW_DOFFLOAD) {
+		/* return macvlan queues to general use */
+		int num_qs = vsi->rss_size + pf->macvlan_num;
+		int i;
+
+		/* stop the upperdev queues if not already stopped */
+		for (i = vsi->rss_size; i < num_qs; i++) {
+			struct i40e_fwd *fwd = vsi->tx_rings[i]->fwd;
+
+			if (fwd)
+				netif_tx_stop_all_queues(fwd->vdev);
+		}
+
+		/* rebuild the rss layout with the restored queues */
+		if (i40e_reconfig_rss_queues(pf, num_qs))
+			need_reset = false;
+
+		pf->macvlan_hint = 0;
+		pf->macvlan_used = 0;
+		pf->macvlan_num = 0;
+	}
+
 	if (need_reset)
 		i40e_do_reset(pf, BIT_ULL(__I40E_PF_RESET_REQUESTED), true);
 
@@ -9674,6 +9773,137 @@ static int i40e_xdp(struct net_device *dev,
 	}
 }
 
+/**
+ * i40e_select_queue - select the Tx queue, watching for macvlan offloads
+ * @dev: netdevice
+ * @skb: packet to be sent
+ * @accel_priv: hint for offloading macvlan
+ * @fallback: alternative function to use if we don't care which Tx
+ **/
+static u16 i40e_select_queue(struct net_device *dev, struct sk_buff *skb,
+			     void *accel_priv, select_queue_fallback_t fallback)
+{
+	struct i40e_fwd *fwd = accel_priv;
+
+	if (fwd)
+		return fwd->tx_base_queue;
+
+	return fallback(dev, skb);
+}
+
+/**
+ * i40e_fwd_add - add a macvlan offload
+ * @pdev: the lower physical device
+ * @vdev: the upper macvlan device
+ **/
+static void *i40e_fwd_add(struct net_device *pdev, struct net_device *vdev)
+{
+	struct i40e_netdev_priv *np = netdev_priv(pdev);
+	struct i40e_pf *pf = np->vsi->back;
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_fwd *fwd = NULL;
+	struct i40e_mac_filter *f;
+	int i;
+
+	if (vdev->num_tx_queues != 1 ||
+	    vdev->num_rx_queues != vdev->num_tx_queues) {
+		netdev_info(pdev, "Macvlan offload for Rx/Tx single queue only\n");
+		return ERR_PTR(-EINVAL);
+	}
+
+	if (!(pf->macvlan_num - pf->macvlan_used)) {
+		netdev_err(pdev, "No macvlan offload slots left\n");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	if (i40e_find_mac(vsi, vdev->dev_addr)) {
+		netdev_err(pdev, "MAC address %pM already in use\n",
+			   vdev->dev_addr);
+		return ERR_PTR(-EINVAL);
+	}
+
+	/* create the fwd struct */
+	fwd = kzalloc(sizeof(*fwd), GFP_KERNEL);
+	if (!fwd)
+		return ERR_PTR(-ENOMEM);
+
+	/* find the next available macvlan queue */
+	if (!pf->macvlan_hint)
+		pf->macvlan_hint = vsi->rss_size;
+	for (i = pf->macvlan_hint; i < vsi->alloc_queue_pairs; i++) {
+		if (!vsi->tx_rings[i]->fwd) {
+			vsi->tx_rings[i]->fwd = fwd;
+
+			fwd->tx_base_queue = i;
+			fwd->vdev = vdev;
+
+			pf->macvlan_hint = i + 1;
+			break;
+		}
+	}
+	if (!fwd->tx_base_queue) {
+		netdev_err(pdev, "No available queue found for macvlan %s\n",
+			   vdev->name);
+		goto no_queue;
+	}
+	pf->macvlan_used++;
+
+	/* set the mac address */
+	spin_lock_bh(&vsi->mac_filter_hash_lock);
+	f = i40e_add_mac_filter(vsi, vdev->dev_addr, fwd->tx_base_queue);
+	spin_unlock_bh(&vsi->mac_filter_hash_lock);
+	if (!f) {
+		netdev_err(pdev, "Failed to add macaddr %pM for macvlan %s\n",
+			   vdev->dev_addr, vdev->name);
+		goto no_open;
+	}
+
+	netdev_info(pdev, "%s: queue %d for macvlan %s\n",
+		    __func__, fwd->tx_base_queue, vdev->name);
+
+	if (netif_running(pdev))
+		netif_tx_start_all_queues(vdev);
+	else
+		netdev_info(pdev, "Macvlan %s offload start pending\n",
+			    vdev->name);
+
+	return fwd;
+
+no_open:
+	vsi->tx_rings[fwd->tx_base_queue]->fwd = NULL;
+no_queue:
+	fwd->vdev = NULL;
+	kfree(fwd);
+	return ERR_PTR(-EBUSY);
+}
+
+/**
+ * i40e_fwd_del - remove a macvlan offload
+ * @pdev: the lower physical device
+ * @priv: the private pointer for the offload information
+ **/
+static void i40e_fwd_del(struct net_device *pdev, void *priv)
+{
+	struct i40e_netdev_priv *np = netdev_priv(pdev);
+	struct i40e_pf *pf = np->vsi->back;
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_fwd *fwd = priv;
+
+	spin_lock_bh(&vsi->mac_filter_hash_lock);
+	i40e_del_mac_filter(vsi, fwd->vdev->dev_addr, fwd->tx_base_queue);
+	spin_unlock_bh(&vsi->mac_filter_hash_lock);
+
+	vsi->tx_rings[fwd->tx_base_queue]->fwd = NULL;
+	fwd->tx_base_queue = 0;
+	fwd->vdev = NULL;
+
+	if (!pf->macvlan_hint || pf->macvlan_hint > fwd->tx_base_queue)
+		pf->macvlan_hint = fwd->tx_base_queue;
+	pf->macvlan_used--;
+
+	kfree(fwd);
+}
+
 static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_open		= i40e_open,
 	.ndo_stop		= i40e_close,
@@ -9691,6 +9921,7 @@ static int i40e_xdp(struct net_device *dev,
 	.ndo_poll_controller	= i40e_netpoll,
 #endif
 	.ndo_setup_tc		= __i40e_setup_tc,
+	.ndo_fix_features	= i40e_fix_features,
 	.ndo_set_features	= i40e_set_features,
 	.ndo_set_vf_mac		= i40e_ndo_set_vf_mac,
 	.ndo_set_vf_vlan	= i40e_ndo_set_vf_port_vlan,
@@ -9707,6 +9938,9 @@ static int i40e_xdp(struct net_device *dev,
 	.ndo_bridge_getlink	= i40e_ndo_bridge_getlink,
 	.ndo_bridge_setlink	= i40e_ndo_bridge_setlink,
 	.ndo_xdp		= i40e_xdp,
+	.ndo_select_queue	= i40e_select_queue,
+	.ndo_dfwd_add_station	= i40e_fwd_add,
+	.ndo_dfwd_del_station	= i40e_fwd_del,
 };
 
 /**
@@ -9776,6 +10010,8 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	netdev->hw_enc_features |= NETIF_F_TSO_MANGLEID;
 
 	if (vsi->type == I40E_VSI_MAIN) {
+		netdev->hw_features |= NETIF_F_HW_L2FW_DOFFLOAD;
+
 		SET_NETDEV_DEV(netdev, &pf->pdev->dev);
 		ether_addr_copy(mac_addr, hw->mac.perm_addr);
 		/* The following steps are necessary for two reasons. First,
@@ -11209,7 +11445,8 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 		/* limit lan qps to the smaller of qps, cpus or msix */
 		q_max = max_t(int, pf->rss_size_max, num_online_cpus());
 		q_max = min_t(int, q_max, pf->hw.func_caps.num_tx_qp);
-		q_max = min_t(int, q_max, pf->hw.func_caps.num_msix_vectors);
+		q_max = min_t(int, q_max,
+			      (pf->hw.func_caps.num_msix_vectors - 1));
 		pf->num_lan_qps = q_max;
 
 		queues_left -= pf->num_lan_qps;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index a4e3e66..8a0ea20 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -363,6 +363,7 @@ struct i40e_ring {
 	struct device *dev;		/* Used for DMA mapping */
 	struct net_device *netdev;	/* netdev ring maps to */
 	struct bpf_prog *xdp_prog;
+	struct i40e_fwd *fwd;		/* macvlan forwarding */
 	union {
 		struct i40e_tx_buffer *tx_bi;
 		struct i40e_rx_buffer *rx_bi;
-- 
1.7.1
