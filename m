From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 07/16] sfc: protect filter table against use-after-free
Date: Mon, 18 May 2015 16:29:08 +0100
Message-ID: <555A0544.6010000@solarflare.com>
References: <555A044A.4060202@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:46148 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753035AbbERP3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:29:31 -0400
In-Reply-To: <555A044A.4060202@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>

If MCDI timeouts are encountered during efx_ef10_filter_table_remove(),
an FLR will be queued, but efx->filter_state will still be kfree()d.
The queued FLR will then call efx_ef10_filter_table_restore(), which
will try to use efx->filter_state. This previously caused a panic.
This patch adds an rwsem to protect the existence of efx->filter_state,
separately from the spinlock protecting its contents.  Users which can
race against efx_ef10_filter_table_remove() should down_read this rwsem.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 19 +++++++++++++++++
 drivers/net/ethernet/sfc/efx.c        | 39 ++++++++++++++++++++++++++---------
 drivers/net/ethernet/sfc/efx.h        |  2 ++
 drivers/net/ethernet/sfc/ethtool.c    |  2 +-
 drivers/net/ethernet/sfc/net_driver.h |  5 ++++-
 5 files changed, 55 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 78d3236..9e2e8e1 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3314,6 +3314,9 @@ fail:
 	return rc;
 }
 
+/* Caller must hold efx->filter_sem for read if race against
+ * efx_ef10_filter_table_remove() is possible
+ */
 static void efx_ef10_filter_table_restore(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
@@ -3323,9 +3326,14 @@ static void efx_ef10_filter_table_restore(struct efx_nic *efx)
 	bool failed = false;
 	int rc;
 
+	WARN_ON(!rwsem_is_locked(&efx->filter_sem));
+
 	if (!nic_data->must_restore_filters)
 		return;
 
+	if (!table)
+		return;
+
 	spin_lock_bh(&efx->filter_lock);
 
 	for (filter_idx = 0; filter_idx < HUNT_FILTER_TBL_ROWS; filter_idx++) {
@@ -3361,6 +3369,7 @@ static void efx_ef10_filter_table_restore(struct efx_nic *efx)
 		nic_data->must_restore_filters = false;
 }
 
+/* Caller must hold efx->filter_sem for write */
 static void efx_ef10_filter_table_remove(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
@@ -3369,6 +3378,10 @@ static void efx_ef10_filter_table_remove(struct efx_nic *efx)
 	unsigned int filter_idx;
 	int rc;
 
+	efx->filter_state = NULL;
+	if (!table)
+		return;
+
 	for (filter_idx = 0; filter_idx < HUNT_FILTER_TBL_ROWS; filter_idx++) {
 		spec = efx_ef10_filter_entry_spec(table, filter_idx);
 		if (!spec)
@@ -3394,6 +3407,9 @@ static void efx_ef10_filter_table_remove(struct efx_nic *efx)
 	kfree(table);
 }
 
+/* Caller must hold efx->filter_sem for read if race against
+ * efx_ef10_filter_table_remove() is possible
+ */
 static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
@@ -3408,6 +3424,9 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	if (!efx_dev_registered(efx))
 		return;
 
+	if (!table)
+		return;
+
 	/* Mark old filters that may need to be removed */
 	spin_lock_bh(&efx->filter_lock);
 	n = table->dev_uc_count < 0 ? 1 : table->dev_uc_count;
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 864c337..50816cd 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -949,6 +949,16 @@ void efx_link_set_wanted_fc(struct efx_nic *efx, u8 wanted_fc)
 
 static void efx_fini_port(struct efx_nic *efx);
 
+/* We assume that efx->type->reconfigure_mac will always try to sync RX
+ * filters and therefore needs to read-lock the filter table against freeing
+ */
+void efx_mac_reconfigure(struct efx_nic *efx)
+{
+	down_read(&efx->filter_sem);
+	efx->type->reconfigure_mac(efx);
+	up_read(&efx->filter_sem);
+}
+
 /* Push loopback/power/transmit disable settings to the PHY, and reconfigure
  * the MAC appropriately. All other PHY configuration changes are pushed
  * through phy_op->set_settings(), and pushed asynchronously to the MAC
@@ -1002,7 +1012,7 @@ static void efx_mac_work(struct work_struct *data)
 
 	mutex_lock(&efx->mac_lock);
 	if (efx->port_enabled)
-		efx->type->reconfigure_mac(efx);
+		efx_mac_reconfigure(efx);
 	mutex_unlock(&efx->mac_lock);
 }
 
@@ -1042,7 +1052,7 @@ static int efx_init_port(struct efx_nic *efx)
 
 	/* Reconfigure the MAC before creating dma queues (required for
 	 * Falcon/A1 where RX_INGR_EN/TX_DRAIN_EN isn't supported) */
-	efx->type->reconfigure_mac(efx);
+	efx_mac_reconfigure(efx);
 
 	/* Ensure the PHY advertises the correct flow control settings */
 	rc = efx->phy_op->reconfigure(efx);
@@ -1068,7 +1078,7 @@ static void efx_start_port(struct efx_nic *efx)
 	efx->port_enabled = true;
 
 	/* Ensure MAC ingress/egress is enabled */
-	efx->type->reconfigure_mac(efx);
+	efx_mac_reconfigure(efx);
 
 	mutex_unlock(&efx->mac_lock);
 }
@@ -1672,10 +1682,11 @@ static int efx_probe_filters(struct efx_nic *efx)
 	int rc;
 
 	spin_lock_init(&efx->filter_lock);
-
+	init_rwsem(&efx->filter_sem);
+	down_write(&efx->filter_sem);
 	rc = efx->type->filter_table_probe(efx);
 	if (rc)
-		return rc;
+		goto out_unlock;
 
 #ifdef CONFIG_RFS_ACCEL
 	if (efx->type->offload_features & NETIF_F_NTUPLE) {
@@ -1684,12 +1695,14 @@ static int efx_probe_filters(struct efx_nic *efx)
 					   GFP_KERNEL);
 		if (!efx->rps_flow_id) {
 			efx->type->filter_table_remove(efx);
-			return -ENOMEM;
+			rc = -ENOMEM;
+			goto out_unlock;
 		}
 	}
 #endif
