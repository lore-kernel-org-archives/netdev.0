From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 13/17] sfc: Fix dup unknown multicast/unicast filters
 after datapath reset
Date: Wed, 15 Jun 2016 17:49:30 +0100
Message-ID: <3a20584b-5c82-2a42-1a55-b0243633e9eb@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:43053 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753263AbcFOQum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:50:42 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

Filter match flags are not unique criteria to be mapped to priority
because of both unknown unicast and unknown multicast are mapped to
LOC_MAC_IG. So, local MAC is required to map filter to priority.
MCDI filter flags is unique criteria to find filter priority.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 80 +++++++++++++++++++++++++++++++++++------
 1 file changed, 69 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index d4f9e94..626054d 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -76,8 +76,8 @@ struct efx_ef10_dev_addr {
 };
 
 struct efx_ef10_filter_table {
-/* The RX match field masks supported by this fw & hw, in order of priority */
-	enum efx_filter_match_flags rx_match_flags[
+/* The MCDI match masks supported by this fw & hw, in order of priority */
+	u32 rx_match_mcdi_flags[
 		MC_CMD_GET_PARSER_DISP_INFO_OUT_SUPPORTED_MATCHES_MAXNUM];
 	unsigned int rx_match_count;
 
@@ -3214,15 +3214,55 @@ static int efx_ef10_filter_push(struct efx_nic *efx,
 	return rc;
 }
 
-static int efx_ef10_filter_rx_match_pri(struct efx_ef10_filter_table *table,
-					enum efx_filter_match_flags match_flags)
+static u32 efx_ef10_filter_mcdi_flags_from_spec(const struct efx_filter_spec *spec)
 {
+	unsigned int match_flags = spec->match_flags;
+	u32 mcdi_flags = 0;
+
+	if (match_flags & EFX_FILTER_MATCH_LOC_MAC_IG) {
+		match_flags &= ~EFX_FILTER_MATCH_LOC_MAC_IG;
+		mcdi_flags |=
+			is_multicast_ether_addr(spec->loc_mac) ?
+			(1 << MC_CMD_FILTER_OP_IN_MATCH_UNKNOWN_MCAST_DST_LBN) :
+			(1 << MC_CMD_FILTER_OP_IN_MATCH_UNKNOWN_UCAST_DST_LBN);
+	}
+
+#define MAP_FILTER_TO_MCDI_FLAG(gen_flag, mcdi_field) {			\
+		unsigned int old_match_flags = match_flags;		\
+		match_flags &= ~EFX_FILTER_MATCH_ ## gen_flag;		\
+		if (match_flags != old_match_flags)			\
+			mcdi_flags |=					\
+				(1 << MC_CMD_FILTER_OP_IN_MATCH_ ##	\
+				 mcdi_field ## _LBN);			\
+	}
+	MAP_FILTER_TO_MCDI_FLAG(REM_HOST, SRC_IP);
+	MAP_FILTER_TO_MCDI_FLAG(LOC_HOST, DST_IP);
+	MAP_FILTER_TO_MCDI_FLAG(REM_MAC, SRC_MAC);
+	MAP_FILTER_TO_MCDI_FLAG(REM_PORT, SRC_PORT);
+	MAP_FILTER_TO_MCDI_FLAG(LOC_MAC, DST_MAC);
+	MAP_FILTER_TO_MCDI_FLAG(LOC_PORT, DST_PORT);
+	MAP_FILTER_TO_MCDI_FLAG(ETHER_TYPE, ETHER_TYPE);
+	MAP_FILTER_TO_MCDI_FLAG(INNER_VID, INNER_VLAN);
+	MAP_FILTER_TO_MCDI_FLAG(OUTER_VID, OUTER_VLAN);
+	MAP_FILTER_TO_MCDI_FLAG(IP_PROTO, IP_PROTO);
+#undef MAP_FILTER_TO_MCDI_FLAG
+
+	/* Did we map them all? */
+	WARN_ON_ONCE(match_flags);
+
+	return mcdi_flags;
+}
+
+static int efx_ef10_filter_pri(struct efx_ef10_filter_table *table,
+			       const struct efx_filter_spec *spec)
+{
+	u32 mcdi_flags = efx_ef10_filter_mcdi_flags_from_spec(spec);
 	unsigned int match_pri;
 
 	for (match_pri = 0;
 	     match_pri < table->rx_match_count;
 	     match_pri++)
-		if (table->rx_match_flags[match_pri] == match_flags)
+		if (table->rx_match_mcdi_flags[match_pri] == mcdi_flags)
 			return match_pri;
 
 	return -EPROTONOSUPPORT;
@@ -3248,7 +3288,7 @@ static s32 efx_ef10_filter_insert(struct efx_nic *efx,
 	    EFX_FILTER_FLAG_RX)
 		return -EINVAL;
 
-	rc = efx_ef10_filter_rx_match_pri(table, spec->match_flags);
+	rc = efx_ef10_filter_pri(table, spec);
 	if (rc < 0)
 		return rc;
 	match_pri = rc;
@@ -3487,7 +3527,7 @@ static int efx_ef10_filter_remove_internal(struct efx_nic *efx,
 	spec = efx_ef10_filter_entry_spec(table, filter_idx);
 	if (!spec ||
 	    (!by_index &&
-	     efx_ef10_filter_rx_match_pri(table, spec->match_flags) !=
+	     efx_ef10_filter_pri(table, spec) !=
 	     filter_id / HUNT_FILTER_TBL_ROWS)) {
 		rc = -ENOENT;
 		goto out_unlock;
@@ -3589,7 +3629,7 @@ static int efx_ef10_filter_get_safe(struct efx_nic *efx,
 	spin_lock_bh(&efx->filter_lock);
 	saved_spec = efx_ef10_filter_entry_spec(table, filter_idx);
 	if (saved_spec && saved_spec->priority == priority &&
-	    efx_ef10_filter_rx_match_pri(table, saved_spec->match_flags) ==
+	    efx_ef10_filter_pri(table, saved_spec) ==
 	    filter_id / HUNT_FILTER_TBL_ROWS) {
 		*spec = *saved_spec;
 		rc = 0;
@@ -3662,8 +3702,7 @@ static s32 efx_ef10_filter_get_rx_ids(struct efx_nic *efx,
 				count = -EMSGSIZE;
 				break;
 			}
-			buf[count++] = (efx_ef10_filter_rx_match_pri(
-						table, spec->match_flags) *
+			buf[count++] = (efx_ef10_filter_pri(table, spec) *
 					HUNT_FILTER_TBL_ROWS +
 					filter_idx);
 		}
@@ -3915,6 +3954,24 @@ static void efx_ef10_filter_cleanup_vlans(struct efx_nic *efx)
 		efx_ef10_filter_del_vlan_internal(efx, vlan);
 }
 
+static bool efx_ef10_filter_match_supported(struct efx_ef10_filter_table *table,
+					    enum efx_filter_match_flags match_flags)
+{
+	unsigned int match_pri;
+	int mf;
+
+	for (match_pri = 0;
+	     match_pri < table->rx_match_count;
+	     match_pri++) {
+		mf = efx_ef10_filter_match_flags_from_mcdi(
+				table->rx_match_mcdi_flags[match_pri]);
+		if (mf == match_flags)
+			return true;
+	}
+
+	return false;
+}
+
 static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_GET_PARSER_DISP_INFO_IN_LEN);
@@ -3964,7 +4021,8 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 				  "%s: fw flags %#x pri %u supported as driver flags %#x pri %u\n",
 				  __func__, mcdi_flags, pd_match_pri,
 				  rc, table->rx_match_count);
-			table->rx_match_flags[table->rx_match_count++] = rc;
+			table->rx_match_mcdi_flags[table->rx_match_count] = mcdi_flags;
+			table->rx_match_count++;
 		}
 	}
 
