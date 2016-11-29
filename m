From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v2 net-next 06/11] qede: Revise state locking scheme
Date: Tue, 29 Nov 2016 16:47:05 +0200
Message-ID: <1480430830-17671-7-git-send-email-Yuval.Mintz@cavium.com>
References: <1480430830-17671-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:52295 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1757891AbcK2Ord (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 09:47:33 -0500
In-Reply-To: <1480430830-17671-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As qede utilizes an internal-reload sequence as result of various
configuration changes, the netif state wouldn't always accurately describe
the status of the configuration.
To compensate, we're storing an internal state of the device, which should
only be accessed under the qede_lock.

This patch fixes and improves several state/lock interactions:
  - The internal state should only be checked while locked.
  - While holding lock, it's preferable to check state rather than
    the netdevice's state.
  - The reload sequence is not 'atomic' - unload and subsequent load
    are not in the same critical section.

This also add the 'locked' variant for the reload, which would later be
used by XDP - useful in the case where the correct sequence is 'lock,
check state and re-configure if good', instead of allowing the reload
itself to make the decision regarding the configurability of the device.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h         |  14 ++-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |  37 +++---
 drivers/net/ethernet/qlogic/qede/qede_main.c    | 146 +++++++++++++++---------
 3 files changed, 122 insertions(+), 75 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index b9584b2..e0a94bc 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -338,8 +338,12 @@ struct qede_fastpath {
 #define QEDE_SP_VXLAN_PORT_CONFIG	2
 #define QEDE_SP_GENEVE_PORT_CONFIG	3
 
-union qede_reload_args {
-	u16 mtu;
+struct qede_reload_args {
+	void (*func)(struct qede_dev *edev, struct qede_reload_args *args);
+	union {
+		netdev_features_t features;
+		u16 mtu;
+	} u;
 };
 
 #ifdef CONFIG_DCB
@@ -348,11 +352,11 @@ struct qede_fastpath {
 void qede_config_debug(uint debug, u32 *p_dp_module, u8 *p_dp_level);
 void qede_set_ethtool_ops(struct net_device *netdev);
 void qede_reload(struct qede_dev *edev,
-		 void (*func)(struct qede_dev *edev,
-			      union qede_reload_args *args),
-		 union qede_reload_args *args);
+		 struct qede_reload_args *args, bool is_locked);
 int qede_change_mtu(struct net_device *dev, int new_mtu);
 void qede_fill_by_demand_stats(struct qede_dev *edev);
+void __qede_lock(struct qede_dev *edev);
+void __qede_unlock(struct qede_dev *edev);
 bool qede_has_rx_work(struct qede_rx_queue *rxq);
 int qede_txq_has_work(struct qede_tx_queue *txq);
 void qede_recycle_rx_bd_ring(struct qede_rx_queue *rxq, struct qede_dev *edev,
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index d2c23d1..ef8c327 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -258,7 +258,9 @@ static void qede_get_ethtool_stats(struct net_device *dev,
 
 	qede_fill_by_demand_stats(edev);
 
-	mutex_lock(&edev->qede_lock);
+	/* Need to protect the access to the fastpath array */
+	__qede_lock(edev);
+
 	for (i = 0; i < QEDE_QUEUE_CNT(edev); i++) {
 		fp = &edev->fp_array[i];
 
@@ -278,7 +280,7 @@ static void qede_get_ethtool_stats(struct net_device *dev,
 		buf++;
 	}
 
-	mutex_unlock(&edev->qede_lock);
+	__qede_unlock(edev);
 }
 
 static int qede_get_sset_count(struct net_device *dev, int stringset)
@@ -374,6 +376,8 @@ static int qede_get_link_ksettings(struct net_device *dev,
 	struct qede_dev *edev = netdev_priv(dev);
 	struct qed_link_output current_link;
 
+	__qede_lock(edev);
+
 	memset(&current_link, 0, sizeof(current_link));
 	edev->ops->common->get_link(edev->cdev, &current_link);
 
@@ -393,6 +397,9 @@ static int qede_get_link_ksettings(struct net_device *dev,
 		base->speed = SPEED_UNKNOWN;
 		base->duplex = DUPLEX_UNKNOWN;
 	}
+
+	__qede_unlock(edev);
+
 	base->port = current_link.port;
 	base->autoneg = (current_link.autoneg) ? AUTONEG_ENABLE :
 			AUTONEG_DISABLE;
@@ -701,8 +708,7 @@ static int qede_set_ringparam(struct net_device *dev,
 	edev->q_num_rx_buffers = ering->rx_pending;
 	edev->q_num_tx_buffers = ering->tx_pending;
 
-	if (netif_running(edev->ndev))
-		qede_reload(edev, NULL, NULL);
+	qede_reload(edev, NULL, false);
 
 	return 0;
 }
@@ -787,29 +793,27 @@ static int qede_get_regs_len(struct net_device *ndev)
 		return -EINVAL;
 }
 
-static void qede_update_mtu(struct qede_dev *edev, union qede_reload_args *args)
+static void qede_update_mtu(struct qede_dev *edev,
+			    struct qede_reload_args *args)
 {
-	edev->ndev->mtu = args->mtu;
+	edev->ndev->mtu = args->u.mtu;
 }
 
 /* Netdevice NDOs */
 int qede_change_mtu(struct net_device *ndev, int new_mtu)
 {
 	struct qede_dev *edev = netdev_priv(ndev);
-	union qede_reload_args args;
+	struct qede_reload_args args;
 
 	DP_VERBOSE(edev, (NETIF_MSG_IFUP | NETIF_MSG_IFDOWN),
 		   "Configuring MTU size of %d\n", new_mtu);
 
-	/* Set the mtu field and re-start the interface if needed*/
-	args.mtu = new_mtu;
-
-	if (netif_running(edev->ndev))
-		qede_reload(edev, &qede_update_mtu, &args);
-
-	qede_update_mtu(edev, &args);
+	/* Set the mtu field and re-start the interface if needed */
+	args.u.mtu = new_mtu;
+	args.func = &qede_update_mtu;
+	qede_reload(edev, &args, false);
 
-	edev->ops->common->update_mtu(edev->cdev, args.mtu);
+	edev->ops->common->update_mtu(edev->cdev, new_mtu);
 
 	return 0;
 }
@@ -893,8 +897,7 @@ static int qede_set_channels(struct net_device *dev,
 		       sizeof(edev->rss_params.rss_ind_table));
 	}
 
-	if (netif_running(dev))
-		qede_reload(edev, NULL, NULL);
+	qede_reload(edev, NULL, false);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index acc350b..8774f8e 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -100,6 +100,19 @@ static int qede_alloc_rx_buffer(struct qede_dev *edev,
 				struct qede_rx_queue *rxq);
 static void qede_link_update(void *dev, struct qed_link_output *link);
 
+/* The qede lock is used to protect driver state change and driver flows that
+ * are not reentrant.
+ */
+void __qede_lock(struct qede_dev *edev)
+{
+	mutex_lock(&edev->qede_lock);
+}
+
+void __qede_unlock(struct qede_dev *edev)
+{
+	mutex_unlock(&edev->qede_lock);
+}
+
 #ifdef CONFIG_QED_SRIOV
 static int qede_set_vf_vlan(struct net_device *ndev, int vf, u16 vlan, u8 qos,
 			    __be16 vlan_proto)
@@ -1952,7 +1965,7 @@ static int qede_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 {
 	struct qede_dev *edev = netdev_priv(dev);
 	struct qede_vlan *vlan, *tmp;
-	int rc;
+	int rc = 0;
 
 	DP_VERBOSE(edev, NETIF_MSG_IFUP, "Adding vlan 0x%04x\n", vid);
 
@@ -1976,6 +1989,7 @@ static int qede_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 	}
 
 	/* If interface is down, cache this VLAN ID and return */
+	__qede_lock(edev);
 	if (edev->state != QEDE_STATE_OPEN) {
 		DP_VERBOSE(edev, NETIF_MSG_IFDOWN,
 			   "Interface is down, VLAN %d will be configured when interface is up\n",
@@ -1983,8 +1997,7 @@ static int qede_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 		if (vid != 0)
 			edev->non_configured_vlans++;
 		list_add(&vlan->list, &edev->vlan_list);
-
-		return 0;
+		goto out;
 	}
 
 	/* Check for the filter limit.
@@ -2000,7 +2013,7 @@ static int qede_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 			DP_ERR(edev, "Failed to configure VLAN %d\n",
 			       vlan->vid);
 			kfree(vlan);
-			return -EINVAL;
+			goto out;
 		}
 		vlan->configured = true;
 
@@ -2017,7 +2030,9 @@ static int qede_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
 
 	list_add(&vlan->list, &edev->vlan_list);
 
-	return 0;
+out:
+	__qede_unlock(edev);
+	return rc;
 }
 
 static void qede_del_vlan_from_list(struct qede_dev *edev,
@@ -2094,11 +2109,12 @@ static int qede_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
 {
 	struct qede_dev *edev = netdev_priv(dev);
 	struct qede_vlan *vlan = NULL;
-	int rc;
+	int rc = 0;
 
 	DP_VERBOSE(edev, NETIF_MSG_IFDOWN, "Removing vlan 0x%04x\n", vid);
 
 	/* Find whether entry exists */
+	__qede_lock(edev);
 	list_for_each_entry(vlan, &edev->vlan_list, list)
 		if (vlan->vid == vid)
 			break;
@@ -2106,7 +2122,7 @@ static int qede_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
 	if (!vlan || (vlan->vid != vid)) {
 		DP_VERBOSE(edev, (NETIF_MSG_IFUP | NETIF_MSG_IFDOWN),
 			   "Vlan isn't configured\n");
-		return 0;
+		goto out;
 	}
 
 	if (edev->state != QEDE_STATE_OPEN) {
@@ -2116,7 +2132,7 @@ static int qede_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
 		DP_VERBOSE(edev, NETIF_MSG_IFDOWN,
 			   "Interface is down, removing VLAN from list only\n");
 		qede_del_vlan_from_list(edev, vlan);
-		return 0;
+		goto out;
 	}
 
 	/* Remove vlan */
@@ -2125,7 +2141,7 @@ static int qede_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
 					    vid);
 		if (rc) {
 			DP_ERR(edev, "Failed to remove VLAN %d\n", vid);
-			return -EINVAL;
+			goto out;
 		}
 	}
 
@@ -2136,6 +2152,8 @@ static int qede_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
 	 */
 	rc = qede_configure_vlan_filters(edev);
 
+out:
+	__qede_unlock(edev);
 	return rc;
 }
 
@@ -2165,7 +2183,13 @@ static void qede_vlan_mark_nonconfigured(struct qede_dev *edev)
 	edev->accept_any_vlan = false;
 }
 
-static int qede_set_features(struct net_device *dev, netdev_features_t features)
+static void qede_set_features_reload(struct qede_dev *edev,
+				     struct qede_reload_args *args)
+{
+	edev->ndev->features = args->u.features;
+}
+
+int qede_set_features(struct net_device *dev, netdev_features_t features)
 {
 	struct qede_dev *edev = netdev_priv(dev);
 	netdev_features_t changes = features ^ dev->features;
@@ -2179,9 +2203,14 @@ static int qede_set_features(struct net_device *dev, netdev_features_t features)
 			need_reload = edev->gro_disable;
 	}
 
-	if (need_reload && netif_running(edev->ndev)) {
-		dev->features = features;
-		qede_reload(edev, NULL, NULL);
+	if (need_reload) {
+		struct qede_reload_args args;
+
+		args.u.features = features;
+		args.func = &qede_set_features_reload;
+
+		qede_reload(edev, &args, false);
+
 		return 1;
 	}
 
@@ -2528,12 +2557,11 @@ static void qede_sp_task(struct work_struct *work)
 					     sp_task.work);
 	struct qed_dev *cdev = edev->cdev;
 
-	mutex_lock(&edev->qede_lock);
+	__qede_lock(edev);
 
-	if (edev->state == QEDE_STATE_OPEN) {
-		if (test_and_clear_bit(QEDE_SP_RX_MODE, &edev->sp_flags))
+	if (test_and_clear_bit(QEDE_SP_RX_MODE, &edev->sp_flags))
+		if (edev->state == QEDE_STATE_OPEN)
 			qede_config_rx_mode(edev->ndev);
-	}
 
 	if (test_and_clear_bit(QEDE_SP_VXLAN_PORT_CONFIG, &edev->sp_flags)) {
 		struct qed_tunn_params tunn_params;
@@ -2553,7 +2581,7 @@ static void qede_sp_task(struct work_struct *work)
 		qed_ops->tunn_config(cdev, &tunn_params);
 	}
 
-	mutex_unlock(&edev->qede_lock);
+	__qede_unlock(edev);
 }
 
 static void qede_update_pf_params(struct qed_dev *cdev)