-
-	return 0;
+out_unlock:
+	up_write(&efx->filter_sem);
+	return rc;
 }
 
 static void efx_remove_filters(struct efx_nic *efx)
@@ -1697,12 +1710,16 @@ static void efx_remove_filters(struct efx_nic *efx)
 #ifdef CONFIG_RFS_ACCEL
 	kfree(efx->rps_flow_id);
 #endif
+	down_write(&efx->filter_sem);
 	efx->type->filter_table_remove(efx);
+	up_write(&efx->filter_sem);
 }
 
 static void efx_restore_filters(struct efx_nic *efx)
 {
+	down_read(&efx->filter_sem);
 	efx->type->filter_table_restore(efx);
+	up_read(&efx->filter_sem);
 }
 
 /**************************************************************************
@@ -2183,7 +2200,7 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 
 	mutex_lock(&efx->mac_lock);
 	net_dev->mtu = new_mtu;
-	efx->type->reconfigure_mac(efx);
+	efx_mac_reconfigure(efx);
 	mutex_unlock(&efx->mac_lock);
 
 	efx_start_all(efx);
@@ -2219,7 +2236,7 @@ static int efx_set_mac_address(struct net_device *net_dev, void *data)
 
 	/* Reconfigure the MAC */
 	mutex_lock(&efx->mac_lock);
-	efx->type->reconfigure_mac(efx);
+	efx_mac_reconfigure(efx);
 	mutex_unlock(&efx->mac_lock);
 
 	return 0;
@@ -2464,7 +2481,9 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 			   " VFs may not function\n", rc);
 #endif
 
+	down_read(&efx->filter_sem);
 	efx_restore_filters(efx);
+	up_read(&efx->filter_sem);
 	if (efx->type->sriov_reset)
 		efx->type->sriov_reset(efx);
 
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 9097906..46aee41 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -74,6 +74,8 @@ void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue);
 
 /* Filters */
 
+void efx_mac_reconfigure(struct efx_nic *efx);
+
 /**
  * efx_filter_insert_filter - add or replace a filter
  * @efx: NIC in which to insert the filter
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 03829b4..0347976 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -734,7 +734,7 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 	/* Reconfigure the MAC. The PHY *may* generate a link state change event
 	 * if the user just changed the advertised capabilities, but there's no
 	 * harm doing this twice */
-	efx->type->reconfigure_mac(efx);
+	efx_mac_reconfigure(efx);
 
 out:
 	mutex_unlock(&efx->mac_lock);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 55a5f48..f6c4832 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -25,6 +25,7 @@
 #include <linux/highmem.h>
 #include <linux/workqueue.h>
 #include <linux/mutex.h>
+#include <linux/rwsem.h>
 #include <linux/vmalloc.h>
 #include <linux/i2c.h>
 #include <linux/mtd/mtd.h>
@@ -896,7 +897,8 @@ struct vfdi_status;
  * @loopback_mode: Loopback status
  * @loopback_modes: Supported loopback mode bitmask
  * @loopback_selftest: Offline self-test private state
- * @filter_lock: Filter table lock
+ * @filter_sem: Filter table rw_semaphore, for freeing the table
+ * @filter_lock: Filter table lock, for mere content changes
  * @filter_state: Architecture-dependent filter table state
  * @rps_flow_id: Flow IDs of filters allocated for accelerated RFS,
  *	indexed by filter ID
@@ -1038,6 +1040,7 @@ struct efx_nic {
 
 	void *loopback_selftest;
 
+	struct rw_semaphore filter_sem;
 	spinlock_t filter_lock;
 	void *filter_state;
 #ifdef CONFIG_RFS_ACCEL
