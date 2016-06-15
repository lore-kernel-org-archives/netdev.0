From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 06/17] sfc: Move filter IDs to per-VLAN data
 structure
Date: Wed, 15 Jun 2016 17:45:36 +0100
Message-ID: <60c02708-262e-a96c-d63d-30589b74de9c@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:23662 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753122AbcFOQu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:50:29 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

It is a step to support VLAN filtering in HW.
Until then, there is only one struct efx_ef10_filter_vlan per struct
efx_ef10_filter_table, with no VLAN information yet.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 88 ++++++++++++++++++++++++-----------------
 1 file changed, 51 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 120a4b7..7abb8a7 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -50,9 +50,21 @@ enum {
 #define HUNT_FILTER_TBL_ROWS 8192
 
 #define EFX_EF10_FILTER_ID_INVALID 0xffff
+
+#define EFX_EF10_FILTER_DEV_UC_MAX	32
+#define EFX_EF10_FILTER_DEV_MC_MAX	256
+
+/* Per-VLAN filters information */
+struct efx_ef10_filter_vlan {
+	u16 uc[EFX_EF10_FILTER_DEV_UC_MAX];
+	u16 mc[EFX_EF10_FILTER_DEV_MC_MAX];
+	u16 ucdef;
+	u16 bcast;
+	u16 mcdef;
+};
+
 struct efx_ef10_dev_addr {
 	u8 addr[ETH_ALEN];
-	u16 id;
 };
 
 struct efx_ef10_filter_table {
@@ -73,18 +85,13 @@ struct efx_ef10_filter_table {
 	} *entry;
 	wait_queue_head_t waitq;
 /* Shadow of net_device address lists, guarded by mac_lock */
-#define EFX_EF10_FILTER_DEV_UC_MAX	32
-#define EFX_EF10_FILTER_DEV_MC_MAX	256
 	struct efx_ef10_dev_addr dev_uc_list[EFX_EF10_FILTER_DEV_UC_MAX];
 	struct efx_ef10_dev_addr dev_mc_list[EFX_EF10_FILTER_DEV_MC_MAX];
 	int dev_uc_count;
 	int dev_mc_count;
-/* Indices (like efx_ef10_dev_addr.id) for promisc/allmulti filters */
-	u16 ucdef_id;
-	u16 bcast_id;
-	u16 mcdef_id;
 /* Whether in multicast promiscuous mode when last changed */
 	bool mc_promisc_last;
+	struct efx_ef10_filter_vlan vlan;
 };
 
 /* An arbitrary search limit for the software hash table */
@@ -3732,6 +3739,7 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_PARSER_DISP_INFO_OUT_LENMAX);
 	unsigned int pd_match_pri, pd_match_count;
 	struct efx_ef10_filter_table *table;
+	struct efx_ef10_filter_vlan *vlan;
 	unsigned int i;
 	size_t outlen;
 	int rc;
@@ -3784,13 +3792,14 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 		goto fail;
 	}
 
-	for (i = 0; i < ARRAY_SIZE(table->dev_uc_list); i++)
-		table->dev_uc_list[i].id = EFX_EF10_FILTER_ID_INVALID;
-	for (i = 0; i < ARRAY_SIZE(table->dev_mc_list); i++)
-		table->dev_mc_list[i].id = EFX_EF10_FILTER_ID_INVALID;
-	table->ucdef_id = EFX_EF10_FILTER_ID_INVALID;
-	table->bcast_id = EFX_EF10_FILTER_ID_INVALID;
-	table->mcdef_id = EFX_EF10_FILTER_ID_INVALID;
+	vlan = &table->vlan;
+	for (i = 0; i < ARRAY_SIZE(vlan->uc); i++)
+		vlan->uc[i] = EFX_EF10_FILTER_ID_INVALID;
+	for (i = 0; i < ARRAY_SIZE(vlan->mc); i++)
+		vlan->mc[i] = EFX_EF10_FILTER_ID_INVALID;
+	vlan->ucdef = EFX_EF10_FILTER_ID_INVALID;
+	vlan->bcast = EFX_EF10_FILTER_ID_INVALID;
+	vlan->mcdef = EFX_EF10_FILTER_ID_INVALID;
 	table->mc_promisc_last = false;
 
 	efx->filter_state = table;
@@ -3921,6 +3930,7 @@ static void efx_ef10_filter_mark_one_old(struct efx_nic *efx, uint16_t *id)
 static void efx_ef10_filter_mark_old(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
+	struct efx_ef10_filter_vlan *vlan = &table->vlan;
 	unsigned int i;
 
 	if (!table)
@@ -3929,12 +3939,12 @@ static void efx_ef10_filter_mark_old(struct efx_nic *efx)
 	/* Mark old filters that may need to be removed */
 	spin_lock_bh(&efx->filter_lock);
 	for (i = 0; i < table->dev_uc_count; i++)
-		efx_ef10_filter_mark_one_old(efx, &table->dev_uc_list[i].id);
+		efx_ef10_filter_mark_one_old(efx, &vlan->uc[i]);
 	for (i = 0; i < table->dev_mc_count; i++)
-		efx_ef10_filter_mark_one_old(efx, &table->dev_mc_list[i].id);
-	efx_ef10_filter_mark_one_old(efx, &table->ucdef_id);
-	efx_ef10_filter_mark_one_old(efx, &table->bcast_id);
-	efx_ef10_filter_mark_one_old(efx, &table->mcdef_id);
+		efx_ef10_filter_mark_one_old(efx, &vlan->mc[i]);
+	efx_ef10_filter_mark_one_old(efx, &vlan->ucdef);
+	efx_ef10_filter_mark_one_old(efx, &vlan->bcast);
+	efx_ef10_filter_mark_one_old(efx, &vlan->mcdef);
 	spin_unlock_bh(&efx->filter_lock);
 }
 
