From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 4/8] sfc: Add filter table management
Date: Mon, 20 Sep 2010 19:43:07 +0100
Message-ID: <1285008187.2282.107.camel@achroite.uk.solarflarecom.com>
References: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7217 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754285Ab0ITSnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 14:43:11 -0400
In-Reply-To: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/Makefile     |    2 +-
 drivers/net/sfc/efx.c        |   11 +
 drivers/net/sfc/efx.h        |   14 ++
 drivers/net/sfc/filter.c     |  445 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/filter.h     |  189 ++++++++++++++++++
 drivers/net/sfc/net_driver.h |    4 +
 drivers/net/sfc/regs.h       |   14 ++
 7 files changed, 678 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/sfc/filter.c
 create mode 100644 drivers/net/sfc/filter.h

diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
index 1047b19..fd9272b 100644
--- a/drivers/net/sfc/Makefile
+++ b/drivers/net/sfc/Makefile
@@ -1,4 +1,4 @@
-sfc-y			+= efx.o nic.o falcon.o siena.o tx.o rx.o \
+sfc-y			+= efx.o nic.o falcon.o siena.o tx.o rx.o filter.o \
 			   falcon_gmac.o falcon_xmac.o mcdi_mac.o \
 			   selftest.o ethtool.o qt202x_phy.o mdio_10g.o \
 			   tenxpress.o falcon_boards.o mcdi.o mcdi_phy.o
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index f702f1f..4a1c93f 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1357,8 +1357,17 @@ static int efx_probe_all(struct efx_nic *efx)
 	if (rc)
 		goto fail3;
 
+	rc = efx_probe_filters(efx);
+	if (rc) {
+		netif_err(efx, probe, efx->net_dev,
+			  "failed to create filter tables\n");
+		goto fail4;
+	}
+
 	return 0;
 
+ fail4:
+	efx_remove_channels(efx);
  fail3:
 	efx_remove_port(efx);
  fail2:
@@ -1489,6 +1498,7 @@ static void efx_stop_all(struct efx_nic *efx)
 
 static void efx_remove_all(struct efx_nic *efx)
 {
+	efx_remove_filters(efx);
 	efx_remove_channels(efx);
 	efx_remove_port(efx);
 	efx_remove_nic(efx);
@@ -2002,6 +2012,7 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok)
 	efx->mac_op->reconfigure(efx);
 
 	efx_init_channels(efx);
+	efx_restore_filters(efx);
 
 	mutex_unlock(&efx->spi_lock);
 	mutex_unlock(&efx->mac_lock);
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index e783c0f..f502b14 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -12,6 +12,7 @@
 #define EFX_EFX_H
 
 #include "net_driver.h"
+#include "filter.h"
 
 /* PCI IDs */
 #define EFX_VENDID_SFC	        0x1924
@@ -64,6 +65,19 @@ extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue);
  * skb. Falcon/A1 may require up to three descriptors per skb_frag. */
 #define EFX_MIN_RING_SIZE (roundup_pow_of_two(2 * 3 * MAX_SKB_FRAGS))
 
+/* Filters */
+extern int efx_probe_filters(struct efx_nic *efx);
+extern void efx_restore_filters(struct efx_nic *efx);
+extern void efx_remove_filters(struct efx_nic *efx);
+extern int efx_filter_insert_filter(struct efx_nic *efx,
+				    struct efx_filter_spec *spec,
+				    bool replace);
+extern int efx_filter_remove_filter(struct efx_nic *efx,
+				    struct efx_filter_spec *spec);
+extern void efx_filter_table_clear(struct efx_nic *efx,
+				   enum efx_filter_table_id table_id,
+				   enum efx_filter_priority priority);
+
 /* Channels */
 extern void efx_process_channel_now(struct efx_channel *channel);
 extern int
