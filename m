From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/2] qede: Add vlan filtering offload support
Date: Thu, 18 Feb 2016 17:00:40 +0200
Message-ID: <1455807640-28165-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1455807640-28165-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>,
	Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:50534 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1426020AbcBRPBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 10:01:09 -0500
In-Reply-To: <1455807640-28165-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>

Device would start receiving only vlan-tagged traffic with tags matching
that of one of the configured vlan IDs, unless:
  - Device is expliicly placed in PROMISC mode.
  - Device exhausts its vlan filter credits.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h      |  10 +
 drivers/net/ethernet/qlogic/qede/qede_main.c | 277 ++++++++++++++++++++++++++-
 2 files changed, 286 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index f75d9e0..15c5528 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -100,6 +100,12 @@ struct qede_stats {
 	u64 tx_mac_ctrl_frames;
 };
 
+struct qede_vlan {
+	struct list_head list;
+	u16 vid;
+	bool configured;
+};
+
 struct qede_dev {
 	struct qed_dev			*cdev;
 	struct net_device		*ndev;
@@ -154,6 +160,10 @@ struct qede_dev {
 	u16			q_num_rx_buffers; /* Must be a power of two */
 	u16			q_num_tx_buffers; /* Must be a power of two */
 
+	struct list_head vlan_list;
+	u16 configured_vlans;
+	u16 non_configured_vlans;
+	bool accept_any_vlan;
 	struct delayed_work		sp_task;
 	unsigned long			sp_flags;
 };
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index f50e0bd..5f15e23 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1140,6 +1140,21 @@ static int qede_set_ucast_rx_mac(struct qede_dev *edev,
 	return edev->ops->filter_config(edev->cdev, &filter_cmd);
 }
 
+static int qede_set_ucast_rx_vlan(struct qede_dev *edev,
+				  enum qed_filter_xcast_params_type opcode,
+				  u16 vid)
+{
+	struct qed_filter_params filter_cmd;
+
+	memset(&filter_cmd, 0, sizeof(filter_cmd));
+	filter_cmd.type = QED_FILTER_TYPE_UCAST;
+	filter_cmd.filter.ucast.type = opcode;
+	filter_cmd.filter.ucast.vlan_valid = 1;
+	filter_cmd.filter.ucast.vlan = vid;
+
+	return edev->ops->filter_config(edev->cdev, &filter_cmd);
+}
+
 void qede_fill_by_demand_stats(struct qede_dev *edev)
 {
 	struct qed_eth_stats stats;
@@ -1252,6 +1267,247 @@ static struct rtnl_link_stats64 *qede_get_stats64(
 	return stats;
 }
 
+static void qede_config_accept_any_vlan(struct qede_dev *edev, bool action)
+{
+	struct qed_update_vport_params params;
+	int rc;
+
+	/* Proceed only if action actually needs to be performed */
+	if (edev->accept_any_vlan == action)
+		return;
+
+	memset(&params, 0, sizeof(params));
+
+	params.vport_id = 0;
+	params.accept_any_vlan = action;
+	params.update_accept_any_vlan_flg = 1;
+
+	rc = edev->ops->vport_update(edev->cdev, &params);
+	if (rc) {
+		DP_ERR(edev, "Failed to %s accept-any-vlan\n",
+		       action ? "enable" : "disable");
+	} else {
+		DP_INFO(edev, "%s accept-any-vlan\n",
+			action ? "enabled" : "disabled");
+		edev->accept_any_vlan = action;
+	}
+}
+
+static int qede_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	struct qede_vlan *vlan, *tmp;
+	int rc;
+
+	DP_VERBOSE(edev, NETIF_MSG_IFUP, "Adding vlan 0x%04x\n", vid);
+
+	vlan = kzalloc(sizeof(*vlan), GFP_KERNEL);
+	if (!vlan) {
+		DP_INFO(edev, "Failed to allocate struct for vlan\n");
+		return -ENOMEM;
+	}
+	INIT_LIST_HEAD(&vlan->list);
+	vlan->vid = vid;
+	vlan->configured = false;
+
+	/* Verify vlan isn't already configured */
+	list_for_each_entry(tmp, &edev->vlan_list, list) {
+		if (tmp->vid == vlan->vid) {
+			DP_VERBOSE(edev, (NETIF_MSG_IFUP | NETIF_MSG_IFDOWN),
+				   "vlan already configured\n");
+			kfree(vlan);
+			return -EEXIST;
+		}
+	}
+
+	/* If interface is down, cache this VLAN ID and return */
+	if (edev->state != QEDE_STATE_OPEN) {
+		DP_VERBOSE(edev, NETIF_MSG_IFDOWN,
+			   "Interface is down, VLAN %d will be configured when interface is up\n",
+			   vid);
+		if (vid != 0)
+			edev->non_configured_vlans++;
+		list_add(&vlan->list, &edev->vlan_list);
+
+		return 0;
+	}
+
+	/* Check for the filter limit.
+	 * Note - vlan0 has a reserved filter and can be added without
+	 * worrying about quota
+	 */
+	if ((edev->configured_vlans < edev->dev_info.num_vlan_filters) ||
+	    (vlan->vid == 0)) {
+		rc = qede_set_ucast_rx_vlan(edev,
+					    QED_FILTER_XCAST_TYPE_ADD,
+					    vlan->vid);
+		if (rc) {
+			DP_ERR(edev, "Failed to configure VLAN %d\n",
+			       vlan->vid);
+			kfree(vlan);
+			return -EINVAL;
+		}
+		vlan->configured = true;
+
+		/* vlan0 filter isn't consuming out of our quota */
+		if (vlan->vid != 0)
+			edev->configured_vlans++;
+	} else {
+		/* Out of quota; Activate accept-any-VLAN mode */
+		if (!edev->non_configured_vlans)
+			qede_config_accept_any_vlan(edev, true);
+
+		edev->non_configured_vlans++;
+	}
+
+	list_add(&vlan->list, &edev->vlan_list);
+
+	return 0;
+}
+
+static void qede_del_vlan_from_list(struct qede_dev *edev,
+				    struct qede_vlan *vlan)
+{
+	/* vlan0 filter isn't consuming out of our quota */
+	if (vlan->vid != 0) {
+		if (vlan->configured)
+			edev->configured_vlans--;
+		else
+			edev->non_configured_vlans--;
+	}
+
+	list_del(&vlan->list);
+	kfree(vlan);
+}
+
+static int qede_configure_vlan_filters(struct qede_dev *edev)
+{
+	int rc = 0, real_rc = 0, accept_any_vlan = 0;
+	struct qed_dev_eth_info *dev_info;
+	struct qede_vlan *vlan = NULL;
+
+	if (list_empty(&edev->vlan_list))
+		return 0;
+
+	dev_info = &edev->dev_info;
+
+	/* Configure non-configured vlans */
+	list_for_each_entry(vlan, &edev->vlan_list, list) {
+		if (vlan->configured)
+			continue;
+
+		/* We have used all our credits, now enable accept_any_vlan */
+		if ((vlan->vid != 0) &&
+		    (edev->configured_vlans == dev_info->num_vlan_filters)) {
+			accept_any_vlan = 1;
+			continue;
+		}
+
+		DP_VERBOSE(edev, NETIF_MSG_IFUP, "Adding vlan %d\n", vlan->vid);
+
+		rc = qede_set_ucast_rx_vlan(edev, QED_FILTER_XCAST_TYPE_ADD,
+					    vlan->vid);
+		if (rc) {
+			DP_ERR(edev, "Failed to configure VLAN %u\n",
+			       vlan->vid);
+			real_rc = rc;
+			continue;
+		}
+
+		vlan->configured = true;
+		/* vlan0 filter doesn't consume our VLAN filter's quota */
+		if (vlan->vid != 0) {
+			edev->non_configured_vlans--;
+			edev->configured_vlans++;
+		}
+	}
+
+	/* enable accept_any_vlan mode if we have more VLANs than credits,
+	 * or remove accept_any_vlan mode if we've actually removed
+	 * a non-configured vlan, and all remaining vlans are truly configured.
+	 */
+
+	if (accept_any_vlan)
+		qede_config_accept_any_vlan(edev, true);
+	else if (!edev->non_configured_vlans)
+		qede_config_accept_any_vlan(edev, false);
+
+	return real_rc;
+}
+
+static int qede_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	struct qede_vlan *vlan = NULL;
+	int rc;
+
+	DP_VERBOSE(edev, NETIF_MSG_IFDOWN, "Removing vlan 0x%04x\n", vid);
+
+	/* Find whether entry exists */
+	list_for_each_entry(vlan, &edev->vlan_list, list)
+		if (vlan->vid == vid)
+			break;
+
+	if (!vlan || (vlan->vid != vid)) {
+		DP_VERBOSE(edev, (NETIF_MSG_IFUP | NETIF_MSG_IFDOWN),
+			   "Vlan isn't configured\n");
+		return 0;
+	}
+
+	if (edev->state != QEDE_STATE_OPEN) {
+		/* As interface is already down, we don't have a VPORT
+		 * instance to remove vlan filter. So just update vlan list
+		 */
+		DP_VERBOSE(edev, NETIF_MSG_IFDOWN,
+			   "Interface is down, removing VLAN from list only\n");
+		qede_del_vlan_from_list(edev, vlan);
+		return 0;
+	}
+
+	/* Remove vlan */
+	rc = qede_set_ucast_rx_vlan(edev, QED_FILTER_XCAST_TYPE_DEL, vid);
+	if (rc) {
+		DP_ERR(edev, "Failed to remove VLAN %d\n", vid);
+		return -EINVAL;
+	}
+
+	qede_del_vlan_from_list(edev, vlan);
+
+	/* We have removed a VLAN - try to see if we can
+	 * configure non-configured VLAN from the list.
+	 */
+	rc = qede_configure_vlan_filters(edev);
+
+	return rc;
+}
+
+static void qede_vlan_mark_nonconfigured(struct qede_dev *edev)
+{
+	struct qede_vlan *vlan = NULL;
+
+	if (list_empty(&edev->vlan_list))
+		return;
+
+	list_for_each_entry(vlan, &edev->vlan_list, list) {
+		if (!vlan->configured)
+			continue;
+
+		vlan->configured = false;
+
+		/* vlan0 filter isn't consuming out of our quota */
+		if (vlan->vid != 0) {
+			edev->non_configured_vlans++;
+			edev->configured_vlans--;
+		}
+
+		DP_VERBOSE(edev, NETIF_MSG_IFDOWN,
+			   "marked vlan %d as non-configured\n",
+			   vlan->vid);
+	}
+
+	edev->accept_any_vlan = false;
+}
+
 static const struct net_device_ops qede_netdev_ops = {
 	.ndo_open = qede_open,
 	.ndo_stop = qede_close,
@@ -1260,6 +1516,8 @@ static const struct net_device_ops qede_netdev_ops = {
 	.ndo_set_mac_address = qede_set_mac_addr,
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_change_mtu = qede_change_mtu,
+	.ndo_vlan_rx_add_vid = qede_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid = qede_vlan_rx_kill_vid,
 	.ndo_get_stats64 = qede_get_stats64,
 };
 
@@ -1304,6 +1562,8 @@ static struct qede_dev *qede_alloc_etherdev(struct qed_dev *cdev,
 
 	edev->num_tc = edev->dev_info.num_tc;
 
+	INIT_LIST_HEAD(&edev->vlan_list);
+
 	return edev;
 }
 
@@ -1335,7 +1595,7 @@ static void qede_init_ndev(struct qede_dev *edev)
 			      NETIF_F_HIGHDMA;
 	ndev->features = hw_features | NETIF_F_RXHASH | NETIF_F_RXCSUM |
 			 NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HIGHDMA |
-			 NETIF_F_HW_VLAN_CTAG_TX;
+			 NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_HW_VLAN_CTAG_TX;
 
 	ndev->hw_features = hw_features;
 
@@ -2342,6 +2602,7 @@ static void qede_unload(struct qede_dev *edev, enum qede_unload_mode mode)
 
 	DP_INFO(edev, "Stopped Queues\n");
 
+	qede_vlan_mark_nonconfigured(edev);
 	edev->ops->fastpath_stop(edev->cdev);
 
 	/* Release the interrupts */
@@ -2410,6 +2671,9 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode)
 	edev->state = QEDE_STATE_OPEN;
 	mutex_unlock(&edev->qede_lock);
 
+	/* Program un-configured VLANs */
+	qede_configure_vlan_filters(edev);
+
 	/* Ask for link-up using current configuration */
 	memset(&link_params, 0, sizeof(link_params));
 	link_params.link_up = true;
@@ -2670,6 +2934,17 @@ static void qede_config_rx_mode(struct net_device *ndev)
 			goto out;
 	}
 
+	/* take care of VLAN mode */
+	if (ndev->flags & IFF_PROMISC) {
+		qede_config_accept_any_vlan(edev, true);
+	} else if (!edev->non_configured_vlans) {
+		/* It's possible that accept_any_vlan mode is set due to a
+		 * previous setting of IFF_PROMISC. If vlan credits are
+		 * sufficient, disable accept_any_vlan.
+		 */
+		qede_config_accept_any_vlan(edev, false);
+	}
+
 	rx_mode.filter.accept_flags = accept_flags;
 	edev->ops->filter_config(edev->cdev, &rx_mode);
 out:
-- 
1.9.3