@@ -3576,15 +3604,18 @@ enum qede_unload_mode {
 	QEDE_UNLOAD_NORMAL,
 };
 
-static void qede_unload(struct qede_dev *edev, enum qede_unload_mode mode)
+static void qede_unload(struct qede_dev *edev, enum qede_unload_mode mode,
+			bool is_locked)
 {
 	struct qed_link_params link_params;
 	int rc;
 
 	DP_INFO(edev, "Starting qede unload\n");
 
+	if (!is_locked)
+		__qede_lock(edev);
+
 	qede_roce_dev_event_close(edev);
-	mutex_lock(&edev->qede_lock);
 	edev->state = QEDE_STATE_CLOSED;
 
 	/* Close OS Tx */
@@ -3616,7 +3647,8 @@ static void qede_unload(struct qede_dev *edev, enum qede_unload_mode mode)
 	qede_free_fp_array(edev);
 
 out:
-	mutex_unlock(&edev->qede_lock);
+	if (!is_locked)
+		__qede_unlock(edev);
 	DP_INFO(edev, "Ending qede unload\n");
 }
 
@@ -3625,7 +3657,8 @@ enum qede_load_mode {
 	QEDE_LOAD_RELOAD,
 };
 
-static int qede_load(struct qede_dev *edev, enum qede_load_mode mode)
+static int qede_load(struct qede_dev *edev, enum qede_load_mode mode,
+		     bool is_locked)
 {
 	struct qed_link_params link_params;
 	struct qed_link_output link_output;
@@ -3633,13 +3666,16 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode)
 
 	DP_INFO(edev, "Starting qede load\n");
 
