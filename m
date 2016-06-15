From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 05/17] sfc: Forget filter ID when the filter is
 marked old
Date: Wed, 15 Jun 2016 17:44:20 +0100
Message-ID: <9256467b-d92a-9fdb-cf40-c511b6ad37f5@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:43021 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752096AbcFOQu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:50:28 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

It is required to remove setting of filter IDs to invalid from multicast
and unicast addresses caching functions.
Add initialization to invalid when filter table is created.
Add paranoid checks to track consistency.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 53 +++++++++++++++++++++++++----------------
 1 file changed, 33 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 66cc963..120a4b7 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3732,6 +3732,7 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_PARSER_DISP_INFO_OUT_LENMAX);
 	unsigned int pd_match_pri, pd_match_count;
 	struct efx_ef10_filter_table *table;
+	unsigned int i;
 	size_t outlen;
 	int rc;
 
@@ -3783,6 +3784,10 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 		goto fail;
 	}
 
+	for (i = 0; i < ARRAY_SIZE(table->dev_uc_list); i++)
+		table->dev_uc_list[i].id = EFX_EF10_FILTER_ID_INVALID;
+	for (i = 0; i < ARRAY_SIZE(table->dev_mc_list); i++)
+		table->dev_mc_list[i].id = EFX_EF10_FILTER_ID_INVALID;
 	table->ucdef_id = EFX_EF10_FILTER_ID_INVALID;
 	table->bcast_id = EFX_EF10_FILTER_ID_INVALID;
 	table->mcdef_id = EFX_EF10_FILTER_ID_INVALID;
@@ -3897,19 +3902,26 @@ static void efx_ef10_filter_table_remove(struct efx_nic *efx)
 	kfree(table);
 }
 
-#define EFX_EF10_FILTER_DO_MARK_OLD(id) \
-	if (id != EFX_EF10_FILTER_ID_INVALID) { \
-		filter_idx = efx_ef10_filter_get_unsafe_id(efx, id); \
-		if (!table->entry[filter_idx].spec) \
-			netif_dbg(efx, drv, efx->net_dev, \
-				  "%s: marked null spec old %04x:%04x\n", \
-				  __func__, id, filter_idx); \
-		table->entry[filter_idx].spec |= EFX_EF10_FILTER_FLAG_AUTO_OLD;\
+static void efx_ef10_filter_mark_one_old(struct efx_nic *efx, uint16_t *id)
+{
+	struct efx_ef10_filter_table *table = efx->filter_state;
+	unsigned int filter_idx;
+
+	if (*id != EFX_EF10_FILTER_ID_INVALID) {
+		filter_idx = efx_ef10_filter_get_unsafe_id(efx, *id);
+		if (!table->entry[filter_idx].spec)
+			netif_dbg(efx, drv, efx->net_dev,
+				  "marked null spec old %04x:%04x\n", *id,
+				  filter_idx);
+		table->entry[filter_idx].spec |= EFX_EF10_FILTER_FLAG_AUTO_OLD;
+		*id = EFX_EF10_FILTER_ID_INVALID;
 	}
+}
+
 static void efx_ef10_filter_mark_old(struct efx_nic *efx)
 {
 	struct efx_ef10_filter_table *table = efx->filter_state;
-	unsigned int filter_idx, i;
+	unsigned int i;
 
 	if (!table)
 		return;
@@ -3917,15 +3929,14 @@ static void efx_ef10_filter_mark_old(struct efx_nic *efx)
 	/* Mark old filters that may need to be removed */
 	spin_lock_bh(&efx->filter_lock);
 	for (i = 0; i < table->dev_uc_count; i++)
-		EFX_EF10_FILTER_DO_MARK_OLD(table->dev_uc_list[i].id);
+		efx_ef10_filter_mark_one_old(efx, &table->dev_uc_list[i].id);
 	for (i = 0; i < table->dev_mc_count; i++)
-		EFX_EF10_FILTER_DO_MARK_OLD(table->dev_mc_list[i].id);
-	EFX_EF10_FILTER_DO_MARK_OLD(table->ucdef_id);
-	EFX_EF10_FILTER_DO_MARK_OLD(table->bcast_id);
-	EFX_EF10_FILTER_DO_MARK_OLD(table->mcdef_id);
+		efx_ef10_filter_mark_one_old(efx, &table->dev_mc_list[i].id);
+	efx_ef10_filter_mark_one_old(efx, &table->ucdef_id);
+	efx_ef10_filter_mark_one_old(efx, &table->bcast_id);
+	efx_ef10_filter_mark_one_old(efx, &table->mcdef_id);
 	spin_unlock_bh(&efx->filter_lock);
 }
-#undef EFX_EF10_FILTER_DO_MARK_OLD
 
 static void efx_ef10_filter_uc_addr_list(struct efx_nic *efx, bool *promisc)
 {
@@ -3935,7 +3946,6 @@ static void efx_ef10_filter_uc_addr_list(struct efx_nic *efx, bool *promisc)
 	int addr_count;
 	unsigned int i;
 
-	table->ucdef_id = EFX_EF10_FILTER_ID_INVALID;
 	addr_count = netdev_uc_count(net_dev);
 	if (net_dev->flags & IFF_PROMISC)
 		*promisc = true;
@@ -3948,7 +3958,6 @@ static void efx_ef10_filter_uc_addr_list(struct efx_nic *efx, bool *promisc)
 			break;
 		}
 		ether_addr_copy(table->dev_uc_list[i].addr, uc->addr);
-		table->dev_uc_list[i].id = EFX_EF10_FILTER_ID_INVALID;
 		i++;
 	}
 }
