From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 6/8] New driver "sfc" for Solarstorm SFC4000 controller (try #8)
Date: Wed, 12 Mar 2008 01:25:39 +0000
Message-ID: <20080312012538.GH24160@solarflare.com>
References: <20080312012102.GB24160@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers@solarflare.com, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:54836 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752511AbYCLCWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2008 22:22:51 -0400
Content-Disposition: inline
In-Reply-To: <20080312012102.GB24160@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
new file mode 100644
index 0000000..999bff4
--- /dev/null
+++ b/drivers/net/sfc/ethtool.c
@@ -0,0 +1,463 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/rtnetlink.h>
+#include <asm/uaccess.h>
+#include "net_driver.h"
+#include "efx.h"
+#include "ethtool.h"
+#include "falcon.h"
+#include "gmii.h"
+#include "mac.h"
+
+static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable);
+
+struct ethtool_string {
+	char name[ETH_GSTRING_LEN];
+};
+
+struct efx_ethtool_stat {
+	const char *name;
+	enum {
+		EFX_ETHTOOL_STAT_SOURCE_mac_stats,
+		EFX_ETHTOOL_STAT_SOURCE_nic,
+		EFX_ETHTOOL_STAT_SOURCE_channel
+	} source;
+	unsigned offset;
+	u64(*get_stat) (void *field); /* Reader function */
+};
+
+/* Initialiser for a struct #efx_ethtool_stat with type-checking */
+#define EFX_ETHTOOL_STAT(stat_name, source_name, field, field_type, \
+				get_stat_function) {			\
+	.name = #stat_name,						\
+	.source = EFX_ETHTOOL_STAT_SOURCE_##source_name,		\
+	.offset = ((((field_type *) 0) ==				\
+		      &((struct efx_##source_name *)0)->field) ?	\
+		    offsetof(struct efx_##source_name, field) :		\
+		    offsetof(struct efx_##source_name, field)),		\
+	.get_stat = get_stat_function,					\
+}
+
+static u64 efx_get_uint_stat(void *field)
+{
+	return *(unsigned int *)field;
+}
+
+static u64 efx_get_ulong_stat(void *field)
+{
+	return *(unsigned long *)field;
+}
+
+static u64 efx_get_u64_stat(void *field)
+{
+	return *(u64 *) field;
+}
+
+static u64 efx_get_atomic_stat(void *field)
+{
+	return atomic_read((atomic_t *) field);
+}
+
+#define EFX_ETHTOOL_ULONG_MAC_STAT(field)			\
+	EFX_ETHTOOL_STAT(field, mac_stats, field, 		\
+			  unsigned long, efx_get_ulong_stat)
+
+#define EFX_ETHTOOL_U64_MAC_STAT(field)				\
+	EFX_ETHTOOL_STAT(field, mac_stats, field, 		\
+			  u64, efx_get_u64_stat)
+
+#define EFX_ETHTOOL_UINT_NIC_STAT(name)				\
+	EFX_ETHTOOL_STAT(name, nic, n_##name,			\
+			 unsigned int, efx_get_uint_stat)
+
+#define EFX_ETHTOOL_ATOMIC_NIC_ERROR_STAT(field)		\
+	EFX_ETHTOOL_STAT(field, nic, field,			\
+			 atomic_t, efx_get_atomic_stat)
+
+#define EFX_ETHTOOL_UINT_CHANNEL_STAT(field)			\
+	EFX_ETHTOOL_STAT(field, channel, n_##field,		\
+			 unsigned int, efx_get_uint_stat)
+
+static struct efx_ethtool_stat efx_ethtool_stats[] = {
+	EFX_ETHTOOL_U64_MAC_STAT(tx_bytes),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_good_bytes),
+	EFX_ETHTOOL_U64_MAC_STAT(tx_bad_bytes),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_packets),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_bad),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_pause),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_control),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_unicast),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_multicast),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_broadcast),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_lt64),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_64),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_65_to_127),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_128_to_255),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_256_to_511),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_512_to_1023),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_1024_to_15xx),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_15xx_to_jumbo),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_gtjumbo),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_collision),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_single_collision),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_multiple_collision),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_excessive_collision),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_deferred),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_late_collision),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_excessive_deferred),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_non_tcpudp),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_mac_src_error),
+	EFX_ETHTOOL_ULONG_MAC_STAT(tx_ip_src_error),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_bytes),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_good_bytes),
+	EFX_ETHTOOL_U64_MAC_STAT(rx_bad_bytes),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_packets),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_good),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_bad),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_pause),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_control),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_unicast),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_multicast),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_broadcast),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_lt64),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_64),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_65_to_127),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_128_to_255),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_256_to_511),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_512_to_1023),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_1024_to_15xx),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_15xx_to_jumbo),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_gtjumbo),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_bad_lt64),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_bad_64_to_15xx),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_bad_15xx_to_jumbo),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_bad_gtjumbo),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_overflow),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_missed),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_false_carrier),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_symbol_error),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_align_error),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_length_error),
+	EFX_ETHTOOL_ULONG_MAC_STAT(rx_internal_error),
+	EFX_ETHTOOL_UINT_NIC_STAT(rx_nodesc_drop_cnt),
+	EFX_ETHTOOL_ATOMIC_NIC_ERROR_STAT(rx_reset),
+	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_tobe_disc),
+	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_ip_hdr_chksum_err),
+	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_tcp_udp_chksum_err),
+	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_frm_trunc),
+};
+
+/* Number of ethtool statistics */
+#define EFX_ETHTOOL_NUM_STATS ARRAY_SIZE(efx_ethtool_stats)
+
+/**************************************************************************
+ *
+ * Ethtool operations
+ *
+ **************************************************************************
+ */
+
+/* Identify device by flashing LEDs */
+static int efx_ethtool_phys_id(struct net_device *net_dev, u32 seconds)
+{
+	struct efx_nic *efx = net_dev->priv;
+
+	efx->board_info.blink(efx, 1);
+	schedule_timeout_interruptible(seconds * HZ);
+	efx->board_info.blink(efx, 0);
+	return 0;
+}
+
+/* This must be called with rtnl_lock held. */
+int efx_ethtool_get_settings(struct net_device *net_dev,
+			     struct ethtool_cmd *ecmd)
+{
+	struct efx_nic *efx = net_dev->priv;
+	int rc;
+
+	mutex_lock(&efx->mac_lock);
+	rc = falcon_xmac_get_settings(efx, ecmd);
+	mutex_unlock(&efx->mac_lock);
+
+	return rc;
+}
+
+/* This must be called with rtnl_lock held. */
+int efx_ethtool_set_settings(struct net_device *net_dev,
+			     struct ethtool_cmd *ecmd)
+{
+	struct efx_nic *efx = net_dev->priv;
+	int rc;
+
+	mutex_lock(&efx->mac_lock);
+	rc = falcon_xmac_set_settings(efx, ecmd);
+	mutex_unlock(&efx->mac_lock);
+	if (!rc)
+		efx_reconfigure_port(efx);
+
+	return rc;
+}
+
+static void efx_ethtool_get_drvinfo(struct net_device *net_dev,
+				    struct ethtool_drvinfo *info)
+{
+	struct efx_nic *efx = net_dev->priv;
+
+	strlcpy(info->driver, EFX_DRIVER_NAME, sizeof(info->driver));
+	strlcpy(info->version, EFX_DRIVER_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(efx->pci_dev), sizeof(info->bus_info));
+}
+
+static int efx_ethtool_get_stats_count(struct net_device *net_dev)
+{
+	return EFX_ETHTOOL_NUM_STATS;
+}
+
+static void efx_ethtool_get_strings(struct net_device *net_dev,
+				    u32 string_set, u8 *strings)
+{
+	struct ethtool_string *ethtool_strings =
+		(struct ethtool_string *)strings;
+	int i;
+
+	if (string_set == ETH_SS_STATS)
+		for (i = 0; i < EFX_ETHTOOL_NUM_STATS; i++)
+			strncpy(ethtool_strings[i].name,
+				efx_ethtool_stats[i].name,
+				sizeof(ethtool_strings[i].name));
+}
+
+static void efx_ethtool_get_stats(struct net_device *net_dev,
+				  struct ethtool_stats *stats
+				  __attribute__ ((unused)), u64 *data)
+{
+	unsigned long flags __attribute__ ((unused));
+	struct efx_nic *efx = net_dev->priv;
+	struct efx_mac_stats *mac_stats = &efx->mac_stats;
+	struct efx_ethtool_stat *stat;
+	struct efx_channel *channel;
+	int i;
+
+	EFX_BUG_ON_PARANOID(stats->n_stats != EFX_ETHTOOL_NUM_STATS);
+
+	/* Update MAC and NIC statistics */
+	net_dev->get_stats(net_dev);
+	falcon_update_nic_stats(efx);
+
+	/* Fill detailed statistics buffer */
+	for (i = 0; i < EFX_ETHTOOL_NUM_STATS; i++) {
+		stat = &efx_ethtool_stats[i];
+		switch (stat->source) {
+		case EFX_ETHTOOL_STAT_SOURCE_mac_stats:
+			data[i] = stat->get_stat((void *)mac_stats +
+						 stat->offset);
+			break;
+		case EFX_ETHTOOL_STAT_SOURCE_nic:
+			data[i] = stat->get_stat((void *)efx + stat->offset);
+			break;
+		case EFX_ETHTOOL_STAT_SOURCE_channel:
+			data[i] = 0;
+			efx_for_each_channel(channel, efx)
+				data[i] += stat->get_stat((void *)channel +
+							  stat->offset);
+			break;
+		}
+	}
+}
+
+static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable)
+{
+	struct efx_nic *efx = net_dev->priv;
+	int rc;
+
+	rc = ethtool_op_set_tx_csum(net_dev, enable);
+	if (rc)
+		return rc;
+
+	efx_flush_queues(efx);
+
+	return 0;
+}
+
+static int efx_ethtool_set_rx_csum(struct net_device *net_dev, u32 enable)
+{
+	struct efx_nic *efx = net_dev->priv;
+
+	/* No way to stop the hardware doing the checks; we just
+	 * ignore the result.
+	 */
+	efx->rx_checksum_enabled = (enable ? 1 : 0);
+
+	return 0;
+}
+
+static u32 efx_ethtool_get_rx_csum(struct net_device *net_dev)
+{
+	struct efx_nic *efx = net_dev->priv;
+
+	return efx->rx_checksum_enabled;
+}
+
+/* Restart autonegotiation */
+static int efx_ethtool_nway_reset(struct net_device *net_dev)
+{
+	struct efx_nic *efx = net_dev->priv;
+
+	return mii_nway_restart(&efx->mii);
+}
+
+static u32 efx_ethtool_get_link(struct net_device *net_dev)
+{
+	struct efx_nic *efx = net_dev->priv;
+
+	return efx->link_up;
+}
+
+static int efx_ethtool_get_coalesce(struct net_device *net_dev,
+				    struct ethtool_coalesce *coalesce)
+{
+	struct efx_nic *efx = net_dev->priv;
+	struct efx_tx_queue *tx_queue;
+	struct efx_rx_queue *rx_queue;
+	struct efx_channel *channel;
+
+	memset(coalesce, 0, sizeof(*coalesce));
+
+	/* Find lowest IRQ moderation across all used TX queues */
+	coalesce->tx_coalesce_usecs_irq = ~((u32) 0);
+	efx_for_each_tx_queue(tx_queue, efx) {
+		channel = tx_queue->channel;
+		if (channel->irq_moderation < coalesce->tx_coalesce_usecs_irq) {
+			if (channel->used_flags != EFX_USED_BY_RX_TX)
+				coalesce->tx_coalesce_usecs_irq =
+					channel->irq_moderation;
+			else
+				coalesce->tx_coalesce_usecs_irq = 0;
+		}
+	}
+
+	/* Find lowest IRQ moderation across all used RX queues */
+	coalesce->rx_coalesce_usecs_irq = ~((u32) 0);
+	efx_for_each_rx_queue(rx_queue, efx) {
+		channel = rx_queue->channel;
+		if (channel->irq_moderation < coalesce->rx_coalesce_usecs_irq)
+			coalesce->rx_coalesce_usecs_irq =
+				channel->irq_moderation;
+	}
+
+	return 0;
+}
+
+/* Set coalescing parameters
+ * The difficulties occur for shared channels
+ */
+static int efx_ethtool_set_coalesce(struct net_device *net_dev,
+				    struct ethtool_coalesce *coalesce)
+{
+	struct efx_nic *efx = net_dev->priv;
+	struct efx_channel *channel;
+	struct efx_tx_queue *tx_queue;
+	unsigned tx_usecs, rx_usecs;
+
+	if (coalesce->use_adaptive_rx_coalesce ||
+	    coalesce->use_adaptive_tx_coalesce)
+		return -EOPNOTSUPP;
+
+	if (coalesce->rx_coalesce_usecs || coalesce->tx_coalesce_usecs) {
+		EFX_ERR(efx, "invalid coalescing setting. "
+			"Only rx/tx_coalesce_usecs_irq are supported\n");
+		return -EOPNOTSUPP;
+	}
+
+	rx_usecs = coalesce->rx_coalesce_usecs_irq;
+	tx_usecs = coalesce->tx_coalesce_usecs_irq;
+
+	/* If the channel is shared only allow RX parameters to be set */
+	efx_for_each_tx_queue(tx_queue, efx) {
+		if ((tx_queue->channel->used_flags == EFX_USED_BY_RX_TX) &&
+		    tx_usecs) {
+			EFX_ERR(efx, "Channel is shared. "
+				"Only RX coalescing may be set\n");
+			return -EOPNOTSUPP;
+		}
+	}
+
+	efx_init_irq_moderation(efx, tx_usecs, rx_usecs);
+
+	/* Reset channel to pick up new moderation value.  Note that
+	 * this may change the value of the irq_moderation field
+	 * (e.g. to allow for hardware timer granularity).
+	 */
+	efx_for_each_channel(channel, efx)
+		falcon_set_int_moderation(channel);
+
+	return 0;
+}
+
+static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
+				      struct ethtool_pauseparam *pause)
+{
+	struct efx_nic *efx = net_dev->priv;
+	enum efx_fc_type flow_control = efx->flow_control;
+	int rc;
+
+	flow_control &= ~(EFX_FC_RX | EFX_FC_TX | EFX_FC_AUTO);
+	flow_control |= pause->rx_pause ? EFX_FC_RX : 0;
+	flow_control |= pause->tx_pause ? EFX_FC_TX : 0;
+	flow_control |= pause->autoneg ? EFX_FC_AUTO : 0;
+
+	/* Try to push the pause parameters */
+	mutex_lock(&efx->mac_lock);
+	rc = falcon_xmac_set_pause(efx, flow_control);
+	mutex_unlock(&efx->mac_lock);
+
+	if (!rc)
+		efx_reconfigure_port(efx);
+
+	return 0;
+}
+
+static void efx_ethtool_get_pauseparam(struct net_device *net_dev,
+				       struct ethtool_pauseparam *pause)
+{
+	struct efx_nic *efx = net_dev->priv;
+
+	pause->rx_pause = (efx->flow_control & EFX_FC_RX) ? 1 : 0;
+	pause->tx_pause = (efx->flow_control & EFX_FC_TX) ? 1 : 0;
+	pause->autoneg = (efx->flow_control & EFX_FC_AUTO) ? 1 : 0;
+}
+
+
+struct ethtool_ops efx_ethtool_ops = {
+	.get_settings		= efx_ethtool_get_settings,
+	.set_settings		= efx_ethtool_set_settings,
+	.get_drvinfo		= efx_ethtool_get_drvinfo,
+	.nway_reset		= efx_ethtool_nway_reset,
+	.get_link		= efx_ethtool_get_link,
+	.get_coalesce		= efx_ethtool_get_coalesce,
+	.set_coalesce		= efx_ethtool_set_coalesce,
+	.get_pauseparam         = efx_ethtool_get_pauseparam,
+	.set_pauseparam         = efx_ethtool_set_pauseparam,
+	.get_rx_csum		= efx_ethtool_get_rx_csum,
+	.set_rx_csum		= efx_ethtool_set_rx_csum,
+	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.set_tx_csum		= efx_ethtool_set_tx_csum,
+	.get_sg			= ethtool_op_get_sg,
+	.set_sg			= ethtool_op_set_sg,
+	.get_flags		= ethtool_op_get_flags,
+	.set_flags		= ethtool_op_set_flags,
+	.get_strings		= efx_ethtool_get_strings,
+	.phys_id		= efx_ethtool_phys_id,
+	.get_stats_count	= efx_ethtool_get_stats_count,
+	.get_ethtool_stats	= efx_ethtool_get_stats,
+};
diff --git a/drivers/net/sfc/ethtool.h b/drivers/net/sfc/ethtool.h
new file mode 100644
index 0000000..3628e43
--- /dev/null
+++ b/drivers/net/sfc/ethtool.h
@@ -0,0 +1,27 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005 Fen Systems Ltd.
+ * Copyright 2006 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_ETHTOOL_H
+#define EFX_ETHTOOL_H
+
+#include "net_driver.h"
+
+/*
+ * Ethtool support
+ */
+
+extern int efx_ethtool_get_settings(struct net_device *net_dev,
+				    struct ethtool_cmd *ecmd);
+extern int efx_ethtool_set_settings(struct net_device *net_dev,
+				    struct ethtool_cmd *ecmd);
+
+extern struct ethtool_ops efx_ethtool_ops;
+
+#endif /* EFX_ETHTOOL_H */
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
new file mode 100644
index 0000000..b3c0916
--- /dev/null
+++ b/drivers/net/sfc/mdio_10g.c
@@ -0,0 +1,282 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2006-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+/*
+ * Useful functions for working with MDIO clause 45 PHYs
+ */
+#include <linux/types.h>
+#include <linux/ethtool.h>
+#include <linux/delay.h>
+#include "net_driver.h"
+#include "mdio_10g.h"
+#include "boards.h"
+
+int mdio_clause45_reset_mmd(struct efx_nic *port, int mmd,
+			    int spins, int spintime)
+{
+	u32 ctrl;
+	int phy_id = port->mii.phy_id;
+
+	/* Catch callers passing values in the wrong units (or just silly) */
+	EFX_BUG_ON_PARANOID(spins * spintime >= 5000);
+
+	mdio_clause45_write(port, phy_id, mmd, MDIO_MMDREG_CTRL1,
+			    (1 << MDIO_MMDREG_CTRL1_RESET_LBN));
+	/* Wait for the reset bit to clear. */
+	do {
+		msleep(spintime);
+		ctrl = mdio_clause45_read(port, phy_id, mmd, MDIO_MMDREG_CTRL1);
+		spins--;
+
+	} while (spins && (ctrl & (1 << MDIO_MMDREG_CTRL1_RESET_LBN)));
+
+	return spins ? spins : -ETIMEDOUT;
+}
+
+static int mdio_clause45_check_mmd(struct efx_nic *efx, int mmd,
+				   int fault_fatal)
+{
+	int status;
+	int phy_id = efx->mii.phy_id;
+
+	/* Read MMD STATUS2 to check it is responding. */
+	status = mdio_clause45_read(efx, phy_id, mmd, MDIO_MMDREG_STAT2);
+	if (((status >> MDIO_MMDREG_STAT2_PRESENT_LBN) &
+	     ((1 << MDIO_MMDREG_STAT2_PRESENT_WIDTH) - 1)) !=
+	    MDIO_MMDREG_STAT2_PRESENT_VAL) {
+		EFX_ERR(efx, "PHY MMD %d not responding.\n", mmd);
+		return -EIO;
+	}
+
+	/* Read MMD STATUS 1 to check for fault. */
+	status = mdio_clause45_read(efx, phy_id, mmd, MDIO_MMDREG_STAT1);
+	if ((status & (1 << MDIO_MMDREG_STAT1_FAULT_LBN)) != 0) {
+		if (fault_fatal) {
+			EFX_ERR(efx, "PHY MMD %d reporting fatal"
+				" fault: status %x\n", mmd, status);
+			return -EIO;
+		} else {
+			EFX_LOG(efx, "PHY MMD %d reporting status"
+				" %x (expected)\n", mmd, status);
+		}
+	}
+	return 0;
+}
+
+/* This ought to be ridiculous overkill. We expect it to fail rarely */
+#define MDIO45_RESET_TIME	HZ
+#define MDIO45_RESET_ITERS	(100)
+
+int mdio_clause45_wait_reset_mmds(struct efx_nic *efx,
+				  unsigned int mmd_mask)
+{
+	const int spintime = MDIO45_RESET_TIME / MDIO45_RESET_ITERS;
+	int tries = MDIO45_RESET_ITERS;
+	int rc = 0;
+	int in_reset;
+
+	while (tries) {
+		int mask = mmd_mask;
+		int mmd = 0;
+		int stat;
+		in_reset = 0;
+		while (mask) {
+			if (mask & 1) {
+				stat = mdio_clause45_read(efx,
+							  efx->mii.phy_id,
+							  mmd,
+							  MDIO_MMDREG_CTRL1);
+				if (stat < 0) {
+					EFX_ERR(efx, "failed to read status of"
+						" MMD %d\n", mmd);
+					return -EIO;
+				}
+				if (stat & (1 << MDIO_MMDREG_CTRL1_RESET_LBN))
+					in_reset |= (1 << mmd);
+			}
+			mask = mask >> 1;
+			mmd++;
+		}
+		if (!in_reset)
+			break;
+		tries--;
+		msleep(spintime);
+	}
+	if (in_reset != 0) {
+		EFX_ERR(efx, "not all MMDs came out of reset in time."
+			" MMDs still in reset: %x\n", in_reset);
+		rc = -ETIMEDOUT;
+	}
+	return rc;
+}
+
+int mdio_clause45_check_mmds(struct efx_nic *efx,
+			     unsigned int mmd_mask, unsigned int fatal_mask)
+{
+	int devices, mmd = 0;
+	int probe_mmd;
+
+	/* Historically we have probed the PHYXS to find out what devices are
+	 * present,but that doesn't work so well if the PHYXS isn't expected
+	 * to exist, if so just find the first item in the list supplied. */
+	probe_mmd = (mmd_mask & MDIO_MMDREG_DEVS0_PHYXS) ? MDIO_MMD_PHYXS :
+	    __ffs(mmd_mask);
+	devices = mdio_clause45_read(efx, efx->mii.phy_id,
+				     probe_mmd, MDIO_MMDREG_DEVS0);
+
+	/* Check all the expected MMDs are present */
+	if (devices < 0) {
+		EFX_ERR(efx, "failed to read devices present\n");
+		return -EIO;
+	}
+	if ((devices & mmd_mask) != mmd_mask) {
+		EFX_ERR(efx, "required MMDs not present: got %x, "
+			"wanted %x\n", devices, mmd_mask);
+		return -ENODEV;
+	}
+	EFX_TRACE(efx, "Devices present: %x\n", devices);
+
+	/* Check all required MMDs are responding and happy. */
+	while (mmd_mask) {
+		if (mmd_mask & 1) {
+			int fault_fatal = fatal_mask & 1;
+			if (mdio_clause45_check_mmd(efx, mmd, fault_fatal))
+				return -EIO;
+		}
+		mmd_mask = mmd_mask >> 1;
+		fatal_mask = fatal_mask >> 1;
+		mmd++;
+	}
+
+	return 0;
+}
+
+int mdio_clause45_links_ok(struct efx_nic *efx, unsigned int mmd_mask)
+{
+	int phy_id = efx->mii.phy_id;
+	int status;
+	int ok = 1;
+	int mmd = 0;
+	int good;
+
+	while (mmd_mask) {
+		if (mmd_mask & 1) {
+			/* Double reads because link state is latched, and a
+			 * read moves the current state into the register */
+			status = mdio_clause45_read(efx, phy_id,
+						    mmd, MDIO_MMDREG_STAT1);
+			status = mdio_clause45_read(efx, phy_id,
+						    mmd, MDIO_MMDREG_STAT1);
+
+			good = status & (1 << MDIO_MMDREG_STAT1_LINK_LBN);
+			ok = ok && good;
+		}
+		mmd_mask = (mmd_mask >> 1);
+		mmd++;
+	}
+	return ok;
+}
+
+/**
+ * mdio_clause45_get_settings - Read (some of) the PHY settings over MDIO.
+ * @efx:		Efx NIC
+ * @ecmd: 		Buffer for settings
+ *
+ * On return the 'port', 'speed', 'supported' and 'advertising' fields of
+ * ecmd have been filled out based on the PMA type.
+ */
+void mdio_clause45_get_settings(struct efx_nic *efx,
+				struct ethtool_cmd *ecmd)
+{
+	int pma_type;
+
+	/* If no PMA is present we are presumably talking something XAUI-ish
+	 * like CX4. Which we report as FIBRE (see below) */
+	if ((efx->phy_op->mmds & DEV_PRESENT_BIT(MDIO_MMD_PMAPMD)) == 0) {
+		ecmd->speed = SPEED_10000;
+		ecmd->port = PORT_FIBRE;
+		ecmd->supported = SUPPORTED_FIBRE;
+		ecmd->advertising = ADVERTISED_FIBRE;
+		return;
+	}
+
+	pma_type = mdio_clause45_read(efx, efx->mii.phy_id,
+				      MDIO_MMD_PMAPMD, MDIO_MMDREG_CTRL2);
+	pma_type &= MDIO_PMAPMD_CTRL2_TYPE_MASK;
+
+	switch (pma_type) {
+		/* We represent CX4 as fibre in the absence of anything
+		   better. */
+	case MDIO_PMAPMD_CTRL2_10G_CX4:
+		ecmd->speed = SPEED_10000;
+		ecmd->port = PORT_FIBRE;
+		ecmd->supported = SUPPORTED_FIBRE;
+		ecmd->advertising = ADVERTISED_FIBRE;
+		break;
+		/* 10G Base-T */
+	case MDIO_PMAPMD_CTRL2_10G_BT:
+		ecmd->speed = SPEED_10000;
+		ecmd->port = PORT_TP;
+		ecmd->supported = SUPPORTED_TP | SUPPORTED_10000baseT_Full;
+		ecmd->advertising = (ADVERTISED_FIBRE
+				     | ADVERTISED_10000baseT_Full);
+		break;
+	case MDIO_PMAPMD_CTRL2_1G_BT:
+		ecmd->speed = SPEED_1000;
+		ecmd->port = PORT_TP;
+		ecmd->supported = SUPPORTED_TP | SUPPORTED_1000baseT_Full;
+		ecmd->advertising = (ADVERTISED_FIBRE
+				     | ADVERTISED_1000baseT_Full);
+		break;
+	case MDIO_PMAPMD_CTRL2_100_BT:
+		ecmd->speed = SPEED_100;
+		ecmd->port = PORT_TP;
+		ecmd->supported = SUPPORTED_TP | SUPPORTED_100baseT_Full;
+		ecmd->advertising = (ADVERTISED_FIBRE
+				     | ADVERTISED_100baseT_Full);
+		break;
+	case MDIO_PMAPMD_CTRL2_10_BT:
+		ecmd->speed = SPEED_10;
+		ecmd->port = PORT_TP;
+		ecmd->supported = SUPPORTED_TP | SUPPORTED_10baseT_Full;
+		ecmd->advertising = ADVERTISED_FIBRE | ADVERTISED_10baseT_Full;
+		break;
+	/* All the other defined modes are flavours of
+	 * 10G optical */
+	default:
+		ecmd->speed = SPEED_10000;
+		ecmd->port = PORT_FIBRE;
+		ecmd->supported = SUPPORTED_FIBRE;
+		ecmd->advertising = ADVERTISED_FIBRE;
+		break;
+	}
+}
+
+/**
+ * mdio_clause45_set_settings - Set (some of) the PHY settings over MDIO.
+ * @efx:		Efx NIC
+ * @ecmd: 		New settings
+ *
+ * Currently this just enforces that we are _not_ changing the
+ * 'port', 'speed', 'supported' or 'advertising' settings as these
+ * cannot be changed on any currently supported PHY.
+ */
+int mdio_clause45_set_settings(struct efx_nic *efx,
+			       struct ethtool_cmd *ecmd)
+{
+	struct ethtool_cmd tmpcmd;
+	mdio_clause45_get_settings(efx, &tmpcmd);
+	/* None of the current PHYs support more than one mode
+	 * of operation (and only 10GBT ever will), so keep things
+	 * simple for now */
+	if ((ecmd->speed == tmpcmd.speed) && (ecmd->port == tmpcmd.port) &&
+	    (ecmd->supported == tmpcmd.supported) &&
+	    (ecmd->advertising == tmpcmd.advertising))
+		return 0;
+	return -EOPNOTSUPP;
+}
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
new file mode 100644
index 0000000..2214b6d
--- /dev/null
+++ b/drivers/net/sfc/mdio_10g.h
@@ -0,0 +1,232 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2006-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_MDIO_10G_H
+#define EFX_MDIO_10G_H
+
+/*
+ * Definitions needed for doing 10G MDIO as specified in clause 45
+ * MDIO, which do not appear in Linux yet. Also some helper functions.
+ */
+
+#include "efx.h"
+#include "boards.h"
+
+/* Numbering of the MDIO Manageable Devices (MMDs) */
+/* Physical Medium Attachment/ Physical Medium Dependent sublayer */
+#define MDIO_MMD_PMAPMD	(1)
+/* WAN Interface Sublayer */
+#define MDIO_MMD_WIS	(2)
+/* Physical Coding Sublayer */
+#define MDIO_MMD_PCS	(3)
+/* PHY Extender Sublayer */
+#define MDIO_MMD_PHYXS	(4)
+/* Extender Sublayer */
+#define MDIO_MMD_DTEXS	(5)
+/* Transmission convergence */
+#define MDIO_MMD_TC	(6)
+/* Auto negotiation */
+#define MDIO_MMD_AN	(7)
+
+/* Generic register locations */
+#define MDIO_MMDREG_CTRL1	(0)
+#define MDIO_MMDREG_STAT1	(1)
+#define MDIO_MMDREG_IDHI	(2)
+#define MDIO_MMDREG_IDLOW	(3)
+#define MDIO_MMDREG_SPEED	(4)
+#define MDIO_MMDREG_DEVS0	(5)
+#define MDIO_MMDREG_DEVS1	(6)
+#define MDIO_MMDREG_CTRL2	(7)
+#define MDIO_MMDREG_STAT2	(8)
+
+/* Bits in MMDREG_CTRL1 */
+/* Reset */
+#define MDIO_MMDREG_CTRL1_RESET_LBN	(15)
+#define MDIO_MMDREG_CTRL1_RESET_WIDTH	(1)
+
+/* Bits in MMDREG_STAT1 */
+#define MDIO_MMDREG_STAT1_FAULT_LBN	(7)
+#define MDIO_MMDREG_STAT1_FAULT_WIDTH	(1)
+/* Link state */
+#define MDIO_MMDREG_STAT1_LINK_LBN	(2)
+#define MDIO_MMDREG_STAT1_LINK_WIDTH	(1)
+
+/* Bits in ID reg */
+#define MDIO_ID_REV(_id32)	(_id32 & 0xf)
+#define MDIO_ID_MODEL(_id32)	((_id32 >> 4) & 0x3f)
+#define MDIO_ID_OUI(_id32)	(_id32 >> 10)
+
+/* Bits in MMDREG_DEVS0. Someone thoughtfully layed things out
+ * so the 'bit present' bit number of an MMD is the number of
+ * that MMD */
+#define DEV_PRESENT_BIT(_b) (1 << _b)
+
+#define MDIO_MMDREG_DEVS0_PHYXS	 DEV_PRESENT_BIT(MDIO_MMD_PHYXS)
+#define MDIO_MMDREG_DEVS0_PCS	 DEV_PRESENT_BIT(MDIO_MMD_PCS)
+#define MDIO_MMDREG_DEVS0_PMAPMD DEV_PRESENT_BIT(MDIO_MMD_PMAPMD)
+
+/* Bits in MMDREG_STAT2 */
+#define MDIO_MMDREG_STAT2_PRESENT_VAL	(2)
+#define MDIO_MMDREG_STAT2_PRESENT_LBN	(14)
+#define MDIO_MMDREG_STAT2_PRESENT_WIDTH (2)
+
+/* PMA type (4 bits) */
+#define MDIO_PMAPMD_CTRL2_10G_CX4	(0x0)
+#define MDIO_PMAPMD_CTRL2_10G_EW	(0x1)
+#define MDIO_PMAPMD_CTRL2_10G_LW	(0x2)
+#define MDIO_PMAPMD_CTRL2_10G_SW	(0x3)
+#define MDIO_PMAPMD_CTRL2_10G_LX4	(0x4)
+#define MDIO_PMAPMD_CTRL2_10G_ER	(0x5)
+#define MDIO_PMAPMD_CTRL2_10G_LR	(0x6)
+#define MDIO_PMAPMD_CTRL2_10G_SR	(0x7)
+/* Reserved */
+#define MDIO_PMAPMD_CTRL2_10G_BT	(0x9)
+/* Reserved */
+/* Reserved */
+#define MDIO_PMAPMD_CTRL2_1G_BT		(0xc)
+/* Reserved */
+#define MDIO_PMAPMD_CTRL2_100_BT	(0xe)
+#define MDIO_PMAPMD_CTRL2_10_BT		(0xf)
+#define MDIO_PMAPMD_CTRL2_TYPE_MASK	(0xf)
+
+/* /\* PHY XGXS lane state *\/ */
+#define MDIO_PHYXS_LANE_STATE		(0x18)
+#define MDIO_PHYXS_LANE_ALIGNED_LBN	(12)
+
+/* AN registers */
+#define MDIO_AN_STATUS			(1)
+#define MDIO_AN_STATUS_XNP_LBN		(7)
+#define MDIO_AN_STATUS_PAGE_LBN		(6)
+#define MDIO_AN_STATUS_AN_DONE_LBN	(5)
+#define MDIO_AN_STATUS_LP_AN_CAP_LBN	(0)
+
+#define MDIO_AN_10GBT_STATUS		(33)
+#define MDIO_AN_10GBT_STATUS_MS_FLT_LBN (15) /* MASTER/SLAVE config fault */
+#define MDIO_AN_10GBT_STATUS_MS_LBN     (14) /* MASTER/SLAVE config */
+#define MDIO_AN_10GBT_STATUS_LOC_OK_LBN (13) /* Local OK */
+#define MDIO_AN_10GBT_STATUS_REM_OK_LBN (12) /* Remote OK */
+#define MDIO_AN_10GBT_STATUS_LP_10G_LBN (11) /* Link partner is 10GBT capable */
+#define MDIO_AN_10GBT_STATUS_LP_LTA_LBN (10) /* LP loop timing ability */
+#define MDIO_AN_10GBT_STATUS_LP_TRR_LBN (9)  /* LP Training Reset Request */
+
+
+/* Packing of the prt and dev arguments of clause 45 style MDIO into a
+ * single int so they can be passed into the mdio_read/write functions
+ * that currently exist. Note that as Falcon is the only current user,
+ * the packed form is chosen to match what Falcon needs to write into
+ * a register. This is checked at compile-time so do not change it. If
+ * your target chip needs things layed out differently you will need
+ * to unpack the arguments in your chip-specific mdio functions.
+ */
+ /* These are defined by the standard. */
+#define MDIO45_PRT_ID_WIDTH  (5)
+#define MDIO45_DEV_ID_WIDTH  (5)
+
+/* The prt ID is just packed in immediately to the left of the dev ID */
+#define MDIO45_PRT_DEV_WIDTH (MDIO45_PRT_ID_WIDTH + MDIO45_DEV_ID_WIDTH)
+
+#define MDIO45_PRT_ID_MASK   ((1 << MDIO45_PRT_DEV_WIDTH) - 1)
+/* This is the prt + dev extended by 1 bit to hold the 'is clause 45' flag. */
+#define MDIO45_XPRT_ID_WIDTH   (MDIO45_PRT_DEV_WIDTH + 1)
+#define MDIO45_XPRT_ID_MASK   ((1 << MDIO45_XPRT_ID_WIDTH) - 1)
+#define MDIO45_XPRT_ID_IS10G   (1 << (MDIO45_XPRT_ID_WIDTH - 1))
+
+
+#define MDIO45_PRT_ID_COMP_LBN   MDIO45_DEV_ID_WIDTH
+#define MDIO45_PRT_ID_COMP_WIDTH  MDIO45_PRT_ID_WIDTH
+#define MDIO45_DEV_ID_COMP_LBN    0
+#define MDIO45_DEV_ID_COMP_WIDTH  MDIO45_DEV_ID_WIDTH
+
+/* Compose port and device into a phy_id */
+static inline int mdio_clause45_pack(u8 prt, u8 dev)
+{
+	efx_dword_t phy_id;
+	EFX_POPULATE_DWORD_2(phy_id, MDIO45_PRT_ID_COMP, prt,
+			     MDIO45_DEV_ID_COMP, dev);
+	return MDIO45_XPRT_ID_IS10G | EFX_DWORD_VAL(phy_id);
+}
+
+static inline void mdio_clause45_unpack(u32 val, u8 *prt, u8 *dev)
+{
+	efx_dword_t phy_id;
+	EFX_POPULATE_DWORD_1(phy_id, EFX_DWORD_0, val);
+	*prt = EFX_DWORD_FIELD(phy_id, MDIO45_PRT_ID_COMP);
+	*dev = EFX_DWORD_FIELD(phy_id, MDIO45_DEV_ID_COMP);
+}
+
+static inline int mdio_clause45_read(struct efx_nic *efx,
+				     u8 prt, u8 dev, u16 addr)
+{
+	return efx->mii.mdio_read(efx->net_dev,
+				  mdio_clause45_pack(prt, dev), addr);
+}
+
+static inline void mdio_clause45_write(struct efx_nic *efx,
+				       u8 prt, u8 dev, u16 addr, int value)
+{
+	efx->mii.mdio_write(efx->net_dev,
+			    mdio_clause45_pack(prt, dev), addr, value);
+}
+
+
+static inline u32 mdio_clause45_read_id(struct efx_nic *efx, int mmd)
+{
+	int phy_id = efx->mii.phy_id;
+	u16 id_low = mdio_clause45_read(efx, phy_id, mmd, MDIO_MMDREG_IDLOW);
+	u16 id_hi = mdio_clause45_read(efx, phy_id, mmd, MDIO_MMDREG_IDHI);
+	return (id_hi << 16) | (id_low);
+}
+
+static inline int mdio_clause45_phyxgxs_lane_sync(struct efx_nic *efx)
+{
+	int i, sync, lane_status;
+
+	for (i = 0; i < 2; ++i)
+		lane_status = mdio_clause45_read(efx, efx->mii.phy_id,
+						 MDIO_MMD_PHYXS,
+						 MDIO_PHYXS_LANE_STATE);
+
+	sync = (lane_status & (1 << MDIO_PHYXS_LANE_ALIGNED_LBN)) != 0;
+	if (!sync)
+		EFX_INFO(efx, "XGXS lane status: %x\n", lane_status);
+	return sync;
+}
+
+extern const char *mdio_clause45_mmd_name(int mmd);
+
+/*
+ * Reset a specific MMD and wait for reset to clear.
+ * Return number of spins left (>0) on success, -%ETIMEDOUT on failure.
+ *
+ * This function will sleep
+ */
+extern int mdio_clause45_reset_mmd(struct efx_nic *efx, int mmd,
+				   int spins, int spintime);
+
+/* As mdio_clause45_check_mmd but for multiple MMDs */
+int mdio_clause45_check_mmds(struct efx_nic *efx,
+			     unsigned int mmd_mask, unsigned int fatal_mask);
+
+/* Check the link status of specified mmds in bit mask */
+extern int mdio_clause45_links_ok(struct efx_nic *efx,
+				  unsigned int mmd_mask);
+
+/* Read (some of) the PHY settings over MDIO */
+extern void mdio_clause45_get_settings(struct efx_nic *efx,
+				       struct ethtool_cmd *ecmd);
+
+/* Set (some of) the PHY settings over MDIO */
+extern int mdio_clause45_set_settings(struct efx_nic *efx,
+				      struct ethtool_cmd *ecmd);
+
+/* Wait for specified MMDs to exit reset within a timeout */
+extern int mdio_clause45_wait_reset_mmds(struct efx_nic *efx,
+					 unsigned int mmd_mask);
+
+#endif /* EFX_MDIO_10G_H */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
