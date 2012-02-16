From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 06/19] sfc: Add support for TX MAC filters
Date: Thu, 16 Feb 2012 00:46:54 +0000
Message-ID: <1329353214.2565.32.camel@bwh-desktop>
References: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27607 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753584Ab2BPAr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:47:56 -0500
In-Reply-To: <1329352938.2565.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Siena each TX queue can be configured to send only packets for
which there is a TX MAC filter that matches the source MAC address,
queue ID, and optionally VID.  This will be used to implement the
'spoofchk' feature for SR-IOV virtual functions.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/filter.c |   63 ++++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/sfc/filter.h |   14 +++++++-
 2 files changed, 72 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index 92517ea..fea7f73 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -36,6 +36,7 @@ enum efx_filter_table_id {
 	EFX_FILTER_TABLE_RX_IP = 0,
 	EFX_FILTER_TABLE_RX_MAC,
 	EFX_FILTER_TABLE_RX_DEF,
+	EFX_FILTER_TABLE_TX_MAC,
 	EFX_FILTER_TABLE_COUNT,
 };
 
@@ -97,8 +98,9 @@ efx_filter_spec_table_id(const struct efx_filter_spec *spec)
 	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_IP != (EFX_FILTER_UDP_WILD >> 2));
 	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_MAC != (EFX_FILTER_MAC_FULL >> 2));
 	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_MAC != (EFX_FILTER_MAC_WILD >> 2));
+	BUILD_BUG_ON(EFX_FILTER_TABLE_TX_MAC != EFX_FILTER_TABLE_RX_MAC + 2);
 	EFX_BUG_ON_PARANOID(spec->type == EFX_FILTER_UNSPEC);
-	return spec->type >> 2;
+	return (spec->type >> 2) + ((spec->flags & EFX_FILTER_FLAG_TX) ? 2 : 0);
 }
 
 static struct efx_filter_table *
@@ -179,6 +181,29 @@ static void efx_filter_push_rx_config(struct efx_nic *efx)
 	efx_writeo(efx, &filter_ctl, FR_BZ_RX_FILTER_CTL);
 }
 
+static void efx_filter_push_tx_limits(struct efx_nic *efx)
+{
+	struct efx_filter_state *state = efx->filter_state;
+	struct efx_filter_table *table;
+	efx_oword_t tx_cfg;
+
+	efx_reado(efx, &tx_cfg, FR_AZ_TX_CFG);
+
+	table = &state->table[EFX_FILTER_TABLE_TX_MAC];
+	if (table->size) {
+		EFX_SET_OWORD_FIELD(
+			tx_cfg, FRF_CZ_TX_ETH_FILTER_FULL_SEARCH_RANGE,
+			table->search_depth[EFX_FILTER_MAC_FULL] +
+			FILTER_CTL_SRCH_FUDGE_FULL);
+		EFX_SET_OWORD_FIELD(
+			tx_cfg, FRF_CZ_TX_ETH_FILTER_WILD_SEARCH_RANGE,
+			table->search_depth[EFX_FILTER_MAC_WILD] +
+			FILTER_CTL_SRCH_FUDGE_WILD);
+	}
+
+	efx_writeo(efx, &tx_cfg, FR_AZ_TX_CFG);
+}
+
 static inline void __efx_filter_set_ipv4(struct efx_filter_spec *spec,
 					 __be32 host1, __be16 port1,
 					 __be32 host2, __be16 port2)
@@ -333,7 +358,8 @@ int efx_filter_get_ipv4_full(const struct efx_filter_spec *spec,
 int efx_filter_set_eth_local(struct efx_filter_spec *spec,
 			     u16 vid, const u8 *addr)
 {
-	EFX_BUG_ON_PARANOID(!(spec->flags & EFX_FILTER_FLAG_RX));
+	EFX_BUG_ON_PARANOID(!(spec->flags &
+			      (EFX_FILTER_FLAG_RX | EFX_FILTER_FLAG_TX)));
 
 	/* This cannot currently be combined with other filtering */
 	if (spec->type != EFX_FILTER_UNSPEC)
@@ -471,6 +497,18 @@ static u32 efx_filter_build(efx_oword_t *filter, struct efx_filter_spec *spec)
 		break;
 	}
 
+	case EFX_FILTER_TABLE_TX_MAC: {
+		bool is_wild = spec->type == EFX_FILTER_MAC_WILD;
+		EFX_POPULATE_OWORD_5(*filter,
+				     FRF_CZ_TMFT_TXQ_ID, spec->dmaq_id,
+				     FRF_CZ_TMFT_WILDCARD_MATCH, is_wild,
+				     FRF_CZ_TMFT_SRC_MAC_HI, spec->data[2],
+				     FRF_CZ_TMFT_SRC_MAC_LO, spec->data[1],
+				     FRF_CZ_TMFT_VLAN_ID, spec->data[0]);
+		data3 = is_wild | spec->dmaq_id << 1;
+		break;
+	}
+
 	default:
 		BUG();
 	}