+	if (!is_locked)
+		__qede_lock(edev);
+
 	rc = qede_set_num_queues(edev);
 	if (rc)
-		goto err0;
+		goto out;
 
 	rc = qede_alloc_fp_array(edev);
 	if (rc)
-		goto err0;
+		goto out;
 
 	qede_init_fp(edev);
 
@@ -3669,10 +3705,6 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode)
 	/* Add primary mac and set Rx filters */
 	ether_addr_copy(edev->primary_mac, edev->ndev->dev_addr);
 
-	mutex_lock(&edev->qede_lock);
-	edev->state = QEDE_STATE_OPEN;
-	mutex_unlock(&edev->qede_lock);
-
 	/* Program un-configured VLANs */
 	qede_configure_vlan_filters(edev);
 
@@ -3687,10 +3719,12 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode)
 	qede_roce_dev_event_open(edev);
 	qede_link_update(edev, &link_output);
 
+	edev->state = QEDE_STATE_OPEN;
+
 	DP_INFO(edev, "Ending successfully qede load\n");
 
-	return 0;
 
+	goto out;
 err4:
 	qede_sync_free_irqs(edev);
 	memset(&edev->int_info.msix_cnt, 0, sizeof(struct qed_int_info));
@@ -3704,26 +3738,40 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode)
 	edev->num_queues = 0;
 	edev->fp_num_tx = 0;
 	edev->fp_num_rx = 0;
