From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 3/3] sfc: insert catch-all filters for encapsulated
 traffic
Date: Thu, 26 Jan 2017 17:54:03 +0000
Message-ID: <e528a69f-5c1b-f9e6-225c-47b9726722e4@solarflare.com>
References: <39d8923f-4400-506c-dd50-250636ff83fa@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:45158 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753883AbdAZRyM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 12:54:12 -0500
In-Reply-To: <39d8923f-4400-506c-dd50-250636ff83fa@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

8000 series adapters support filtering VXLAN, NVGRE and GENEVE traffic
 based on inner fields, and when the NIC recognises such traffic, it
 does not match unencapsulated traffic filters any more.  So add catch-
 all filters for encapsulated traffic on supporting platforms.
Although recognition of VXLAN and GENEVE is based on UDP ports, and thus
 will not occur until the driver (on the primary PF) notifies the
 firmware of UDP ports to use, NVGRE will always be recognised, hence
 without this patch 8000 series adapters will drop all NVGRE traffic.

Partly based on patches by Jon Cooper <jcooper@solarflare.com>.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c   | 554 ++++++++++++++++++++++++++++----------
 drivers/net/ethernet/sfc/filter.h |  41 ++-
 2 files changed, 449 insertions(+), 146 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index d0c1ed0e..8bec938 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -60,15 +60,33 @@ struct efx_ef10_vlan {
 	u16 vid;
 };
 