@@ -485,6 +523,10 @@ static bool efx_filter_equal(const struct efx_filter_spec *left,
 	    memcmp(left->data, right->data, sizeof(left->data)))
 		return false;
 
+	if (left->flags & EFX_FILTER_FLAG_TX &&
+	    left->dmaq_id != right->dmaq_id)
+		return false;
+
 	return true;
 }
 
@@ -581,8 +623,11 @@ static inline u8 efx_filter_id_flags(u32 id)
 
 	if (match_pri < EFX_FILTER_MATCH_PRI_NORMAL_BASE)
 		return EFX_FILTER_FLAG_RX | EFX_FILTER_FLAG_RX_OVERRIDE_IP;
-	else
+	else if (match_pri <=
+		 EFX_FILTER_MATCH_PRI_NORMAL_BASE + EFX_FILTER_TABLE_RX_DEF)
 		return EFX_FILTER_FLAG_RX;
+	else
+		return EFX_FILTER_FLAG_TX;
 }
 
 u32 efx_filter_get_rx_id_limit(struct efx_nic *efx)
@@ -660,7 +705,10 @@ s32 efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 	} else {
 		if (table->search_depth[spec->type] < depth) {
 			table->search_depth[spec->type] = depth;
-			efx_filter_push_rx_config(efx);
+			if (spec->flags & EFX_FILTER_FLAG_TX)
+				efx_filter_push_tx_limits(efx);
+			else
+				efx_filter_push_rx_config(efx);
 		}
 
 		efx_writeo(efx, &filter,
@@ -918,6 +966,7 @@ void efx_restore_filters(struct efx_nic *efx)
 	}
 
 	efx_filter_push_rx_config(efx);
+	efx_filter_push_tx_limits(efx);
 
 	spin_unlock_bh(&state->lock);
 }
@@ -960,6 +1009,12 @@ int efx_probe_filters(struct efx_nic *efx)
 		table = &state->table[EFX_FILTER_TABLE_RX_DEF];
 		table->id = EFX_FILTER_TABLE_RX_DEF;
 		table->size = EFX_FILTER_SIZE_RX_DEF;
+
+		table = &state->table[EFX_FILTER_TABLE_TX_MAC];
+		table->id = EFX_FILTER_TABLE_TX_MAC;
+		table->offset = FR_CZ_TX_MAC_FILTER_TBL0;
+		table->size = FR_CZ_TX_MAC_FILTER_TBL0_ROWS;
+		table->step = FR_CZ_TX_MAC_FILTER_TBL0_STEP;
 	}
 
 	for (table_id = 0; table_id < EFX_FILTER_TABLE_COUNT; table_id++) {
diff --git a/drivers/net/ethernet/sfc/filter.h b/drivers/net/ethernet/sfc/filter.h
index 4519978..3c77802 100644
--- a/drivers/net/ethernet/sfc/filter.h
+++ b/drivers/net/ethernet/sfc/filter.h
@@ -43,7 +43,8 @@ enum efx_filter_type {
  * enum efx_filter_priority - priority of a hardware filter specification
  * @EFX_FILTER_PRI_HINT: Performance hint
  * @EFX_FILTER_PRI_MANUAL: Manually configured filter
- * @EFX_FILTER_PRI_REQUIRED: Required for correct behaviour
+ * @EFX_FILTER_PRI_REQUIRED: Required for correct behaviour (user-level
+ *	networking and SR-IOV)
  */
 enum efx_filter_priority {
 	EFX_FILTER_PRI_HINT = 0,
@@ -64,12 +65,14 @@ enum efx_filter_priority {
  *	any IP filter that matches the same packet.  By default, IP
  *	filters take precedence.
  * @EFX_FILTER_FLAG_RX: Filter is for RX
+ * @EFX_FILTER_FLAG_TX: Filter is for TX
  */
 enum efx_filter_flags {
 	EFX_FILTER_FLAG_RX_RSS = 0x01,
 	EFX_FILTER_FLAG_RX_SCATTER = 0x02,
 	EFX_FILTER_FLAG_RX_OVERRIDE_IP = 0x04,
 	EFX_FILTER_FLAG_RX = 0x08,
+	EFX_FILTER_FLAG_TX = 0x10,
 };
 
 /**
@@ -107,6 +110,15 @@ static inline void efx_filter_init_rx(struct efx_filter_spec *spec,
 	spec->dmaq_id = rxq_id;
 }
 
+static inline void efx_filter_init_tx(struct efx_filter_spec *spec,
+				      unsigned txq_id)
+{
+	spec->type = EFX_FILTER_UNSPEC;
+	spec->priority = EFX_FILTER_PRI_REQUIRED;
+	spec->flags = EFX_FILTER_FLAG_TX;
+	spec->dmaq_id = txq_id;
+}
+
 extern int efx_filter_set_ipv4_local(struct efx_filter_spec *spec, u8 proto,
 				     __be32 host, __be16 port);
 extern int efx_filter_get_ipv4_local(const struct efx_filter_spec *spec,
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
