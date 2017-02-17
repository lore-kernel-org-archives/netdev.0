From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/3] sfc: fix filter_id misinterpretation in edge
 case
Date: Fri, 17 Feb 2017 15:49:13 +0000
Message-ID: <682fa8b8-1efe-bdcc-9eee-db931f80be3a@solarflare.com>
References: <f49743cd-3227-4d30-9d6d-bd2f8400df62@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:65534 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934431AbdBQPtY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 10:49:24 -0500
In-Reply-To: <f49743cd-3227-4d30-9d6d-bd2f8400df62@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

On EF10, hardware filter IDs are 13 bits, but in some places we store
 32-bit "full filter IDs" in which higher order bits encode the filter
 match-priority.  This could cause a filter to have a full filter ID of
 0xffff, which is also the value EFX_EF10_FILTER_ID_INVALID which we use
 in 16-bit "short" filter IDs (without match-priority bits).  This would
 occur if the hardware filter ID was 0x1fff and the match-priority was 7.
Unfortunately, some code that checks for EFX_EF10_FILTER_ID_INVALID can
 be called on full filter IDs, and will WARN_ON if this ever happens.
So, since we have plenty of spare bits in the full filter ID, this patch
 shifts the priority bits left one bit when constructing the full filter
 IDs, ensuring that the 0x2000 bit of a full filter ID will always be 0
 and thus no full filter ID can ever equal EFX_EF10_FILTER_ID_INVALID.