diff --git a/drivers/net/sfc/filter.c b/drivers/net/sfc/filter.c
new file mode 100644
index 0000000..abc884d
--- /dev/null
+++ b/drivers/net/sfc/filter.c
@@ -0,0 +1,445 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2010 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include "efx.h"
+#include "filter.h"
+#include "io.h"
+#include "nic.h"
+#include "regs.h"
+
+/* "Fudge factors" - difference between programmed value and actual depth.
+ * Due to pipelined implementation we need to program H/W with a value that
+ * is larger than the hop limit we want.
+ */
+#define FILTER_CTL_SRCH_FUDGE_WILD 3
+#define FILTER_CTL_SRCH_FUDGE_FULL 1
+
+struct efx_filter_table {
+	u32		offset;		/* address of table relative to BAR */
+	unsigned	size;		/* number of entries */
+	unsigned	step;		/* step between entries */
+	unsigned	used;		/* number currently used */
+	unsigned long	*used_bitmap;
+	struct efx_filter_spec *spec;
+};
+
+struct efx_filter_state {
+	spinlock_t	lock;
+	struct efx_filter_table table[EFX_FILTER_TABLE_COUNT];
+	unsigned	search_depth[EFX_FILTER_TYPE_COUNT];
+};
+
+/* The filter hash function is LFSR polynomial x^16 + x^3 + 1 of a 32-bit
+ * key derived from the n-tuple.  The initial LFSR state is 0xffff. */
+static u16 efx_filter_hash(u32 key)
+{
+	u16 tmp;
+
+	/* First 16 rounds */
+	tmp = 0x1fff ^ key >> 16;
+	tmp = tmp ^ tmp >> 3 ^ tmp >> 6;
+	tmp = tmp ^ tmp >> 9;
+	/* Last 16 rounds */
+	tmp = tmp ^ tmp << 13 ^ key;
+	tmp = tmp ^ tmp >> 3 ^ tmp >> 6;
+	return tmp ^ tmp >> 9;
+}
+
+/* To allow for hash collisions, filter search continues at these
+ * increments from the first possible entry selected by the hash. */
+static u16 efx_filter_increment(u32 key)
+{
+	return key * 2 - 1;
+}
+
+static enum efx_filter_table_id
+efx_filter_type_table_id(enum efx_filter_type type)
+{
+	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_IP != (EFX_FILTER_RX_TCP_FULL >> 2));
+	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_IP != (EFX_FILTER_RX_TCP_WILD >> 2));
+	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_IP != (EFX_FILTER_RX_UDP_FULL >> 2));
+	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_IP != (EFX_FILTER_RX_UDP_WILD >> 2));
+	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_MAC != (EFX_FILTER_RX_MAC_FULL >> 2));
+	BUILD_BUG_ON(EFX_FILTER_TABLE_RX_MAC != (EFX_FILTER_RX_MAC_WILD >> 2));
+	return type >> 2;
+}
+
+static void
+efx_filter_table_reset_search_depth(struct efx_filter_state *state,
+				    enum efx_filter_table_id table_id)
+{
+	memset(state->search_depth + (table_id << 2), 0,
+	       sizeof(state->search_depth[0]) << 2);
+}
+
+static void efx_filter_push_rx_limits(struct efx_nic *efx)
+{
+	struct efx_filter_state *state = efx->filter_state;
+	efx_oword_t filter_ctl;
+
+	efx_reado(efx, &filter_ctl, FR_BZ_RX_FILTER_CTL);
+
+	EFX_SET_OWORD_FIELD(filter_ctl, FRF_BZ_TCP_FULL_SRCH_LIMIT,
+			    state->search_depth[EFX_FILTER_RX_TCP_FULL] +
+			    FILTER_CTL_SRCH_FUDGE_FULL);
+	EFX_SET_OWORD_FIELD(filter_ctl, FRF_BZ_TCP_WILD_SRCH_LIMIT,
+			    state->search_depth[EFX_FILTER_RX_TCP_WILD] +
+			    FILTER_CTL_SRCH_FUDGE_WILD);
+	EFX_SET_OWORD_FIELD(filter_ctl, FRF_BZ_UDP_FULL_SRCH_LIMIT,
+			    state->search_depth[EFX_FILTER_RX_UDP_FULL] +
+			    FILTER_CTL_SRCH_FUDGE_FULL);
+	EFX_SET_OWORD_FIELD(filter_ctl, FRF_BZ_UDP_WILD_SRCH_LIMIT,
+			    state->search_depth[EFX_FILTER_RX_UDP_WILD] +
+			    FILTER_CTL_SRCH_FUDGE_WILD);
+
+	if (state->table[EFX_FILTER_TABLE_RX_MAC].size) {
+		EFX_SET_OWORD_FIELD(
+			filter_ctl, FRF_CZ_ETHERNET_FULL_SEARCH_LIMIT,
+			state->search_depth[EFX_FILTER_RX_MAC_FULL] +
+			FILTER_CTL_SRCH_FUDGE_FULL);
+		EFX_SET_OWORD_FIELD(
+			filter_ctl, FRF_CZ_ETHERNET_WILDCARD_SEARCH_LIMIT,
+			state->search_depth[EFX_FILTER_RX_MAC_WILD] +
+			FILTER_CTL_SRCH_FUDGE_WILD);
+	}
+
+	efx_writeo(efx, &filter_ctl, FR_BZ_RX_FILTER_CTL);
+}
+
+/* Build a filter entry and return its n-tuple key. */
+static u32 efx_filter_build(efx_oword_t *filter, struct efx_filter_spec *spec)
+{
+	u32 data3;
+
+	switch (efx_filter_type_table_id(spec->type)) {
+	case EFX_FILTER_TABLE_RX_IP: {
+		bool is_udp = (spec->type == EFX_FILTER_RX_UDP_FULL ||
+			       spec->type == EFX_FILTER_RX_UDP_WILD);
+		EFX_POPULATE_OWORD_7(
+			*filter,
+			FRF_BZ_RSS_EN,
+			!!(spec->flags & EFX_FILTER_FLAG_RX_RSS),
+			FRF_BZ_SCATTER_EN,
+			!!(spec->flags & EFX_FILTER_FLAG_RX_SCATTER),
+			FRF_BZ_TCP_UDP, is_udp,
+			FRF_BZ_RXQ_ID, spec->dmaq_id,
+			EFX_DWORD_2, spec->data[2],
+			EFX_DWORD_1, spec->data[1],
+			EFX_DWORD_0, spec->data[0]);
+		data3 = is_udp;
+		break;
+	}
+
+	case EFX_FILTER_TABLE_RX_MAC: {
+		bool is_wild = spec->type == EFX_FILTER_RX_MAC_WILD;
+		EFX_POPULATE_OWORD_8(
+			*filter,
+			FRF_CZ_RMFT_RSS_EN,
+			!!(spec->flags & EFX_FILTER_FLAG_RX_RSS),
+			FRF_CZ_RMFT_SCATTER_EN,
+			!!(spec->flags & EFX_FILTER_FLAG_RX_SCATTER),
+			FRF_CZ_RMFT_IP_OVERRIDE,
+			!!(spec->flags & EFX_FILTER_FLAG_RX_OVERRIDE_IP),
+			FRF_CZ_RMFT_RXQ_ID, spec->dmaq_id,
+			FRF_CZ_RMFT_WILDCARD_MATCH, is_wild,
+			FRF_CZ_RMFT_DEST_MAC_HI, spec->data[2],
+			FRF_CZ_RMFT_DEST_MAC_LO, spec->data[1],
+			FRF_CZ_RMFT_VLAN_ID, spec->data[0]);
+		data3 = is_wild;
+		break;
+	}
+
+	default:
+		BUG();
+	}
+
+	return spec->data[0] ^ spec->data[1] ^ spec->data[2] ^ data3;
+}
+
+static bool efx_filter_equal(const struct efx_filter_spec *left,
+			     const struct efx_filter_spec *right)
+{
+	if (left->type != right->type ||
+	    memcmp(left->data, right->data, sizeof(left->data)))
+		return false;
+
+	return true;
+}
+
+static int efx_filter_search(struct efx_filter_table *table,
+			     struct efx_filter_spec *spec, u32 key,
+			     bool for_insert, int *depth_required)
+{
+	unsigned hash, incr, filter_idx, depth;
+	struct efx_filter_spec *cmp;
+
+	hash = efx_filter_hash(key);
+	incr = efx_filter_increment(key);
+
+	for (depth = 1, filter_idx = hash & (table->size - 1);
+	     test_bit(filter_idx, table->used_bitmap);
+	     ++depth) {
+		cmp = &table->spec[filter_idx];
+		if (efx_filter_equal(spec, cmp))
+			goto found;
+		filter_idx = (filter_idx + incr) & (table->size - 1);
+	}
+	if (!for_insert)
+		return -ENOENT;
+found:
+	*depth_required = depth;
+	return filter_idx;
+}
+
+/**
+ * efx_filter_insert_filter - add or replace a filter
+ * @efx: NIC in which to insert the filter
+ * @spec: Specification for the filter
+ * @replace: Flag for whether the specified filter may replace a filter
+ *	with an identical match expression and equal or lower priority
+ *
+ * On success, return the filter index within its table.
+ * On failure, return a negative error code.
+ */
+int efx_filter_insert_filter(struct efx_nic *efx, struct efx_filter_spec *spec,
+			     bool replace)
+{
+	struct efx_filter_state *state = efx->filter_state;
+	enum efx_filter_table_id table_id =
+		efx_filter_type_table_id(spec->type);
+	struct efx_filter_table *table = &state->table[table_id];
+	struct efx_filter_spec *saved_spec;
+	efx_oword_t filter;
+	int filter_idx, depth;
+	u32 key;
+	int rc;
+
+	if (table->size == 0)
+		return -EINVAL;
+
+	key = efx_filter_build(&filter, spec);
+
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "%s: type %d search_depth=%d", __func__, spec->type,
+		   state->search_depth[spec->type]);
+
+	spin_lock_bh(&state->lock);
+
+	rc = efx_filter_search(table, spec, key, true, &depth);
+	if (rc < 0)
+		goto out;
+	filter_idx = rc;
+	BUG_ON(filter_idx >= table->size);
+	saved_spec = &table->spec[filter_idx];
+
+	if (test_bit(filter_idx, table->used_bitmap)) {
+		/* Should we replace the existing filter? */
+		if (!replace) {
+			rc = -EEXIST;
+			goto out;
+		}
+		if (spec->priority < saved_spec->priority) {
+			rc = -EPERM;
+			goto out;
+		}
+	} else {
+		__set_bit(filter_idx, table->used_bitmap);
+		++table->used;
+	}
+	*saved_spec = *spec;
+
+	if (state->search_depth[spec->type] < depth) {
+		state->search_depth[spec->type] = depth;
+		efx_filter_push_rx_limits(efx);
+	}
+
+	efx_writeo(efx, &filter, table->offset + table->step * filter_idx);
+
+	netif_vdbg(efx, hw, efx->net_dev,
+		   "%s: filter type %d index %d rxq %u set",
+		   __func__, spec->type, filter_idx, spec->dmaq_id);
+
+out:
+	spin_unlock_bh(&state->lock);
+	return rc;
+}
+
+static void efx_filter_table_clear_entry(struct efx_nic *efx,
+					 struct efx_filter_table *table,
+					 int filter_idx)
+{
+	static efx_oword_t filter;
+
+	if (test_bit(filter_idx, table->used_bitmap)) {
+		__clear_bit(filter_idx, table->used_bitmap);
+		--table->used;
+		memset(&table->spec[filter_idx], 0, sizeof(table->spec[0]));
+
+		efx_writeo(efx, &filter,
+			   table->offset + table->step * filter_idx);
+	}
+}
+
+/**
+ * efx_filter_remove_filter - remove a filter by specification
+ * @efx: NIC from which to remove the filter
+ * @spec: Specification for the filter
+ *
+ * On success, return zero.
+ * On failure, return a negative error code.
+ */
+int efx_filter_remove_filter(struct efx_nic *efx, struct efx_filter_spec *spec)
+{
+	struct efx_filter_state *state = efx->filter_state;
+	enum efx_filter_table_id table_id =
+		efx_filter_type_table_id(spec->type);
+	struct efx_filter_table *table = &state->table[table_id];
+	struct efx_filter_spec *saved_spec;
+	efx_oword_t filter;
+	int filter_idx, depth;
+	u32 key;
+	int rc;
+
+	key = efx_filter_build(&filter, spec);
+
+	spin_lock_bh(&state->lock);
+
+	rc = efx_filter_search(table, spec, key, false, &depth);
+	if (rc < 0)
+		goto out;
+	filter_idx = rc;
+	saved_spec = &table->spec[filter_idx];
+
+	if (spec->priority < saved_spec->priority) {
+		rc = -EPERM;
+		goto out;
+	}
+
+	efx_filter_table_clear_entry(efx, table, filter_idx);
+	if (table->used == 0)
+		efx_filter_table_reset_search_depth(state, table_id);
+	rc = 0;
+
+out:
+	spin_unlock_bh(&state->lock);
+	return rc;
+}
+
+/**
+ * efx_filter_table_clear - remove filters from a table by priority
+ * @efx: NIC from which to remove the filters
+ * @table_id: Table from which to remove the filters
+ * @priority: Maximum priority to remove
+ */
+void efx_filter_table_clear(struct efx_nic *efx,
+			    enum efx_filter_table_id table_id,
+			    enum efx_filter_priority priority)
+{
+	struct efx_filter_state *state = efx->filter_state;
+	struct efx_filter_table *table = &state->table[table_id];
+	int filter_idx;
+
+	spin_lock_bh(&state->lock);
+
+	for (filter_idx = 0; filter_idx < table->size; ++filter_idx)
+		if (table->spec[filter_idx].priority <= priority)
+			efx_filter_table_clear_entry(efx, table, filter_idx);
+	if (table->used == 0)
+		efx_filter_table_reset_search_depth(state, table_id);
+
+	spin_unlock_bh(&state->lock);
+}
+
+/* Restore filter stater after reset */
+void efx_restore_filters(struct efx_nic *efx)
+{
+	struct efx_filter_state *state = efx->filter_state;
+	enum efx_filter_table_id table_id;
+	struct efx_filter_table *table;
+	efx_oword_t filter;
+	int filter_idx;
+
+	spin_lock_bh(&state->lock);
+
+	for (table_id = 0; table_id < EFX_FILTER_TABLE_COUNT; table_id++) {
+		table = &state->table[table_id];
+		for (filter_idx = 0; filter_idx < table->size; filter_idx++) {
+			if (!test_bit(filter_idx, table->used_bitmap))
+				continue;
+			efx_filter_build(&filter, &table->spec[filter_idx]);
+			efx_writeo(efx, &filter,
+				   table->offset + table->step * filter_idx);
+		}
+	}
+
+	efx_filter_push_rx_limits(efx);
+
+	spin_unlock_bh(&state->lock);
+}
+
+int efx_probe_filters(struct efx_nic *efx)
+{
+	struct efx_filter_state *state;
+	struct efx_filter_table *table;
+	unsigned table_id;
+
+	state = kzalloc(sizeof(*efx->filter_state), GFP_KERNEL);
+	if (!state)
+		return -ENOMEM;
+	efx->filter_state = state;
+
+	spin_lock_init(&state->lock);
+
+	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
+		table = &state->table[EFX_FILTER_TABLE_RX_IP];
+		table->offset = FR_BZ_RX_FILTER_TBL0;
+		table->size = FR_BZ_RX_FILTER_TBL0_ROWS;
+		table->step = FR_BZ_RX_FILTER_TBL0_STEP;
+	}
+
+	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0) {
+		table = &state->table[EFX_FILTER_TABLE_RX_MAC];
+		table->offset = FR_CZ_RX_MAC_FILTER_TBL0;
+		table->size = FR_CZ_RX_MAC_FILTER_TBL0_ROWS;
+		table->step = FR_CZ_RX_MAC_FILTER_TBL0_STEP;
+	}
+
+	for (table_id = 0; table_id < EFX_FILTER_TABLE_COUNT; table_id++) {
+		table = &state->table[table_id];
+		if (table->size == 0)
+			continue;
+		table->used_bitmap = kcalloc(BITS_TO_LONGS(table->size),
+					     sizeof(unsigned long),
+					     GFP_KERNEL);
+		if (!table->used_bitmap)
+			goto fail;
+		table->spec = vmalloc(table->size * sizeof(*table->spec));
+		if (!table->spec)
+			goto fail;
+		memset(table->spec, 0, table->size * sizeof(*table->spec));
+	}
+
+	return 0;
+
+fail:
+	efx_remove_filters(efx);
+	return -ENOMEM;
+}
+
+void efx_remove_filters(struct efx_nic *efx)
+{
+	struct efx_filter_state *state = efx->filter_state;
+	enum efx_filter_table_id table_id;
+
+	for (table_id = 0; table_id < EFX_FILTER_TABLE_COUNT; table_id++) {
+		kfree(state->table[table_id].used_bitmap);
+		vfree(state->table[table_id].spec);
+	}
+	kfree(state);
+}
diff --git a/drivers/net/sfc/filter.h b/drivers/net/sfc/filter.h
new file mode 100644
index 0000000..a53319d
--- /dev/null
+++ b/drivers/net/sfc/filter.h
@@ -0,0 +1,189 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2010 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_FILTER_H
+#define EFX_FILTER_H
+
+#include <linux/types.h>
+
+enum efx_filter_table_id {
+	EFX_FILTER_TABLE_RX_IP = 0,
+	EFX_FILTER_TABLE_RX_MAC,
+	EFX_FILTER_TABLE_COUNT,
+};
+
+/**
+ * enum efx_filter_type - type of hardware filter
+ * @EFX_FILTER_RX_TCP_FULL: RX, matching TCP/IPv4 4-tuple
+ * @EFX_FILTER_RX_TCP_WILD: RX, matching TCP/IPv4 destination (host, port)
+ * @EFX_FILTER_RX_UDP_FULL: RX, matching UDP/IPv4 4-tuple
+ * @EFX_FILTER_RX_UDP_WILD: RX, matching UDP/IPv4 destination (host, port)
+ * @EFX_FILTER_RX_MAC_FULL: RX, matching Ethernet destination MAC address, VID
+ * @EFX_FILTER_RX_MAC_WILD: RX, matching Ethernet destination MAC address
+ *
+ * Falcon NICs only support the RX TCP/IPv4 and UDP/IPv4 filter types.
+ */
+enum efx_filter_type {
+	EFX_FILTER_RX_TCP_FULL = 0,
+	EFX_FILTER_RX_TCP_WILD,
+	EFX_FILTER_RX_UDP_FULL,
+	EFX_FILTER_RX_UDP_WILD,
+	EFX_FILTER_RX_MAC_FULL = 4,
+	EFX_FILTER_RX_MAC_WILD,
+	EFX_FILTER_TYPE_COUNT,
+};
+
+/**
+ * enum efx_filter_priority - priority of a hardware filter specification
+ * @EFX_FILTER_PRI_HINT: Performance hint
+ * @EFX_FILTER_PRI_MANUAL: Manually configured filter
+ * @EFX_FILTER_PRI_REQUIRED: Required for correct behaviour
+ */
+enum efx_filter_priority {
+	EFX_FILTER_PRI_HINT = 0,
+	EFX_FILTER_PRI_MANUAL,
+	EFX_FILTER_PRI_REQUIRED,
+};
+
+/**
+ * enum efx_filter_flags - flags for hardware filter specifications
+ * @EFX_FILTER_FLAG_RX_RSS: Use RSS to spread across multiple queues.
+ *	By default, matching packets will be delivered only to the
+ *	specified queue. If this flag is set, they will be delivered
+ *	to a range of queues offset from the specified queue number
+ *	according to the indirection table.
+ * @EFX_FILTER_FLAG_RX_SCATTER: Enable DMA scatter on the receiving
+ *	queue.
+ * @EFX_FILTER_FLAG_RX_OVERRIDE_IP: Enables a MAC filter to override
+ *	any IP filter that matches the same packet.  By default, IP
+ *	filters take precedence.
+ *
+ * Currently, no flags are defined for TX filters.
+ */
+enum efx_filter_flags {
+	EFX_FILTER_FLAG_RX_RSS = 0x01,
+	EFX_FILTER_FLAG_RX_SCATTER = 0x02,
+	EFX_FILTER_FLAG_RX_OVERRIDE_IP = 0x04,
+};
+
+/**
+ * struct efx_filter_spec - specification for a hardware filter
+ * @type: Type of match to be performed, from &enum efx_filter_type
+ * @priority: Priority of the filter, from &enum efx_filter_priority
+ * @flags: Miscellaneous flags, from &enum efx_filter_flags
+ * @dmaq_id: Source/target queue index
+ * @data: Match data (type-dependent)
+ *
+ * Use the efx_filter_set_*() functions to initialise the @type and
+ * @data fields.
+ */
+struct efx_filter_spec {
+	u8	type:4;
+	u8	priority:4;
+	u8	flags;
+	u16	dmaq_id;
+	u32	data[3];
+};
+
+/**
+ * efx_filter_set_rx_tcp_full - specify RX filter with TCP/IPv4 full match
+ * @spec: Specification to initialise
+ * @shost: Source host address (host byte order)
+ * @sport: Source port (host byte order)
+ * @dhost: Destination host address (host byte order)
+ * @dport: Destination port (host byte order)
+ */
+static inline void
+efx_filter_set_rx_tcp_full(struct efx_filter_spec *spec,
+			   u32 shost, u16 sport, u32 dhost, u16 dport)
+{
+	spec->type = EFX_FILTER_RX_TCP_FULL;
+	spec->data[0] = sport | shost << 16;
+	spec->data[1] = dport << 16 | shost >> 16;
+	spec->data[2] = dhost;
+}
+
+/**
+ * efx_filter_set_rx_tcp_wild - specify RX filter with TCP/IPv4 wildcard match
+ * @spec: Specification to initialise
+ * @dhost: Destination host address (host byte order)
+ * @dport: Destination port (host byte order)
+ */
+static inline void
+efx_filter_set_rx_tcp_wild(struct efx_filter_spec *spec, u32 dhost, u16 dport)
+{
+	spec->type = EFX_FILTER_RX_TCP_WILD;
+	spec->data[0] = 0;
+	spec->data[1] = dport << 16;
+	spec->data[2] = dhost;
+}
+
+/**
+ * efx_filter_set_rx_udp_full - specify RX filter with UDP/IPv4 full match
+ * @spec: Specification to initialise
+ * @shost: Source host address (host byte order)
+ * @sport: Source port (host byte order)
+ * @dhost: Destination host address (host byte order)
+ * @dport: Destination port (host byte order)
+ */
+static inline void
+efx_filter_set_rx_udp_full(struct efx_filter_spec *spec,
+			   u32 shost, u16 sport, u32 dhost, u16 dport)
+{
+	spec->type = EFX_FILTER_RX_UDP_FULL;
+	spec->data[0] = sport | shost << 16;
+	spec->data[1] = dport << 16 | shost >> 16;
+	spec->data[2] = dhost;
+}
+
+/**
+ * efx_filter_set_rx_udp_wild - specify RX filter with UDP/IPv4 wildcard match
+ * @spec: Specification to initialise
+ * @dhost: Destination host address (host byte order)
+ * @dport: Destination port (host byte order)
+ */
+static inline void
+efx_filter_set_rx_udp_wild(struct efx_filter_spec *spec, u32 dhost, u16 dport)
+{
+	spec->type = EFX_FILTER_RX_UDP_WILD;
+	spec->data[0] = dport;
+	spec->data[1] = 0;
+	spec->data[2] = dhost;
+}
+
+/**
+ * efx_filter_set_rx_mac_full - specify RX filter with MAC full match
+ * @spec: Specification to initialise
+ * @vid: VLAN ID
+ * @addr: Destination MAC address
+ */
+static inline void efx_filter_set_rx_mac_full(struct efx_filter_spec *spec,
+					      u16 vid, const u8 *addr)
+{
+	spec->type = EFX_FILTER_RX_MAC_FULL;
+	spec->data[0] = vid;
+	spec->data[1] = addr[2] << 24 | addr[3] << 16 | addr[4] << 8 | addr[5];
+	spec->data[2] = addr[0] << 8 | addr[1];
+}
+
+/**
+ * efx_filter_set_rx_mac_full - specify RX filter with MAC wildcard match
+ * @spec: Specification to initialise
+ * @addr: Destination MAC address
+ */
+static inline void efx_filter_set_rx_mac_wild(struct efx_filter_spec *spec,
+					      const u8 *addr)
+{
+	spec->type = EFX_FILTER_RX_MAC_WILD;
+	spec->data[0] = 0;
+	spec->data[1] = addr[2] << 24 | addr[3] << 16 | addr[4] << 8 | addr[5];
+	spec->data[2] = addr[0] << 8 | addr[1];
+}
+
+#endif /* EFX_FILTER_H */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 152342d..ea6691c 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -619,6 +619,8 @@ union efx_multicast_hash {
 	efx_oword_t oword[EFX_MCAST_HASH_ENTRIES / sizeof(efx_oword_t) / 8];
 };
 