@@ -3960,8 +3969,6 @@ static void efx_ef10_filter_mc_addr_list(struct efx_nic *efx, bool *promisc)
 	struct netdev_hw_addr *mc;
 	unsigned int i, addr_count;
 
-	table->mcdef_id = EFX_EF10_FILTER_ID_INVALID;
-	table->bcast_id = EFX_EF10_FILTER_ID_INVALID;
 	if (net_dev->flags & (IFF_PROMISC | IFF_ALLMULTI))
 		*promisc = true;
 
@@ -3973,7 +3980,6 @@ static void efx_ef10_filter_mc_addr_list(struct efx_nic *efx, bool *promisc)
 			break;
 		}
 		ether_addr_copy(table->dev_mc_list[i].addr, mc->addr);
-		table->dev_mc_list[i].id = EFX_EF10_FILTER_ID_INVALID;
 		i++;
 	}
 
@@ -4051,6 +4057,8 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 			}
 			return rc;
 		} else {
+			EFX_WARN_ON_PARANOID(table->bcast_id !=
+					     EFX_EF10_FILTER_ID_INVALID);
 			table->bcast_id = efx_ef10_filter_get_unsafe_id(efx, rc);
 		}
 	}
@@ -4084,6 +4092,8 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx, bool multicast,
 			     "%scast mismatch filter insert failed rc=%d\n",
 			     multicast ? "Multi" : "Uni", rc);
 	} else if (multicast) {
+		EFX_WARN_ON_PARANOID(table->mcdef_id !=
+				     EFX_EF10_FILTER_ID_INVALID);
 		table->mcdef_id = efx_ef10_filter_get_unsafe_id(efx, rc);
 		if (!nic_data->workaround_26807) {
 			/* Also need an Ethernet broadcast filter */
@@ -4106,11 +4116,14 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx, bool multicast,
 					return rc;
 				}
 			} else {
+				EFX_WARN_ON_PARANOID(table->bcast_id !=
+						     EFX_EF10_FILTER_ID_INVALID);
 				table->bcast_id = efx_ef10_filter_get_unsafe_id(efx, rc);
 			}
 		}
 		rc = 0;
 	} else {
+		EFX_WARN_ON_PARANOID(table->ucdef_id != EFX_EF10_FILTER_ID_INVALID);
 		table->ucdef_id = rc;
 		rc = 0;
 	}