This patch also replaces open-coded full<->short filter ID conversions
 with calls to functions, thus keeping the definition of the full filter
 ID format in one place.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 48 +++++++++++++++++++++++++----------------
 1 file changed, 30 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index b29a819..7da9699 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -134,6 +134,22 @@ static void efx_ef10_filter_del_vlan_internal(struct efx_nic *efx,
 static void efx_ef10_filter_del_vlan(struct efx_nic *efx, u16 vid);
 static int efx_ef10_set_udp_tnl_ports(struct efx_nic *efx, bool unloading);
 
+static u32 efx_ef10_filter_get_unsafe_id(u32 filter_id)
+{
+	WARN_ON_ONCE(filter_id == EFX_EF10_FILTER_ID_INVALID);
+	return filter_id & (HUNT_FILTER_TBL_ROWS - 1);
+}
+
+static unsigned int efx_ef10_filter_get_unsafe_pri(u32 filter_id)
+{
+	return filter_id / (HUNT_FILTER_TBL_ROWS * 2);
+}
+
+static u32 efx_ef10_make_filter_id(unsigned int pri, u16 idx)
+{
+	return pri * HUNT_FILTER_TBL_ROWS * 2 + idx;
+}
+
 static int efx_ef10_get_warm_boot_count(struct efx_nic *efx)
 {
 	efx_dword_t reg;
@@ -4194,7 +4210,7 @@ static s32 efx_ef10_filter_insert(struct efx_nic *efx,
 
 	/* If successful, return the inserted filter ID */
 	if (rc == 0)
-		rc = match_pri * HUNT_FILTER_TBL_ROWS + ins_index;
+		rc = efx_ef10_make_filter_id(match_pri, ins_index);
 
 	wake_up_all(&table->waitq);
 out_unlock:
@@ -4217,7 +4233,7 @@ static int efx_ef10_filter_remove_internal(struct efx_nic *efx,
 					   unsigned int priority_mask,
 					   u32 filter_id, bool by_index)
 {
-	unsigned int filter_idx = filter_id % HUNT_FILTER_TBL_ROWS;
+	unsigned int filter_idx = efx_ef10_filter_get_unsafe_id(filter_id);
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	MCDI_DECLARE_BUF(inbuf,
 			 MC_CMD_FILTER_OP_IN_HANDLE_OFST +
@@ -4244,7 +4260,7 @@ static int efx_ef10_filter_remove_internal(struct efx_nic *efx,
 	if (!spec ||
 	    (!by_index &&
 	     efx_ef10_filter_pri(table, spec) !=
-	     filter_id / HUNT_FILTER_TBL_ROWS)) {
+	     efx_ef10_filter_get_unsafe_pri(filter_id))) {
 		rc = -ENOENT;
 		goto out_unlock;
 	}
@@ -4319,11 +4335,6 @@ static int efx_ef10_filter_remove_safe(struct efx_nic *efx,
 					       filter_id, false);
 }
 
-static u32 efx_ef10_filter_get_unsafe_id(struct efx_nic *efx, u32 filter_id)
-{
-	return filter_id % HUNT_FILTER_TBL_ROWS;
-}
-
 static void efx_ef10_filter_remove_unsafe(struct efx_nic *efx,
 					  enum efx_filter_priority priority,
 					  u32 filter_id)
@@ -4337,7 +4348,7 @@ static int efx_ef10_filter_get_safe(struct efx_nic *efx,
 				    enum efx_filter_priority priority,
 				    u32 filter_id, struct efx_filter_spec *spec)
 {
-	unsigned int filter_idx = filter_id % HUNT_FILTER_TBL_ROWS;
+	unsigned int filter_idx = efx_ef10_filter_get_unsafe_id(filter_id);
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	const struct efx_filter_spec *saved_spec;
 	int rc;
@@ -4346,7 +4357,7 @@ static int efx_ef10_filter_get_safe(struct efx_nic *efx,
 	saved_spec = efx_ef10_filter_entry_spec(table, filter_idx);
 	if (saved_spec && saved_spec->priority == priority &&
 	    efx_ef10_filter_pri(table, saved_spec) ==
-	    filter_id / HUNT_FILTER_TBL_ROWS) {
+	    efx_ef10_filter_get_unsafe_pri(filter_id)) {
 		*spec = *saved_spec;
 		rc = 0;
 	} else {
@@ -4398,7 +4409,7 @@ static u32 efx_ef10_filter_get_rx_id_limit(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
 
-	return table->rx_match_count * HUNT_FILTER_TBL_ROWS;
+	return table->rx_match_count * HUNT_FILTER_TBL_ROWS * 2;
 }
 
 static s32 efx_ef10_filter_get_rx_ids(struct efx_nic *efx,
@@ -4418,8 +4429,9 @@ static s32 efx_ef10_filter_get_rx_ids(struct efx_nic *efx,
 				count = -EMSGSIZE;
 				break;
 			}
-			buf[count++] = (efx_ef10_filter_pri(table, spec) *
-					HUNT_FILTER_TBL_ROWS +
+			buf[count++] =
+				efx_ef10_make_filter_id(
+					efx_ef10_filter_pri(table, spec),
 					filter_idx);
 		}
 	}
@@ -4971,7 +4983,7 @@ static void efx_ef10_filter_mark_one_old(struct efx_nic *efx, uint16_t *id)
 	unsigned int filter_idx;
 
 	if (*id != EFX_EF10_FILTER_ID_INVALID) {
-		filter_idx = efx_ef10_filter_get_unsafe_id(efx, *id);
+		filter_idx = efx_ef10_filter_get_unsafe_id(*id);
 		if (!table->entry[filter_idx].spec)
 			netif_dbg(efx, drv, efx->net_dev,
 				  "marked null spec old %04x:%04x\n", *id,
@@ -5106,7 +5118,7 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 				rc = EFX_EF10_FILTER_ID_INVALID;
 			}
 		}
-		ids[i] = efx_ef10_filter_get_unsafe_id(efx, rc);
+		ids[i] = efx_ef10_filter_get_unsafe_id(rc);
 	}
 
 	if (multicast && rollback) {
@@ -5130,7 +5142,7 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 			return rc;
 		} else {
 			vlan->default_filters[EFX_EF10_BCAST] =
-				efx_ef10_filter_get_unsafe_id(efx, rc);
+				efx_ef10_filter_get_unsafe_id(rc);
 		}
 	}
 
@@ -5225,7 +5237,7 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx,
 		id = &vlan->default_filters[map[encap_type]];
 
 		EFX_WARN_ON_PARANOID(*id != EFX_EF10_FILTER_ID_INVALID);
-		*id = efx_ef10_filter_get_unsafe_id(efx, rc);
+		*id = efx_ef10_filter_get_unsafe_id(rc);
 		if (!nic_data->workaround_26807 && !encap_type) {
 			/* Also need an Ethernet broadcast filter */
 			efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
@@ -5250,7 +5262,7 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx,
 					vlan->default_filters[EFX_EF10_BCAST] !=
 					EFX_EF10_FILTER_ID_INVALID);
 				vlan->default_filters[EFX_EF10_BCAST] =
-					efx_ef10_filter_get_unsafe_id(efx, rc);
+					efx_ef10_filter_get_unsafe_id(rc);
 			}
 		}
 		rc = 0;
