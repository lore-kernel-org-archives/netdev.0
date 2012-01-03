From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net-next 5/8] sfc: Add support for retrieving and
 removing filters by ID
Date: Tue, 3 Jan 2012 22:05:39 +0000
Message-ID: <1325628339.2832.41.camel@bwh-desktop>
References: <1325627819.2832.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:36896 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755385Ab2ACWFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 17:05:43 -0500
In-Reply-To: <1325627819.2832.31.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These new functions will support an implementation of the ethtool
RX NFC rules API.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.h    |   12 ++
 drivers/net/ethernet/sfc/filter.c |  247 +++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/filter.h |    7 +
 3 files changed, 266 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 27f0b01..f0a5b7c 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -66,8 +66,20 @@ extern s32 efx_filter_insert_filter(struct efx_nic *efx,
 				    bool replace);
 extern int efx_filter_remove_filter(struct efx_nic *efx,
 				    struct efx_filter_spec *spec);
+extern int efx_filter_remove_id_safe(struct efx_nic *efx,
+				     enum efx_filter_priority priority,
+				     u32 filter_id);
+extern int efx_filter_get_filter_safe(struct efx_nic *efx,
+				      enum efx_filter_priority priority,
+				      u32 filter_id, struct efx_filter_spec *);
 extern void efx_filter_clear_rx(struct efx_nic *efx,
 				enum efx_filter_priority priority);
+extern u32 efx_filter_count_rx_used(struct efx_nic *efx,
+				    enum efx_filter_priority priority);
+extern u32 efx_filter_get_rx_id_limit(struct efx_nic *efx);
+extern s32 efx_filter_get_rx_ids(struct efx_nic *efx,
+				 enum efx_filter_priority priority,
+				 u32 *buf, u32 size);
 #ifdef CONFIG_RFS_ACCEL
 extern int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 			  u16 rxq_index, u32 flow_id);
diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index f41ed5b..8e3d33d 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -155,6 +155,16 @@ static inline void __efx_filter_set_ipv4(struct efx_filter_spec *spec,
 	spec->data[2] = ntohl(host2);
 }
 
+static inline void __efx_filter_get_ipv4(const struct efx_filter_spec *spec,
+					 __be32 *host1, __be16 *port1,
+					 __be32 *host2, __be16 *port2)
+{
+	*host1 = htonl(spec->data[0] >> 16 | spec->data[1] << 16);
+	*port1 = htons(spec->data[0]);
+	*host2 = htonl(spec->data[2]);
+	*port2 = htons(spec->data[1] >> 16);
+}
+
 /**
  * efx_filter_set_ipv4_local - specify IPv4 host, transport protocol and port
  * @spec: Specification to initialise
@@ -205,6 +215,26 @@ int efx_filter_set_ipv4_local(struct efx_filter_spec *spec, u8 proto,
 	return 0;
 }
 
+int efx_filter_get_ipv4_local(const struct efx_filter_spec *spec,
+			      u8 *proto, __be32 *host, __be16 *port)
+{
+	__be32 host1;
+	__be16 port1;
+
+	switch (spec->type) {
+	case EFX_FILTER_TCP_WILD:
+		*proto = IPPROTO_TCP;
+		__efx_filter_get_ipv4(spec, &host1, &port1, host, port);
+		return 0;
+	case EFX_FILTER_UDP_WILD:
+		*proto = IPPROTO_UDP;
+		__efx_filter_get_ipv4(spec, &host1, port, host, &port1);
+		return 0;
+	default:
+		return -EINVAL;
+	}
+}
+
 /**
  * efx_filter_set_ipv4_full - specify IPv4 hosts, transport protocol and ports
  * @spec: Specification to initialise
@@ -242,6 +272,25 @@ int efx_filter_set_ipv4_full(struct efx_filter_spec *spec, u8 proto,
 	return 0;
 }
 
+int efx_filter_get_ipv4_full(const struct efx_filter_spec *spec,
+			     u8 *proto, __be32 *host, __be16 *port,
+			     __be32 *rhost, __be16 *rport)
+{
+	switch (spec->type) {
+	case EFX_FILTER_TCP_FULL:
+		*proto = IPPROTO_TCP;
+		break;
+	case EFX_FILTER_UDP_FULL:
+		*proto = IPPROTO_UDP;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	__efx_filter_get_ipv4(spec, rhost, rport, host, port);
+	return 0;
+}
+
 /**
  * efx_filter_set_eth_local - specify local Ethernet address and optional VID
  * @spec: Specification to initialise
@@ -270,6 +319,29 @@ int efx_filter_set_eth_local(struct efx_filter_spec *spec,
 	return 0;
 }
 
+int efx_filter_get_eth_local(const struct efx_filter_spec *spec,
+			     u16 *vid, u8 *addr)
+{
+	switch (spec->type) {
+	case EFX_FILTER_MAC_WILD:
+		*vid = EFX_FILTER_VID_UNSPEC;
+		break;
+	case EFX_FILTER_MAC_FULL:
+		*vid = spec->data[0];
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	addr[0] = spec->data[2] >> 8;
+	addr[1] = spec->data[2];
+	addr[2] = spec->data[1] >> 24;
+	addr[3] = spec->data[1] >> 16;
+	addr[4] = spec->data[1] >> 8;
+	addr[5] = spec->data[1];
+	return 0;
+}
+
 /* Build a filter entry and return its n-tuple key. */
 static u32 efx_filter_build(efx_oword_t *filter, struct efx_filter_spec *spec)
 {
@@ -407,6 +479,20 @@ static inline u8 efx_filter_id_flags(u32 id)
 		EFX_FILTER_FLAG_RX;
 }
 
