From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 09/17] sfc: Implement list of VLANs added over
 interface
Date: Wed, 15 Jun 2016 17:48:14 +0100
Message-ID: <4f0a1788-5f3d-fead-5c20-8f5c50a78cfe@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:5200 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932738AbcFOQup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:50:45 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

Right now it contains dummy VLAN entry with unspecified VID only.
The entry is used for the case when HW VLAN filtering is not used.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 325 +++++++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/sfc/nic.h  |   5 +
 2 files changed, 295 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index d1bc0dc..6dd0a79 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -54,8 +54,15 @@ enum {
 #define EFX_EF10_FILTER_DEV_UC_MAX	32
 #define EFX_EF10_FILTER_DEV_MC_MAX	256
 
+/* VLAN list entry */
+struct efx_ef10_vlan {
+	struct list_head list;
+	u16 vid;
+};
+
 /* Per-VLAN filters information */
 struct efx_ef10_filter_vlan {
+	struct list_head list;
 	u16 vid;
 	u16 uc[EFX_EF10_FILTER_DEV_UC_MAX];
 	u16 mc[EFX_EF10_FILTER_DEV_MC_MAX];
@@ -94,7 +101,7 @@ struct efx_ef10_filter_table {
 	bool mc_promisc;
 /* Whether in multicast promiscuous mode when last changed */
 	bool mc_promisc_last;
-	struct efx_ef10_filter_vlan vlan;
+	struct list_head vlan_list;
 };
 
 /* An arbitrary search limit for the software hash table */
@@ -102,6 +109,10 @@ struct efx_ef10_filter_table {
 
 static void efx_ef10_rx_free_indir_table(struct efx_nic *efx);
 static void efx_ef10_filter_table_remove(struct efx_nic *efx);
+static int efx_ef10_filter_add_vlan(struct efx_nic *efx, u16 vid);
+static void efx_ef10_filter_del_vlan_internal(struct efx_nic *efx,
+					      struct efx_ef10_filter_vlan *vlan);
+static void efx_ef10_filter_del_vlan(struct efx_nic *efx, u16 vid);
 
 static int efx_ef10_get_warm_boot_count(struct efx_nic *efx)
 {
@@ -287,6 +298,96 @@ static ssize_t efx_ef10_show_primary_flag(struct device *dev,
 		       ? 1 : 0);
 }
 
+static struct efx_ef10_vlan *efx_ef10_find_vlan(struct efx_nic *efx, u16 vid)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	struct efx_ef10_vlan *vlan;
+
+	WARN_ON(!mutex_is_locked(&nic_data->vlan_lock));
+
+	list_for_each_entry(vlan, &nic_data->vlan_list, list) {
+		if (vlan->vid == vid)
+			return vlan;
+	}
+
+	return NULL;
+}
+
+static int efx_ef10_add_vlan(struct efx_nic *efx, u16 vid)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	struct efx_ef10_vlan *vlan;
+	int rc;
+
+	mutex_lock(&nic_data->vlan_lock);
+
+	vlan = efx_ef10_find_vlan(efx, vid);
+	if (vlan) {
+		netif_warn(efx, drv, efx->net_dev,
+			   "VLAN %u already added\n", vid);
+		rc = -EALREADY;
+		goto fail_exist;
+	}
+
+	rc = -ENOMEM;
+	vlan = kzalloc(sizeof(*vlan), GFP_KERNEL);
+	if (!vlan)
+		goto fail_alloc;
+
+	vlan->vid = vid;
+
+	list_add_tail(&vlan->list, &nic_data->vlan_list);
+
+	if (efx->filter_state) {
+		mutex_lock(&efx->mac_lock);
+		down_write(&efx->filter_sem);
+		rc = efx_ef10_filter_add_vlan(efx, vlan->vid);
+		up_write(&efx->filter_sem);
+		mutex_unlock(&efx->mac_lock);
+		if (rc)
+			goto fail_filter_add_vlan;
+	}
+
+	mutex_unlock(&nic_data->vlan_lock);
+	return 0;
+
+fail_filter_add_vlan:
+	list_del(&vlan->list);
+	kfree(vlan);
+fail_alloc:
+fail_exist:
+	mutex_unlock(&nic_data->vlan_lock);
+	return rc;
+}
+
+static void efx_ef10_del_vlan_internal(struct efx_nic *efx,
+				       struct efx_ef10_vlan *vlan)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+
+	WARN_ON(!mutex_is_locked(&nic_data->vlan_lock));
+
+	if (efx->filter_state) {
+		down_write(&efx->filter_sem);
+		efx_ef10_filter_del_vlan(efx, vlan->vid);
+		up_write(&efx->filter_sem);
+	}
+
+	list_del(&vlan->list);
+	kfree(vlan);
+}
+
+static void efx_ef10_cleanup_vlans(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	struct efx_ef10_vlan *vlan, *next_vlan;
+
+	mutex_lock(&nic_data->vlan_lock);
+	list_for_each_entry_safe(vlan, next_vlan, &nic_data->vlan_list, list)
+		efx_ef10_del_vlan_internal(efx, vlan);
+	mutex_unlock(&nic_data->vlan_lock);
+}
+
 static DEVICE_ATTR(link_control_flag, 0444, efx_ef10_show_link_control_flag,
 		   NULL);
 static DEVICE_ATTR(primary_flag, 0444, efx_ef10_show_primary_flag, NULL);
