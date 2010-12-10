From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 10/10] sfc: Generalise filter spec
 initialisation
Date: Fri, 10 Dec 2010 17:39:29 +0000
Message-ID: <1292002769.11673.24.camel@bwh-desktop>
References: <1292002527.11673.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27061 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754428Ab0LJRjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 12:39:33 -0500
In-Reply-To: <1292002527.11673.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move search_depth arrays into per-table state.

Define initialisation function efx_filter_init_rx() which sets
everything apart from the match fields.

Define efx_filter_set_{ipv4_local,ipv4_full,eth_local}() to set the
match fields.  This allows some simplification of callers and later
support for additional protocols and more flexible matching using
multiple calls to these functions.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |   82 ++++++++----------
 drivers/net/sfc/filter.c  |  214 +++++++++++++++++++++++++++++++++++++--------
 drivers/net/sfc/filter.h  |  143 ++++++++----------------------
 3 files changed, 248 insertions(+), 191 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 0f46c1a..5e50e57 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -11,6 +11,7 @@
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
 #include <linux/rtnetlink.h>
+#include <linux/in.h>
 #include "net_driver.h"
 #include "workarounds.h"
 #include "selftest.h"
@@ -920,6 +921,7 @@ static int efx_ethtool_set_rx_ntuple(struct net_device *net_dev,
 	struct ethhdr *mac_entry = &ntuple->fs.h_u.ether_spec;
 	struct ethhdr *mac_mask = &ntuple->fs.m_u.ether_spec;
 	struct efx_filter_spec filter;
+	int rc;
 
 	/* Range-check action */
 	if (ntuple->fs.action < ETHTOOL_RXNTUPLE_ACTION_CLEAR ||
@@ -929,9 +931,16 @@ static int efx_ethtool_set_rx_ntuple(struct net_device *net_dev,
 	if (~ntuple->fs.data_mask)
 		return -EINVAL;
 
+	efx_filter_init_rx(&filter, EFX_FILTER_PRI_MANUAL, 0,
+			   (ntuple->fs.action == ETHTOOL_RXNTUPLE_ACTION_DROP) ?
+			   0xfff : ntuple->fs.action);
+
 	switch (ntuple->fs.flow_type) {
 	case TCP_V4_FLOW:
-	case UDP_V4_FLOW:
+	case UDP_V4_FLOW: {
+		u8 proto = (ntuple->fs.flow_type == TCP_V4_FLOW ?
+			    IPPROTO_TCP : IPPROTO_UDP);
+
 		/* Must match all of destination, */
 		if (ip_mask->ip4dst | ip_mask->pdst)
 			return -EINVAL;
@@ -943,7 +952,22 @@ static int efx_ethtool_set_rx_ntuple(struct net_device *net_dev,
 		/* and nothing else */
 		if ((u8)~ip_mask->tos | (u16)~ntuple->fs.vlan_tag_mask)
 			return -EINVAL;
+
+		if (!ip_mask->ip4src)
+			rc = efx_filter_set_ipv4_full(&filter, proto,
+						      ip_entry->ip4dst,
+						      ip_entry->pdst,
+						      ip_entry->ip4src,
+						      ip_entry->psrc);
+		else
+			rc = efx_filter_set_ipv4_local(&filter, proto,
+						       ip_entry->ip4dst,
+						       ip_entry->pdst);
+		if (rc)
+			return rc;
 		break;
+	}
+
 	case ETHER_FLOW:
 		/* Must match all of destination, */
 		if (!is_zero_ether_addr(mac_mask->h_dest))
@@ -956,58 +980,24 @@ static int efx_ethtool_set_rx_ntuple(struct net_device *net_dev,
 		if (!is_broadcast_ether_addr(mac_mask->h_source) ||
 		    mac_mask->h_proto != htons(0xffff))
 			return -EINVAL;
+
+		rc = efx_filter_set_eth_local(
+			&filter,
+			(ntuple->fs.vlan_tag_mask == 0xf000) ?
+			ntuple->fs.vlan_tag : EFX_FILTER_VID_UNSPEC,
+			mac_entry->h_dest);
+		if (rc)
+			return rc;
 		break;
+
 	default:
 		return -EINVAL;
 	}
 
-	filter.priority = EFX_FILTER_PRI_MANUAL;
-	filter.flags = 0;
-
-	switch (ntuple->fs.flow_type) {
-	case TCP_V4_FLOW:
-		if (!ip_mask->ip4src)
-			efx_filter_set_rx_tcp_full(&filter,
-						   htonl(ip_entry->ip4src),
-						   htons(ip_entry->psrc),
-						   htonl(ip_entry->ip4dst),
-						   htons(ip_entry->pdst));
-		else
-			efx_filter_set_rx_tcp_wild(&filter,
-						   htonl(ip_entry->ip4dst),
-						   htons(ip_entry->pdst));
-		break;
-	case UDP_V4_FLOW:
-		if (!ip_mask->ip4src)
-			efx_filter_set_rx_udp_full(&filter,
-						   htonl(ip_entry->ip4src),
-						   htons(ip_entry->psrc),
-						   htonl(ip_entry->ip4dst),
-						   htons(ip_entry->pdst));
-		else
-			efx_filter_set_rx_udp_wild(&filter,
-						   htonl(ip_entry->ip4dst),
-						   htons(ip_entry->pdst));
-		break;
-	case ETHER_FLOW:
-		if (ntuple->fs.vlan_tag_mask == 0xf000)
-			efx_filter_set_rx_mac_full(&filter,
-						   ntuple->fs.vlan_tag & 0xfff,
-						   mac_entry->h_dest);
-		else
-			efx_filter_set_rx_mac_wild(&filter, mac_entry->h_dest);
-		break;
-	}
-
-	if (ntuple->fs.action == ETHTOOL_RXNTUPLE_ACTION_CLEAR) {
+	if (ntuple->fs.action == ETHTOOL_RXNTUPLE_ACTION_CLEAR)
 		return efx_filter_remove_filter(efx, &filter);
-	} else {
-		if (ntuple->fs.action == ETHTOOL_RXNTUPLE_ACTION_DROP)
-			filter.dmaq_id = 0xfff;
-		else
-			filter.dmaq_id = ntuple->fs.action;
+	else
 		return efx_filter_insert_filter(efx, &filter, true);
-	}
 }
 
 static int efx_ethtool_get_rxfh_indir(struct net_device *net_dev,
diff --git a/drivers/net/sfc/filter.c b/drivers/net/sfc/filter.c
index e96e6e8..d4722c4 100644
--- a/drivers/net/sfc/filter.c
+++ b/drivers/net/sfc/filter.c
@@ -7,6 +7,7 @@
  * by the Free Software Foundation, incorporated herein by reference.
  */
 
+#include <linux/in.h>
 #include "efx.h"
 #include "filter.h"
 #include "io.h"
@@ -33,18 +34,19 @@ enum efx_filter_table_id {
 };
 
 struct efx_filter_table {
+	enum efx_filter_table_id id;
 	u32		offset;		/* address of table relative to BAR */
 	unsigned	size;		/* number of entries */
 	unsigned	step;		/* step between entries */
 	unsigned	used;		/* number currently used */
 	unsigned long	*used_bitmap;
 	struct efx_filter_spec *spec;
+	unsigned	search_depth[EFX_FILTER_TYPE_COUNT];
 };
 
 struct efx_filter_state {
 	spinlock_t	lock;
 	struct efx_filter_table table[EFX_FILTER_TABLE_COUNT];
-	unsigned	search_depth[EFX_FILTER_TYPE_COUNT];
 };
 
 /* The filter hash function is LFSR polynomial x^16 + x^3 + 1 of a 32-bit
@@ -71,68 +73,203 @@ static u16 efx_filter_increment(u32 key)
 }
 
 static enum efx_filter_table_id
-efx_filter_type_table_id(enum efx_filter_type type)
+efx_filter_spec_table_id(const struct efx_filter_spec *spec)
+{
+	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_IP != (EFX_FILTER_TCP_FULL >> 2));
+	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_IP != (EFX_FILTER_TCP_WILD >> 2));
+	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_IP != (EFX_FILTER_UDP_FULL >> 2));
+	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_IP != (EFX_FILTER_UDP_WILD >> 2));
+	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_MAC != (EFX_FILTER_MAC_FULL >> 2));
+	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_MAC != (EFX_FILTER_MAC_WILD >> 2));
+	EFX_BUG_ON_PARANOID(spec->type == EFX_FILTER_UNSPEC);
+	return spec->type >> 2;
+}
+
+static struct efx_filter_table *
+efx_filter_spec_table(struct efx_filter_state *state,
+		      const struct efx_filter_spec *spec)
 {
-	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_IP != (EFX_FILTER_RX_TCP_FULL >> 2));
-	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_IP != (EFX_FILTER_RX_TCP_WILD >> 2));
-	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_IP != (EFX_FILTER_RX_UDP_FULL >> 2));
-	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_IP != (EFX_FILTER_RX_UDP_WILD >> 2));
-	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_MAC != (EFX_FILTER_RX_MAC_FULL >> 2));
-	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_MAC != (EFX_FILTER_RX_MAC_WILD >> 2));
-	return type >> 2;
+	if (spec->type == EFX_FILTER_UNSPEC)
+		return NULL;
+	else
+		return &state->table[efx_filter_spec_table_id(spec)];
 }
 
-static void
-efx_filter_table_reset_search_depth(struct efx_filter_state *state,
-				    enum efx_filter_table_id table_id)
+static void efx_filter_table_reset_search_depth(struct efx_filter_table *table)
 {
-	memset(state->search_depth + (table_id << 2), 0,
-	       sizeof(state->search_depth[0]) << 2);
+	memset(table->search_depth, 0, sizeof(table->search_depth));
 }
 
 static void efx_filter_push_rx_limits(struct efx_nic *efx)
 {
 	struct efx_filter_state *state = efx->filter_state;
+	struct efx_filter_table *table;
 	efx_oword_t filter_ctl;
 
 	efx_reado(efx, &filter_ctl, FR_BZ_RX_FILTER_CTL);
 
+	table = &state->table[EFX_FILTER_TABLE_RX_IP];
 	EFX_SET_OWORD_FIELD(filter_ctl, FRF_BZ_TCP_FULL_SRCH_LIMIT,
-			    state->search_depth[EFX_FILTER_RX_TCP_FULL] +
+			    table->search_depth[EFX_FILTER_TCP_FULL] +
 			    FILTER_CTL_SRCH_FUDGE_FULL);
 	EFX_SET_OWORD_FIELD(filter_ctl, FRF_BZ_TCP_WILD_SRCH_LIMIT,
-			    state->search_depth[EFX_FILTER_RX_TCP_WILD] +
+			    table->search_depth[EFX_FILTER_TCP_WILD] +
 			    FILTER_CTL_SRCH_FUDGE_WILD);
 	EFX_SET_OWORD_FIELD(filter_ctl, FRF_BZ_UDP_FULL_SRCH_LIMIT,
-			    state->search_depth[EFX_FILTER_RX_UDP_FULL] +
+			    table->search_depth[EFX_FILTER_UDP_FULL] +
 			    FILTER_CTL_SRCH_FUDGE_FULL);
 	EFX_SET_OWORD_FIELD(filter_ctl, FRF_BZ_UDP_WILD_SRCH_LIMIT,
-			    state->search_depth[EFX_FILTER_RX_UDP_WILD] +
+			    table->search_depth[EFX_FILTER_UDP_WILD] +
 			    FILTER_CTL_SRCH_FUDGE_WILD);
 
-	if (state->table[EFX_FILTER_TABLE_RX_MAC].size) {
+	table = &state->table[EFX_FILTER_TABLE_RX_MAC];
+	if (table->size) {
 		EFX_SET_OWORD_FIELD(
 			filter_ctl, FRF_CZ_ETHERNET_FULL_SEARCH_LIMIT,
-			state->search_depth[EFX_FILTER_RX_MAC_FULL] +
+			table->search_depth[EFX_FILTER_MAC_FULL] +
 			FILTER_CTL_SRCH_FUDGE_FULL);
 		EFX_SET_OWORD_FIELD(
 			filter_ctl, FRF_CZ_ETHERNET_WILDCARD_SEARCH_LIMIT,
-			state->search_depth[EFX_FILTER_RX_MAC_WILD] +
+			table->search_depth[EFX_FILTER_MAC_WILD] +
 			FILTER_CTL_SRCH_FUDGE_WILD);
 	}
 
 	efx_writeo(efx, &filter_ctl, FR_BZ_RX_FILTER_CTL);
 }
 
+static inline void __efx_filter_set_ipv4(struct efx_filter_spec *spec,
+					 __be32 host1, __be16 port1,
+					 __be32 host2, __be16 port2)
+{
+	spec->data[0] = ntohl(host1) << 16 | ntohs(port1);
+	spec->data[1] = ntohs(port2) << 16 | ntohl(host1) >> 16;
+	spec->data[2] = ntohl(host2);
+}
+
+/**
+ * efx_filter_set_ipv4_local - specify IPv4 host, transport protocol and port
+ * @spec: Specification to initialise
+ * @proto: Transport layer protocol number
+ * @host: Local host address (network byte order)
+ * @port: Local port (network byte order)
+ */
+int efx_filter_set_ipv4_local(struct efx_filter_spec *spec, u8 proto,
+			      __be32 host, __be16 port)
+{
+	__be32 host1;
+	__be16 port1;
+
+	EFX_BUG_ON_PARANOID(!(spec->flags & EFX_FILTER_FLAG_RX));
+
+	/* This cannot currently be combined with other filtering */
+	if (spec->type != EFX_FILTER_UNSPEC)
+		return -EPROTONOSUPPORT;
+
+	if (port == 0)
+		return -EINVAL;
+
+	switch (proto) {
+	case IPPROTO_TCP:
+		spec->type = EFX_FILTER_TCP_WILD;
+		break;
+	case IPPROTO_UDP:
+		spec->type = EFX_FILTER_UDP_WILD;
+		break;
+	default:
+		return -EPROTONOSUPPORT;
+	}
+
+	/* Filter is constructed in terms of source and destination,
+	 * with the odd wrinkle that the ports are swapped in a UDP
+	 * wildcard filter.  We need to convert from local and remote
+	 * (= zero for wildcard) addresses.
+	 */
+	host1 = 0;
+	if (proto != IPPROTO_UDP) {
+		port1 = 0;
+	} else {
+		port1 = port;
+		port = 0;
+	}
+
+	__efx_filter_set_ipv4(spec, host1, port1, host, port);
+	return 0;
+}
+
+/**
+ * efx_filter_set_ipv4_full - specify IPv4 hosts, transport protocol and ports
+ * @spec: Specification to initialise
+ * @proto: Transport layer protocol number
+ * @host: Local host address (network byte order)
+ * @port: Local port (network byte order)
+ * @rhost: Remote host address (network byte order)
+ * @rport: Remote port (network byte order)
+ */
+int efx_filter_set_ipv4_full(struct efx_filter_spec *spec, u8 proto,
+			     __be32 host, __be16 port,
+			     __be32 rhost, __be16 rport)
+{
+	EFX_BUG_ON_PARANOID(!(spec->flags & EFX_FILTER_FLAG_RX));
+
+	/* This cannot currently be combined with other filtering */
+	if (spec->type != EFX_FILTER_UNSPEC)
+		return -EPROTONOSUPPORT;
+
+	if (port == 0 || rport == 0)
+		return -EINVAL;
+
+	switch (proto) {
+	case IPPROTO_TCP:
+		spec->type = EFX_FILTER_TCP_FULL;
+		break;
+	case IPPROTO_UDP:
+		spec->type = EFX_FILTER_UDP_FULL;
+		break;
+	default:
+		return -EPROTONOSUPPORT;
+	}
+
+	__efx_filter_set_ipv4(spec, rhost, rport, host, port);
+	return 0;
+}
+
+/**
+ * efx_filter_set_eth_local - specify local Ethernet address and optional VID
+ * @spec: Specification to initialise
+ * @vid: VLAN ID to match, or %EFX_FILTER_VID_UNSPEC
+ * @addr: Local Ethernet MAC address
+ */
+int efx_filter_set_eth_local(struct efx_filter_spec *spec,
+			     u16 vid, const u8 *addr)
+{
+	EFX_BUG_ON_PARANOID(!(spec->flags & EFX_FILTER_FLAG_RX));
+
+	/* This cannot currently be combined with other filtering */
+	if (spec->type != EFX_FILTER_UNSPEC)
+		return -EPROTONOSUPPORT;
+
+	if (vid == EFX_FILTER_VID_UNSPEC) {
+		spec->type = EFX_FILTER_MAC_WILD;
+		spec->data[0] = 0;
+	} else {
+		spec->type = EFX_FILTER_MAC_FULL;
+		spec->data[0] = vid;
+	}
+
+	spec->data[1] = addr[2] << 24 | addr[3] << 16 | addr[4] << 8 | addr[5];
+	spec->data[2] = addr[0] << 8 | addr[1];
+	return 0;
+}
+
 /* Build a filter entry and return its n-tuple key. */
 static u32 efx_filter_build(efx_oword_t *filter, struct efx_filter_spec *spec)
 {
 	u32 data3;
 
-	switch (efx_filter_type_table_id(spec->type)) {
+	switch (efx_filter_spec_table_id(spec)) {
 	case EFX_FILTER_TABLE_RX_IP: {
-		bool is_udp = (spec->type == EFX_FILTER_RX_UDP_FULL ||
-			       spec->type == EFX_FILTER_RX_UDP_WILD);
+		bool is_udp = (spec->type == EFX_FILTER_UDP_FULL ||
+			       spec->type == EFX_FILTER_UDP_WILD);
 		EFX_POPULATE_OWORD_7(
 			*filter,
 			FRF_BZ_RSS_EN,
@@ -149,7 +286,7 @@ static u32 efx_filter_build(efx_oword_t *filter, struct efx_filter_spec *spec)
 	}
 
 	case EFX_FILTER_TABLE_RX_MAC: {
-		bool is_wild = spec->type == EFX_FILTER_RX_MAC_WILD;
+		bool is_wild = spec->type == EFX_FILTER_MAC_WILD;
 		EFX_POPULATE_OWORD_8(
 			*filter,
 			FRF_CZ_RMFT_RSS_EN,
@@ -234,23 +371,21 @@ int efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 			     bool replace)
 {
 	struct efx_filter_state *state = efx->filter_state;
-	enum efx_filter_table_id table_id =
-		efx_filter_type_table_id(spec->type);
-	struct efx_filter_table *table = &state->table[table_id];
+	struct efx_filter_table *table = efx_filter_spec_table(state, spec);
 	struct efx_filter_spec *saved_spec;
 	efx_oword_t filter;
 	int filter_idx, depth;
 	u32 key;
 	int rc;
 
-	if (table->size == 0)
+	if (!table || table->size == 0)
 		return -EINVAL;
 
 	key = efx_filter_build(&filter, spec);
 
 	netif_vdbg(efx, hw, efx->net_dev,
 		   "%s: type %d search_depth=%d", __func__, spec->type,
-		   state->search_depth[spec->type]);
+		   table->search_depth[spec->type]);
 
 	spin_lock_bh(&state->lock);
 
@@ -277,8 +412,8 @@ int efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 	}
 	*saved_spec = *spec;
 
-	if (state->search_depth[spec->type] < depth) {
-		state->search_depth[spec->type] = depth;
+	if (table->search_depth[spec->type] < depth) {
+		table->search_depth[spec->type] = depth;
 		efx_filter_push_rx_limits(efx);
 	}
 
@@ -287,7 +422,7 @@ int efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
 	netif_vdbg(efx, hw, efx->net_dev,
 		   "%s: filter type %d index %d rxq %u set",
 		   __func__, spec->type, filter_idx, spec->dmaq_id);
-	rc = efx_filter_make_id(table_id, filter_idx);
+	rc = efx_filter_make_id(table->id, filter_idx);
 
 out:
 	spin_unlock_bh(&state->lock);
@@ -321,15 +456,16 @@ static void efx_filter_table_clear_entry(struct efx_nic *efx,
 int efx_filter_remove_filter(struct efx_nic *efx, struct efx_filter_spec *spec)
 {
 	struct efx_filter_state *state = efx->filter_state;
-	enum efx_filter_table_id table_id =
-		efx_filter_type_table_id(spec->type);
-	struct efx_filter_table *table = &state->table[table_id];
+	struct efx_filter_table *table = efx_filter_spec_table(state, spec);
 	struct efx_filter_spec *saved_spec;
 	efx_oword_t filter;
 	int filter_idx, depth;
 	u32 key;
 	int rc;
 
+	if (!table)
+		return -EINVAL;
+
 	key = efx_filter_build(&filter, spec);
 
 	spin_lock_bh(&state->lock);
@@ -347,7 +483,7 @@ int efx_filter_remove_filter(struct efx_nic *efx, struct efx_filter_spec *spec)
 
 	efx_filter_table_clear_entry(efx, table, filter_idx);
 	if (table->used == 0)
-		efx_filter_table_reset_search_depth(state, table_id);
+		efx_filter_table_reset_search_depth(table);
 	rc = 0;
 
 out:
@@ -369,7 +505,7 @@ static void efx_filter_table_clear(struct efx_nic *efx,
 		if (table->spec[filter_idx].priority <= priority)
 			efx_filter_table_clear_entry(efx, table, filter_idx);
 	if (table->used == 0)
-		efx_filter_table_reset_search_depth(state, table_id);
+		efx_filter_table_reset_search_depth(table);
 
 	spin_unlock_bh(&state->lock);
 }
@@ -427,6 +563,7 @@ int efx_probe_filters(struct efx_nic *efx)
 
 	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
 		table = &state->table[EFX_FILTER_TABLE_RX_IP];
+		table->id = EFX_FILTER_TABLE_RX_IP;
 		table->offset = FR_BZ_RX_FILTER_TBL0;
 		table->size = FR_BZ_RX_FILTER_TBL0_ROWS;
 		table->step = FR_BZ_RX_FILTER_TBL0_STEP;
@@ -434,6 +571,7 @@ int efx_probe_filters(struct efx_nic *efx)
 
 	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0) {
 		table = &state->table[EFX_FILTER_TABLE_RX_MAC];
+		table->id = EFX_FILTER_TABLE_RX_MAC;
 		table->offset = FR_CZ_RX_MAC_FILTER_TBL0;
 		table->size = FR_CZ_RX_MAC_FILTER_TBL0_ROWS;
 		table->step = FR_CZ_RX_MAC_FILTER_TBL0_STEP;
diff --git a/drivers/net/sfc/filter.h b/drivers/net/sfc/filter.h
index d11e4aa..872f213 100644
--- a/drivers/net/sfc/filter.h
+++ b/drivers/net/sfc/filter.h
@@ -14,23 +14,25 @@
 
 /**
  * enum efx_filter_type - type of hardware filter
- * @EFX_FILTER_RX_TCP_FULL: RX, matching TCP/IPv4 4-tuple
- * @EFX_FILTER_RX_TCP_WILD: RX, matching TCP/IPv4 destination (host, port)
- * @EFX_FILTER_RX_UDP_FULL: RX, matching UDP/IPv4 4-tuple
- * @EFX_FILTER_RX_UDP_WILD: RX, matching UDP/IPv4 destination (host, port)
- * @EFX_FILTER_RX_MAC_FULL: RX, matching Ethernet destination MAC address, VID
- * @EFX_FILTER_RX_MAC_WILD: RX, matching Ethernet destination MAC address
+ * @EFX_FILTER_TCP_FULL: Matching TCP/IPv4 4-tuple
+ * @EFX_FILTER_TCP_WILD: Matching TCP/IPv4 destination (host, port)
+ * @EFX_FILTER_UDP_FULL: Matching UDP/IPv4 4-tuple
+ * @EFX_FILTER_UDP_WILD: Matching UDP/IPv4 destination (host, port)
+ * @EFX_FILTER_MAC_FULL: Matching Ethernet destination MAC address, VID
+ * @EFX_FILTER_MAC_WILD: Matching Ethernet destination MAC address
+ * @EFX_FILTER_UNSPEC: Match type is unspecified
  *
- * Falcon NICs only support the RX TCP/IPv4 and UDP/IPv4 filter types.
+ * Falcon NICs only support the TCP/IPv4 and UDP/IPv4 filter types.
  */
 enum efx_filter_type {
-	EFX_FILTER_RX_TCP_FULL = 0,
-	EFX_FILTER_RX_TCP_WILD,
-	EFX_FILTER_RX_UDP_FULL,
-	EFX_FILTER_RX_UDP_WILD,
-	EFX_FILTER_RX_MAC_FULL = 4,
-	EFX_FILTER_RX_MAC_WILD,
-	EFX_FILTER_TYPE_COUNT,
+	EFX_FILTER_TCP_FULL = 0,
+	EFX_FILTER_TCP_WILD,
+	EFX_FILTER_UDP_FULL,
+	EFX_FILTER_UDP_WILD,
+	EFX_FILTER_MAC_FULL = 4,
+	EFX_FILTER_MAC_WILD,
+	EFX_FILTER_TYPE_COUNT,		/* number of specific types */
+	EFX_FILTER_UNSPEC = 0xf,
 };
 
 /**
@@ -57,13 +59,13 @@ enum efx_filter_priority {
  * @EFX_FILTER_FLAG_RX_OVERRIDE_IP: Enables a MAC filter to override
  *	any IP filter that matches the same packet.  By default, IP
  *	filters take precedence.
- *
- * Currently, no flags are defined for TX filters.
+ * @EFX_FILTER_FLAG_RX: Filter is for RX
  */
 enum efx_filter_flags {
 	EFX_FILTER_FLAG_RX_RSS = 0x01,
 	EFX_FILTER_FLAG_RX_SCATTER = 0x02,
 	EFX_FILTER_FLAG_RX_OVERRIDE_IP = 0x04,
+	EFX_FILTER_FLAG_RX = 0x08,
 };
 
 /**
@@ -85,99 +87,26 @@ struct efx_filter_spec {
 	u32	data[3];
 };
 
-/**
- * efx_filter_set_rx_tcp_full - specify RX filter with TCP/IPv4 full match
- * @spec: Specification to initialise
- * @shost: Source host address (host byte order)
- * @sport: Source port (host byte order)
- * @dhost: Destination host address (host byte order)
- * @dport: Destination port (host byte order)
- */
-static inline void
-efx_filter_set_rx_tcp_full(struct efx_filter_spec *spec,
-			   u32 shost, u16 sport, u32 dhost, u16 dport)
-{
-	spec->type = EFX_FILTER_RX_TCP_FULL;
-	spec->data[0] = sport | shost << 16;
-	spec->data[1] = dport << 16 | shost >> 16;
-	spec->data[2] = dhost;
-}
-
-/**
- * efx_filter_set_rx_tcp_wild - specify RX filter with TCP/IPv4 wildcard match
- * @spec: Specification to initialise
- * @dhost: Destination host address (host byte order)
- * @dport: Destination port (host byte order)
- */
-static inline void
-efx_filter_set_rx_tcp_wild(struct efx_filter_spec *spec, u32 dhost, u16 dport)
-{
-	spec->type = EFX_FILTER_RX_TCP_WILD;
-	spec->data[0] = 0;
-	spec->data[1] = dport << 16;
-	spec->data[2] = dhost;
-}
-
-/**
- * efx_filter_set_rx_udp_full - specify RX filter with UDP/IPv4 full match
- * @spec: Specification to initialise
- * @shost: Source host address (host byte order)
- * @sport: Source port (host byte order)
- * @dhost: Destination host address (host byte order)
- * @dport: Destination port (host byte order)
- */
-static inline void
-efx_filter_set_rx_udp_full(struct efx_filter_spec *spec,
-			   u32 shost, u16 sport, u32 dhost, u16 dport)
-{
-	spec->type = EFX_FILTER_RX_UDP_FULL;
-	spec->data[0] = sport | shost << 16;
-	spec->data[1] = dport << 16 | shost >> 16;
-	spec->data[2] = dhost;
-}
-
-/**
- * efx_filter_set_rx_udp_wild - specify RX filter with UDP/IPv4 wildcard match
- * @spec: Specification to initialise
- * @dhost: Destination host address (host byte order)
- * @dport: Destination port (host byte order)
- */
-static inline void
-efx_filter_set_rx_udp_wild(struct efx_filter_spec *spec, u32 dhost, u16 dport)
-{
-	spec->type = EFX_FILTER_RX_UDP_WILD;
-	spec->data[0] = dport;
-	spec->data[1] = 0;
-	spec->data[2] = dhost;
-}
-
-/**
- * efx_filter_set_rx_mac_full - specify RX filter with MAC full match
- * @spec: Specification to initialise
- * @vid: VLAN ID
- * @addr: Destination MAC address
- */
-static inline void efx_filter_set_rx_mac_full(struct efx_filter_spec *spec,
-					      u16 vid, const u8 *addr)
+static inline void efx_filter_init_rx(struct efx_filter_spec *spec,
+				      enum efx_filter_priority priority,
+				      enum efx_filter_flags flags,
+				      unsigned rxq_id)
 {
-	spec->type = EFX_FILTER_RX_MAC_FULL;
-	spec->data[0] = vid;
-	spec->data[1] = addr[2] << 24 | addr[3] << 16 | addr[4] << 8 | addr[5];
-	spec->data[2] = addr[0] << 8 | addr[1];
+	spec->type = EFX_FILTER_UNSPEC;
+	spec->priority = priority;
+	spec->flags = EFX_FILTER_FLAG_RX | flags;
+	spec->dmaq_id = rxq_id;
 }
 
-/**
- * efx_filter_set_rx_mac_full - specify RX filter with MAC wildcard match
- * @spec: Specification to initialise
- * @addr: Destination MAC address
- */
-static inline void efx_filter_set_rx_mac_wild(struct efx_filter_spec *spec,
-					      const u8 *addr)
-{
-	spec->type = EFX_FILTER_RX_MAC_WILD;
-	spec->data[0] = 0;
-	spec->data[1] = addr[2] << 24 | addr[3] << 16 | addr[4] << 8 | addr[5];
-	spec->data[2] = addr[0] << 8 | addr[1];
-}
+extern int efx_filter_set_ipv4_local(struct efx_filter_spec *spec, u8 proto,
+				     __be32 host, __be16 port);
+extern int efx_filter_set_ipv4_full(struct efx_filter_spec *spec, u8 proto,
+				    __be32 host, __be16 port,
+				    __be32 rhost, __be16 rport);
+extern int efx_filter_set_eth_local(struct efx_filter_spec *spec,
+				    u16 vid, const u8 *addr);
+enum {
+	EFX_FILTER_VID_UNSPEC = 0xffff,
+};
 
 #endif /* EFX_FILTER_H */
-- 
1.7.3.2


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