+u32 efx_filter_get_rx_id_limit(struct efx_nic *efx)
+{
+	struct efx_filter_state *state = efx->filter_state;
+
+	if (state->table[EFX_FILTER_TABLE_RX_MAC].size != 0)
+		return ((EFX_FILTER_TABLE_RX_MAC + 1) << EFX_FILTER_INDEX_WIDTH)
+			+ state->table[EFX_FILTER_TABLE_RX_MAC].size;
+	else if (state->table[EFX_FILTER_TABLE_RX_IP].size != 0)
+		return ((EFX_FILTER_TABLE_RX_IP + 1) << EFX_FILTER_INDEX_WIDTH) 
+			+ state->table[EFX_FILTER_TABLE_RX_IP].size;
+	else
+		return 0;
+}
+
 /**
  * efx_filter_insert_filter - add or replace a filter
  * @efx: NIC in which to insert the filter
@@ -496,6 +582,105 @@ static void efx_filter_table_clear_entry(struct efx_nic *efx,
 }
 
 /**
+ * efx_filter_remove_id_safe - remove a filter by ID, carefully
+ * @efx: NIC from which to remove the filter
+ * @priority: Priority of filter, as passed to @efx_filter_insert_filter
+ * @filter_id: ID of filter, as returned by @efx_filter_insert_filter
+ *
+ * This function will range-check @filter_id, so it is safe to call
+ * with a value passed from userland.
+ */
+int efx_filter_remove_id_safe(struct efx_nic *efx,
+			      enum efx_filter_priority priority,
+			      u32 filter_id)
+{
+	struct efx_filter_state *state = efx->filter_state;
+	enum efx_filter_table_id table_id;
+	struct efx_filter_table *table;
+	unsigned int filter_idx;
+	struct efx_filter_spec *spec;
+	u8 filter_flags;
+	int rc;
+
+	table_id = efx_filter_id_table_id(filter_id);
+	if ((unsigned int)table_id >= EFX_FILTER_TABLE_COUNT)
+		return -ENOENT;
+	table = &state->table[table_id];
+
+	filter_idx = efx_filter_id_index(filter_id);
+	if (filter_idx >= table->size)
+		return -ENOENT;
+	spec = &table->spec[filter_idx];
+
+	filter_flags = efx_filter_id_flags(filter_id);
+
+	spin_lock_bh(&state->lock);
+
+	if (test_bit(filter_idx, table->used_bitmap) &&
+	    spec->priority == priority && spec->flags == filter_flags) {
+		efx_filter_table_clear_entry(efx, table, filter_idx);
+		if (table->used == 0)
+			efx_filter_table_reset_search_depth(table);
+		rc = 0;
+	} else {
+		rc = -ENOENT;
+	}
+
+	spin_unlock_bh(&state->lock);
+
+	return rc;
+}
+
+/**
+ * efx_filter_get_filter_safe - retrieve a filter by ID, carefully
+ * @efx: NIC from which to remove the filter
+ * @priority: Priority of filter, as passed to @efx_filter_insert_filter
+ * @filter_id: ID of filter, as returned by @efx_filter_insert_filter
+ * @spec: Buffer in which to store filter specification
+ *
+ * This function will range-check @filter_id, so it is safe to call
+ * with a value passed from userland.
+ */
+int efx_filter_get_filter_safe(struct efx_nic *efx,
+			       enum efx_filter_priority priority,
+			       u32 filter_id, struct efx_filter_spec *spec_buf)
+{
+	struct efx_filter_state *state = efx->filter_state;
+	enum efx_filter_table_id table_id;
+	struct efx_filter_table *table;
+	struct efx_filter_spec *spec;
+	unsigned int filter_idx;
+	u8 filter_flags;
+	int rc;
+
+	table_id = efx_filter_id_table_id(filter_id);
+	if ((unsigned int)table_id >= EFX_FILTER_TABLE_COUNT)
+		return -ENOENT;
+	table = &state->table[table_id];
+
+	filter_idx = efx_filter_id_index(filter_id);
+	if (filter_idx >= table->size)
+		return -ENOENT;
+	spec = &table->spec[filter_idx];
+
+	filter_flags = efx_filter_id_flags(filter_id);
+
+	spin_lock_bh(&state->lock);
+
+	if (test_bit(filter_idx, table->used_bitmap) &&
+	    spec->priority == priority && spec->flags == filter_flags) {
+		*spec_buf = *spec;
+		rc = 0;
+	} else {
+		rc = -ENOENT;
+	}
+
+	spin_unlock_bh(&state->lock);
+
+	return rc;
+}
+
+/**
  * efx_filter_remove_filter - remove a filter by specification
  * @efx: NIC from which to remove the filter
  * @spec: Specification for the filter
@@ -571,6 +756,68 @@ void efx_filter_clear_rx(struct efx_nic *efx, enum efx_filter_priority priority)
 	efx_filter_table_clear(efx, EFX_FILTER_TABLE_RX_MAC, priority);
 }
 
+u32 efx_filter_count_rx_used(struct efx_nic *efx,
+			     enum efx_filter_priority priority)
+{
+	struct efx_filter_state *state = efx->filter_state;
+	enum efx_filter_table_id table_id;
+	struct efx_filter_table *table;
+	unsigned int filter_idx;
+	u32 count = 0;
+
+	spin_lock_bh(&state->lock);
+
+	for (table_id = EFX_FILTER_TABLE_RX_IP;
+	     table_id <= EFX_FILTER_TABLE_RX_MAC;
+	     table_id++) {
+		table = &state->table[table_id];
+		for (filter_idx = 0; filter_idx < table->size; filter_idx++) {
+			if (test_bit(filter_idx, table->used_bitmap) &&
+			    table->spec[filter_idx].priority == priority)
+				++count;
+		}
+	}
+
+	spin_unlock_bh(&state->lock);
+
+	return count;
+}
+
+s32 efx_filter_get_rx_ids(struct efx_nic *efx,
+			  enum efx_filter_priority priority,
+			  u32 *buf, u32 size)
+{
+	struct efx_filter_state *state = efx->filter_state;
+	enum efx_filter_table_id table_id;
+	struct efx_filter_table *table;
+	unsigned int filter_idx;
+	s32 count = 0;
+
+	spin_lock_bh(&state->lock);
+
+	for (table_id = EFX_FILTER_TABLE_RX_IP;
+	     table_id <= EFX_FILTER_TABLE_RX_MAC;
+	     table_id++) {
+		table = &state->table[table_id];
+		for (filter_idx = 0; filter_idx < table->size; filter_idx++) {
+			if (test_bit(filter_idx, table->used_bitmap) &&
+			    table->spec[filter_idx].priority == priority) {
+				if (count == size) {
+					count = -EMSGSIZE;
+					goto out;
+				}
+				buf[count++] = efx_filter_make_id(
+					table_id, filter_idx,
+					table->spec[filter_idx].flags);
+			}
+		}
+	}
+out:
+	spin_unlock_bh(&state->lock);
+
+	return count;
+}
+
 /* Restore filter stater after reset */
 void efx_restore_filters(struct efx_nic *efx)
 {
diff --git a/drivers/net/ethernet/sfc/filter.h b/drivers/net/ethernet/sfc/filter.h
index dc9a256..3d4108c 100644
--- a/drivers/net/ethernet/sfc/filter.h
+++ b/drivers/net/ethernet/sfc/filter.h
@@ -105,11 +105,18 @@ static inline void efx_filter_init_rx(struct efx_filter_spec *spec,
 
 extern int efx_filter_set_ipv4_local(struct efx_filter_spec *spec, u8 proto,
 				     __be32 host, __be16 port);
+extern int efx_filter_get_ipv4_local(const struct efx_filter_spec *spec,
+				     u8 *proto, __be32 *host, __be16 *port);
 extern int efx_filter_set_ipv4_full(struct efx_filter_spec *spec, u8 proto,
 				    __be32 host, __be16 port,
 				    __be32 rhost, __be16 rport);
+extern int efx_filter_get_ipv4_full(const struct efx_filter_spec *spec,
+				    u8 *proto, __be32 *host, __be16 *port,
+				    __be32 *rhost, __be16 *rport);
 extern int efx_filter_set_eth_local(struct efx_filter_spec *spec,
 				    u16 vid, const u8 *addr);
+extern int efx_filter_get_eth_local(const struct efx_filter_spec *spec,
+				    u16 *vid, u8 *addr);
 enum {
 	EFX_FILTER_VID_UNSPEC = 0xffff,
 };
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