@@ -433,8 +534,20 @@ static int efx_ef10_probe(struct efx_nic *efx)
 #endif
 		ether_addr_copy(nic_data->port_id, efx->net_dev->perm_addr);
 
+	INIT_LIST_HEAD(&nic_data->vlan_list);
+	mutex_init(&nic_data->vlan_lock);
+
+	/* Add unspecified VID to support VLAN filtering being disabled */
+	rc = efx_ef10_add_vlan(efx, EFX_FILTER_VID_UNSPEC);
+	if (rc)
+		goto fail_add_vid_unspec;
+
 	return 0;
 
+fail_add_vid_unspec:
+	mutex_destroy(&nic_data->vlan_lock);
+	efx_ptp_remove(efx);
+	efx_mcdi_mon_remove(efx);
 fail5:
 	device_remove_file(&efx->pci_dev->dev, &dev_attr_primary_flag);
 fail4:
@@ -688,6 +801,9 @@ static void efx_ef10_remove(struct efx_nic *efx)
 	}
 #endif
 
+	efx_ef10_cleanup_vlans(efx);
+	mutex_destroy(&nic_data->vlan_lock);
+
 	efx_ptp_remove(efx);
 
 	efx_mcdi_mon_remove(efx);
@@ -3736,14 +3852,30 @@ static int efx_ef10_filter_match_flags_from_mcdi(u32 mcdi_flags)
 	return match_flags;
 }
 
+static void efx_ef10_filter_cleanup_vlans(struct efx_nic *efx)
+{
+	struct efx_ef10_filter_table *table = efx->filter_state;
+	struct efx_ef10_filter_vlan *vlan, *next_vlan;
+
+	/* See comment in efx_ef10_filter_table_remove() */
+	if (!efx_rwsem_assert_write_locked(&efx->filter_sem))
+		return;
+
+	if (!table)
+		return;
+
+	list_for_each_entry_safe(vlan, next_vlan, &table->vlan_list, list)
+		efx_ef10_filter_del_vlan_internal(efx, vlan);
+}
+
 static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_GET_PARSER_DISP_INFO_IN_LEN);
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_PARSER_DISP_INFO_OUT_LENMAX);
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	unsigned int pd_match_pri, pd_match_count;
 	struct efx_ef10_filter_table *table;
-	struct efx_ef10_filter_vlan *vlan;
-	unsigned int i;
+	struct efx_ef10_vlan *vlan;
 	size_t outlen;
 	int rc;
 
@@ -3795,21 +3927,23 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 		goto fail;
 	}
 
-	vlan = &table->vlan;
-	vlan->vid = EFX_FILTER_VID_UNSPEC;
-	for (i = 0; i < ARRAY_SIZE(vlan->uc); i++)
-		vlan->uc[i] = EFX_EF10_FILTER_ID_INVALID;
-	for (i = 0; i < ARRAY_SIZE(vlan->mc); i++)
-		vlan->mc[i] = EFX_EF10_FILTER_ID_INVALID;
-	vlan->ucdef = EFX_EF10_FILTER_ID_INVALID;
-	vlan->bcast = EFX_EF10_FILTER_ID_INVALID;
-	vlan->mcdef = EFX_EF10_FILTER_ID_INVALID;
 	table->mc_promisc_last = false;
+	INIT_LIST_HEAD(&table->vlan_list);
 
 	efx->filter_state = table;
 	init_waitqueue_head(&table->waitq);