-err0:
+out:
+	if (!is_locked)
+		__qede_unlock(edev);
+
 	return rc;
 }
 
+/* 'func' should be able to run between unload and reload assuming interface
+ * is actually running, or afterwards in case it's currently DOWN.
+ */
 void qede_reload(struct qede_dev *edev,
-		 void (*func)(struct qede_dev *, union qede_reload_args *),
-		 union qede_reload_args *args)
+		 struct qede_reload_args *args, bool is_locked)
 {
-	qede_unload(edev, QEDE_UNLOAD_NORMAL);
-	/* Call function handler to update parameters
-	 * needed for function load.
+	if (!is_locked)
+		__qede_lock(edev);
+
+	/* Since qede_lock is held, internal state wouldn't change even
+	 * if netdev state would start transitioning. Check whether current
+	 * internal configuration indicates device is up, then reload.
 	 */
-	if (func)
-		func(edev, args);
+	if (edev->state == QEDE_STATE_OPEN) {
+		qede_unload(edev, QEDE_UNLOAD_NORMAL, true);
+		if (args)
+			args->func(edev, args);
+		qede_load(edev, QEDE_LOAD_RELOAD, true);
 
-	qede_load(edev, QEDE_LOAD_RELOAD);
+		/* Since no one is going to do it for us, re-configure */
+		qede_config_rx_mode(edev->ndev);
+	} else if (args) {
+		args->func(edev, args);
+	}
 
-	mutex_lock(&edev->qede_lock);
-	qede_config_rx_mode(edev->ndev);
-	mutex_unlock(&edev->qede_lock);
+	if (!is_locked)
+		__qede_unlock(edev);
 }
 
 /* called with rtnl_lock */