+enum efx_ef10_default_filters {
+	EFX_EF10_BCAST,
+	EFX_EF10_UCDEF,
+	EFX_EF10_MCDEF,
+	EFX_EF10_VXLAN4_UCDEF,
+	EFX_EF10_VXLAN4_MCDEF,
+	EFX_EF10_VXLAN6_UCDEF,
+	EFX_EF10_VXLAN6_MCDEF,
+	EFX_EF10_NVGRE4_UCDEF,
+	EFX_EF10_NVGRE4_MCDEF,
+	EFX_EF10_NVGRE6_UCDEF,
+	EFX_EF10_NVGRE6_MCDEF,
+	EFX_EF10_GENEVE4_UCDEF,
+	EFX_EF10_GENEVE4_MCDEF,
+	EFX_EF10_GENEVE6_UCDEF,
+	EFX_EF10_GENEVE6_MCDEF,
+
+	EFX_EF10_NUM_DEFAULT_FILTERS
+};
+
 /* Per-VLAN filters information */
 struct efx_ef10_filter_vlan {
 	struct list_head list;
 	u16 vid;
 	u16 uc[EFX_EF10_FILTER_DEV_UC_MAX];
 	u16 mc[EFX_EF10_FILTER_DEV_MC_MAX];
-	u16 ucdef;
-	u16 bcast;
-	u16 mcdef;
+	u16 default_filters[EFX_EF10_NUM_DEFAULT_FILTERS];
 };
 
 struct efx_ef10_dev_addr {
@@ -78,7 +96,7 @@ struct efx_ef10_dev_addr {
 struct efx_ef10_filter_table {
 /* The MCDI match masks supported by this fw & hw, in order of priority */
 	u32 rx_match_mcdi_flags[
-		MC_CMD_GET_PARSER_DISP_INFO_OUT_SUPPORTED_MATCHES_MAXNUM];
+		MC_CMD_GET_PARSER_DISP_INFO_OUT_SUPPORTED_MATCHES_MAXNUM * 2];
 	unsigned int rx_match_count;
 
 	struct {
@@ -3592,6 +3610,104 @@ efx_ef10_filter_set_entry(struct efx_ef10_filter_table *table,
 	table->entry[filter_idx].spec =	(unsigned long)spec | flags;
 }
 
+static void
+efx_ef10_filter_push_prep_set_match_fields(struct efx_nic *efx,
+					   const struct efx_filter_spec *spec,
+					   efx_dword_t *inbuf)
+{
+	enum efx_encap_type encap_type = efx_filter_get_encap_type(spec);
+	u32 match_fields = 0, uc_match, mc_match;
+
+	MCDI_SET_DWORD(inbuf, FILTER_OP_IN_OP,
+		       efx_ef10_filter_is_exclusive(spec) ?
+		       MC_CMD_FILTER_OP_IN_OP_INSERT :
+		       MC_CMD_FILTER_OP_IN_OP_SUBSCRIBE);
+
+	/* Convert match flags and values.  Unlike almost
+	 * everything else in MCDI, these fields are in
+	 * network byte order.
+	 */
+#define COPY_VALUE(value, mcdi_field)					     \
+	do {							     \
+		match_fields |=					     \
+			1 << MC_CMD_FILTER_OP_IN_MATCH_ ##	     \
+			mcdi_field ## _LBN;			     \
+		BUILD_BUG_ON(					     \
+			MC_CMD_FILTER_OP_IN_ ## mcdi_field ## _LEN < \
+			sizeof(value));				     \
+		memcpy(MCDI_PTR(inbuf, FILTER_OP_IN_ ##	mcdi_field), \
+		       &value, sizeof(value));			     \
+	} while (0)
+#define COPY_FIELD(gen_flag, gen_field, mcdi_field)			     \
+	if (spec->match_flags & EFX_FILTER_MATCH_ ## gen_flag) {     \
+		COPY_VALUE(spec->gen_field, mcdi_field);	     \
+	}
+	/* Handle encap filters first.  They will always be mismatch
+	 * (unknown UC or MC) filters
+	 */
+	if (encap_type) {
+		/* ether_type and outer_ip_proto need to be variables
+		 * because COPY_VALUE wants to memcpy them
+		 */
+		__be16 ether_type =
+			htons(encap_type & EFX_ENCAP_FLAG_IPV6 ?
+			      ETH_P_IPV6 : ETH_P_IP);
+		u8 vni_type = MC_CMD_FILTER_OP_EXT_IN_VNI_TYPE_GENEVE;
+		u8 outer_ip_proto;
+
+		switch (encap_type & EFX_ENCAP_TYPES_MASK) {
+		case EFX_ENCAP_TYPE_VXLAN:
+			vni_type = MC_CMD_FILTER_OP_EXT_IN_VNI_TYPE_VXLAN;
+			/* fallthrough */
+		case EFX_ENCAP_TYPE_GENEVE:
+			COPY_VALUE(ether_type, ETHER_TYPE);
+			outer_ip_proto = IPPROTO_UDP;
+			COPY_VALUE(outer_ip_proto, IP_PROTO);
+			/* We always need to set the type field, even
+			 * though we're not matching on the TNI.
+			 */
+			MCDI_POPULATE_DWORD_1(inbuf,
+				FILTER_OP_EXT_IN_VNI_OR_VSID,
+				FILTER_OP_EXT_IN_VNI_TYPE,
+				vni_type);
+			break;
+		case EFX_ENCAP_TYPE_NVGRE:
+			COPY_VALUE(ether_type, ETHER_TYPE);
+			outer_ip_proto = IPPROTO_GRE;
+			COPY_VALUE(outer_ip_proto, IP_PROTO);
+			break;
+		default:
+			WARN_ON(1);
+		}
+
+		uc_match = MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_UNKNOWN_UCAST_DST_LBN;
+		mc_match = MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_UNKNOWN_MCAST_DST_LBN;
+	} else {
+		uc_match = MC_CMD_FILTER_OP_EXT_IN_MATCH_UNKNOWN_UCAST_DST_LBN;
+		mc_match = MC_CMD_FILTER_OP_EXT_IN_MATCH_UNKNOWN_MCAST_DST_LBN;
+	}
+
+	if (spec->match_flags & EFX_FILTER_MATCH_LOC_MAC_IG)
+		match_fields |=
+			is_multicast_ether_addr(spec->loc_mac) ?
+			1 << mc_match :
+			1 << uc_match;
+	COPY_FIELD(REM_HOST, rem_host, SRC_IP);
+	COPY_FIELD(LOC_HOST, loc_host, DST_IP);
+	COPY_FIELD(REM_MAC, rem_mac, SRC_MAC);
+	COPY_FIELD(REM_PORT, rem_port, SRC_PORT);
+	COPY_FIELD(LOC_MAC, loc_mac, DST_MAC);
+	COPY_FIELD(LOC_PORT, loc_port, DST_PORT);
+	COPY_FIELD(ETHER_TYPE, ether_type, ETHER_TYPE);
+	COPY_FIELD(INNER_VID, inner_vid, INNER_VLAN);
+	COPY_FIELD(OUTER_VID, outer_vid, OUTER_VLAN);
+	COPY_FIELD(IP_PROTO, ip_proto, IP_PROTO);
+#undef COPY_FIELD
+#undef COPY_VALUE
+	MCDI_SET_DWORD(inbuf, FILTER_OP_IN_MATCH_FIELDS,
+		       match_fields);
+}
+
 static void efx_ef10_filter_push_prep(struct efx_nic *efx,
 				      const struct efx_filter_spec *spec,
 				      efx_dword_t *inbuf, u64 handle,
@@ -3600,7 +3716,7 @@ static void efx_ef10_filter_push_prep(struct efx_nic *efx,
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	u32 flags = spec->flags;
 
-	memset(inbuf, 0, MC_CMD_FILTER_OP_IN_LEN);
+	memset(inbuf, 0, MC_CMD_FILTER_OP_EXT_IN_LEN);
 
 	/* Remove RSS flag if we don't have an RSS context. */
 	if (flags & EFX_FILTER_FLAG_RX_RSS &&
@@ -3613,46 +3729,7 @@ static void efx_ef10_filter_push_prep(struct efx_nic *efx,
 			       MC_CMD_FILTER_OP_IN_OP_REPLACE);
 		MCDI_SET_QWORD(inbuf, FILTER_OP_IN_HANDLE, handle);
 	} else {
-		u32 match_fields = 0;
-
-		MCDI_SET_DWORD(inbuf, FILTER_OP_IN_OP,
-			       efx_ef10_filter_is_exclusive(spec) ?
-			       MC_CMD_FILTER_OP_IN_OP_INSERT :
-			       MC_CMD_FILTER_OP_IN_OP_SUBSCRIBE);
-
-		/* Convert match flags and values.  Unlike almost
-		 * everything else in MCDI, these fields are in
-		 * network byte order.
-		 */
-		if (spec->match_flags & EFX_FILTER_MATCH_LOC_MAC_IG)
-			match_fields |=
-				is_multicast_ether_addr(spec->loc_mac) ?
-				1 << MC_CMD_FILTER_OP_IN_MATCH_UNKNOWN_MCAST_DST_LBN :
-				1 << MC_CMD_FILTER_OP_IN_MATCH_UNKNOWN_UCAST_DST_LBN;
-#define COPY_FIELD(gen_flag, gen_field, mcdi_field)			     \
-		if (spec->match_flags & EFX_FILTER_MATCH_ ## gen_flag) {     \
-			match_fields |=					     \
-				1 << MC_CMD_FILTER_OP_IN_MATCH_ ##	     \
-				mcdi_field ## _LBN;			     \
-			BUILD_BUG_ON(					     \
-				MC_CMD_FILTER_OP_IN_ ## mcdi_field ## _LEN < \
-				sizeof(spec->gen_field));		     \
-			memcpy(MCDI_PTR(inbuf, FILTER_OP_IN_ ##	mcdi_field), \
-			       &spec->gen_field, sizeof(spec->gen_field));   \
-		}
-		COPY_FIELD(REM_HOST, rem_host, SRC_IP);
-		COPY_FIELD(LOC_HOST, loc_host, DST_IP);
-		COPY_FIELD(REM_MAC, rem_mac, SRC_MAC);
-		COPY_FIELD(REM_PORT, rem_port, SRC_PORT);
-		COPY_FIELD(LOC_MAC, loc_mac, DST_MAC);
-		COPY_FIELD(LOC_PORT, loc_port, DST_PORT);
-		COPY_FIELD(ETHER_TYPE, ether_type, ETHER_TYPE);
-		COPY_FIELD(INNER_VID, inner_vid, INNER_VLAN);
-		COPY_FIELD(OUTER_VID, outer_vid, OUTER_VLAN);
-		COPY_FIELD(IP_PROTO, ip_proto, IP_PROTO);
-#undef COPY_FIELD
-		MCDI_SET_DWORD(inbuf, FILTER_OP_IN_MATCH_FIELDS,
-			       match_fields);
+		efx_ef10_filter_push_prep_set_match_fields(efx, spec, inbuf);
 	}
 
 	MCDI_SET_DWORD(inbuf, FILTER_OP_IN_PORT_ID, nic_data->vport_id);
@@ -3681,8 +3758,8 @@ static int efx_ef10_filter_push(struct efx_nic *efx,
 				const struct efx_filter_spec *spec,
 				u64 *handle, bool replacing)
 {
-	MCDI_DECLARE_BUF(inbuf, MC_CMD_FILTER_OP_IN_LEN);
-	MCDI_DECLARE_BUF(outbuf, MC_CMD_FILTER_OP_OUT_LEN);
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_FILTER_OP_EXT_IN_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_FILTER_OP_EXT_OUT_LEN);
 	int rc;
 
 	efx_ef10_filter_push_prep(efx, spec, inbuf, *handle, replacing);
@@ -3697,37 +3774,58 @@ static int efx_ef10_filter_push(struct efx_nic *efx,
 
 static u32 efx_ef10_filter_mcdi_flags_from_spec(const struct efx_filter_spec *spec)
 {
+	enum efx_encap_type encap_type = efx_filter_get_encap_type(spec);
 	unsigned int match_flags = spec->match_flags;
+	unsigned int uc_match, mc_match;
 	u32 mcdi_flags = 0;
 
-	if (match_flags & EFX_FILTER_MATCH_LOC_MAC_IG) {
-		match_flags &= ~EFX_FILTER_MATCH_LOC_MAC_IG;
-		mcdi_flags |=
-			is_multicast_ether_addr(spec->loc_mac) ?
-			(1 << MC_CMD_FILTER_OP_IN_MATCH_UNKNOWN_MCAST_DST_LBN) :
-			(1 << MC_CMD_FILTER_OP_IN_MATCH_UNKNOWN_UCAST_DST_LBN);
-	}
-
-#define MAP_FILTER_TO_MCDI_FLAG(gen_flag, mcdi_field) {			\
-		unsigned int old_match_flags = match_flags;		\
+#define MAP_FILTER_TO_MCDI_FLAG(gen_flag, mcdi_field, encap) {		\
+		unsigned int  old_match_flags = match_flags;		\
 		match_flags &= ~EFX_FILTER_MATCH_ ## gen_flag;		\
 		if (match_flags != old_match_flags)			\
 			mcdi_flags |=					\
-				(1 << MC_CMD_FILTER_OP_IN_MATCH_ ##	\
-				 mcdi_field ## _LBN);			\
+				(1 << ((encap) ?			\
+				       MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_ ## \
+				       mcdi_field ## _LBN :		\
+				       MC_CMD_FILTER_OP_EXT_IN_MATCH_ ##\
+				       mcdi_field ## _LBN));		\
 	}
-	MAP_FILTER_TO_MCDI_FLAG(REM_HOST, SRC_IP);
-	MAP_FILTER_TO_MCDI_FLAG(LOC_HOST, DST_IP);
-	MAP_FILTER_TO_MCDI_FLAG(REM_MAC, SRC_MAC);
-	MAP_FILTER_TO_MCDI_FLAG(REM_PORT, SRC_PORT);
-	MAP_FILTER_TO_MCDI_FLAG(LOC_MAC, DST_MAC);
-	MAP_FILTER_TO_MCDI_FLAG(LOC_PORT, DST_PORT);
-	MAP_FILTER_TO_MCDI_FLAG(ETHER_TYPE, ETHER_TYPE);
-	MAP_FILTER_TO_MCDI_FLAG(INNER_VID, INNER_VLAN);
-	MAP_FILTER_TO_MCDI_FLAG(OUTER_VID, OUTER_VLAN);
-	MAP_FILTER_TO_MCDI_FLAG(IP_PROTO, IP_PROTO);
+	/* inner or outer based on encap type */
+	MAP_FILTER_TO_MCDI_FLAG(REM_HOST, SRC_IP, encap_type);
+	MAP_FILTER_TO_MCDI_FLAG(LOC_HOST, DST_IP, encap_type);
+	MAP_FILTER_TO_MCDI_FLAG(REM_MAC, SRC_MAC, encap_type);
+	MAP_FILTER_TO_MCDI_FLAG(REM_PORT, SRC_PORT, encap_type);
+	MAP_FILTER_TO_MCDI_FLAG(LOC_MAC, DST_MAC, encap_type);
+	MAP_FILTER_TO_MCDI_FLAG(LOC_PORT, DST_PORT, encap_type);
+	MAP_FILTER_TO_MCDI_FLAG(ETHER_TYPE, ETHER_TYPE, encap_type);
+	MAP_FILTER_TO_MCDI_FLAG(IP_PROTO, IP_PROTO, encap_type);
+	/* always outer */
+	MAP_FILTER_TO_MCDI_FLAG(INNER_VID, INNER_VLAN, false);
+	MAP_FILTER_TO_MCDI_FLAG(OUTER_VID, OUTER_VLAN, false);
 #undef MAP_FILTER_TO_MCDI_FLAG
 
+	/* special handling for encap type, and mismatch */
+	if (encap_type) {
+		match_flags &= ~EFX_FILTER_MATCH_ENCAP_TYPE;
+		mcdi_flags |=
+			(1 << MC_CMD_FILTER_OP_EXT_IN_MATCH_ETHER_TYPE_LBN);
+		mcdi_flags |= (1 << MC_CMD_FILTER_OP_EXT_IN_MATCH_IP_PROTO_LBN);
+
+		uc_match = MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_UNKNOWN_UCAST_DST_LBN;
+		mc_match = MC_CMD_FILTER_OP_EXT_IN_MATCH_IFRM_UNKNOWN_MCAST_DST_LBN;
+	} else {
+		uc_match = MC_CMD_FILTER_OP_EXT_IN_MATCH_UNKNOWN_UCAST_DST_LBN;
+		mc_match = MC_CMD_FILTER_OP_EXT_IN_MATCH_UNKNOWN_MCAST_DST_LBN;
+	}
+
+	if (match_flags & EFX_FILTER_MATCH_LOC_MAC_IG) {
+		match_flags &= ~EFX_FILTER_MATCH_LOC_MAC_IG;
+		mcdi_flags |=
+			is_multicast_ether_addr(spec->loc_mac) ?
+			1 << mc_match :
+			1 << uc_match;
+	}
+
 	/* Did we map them all? */
 	WARN_ON_ONCE(match_flags);
 
@@ -4387,29 +4485,54 @@ efx_ef10_filter_rfs_expire_complete(struct efx_nic *efx,
 
 #endif /* CONFIG_RFS_ACCEL */
 
-static int efx_ef10_filter_match_flags_from_mcdi(u32 mcdi_flags)
+static int efx_ef10_filter_match_flags_from_mcdi(bool encap, u32 mcdi_flags)
 {
 	int match_flags = 0;
 
-#define MAP_FLAG(gen_flag, mcdi_field) {				\
+#define MAP_FLAG(gen_flag, mcdi_field) do {				\
 		u32 old_mcdi_flags = mcdi_flags;			\
-		mcdi_flags &= ~(1 << MC_CMD_FILTER_OP_IN_MATCH_ ##	\
-				mcdi_field ## _LBN);			\
+		mcdi_flags &= ~(1 << MC_CMD_FILTER_OP_EXT_IN_MATCH_ ##	\
+				     mcdi_field ## _LBN);		\
 		if (mcdi_flags != old_mcdi_flags)			\
 			match_flags |= EFX_FILTER_MATCH_ ## gen_flag;	\
+	} while (0)
+
+	if (encap) {
+		/* encap filters must specify encap type */
+		match_flags |= EFX_FILTER_MATCH_ENCAP_TYPE;
+		/* and imply ethertype and ip proto */
+		mcdi_flags &=
+			~(1 << MC_CMD_FILTER_OP_EXT_IN_MATCH_IP_PROTO_LBN);
+		mcdi_flags &=
+			~(1 << MC_CMD_FILTER_OP_EXT_IN_MATCH_ETHER_TYPE_LBN);
+		/* VLAN tags refer to the outer packet */
+		MAP_FLAG(INNER_VID, INNER_VLAN);
+		MAP_FLAG(OUTER_VID, OUTER_VLAN);
+		/* everything else refers to the inner packet */
+		MAP_FLAG(LOC_MAC_IG, IFRM_UNKNOWN_UCAST_DST);
+		MAP_FLAG(LOC_MAC_IG, IFRM_UNKNOWN_MCAST_DST);
+		MAP_FLAG(REM_HOST, IFRM_SRC_IP);
+		MAP_FLAG(LOC_HOST, IFRM_DST_IP);
+		MAP_FLAG(REM_MAC, IFRM_SRC_MAC);
+		MAP_FLAG(REM_PORT, IFRM_SRC_PORT);
+		MAP_FLAG(LOC_MAC, IFRM_DST_MAC);
+		MAP_FLAG(LOC_PORT, IFRM_DST_PORT);
+		MAP_FLAG(ETHER_TYPE, IFRM_ETHER_TYPE);
+		MAP_FLAG(IP_PROTO, IFRM_IP_PROTO);
+	} else {
+		MAP_FLAG(LOC_MAC_IG, UNKNOWN_UCAST_DST);
+		MAP_FLAG(LOC_MAC_IG, UNKNOWN_MCAST_DST);
+		MAP_FLAG(REM_HOST, SRC_IP);
+		MAP_FLAG(LOC_HOST, DST_IP);
+		MAP_FLAG(REM_MAC, SRC_MAC);
+		MAP_FLAG(REM_PORT, SRC_PORT);
+		MAP_FLAG(LOC_MAC, DST_MAC);
+		MAP_FLAG(LOC_PORT, DST_PORT);
+		MAP_FLAG(ETHER_TYPE, ETHER_TYPE);
+		MAP_FLAG(INNER_VID, INNER_VLAN);
+		MAP_FLAG(OUTER_VID, OUTER_VLAN);
+		MAP_FLAG(IP_PROTO, IP_PROTO);
 	}
-	MAP_FLAG(LOC_MAC_IG, UNKNOWN_UCAST_DST);
-	MAP_FLAG(LOC_MAC_IG, UNKNOWN_MCAST_DST);
-	MAP_FLAG(REM_HOST, SRC_IP);
-	MAP_FLAG(LOC_HOST, DST_IP);
-	MAP_FLAG(REM_MAC, SRC_MAC);
-	MAP_FLAG(REM_PORT, SRC_PORT);
-	MAP_FLAG(LOC_MAC, DST_MAC);
-	MAP_FLAG(LOC_PORT, DST_PORT);
-	MAP_FLAG(ETHER_TYPE, ETHER_TYPE);
-	MAP_FLAG(INNER_VID, INNER_VLAN);
-	MAP_FLAG(OUTER_VID, OUTER_VLAN);
-	MAP_FLAG(IP_PROTO, IP_PROTO);
 #undef MAP_FLAG
 
 	/* Did we map them all? */
@@ -4436,6 +4559,7 @@ static void efx_ef10_filter_cleanup_vlans(struct efx_nic *efx)
 }
 
 static bool efx_ef10_filter_match_supported(struct efx_ef10_filter_table *table,
+					    bool encap,
 					    enum efx_filter_match_flags match_flags)
 {
 	unsigned int match_pri;
@@ -4444,7 +4568,7 @@ static bool efx_ef10_filter_match_supported(struct efx_ef10_filter_table *table,
 	for (match_pri = 0;
 	     match_pri < table->rx_match_count;
 	     match_pri++) {
-		mf = efx_ef10_filter_match_flags_from_mcdi(
+		mf = efx_ef10_filter_match_flags_from_mcdi(encap,
 				table->rx_match_mcdi_flags[match_pri]);
 		if (mf == match_flags)
 			return true;
@@ -4453,39 +4577,30 @@ static bool efx_ef10_filter_match_supported(struct efx_ef10_filter_table *table,
 	return false;
 }
 
-static int efx_ef10_filter_table_probe(struct efx_nic *efx)
+static int
+efx_ef10_filter_table_probe_matches(struct efx_nic *efx,
+				    struct efx_ef10_filter_table *table,
+				    bool encap)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_GET_PARSER_DISP_INFO_IN_LEN);
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_PARSER_DISP_INFO_OUT_LENMAX);
-	struct efx_ef10_nic_data *nic_data = efx->nic_data;
-	struct net_device *net_dev = efx->net_dev;
 	unsigned int pd_match_pri, pd_match_count;
-	struct efx_ef10_filter_table *table;
-	struct efx_ef10_vlan *vlan;
 	size_t outlen;
 	int rc;
 
-	if (!efx_rwsem_assert_write_locked(&efx->filter_sem))
-		return -EINVAL;
-
-	if (efx->filter_state) /* already probed */
-		return 0;
-
-	table = kzalloc(sizeof(*table), GFP_KERNEL);
-	if (!table)
-		return -ENOMEM;
-
 	/* Find out which RX filter types are supported, and their priorities */
 	MCDI_SET_DWORD(inbuf, GET_PARSER_DISP_INFO_IN_OP,
+		       encap ?
+		       MC_CMD_GET_PARSER_DISP_INFO_IN_OP_GET_SUPPORTED_ENCAP_RX_MATCHES :
 		       MC_CMD_GET_PARSER_DISP_INFO_IN_OP_GET_SUPPORTED_RX_MATCHES);
 	rc = efx_mcdi_rpc(efx, MC_CMD_GET_PARSER_DISP_INFO,
 			  inbuf, sizeof(inbuf), outbuf, sizeof(outbuf),
 			  &outlen);
 	if (rc)
-		goto fail;
+		return rc;
+
 	pd_match_count = MCDI_VAR_ARRAY_LEN(
 		outlen, GET_PARSER_DISP_INFO_OUT_SUPPORTED_MATCHES);
-	table->rx_match_count = 0;
 
 	for (pd_match_pri = 0; pd_match_pri < pd_match_count; pd_match_pri++) {
 		u32 mcdi_flags =
@@ -4493,7 +4608,7 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 				outbuf,
 				GET_PARSER_DISP_INFO_OUT_SUPPORTED_MATCHES,
 				pd_match_pri);
-		rc = efx_ef10_filter_match_flags_from_mcdi(mcdi_flags);
+		rc = efx_ef10_filter_match_flags_from_mcdi(encap, mcdi_flags);
 		if (rc < 0) {
 			netif_dbg(efx, probe, efx->net_dev,
 				  "%s: fw flags %#x pri %u not supported in driver\n",
@@ -4508,10 +4623,40 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 		}
 	}
 
+	return 0;
+}
+
+static int efx_ef10_filter_table_probe(struct efx_nic *efx)
+{
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	struct net_device *net_dev = efx->net_dev;
+	struct efx_ef10_filter_table *table;
+	struct efx_ef10_vlan *vlan;
+	int rc;
+
+	if (!efx_rwsem_assert_write_locked(&efx->filter_sem))
+		return -EINVAL;
+
+	if (efx->filter_state) /* already probed */
+		return 0;
+
+	table = kzalloc(sizeof(*table), GFP_KERNEL);
+	if (!table)
+		return -ENOMEM;
+
+	table->rx_match_count = 0;
+	rc = efx_ef10_filter_table_probe_matches(efx, table, false);
+	if (rc)
+		goto fail;
+	if (nic_data->datapath_caps &
+		   (1 << MC_CMD_GET_CAPABILITIES_OUT_VXLAN_NVGRE_LBN))
+		rc = efx_ef10_filter_table_probe_matches(efx, table, true);
+	if (rc)
+		goto fail;
 	if ((efx_supported_features(efx) & NETIF_F_HW_VLAN_CTAG_FILTER) &&
-	    !(efx_ef10_filter_match_supported(table,
+	    !(efx_ef10_filter_match_supported(table, false,
 		(EFX_FILTER_MATCH_OUTER_VID | EFX_FILTER_MATCH_LOC_MAC)) &&
-	      efx_ef10_filter_match_supported(table,
+	      efx_ef10_filter_match_supported(table, false,
 		(EFX_FILTER_MATCH_OUTER_VID | EFX_FILTER_MATCH_LOC_MAC_IG)))) {
 		netif_info(efx, probe, net_dev,
 			   "VLAN filters are not supported in this firmware variant\n");
@@ -4563,7 +4708,7 @@ static void efx_ef10_filter_table_restore(struct efx_nic *efx)
 	unsigned int filter_idx;
 	u32 mcdi_flags;
 	int match_pri;
-	int rc;
+	int rc, i;
 
 	WARN_ON(!rwsem_is_locked(&efx->filter_sem));
 
@@ -4606,14 +4751,12 @@ static void efx_ef10_filter_table_restore(struct efx_nic *efx)
 
 		if (rc) {
 not_restored:
-			list_for_each_entry(vlan, &table->vlan_list, list) {
-				if (vlan->ucdef == filter_idx)
-					vlan->ucdef = EFX_EF10_FILTER_ID_INVALID;
-				if (vlan->mcdef == filter_idx)
-					vlan->mcdef = EFX_EF10_FILTER_ID_INVALID;
-				if (vlan->bcast == filter_idx)
-					vlan->bcast = EFX_EF10_FILTER_ID_INVALID;
-			}
+			list_for_each_entry(vlan, &table->vlan_list, list)
+				for (i = 0; i < EFX_EF10_NUM_DEFAULT_FILTERS; ++i)
+					if (vlan->default_filters[i] == filter_idx)
+						vlan->default_filters[i] =
+							EFX_EF10_FILTER_ID_INVALID;
+
 			kfree(spec);
 			efx_ef10_filter_set_entry(table, filter_idx, NULL, 0);
 		} else {
@@ -4712,9 +4855,8 @@ static void _efx_ef10_filter_vlan_mark_old(struct efx_nic *efx,
 		efx_ef10_filter_mark_one_old(efx, &vlan->uc[i]);
 	for (i = 0; i < table->dev_mc_count; i++)
 		efx_ef10_filter_mark_one_old(efx, &vlan->mc[i]);
-	efx_ef10_filter_mark_one_old(efx, &vlan->ucdef);
-	efx_ef10_filter_mark_one_old(efx, &vlan->bcast);
-	efx_ef10_filter_mark_one_old(efx, &vlan->mcdef);
+	for (i = 0; i < EFX_EF10_NUM_DEFAULT_FILTERS; i++)
+		efx_ef10_filter_mark_one_old(efx, &vlan->default_filters[i]);
 }
 
 /* Mark old filters that may need to be removed.
@@ -4832,6 +4974,8 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 
 	if (multicast && rollback) {
 		/* Also need an Ethernet broadcast filter */
+		EFX_WARN_ON_PARANOID(vlan->default_filters[EFX_EF10_BCAST] !=
+				     EFX_EF10_FILTER_ID_INVALID);
 		efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO, filter_flags, 0);
 		eth_broadcast_addr(baddr);
 		efx_filter_set_eth_local(&spec, vlan->vid, baddr);
@@ -4848,9 +4992,8 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 			}
 			return rc;
 		} else {
-			EFX_WARN_ON_PARANOID(vlan->bcast !=
-					     EFX_EF10_FILTER_ID_INVALID);
-			vlan->bcast = efx_ef10_filter_get_unsafe_id(efx, rc);
+			vlan->default_filters[EFX_EF10_BCAST] =
+				efx_ef10_filter_get_unsafe_id(efx, rc);
 		}
 	}
 
@@ -4859,6 +5002,7 @@ static int efx_ef10_filter_insert_addr_list(struct efx_nic *efx,
 
 static int efx_ef10_filter_insert_def(struct efx_nic *efx,
 				      struct efx_ef10_filter_vlan *vlan,
+				      enum efx_encap_type encap_type,
 				      bool multicast, bool rollback)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
@@ -4866,6 +5010,7 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx,
 	struct efx_filter_spec spec;
 	u8 baddr[ETH_ALEN];
 	int rc;
+	u16 *id;
 
 	filter_flags = efx_rss_enabled(efx) ? EFX_FILTER_FLAG_RX_RSS : 0;
 
@@ -4876,19 +5021,75 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx,
 	else
 		efx_filter_set_uc_def(&spec);
 
+	if (encap_type) {
+		if (nic_data->datapath_caps &
+		    (1 << MC_CMD_GET_CAPABILITIES_OUT_VXLAN_NVGRE_LBN))
+			efx_filter_set_encap_type(&spec, encap_type);
+		else
+			/* don't insert encap filters on non-supporting
+			 * platforms. ID will be left as INVALID.
+			 */
+			return 0;
+	}
+
 	if (vlan->vid != EFX_FILTER_VID_UNSPEC)
 		efx_filter_set_eth_local(&spec, vlan->vid, NULL);
 
 	rc = efx_ef10_filter_insert(efx, &spec, true);
 	if (rc < 0) {
+		const char *um = multicast ? "Multicast" : "Unicast";
+		const char *encap_name = "";
+		const char *encap_ipv = "";
+
+		if ((encap_type & EFX_ENCAP_TYPES_MASK) ==
+		    EFX_ENCAP_TYPE_VXLAN)
+			encap_name = "VXLAN ";
+		else if ((encap_type & EFX_ENCAP_TYPES_MASK) ==
+			 EFX_ENCAP_TYPE_NVGRE)
+			encap_name = "NVGRE ";
+		else if ((encap_type & EFX_ENCAP_TYPES_MASK) ==
+			 EFX_ENCAP_TYPE_GENEVE)
+			encap_name = "GENEVE ";
+		if (encap_type & EFX_ENCAP_FLAG_IPV6)
+			encap_ipv = "IPv6 ";
+		else if (encap_type)
+			encap_ipv = "IPv4 ";
+
+		/* unprivileged functions can't insert mismatch filters
+		 * for encapsulated or unicast traffic, so downgrade
+		 * those warnings to debug.
+		 */
 		netif_cond_dbg(efx, drv, efx->net_dev,
-			       rc == -EPERM, warn,
-			       "%scast mismatch filter insert failed rc=%d\n",
-			       multicast ? "Multi" : "Uni", rc);
+			       rc == -EPERM && (encap_type || !multicast), warn,
+			       "%s%s%s mismatch filter insert failed rc=%d\n",
+			       encap_name, encap_ipv, um, rc);
 	} else if (multicast) {
-		EFX_WARN_ON_PARANOID(vlan->mcdef != EFX_EF10_FILTER_ID_INVALID);
-		vlan->mcdef = efx_ef10_filter_get_unsafe_id(efx, rc);
-		if (!nic_data->workaround_26807) {
+		/* mapping from encap types to default filter IDs (multicast) */
+		static enum efx_ef10_default_filters map[] = {
+			[EFX_ENCAP_TYPE_NONE] = EFX_EF10_MCDEF,
+			[EFX_ENCAP_TYPE_VXLAN] = EFX_EF10_VXLAN4_MCDEF,
+			[EFX_ENCAP_TYPE_NVGRE] = EFX_EF10_NVGRE4_MCDEF,
+			[EFX_ENCAP_TYPE_GENEVE] = EFX_EF10_GENEVE4_MCDEF,
+			[EFX_ENCAP_TYPE_VXLAN | EFX_ENCAP_FLAG_IPV6] =
+				EFX_EF10_VXLAN6_MCDEF,
+			[EFX_ENCAP_TYPE_NVGRE | EFX_ENCAP_FLAG_IPV6] =
+				EFX_EF10_NVGRE6_MCDEF,
+			[EFX_ENCAP_TYPE_GENEVE | EFX_ENCAP_FLAG_IPV6] =
+				EFX_EF10_GENEVE6_MCDEF,
+		};
+
+		/* quick bounds check (BCAST result impossible) */
+		BUILD_BUG_ON(EFX_EF10_BCAST != 0);
+		if (encap_type > ARRAY_SIZE(map) || map[encap_type] == 0) {
+			WARN_ON(1);
+			return -EINVAL;
+		}
+		/* then follow map */
+		id = &vlan->default_filters[map[encap_type]];
+
+		EFX_WARN_ON_PARANOID(*id != EFX_EF10_FILTER_ID_INVALID);
+		*id = efx_ef10_filter_get_unsafe_id(efx, rc);
+		if (!nic_data->workaround_26807 && !encap_type) {
 			/* Also need an Ethernet broadcast filter */
 			efx_filter_init_rx(&spec, EFX_FILTER_PRI_AUTO,
 					   filter_flags, 0);
@@ -4903,20 +5104,44 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx,
 					/* Roll back the mc_def filter */
 					efx_ef10_filter_remove_unsafe(
 							efx, EFX_FILTER_PRI_AUTO,
-							vlan->mcdef);
-					vlan->mcdef = EFX_EF10_FILTER_ID_INVALID;
+							*id);
+					*id = EFX_EF10_FILTER_ID_INVALID;
 					return rc;
 				}
 			} else {
-				EFX_WARN_ON_PARANOID(vlan->bcast !=
-						     EFX_EF10_FILTER_ID_INVALID);
-				vlan->bcast = efx_ef10_filter_get_unsafe_id(efx, rc);
+				EFX_WARN_ON_PARANOID(
+					vlan->default_filters[EFX_EF10_BCAST] !=
+					EFX_EF10_FILTER_ID_INVALID);
+				vlan->default_filters[EFX_EF10_BCAST] =
+					efx_ef10_filter_get_unsafe_id(efx, rc);
 			}
 		}
 		rc = 0;
 	} else {
-		EFX_WARN_ON_PARANOID(vlan->ucdef != EFX_EF10_FILTER_ID_INVALID);
-		vlan->ucdef = rc;
+		/* mapping from encap types to default filter IDs (unicast) */
+		static enum efx_ef10_default_filters map[] = {
+			[EFX_ENCAP_TYPE_NONE] = EFX_EF10_UCDEF,
+			[EFX_ENCAP_TYPE_VXLAN] = EFX_EF10_VXLAN4_UCDEF,
+			[EFX_ENCAP_TYPE_NVGRE] = EFX_EF10_NVGRE4_UCDEF,
+			[EFX_ENCAP_TYPE_GENEVE] = EFX_EF10_GENEVE4_UCDEF,
+			[EFX_ENCAP_TYPE_VXLAN | EFX_ENCAP_FLAG_IPV6] =
+				EFX_EF10_VXLAN6_UCDEF,
+			[EFX_ENCAP_TYPE_NVGRE | EFX_ENCAP_FLAG_IPV6] =
+				EFX_EF10_NVGRE6_UCDEF,
+			[EFX_ENCAP_TYPE_GENEVE | EFX_ENCAP_FLAG_IPV6] =
+				EFX_EF10_GENEVE6_UCDEF,
+		};
+
+		/* quick bounds check (BCAST result impossible) */
+		BUILD_BUG_ON(EFX_EF10_BCAST != 0);
+		if (encap_type > ARRAY_SIZE(map) || map[encap_type] == 0) {
+			WARN_ON(1);
+			return -EINVAL;
+		}
+		/* then follow map */
+		id = &vlan->default_filters[map[encap_type]];
+		EFX_WARN_ON_PARANOID(*id != EFX_EF10_FILTER_ID_INVALID);
+		*id = rc;
 		rc = 0;
 	}
 	return rc;
@@ -5039,7 +5264,8 @@ static void efx_ef10_filter_vlan_sync_rx_mode(struct efx_nic *efx,
 
 	/* Insert/renew unicast filters */
 	if (table->uc_promisc) {
-		efx_ef10_filter_insert_def(efx, vlan, false, false);
+		efx_ef10_filter_insert_def(efx, vlan, EFX_ENCAP_TYPE_NONE,
+					   false, false);
 		efx_ef10_filter_insert_addr_list(efx, vlan, false, false);
 	} else {
 		/* If any of the filters failed to insert, fall back to
@@ -5047,8 +5273,25 @@ static void efx_ef10_filter_vlan_sync_rx_mode(struct efx_nic *efx,
 		 * our individual unicast filters.
 		 */
 		if (efx_ef10_filter_insert_addr_list(efx, vlan, false, false))
-			efx_ef10_filter_insert_def(efx, vlan, false, false);
+			efx_ef10_filter_insert_def(efx, vlan,
+						   EFX_ENCAP_TYPE_NONE,
+						   false, false);
 	}
+	efx_ef10_filter_insert_def(efx, vlan, EFX_ENCAP_TYPE_VXLAN,
+				   false, false);
+	efx_ef10_filter_insert_def(efx, vlan, EFX_ENCAP_TYPE_VXLAN |
+					      EFX_ENCAP_FLAG_IPV6,
+				   false, false);
+	efx_ef10_filter_insert_def(efx, vlan, EFX_ENCAP_TYPE_NVGRE,
+				   false, false);
+	efx_ef10_filter_insert_def(efx, vlan, EFX_ENCAP_TYPE_NVGRE |
+					      EFX_ENCAP_FLAG_IPV6,
+				   false, false);
+	efx_ef10_filter_insert_def(efx, vlan, EFX_ENCAP_TYPE_GENEVE,
+				   false, false);
+	efx_ef10_filter_insert_def(efx, vlan, EFX_ENCAP_TYPE_GENEVE |
+					      EFX_ENCAP_FLAG_IPV6,
+				   false, false);
 
 	/* Insert/renew multicast filters */
 	/* If changing promiscuous state with cascaded multicast filters, remove
@@ -5062,7 +5305,9 @@ static void efx_ef10_filter_vlan_sync_rx_mode(struct efx_nic *efx,
 			/* If we failed to insert promiscuous filters, rollback
 			 * and fall back to individual multicast filters
 			 */
-			if (efx_ef10_filter_insert_def(efx, vlan, true, true)) {
+			if (efx_ef10_filter_insert_def(efx, vlan,
+						       EFX_ENCAP_TYPE_NONE,
+						       true, true)) {
 				/* Changing promisc state, so remove old filters */
 				efx_ef10_filter_remove_old(efx);
 				efx_ef10_filter_insert_addr_list(efx, vlan,
@@ -5072,7 +5317,9 @@ static void efx_ef10_filter_vlan_sync_rx_mode(struct efx_nic *efx,
 			/* If we failed to insert promiscuous filters, don't
 			 * rollback.  Regardless, also insert the mc_list
 			 */
-			efx_ef10_filter_insert_def(efx, vlan, true, false);
+			efx_ef10_filter_insert_def(efx, vlan,
+						   EFX_ENCAP_TYPE_NONE,
+						   true, false);
 			efx_ef10_filter_insert_addr_list(efx, vlan, true, false);
 		}
 	} else {
@@ -5085,11 +5332,28 @@ static void efx_ef10_filter_vlan_sync_rx_mode(struct efx_nic *efx,
 			/* Changing promisc state, so remove old filters */
 			if (nic_data->workaround_26807)
 				efx_ef10_filter_remove_old(efx);
-			if (efx_ef10_filter_insert_def(efx, vlan, true, true))
+			if (efx_ef10_filter_insert_def(efx, vlan,
+						       EFX_ENCAP_TYPE_NONE,
+						       true, true))
 				efx_ef10_filter_insert_addr_list(efx, vlan,
 								 true, false);
 		}
 	}
+	efx_ef10_filter_insert_def(efx, vlan, EFX_ENCAP_TYPE_VXLAN,
+				   true, false);
+	efx_ef10_filter_insert_def(efx, vlan, EFX_ENCAP_TYPE_VXLAN |
+					      EFX_ENCAP_FLAG_IPV6,
+				   true, false);
+	efx_ef10_filter_insert_def(efx, vlan, EFX_ENCAP_TYPE_NVGRE,
+				   true, false);
+	efx_ef10_filter_insert_def(efx, vlan, EFX_ENCAP_TYPE_NVGRE |
+					      EFX_ENCAP_FLAG_IPV6,
+				   true, false);
+	efx_ef10_filter_insert_def(efx, vlan, EFX_ENCAP_TYPE_GENEVE,
+				   true, false);
+	efx_ef10_filter_insert_def(efx, vlan, EFX_ENCAP_TYPE_GENEVE |
+					      EFX_ENCAP_FLAG_IPV6,
+				   true, false);
 }
 
 /* Caller must hold efx->filter_sem for read if race against
@@ -5176,9 +5440,8 @@ static int efx_ef10_filter_add_vlan(struct efx_nic *efx, u16 vid)
 		vlan->uc[i] = EFX_EF10_FILTER_ID_INVALID;
 	for (i = 0; i < ARRAY_SIZE(vlan->mc); i++)
 		vlan->mc[i] = EFX_EF10_FILTER_ID_INVALID;
-	vlan->ucdef = EFX_EF10_FILTER_ID_INVALID;
-	vlan->bcast = EFX_EF10_FILTER_ID_INVALID;
-	vlan->mcdef = EFX_EF10_FILTER_ID_INVALID;
+	for (i = 0; i < EFX_EF10_NUM_DEFAULT_FILTERS; i++)
+		vlan->default_filters[i] = EFX_EF10_FILTER_ID_INVALID;
 
 	list_add_tail(&vlan->list, &table->vlan_list);
 
@@ -5205,9 +5468,10 @@ static void efx_ef10_filter_del_vlan_internal(struct efx_nic *efx,
 	for (i = 0; i < ARRAY_SIZE(vlan->mc); i++)
 		efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO,
 					      vlan->mc[i]);
-	efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO, vlan->ucdef);
-	efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO, vlan->bcast);
-	efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO, vlan->mcdef);
+	for (i = 0; i < EFX_EF10_NUM_DEFAULT_FILTERS; i++)
+		if (vlan->default_filters[i] != EFX_EF10_FILTER_ID_INVALID)
+			efx_ef10_filter_remove_unsafe(efx, EFX_FILTER_PRI_AUTO,
+						      vlan->default_filters[i]);
 
 	kfree(vlan);
 }
diff --git a/drivers/net/ethernet/sfc/filter.h b/drivers/net/ethernet/sfc/filter.h
index d0ed7f7..8189a1c 100644
--- a/drivers/net/ethernet/sfc/filter.h
+++ b/drivers/net/ethernet/sfc/filter.h
@@ -27,6 +27,7 @@
  * @EFX_FILTER_MATCH_OUTER_VID: Match by outer VLAN ID
  * @EFX_FILTER_MATCH_IP_PROTO: Match by IP transport protocol
  * @EFX_FILTER_MATCH_LOC_MAC_IG: Match by local MAC address I/G bit.
+ * @EFX_FILTER_MATCH_ENCAP_TYPE: Match by encapsulation type.
  *	Used for RX default unicast and multicast/broadcast filters.
  *
  * Only some combinations are supported, depending on NIC type:
@@ -54,6 +55,7 @@ enum efx_filter_match_flags {
 	EFX_FILTER_MATCH_OUTER_VID =	0x0100,
 	EFX_FILTER_MATCH_IP_PROTO =	0x0200,
 	EFX_FILTER_MATCH_LOC_MAC_IG =	0x0400,
+	EFX_FILTER_MATCH_ENCAP_TYPE =	0x0800,
 };
 
 /**
@@ -98,6 +100,26 @@ enum efx_filter_flags {
 	EFX_FILTER_FLAG_TX = 0x10,
 };
 
+/** enum efx_encap_type - types of encapsulation
+ * @EFX_ENCAP_TYPE_NONE: no encapsulation
+ * @EFX_ENCAP_TYPE_VXLAN: VXLAN encapsulation
+ * @EFX_ENCAP_TYPE_NVGRE: NVGRE encapsulation
+ * @EFX_ENCAP_TYPE_GENEVE: GENEVE encapsulation
+ * @EFX_ENCAP_FLAG_IPV6: indicates IPv6 outer frame
+ *
+ * Contains both enumerated types and flags.
+ * To get just the type, OR with @EFX_ENCAP_TYPES_MASK.
+ */
+enum efx_encap_type {
+	EFX_ENCAP_TYPE_NONE = 0,
+	EFX_ENCAP_TYPE_VXLAN = 1,
+	EFX_ENCAP_TYPE_NVGRE = 2,
+	EFX_ENCAP_TYPE_GENEVE = 3,
+
+	EFX_ENCAP_TYPES_MASK = 7,
+	EFX_ENCAP_FLAG_IPV6 = 8,
+};
+
 /**
  * struct efx_filter_spec - specification for a hardware filter
  * @match_flags: Match type flags, from &enum efx_filter_match_flags
@@ -118,6 +140,8 @@ enum efx_filter_flags {
  * @rem_host: Remote IP host to match, if %EFX_FILTER_MATCH_REM_HOST is set
  * @loc_port: Local TCP/UDP port to match, if %EFX_FILTER_MATCH_LOC_PORT is set
  * @rem_port: Remote TCP/UDP port to match, if %EFX_FILTER_MATCH_REM_PORT is set
+ * @encap_type: Encapsulation type to match (from &enum efx_encap_type), if
+ *	%EFX_FILTER_MATCH_ENCAP_TYPE is set
  *
  * The efx_filter_init_rx() or efx_filter_init_tx() function *must* be
  * used to initialise the structure.  The efx_filter_set_*() functions
@@ -144,7 +168,8 @@ struct efx_filter_spec {
 	__be32	rem_host[4];
 	__be16	loc_port;
 	__be16	rem_port;
-	/* total 64 bytes */
+	u32     encap_type:4;
+	/* total 65 bytes */
 };
 
 enum {
@@ -269,4 +294,18 @@ static inline int efx_filter_set_mc_def(struct efx_filter_spec *spec)
 	return 0;
 }
 
+static inline void efx_filter_set_encap_type(struct efx_filter_spec *spec,
+					     enum efx_encap_type encap_type)
+{
+	spec->match_flags |= EFX_FILTER_MATCH_ENCAP_TYPE;
+	spec->encap_type = encap_type;
+}
+
+static inline enum efx_encap_type efx_filter_get_encap_type(
+		const struct efx_filter_spec *spec)
+{
+	if (spec->match_flags & EFX_FILTER_MATCH_ENCAP_TYPE)
+		return spec->encap_type;
+	return EFX_ENCAP_TYPE_NONE;
+}
 #endif /* EFX_FILTER_H */