+
+	list_for_each_entry(vlan, &nic_data->vlan_list, list) {
+		rc = efx_ef10_filter_add_vlan(efx, vlan->vid);
+		if (rc)
+			goto fail_add_vlan;
+	}
+
 	return 0;
 
+fail_add_vlan:
+	efx_ef10_filter_cleanup_vlans(efx);
+	efx->filter_state = NULL;
 fail:
 	kfree(table);
 	return rc;
@@ -3878,6 +4012,7 @@ static void efx_ef10_filter_table_remove(struct efx_nic *efx)
 	unsigned int filter_idx;
 	int rc;
 
+	efx_ef10_filter_cleanup_vlans(efx);
 	efx->filter_state = NULL;
 	/* If we were called without locking, then it's not safe to free
 	 * the table as others might be using it.  So we just WARN, leak
@@ -3947,13 +4082,18 @@ static void _efx_ef10_filter_vlan_mark_old(struct efx_nic *efx,
 	efx_ef10_filter_mark_one_old(efx, &vlan->mcdef);
 }
 
-/* Mark old filters that may need to be removed */
+/* Mark old filters that may need to be removed.
+ * Caller must hold efx->filter_sem for read if race against
+ * efx_ef10_filter_table_remove() is possible
+ */
 static void efx_ef10_filter_mark_old(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
+	struct efx_ef10_filter_vlan *vlan;
 
 	spin_lock_bh(&efx->filter_lock);
-	_efx_ef10_filter_vlan_mark_old(efx, &table->vlan);
+	list_for_each_entry(vlan, &table->vlan_list, list)
+		_efx_ef10_filter_vlan_mark_old(efx, vlan);
 	spin_unlock_bh(&efx->filter_lock);
 }
 
@@ -4254,30 +4394,11 @@ reset_nic:
 /* Caller must hold efx->filter_sem for read if race against
  * efx_ef10_filter_table_remove() is possible
  */
-static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
+static void efx_ef10_filter_vlan_sync_rx_mode(struct efx_nic *efx,
+					      struct efx_ef10_filter_vlan *vlan)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
-	struct net_device *net_dev = efx->net_dev;
-	struct efx_ef10_filter_vlan *vlan;
-
-	if (!efx_dev_registered(efx))
-		return;
-
-	if (!table)
-		return;
-
-	efx_ef10_filter_mark_old(efx);
-
-	/* Copy/convert the address lists; add the primary station
-	 * address and broadcast address
-	 */
-	netif_addr_lock_bh(net_dev);
-	efx_ef10_filter_uc_addr_list(efx);
-	efx_ef10_filter_mc_addr_list(efx);
-	netif_addr_unlock_bh(net_dev);
-
-	vlan = &table->vlan;
 
 	/* Insert/renew unicast filters */
 	if (table->uc_promisc) {
@@ -4332,11 +4453,145 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 								 true, false);
 		}
 	}
+}
+
+/* Caller must hold efx->filter_sem for read if race against
+ * efx_ef10_filter_table_remove() is possible
+ */
+static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
+{
+	struct efx_ef10_filter_table *table = efx->filter_state;
+	struct net_device *net_dev = efx->net_dev;
+	struct efx_ef10_filter_vlan *vlan;
+
+	if (!efx_dev_registered(efx))
+		return;
+
+	if (!table)
+		return;
+
+	efx_ef10_filter_mark_old(efx);
+
+	/* Copy/convert the address lists; add the primary station
+	 * address and broadcast address
+	 */
+	netif_addr_lock_bh(net_dev);
+	efx_ef10_filter_uc_addr_list(efx);
+	efx_ef10_filter_mc_addr_list(efx);
+	netif_addr_unlock_bh(net_dev);
+
+	list_for_each_entry(vlan, &table->vlan_list, list)
+		efx_ef10_filter_vlan_sync_rx_mode(efx, vlan);
 
 	efx_ef10_filter_remove_old(efx);
 	table->mc_promisc_last = table->mc_promisc;
 }
 