@@ -3990,20 +4000,24 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 					     bool multicast, bool rollback)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
+	struct efx_ef10_filter_vlan *vlan = &table->vlan;
 	struct efx_ef10_dev_addr *addr_list;
 	enum efx_filter_flags filter_flags;
 	struct efx_filter_spec spec;
 	u8 baddr[ETH_ALEN];
 	unsigned int i, j;
 	int addr_count;
+	u16 *ids;
 	int rc;
 
 	if (multicast) {
 		addr_list = table->dev_mc_list;
 		addr_count = table->dev_mc_count;
+		ids = vlan->mc;
 	} else {
 		addr_list = table->dev_uc_list;
 		addr_count = table->dev_uc_count;
+		ids = vlan->uc;
 	}
 
 	filter_flags = efx_rss_enabled(efx) ? EFX_FILTER_FLAG_RX_RSS : 0;
@@ -4021,12 +4035,12 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 					   rc);
 				/* Fall back to promiscuous */
 				for (j = 0; j < i; j++) {
-					if (addr_list[j].id == EFX_EF10_FILTER_ID_INVALID)
+					if (ids[j] == EFX_EF10_FILTER_ID_INVALID)
 						continue;
 					efx_ef10_filter_remove_unsafe(
 						efx, EFX_FILTER_PRI_AUTO,
-						addr_list[j].id);
-					addr_list[j].id = EFX_EF10_FILTER_ID_INVALID;
+						ids[j]);
+					ids[j] = EFX_EF10_FILTER_ID_INVALID;
 				}
 				return rc;
 			} else {
@@ -4034,7 +4048,7 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 				rc = EFX_EF10_FILTER_ID_INVALID;
 			}
 		}
-		addr_list[i].id = efx_ef10_filter_get_unsafe_id(efx, rc);
+		ids[i] = efx_ef10_filter_get_unsafe_id(efx, rc);
 	}
 
 	if (multicast && rollback) {
@@ -4048,18 +4062,18 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 				   "Broadcast filter insert failed rc=%d\n", rc);
 			/* Fall back to promiscuous */
 			for (j = 0; j < i; j++) {
-				if (addr_list[j].id == EFX_EF10_FILTER_ID_INVALID)
+				if (ids[j] == EFX_EF10_FILTER_ID_INVALID)
 					continue;
 				efx_ef10_filter_remove_unsafe(
 					efx, EFX_FILTER_PRI_AUTO,
-					addr_list[j].id);
-				addr_list[j].id = EFX_EF10_FILTER_ID_INVALID;
+					ids[j]);
+				ids[j] = EFX_EF10_FILTER_ID_INVALID;
 			}
 			return rc;
 		} else {
-			EFX_WARN_ON_PARANOID(table->bcast_id !=
+			EFX_WARN_ON_PARANOID(vlan->bcast !=
 					     EFX_EF10_FILTER_ID_INVALID);
-			table->bcast_id = efx_ef10_filter_get_unsafe_id(efx, rc);
+			vlan->bcast = efx_ef10_filter_get_unsafe_id(efx, rc);
 		}
 	}
 
@@ -4071,6 +4085,7 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx, bool multicast,
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	struct efx_ef10_filter_vlan *vlan = &table->vlan;
 	enum efx_filter_flags filter_flags;
 	struct efx_filter_spec spec;
 	u8 baddr[ETH_ALEN];
@@ -4092,9 +4107,8 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx, bool multicast,
 			     "%scast mismatch filter insert failed rc=%d\n",
 			     multicast ? "Multi" : "Uni", rc);
 	} else if (multicast) {
-		EFX_WARN_ON_PARANOID(table->mcdef_id !=
-				     EFX_EF10_FILTER_ID_INVALID);
-		table->mcdef_id = efx_ef10_filter_get_unsafe_id(efx, rc);
+		EFX_WARN_ON_PARANOID(vlan->mcdef != EFX_EF10_FILTER_ID_INVALID);
+		vlan->mcdef = efx_ef10_filter_get_unsafe_id(efx, rc);
 		if (!nic_data->workaround_26807) {
 			/* Also need an Ethernet broadcast filter */
 			efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
@@ -4111,20 +4125,20 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx, bool multicast,
 					/* Roll back the mc_def filter */
 					efx_ef10_filter_remove_unsafe(
 							efx, EFX_FILTER_PRI_AUTO,
-							table->mcdef_id);
-					table->mcdef_id = EFX_EF10_FILTER_ID_INVALID;
+							vlan->mcdef);
+					vlan->mcdef = EFX_EF10_FILTER_ID_INVALID;
 					return rc;
 				}
 			} else {
-				EFX_WARN_ON_PARANOID(table->bcast_id !=
+				EFX_WARN_ON_PARANOID(vlan->bcast !=
 						     EFX_EF10_FILTER_ID_INVALID);
-				table->bcast_id = efx_ef10_filter_get_unsafe_id(efx, rc);
+				vlan->bcast = efx_ef10_filter_get_unsafe_id(efx, rc);
 			}
 		}
 		rc = 0;
 	} else {
-		EFX_WARN_ON_PARANOID(table->ucdef_id != EFX_EF10_FILTER_ID_INVALID);
-		table->ucdef_id = rc;
+		EFX_WARN_ON_PARANOID(vlan->ucdef != EFX_EF10_FILTER_ID_INVALID);
+		vlan->ucdef = rc;
 		rc = 0;
 	}
 	return rc;
