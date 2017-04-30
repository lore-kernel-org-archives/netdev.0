From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/13] i40e: use DECLARE_BITMAP for state fields
Date: Sun, 30 Apr 2017 06:24:46 -0700
Message-ID: <20170430132451.68494-9-jeffrey.t.kirsher@intel.com>
References: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:53521 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1163237AbdD3NY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 09:24:57 -0400
In-Reply-To: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Instead of assuming our flags fit within an unsigned long, use
DECLARE_BITMAP which will ensure that we always allocate enough space.
Additionally, use __I40E_STATE_SIZE__ markers as the last element of the
enumeration so that the size of the BITMAP is compile-time assigned
rather than programmer-time assigned. This ensures that potential future
flag additions do not actually overrun the array. This is especially
important as 32bit systems would only have 32bit longs instead of 64bit
longs as we generally have assumed in the prior code.

This change also removes a dereference of the state fields throughout
the code, so it does have a bit of code churn. The conversions were
automated using sed replacements with an alternation

  s/&(vsi->back|vsi|pf)->state/\1->state/
  s/&adapter->vsi.state/adapter->vsi.state/

For debugfs, we modify the printing so that we can display chunks of the
state value on new lines. This ensures that we can print the entire set
of state values. Additionally, we now print them as 08lx to ensure that
they display nicely.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_client.c      |  16 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  13 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  42 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 233 ++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  14 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  18 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   8 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   4 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  10 +-
 11 files changed, 189 insertions(+), 181 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index ac2a4850a30b..6eb21abdc60e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -145,6 +145,8 @@ enum i40e_state_t {
 	__I40E_RESET_FAILED,
 	__I40E_PORT_SUSPENDED,
 	__I40E_VF_DISABLE,
+	/* This must be last as it determines the size of the BITMAP */
+	__I40E_STATE_SIZE__,
 };
 
 /* VSI state flags */