+static struct efx_ef10_filter_vlan *efx_ef10_filter_find_vlan(struct efx_nic *efx, u16 vid)
+{
+	struct efx_ef10_filter_table *table = efx->filter_state;
+	struct efx_ef10_filter_vlan *vlan;
+
+	WARN_ON(!rwsem_is_locked(&efx->filter_sem));
+
+	list_for_each_entry(vlan, &table->vlan_list, list) {
+		if (vlan->vid == vid)
+			return vlan;
+	}
+
+	return NULL;
+}
+
+static int efx_ef10_filter_add_vlan(struct efx_nic *efx, u16 vid)
+{
+	struct efx_ef10_filter_table *table = efx->filter_state;
+	struct efx_ef10_filter_vlan *vlan;
+	unsigned int i;
+
+	if (!efx_rwsem_assert_write_locked(&efx->filter_sem))
+		return -EINVAL;
+
+	vlan = efx_ef10_filter_find_vlan(efx, vid);
+	if (WARN_ON(vlan)) {
+		netif_err(efx, drv, efx->net_dev,
+			  "VLAN %u already added\n", vid);
+		return -EALREADY;
+	}
+
+	vlan = kzalloc(sizeof(*vlan), GFP_KERNEL);
+	if (!vlan)
+		return -ENOMEM;
+
+	vlan->vid = vid;
+
+	for (i = 0; i < ARRAY_SIZE(vlan->uc); i++)
+		vlan->uc[i] = EFX_EF10_FILTER_ID_INVALID;
+	for (i = 0; i < ARRAY_SIZE(vlan->mc); i++)
+		vlan->mc[i] = EFX_EF10_FILTER_ID_INVALID;
+	vlan->ucdef = EFX_EF10_FILTER_ID_INVALID;
+	vlan->bcast = EFX_EF10_FILTER_ID_INVALID;
+	vlan->mcdef = EFX_EF10_FILTER_ID_INVALID;
+
+	list_add_tail(&vlan->list, &table->vlan_list);
+
+	if (efx_dev_registered(efx))
+		efx_ef10_filter_vlan_sync_rx_mode(efx, vlan);
+
+	return 0;
+}
+
+static void efx_ef10_filter_del_vlan_internal(struct efx_nic *efx,
+					      struct efx_ef10_filter_vlan *vlan)
+{
+	unsigned int i;
+
+	/* See comment in efx_ef10_filter_table_remove() */
+	if (!efx_rwsem_assert_write_locked(&efx->filter_sem))
+		return;
+
+	list_del(&vlan->list);
+
+	for (i = 0; i < ARRAY_SIZE(vlan->uc); i++) {
+		if (vlan->uc[i] != EFX_EF10_FILTER_ID_INVALID)
+			efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO,
+						      vlan->uc[i]);
+	}
+	for (i = 0; i < ARRAY_SIZE(vlan->mc); i++) {
+		if (vlan->mc[i] != EFX_EF10_FILTER_ID_INVALID)
+			efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO,
+						      vlan->mc[i]);
+	}
+	if (vlan->ucdef != EFX_EF10_FILTER_ID_INVALID)
+		efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO,
+					      vlan->ucdef);
+	if (vlan->bcast != EFX_EF10_FILTER_ID_INVALID)
+		efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO,
+					      vlan->bcast);
+	if (vlan->mcdef != EFX_EF10_FILTER_ID_INVALID)
+		efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO,
+					      vlan->mcdef);
+
+	kfree(vlan);
+}
+
+static void efx_ef10_filter_del_vlan(struct efx_nic *efx, u16 vid)
+{
+	struct efx_ef10_filter_vlan *vlan;
+
+	/* See comment in efx_ef10_filter_table_remove() */
+	if (!efx_rwsem_assert_write_locked(&efx->filter_sem))
+		return;
+
+	vlan = efx_ef10_filter_find_vlan(efx, vid);
+	if (!vlan) {
+		netif_err(efx, drv, efx->net_dev,
+			  "VLAN %u not found in filter state\n", vid);
+		return;
+	}
+
+	efx_ef10_filter_del_vlan_internal(efx, vlan);
+}
+
 static int efx_ef10_set_mac_address(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_VADAPTOR_SET_MAC_IN_LEN);
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 0b536e2..96944c3 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -519,6 +519,9 @@ enum {
 #ifdef CONFIG_SFC_SRIOV
  * @vf: Pointer to VF data structure
 #endif
+ * @vport_mac: The MAC address on the vport, only for PFs; VFs will be zero
+ * @vlan_list: List of VLANs added over the interface. Serialised by vlan_lock.
+ * @vlan_lock: Lock to serialize access to vlan_list.
  */
 struct efx_ef10_nic_data {
 	struct efx_buffer mcdi_buf;
@@ -550,6 +553,8 @@ struct efx_ef10_nic_data {
 	struct ef10_vf *vf;
 #endif
 	u8 vport_mac[ETH_ALEN];
+	struct list_head vlan_list;
+	struct mutex vlan_lock;
 };
 
 int efx_init_sriov(void);
