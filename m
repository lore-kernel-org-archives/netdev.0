From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 08/17] sfc: Make EF10 filter management helper
 functions VLAN-aware
Date: Wed, 15 Jun 2016 17:47:36 +0100
Message-ID: <a7d9aa98-a863-3ac3-52fa-9e0e7e90c0e5@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:43040 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753237AbcFOQue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:50:34 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

It is a step to support VLAN filtering in HW.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 70 ++++++++++++++++++++++++-----------------
 1 file changed, 41 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index a2a10dc..d1bc0dc 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -56,6 +56,7 @@ enum {
 
 /* Per-VLAN filters information */
 struct efx_ef10_filter_vlan {
+	u16 vid;
 	u16 uc[EFX_EF10_FILTER_DEV_UC_MAX];
 	u16 mc[EFX_EF10_FILTER_DEV_MC_MAX];
 	u16 ucdef;
@@ -3795,6 +3796,7 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 	}
 
 	vlan = &table->vlan;
+	vlan->vid = EFX_FILTER_VID_UNSPEC;
 	for (i = 0; i < ARRAY_SIZE(vlan->uc); i++)
 		vlan->uc[i] = EFX_EF10_FILTER_ID_INVALID;
 	for (i = 0; i < ARRAY_SIZE(vlan->mc); i++)
@@ -3929,17 +3931,13 @@ static void efx_ef10_filter_mark_one_old(struct efx_nic *efx, uint16_t *id)
 	}
 }
 
-static void efx_ef10_filter_mark_old(struct efx_nic *efx)
+/* Mark old per-VLAN filters that may need to be removed */
+static void _efx_ef10_filter_vlan_mark_old(struct efx_nic *efx,
+					   struct efx_ef10_filter_vlan *vlan)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
-	struct efx_ef10_filter_vlan *vlan = &table->vlan;
 	unsigned int i;
 
-	if (!table)
-		return;
-
-	/* Mark old filters that may need to be removed */
-	spin_lock_bh(&efx->filter_lock);
 	for (i = 0; i < table->dev_uc_count; i++)
 		efx_ef10_filter_mark_one_old(efx, &vlan->uc[i]);
 	for (i = 0; i < table->dev_mc_count; i++)
@@ -3947,6 +3945,15 @@ static void efx_ef10_filter_mark_old(struct efx_nic *efx)
 	efx_ef10_filter_mark_one_old(efx, &vlan->ucdef);
 	efx_ef10_filter_mark_one_old(efx, &vlan->bcast);
 	efx_ef10_filter_mark_one_old(efx, &vlan->mcdef);
+}
+
+/* Mark old filters that may need to be removed */
+static void efx_ef10_filter_mark_old(struct efx_nic *efx)
+{
+	struct efx_ef10_filter_table *table = efx->filter_state;
+
+	spin_lock_bh(&efx->filter_lock);
+	_efx_ef10_filter_vlan_mark_old(efx, &table->vlan);
 	spin_unlock_bh(&efx->filter_lock);
 }
 
@@ -3997,10 +4004,10 @@ static void efx_ef10_filter_mc_addr_list(struct efx_nic *efx)
 }
 
 static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
-					     bool multicast, bool rollback)
+					    struct efx_ef10_filter_vlan *vlan,
+					    bool multicast, bool rollback)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
-	struct efx_ef10_filter_vlan *vlan = &table->vlan;
 	struct efx_ef10_dev_addr *addr_list;
 	enum efx_filter_flags filter_flags;
 	struct efx_filter_spec spec;
@@ -4025,8 +4032,7 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 	/* Insert/renew filters */
 	for (i = 0; i < addr_count; i++) {
 		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO, filter_flags, 0);