@@ -3736,8 +3784,7 @@ static int qede_open(struct net_device *ndev)
 
 	edev->ops->common->set_power_state(edev->cdev, PCI_D0);
 
-	rc = qede_load(edev, QEDE_LOAD_NORMAL);
-
+	rc = qede_load(edev, QEDE_LOAD_NORMAL, false);
 	if (rc)
 		return rc;
 
@@ -3752,7 +3799,7 @@ static int qede_close(struct net_device *ndev)
 {
 	struct qede_dev *edev = netdev_priv(ndev);
 
-	qede_unload(edev, QEDE_UNLOAD_NORMAL);
+	qede_unload(edev, QEDE_UNLOAD_NORMAL, false);
 
 	edev->ops->common->update_drv_state(edev->cdev, false);
 
@@ -3884,15 +3931,8 @@ static void qede_set_rx_mode(struct net_device *ndev)
 {
 	struct qede_dev *edev = netdev_priv(ndev);
 
-	DP_INFO(edev, "qede_set_rx_mode called\n");
-
-	if (edev->state != QEDE_STATE_OPEN) {
-		DP_INFO(edev,
-			"qede_set_rx_mode called while interface is down\n");
-	} else {
-		set_bit(QEDE_SP_RX_MODE, &edev->sp_flags);
-		schedule_delayed_work(&edev->sp_task, 0);
-	}
+	set_bit(QEDE_SP_RX_MODE, &edev->sp_flags);
+	schedule_delayed_work(&edev->sp_task, 0);
 }
 
 /* Must be called with qede_lock held */
-- 
1.9.3