+struct efx_filter_state;
+
 /**
  * struct efx_nic - an Efx NIC
  * @name: Device name (net device name or bus id before net device registered)
@@ -799,6 +801,8 @@ struct efx_nic {
 	u64 loopback_modes;
 
 	void *loopback_selftest;
+
+	struct efx_filter_state *filter_state;
 };
 
 static inline int efx_dev_registered(struct efx_nic *efx)
diff --git a/drivers/net/sfc/regs.h b/drivers/net/sfc/regs.h
index 18a3be4..96430ed 100644
--- a/drivers/net/sfc/regs.h
+++ b/drivers/net/sfc/regs.h
@@ -2893,6 +2893,20 @@
 #define	FRF_AB_XX_FORCE_SIG_WIDTH 8
 #define	FFE_AB_XX_FORCE_SIG_ALL_LANES 0xff
 
+/* RX_MAC_FILTER_TBL0 */
+/* RMFT_DEST_MAC is wider than 32 bits */
+#define FRF_CZ_RMFT_DEST_MAC_LO_LBN 12
+#define FRF_CZ_RMFT_DEST_MAC_LO_WIDTH 32
+#define FRF_CZ_RMFT_DEST_MAC_HI_LBN 44
+#define FRF_CZ_RMFT_DEST_MAC_HI_WIDTH 16
+
+/* TX_MAC_FILTER_TBL0 */
+/* TMFT_SRC_MAC is wider than 32 bits */
+#define FRF_CZ_TMFT_SRC_MAC_LO_LBN 12
+#define FRF_CZ_TMFT_SRC_MAC_LO_WIDTH 32
+#define FRF_CZ_TMFT_SRC_MAC_HI_LBN 44
+#define FRF_CZ_TMFT_SRC_MAC_HI_WIDTH 16
+
 /* DRIVER_EV */
 /* Sub-fields of an RX flush completion event */
 #define FSF_AZ_DRIVER_EV_RX_FLUSH_FAIL_LBN 12
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