-		efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC,
-					 addr_list[i].addr);
+		efx_filter_set_eth_local(&spec, vlan->vid, addr_list[i].addr);
 		rc = efx_ef10_filter_insert(efx, &spec, true);
 		if (rc < 0) {
 			if (rollback) {
@@ -4055,7 +4061,7 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 		/* Also need an Ethernet broadcast filter */
 		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO, filter_flags, 0);
 		eth_broadcast_addr(baddr);
-		efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC, baddr);
+		efx_filter_set_eth_local(&spec, vlan->vid, baddr);
 		rc = efx_ef10_filter_insert(efx, &spec, true);
 		if (rc < 0) {
 			netif_warn(efx, drv, efx->net_dev,
@@ -4080,12 +4086,11 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 	return 0;
 }
 
-static int efx_ef10_filter_insert_def(struct efx_nic *efx, bool multicast,
-				      bool rollback)
+static int efx_ef10_filter_insert_def(struct efx_nic *efx,
+				      struct efx_ef10_filter_vlan *vlan,
+				      bool multicast, bool rollback)
 {
-	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
-	struct efx_ef10_filter_vlan *vlan = &table->vlan;
 	enum efx_filter_flags filter_flags;
 	struct efx_filter_spec spec;
 	u8 baddr[ETH_ALEN];
@@ -4100,6 +4105,9 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx, bool multicast,
 	else
 		efx_filter_set_uc_def(&spec);
 
+	if (vlan->vid != EFX_FILTER_VID_UNSPEC)
+		efx_filter_set_eth_local(&spec, vlan->vid, NULL);
+
 	rc = efx_ef10_filter_insert(efx, &spec, true);
 	if (rc < 0) {
 		netif_printk(efx, drv, rc == -EPERM ? KERN_DEBUG : KERN_WARNING,
@@ -4114,8 +4122,7 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx, bool multicast,
 			efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
 					   filter_flags, 0);
 			eth_broadcast_addr(baddr);
-			efx_filter_set_eth_local(&spec, EFX_FILTER_VID_UNSPEC,
-						 baddr);
+			efx_filter_set_eth_local(&spec, vlan->vid, baddr);
 			rc = efx_ef10_filter_insert(efx, &spec, true);
 			if (rc < 0) {
 				netif_warn(efx, drv, efx->net_dev,
@@ -4252,6 +4259,7 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	struct net_device *net_dev = efx->net_dev;
+	struct efx_ef10_filter_vlan *vlan;
 
 	if (!efx_dev_registered(efx))
 		return;
@@ -4269,17 +4277,19 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 	efx_ef10_filter_mc_addr_list(efx);
 	netif_addr_unlock_bh(net_dev);
 
+	vlan = &table->vlan;
+
 	/* Insert/renew unicast filters */
 	if (table->uc_promisc) {
-		efx_ef10_filter_insert_def(efx, false, false);
-		efx_ef10_filter_insert_addr_list(efx, false, false);
+		efx_ef10_filter_insert_def(efx, vlan, false, false);
+		efx_ef10_filter_insert_addr_list(efx, vlan, false, false);
 	} else {
 		/* If any of the filters failed to insert, fall back to
 		 * promiscuous mode - add in the uc_def filter.  But keep
 		 * our individual unicast filters.
 		 */
-		if (efx_ef10_filter_insert_addr_list(efx, false, false))
-			efx_ef10_filter_insert_def(efx, false, false);
+		if (efx_ef10_filter_insert_addr_list(efx, vlan, false, false))
+			efx_ef10_filter_insert_def(efx, vlan, false, false);
 	}
 
 	/* Insert/renew multicast filters */
@@ -4294,17 +4304,18 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 			/* If we failed to insert promiscuous filters, rollback
 			 * and fall back to individual multicast filters
 			 */
-			if (efx_ef10_filter_insert_def(efx, true, true)) {
+			if (efx_ef10_filter_insert_def(efx, vlan, true, true)) {
 				/* Changing promisc state, so remove old filters */
 				efx_ef10_filter_remove_old(efx);
-				efx_ef10_filter_insert_addr_list(efx, true, false);
+				efx_ef10_filter_insert_addr_list(efx, vlan,
+								 true, false);
 			}
 		} else {
 			/* If we failed to insert promiscuous filters, don't
 			 * rollback.  Regardless, also insert the mc_list
 			 */
-			efx_ef10_filter_insert_def(efx, true, false);
-			efx_ef10_filter_insert_addr_list(efx, true, false);
+			efx_ef10_filter_insert_def(efx, vlan, true, false);
+			efx_ef10_filter_insert_addr_list(efx, vlan, true, false);
 		}
 	} else {
 		/* If any filters failed to insert, rollback and fall back to
@@ -4312,12 +4323,13 @@ static void efx_ef10_filter_sync_rx_mode(struct efx_nic *efx)
 		 * that fails, roll back again and insert as many of our
 		 * individual multicast filters as we can.
 		 */
-		if (efx_ef10_filter_insert_addr_list(efx, true, true)) {
+		if (efx_ef10_filter_insert_addr_list(efx, vlan, true, true)) {
 			/* Changing promisc state, so remove old filters */
 			if (nic_data->workaround_26807)
 				efx_ef10_filter_remove_old(efx);
-			if (efx_ef10_filter_insert_def(efx, true, true))
-				efx_ef10_filter_insert_addr_list(efx, true, false);
+			if (efx_ef10_filter_insert_def(efx, vlan, true, true))
+				efx_ef10_filter_insert_addr_list(efx, vlan,
+								 true, false);
 		}
 	}
 