@@ -155,6 +157,8 @@ enum i40e_vsi_state_t {
 	__I40E_VSI_OVERFLOW_PROMISC,
 	__I40E_VSI_REINIT_REQUESTED,
 	__I40E_VSI_DOWN_REQUESTED,
+	/* This must be last as it determines the size of the BITMAP */
+	__I40E_VSI_STATE_SIZE__,
 };
 
 enum i40e_interrupt_policy {
@@ -330,7 +334,7 @@ struct i40e_flex_pit {
 struct i40e_pf {
 	struct pci_dev *pdev;
 	struct i40e_hw hw;
-	unsigned long state;
+	DECLARE_BITMAP(state, __I40E_STATE_SIZE__);
 	struct msix_entry *msix_entries;
 	bool fc_autoneg_status;
 
@@ -601,7 +605,7 @@ struct i40e_vsi {
 	bool stat_offsets_loaded;
 
 	u32 current_netdev_flags;
-	unsigned long state;
+	DECLARE_BITMAP(state, __I40E_VSI_STATE_SIZE__);
 #define I40E_VSI_FLAG_FILTER_CHANGED	BIT(0)
 #define I40E_VSI_FLAG_VEB_OWNER		BIT(1)
 	unsigned long flags;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index 75e528a6943f..c3b81a97558e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -371,8 +371,8 @@ void i40e_client_subtask(struct i40e_pf *pf)
 	cdev = pf->cinst;
 
 	/* If we're down or resetting, just bail */
-	if (test_bit(__I40E_DOWN, &pf->state) ||
-	    test_bit(__I40E_CONFIG_BUSY, &pf->state))
+	if (test_bit(__I40E_DOWN, pf->state) ||
+	    test_bit(__I40E_CONFIG_BUSY, pf->state))
 		return;
 
 	if (!client || !cdev)
@@ -382,7 +382,7 @@ void i40e_client_subtask(struct i40e_pf *pf)
 	 * the netdev is up, then open the client.
 	 */
 	if (!test_bit(__I40E_CLIENT_INSTANCE_OPENED, &cdev->state)) {
-		if (!test_bit(__I40E_VSI_DOWN, &vsi->state) &&
+		if (!test_bit(__I40E_VSI_DOWN, vsi->state) &&
 		    client->ops && client->ops->open) {
 			set_bit(__I40E_CLIENT_INSTANCE_OPENED, &cdev->state);
 			ret = client->ops->open(&cdev->lan_info, client);
@@ -397,7 +397,7 @@ void i40e_client_subtask(struct i40e_pf *pf)
 	/* Likewise for client close. If the client is up, but the netdev
 	 * is down, then close the client.
 	 */
-		if (test_bit(__I40E_VSI_DOWN, &vsi->state) &&
+		if (test_bit(__I40E_VSI_DOWN, vsi->state) &&
 		    client->ops && client->ops->close) {
 			clear_bit(__I40E_CLIENT_INSTANCE_OPENED, &cdev->state);
 			client->ops->close(&cdev->lan_info, client, false);
@@ -503,7 +503,7 @@ static void i40e_client_release(struct i40e_client *client)
 			continue;
 
 		while (test_and_set_bit(__I40E_SERVICE_SCHED,
-					&pf->state))
+					pf->state))
 			usleep_range(500, 1000);
 
 		if (test_bit(__I40E_CLIENT_INSTANCE_OPENED, &cdev->state)) {
@@ -521,7 +521,7 @@ static void i40e_client_release(struct i40e_client *client)
 		i40e_client_del_instance(pf);
 		dev_info(&pf->pdev->dev, "Deleted client instance of Client %s\n",
 			 client->name);
-		clear_bit(__I40E_SERVICE_SCHED, &pf->state);
+		clear_bit(__I40E_SERVICE_SCHED, pf->state);
 	}
 	mutex_unlock(&i40e_device_mutex);
 }
@@ -661,10 +661,10 @@ static void i40e_client_request_reset(struct i40e_info *ldev,
 
 	switch (reset_level) {
 	case I40E_CLIENT_RESET_LEVEL_PF:
-		set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
+		set_bit(__I40E_PF_RESET_REQUESTED, pf->state);
 		break;
 	case I40E_CLIENT_RESET_LEVEL_CORE:
-		set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
+		set_bit(__I40E_PF_RESET_REQUESTED, pf->state);
 		break;
 	default:
 		dev_warn(&pf->pdev->dev,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 5408dbf04a00..8f326f87a815 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -158,9 +158,12 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 	dev_info(&pf->pdev->dev,
 		 "    vlgrp: & = %p\n", vsi->active_vlans);
 	dev_info(&pf->pdev->dev,
-		 "    state = %li flags = 0x%08lx, netdev_registered = %i, current_netdev_flags = 0x%04x\n",
-		 vsi->state, vsi->flags,
-		 vsi->netdev_registered, vsi->current_netdev_flags);
+		 "    flags = 0x%08lx, netdev_registered = %i, current_netdev_flags = 0x%04x\n",
+		 vsi->flags, vsi->netdev_registered, vsi->current_netdev_flags);
+	for (i = 0; i < BITS_TO_LONGS(__I40E_VSI_STATE_SIZE__); i++)
+		dev_info(&pf->pdev->dev,
+			 "    state[%d] = %08lx\n",
+			 i, vsi->state[i]);
 	if (vsi == pf->vsi[pf->lan_vsi])
 		dev_info(&pf->pdev->dev, "    MAC address: %pM SAN MAC: %pM Port MAC: %pM\n",
 			 pf->hw.mac.addr,
@@ -174,7 +177,7 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 	}
 	dev_info(&pf->pdev->dev, "    active_filters %u, promisc_threshold %u, overflow promisc %s\n",
 		 vsi->active_filters, vsi->promisc_threshold,
-		 (test_bit(__I40E_VSI_OVERFLOW_PROMISC, &vsi->state) ?
+		 (test_bit(__I40E_VSI_OVERFLOW_PROMISC, vsi->state) ?
 		  "ON" : "OFF"));
 	nstat = i40e_get_vsi_stats_struct(vsi);
 	dev_info(&pf->pdev->dev,
@@ -1706,7 +1709,7 @@ static ssize_t i40e_dbg_netdev_ops_write(struct file *filp,
 		} else if (!vsi->netdev) {
 			dev_info(&pf->pdev->dev, "tx_timeout: no netdev for VSI %d\n",
 				 vsi_seid);
-		} else if (test_bit(__I40E_VSI_DOWN, &vsi->state)) {
+		} else if (test_bit(__I40E_VSI_DOWN, vsi->state)) {
 			dev_info(&pf->pdev->dev, "tx_timeout: VSI %d not UP\n",
 				 vsi_seid);
 		} else if (rtnl_trylock()) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 523dd81d76b7..b1064c6468c2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -757,7 +757,7 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 	if (memcmp(&copy_cmd, &safe_cmd, sizeof(struct ethtool_link_ksettings)))
 		return -EOPNOTSUPP;
 
-	while (test_and_set_bit(__I40E_CONFIG_BUSY, &pf->state)) {
+	while (test_and_set_bit(__I40E_CONFIG_BUSY, pf->state)) {
 		timeout--;
 		if (!timeout)
 			return -EBUSY;
@@ -891,7 +891,7 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 	}
 
 done:
-	clear_bit(__I40E_CONFIG_BUSY, &pf->state);
+	clear_bit(__I40E_CONFIG_BUSY, pf->state);
 
 	return err;
 }
@@ -987,7 +987,7 @@ static int i40e_set_pauseparam(struct net_device *netdev,
 	}
 
 	/* If we have link and don't have autoneg */
-	if (!test_bit(__I40E_DOWN, &pf->state) &&
+	if (!test_bit(__I40E_DOWN, pf->state) &&
 	    !(hw_link_info->an_info & I40E_AQ_AN_COMPLETED)) {
 		/* Send message that it might not necessarily work*/
 		netdev_info(netdev, "Autoneg did not complete so changing settings may not result in an actual change.\n");
@@ -1039,10 +1039,10 @@ static int i40e_set_pauseparam(struct net_device *netdev,
 		err = -EAGAIN;
 	}
 
-	if (!test_bit(__I40E_DOWN, &pf->state)) {
+	if (!test_bit(__I40E_DOWN, pf->state)) {
 		/* Give it a little more time to try to come back */
 		msleep(75);
-		if (!test_bit(__I40E_DOWN, &pf->state))
+		if (!test_bit(__I40E_DOWN, pf->state))
 			return i40e_nway_reset(netdev);
 	}
 
@@ -1139,8 +1139,8 @@ static int i40e_get_eeprom(struct net_device *netdev,
 		/* make sure it is the right magic for NVMUpdate */
 		if ((eeprom->magic >> 16) != hw->device_id)
 			errno = -EINVAL;
-		else if (test_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state) ||
-			 test_bit(__I40E_RESET_INTR_RECEIVED, &pf->state))
+		else if (test_bit(__I40E_RESET_RECOVERY_PENDING, pf->state) ||
+			 test_bit(__I40E_RESET_INTR_RECEIVED, pf->state))
 			errno = -EBUSY;
 		else
 			ret_val = i40e_nvmupd_command(hw, cmd, bytes, &errno);
@@ -1246,8 +1246,8 @@ static int i40e_set_eeprom(struct net_device *netdev,
 	/* check for NVMUpdate access method */
 	else if (!eeprom->magic || (eeprom->magic >> 16) != hw->device_id)
 		errno = -EINVAL;
-	else if (test_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state) ||
-		 test_bit(__I40E_RESET_INTR_RECEIVED, &pf->state))
+	else if (test_bit(__I40E_RESET_RECOVERY_PENDING, pf->state) ||
+		 test_bit(__I40E_RESET_INTR_RECEIVED, pf->state))
 		errno = -EBUSY;
 	else
 		ret_val = i40e_nvmupd_command(hw, cmd, bytes, &errno);
@@ -1332,7 +1332,7 @@ static int i40e_set_ringparam(struct net_device *netdev,
 	    (new_rx_count == vsi->rx_rings[0]->count))
 		return 0;
 
-	while (test_and_set_bit(__I40E_CONFIG_BUSY, &pf->state)) {
+	while (test_and_set_bit(__I40E_CONFIG_BUSY, pf->state)) {
 		timeout--;
 		if (!timeout)
 			return -EBUSY;
@@ -1485,7 +1485,7 @@ static int i40e_set_ringparam(struct net_device *netdev,
 	}
 
 done:
-	clear_bit(__I40E_CONFIG_BUSY, &pf->state);
+	clear_bit(__I40E_CONFIG_BUSY, pf->state);
 
 	return err;
 }
@@ -1847,7 +1847,7 @@ static void i40e_diag_test(struct net_device *netdev,
 		/* Offline tests */
 		netif_info(pf, drv, netdev, "offline testing starting\n");
 
-		set_bit(__I40E_TESTING, &pf->state);
+		set_bit(__I40E_TESTING, pf->state);
 
 		if (i40e_active_vfs(pf) || i40e_active_vmdqs(pf)) {
 			dev_warn(&pf->pdev->dev,
@@ -1857,7 +1857,7 @@ static void i40e_diag_test(struct net_device *netdev,
 			data[I40E_ETH_TEST_INTR]	= 1;
 			data[I40E_ETH_TEST_LINK]	= 1;
 			eth_test->flags |= ETH_TEST_FL_FAILED;
-			clear_bit(__I40E_TESTING, &pf->state);
+			clear_bit(__I40E_TESTING, pf->state);
 			goto skip_ol_tests;
 		}
 
@@ -1886,7 +1886,7 @@ static void i40e_diag_test(struct net_device *netdev,
 		if (i40e_reg_test(netdev, &data[I40E_ETH_TEST_REG]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		clear_bit(__I40E_TESTING, &pf->state);
+		clear_bit(__I40E_TESTING, pf->state);
 		i40e_do_reset(pf, BIT(__I40E_PF_RESET_REQUESTED), true);
 
 		if (if_running)
@@ -2924,11 +2924,11 @@ static int i40e_del_fdir_entry(struct i40e_vsi *vsi,
 	struct i40e_pf *pf = vsi->back;
 	int ret = 0;
 
-	if (test_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state) ||
-	    test_bit(__I40E_RESET_INTR_RECEIVED, &pf->state))
+	if (test_bit(__I40E_RESET_RECOVERY_PENDING, pf->state) ||
+	    test_bit(__I40E_RESET_INTR_RECEIVED, pf->state))
 		return -EBUSY;
 
-	if (test_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state))
+	if (test_bit(__I40E_FD_FLUSH_REQUESTED, pf->state))
 		return -EBUSY;
 
 	ret = i40e_update_ethtool_fdir_entry(vsi, NULL, fsp->location, cmd);
@@ -3646,11 +3646,11 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 	if (pf->hw_disabled_flags & I40E_FLAG_FD_SB_ENABLED)
 		return -ENOSPC;
 
-	if (test_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state) ||
-	    test_bit(__I40E_RESET_INTR_RECEIVED, &pf->state))
+	if (test_bit(__I40E_RESET_RECOVERY_PENDING, pf->state) ||
+	    test_bit(__I40E_RESET_INTR_RECEIVED, pf->state))
 		return -EBUSY;
 
-	if (test_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state))
+	if (test_bit(__I40E_FD_FLUSH_REQUESTED, pf->state))
 		return -EBUSY;
 
 	fsp = (struct ethtool_rx_flow_spec *)&cmd->fs;
@@ -4087,7 +4087,7 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 	if ((changed_flags & I40E_FLAG_FD_ATR_ENABLED) &&
 	    !(pf->flags & I40E_FLAG_FD_ATR_ENABLED)) {
 		pf->hw_disabled_flags |= I40E_FLAG_FD_ATR_ENABLED;
-		set_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
+		set_bit(__I40E_FD_FLUSH_REQUESTED, pf->state);
 	}
 
 	/* Only allow ATR evict on hardware that is capable of handling it */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c30f2bc65451..38772e49bb84 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -295,8 +295,8 @@ struct i40e_vsi *i40e_find_vsi_from_id(struct i40e_pf *pf, u16 id)
  **/
 void i40e_service_event_schedule(struct i40e_pf *pf)
 {
-	if (!test_bit(__I40E_DOWN, &pf->state) &&
-	    !test_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state))
+	if (!test_bit(__I40E_VSI_DOWN, pf->state) &&
+	    !test_bit(__I40E_RESET_RECOVERY_PENDING, pf->state))
 		queue_work(i40e_wq, &pf->service_task);
 }
 
@@ -377,13 +377,13 @@ static void i40e_tx_timeout(struct net_device *netdev)
 
 	switch (pf->tx_timeout_recovery_level) {
 	case 1:
-		set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
+		set_bit(__I40E_PF_RESET_REQUESTED, pf->state);
 		break;
 	case 2:
-		set_bit(__I40E_CORE_RESET_REQUESTED, &pf->state);
+		set_bit(__I40E_CORE_RESET_REQUESTED, pf->state);
 		break;
 	case 3:
-		set_bit(__I40E_GLOBAL_RESET_REQUESTED, &pf->state);
+		set_bit(__I40E_GLOBAL_RESET_REQUESTED, pf->state);
 		break;
 	default:
 		netdev_err(netdev, "tx_timeout recovery unsuccessful\n");
@@ -422,7 +422,7 @@ static void i40e_get_netdev_stats_struct(struct net_device *netdev,
 	struct rtnl_link_stats64 *vsi_stats = i40e_get_vsi_stats_struct(vsi);
 	int i;
 
-	if (test_bit(__I40E_VSI_DOWN, &vsi->state))
+	if (test_bit(__I40E_VSI_DOWN, vsi->state))
 		return;
 
 	if (!vsi->tx_rings)
@@ -753,8 +753,8 @@ static void i40e_update_vsi_stats(struct i40e_vsi *vsi)
 	u64 tx_p, tx_b;
 	u16 q;
 
-	if (test_bit(__I40E_VSI_DOWN, &vsi->state) ||
-	    test_bit(__I40E_CONFIG_BUSY, &pf->state))
+	if (test_bit(__I40E_VSI_DOWN, vsi->state) ||
+	    test_bit(__I40E_CONFIG_BUSY, pf->state))
 		return;
 
 	ns = i40e_get_vsi_stats_struct(vsi);
@@ -1346,7 +1346,7 @@ struct i40e_mac_filter *i40e_add_filter(struct i40e_vsi *vsi,
 		 * to failed, so we don't bother to try sending the filter
 		 * to the hardware.
 		 */
-		if (test_bit(__I40E_VSI_OVERFLOW_PROMISC, &vsi->state))
+		if (test_bit(__I40E_VSI_OVERFLOW_PROMISC, vsi->state))
 			f->state = I40E_FILTER_FAILED;
 		else
 			f->state = I40E_FILTER_NEW;
@@ -1525,8 +1525,8 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
 		return 0;
 	}
 
-	if (test_bit(__I40E_VSI_DOWN, &vsi->back->state) ||
-	    test_bit(__I40E_RESET_RECOVERY_PENDING, &vsi->back->state))
+	if (test_bit(__I40E_VSI_DOWN, vsi->back->state) ||
+	    test_bit(__I40E_RESET_RECOVERY_PENDING, vsi->back->state))
 		return -EADDRNOTAVAIL;
 
 	if (ether_addr_equal(hw->mac.addr, addr->sa_data))
@@ -1920,7 +1920,7 @@ void i40e_aqc_add_filters(struct i40e_vsi *vsi, const char *vsi_name,
 
 	if (fcnt != num_add) {
 		*promisc_changed = true;
-		set_bit(__I40E_VSI_OVERFLOW_PROMISC, &vsi->state);
+		set_bit(__I40E_VSI_OVERFLOW_PROMISC, vsi->state);
 		dev_warn(&vsi->back->pdev->dev,
 			 "Error %s adding RX filters on %s, promiscuous mode forced on\n",
 			 i40e_aq_str(hw, aq_err),
@@ -2003,7 +2003,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 	struct i40e_aqc_add_macvlan_element_data *add_list;
 	struct i40e_aqc_remove_macvlan_element_data *del_list;
 
-	while (test_and_set_bit(__I40E_VSI_SYNCING_FILTERS, &vsi->state))
+	while (test_and_set_bit(__I40E_VSI_SYNCING_FILTERS, vsi->state))
 		usleep_range(1000, 2000);
 	pf = vsi->back;
 
@@ -2140,7 +2140,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		num_add = 0;
 		hlist_for_each_entry_safe(new, h, &tmp_add_list, hlist) {
 			if (test_bit(__I40E_VSI_OVERFLOW_PROMISC,
-				     &vsi->state)) {
+				     vsi->state)) {
 				new->state = I40E_FILTER_FAILED;
 				continue;
 			}
@@ -2227,20 +2227,20 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 	 * safely exit if we didn't just enter, we no longer have any failed
 	 * filters, and we have reduced filters below the threshold value.
 	 */
-	if (test_bit(__I40E_VSI_OVERFLOW_PROMISC, &vsi->state) &&
+	if (test_bit(__I40E_VSI_OVERFLOW_PROMISC, vsi->state) &&
 	    !promisc_changed && !failed_filters &&
 	    (vsi->active_filters < vsi->promisc_threshold)) {
 		dev_info(&pf->pdev->dev,
 			 "filter logjam cleared on %s, leaving overflow promiscuous mode\n",
 			 vsi_name);
-		clear_bit(__I40E_VSI_OVERFLOW_PROMISC, &vsi->state);
+		clear_bit(__I40E_VSI_OVERFLOW_PROMISC, vsi->state);
 		promisc_changed = true;
 		vsi->promisc_threshold = 0;
 	}
 
 	/* if the VF is not trusted do not do promisc */
 	if ((vsi->type == I40E_VSI_SRIOV) && !pf->vf[vsi->vf_id].trusted) {
-		clear_bit(__I40E_VSI_OVERFLOW_PROMISC, &vsi->state);
+		clear_bit(__I40E_VSI_OVERFLOW_PROMISC, vsi->state);
 		goto out;
 	}
 
@@ -2265,12 +2265,12 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 	}
 	if ((changed_flags & IFF_PROMISC) ||
 	    (promisc_changed &&
-	     test_bit(__I40E_VSI_OVERFLOW_PROMISC, &vsi->state))) {
+	     test_bit(__I40E_VSI_OVERFLOW_PROMISC, vsi->state))) {
 		bool cur_promisc;
 
 		cur_promisc = (!!(vsi->current_netdev_flags & IFF_PROMISC) ||
 			       test_bit(__I40E_VSI_OVERFLOW_PROMISC,
-					&vsi->state));
+					vsi->state));
 		if ((vsi->type == I40E_VSI_MAIN) &&
 		    (pf->lan_veb != I40E_NO_VEB) &&
 		    !(pf->flags & I40E_FLAG_MFP_ENABLED)) {
@@ -2353,7 +2353,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 	if (retval)
 		vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
 
-	clear_bit(__I40E_VSI_SYNCING_FILTERS, &vsi->state);
+	clear_bit(__I40E_VSI_SYNCING_FILTERS, vsi->state);
 	return retval;
 
 err_no_memory:
@@ -2365,7 +2365,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 	spin_unlock_bh(&vsi->mac_filter_hash_lock);
 
 	vsi->flags |= I40E_VSI_FLAG_FILTER_CHANGED;
-	clear_bit(__I40E_VSI_SYNCING_FILTERS, &vsi->state);
+	clear_bit(__I40E_VSI_SYNCING_FILTERS, vsi->state);
 	return -ENOMEM;
 }
 
@@ -3611,29 +3611,29 @@ static irqreturn_t i40e_intr(int irq, void *data)
 		 * this is not a performance path and napi_schedule()
 		 * can deal with rescheduling.
 		 */
-		if (!test_bit(__I40E_DOWN, &pf->state))
+		if (!test_bit(__I40E_VSI_DOWN, pf->state))
 			napi_schedule_irqoff(&q_vector->napi);
 	}
 
 	if (icr0 & I40E_PFINT_ICR0_ADMINQ_MASK) {
 		ena_mask &= ~I40E_PFINT_ICR0_ENA_ADMINQ_MASK;
-		set_bit(__I40E_ADMINQ_EVENT_PENDING, &pf->state);
+		set_bit(__I40E_ADMINQ_EVENT_PENDING, pf->state);
 		i40e_debug(&pf->hw, I40E_DEBUG_NVM, "AdminQ event\n");
 	}
 
 	if (icr0 & I40E_PFINT_ICR0_MAL_DETECT_MASK) {
 		ena_mask &= ~I40E_PFINT_ICR0_ENA_MAL_DETECT_MASK;
-		set_bit(__I40E_MDD_EVENT_PENDING, &pf->state);
+		set_bit(__I40E_MDD_EVENT_PENDING, pf->state);
 	}
 
 	if (icr0 & I40E_PFINT_ICR0_VFLR_MASK) {
 		ena_mask &= ~I40E_PFINT_ICR0_ENA_VFLR_MASK;
-		set_bit(__I40E_VFLR_EVENT_PENDING, &pf->state);
+		set_bit(__I40E_VFLR_EVENT_PENDING, pf->state);
 	}
 
 	if (icr0 & I40E_PFINT_ICR0_GRST_MASK) {
-		if (!test_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state))
-			set_bit(__I40E_RESET_INTR_RECEIVED, &pf->state);
+		if (!test_bit(__I40E_RESET_RECOVERY_PENDING, pf->state))
+			set_bit(__I40E_RESET_INTR_RECEIVED, pf->state);
 		ena_mask &= ~I40E_PFINT_ICR0_ENA_GRST_MASK;
 		val = rd32(hw, I40E_GLGEN_RSTAT);
 		val = (val & I40E_GLGEN_RSTAT_RESET_TYPE_MASK)
@@ -3644,7 +3644,7 @@ static irqreturn_t i40e_intr(int irq, void *data)
 			pf->globr_count++;
 		} else if (val == I40E_RESET_EMPR) {
 			pf->empr_count++;
-			set_bit(__I40E_EMP_RESET_INTR_RECEIVED, &pf->state);
+			set_bit(__I40E_EMP_RESET_INTR_RECEIVED, pf->state);
 		}
 	}
 
@@ -3677,7 +3677,7 @@ static irqreturn_t i40e_intr(int irq, void *data)
 		    (icr0_remaining & I40E_PFINT_ICR0_PCI_EXCEPTION_MASK) ||
 		    (icr0_remaining & I40E_PFINT_ICR0_ECC_ERR_MASK)) {
 			dev_info(&pf->pdev->dev, "device will be reset\n");
-			set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
+			set_bit(__I40E_PF_RESET_REQUESTED, pf->state);
 			i40e_service_event_schedule(pf);
 		}
 		ena_mask &= ~icr0_remaining;
@@ -3687,7 +3687,7 @@ static irqreturn_t i40e_intr(int irq, void *data)
 enable_intr:
 	/* re-enable interrupt causes */
 	wr32(hw, I40E_PFINT_ICR0_ENA, ena_mask);
-	if (!test_bit(__I40E_DOWN, &pf->state)) {
+	if (!test_bit(__I40E_VSI_DOWN, pf->state)) {
 		i40e_service_event_schedule(pf);
 		i40e_irq_dynamic_enable_icr0(pf, false);
 	}
@@ -3907,7 +3907,7 @@ static void i40e_netpoll(struct net_device *netdev)
 	int i;
 
 	/* if interface is down do nothing */
-	if (test_bit(__I40E_VSI_DOWN, &vsi->state))
+	if (test_bit(__I40E_VSI_DOWN, vsi->state))
 		return;
 
 	if (pf->flags & I40E_FLAG_MSIX_ENABLED) {
@@ -4144,7 +4144,7 @@ int i40e_vsi_start_rings(struct i40e_vsi *vsi)
 void i40e_vsi_stop_rings(struct i40e_vsi *vsi)
 {
 	/* When port TX is suspended, don't wait */
-	if (test_bit(__I40E_PORT_SUSPENDED, &vsi->back->state))
+	if (test_bit(__I40E_PORT_SUSPENDED, vsi->back->state))
 		return i40e_vsi_stop_rings_no_wait(vsi);
 
 	/* do rx first for enable and last for disable
@@ -4436,14 +4436,14 @@ static void i40e_napi_disable_all(struct i40e_vsi *vsi)
 static void i40e_vsi_close(struct i40e_vsi *vsi)
 {
 	struct i40e_pf *pf = vsi->back;
-	if (!test_and_set_bit(__I40E_VSI_DOWN, &vsi->state))
+	if (!test_and_set_bit(__I40E_VSI_DOWN, vsi->state))
 		i40e_down(vsi);
 	i40e_vsi_free_irq(vsi);
 	i40e_vsi_free_tx_resources(vsi);
 	i40e_vsi_free_rx_resources(vsi);
 	vsi->current_netdev_flags = 0;
 	pf->flags |= I40E_FLAG_SERVICE_CLIENT_REQUESTED;
-	if (test_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state))
+	if (test_bit(__I40E_RESET_RECOVERY_PENDING, pf->state))
 		pf->flags |=  I40E_FLAG_CLIENT_RESET;
 }
 
@@ -4453,10 +4453,10 @@ static void i40e_vsi_close(struct i40e_vsi *vsi)
  **/
 static void i40e_quiesce_vsi(struct i40e_vsi *vsi)
 {
-	if (test_bit(__I40E_VSI_DOWN, &vsi->state))
+	if (test_bit(__I40E_VSI_DOWN, vsi->state))
 		return;
 
-	set_bit(__I40E_VSI_NEEDS_RESTART, &vsi->state);
+	set_bit(__I40E_VSI_NEEDS_RESTART, vsi->state);
 	if (vsi->netdev && netif_running(vsi->netdev))
 		vsi->netdev->netdev_ops->ndo_stop(vsi->netdev);
 	else
@@ -4469,7 +4469,7 @@ static void i40e_quiesce_vsi(struct i40e_vsi *vsi)
  **/
 static void i40e_unquiesce_vsi(struct i40e_vsi *vsi)
 {
-	if (!test_and_clear_bit(__I40E_VSI_NEEDS_RESTART, &vsi->state))
+	if (!test_and_clear_bit(__I40E_VSI_NEEDS_RESTART, vsi->state))
 		return;
 
 	if (vsi->netdev && netif_running(vsi->netdev))
@@ -4637,8 +4637,8 @@ static void i40e_detect_recover_hung(struct i40e_pf *pf)
 		return;
 
 	/* Make sure, VSI state is not DOWN/RECOVERY_PENDING */
-	if (test_bit(__I40E_VSI_DOWN, &vsi->back->state) ||
-	    test_bit(__I40E_RESET_RECOVERY_PENDING, &vsi->back->state))
+	if (test_bit(__I40E_VSI_DOWN, vsi->back->state) ||
+	    test_bit(__I40E_RESET_RECOVERY_PENDING, vsi->back->state))
 		return;
 
 	/* Make sure type is MAIN VSI */
@@ -5185,7 +5185,7 @@ static int i40e_resume_port_tx(struct i40e_pf *pf)
 			  i40e_stat_str(&pf->hw, ret),
 			  i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
 		/* Schedule PF reset to recover */
-		set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
+		set_bit(__I40E_PF_RESET_REQUESTED, pf->state);
 		i40e_service_event_schedule(pf);
 	}
 
@@ -5353,7 +5353,7 @@ static int i40e_up_complete(struct i40e_vsi *vsi)
 	if (err)
 		return err;
 
-	clear_bit(__I40E_VSI_DOWN, &vsi->state);
+	clear_bit(__I40E_VSI_DOWN, vsi->state);
 	i40e_napi_enable_all(vsi);
 	i40e_vsi_enable_irq(vsi);
 
@@ -5402,12 +5402,12 @@ static void i40e_vsi_reinit_locked(struct i40e_vsi *vsi)
 	struct i40e_pf *pf = vsi->back;
 
 	WARN_ON(in_interrupt());
-	while (test_and_set_bit(__I40E_CONFIG_BUSY, &pf->state))
+	while (test_and_set_bit(__I40E_CONFIG_BUSY, pf->state))
 		usleep_range(1000, 2000);
 	i40e_down(vsi);
 
 	i40e_up(vsi);
-	clear_bit(__I40E_CONFIG_BUSY, &pf->state);
+	clear_bit(__I40E_CONFIG_BUSY, pf->state);
 }
 
 /**
@@ -5540,8 +5540,8 @@ int i40e_open(struct net_device *netdev)
 	int err;
 
 	/* disallow open during test or if eeprom is broken */
-	if (test_bit(__I40E_TESTING, &pf->state) ||
-	    test_bit(__I40E_BAD_EEPROM, &pf->state))
+	if (test_bit(__I40E_TESTING, pf->state) ||
+	    test_bit(__I40E_BAD_EEPROM, pf->state))
 		return -EBUSY;
 
 	netif_carrier_off(netdev);
@@ -5787,7 +5787,7 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags, bool lock_acquired)
 
 			if (vsi != NULL &&
 			    test_and_clear_bit(__I40E_VSI_REINIT_REQUESTED,
-					       &vsi->state))
+					       vsi->state))
 				i40e_vsi_reinit_locked(pf->vsi[v]);
 		}
 	} else if (reset_flags & BIT_ULL(__I40E_DOWN_REQUESTED)) {
@@ -5800,8 +5800,8 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags, bool lock_acquired)
 
 			if (vsi != NULL &&
 			    test_and_clear_bit(__I40E_VSI_DOWN_REQUESTED,
-					       &vsi->state)) {
-				set_bit(__I40E_VSI_DOWN, &vsi->state);
+					       vsi->state)) {
+				set_bit(__I40E_VSI_DOWN, vsi->state);
 				i40e_down(vsi);
 			}
 		}
@@ -5942,7 +5942,7 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 	else
 		pf->flags &= ~I40E_FLAG_DCB_ENABLED;
 
-	set_bit(__I40E_PORT_SUSPENDED, &pf->state);
+	set_bit(__I40E_PORT_SUSPENDED, pf->state);
 	/* Reconfiguration needed quiesce all VSIs */
 	i40e_pf_quiesce_all_vsi(pf);
 
@@ -5951,7 +5951,7 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 
 	ret = i40e_resume_port_tx(pf);
 
-	clear_bit(__I40E_PORT_SUSPENDED, &pf->state);
+	clear_bit(__I40E_PORT_SUSPENDED, pf->state);
 	/* In case of error no point in resuming VSIs */
 	if (ret)
 		goto exit;
@@ -5960,7 +5960,7 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 	ret = i40e_pf_wait_queues_disabled(pf);
 	if (ret) {
 		/* Schedule PF reset to recover */
-		set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
+		set_bit(__I40E_PF_RESET_REQUESTED, pf->state);
 		i40e_service_event_schedule(pf);
 	} else {
 		i40e_pf_unquiesce_all_vsi(pf);
@@ -6075,7 +6075,7 @@ void i40e_fdir_check_and_reenable(struct i40e_pf *pf)
 	u32 fcnt_prog, fcnt_avail;
 	struct hlist_node *node;
 
-	if (test_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state))
+	if (test_bit(__I40E_FD_FLUSH_REQUESTED, pf->state))
 		return;
 
 	/* Check if, FD SB or ATR was auto disabled and if there is enough room
@@ -6174,7 +6174,7 @@ static void i40e_fdir_flush_and_replay(struct i40e_pf *pf)
 		i40e_fdir_filter_restore(pf->vsi[pf->lan_vsi]);
 		if (!disable_atr && !pf->fd_tcp4_filter_cnt)
 			pf->hw_disabled_flags &= ~I40E_FLAG_FD_ATR_ENABLED;
-		clear_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
+		clear_bit(__I40E_FD_FLUSH_REQUESTED, pf->state);
 		if (I40E_DEBUG_FD & pf->hw.debug_mask)
 			dev_info(&pf->pdev->dev, "FD Filter table flushed and FD-SB replayed.\n");
 	}
@@ -6204,10 +6204,10 @@ static void i40e_fdir_reinit_subtask(struct i40e_pf *pf)
 {
 
 	/* if interface is down do nothing */
-	if (test_bit(__I40E_DOWN, &pf->state))
+	if (test_bit(__I40E_VSI_DOWN, pf->state))
 		return;
 
-	if (test_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state))
+	if (test_bit(__I40E_FD_FLUSH_REQUESTED, pf->state))
 		i40e_fdir_flush_and_replay(pf);
 
 	i40e_fdir_check_and_reenable(pf);
@@ -6221,7 +6221,7 @@ static void i40e_fdir_reinit_subtask(struct i40e_pf *pf)
  **/
 static void i40e_vsi_link_event(struct i40e_vsi *vsi, bool link_up)
 {
-	if (!vsi || test_bit(__I40E_VSI_DOWN, &vsi->state))
+	if (!vsi || test_bit(__I40E_VSI_DOWN, vsi->state))
 		return;
 
 	switch (vsi->type) {
@@ -6314,11 +6314,11 @@ static void i40e_link_event(struct i40e_pf *pf)
 
 	if (new_link == old_link &&
 	    new_link_speed == old_link_speed &&
-	    (test_bit(__I40E_VSI_DOWN, &vsi->state) ||
+	    (test_bit(__I40E_VSI_DOWN, vsi->state) ||
 	     new_link == netif_carrier_ok(vsi->netdev)))
 		return;
 
-	if (!test_bit(__I40E_VSI_DOWN, &vsi->state))
+	if (!test_bit(__I40E_VSI_DOWN, vsi->state))
 		i40e_print_link_message(vsi, new_link);
 
 	/* Notify the base of the switch tree connected to
@@ -6345,8 +6345,8 @@ static void i40e_watchdog_subtask(struct i40e_pf *pf)
 	int i;
 
 	/* if interface is down do nothing */
-	if (test_bit(__I40E_DOWN, &pf->state) ||
-	    test_bit(__I40E_CONFIG_BUSY, &pf->state))
+	if (test_bit(__I40E_VSI_DOWN, pf->state) ||
+	    test_bit(__I40E_CONFIG_BUSY, pf->state))
 		return;
 
 	/* make sure we don't do these things too often */
@@ -6384,31 +6384,31 @@ static void i40e_reset_subtask(struct i40e_pf *pf)
 {
 	u32 reset_flags = 0;
 
-	if (test_bit(__I40E_REINIT_REQUESTED, &pf->state)) {
+	if (test_bit(__I40E_REINIT_REQUESTED, pf->state)) {
 		reset_flags |= BIT(__I40E_REINIT_REQUESTED);
-		clear_bit(__I40E_REINIT_REQUESTED, &pf->state);
+		clear_bit(__I40E_REINIT_REQUESTED, pf->state);
 	}
-	if (test_bit(__I40E_PF_RESET_REQUESTED, &pf->state)) {
+	if (test_bit(__I40E_PF_RESET_REQUESTED, pf->state)) {
 		reset_flags |= BIT(__I40E_PF_RESET_REQUESTED);
-		clear_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
+		clear_bit(__I40E_PF_RESET_REQUESTED, pf->state);
 	}
-	if (test_bit(__I40E_CORE_RESET_REQUESTED, &pf->state)) {
+	if (test_bit(__I40E_CORE_RESET_REQUESTED, pf->state)) {
 		reset_flags |= BIT(__I40E_CORE_RESET_REQUESTED);
-		clear_bit(__I40E_CORE_RESET_REQUESTED, &pf->state);
+		clear_bit(__I40E_CORE_RESET_REQUESTED, pf->state);
 	}
-	if (test_bit(__I40E_GLOBAL_RESET_REQUESTED, &pf->state)) {
+	if (test_bit(__I40E_GLOBAL_RESET_REQUESTED, pf->state)) {
 		reset_flags |= BIT(__I40E_GLOBAL_RESET_REQUESTED);
-		clear_bit(__I40E_GLOBAL_RESET_REQUESTED, &pf->state);
+		clear_bit(__I40E_GLOBAL_RESET_REQUESTED, pf->state);
 	}
-	if (test_bit(__I40E_DOWN_REQUESTED, &pf->state)) {
-		reset_flags |= BIT(__I40E_DOWN_REQUESTED);
-		clear_bit(__I40E_DOWN_REQUESTED, &pf->state);
+	if (test_bit(__I40E_VSI_DOWN_REQUESTED, pf->state)) {
+		reset_flags |= BIT(__I40E_VSI_DOWN_REQUESTED);
+		clear_bit(__I40E_VSI_DOWN_REQUESTED, pf->state);
 	}
 
 	/* If there's a recovery already waiting, it takes
 	 * precedence before starting a new reset sequence.
 	 */
-	if (test_bit(__I40E_RESET_INTR_RECEIVED, &pf->state)) {
+	if (test_bit(__I40E_RESET_INTR_RECEIVED, pf->state)) {
 		i40e_prep_for_reset(pf, false);
 		i40e_reset(pf);
 		i40e_rebuild(pf, false, false);
@@ -6416,8 +6416,8 @@ static void i40e_reset_subtask(struct i40e_pf *pf)
 
 	/* If we're already down or resetting, just bail */
 	if (reset_flags &&
-	    !test_bit(__I40E_DOWN, &pf->state) &&
-	    !test_bit(__I40E_CONFIG_BUSY, &pf->state)) {
+	    !test_bit(__I40E_VSI_DOWN, pf->state) &&
+	    !test_bit(__I40E_CONFIG_BUSY, pf->state)) {
 		rtnl_lock();
 		i40e_do_reset(pf, reset_flags, true);
 		rtnl_unlock();
@@ -6466,7 +6466,7 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 	u32 val;
 
 	/* Do not run clean AQ when PF reset fails */
-	if (test_bit(__I40E_RESET_FAILED, &pf->state))
+	if (test_bit(__I40E_RESET_FAILED, pf->state))
 		return;
 
 	/* check for error indications */
@@ -6570,7 +6570,7 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 	} while (i++ < pf->adminq_work_limit);
 
 	if (i < pf->adminq_work_limit)
-		clear_bit(__I40E_ADMINQ_EVENT_PENDING, &pf->state);
+		clear_bit(__I40E_ADMINQ_EVENT_PENDING, pf->state);
 
 	/* re-enable Admin queue interrupt cause */
 	val = rd32(hw, I40E_PFINT_ICR0_ENA);
@@ -6596,13 +6596,13 @@ static void i40e_verify_eeprom(struct i40e_pf *pf)
 		if (err) {
 			dev_info(&pf->pdev->dev, "eeprom check failed (%d), Tx/Rx traffic disabled\n",
 				 err);
-			set_bit(__I40E_BAD_EEPROM, &pf->state);
+			set_bit(__I40E_BAD_EEPROM, pf->state);
 		}
 	}
 
-	if (!err && test_bit(__I40E_BAD_EEPROM, &pf->state)) {
+	if (!err && test_bit(__I40E_BAD_EEPROM, pf->state)) {
 		dev_info(&pf->pdev->dev, "eeprom check passed, Tx/Rx traffic enabled\n");
-		clear_bit(__I40E_BAD_EEPROM, &pf->state);
+		clear_bit(__I40E_BAD_EEPROM, pf->state);
 	}
 }
 
@@ -6920,8 +6920,8 @@ static void i40e_prep_for_reset(struct i40e_pf *pf, bool lock_acquired)
 	i40e_status ret = 0;
 	u32 v;
 
-	clear_bit(__I40E_RESET_INTR_RECEIVED, &pf->state);
-	if (test_and_set_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state))
+	clear_bit(__I40E_RESET_INTR_RECEIVED, pf->state);
+	if (test_and_set_bit(__I40E_RESET_RECOVERY_PENDING, pf->state))
 		return;
 	if (i40e_check_asq_alive(&pf->hw))
 		i40e_vc_notify_reset(pf);
@@ -6980,8 +6980,8 @@ static int i40e_reset(struct i40e_pf *pf)
 	ret = i40e_pf_reset(hw);
 	if (ret) {
 		dev_info(&pf->pdev->dev, "PF reset failed, %d\n", ret);
-		set_bit(__I40E_RESET_FAILED, &pf->state);
-		clear_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state);
+		set_bit(__I40E_RESET_FAILED, pf->state);
+		clear_bit(__I40E_RESET_RECOVERY_PENDING, pf->state);
 	} else {
 		pf->pfr_count++;
 	}
@@ -7003,7 +7003,7 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
 	u32 val;
 	int v;
 
-	if (test_bit(__I40E_DOWN, &pf->state))
+	if (test_bit(__I40E_VSI_DOWN, pf->state))
 		goto clear_recovery;
 	dev_dbg(&pf->pdev->dev, "Rebuilding internal switch\n");
 
@@ -7017,7 +7017,7 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
 	}
 
 	/* re-verify the eeprom if we just had an EMP reset */
-	if (test_and_clear_bit(__I40E_EMP_RESET_INTR_RECEIVED, &pf->state))
+	if (test_and_clear_bit(__I40E_EMP_RESET_INTR_RECEIVED, pf->state))
 		i40e_verify_eeprom(pf);
 
 	i40e_clear_pxe_mode(hw);
@@ -7180,9 +7180,9 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
 	if (!lock_acquired)
 		rtnl_unlock();
 end_core_reset:
-	clear_bit(__I40E_RESET_FAILED, &pf->state);
+	clear_bit(__I40E_RESET_FAILED, pf->state);
 clear_recovery:
-	clear_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state);
+	clear_bit(__I40E_RESET_RECOVERY_PENDING, pf->state);
 }
 
 /**
@@ -7235,7 +7235,7 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 	u32 reg;
 	int i;
 
-	if (!test_bit(__I40E_MDD_EVENT_PENDING, &pf->state))
+	if (!test_bit(__I40E_MDD_EVENT_PENDING, pf->state))
 		return;
 
 	/* find what triggered the MDD event */
@@ -7287,7 +7287,7 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 		}
 		/* Queue belongs to the PF, initiate a reset */
 		if (pf_mdd_detected) {
-			set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
+			set_bit(__I40E_PF_RESET_REQUESTED, pf->state);
 			i40e_service_event_schedule(pf);
 		}
 	}
@@ -7321,7 +7321,7 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
 	}
 
 	/* re-enable mdd interrupt cause */
-	clear_bit(__I40E_MDD_EVENT_PENDING, &pf->state);
+	clear_bit(__I40E_MDD_EVENT_PENDING, pf->state);
 	reg = rd32(hw, I40E_PFINT_ICR0_ENA);
 	reg |=  I40E_PFINT_ICR0_ENA_MAL_DETECT_MASK;
 	wr32(hw, I40E_PFINT_ICR0_ENA, reg);
@@ -7399,11 +7399,10 @@ static void i40e_service_task(struct work_struct *work)
 	unsigned long start_time = jiffies;
 
 	/* don't bother with service tasks if a reset is in progress */
-	if (test_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state)) {
+	if (test_bit(__I40E_RESET_RECOVERY_PENDING, pf->state))
 		return;
-	}
 
-	if (test_and_set_bit(__I40E_SERVICE_SCHED, &pf->state))
+	if (test_and_set_bit(__I40E_SERVICE_SCHED, pf->state))
 		return;
 
 	i40e_detect_recover_hung(pf);
@@ -7431,16 +7430,16 @@ static void i40e_service_task(struct work_struct *work)
 
 	/* flush memory to make sure state is correct before next watchdog */
 	smp_mb__before_atomic();
-	clear_bit(__I40E_SERVICE_SCHED, &pf->state);
+	clear_bit(__I40E_SERVICE_SCHED, pf->state);
 
 	/* If the tasks have taken longer than one timer cycle or there
 	 * is more work to be done, reschedule the service task now
 	 * rather than wait for the timer to tick again.
 	 */
 	if (time_after(jiffies, (start_time + pf->service_timer_period)) ||
-	    test_bit(__I40E_ADMINQ_EVENT_PENDING, &pf->state)		 ||
-	    test_bit(__I40E_MDD_EVENT_PENDING, &pf->state)		 ||
-	    test_bit(__I40E_VFLR_EVENT_PENDING, &pf->state))
+	    test_bit(__I40E_ADMINQ_EVENT_PENDING, pf->state)		 ||
+	    test_bit(__I40E_MDD_EVENT_PENDING, pf->state)		 ||
+	    test_bit(__I40E_VFLR_EVENT_PENDING, pf->state))
 		i40e_service_event_schedule(pf);
 }
 
@@ -7589,7 +7588,7 @@ static int i40e_vsi_mem_alloc(struct i40e_pf *pf, enum i40e_vsi_type type)
 	}
 	vsi->type = type;
 	vsi->back = pf;
-	set_bit(__I40E_VSI_DOWN, &vsi->state);
+	set_bit(__I40E_VSI_DOWN, vsi->state);
 	vsi->flags = 0;
 	vsi->idx = vsi_idx;
 	vsi->int_rate_limit = 0;
@@ -8171,7 +8170,7 @@ static int i40e_setup_misc_vector(struct i40e_pf *pf)
 	/* Only request the irq if this is the first time through, and
 	 * not when we're rebuilding after a Reset
 	 */
-	if (!test_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state)) {
+	if (!test_bit(__I40E_RESET_RECOVERY_PENDING, pf->state)) {
 		err = request_irq(pf->msix_entries[0].vector,
 				  i40e_intr, 0, pf->int_name, pf);
 		if (err) {
@@ -9716,7 +9715,7 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 	}
 
 	vsi->active_filters = 0;
-	clear_bit(__I40E_VSI_OVERFLOW_PROMISC, &vsi->state);
+	clear_bit(__I40E_VSI_OVERFLOW_PROMISC, vsi->state);
 	spin_lock_bh(&vsi->mac_filter_hash_lock);
 	/* If macvlan filters already exist, force them to get loaded */
 	hash_for_each_safe(vsi->mac_filter_hash, bkt, h, f, hlist) {
@@ -9769,7 +9768,7 @@ int i40e_vsi_release(struct i40e_vsi *vsi)
 		return -ENODEV;
 	}
 	if (vsi == pf->vsi[pf->lan_vsi] &&
-	    !test_bit(__I40E_DOWN, &pf->state)) {
+	    !test_bit(__I40E_VSI_DOWN, pf->state)) {
 		dev_info(&pf->pdev->dev, "Can't remove PF VSI\n");
 		return -ENODEV;
 	}
@@ -11005,7 +11004,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 	pf->next_vsi = 0;
 	pf->pdev = pdev;
-	set_bit(__I40E_DOWN, &pf->state);
+	set_bit(__I40E_VSI_DOWN, pf->state);
 
 	hw = &pf->hw;
 	hw->back = pf;
@@ -11184,7 +11183,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pf->service_timer_period = HZ;
 
 	INIT_WORK(&pf->service_task, i40e_service_task);
-	clear_bit(__I40E_SERVICE_SCHED, &pf->state);
+	clear_bit(__I40E_SERVICE_SCHED, pf->state);
 
 	/* NVM bit on means WoL disabled for the port */
 	i40e_read_nvm_word(hw, I40E_SR_NVM_WAKE_ON_LAN, &wol_nvm_bits);
@@ -11222,7 +11221,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* prep for VF support */
 	if ((pf->flags & I40E_FLAG_SRIOV_ENABLED) &&
 	    (pf->flags & I40E_FLAG_MSIX_ENABLED) &&
-	    !test_bit(__I40E_BAD_EEPROM, &pf->state)) {
+	    !test_bit(__I40E_BAD_EEPROM, pf->state)) {
 		if (pci_num_vf(pdev))
 			pf->flags |= I40E_FLAG_VEB_MODE_ENABLED;
 	}
@@ -11295,7 +11294,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * before setting up the misc vector or we get a race and the vector
 	 * ends up disabled forever.
 	 */
-	clear_bit(__I40E_DOWN, &pf->state);
+	clear_bit(__I40E_VSI_DOWN, pf->state);
 
 	/* In case of MSIX we are going to setup the misc vector right here
 	 * to handle admin queue events etc. In case of legacy and MSI
@@ -11315,7 +11314,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* prep for VF support */
 	if ((pf->flags & I40E_FLAG_SRIOV_ENABLED) &&
 	    (pf->flags & I40E_FLAG_MSIX_ENABLED) &&
-	    !test_bit(__I40E_BAD_EEPROM, &pf->state)) {
+	    !test_bit(__I40E_BAD_EEPROM, pf->state)) {
 		/* disable link interrupts for VFs */
 		val = rd32(hw, I40E_PFGEN_PORTMDIO_NUM);
 		val &= ~I40E_PFGEN_PORTMDIO_NUM_VFLINK_STAT_ENA_MASK;
@@ -11450,7 +11449,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* Unwind what we've done if something failed in the setup */
 err_vsis:
-	set_bit(__I40E_DOWN, &pf->state);
+	set_bit(__I40E_VSI_DOWN, pf->state);
 	i40e_clear_interrupt_scheme(pf);
 	kfree(pf->vsi);
 err_switch_setup:
@@ -11501,8 +11500,8 @@ static void i40e_remove(struct pci_dev *pdev)
 	i40e_write_rx_ctl(hw, I40E_PFQF_HENA(1), 0);
 
 	/* no more scheduling of any task */
-	set_bit(__I40E_SUSPENDED, &pf->state);
-	set_bit(__I40E_DOWN, &pf->state);
+	set_bit(__I40E_SUSPENDED, pf->state);
+	set_bit(__I40E_VSI_DOWN, pf->state);
 	if (pf->service_timer.data)
 		del_timer_sync(&pf->service_timer);
 	if (pf->service_task.func)
@@ -11610,7 +11609,7 @@ static pci_ers_result_t i40e_pci_error_detected(struct pci_dev *pdev,
 	}
 
 	/* shutdown all operations */
-	if (!test_bit(__I40E_SUSPENDED, &pf->state)) {
+	if (!test_bit(__I40E_SUSPENDED, pf->state)) {
 		rtnl_lock();
 		i40e_prep_for_reset(pf, true);
 		rtnl_unlock();
@@ -11677,7 +11676,7 @@ static void i40e_pci_error_resume(struct pci_dev *pdev)
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
 
 	dev_dbg(&pdev->dev, "%s\n", __func__);
-	if (test_bit(__I40E_SUSPENDED, &pf->state))
+	if (test_bit(__I40E_SUSPENDED, pf->state))
 		return;
 
 	rtnl_lock();
@@ -11741,8 +11740,8 @@ static void i40e_shutdown(struct pci_dev *pdev)
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
 	struct i40e_hw *hw = &pf->hw;
 
-	set_bit(__I40E_SUSPENDED, &pf->state);
-	set_bit(__I40E_DOWN, &pf->state);
+	set_bit(__I40E_SUSPENDED, pf->state);
+	set_bit(__I40E_VSI_DOWN, pf->state);
 	rtnl_lock();
 	i40e_prep_for_reset(pf, true);
 	rtnl_unlock();
@@ -11790,8 +11789,8 @@ static int i40e_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct i40e_hw *hw = &pf->hw;
 	int retval = 0;
 
-	set_bit(__I40E_SUSPENDED, &pf->state);
-	set_bit(__I40E_DOWN, &pf->state);
+	set_bit(__I40E_SUSPENDED, pf->state);
+	set_bit(__I40E_VSI_DOWN, pf->state);
 
 	if (pf->wol_en && (pf->flags & I40E_FLAG_WOL_MC_MAGIC_PKT_WAKE))
 		i40e_enable_mc_magic_wake(pf);
@@ -11842,8 +11841,8 @@ static int i40e_resume(struct pci_dev *pdev)
 	pci_wake_from_d3(pdev, false);
 
 	/* handling the reset will rebuild the device state */
-	if (test_and_clear_bit(__I40E_SUSPENDED, &pf->state)) {
-		clear_bit(__I40E_DOWN, &pf->state);
+	if (test_and_clear_bit(__I40E_SUSPENDED, pf->state)) {
+		clear_bit(__I40E_VSI_DOWN, pf->state);
 		rtnl_lock();
 		i40e_reset_and_rebuild(pf, false, true);
 		rtnl_unlock();
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 2caee35528fa..18c1cc08da97 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -358,7 +358,7 @@ void i40e_ptp_tx_hwtstamp(struct i40e_pf *pf)
 	skb_tstamp_tx(pf->ptp_tx_skb, &shhwtstamps);
 	dev_kfree_skb_any(pf->ptp_tx_skb);
 	pf->ptp_tx_skb = NULL;
-	clear_bit_unlock(__I40E_PTP_TX_IN_PROGRESS, &pf->state);
+	clear_bit_unlock(__I40E_PTP_TX_IN_PROGRESS, pf->state);
 }
 
 /**
@@ -768,7 +768,7 @@ void i40e_ptp_stop(struct i40e_pf *pf)
 	if (pf->ptp_tx_skb) {
 		dev_kfree_skb_any(pf->ptp_tx_skb);
 		pf->ptp_tx_skb = NULL;
-		clear_bit_unlock(__I40E_PTP_TX_IN_PROGRESS, &pf->state);
+		clear_bit_unlock(__I40E_PTP_TX_IN_PROGRESS, pf->state);
 	}
 
 	if (pf->ptp_clock) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index bbd21cbf3e4d..6e677a235fe4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -589,7 +589,7 @@ static void i40e_fd_handle_status(struct i40e_ring *rx_ring,
 		 * progress do nothing, once flush is complete the state will
 		 * be cleared.
 		 */
-		if (test_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state))
+		if (test_bit(__I40E_FD_FLUSH_REQUESTED, pf->state))
 			return;
 
 		pf->fd_add_err++;
@@ -599,7 +599,7 @@ static void i40e_fd_handle_status(struct i40e_ring *rx_ring,
 		if ((rx_desc->wb.qword0.hi_dword.fd_id == 0) &&
 		    (pf->hw_disabled_flags & I40E_FLAG_FD_SB_ENABLED)) {
 			pf->hw_disabled_flags |= I40E_FLAG_FD_ATR_ENABLED;
-			set_bit(__I40E_FD_FLUSH_REQUESTED, &pf->state);
+			set_bit(__I40E_FD_FLUSH_REQUESTED, pf->state);
 		}
 
 		/* filter programming failed most likely due to table full */
@@ -850,7 +850,7 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
 
 		if (budget &&
 		    ((j / WB_STRIDE) == 0) && (j > 0) &&
-		    !test_bit(__I40E_VSI_DOWN, &vsi->state) &&
+		    !test_bit(__I40E_VSI_DOWN, vsi->state) &&
 		    (I40E_DESC_UNUSED(tx_ring) != tx_ring->count))
 			tx_ring->arm_wb = true;
 	}
@@ -868,7 +868,7 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
 		smp_mb();
 		if (__netif_subqueue_stopped(tx_ring->netdev,
 					     tx_ring->queue_index) &&
-		   !test_bit(__I40E_VSI_DOWN, &vsi->state)) {
+		   !test_bit(__I40E_VSI_DOWN, vsi->state)) {
 			netif_wake_subqueue(tx_ring->netdev,
 					    tx_ring->queue_index);
 			++tx_ring->tx_stats.restart_queue;
@@ -2179,7 +2179,7 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 	}
 
 enable_int:
-	if (!test_bit(__I40E_VSI_DOWN, &vsi->state))
+	if (!test_bit(__I40E_VSI_DOWN, vsi->state))
 		wr32(hw, INTREG(vector - 1), txval);
 
 	if (q_vector->itr_countdown)
@@ -2208,7 +2208,7 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	int budget_per_ring;
 	int work_done = 0;
 
-	if (test_bit(__I40E_VSI_DOWN, &vsi->state)) {
+	if (test_bit(__I40E_VSI_DOWN, vsi->state)) {
 		napi_complete(napi);
 		return 0;
 	}
@@ -2634,7 +2634,7 @@ static int i40e_tsyn(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		return 0;
 
 	if (pf->ptp_tx &&
-	    !test_and_set_bit_lock(__I40E_PTP_TX_IN_PROGRESS, &pf->state)) {
+	    !test_and_set_bit_lock(__I40E_PTP_TX_IN_PROGRESS, pf->state)) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 		pf->ptp_tx_skb = skb_get(skb);
 	} else {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 29f53f032c3c..95c23fbaa211 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1036,7 +1036,7 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 	int i;
 
 	/* If VFs have been disabled, there is no need to reset */
-	if (test_and_set_bit(__I40E_VF_DISABLE, &pf->state))
+	if (test_and_set_bit(__I40E_VF_DISABLE, pf->state))
 		return;
 
 	i40e_trigger_vf_reset(vf, flr);
@@ -1073,7 +1073,7 @@ void i40e_reset_vf(struct i40e_vf *vf, bool flr)
 	i40e_cleanup_reset_vf(vf);
 
 	i40e_flush(hw);
-	clear_bit(__I40E_VF_DISABLE, &pf->state);
+	clear_bit(__I40E_VF_DISABLE, pf->state);
 }
 
 /**
@@ -1098,7 +1098,7 @@ void i40e_reset_all_vfs(struct i40e_pf *pf, bool flr)
 		return;
 
 	/* If VFs have been disabled, there is no need to reset */
-	if (test_and_set_bit(__I40E_VF_DISABLE, &pf->state))
+	if (test_and_set_bit(__I40E_VF_DISABLE, pf->state))
 		return;
 
 	/* Begin reset on all VFs at once */
@@ -1173,7 +1173,7 @@ void i40e_reset_all_vfs(struct i40e_pf *pf, bool flr)
 		i40e_cleanup_reset_vf(&pf->vf[v]);
 
 	i40e_flush(hw);
-	clear_bit(__I40E_VF_DISABLE, &pf->state);
+	clear_bit(__I40E_VF_DISABLE, pf->state);
 }
 
 /**
@@ -1190,7 +1190,7 @@ void i40e_free_vfs(struct i40e_pf *pf)
 
 	if (!pf->vf)
 		return;
-	while (test_and_set_bit(__I40E_VF_DISABLE, &pf->state))
+	while (test_and_set_bit(__I40E_VF_DISABLE, pf->state))
 		usleep_range(1000, 2000);
 
 	i40e_notify_client_of_vf_enable(pf, 0);
@@ -1246,7 +1246,7 @@ void i40e_free_vfs(struct i40e_pf *pf)
 			wr32(hw, I40E_GLGEN_VFLRSTAT(reg_idx), BIT(bit_idx));
 		}
 	}
-	clear_bit(__I40E_VF_DISABLE, &pf->state);
+	clear_bit(__I40E_VF_DISABLE, pf->state);
 }
 
 #ifdef CONFIG_PCI_IOV
@@ -1326,7 +1326,7 @@ static int i40e_pci_sriov_enable(struct pci_dev *pdev, int num_vfs)
 	int pre_existing_vfs = pci_num_vf(pdev);
 	int err = 0;
 
-	if (test_bit(__I40E_TESTING, &pf->state)) {
+	if (test_bit(__I40E_TESTING, pf->state)) {
 		dev_warn(&pdev->dev,
 			 "Cannot enable SR-IOV virtual functions while the device is undergoing diagnostic testing\n");
 		err = -EPERM;
@@ -2818,7 +2818,7 @@ int i40e_vc_process_vflr_event(struct i40e_pf *pf)
 	struct i40e_vf *vf;
 	int vf_id;
 
-	if (!test_bit(__I40E_VFLR_EVENT_PENDING, &pf->state))
+	if (!test_bit(__I40E_VFLR_EVENT_PENDING, pf->state))
 		return 0;
 
 	/* Re-enable the VFLR interrupt cause here, before looking for which
@@ -2831,7 +2831,7 @@ int i40e_vc_process_vflr_event(struct i40e_pf *pf)
 	wr32(hw, I40E_PFINT_ICR0_ENA, reg);
 	i40e_flush(hw);
 
-	clear_bit(__I40E_VFLR_EVENT_PENDING, &pf->state);
+	clear_bit(__I40E_VFLR_EVENT_PENDING, pf->state);
 	for (vf_id = 0; vf_id < pf->num_alloc_vfs; vf_id++) {
 		reg_idx = (hw->func_caps.vf_base_id + vf_id) / 32;
 		bit_idx = (hw->func_caps.vf_base_id + vf_id) % 32;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index c95ee0a8950f..dfe241a12ad0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -266,7 +266,7 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
 
 		if (budget &&
 		    ((j / WB_STRIDE) == 0) && (j > 0) &&
-		    !test_bit(__I40E_VSI_DOWN, &vsi->state) &&
+		    !test_bit(__I40E_VSI_DOWN, vsi->state) &&
 		    (I40E_DESC_UNUSED(tx_ring) != tx_ring->count))
 			tx_ring->arm_wb = true;
 	}
@@ -284,7 +284,7 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
 		smp_mb();
 		if (__netif_subqueue_stopped(tx_ring->netdev,
 					     tx_ring->queue_index) &&
-		   !test_bit(__I40E_VSI_DOWN, &vsi->state)) {
+		   !test_bit(__I40E_VSI_DOWN, vsi->state)) {
 			netif_wake_subqueue(tx_ring->netdev,
 					    tx_ring->queue_index);
 			++tx_ring->tx_stats.restart_queue;
@@ -1508,7 +1508,7 @@ static inline void i40e_update_enable_itr(struct i40e_vsi *vsi,
 	}
 
 enable_int:
-	if (!test_bit(__I40E_VSI_DOWN, &vsi->state))
+	if (!test_bit(__I40E_VSI_DOWN, vsi->state))
 		wr32(hw, INTREG(vector - 1), txval);
 
 	if (q_vector->itr_countdown)
@@ -1537,7 +1537,7 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 	int budget_per_ring;
 	int work_done = 0;
 
-	if (test_bit(__I40E_VSI_DOWN, &vsi->state)) {
+	if (test_bit(__I40E_VSI_DOWN, vsi->state)) {
 		napi_complete(napi);
 		return 0;
 	}
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index a56a6e54d907..4681c63ee7e3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -52,6 +52,8 @@
 /* VSI state flags shared with common code */
 enum i40evf_vsi_state_t {
 	__I40E_VSI_DOWN,
+	/* This must be last as it determines the size of the BITMAP */
+	__I40E_VSI_STATE_SIZE__,
 };
 
 /* dummy struct to make common code less painful */
@@ -61,7 +63,7 @@ struct i40e_vsi {
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u16 seid;
 	u16 id;
-	unsigned long state;
+	DECLARE_BITMAP(state, __I40E_VSI_STATE_SIZE__);
 	int base_vector;
 	u16 work_limit;
 	u16 qs_handle;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index b453d05c2a30..8e6276d864e6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -497,7 +497,7 @@ static void i40evf_netpoll(struct net_device *netdev)
 	int i;
 
 	/* if interface is down do nothing */
-	if (test_bit(__I40E_VSI_DOWN, &adapter->vsi.state))
+	if (test_bit(__I40E_VSI_DOWN, adapter->vsi.state))
 		return;
 
 	for (i = 0; i < q_vectors; i++)
@@ -1087,7 +1087,7 @@ static void i40evf_configure(struct i40evf_adapter *adapter)
 static void i40evf_up_complete(struct i40evf_adapter *adapter)
 {
 	adapter->state = __I40EVF_RUNNING;
-	clear_bit(__I40E_VSI_DOWN, &adapter->vsi.state);
+	clear_bit(__I40E_VSI_DOWN, adapter->vsi.state);
 
 	i40evf_napi_enable_all(adapter);
 
@@ -1753,7 +1753,7 @@ static void i40evf_disable_vf(struct i40evf_adapter *adapter)
 	adapter->flags |= I40EVF_FLAG_PF_COMMS_FAILED;
 
 	if (netif_running(adapter->netdev)) {
-		set_bit(__I40E_VSI_DOWN, &adapter->vsi.state);
+		set_bit(__I40E_VSI_DOWN, adapter->vsi.state);
 		netif_carrier_off(adapter->netdev);
 		netif_tx_disable(adapter->netdev);
 		adapter->link_up = false;
@@ -2233,7 +2233,7 @@ static int i40evf_close(struct net_device *netdev)
 		return 0;
 
 
-	set_bit(__I40E_VSI_DOWN, &adapter->vsi.state);
+	set_bit(__I40E_VSI_DOWN, adapter->vsi.state);
 	if (CLIENT_ENABLED(adapter))
 		adapter->flags |= I40EVF_FLAG_CLIENT_NEEDS_CLOSE;
 
@@ -2674,7 +2674,7 @@ static void i40evf_init_task(struct work_struct *work)
 		dev_info(&pdev->dev, "GRO is enabled\n");
 
 	adapter->state = __I40EVF_DOWN;
-	set_bit(__I40E_VSI_DOWN, &adapter->vsi.state);
+	set_bit(__I40E_VSI_DOWN, adapter->vsi.state);
 	i40evf_misc_irq_enable(adapter);
 
 	adapter->rss_key = kzalloc(adapter->rss_key_size, GFP_KERNEL);
-- 
2.12.2
