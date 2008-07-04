From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATCH 2/8] benet: interrupt, ethtool, stack i/f functions
Date: Fri, 04 Jul 2008 09:51:13 -0700
Message-ID: <20080704165113.444cff4e@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail96.messagelabs.com ([216.82.254.19]:57226 "EHLO
	mail96.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755847AbYGDQvQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 12:51:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
---
 drivers/net/benet/Makefile     |    9 +
 drivers/net/benet/be_ethtool.c |  348 ++++++++++++++++
 drivers/net/benet/be_int.c     |  874 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/benet/be_netif.c   |  706 ++++++++++++++++++++++++++++++++
 4 files changed, 1937 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/benet/Makefile
 create mode 100644 drivers/net/benet/be_ethtool.c
 create mode 100644 drivers/net/benet/be_int.c
 create mode 100644 drivers/net/benet/be_netif.c

diff --git a/drivers/net/benet/Makefile b/drivers/net/benet/Makefile
new file mode 100644
index 0000000..58c050d
--- /dev/null
+++ b/drivers/net/benet/Makefile
@@ -0,0 +1,9 @@
+#
+# Makefile to build the network driver for ServerEngine's BladeEngine.
+#
+EXTRA_CFLAGS = -I$(src)/hwlib -I$(src)/fw
+
+obj-$(CONFIG_BENET) += benet.o
+
+benet-y :=  be_init.o be_int.o be_netif.o be_ethtool.o \
+	hwlib/funcobj.o hwlib/cq.o hwlib/eq.o hwlib/mpu.o hwlib/eth.o
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
new file mode 100644
index 0000000..8c3ac90
--- /dev/null
+++ b/drivers/net/benet/be_ethtool.c
@@ -0,0 +1,348 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+/*
+ * be_ethtool.c
+ *
+ * 	This file contains various functions that ethtool can use
+ * 	to talk to the driver and the BE H/W.
+ */
+
+#include "benet.h"
+
+#include <linux/ethtool.h>
+
+static const char benet_gstrings_stats[][ETH_GSTRING_LEN] = {
+/* net_device_stats */
+	"rx_packets",
+	"tx_packets",
+	"rx_bytes",
+	"tx_bytes",
+	"rx_errors",
+	"tx_errors",
+	"rx_dropped",
+	"tx_dropped",
+	"multicast",
+	"collisions",
+	"rx_length_errors",
+	"rx_over_errors",
+	"rx_crc_errors",
+	"rx_frame_errors",
+	"rx_fifo_errors",
+	"rx_missed_errors",
+	"tx_aborted_errors",
+	"tx_carrier_errors",
+	"tx_fifo_errors",
+	"tx_heartbeat_errors",
+	"tx_window_errors",
+	"rx_compressed",
+	"tc_compressed",
+/* BE driver Stats */
+	"bes_tx_reqs",
+	"bes_tx_fails",
+	"bes_fwd_reqs",
+	"bes_tx_wrbs",
+	"bes_interrupts",
+	"bes_events",
+	"bes_tx_events",
+	"bes_rx_events",
+	"bes_tx_compl",
+	"bes_rx_compl",
+	"bes_ethrx_post_fail",
+	"bes_802_3_dropped_frames",
+	"bes_802_3_malformed_frames",
+	"bes_rx_misc_pkts",
+	"bes_eth_tx_rate",
+	"bes_eth_rx_rate",
+	"Num Packets collected",
+	"Num Times Flushed",
+};
+
+#define NET_DEV_STATS_LEN \
+	(sizeof(struct net_device_stats)/sizeof(unsigned long))
+
+#define BENET_STATS_LEN  ARRAY_SIZE(benet_gstrings_stats)
+
+static void
+be_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
+{
+	struct be_net_object *pnob = netdev->priv;
+	struct be_adapter *adapter = pnob->adapter;
+
+	strncpy(drvinfo->driver, be_driver_name, 32);
+	strncpy(drvinfo->version, be_drvr_ver, 32);
+	strncpy(drvinfo->fw_version, be_fw_ver, 32);
+	strcpy(drvinfo->bus_info, pci_name(adapter->pdev));
+	drvinfo->testinfo_len = 0;
+	drvinfo->regdump_len = 0;
+	drvinfo->eedump_len = 0;
+}
+
+static int
+be_get_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
+{
+	struct be_net_object *pnob = netdev->priv;
+	struct be_adapter *adapter = pnob->adapter;
+
+	coalesce->rx_max_coalesced_frames = adapter->max_rx_coal;
+
+	coalesce->rx_coalesce_usecs = adapter->cur_eqd;
+	coalesce->rx_coalesce_usecs_high = adapter->max_eqd;
+	coalesce->rx_coalesce_usecs_low = adapter->min_eqd;
+
+	coalesce->tx_coalesce_usecs = adapter->cur_eqd;
+	coalesce->tx_coalesce_usecs_high = adapter->max_eqd;
+	coalesce->tx_coalesce_usecs_low = adapter->min_eqd;
+
+	coalesce->use_adaptive_rx_coalesce = adapter->enable_aic;
+	coalesce->use_adaptive_tx_coalesce = adapter->enable_aic;
+
+	return 0;
+}
+
+/*
+ * This routine is used to set interrup coalescing delay *as well as*
+ * the number of pkts to coalesce for LRO.
+ */
+static int
+be_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
+{
+	struct be_net_object *pnob = netdev->priv;
+	struct be_adapter *adapter = pnob->adapter;
+	struct be_eq_object *eq_objectp;
+	u32 max, min, cur;
+	int status;
+
+	adapter->max_rx_coal = coalesce->rx_max_coalesced_frames;
+	if (adapter->max_rx_coal >= BE_LRO_MAX_PKTS)
+		adapter->max_rx_coal = BE_LRO_MAX_PKTS;
+
+	if (adapter->enable_aic == 0 &&
+		coalesce->use_adaptive_rx_coalesce == 1) {
+		/* if AIC is being turned on now, start with an EQD of 0 */
+		adapter->cur_eqd = 0;
+	}
+	adapter->enable_aic = coalesce->use_adaptive_rx_coalesce;
+
+	/* round off to nearest multiple of 8 */
+	max = (((coalesce->rx_coalesce_usecs_high + 4) >> 3) << 3);
+	min = (((coalesce->rx_coalesce_usecs_low + 4) >> 3) << 3);
+	cur = (((coalesce->rx_coalesce_usecs + 4) >> 3) << 3);
+
+	if (adapter->enable_aic) {
+		/* accept low and high if AIC is enabled */
+		if (max > MAX_EQD)
+			max = MAX_EQD;
+		if (min > max)
+			min = max;
+		adapter->max_eqd = max;
+		adapter->min_eqd = min;
+		if (adapter->cur_eqd > max)
+			adapter->cur_eqd = max;
+		if (adapter->cur_eqd < min)
+			adapter->cur_eqd = min;
+	} else {
+		/* accept specified coalesce_usecs only if AIC is disabled */
+		if (cur > MAX_EQD)
+			cur = MAX_EQD;
+		eq_objectp = &pnob->event_q_obj;
+		status =
+		    be_eq_modify_delay(&pnob->fn_obj, 1, &eq_objectp, &cur,
+				       NULL, NULL, NULL);
+		if (status == BE_SUCCESS)
+			adapter->cur_eqd = cur;
+	}
+	return 0;
+}
+
+static u32 be_get_rx_csum(struct net_device *netdev)
+{
+	struct be_net_object *pnob = netdev->priv;
+	struct be_adapter *adapter = pnob->adapter;
+	return adapter->rx_csum;
+}
+
+static int be_set_rx_csum(struct net_device *netdev, uint32_t data)
+{
+	struct be_net_object *pnob = netdev->priv;
+	struct be_adapter *adapter = pnob->adapter;
+
+	if (data)
+		adapter->rx_csum = 1;
+	else
+		adapter->rx_csum = 0;
+
+	return 0;
+}
+
+static void
+be_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(data, *benet_gstrings_stats,
+		       sizeof(benet_gstrings_stats));
+		break;
+	}
+}
+
+static int be_get_stats_count(struct net_device *netdev)
+{
+	return BENET_STATS_LEN;
+}
+
+static void
+be_get_ethtool_stats(struct net_device *netdev,
+		     struct ethtool_stats *stats, uint64_t *data)
+{
+	struct be_net_object *pnob = netdev->priv;
+	struct be_adapter *adapter = pnob->adapter;
+	int i;
+
+	benet_get_stats(netdev);
+
+	for (i = 0; i <= NET_DEV_STATS_LEN; i++)
+		data[i] = ((unsigned long *)&adapter->benet_stats)[i];
+
+	data[i] = adapter->be_stat.bes_tx_reqs;
+	data[i++] = adapter->be_stat.bes_tx_fails;
+	data[i++] = adapter->be_stat.bes_fwd_reqs;
+	data[i++] = adapter->be_stat.bes_tx_wrbs;
+
+	data[i++] = adapter->be_stat.bes_ints;
+	data[i++] = adapter->be_stat.bes_events;
+	data[i++] = adapter->be_stat.bes_tx_events;
+	data[i++] = adapter->be_stat.bes_rx_events;
+	data[i++] = adapter->be_stat.bes_tx_compl;
+	data[i++] = adapter->be_stat.bes_rx_compl;
+	data[i++] = adapter->be_stat.bes_ethrx_post_fail;
+	data[i++] = adapter->be_stat.bes_802_3_dropped_frames;
+	data[i++] = adapter->be_stat.bes_802_3_malformed_frames;
+	data[i++] = adapter->be_stat.bes_rx_misc_pkts;
+	data[i++] = adapter->be_stat.bes_eth_tx_rate;
+	data[i++] = adapter->be_stat.bes_eth_rx_rate;
+	data[i++] = adapter->be_stat.bes_rx_coal;
+	data[i++] = adapter->be_stat.bes_rx_flush;
+
+}
+
+static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+{
+	ecmd->speed = SPEED_10000;
+	ecmd->duplex = DUPLEX_FULL;
+	ecmd->autoneg = AUTONEG_DISABLE;
+	return 0;
+}
+
+/* Get the Ring parameters from the pnob */
+static void
+be_get_ringparam(struct net_device *netdev, struct ethtool_ringparam *ring)
+{
+	struct be_net_object *pnob = netdev->priv;
+
+	/* Pre Set Maxims */
+	ring->rx_max_pending = pnob->rx_q_len;
+	ring->rx_mini_max_pending = ring->rx_mini_max_pending;
+	ring->rx_jumbo_max_pending = ring->rx_jumbo_max_pending;
+	ring->tx_max_pending = pnob->tx_q_len;
+
+	/* Current hardware Settings                */
+	ring->rx_pending = atomic_read(&pnob->rx_q_posted);
+	ring->rx_mini_pending = ring->rx_mini_pending;
+	ring->rx_jumbo_pending = ring->rx_jumbo_pending;
+	ring->tx_pending = atomic_read(&pnob->tx_q_used);
+
+}
+
+static void
+be_get_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *ecmd)
+{
+	struct be_net_object *pnob = netdev->priv;
+	bool rxfc, txfc;
+	int status;
+
+	status = be_eth_get_flow_control(&pnob->fn_obj, &txfc, &rxfc);
+	if (status != BE_SUCCESS) {
+		dev_info(&netdev->dev, "Unable to get pause frame settings\n");
+		/* return defaults */
+		ecmd->rx_pause = 1;
+		ecmd->tx_pause = 0;
+		ecmd->autoneg = AUTONEG_ENABLE;
+		return;
+	}
+
+	if (txfc == true)
+		ecmd->tx_pause = 1;
+	else
+		ecmd->tx_pause = 0;
+
+	if (rxfc == true)
+		ecmd->rx_pause = 1;
+	else
+		ecmd->rx_pause = 0;
+
+	ecmd->autoneg = AUTONEG_ENABLE;
+}
+
+static int
+be_set_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *ecmd)
+{
+	struct be_net_object *pnob = netdev->priv;
+	bool txfc, rxfc;
+	int status;
+
+	if (ecmd->autoneg != AUTONEG_ENABLE)
+		return -EINVAL;
+
+	if (ecmd->tx_pause)
+		txfc = true;
+	else
+		txfc = false;
+
+	if (ecmd->rx_pause)
+		rxfc = true;
+	else
+		rxfc = false;
+
+	status = be_eth_set_flow_control(&pnob->fn_obj, txfc, rxfc);
+	if (status != BE_SUCCESS) {
+		dev_info(&netdev->dev, "Unable to set pause frame settings\n");
+		return -1;
+	}
+	return 0;
+}
+
+struct ethtool_ops be_ethtool_ops = {
+	.get_settings = be_get_settings,
+	.get_drvinfo = be_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+	.get_coalesce = be_get_coalesce,
+	.set_coalesce = be_set_coalesce,
+	.get_ringparam = be_get_ringparam,
+	.get_pauseparam = be_get_pauseparam,
+	.set_pauseparam = be_set_pauseparam,
+	.get_rx_csum = be_get_rx_csum,
+	.set_rx_csum = be_set_rx_csum,
+	.get_tx_csum = ethtool_op_get_tx_csum,
+	.set_tx_csum = ethtool_op_set_tx_csum,
+	.get_sg = ethtool_op_get_sg,
+	.set_sg = ethtool_op_set_sg,
+	.get_tso = ethtool_op_get_tso,
+	.set_tso = ethtool_op_set_tso,
+	.get_strings = be_get_strings,
+	.get_stats_count = be_get_stats_count,
+	.get_ethtool_stats = be_get_ethtool_stats,
+};
diff --git a/drivers/net/benet/be_int.c b/drivers/net/benet/be_int.c
new file mode 100644
index 0000000..82472b4
--- /dev/null
+++ b/drivers/net/benet/be_int.c
@@ -0,0 +1,874 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+#include <linux/if_vlan.h>
+#include <linux/inet_lro.h>
+
+#include "benet.h"
+
+/* number of bytes of RX frame that are copied to skb->data */
+#define BE_HDR_LEN 64
+
+#define NETIF_RX(skb) netif_receive_skb(skb)
+#define VLAN_ACCEL_RX(skb, pnob, vt) \
+		vlan_hwaccel_rx(skb, pnob->vlan_grp, vt)
+
+/*
+    This function notifies BladeEngine of the number of completion
+    entries processed from the specified completion queue by writing
+    the number of popped entries to the door bell.
+
+    pnob	- Pointer to the NetObject structure
+    n		- Number of completion entries processed
+    cq_id	- Queue ID of the completion queue for which notification
+			is being done.
+    re_arm	- 1  - rearm the completion ring to generate an event.
+		- 0  - dont rearm the completion ring to generate an event
+*/
+void be_notify_cmpl(struct be_net_object *pnob, int n, int cq_id, int re_arm)
+{
+	struct CQ_DB_AMAP cqdb;
+
+	cqdb.dw[0] = 0;
+	AMAP_SET_BITS_PTR(CQ_DB, qid, &cqdb, cq_id);
+	AMAP_SET_BITS_PTR(CQ_DB, rearm, &cqdb, re_arm);
+	AMAP_SET_BITS_PTR(CQ_DB, num_popped, &cqdb, n);
+	PD_WRITE(&pnob->fn_obj, cq_db, cqdb.dw[0]);
+}
+
+/*
+ * adds additional receive frags indicated by BE starting from given
+ * frag index (fi) to specified skb's frag list
+ */
+static void
+add_skb_frags(struct be_net_object *pnob, struct sk_buff *skb,
+	      u32 nresid, u32 fi)
+{
+	struct be_adapter *adapter = pnob->adapter;
+	u32 sk_frag_idx, n;
+	struct be_rx_page_info *rx_page_info;
+	u32 frag_sz = pnob->rx_buf_size;
+
+	sk_frag_idx = skb_shinfo(skb)->nr_frags;
+	while (nresid) {
+		index_inc(&fi, pnob->rx_q_len);
+
+		rx_page_info = (struct be_rx_page_info *)pnob->rx_ctxt[fi];
+		pnob->rx_ctxt[fi] = NULL;
+		if ((rx_page_info->page_offset) ||
+		    (pnob->rx_pg_shared == false)) {
+			pci_unmap_page(adapter->pdev,
+				       pci_unmap_addr(rx_page_info, bus),
+				       frag_sz, PCI_DMA_FROMDEVICE);
+		}
+
+		n = min(nresid, frag_sz);
+		skb_shinfo(skb)->frags[sk_frag_idx].page = rx_page_info->page;
+		skb_shinfo(skb)->frags[sk_frag_idx].page_offset
+		    = rx_page_info->page_offset;
+		skb_shinfo(skb)->frags[sk_frag_idx].size = n;
+
+		sk_frag_idx++;
+		skb->len += n;
+		skb->data_len += n;
+		skb_shinfo(skb)->nr_frags++;
+		nresid -= n;
+
+		memset(rx_page_info, 0, sizeof(struct be_rx_page_info));
+		atomic_dec(&pnob->rx_q_posted);
+	}
+}
+
+/*
+ * This function processes incoming nic packets over various Rx queues.
+ * This function takes the adapter, the current Rx status descriptor
+ * entry and the Rx completion queue ID as argument.
+ */
+static inline int process_nic_rx_completion(struct be_net_object *pnob,
+					    struct ETH_RX_COMPL_AMAP *rxcp)
+{
+	struct be_adapter *adapter = pnob->adapter;
+	struct sk_buff *skb;
+	int udpcksm, tcpcksm;
+	int n;
+	u32 nresid, fi;
+	u32 frag_sz = pnob->rx_buf_size;
+	u8 *va;
+	struct be_rx_page_info *rx_page_info;
+	u32 numfrags, vtp, vtm, vlan_tag, pktsize;
+
+	fi = AMAP_GET_BITS_PTR(ETH_RX_COMPL, fragndx, rxcp);
+	BUG_ON(fi >= (int)pnob->rx_q_len);
+	BUG_ON(fi < 0);
+
+	rx_page_info = (struct be_rx_page_info *)pnob->rx_ctxt[fi];
+	BUG_ON(!rx_page_info->page);
+	pnob->rx_ctxt[fi] = NULL;
+
+	/*
+	 * If one page is used per fragment or if this is the second half of
+	 *  of the page, unmap the page here
+	 */
+	if ((rx_page_info->page_offset) || (pnob->rx_pg_shared == false)) {
+		pci_unmap_page(adapter->pdev,
+			       pci_unmap_addr(rx_page_info, bus), frag_sz,
+			       PCI_DMA_FROMDEVICE);
+	}
+
+	atomic_dec(&pnob->rx_q_posted);
+	udpcksm = AMAP_GET_BITS_PTR(ETH_RX_COMPL, udpcksm, rxcp);
+	tcpcksm = AMAP_GET_BITS_PTR(ETH_RX_COMPL, tcpcksm, rxcp);
+	pktsize = AMAP_GET_BITS_PTR(ETH_RX_COMPL, pktsize, rxcp);
+	/*
+	 * get rid of RX flush completions first.
+	 */
+	if ((tcpcksm) && (udpcksm) && (pktsize == 32)) {
+		put_page(rx_page_info->page);
+		memset(rx_page_info, 0, sizeof(struct be_rx_page_info));
+		return 0;
+	}
+	skb = netdev_alloc_skb(pnob->netdev, BE_HDR_LEN + NET_IP_ALIGN);
+	if (skb == NULL) {
+		dev_info(&pnob->netdev->dev, "alloc_skb() failed\n");
+		put_page(rx_page_info->page);
+		memset(rx_page_info, 0, sizeof(struct be_rx_page_info));
+		goto free_frags;
+	}
+	skb_reserve(skb, NET_IP_ALIGN);
+
+	skb->dev = pnob->netdev;
+
+	n = min(pktsize, frag_sz);
+
+	va = page_address(rx_page_info->page) + rx_page_info->page_offset;
+	prefetch(va);
+
+	skb->len = skb->data_len = n;
+	if (n <= BE_HDR_LEN) {
+		memcpy(skb->data, va, n);
+		put_page(rx_page_info->page);
+		skb->data_len -= n;
+		skb->tail += n;
+	} else {
+
+		/* Setup the SKB with page buffer information */
+		skb_shinfo(skb)->frags[0].page = rx_page_info->page;
+		skb_shinfo(skb)->nr_frags++;
+
+		/* Copy the header into the skb_data */
+		memcpy(skb->data, va, BE_HDR_LEN);
+		skb_shinfo(skb)->frags[0].page_offset =
+		    rx_page_info->page_offset + BE_HDR_LEN;
+		skb_shinfo(skb)->frags[0].size = n - BE_HDR_LEN;
+		skb->data_len -= BE_HDR_LEN;
+		skb->tail += BE_HDR_LEN;
+	}
+	memset(rx_page_info, 0, sizeof(struct be_rx_page_info));
+	nresid = pktsize - n;
+
+	skb->protocol = eth_type_trans(skb, pnob->netdev);
+
+	if ((tcpcksm || udpcksm) && adapter->rx_csum)
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	else
+		skb->ip_summed = CHECKSUM_NONE;
+	/*
+	 * if we have more bytes left, the frame has been
+	 * given to us in multiple fragments.  This happens
+	 * with Jumbo frames. Add the remaining fragments to
+	 * skb->frags[] array.
+	 */
+	if (nresid)
+		add_skb_frags(pnob, skb, nresid, fi);
+
+	/* update the the true size of the skb. */
+	skb->truesize = skb->len + sizeof(struct sk_buff);
+
+	/*
+	 * If a 802.3 frame or 802.2 LLC frame
+	 * (i.e) contains length field in MAC Hdr
+	 * and frame len is greater than 64 bytes
+	 */
+	if (((skb->protocol == ntohs(ETH_P_802_2)) ||
+	     (skb->protocol == ntohs(ETH_P_802_3)))
+	    && (pktsize > BE_HDR_LEN)) {
+		/*
+		 * If the length given in Mac Hdr is less than frame size
+		 * Erraneous frame, Drop it
+		 */
+		if ((ntohs(*(u16 *) (va + 12)) + ETH_HLEN) < pktsize) {
+			/* Increment Non Ether type II frames dropped */
+			adapter->be_stat.bes_802_3_dropped_frames++;
+
+			kfree_skb(skb);
+			return 0;
+		}
+		/*
+		 * else if the length given in Mac Hdr is greater than
+		 * frame size, should not be seeing this sort of frames
+		 * dump the pkt and pass to stack
+		 */
+		else if ((ntohs(*(u16 *) (va + 12)) + ETH_HLEN) > pktsize) {
+			/* Increment Non Ether type II frames malformed */
+			adapter->be_stat.bes_802_3_malformed_frames++;
+		}
+	}
+
+	vtp = AMAP_GET_BITS_PTR(ETH_RX_COMPL, vtp, rxcp);
+	vtm = AMAP_GET_BITS_PTR(ETH_RX_COMPL, vtm, rxcp);
+	if (vtp && vtm) {
+		/* Vlan tag present in pkt and BE found
+		 * that the tag matched an entry in VLAN table
+		 */
+		if (!pnob->vlan_grp || pnob->num_vlans == 0) {
+			/* But we have no VLANs configured.
+			 * This should never happen.  Drop the packet.
+			 */
+			dev_info(&pnob->netdev->dev,
+			       "BladeEngine: Unexpected vlan tagged packet\n");
+			kfree_skb(skb);
+			return 0;
+		}
+		/* pass the VLAN packet to stack */
+		vlan_tag = AMAP_GET_BITS_PTR(ETH_RX_COMPL, vlan_tag, rxcp);
+		VLAN_ACCEL_RX(skb, pnob, be16_to_cpu(vlan_tag));
+
+	} else {
+		NETIF_RX(skb);
+	}
+	return 0;
+
+free_frags:
+	/* free all frags associated with the current rxcp */
+	numfrags = AMAP_GET_BITS_PTR(ETH_RX_COMPL, numfrags, rxcp);
+	while (numfrags-- > 1) {
+		index_inc(&fi, pnob->rx_q_len);
+
+		rx_page_info = (struct be_rx_page_info *)
+		    pnob->rx_ctxt[fi];
+		pnob->rx_ctxt[fi] = (void *)NULL;
+		if (rx_page_info->page_offset || !pnob->rx_pg_shared) {
+			pci_unmap_page(adapter->pdev,
+				       pci_unmap_addr(rx_page_info, bus),
+				       frag_sz, PCI_DMA_FROMDEVICE);
+		}
+
+		put_page(rx_page_info->page);
+		memset(rx_page_info, 0, sizeof(struct be_rx_page_info));
+		atomic_dec(&pnob->rx_q_posted);
+	}
+	return -ENOMEM;
+}
+
+static void process_nic_rx_completion_lro(struct be_net_object *pnob,
+					  struct ETH_RX_COMPL_AMAP *rxcp)
+{
+	struct be_adapter *adapter = pnob->adapter;
+	struct skb_frag_struct rx_frags[BE_MAX_FRAGS_PER_FRAME];
+	unsigned int udpcksm, tcpcksm;
+	u32 numfrags, vlanf, vtm, vlan_tag, nresid;
+	u16 vlant;
+	unsigned int fi, idx, n;
+	struct be_rx_page_info *rx_page_info;
+	u32 frag_sz = pnob->rx_buf_size, pktsize;
+	bool rx_coal = (adapter->max_rx_coal <= 1) ? 0 : 1;
+	u8 err, *va;
+	__wsum csum = 0;
+
+	if (AMAP_GET_BITS_PTR(ETH_RX_COMPL, ipsec, rxcp)) {
+		/*  Drop the pkt and move to the next completion.  */
+		adapter->be_stat.bes_rx_misc_pkts++;
+		return;
+	}
+	err = AMAP_GET_BITS_PTR(ETH_RX_COMPL, err, rxcp);
+	if (err || !rx_coal) {
+		/* We won't coalesce Rx pkts if the err bit set.
+		 * take the path of normal completion processing */
+		process_nic_rx_completion(pnob, rxcp);
+		return;
+	}
+
+	fi = AMAP_GET_BITS_PTR(ETH_RX_COMPL, fragndx, rxcp);
+	BUG_ON(fi >= (int)pnob->rx_q_len);
+	BUG_ON(fi < 0);
+	rx_page_info = (struct be_rx_page_info *)pnob->rx_ctxt[fi];
+	BUG_ON(!rx_page_info->page);
+	pnob->rx_ctxt[fi] = (void *)NULL;
+	/*  If one page is used per fragment or if this is the
+	 * second half of the page, unmap the page here
+	 */
+	if (rx_page_info->page_offset || !pnob->rx_pg_shared) {
+		pci_unmap_page(adapter->pdev,
+			       pci_unmap_addr(rx_page_info, bus),
+			       frag_sz, PCI_DMA_FROMDEVICE);
+	}
+
+	numfrags = AMAP_GET_BITS_PTR(ETH_RX_COMPL, numfrags, rxcp);
+	udpcksm = AMAP_GET_BITS_PTR(ETH_RX_COMPL, udpcksm, rxcp);
+	tcpcksm = AMAP_GET_BITS_PTR(ETH_RX_COMPL, tcpcksm, rxcp);
+	vlan_tag = AMAP_GET_BITS_PTR(ETH_RX_COMPL, vlan_tag, rxcp);
+	vlant = be16_to_cpu(vlan_tag);
+	vlanf = AMAP_GET_BITS_PTR(ETH_RX_COMPL, vtp, rxcp);
+	vtm = AMAP_GET_BITS_PTR(ETH_RX_COMPL, vtm, rxcp);
+	pktsize = AMAP_GET_BITS_PTR(ETH_RX_COMPL, pktsize, rxcp);
+
+	atomic_dec(&pnob->rx_q_posted);
+
+	if (tcpcksm && udpcksm && pktsize == 32) {
+		/* flush completion entries */
+		put_page(rx_page_info->page);
+		memset(rx_page_info, 0, sizeof(struct be_rx_page_info));
+		return;
+	}
+	/* Only one of udpcksum and tcpcksum can be set */
+	BUG_ON(udpcksm && tcpcksm);
+
+	/* jumbo frames could come in multiple fragments */
+	BUG_ON(numfrags != ((pktsize + (frag_sz - 1)) / frag_sz));
+	n = min(pktsize, frag_sz);
+	nresid = pktsize - n;	/* will be useful for jumbo pkts */
+	idx = 0;
+
+	va = page_address(rx_page_info->page) + rx_page_info->page_offset;
+	prefetch(va);
+	rx_frags[idx].page = rx_page_info->page;
+	rx_frags[idx].page_offset = (rx_page_info->page_offset);
+	rx_frags[idx].size = n;
+	memset(rx_page_info, 0, sizeof(struct be_rx_page_info));
+
+	/* If we got multiple fragments, we have more data. */
+	while (nresid) {
+		idx++;
+		index_inc(&fi, pnob->rx_q_len);
+
+		rx_page_info = (struct be_rx_page_info *)pnob->rx_ctxt[fi];
+		pnob->rx_ctxt[fi] = (void *)NULL;
+		if (rx_page_info->page_offset || !pnob->rx_pg_shared) {
+			pci_unmap_page(adapter->pdev,
+				       pci_unmap_addr(rx_page_info, bus),
+				       frag_sz, PCI_DMA_FROMDEVICE);
+		}
+
+		n = min(nresid, frag_sz);
+		rx_frags[idx].page = rx_page_info->page;
+		rx_frags[idx].page_offset = (rx_page_info->page_offset);
+		rx_frags[idx].size = n;
+
+		nresid -= n;
+		memset(rx_page_info, 0, sizeof(struct be_rx_page_info));
+		atomic_dec(&pnob->rx_q_posted);
+	}
+
+	if (likely(!(vlanf && vtm))) {
+		lro_receive_frags(&pnob->lro_mgr, rx_frags,
+				  pktsize, pktsize,
+				  (void *)(unsigned long)csum, csum);
+	} else {
+		/* Vlan tag present in pkt and BE found
+		 * that the tag matched an entry in VLAN table
+		 */
+		if (unlikely(!pnob->vlan_grp || pnob->num_vlans == 0)) {
+			/* But we have no VLANs configured.
+			 * This should never happen.  Drop the packet.
+			 */
+			dev_info(&pnob->netdev->dev,
+			       "BladeEngine: Unexpected vlan tagged packet\n");
+			return;
+		}
+		/* pass the VLAN packet to stack */
+		lro_vlan_hwaccel_receive_frags(&pnob->lro_mgr,
+					       rx_frags, pktsize, pktsize,
+					       pnob->vlan_grp, vlant,
+					       (void *)(unsigned long)csum,
+					       csum);
+	}
+
+	adapter->be_stat.bes_rx_coal++;
+}
+
+struct ETH_RX_COMPL_AMAP *be_get_rx_cmpl(struct be_net_object *pnob)
+{
+	struct ETH_RX_COMPL_AMAP *rxcp = &pnob->rx_cq[pnob->rx_cq_tl];
+	u32 valid, ct;
+
+	valid = AMAP_GET_BITS_PTR(ETH_RX_COMPL, valid, rxcp);
+	if (valid == 0)
+		return NULL;
+
+	ct = AMAP_GET_BITS_PTR(ETH_RX_COMPL, ct, rxcp);
+	if (ct != 0) {
+		/* Invalid chute #. treat as error */
+		AMAP_SET_BITS_PTR(ETH_RX_COMPL, err, rxcp, 1);
+	}
+
+	be_adv_rxcq_tl(pnob);
+	AMAP_SET_BITS_PTR(ETH_RX_COMPL, valid, rxcp, 0);
+	return rxcp;
+}
+
+static void update_rx_rate(struct be_adapter *adapter)
+{
+	/* update the rate once in two seconds */
+	if ((jiffies - adapter->eth_rx_jiffies) > 2 * (HZ)) {
+		u32 r;
+		r = adapter->eth_rx_bytes /
+		    ((jiffies - adapter->eth_rx_jiffies) / (HZ));
+		r = (r / 1000000);	/* MB/Sec */
+
+		/* Mega Bits/Sec */
+		adapter->be_stat.bes_eth_rx_rate = (r * 8);
+		adapter->eth_rx_jiffies = jiffies;
+		adapter->eth_rx_bytes = 0;
+	}
+}
+
+static int process_rx_completions(struct be_net_object *pnob, int max_work)
+{
+	struct be_adapter *adapter = pnob->adapter;
+	struct ETH_RX_COMPL_AMAP *rxcp;
+	u32 nc = 0;
+	unsigned int pktsize;
+
+	while (max_work && (rxcp = be_get_rx_cmpl(pnob))) {
+		prefetch(rxcp);
+		pktsize = AMAP_GET_BITS_PTR(ETH_RX_COMPL, pktsize, rxcp);
+		process_nic_rx_completion_lro(pnob, rxcp);
+		adapter->eth_rx_bytes += pktsize;
+		update_rx_rate(adapter);
+		nc++;
+		max_work--;
+		adapter->be_stat.bes_rx_compl++;
+	}
+	if (likely(adapter->max_rx_coal > 1)) {
+		adapter->be_stat.bes_rx_flush++;
+		lro_flush_all(&pnob->lro_mgr);
+	}
+
+	/* Refill the queue */
+	if (atomic_read(&pnob->rx_q_posted) < 900)
+		be_post_eth_rx_buffs(pnob);
+
+	return nc;
+}
+
+static struct ETH_TX_COMPL_AMAP *be_get_tx_cmpl(struct be_net_object *pnob)
+{
+	struct ETH_TX_COMPL_AMAP *txcp = &pnob->tx_cq[pnob->tx_cq_tl];
+	u32 valid;
+
+	valid = AMAP_GET_BITS_PTR(ETH_TX_COMPL, valid, txcp);
+	if (valid == 0)
+		return NULL;
+
+	AMAP_SET_BITS_PTR(ETH_TX_COMPL, valid, txcp, 0);
+	be_adv_txcq_tl(pnob);
+	return txcp;
+
+}
+
+void process_one_tx_compl(struct be_net_object *pnob, u32 end_idx)
+{
+	struct be_adapter *adapter = pnob->adapter;
+	int cur_index, tx_wrbs_completed = 0;
+	struct sk_buff *skb;
+	u64 busaddr, pa, pa_lo, pa_hi;
+	struct ETH_WRB_AMAP *wrb;
+	u32 frag_len, last_index, j;
+
+	last_index = tx_compl_lastwrb_idx_get(pnob);
+	BUG_ON(last_index != end_idx);
+	pnob->tx_ctxt[pnob->tx_q_tl] = NULL;
+	do {
+		cur_index = pnob->tx_q_tl;
+		wrb = &pnob->tx_q[cur_index];
+		pa_hi = AMAP_GET_BITS_PTR(ETH_WRB, frag_pa_hi, wrb);
+		pa_lo = AMAP_GET_BITS_PTR(ETH_WRB, frag_pa_lo, wrb);
+		frag_len = AMAP_GET_BITS_PTR(ETH_WRB, frag_len, wrb);
+		busaddr = (pa_hi << 32) | pa_lo;
+		if (busaddr != 0) {
+			pa = le64_to_cpu(busaddr);
+			pci_unmap_single(adapter->pdev, pa,
+					 frag_len, PCI_DMA_TODEVICE);
+		}
+		if (cur_index == last_index) {
+			skb = (struct sk_buff *)pnob->tx_ctxt[cur_index];
+			BUG_ON(!skb);
+			for (j = 0; j < skb_shinfo(skb)->nr_frags; j++) {
+				struct skb_frag_struct *frag;
+				frag = &skb_shinfo(skb)->frags[j];
+				pci_unmap_page(adapter->pdev,
+					       (ulong) frag->page, frag->size,
+					       PCI_DMA_TODEVICE);
+			}
+			kfree_skb(skb);
+			pnob->tx_ctxt[cur_index] = NULL;
+		} else {
+			BUG_ON(pnob->tx_ctxt[cur_index]);
+		}
+		tx_wrbs_completed++;
+		be_adv_txq_tl(pnob);
+	} while (cur_index != last_index);
+	atomic_sub(tx_wrbs_completed, &pnob->tx_q_used);
+}
+
+/* there is no need to take an SMP lock here since currently
+ * we have only one instance of the tasklet that does completion
+ * processing.
+ */
+static void process_nic_tx_completions(struct be_net_object *pnob)
+{
+	struct be_adapter *adapter = pnob->adapter;
+	struct ETH_TX_COMPL_AMAP *txcp;
+	struct net_device *netdev = pnob->netdev;
+	u32 end_idx, num_processed = 0;
+
+	adapter->be_stat.bes_tx_events++;
+
+	while ((txcp = be_get_tx_cmpl(pnob))) {
+		end_idx = AMAP_GET_BITS_PTR(ETH_TX_COMPL, wrb_index, txcp);
+		process_one_tx_compl(pnob, end_idx);
+		num_processed++;
+		adapter->be_stat.bes_tx_compl++;
+	}
+	be_notify_cmpl(pnob, num_processed, pnob->tx_cq_id, 1);
+	/*
+	 * We got Tx completions and have usable WRBs.
+	 * If the netdev's queue has been stopped
+	 * because we had run out of WRBs, wake it now.
+	 */
+	spin_lock(&adapter->txq_lock);
+	if (netif_queue_stopped(netdev)
+	    && atomic_read(&pnob->tx_q_used) < pnob->tx_q_len / 2) {
+		netif_wake_queue(netdev);
+	}
+	spin_unlock(&adapter->txq_lock);
+}
+
+static u32 post_rx_buffs(struct be_net_object *pnob, struct list_head *rxbl)
+{
+	u32 nposted = 0;
+	struct ETH_RX_D_AMAP *rxd = NULL;
+	struct be_recv_buffer *rxbp;
+	void **rx_ctxp;
+	struct RQ_DB_AMAP rqdb;
+
+	rx_ctxp = pnob->rx_ctxt;
+
+	while (!list_empty(rxbl) &&
+	       (rx_ctxp[pnob->rx_q_hd] == NULL) && nposted < 255) {
+
+		rxbp = list_first_entry(rxbl, struct be_recv_buffer, rxb_list);
+		list_del(&rxbp->rxb_list);
+		rxd = pnob->rx_q + pnob->rx_q_hd;
+		AMAP_SET_BITS_PTR(ETH_RX_D, fragpa_lo, rxd, rxbp->rxb_pa_lo);
+		AMAP_SET_BITS_PTR(ETH_RX_D, fragpa_hi, rxd, rxbp->rxb_pa_hi);
+
+		rx_ctxp[pnob->rx_q_hd] = rxbp->rxb_ctxt;
+		be_adv_rxq_hd(pnob);
+		nposted++;
+	}
+
+	if (nposted) {
+		/* Now press the door bell to notify BladeEngine. */
+		rqdb.dw[0] = 0;
+		AMAP_SET_BITS_PTR(RQ_DB, numPosted, &rqdb, nposted);
+		AMAP_SET_BITS_PTR(RQ_DB, rq, &rqdb, pnob->rx_q_id);
+		PD_WRITE(&pnob->fn_obj, erx_rq_db, rqdb.dw[0]);
+	}
+	atomic_add(nposted, &pnob->rx_q_posted);
+	return nposted;
+}
+
+void be_post_eth_rx_buffs(struct be_net_object *pnob)
+{
+	struct be_adapter *adapter = pnob->adapter;
+	u32 num_bufs, r;
+	u64 busaddr = 0, tmp_pa;
+	u32 max_bufs, pg_hd;
+	u32 frag_size;
+	struct be_recv_buffer *rxbp;
+	struct list_head rxbl;
+	struct be_rx_page_info *rx_page_info;
+	struct page *page = NULL;
+	u32 page_order = 0;
+	gfp_t alloc_flags = GFP_ATOMIC;
+
+	BUG_ON(!adapter);
+
+	max_bufs = 64;		/* should be even # <= 255. */
+
+	frag_size = pnob->rx_buf_size;
+	page_order = get_order(frag_size);
+
+	if (frag_size == 8192)
+		alloc_flags |= (gfp_t) __GFP_COMP;
+	/*
+	 * Form a linked list of RECV_BUFFFER structure to be be posted.
+	 * We will post even number of buffer so that pages can be
+	 * shared.
+	 */
+	INIT_LIST_HEAD(&rxbl);
+
+	for (num_bufs = 0; num_bufs < max_bufs; ++num_bufs) {
+
+		rxbp = &pnob->eth_rx_bufs[num_bufs];
+		pg_hd = pnob->rx_pg_info_hd;
+		rx_page_info = &pnob->rx_page_info[pg_hd];
+
+		if (!page) {
+			/*
+			 * before we allocate a page make sure that we
+			 * have space in the RX queue to post the buffer.
+			 * We check for two vacant slots since with
+			 * 2K frags, we will need two slots.
+			 */
+			if ((pnob->rx_ctxt[(pnob->rx_q_hd + num_bufs) &
+					   (pnob->rx_q_len - 1)] != NULL)
+			    || (pnob->rx_ctxt[(pnob->rx_q_hd + num_bufs + 1) %
+					      pnob->rx_q_len] != NULL)) {
+				break;
+			}
+			page = alloc_pages(alloc_flags, page_order);
+			if (unlikely(page == NULL)) {
+				adapter->be_stat.bes_ethrx_post_fail++;
+				pnob->rxbuf_post_fail++;
+				break;
+			}
+			pnob->rxbuf_post_fail = 0;
+			busaddr = pci_map_page(adapter->pdev, page, 0,
+					       frag_size, PCI_DMA_FROMDEVICE);
+			rx_page_info->page_offset = 0;
+			rx_page_info->page = page;
+			/*
+			 * If we are sharing a page among two skbs,
+			 * alloc a new one on the next iteration
+			 */
+			if (pnob->rx_pg_shared == false)
+				page = NULL;
+		} else {
+			get_page(page);
+			rx_page_info->page_offset += frag_size;
+			rx_page_info->page = page;
+			/*
+			 * We are finished with the alloced page,
+			 * Alloc a new one on the next iteration
+			 */
+			page = NULL;
+		}
+		rxbp->rxb_ctxt = (void *)rx_page_info;
+		index_inc(&pnob->rx_pg_info_hd, pnob->rx_q_len);
+
+		pci_unmap_addr_set(rx_page_info, bus, busaddr);
+		tmp_pa = busaddr + rx_page_info->page_offset;
+		rxbp->rxb_pa_lo = (tmp_pa & 0xFFFFFFFF);
+		rxbp->rxb_pa_hi = (tmp_pa >> 32);
+		rxbp->rxb_len = frag_size;
+		list_add_tail(&rxbp->rxb_list, &rxbl);
+	}			/* End of for */
+
+	r = post_rx_buffs(pnob, &rxbl);
+	BUG_ON(r != num_bufs);
+	return;
+}
+
+/*
+ * Interrupt service for network function.  We just schedule the
+ * tasklet which does all completion processing.
+ */
+irqreturn_t be_int(int irq, void *dev)
+{
+	struct net_device *netdev = dev;
+	struct be_net_object *pnob = (struct be_net_object *)(netdev->priv);
+	struct be_adapter *adapter = pnob->adapter;
+	u32 isr;
+
+	isr = CSR_READ(&pnob->fn_obj, cev.isr1);
+	if (unlikely(!isr))
+		return IRQ_NONE;
+
+	spin_lock(&adapter->int_lock);
+	adapter->isr |= isr;
+	spin_unlock(&adapter->int_lock);
+
+	adapter->be_stat.bes_ints++;
+
+	tasklet_schedule(&adapter->sts_handler);
+	return IRQ_HANDLED;
+}
+
+/*
+ * Poll function called by NAPI with a work budget.
+ * We process as many UC. BC and MC receive completions
+ * as the budget allows and return the actual number of
+ * RX ststutses processed.
+ */
+int be_poll(struct napi_struct *napi, int budget)
+{
+	struct net_device *netdev = napi->dev;
+	struct be_net_object *pnob = (struct be_net_object *)netdev->priv;
+	struct be_adapter *adapter = pnob->adapter;
+	u32 work_done;
+
+	adapter->be_stat.bes_polls++;
+	work_done = process_rx_completions(pnob, budget);
+	BUG_ON(work_done > budget);
+
+	/* All consumed */
+	if (work_done < budget) {
+		netif_rx_complete(netdev, napi);
+		/* enable intr */
+		be_notify_cmpl(pnob, work_done, pnob->rx_cq_id, 1);
+	} else {
+		/* More to be consumed; continue with interrupts disabled */
+		be_notify_cmpl(pnob, work_done, pnob->rx_cq_id, 0);
+	}
+	return work_done;
+}
+
+static struct EQ_ENTRY_AMAP *get_event(struct be_net_object *pnob)
+{
+	struct EQ_ENTRY_AMAP *eqp = &(pnob->event_q[pnob->event_q_tl]);
+	if (!AMAP_GET_BITS_PTR(EQ_ENTRY, Valid, eqp))
+		return NULL;
+	be_adv_eq_tl(pnob);
+	return eqp;
+}
+
+/*
+ * Processes all valid events in the event ring associated with given
+ * NetObject.  Also, notifies BE the number of events processed.
+ */
+static inline u32 process_events(struct be_net_object *pnob)
+{
+	struct be_adapter *adapter = pnob->adapter;
+	struct EQ_ENTRY_AMAP *eqp;
+	u32 rid, num_events = 0;
+	struct net_device *netdev = pnob->netdev;
+
+	while ((eqp = get_event(pnob)) != NULL) {
+		adapter->be_stat.bes_events++;
+		rid = AMAP_GET_BITS_PTR(EQ_ENTRY, ResourceID, eqp);
+		if (rid == pnob->rx_cq_id) {
+			adapter->be_stat.bes_rx_events++;
+			netif_rx_schedule(netdev, &pnob->napi);
+		} else if (rid == pnob->tx_cq_id) {
+			process_nic_tx_completions(pnob);
+		} else if (rid == pnob->mcc_cq_id) {
+			be_mcc_process_cq(&pnob->mcc_q_obj, 1);
+		} else {
+			dev_info(&netdev->dev,
+					"Invalid EQ ResourceID %d\n", rid);
+		}
+		AMAP_SET_BITS_PTR(EQ_ENTRY, Valid, eqp, 0);
+		AMAP_SET_BITS_PTR(EQ_ENTRY, ResourceID, eqp, 0);
+		num_events++;
+	}
+	return num_events;
+}
+
+static void update_eqd(struct be_adapter *adapter, struct be_net_object *pnob)
+{
+	int status;
+	struct be_eq_object *eq_objectp;
+
+	/* update once a second */
+	if ((jiffies - adapter->ips_jiffies) > 1 * (HZ)) {
+		/* One second elapsed since last update  */
+		u32 r, new_eqd = -1;
+		r = adapter->be_stat.bes_ints - adapter->be_stat.bes_prev_ints;
+		r = r / ((jiffies - adapter->ips_jiffies) / (HZ));
+		adapter->be_stat.bes_ips = r;
+		adapter->ips_jiffies = jiffies;
+		adapter->be_stat.bes_prev_ints = adapter->be_stat.bes_ints;
+		if (r > IPS_HI_WM && adapter->cur_eqd < adapter->max_eqd)
+			new_eqd = (adapter->cur_eqd + 8);
+		if (r < IPS_LO_WM && adapter->cur_eqd > adapter->min_eqd)
+			new_eqd = (adapter->cur_eqd - 8);
+		if (adapter->enable_aic && new_eqd != -1) {
+			eq_objectp = &pnob->event_q_obj;
+			status = be_eq_modify_delay(&pnob->fn_obj, 1,
+						    &eq_objectp, &new_eqd, NULL,
+						    NULL, NULL);
+			if (status == BE_SUCCESS)
+				adapter->cur_eqd = new_eqd;
+		}
+	}
+}
+
+/*
+    This function notifies BladeEngine of how many events were processed
+    from the event queue by ringing the corresponding door bell and
+    optionally re-arms the event queue.
+    n		- number of events processed
+    re_arm	- 1 - re-arm the EQ, 0 - do not re-arm the EQ
+
+*/
+static void be_notify_event(struct be_net_object *pnob, int n, int re_arm)
+{
+	struct CQ_DB_AMAP eqdb;
+	eqdb.dw[0] = 0;
+
+	AMAP_SET_BITS_PTR(CQ_DB, qid, &eqdb, pnob->event_q_id);
+	AMAP_SET_BITS_PTR(CQ_DB, rearm, &eqdb, re_arm);
+	AMAP_SET_BITS_PTR(CQ_DB, event, &eqdb, 1);
+	AMAP_SET_BITS_PTR(CQ_DB, num_popped, &eqdb, n);
+	/*
+	 * Under some situations we see an interrupt and no valid
+	 * EQ entry.  To keep going, we need to ring the DB even if
+	 * numPOsted is 0.
+	 */
+	PD_WRITE(&pnob->fn_obj, cq_db, eqdb.dw[0]);
+	return;
+}
+
+/*
+ * Called from the tasklet scheduled by ISR.  All real interrupt processing
+ * is done here.
+ */
+void be_process_intr(unsigned long context)
+{
+	struct be_adapter *adapter = (struct be_adapter *)context;
+	struct be_net_object *pnob = adapter->net_obj;
+	u32 isr, n;
+	ulong flags = 0;
+
+	isr = adapter->isr;
+
+	/*
+	 * we create only one NIC event queue in Linux. Event is
+	 * expected only in the first event queue
+	 */
+	BUG_ON(isr & 0xfffffffe);
+	if ((isr & 1) == 0)
+		return;		/* not our interrupt */
+	n = process_events(pnob);
+	/*
+	 * Clear the event bit. adapter->isr is  set by
+	 * hard interrupt.  Prevent race with lock.
+	 */
+	spin_lock_irqsave(&adapter->int_lock, flags);
+	adapter->isr &= ~1;
+	spin_unlock_irqrestore(&adapter->int_lock, flags);
+	be_notify_event(pnob, n, 1);
+	/*
+	 * If previous allocation attempts had failed and
+	 * BE has used up all posted buffers, post RX buffers here
+	 */
+	if (pnob->rxbuf_post_fail && atomic_read(&pnob->rx_q_posted) == 0)
+		be_post_eth_rx_buffs(pnob);
+	update_eqd(adapter, pnob);
+	return;
+}
diff --git a/drivers/net/benet/be_netif.c b/drivers/net/benet/be_netif.c
new file mode 100644
index 0000000..2e59044
--- /dev/null
+++ b/drivers/net/benet/be_netif.c
@@ -0,0 +1,706 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+/*
+ * be_netif.c
+ *
+ * This file contains various entry points of drivers seen by tcp/ip stack.
+ */
+
+#include <linux/if_vlan.h>
+#include <linux/in.h>
+#include "benet.h"
+#include <linux/ip.h>
+#include <linux/inet_lro.h>
+
+/* Strings to print Link properties */
+static const char *link_speed[] = {
+	"Invalid link Speed Value",
+	"10 Mbps",
+	"100 Mbps",
+	"1 Gbps",
+	"10 Gbps"
+};
+
+static const char *link_duplex[] = {
+	"Invalid Duplex Value",
+	"Half Duplex",
+	"Full Duplex"
+};
+
+static const char *link_state[] = {
+	"",
+	"(active)"
+};
+
+void be_print_link_info(struct BE_LINK_STATUS *lnk_status)
+{
+	u16 si, di, ai;
+
+	/* Port 0 */
+	if (lnk_status->mac0_speed && lnk_status->mac0_duplex) {
+		/* Port is up and running */
+		si = (lnk_status->mac0_speed < 5) ? lnk_status->mac0_speed : 0;
+		di = (lnk_status->mac0_duplex < 3) ?
+		    lnk_status->mac0_duplex : 0;
+		ai = (lnk_status->active_port == 0) ? 1 : 0;
+		printk(KERN_INFO "PortNo. 0: Speed - %s %s %s\n",
+		       link_speed[si], link_duplex[di], link_state[ai]);
+	} else
+		printk(KERN_INFO "PortNo. 0: Down\n");
+
+	/* Port 1 */
+	if (lnk_status->mac1_speed && lnk_status->mac1_duplex) {
+		/* Port is up and running */
+		si = (lnk_status->mac1_speed < 5) ? lnk_status->mac1_speed : 0;
+		di = (lnk_status->mac1_duplex < 3) ?
+		    lnk_status->mac1_duplex : 0;
+		ai = (lnk_status->active_port == 0) ? 1 : 0;
+		printk(KERN_INFO "PortNo. 1: Speed - %s %s %s\n",
+		       link_speed[si], link_duplex[di], link_state[ai]);
+	} else
+		printk(KERN_INFO "PortNo. 1: Down\n");
+
+	return;
+}
+
+static int
+be_get_frag_header(struct skb_frag_struct *frag, void **mac_hdr,
+		   void **ip_hdr, void **tcpudp_hdr,
+		   u64 *hdr_flags, void *priv)
+{
+	struct ethhdr *eh;
+	struct vlan_ethhdr *veh;
+	struct iphdr *iph;
+	u8 *va = page_address(frag->page) + frag->page_offset;
+	unsigned long ll_hlen;
+
+	/* find the mac header, abort if not IPv4 */
+
+	prefetch(va);
+	eh = (struct ethhdr *)va;
+	*mac_hdr = eh;
+	ll_hlen = ETH_HLEN;
+	if (eh->h_proto != htons(ETH_P_IP)) {
+		if (eh->h_proto == htons(ETH_P_8021Q)) {
+			veh = (struct vlan_ethhdr *)va;
+			if (veh->h_vlan_encapsulated_proto != htons(ETH_P_IP))
+				return -1;
+
+			ll_hlen += VLAN_HLEN;
+
+		} else {
+			return -1;
+		}
+	}
+	*hdr_flags = LRO_IPV4;
+
+	iph = (struct iphdr *)(va + ll_hlen);
+	*ip_hdr = iph;
+	if (iph->protocol != IPPROTO_TCP)
+		return -1;
+	*hdr_flags |= LRO_TCP;
+	*tcpudp_hdr = (u8 *) (*ip_hdr) + (iph->ihl << 2);
+
+	return 0;
+}
+
+static int benet_open(struct net_device *netdev)
+{
+	struct be_net_object *pnob = (struct be_net_object *)netdev->priv;
+	struct be_adapter *adapter = pnob->adapter;
+	struct net_lro_mgr *lro_mgr;
+
+	if (adapter->dev_state < BE_DEV_STATE_INIT)
+		return -EAGAIN;
+
+	lro_mgr = &pnob->lro_mgr;
+	lro_mgr->dev = netdev;
+
+	lro_mgr->features = LRO_F_NAPI;
+	lro_mgr->ip_summed = CHECKSUM_UNNECESSARY;
+	lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
+	lro_mgr->max_desc = BE_MAX_LRO_DESCRIPTORS;
+	lro_mgr->lro_arr = pnob->lro_desc;
+	lro_mgr->get_frag_header = be_get_frag_header;
+	lro_mgr->max_aggr = adapter->max_rx_coal;
+	lro_mgr->frag_align_pad = 2;
+	if (lro_mgr->max_aggr > MAX_SKB_FRAGS)
+		lro_mgr->max_aggr = MAX_SKB_FRAGS;
+
+	adapter->max_rx_coal = BE_LRO_MAX_PKTS;
+
+	be_update_link_status(adapter);
+
+	/*
+	 * Set carrier on only if Physical Link up
+	 * Either of the port link status up signifies this
+	 */
+	if ((adapter->port0_link_sts == BE_PORT_LINK_UP) ||
+	    (adapter->port1_link_sts == BE_PORT_LINK_UP)) {
+		netif_start_queue(netdev);
+		netif_carrier_on(netdev);
+	}
+
+	adapter->dev_state = BE_DEV_STATE_OPEN;
+	napi_enable(&pnob->napi);
+	be_enable_intr(pnob);
+	be_enable_eq_intr(pnob);
+	/*
+	 * RX completion queue may be in dis-armed state. Arm it.
+	 */
+	be_notify_cmpl(pnob, 0, pnob->rx_cq_id, 1);
+
+	return 0;
+}
+
+static int benet_close(struct net_device *netdev)
+{
+	struct be_net_object *pnob = (struct be_net_object *)netdev->priv;
+	struct be_adapter *adapter = pnob->adapter;
+
+	netif_stop_queue(netdev);
+	synchronize_irq(netdev->irq);
+
+	be_wait_nic_tx_cmplx_cmpl(pnob);
+	adapter->dev_state = BE_DEV_STATE_INIT;
+	netif_carrier_off(netdev);
+
+	adapter->port0_link_sts = BE_PORT_LINK_DOWN;
+	adapter->port1_link_sts = BE_PORT_LINK_DOWN;
+	be_disable_intr(pnob);
+	be_disable_eq_intr(pnob);
+	napi_disable(&pnob->napi);
+
+	return 0;
+}
+
+/*
+ * Setting a Mac Address for BE
+ * Takes netdev and a void pointer as arguments.
+ * The pointer holds the new addres to be used.
+ */
+static int benet_set_mac_addr(struct net_device *netdev, void *p)
+{
+	struct sockaddr *addr = p;
+	struct be_net_object *pnob;
+
+	pnob = (struct be_net_object *)netdev->priv;
+
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+	be_rxf_mac_address_read_write(&pnob->fn_obj, 0, 0, false, true, false,
+				netdev->dev_addr, NULL, NULL);
+	/*
+	 * Since we are doing Active-Passive failover, both
+	 * ports should have matching MAC addresses everytime.
+	 */
+	be_rxf_mac_address_read_write(&pnob->fn_obj, 1, 0, false, true, false,
+				      netdev->dev_addr, NULL, NULL);
+
+	return 0;
+}
+
+void be_get_stats_timer_handler(unsigned long context)
+{
+	struct be_timer_ctxt *ctxt = (struct be_timer_ctxt *)context;
+
+	if (atomic_read(&ctxt->get_stat_flag)) {
+		atomic_dec(&ctxt->get_stat_flag);
+		up((void *)ctxt->get_stat_sem_addr);
+	}
+	del_timer(&ctxt->get_stats_timer);
+	return;
+}
+
+void be_get_stat_cb(void *context, int status,
+		    struct MCC_WRB_AMAP *optional_wrb)
+{
+	struct be_timer_ctxt *ctxt = (struct be_timer_ctxt *)context;
+	/*
+	 * just up the semaphore if the get_stat_flag
+	 * reads 1. so that the waiter can continue.
+	 * If it is 0, then it was handled by the timer handler.
+	 */
+	del_timer(&ctxt->get_stats_timer);
+	if (atomic_read(&ctxt->get_stat_flag)) {
+		atomic_dec(&ctxt->get_stat_flag);
+		up((void *)ctxt->get_stat_sem_addr);
+	}
+}
+
+struct net_device_stats *benet_get_stats(struct net_device *dev)
+{
+	struct be_net_object *pnob = dev->priv;
+	struct be_adapter *adapter = pnob->adapter;
+	u64 pa;
+	struct be_timer_ctxt *ctxt = &adapter->timer_ctxt;
+
+	if (adapter->dev_state != BE_DEV_STATE_OPEN) {
+		/* Return previously read stats */
+		return &(adapter->benet_stats);
+	}
+	/* Get Physical Addr */
+	pa = pci_map_single(adapter->pdev, adapter->eth_statsp,
+			    sizeof(struct FWCMD_ETH_GET_STATISTICS),
+			    PCI_DMA_FROMDEVICE);
+	ctxt->get_stat_sem_addr = (unsigned long)&adapter->get_eth_stat_sem;
+	atomic_inc(&ctxt->get_stat_flag);
+
+	be_rxf_query_eth_statistics(&pnob->fn_obj, adapter->eth_statsp,
+				    cpu_to_le64(pa), be_get_stat_cb, ctxt,
+				    NULL);
+
+	ctxt->get_stats_timer.data = (unsigned long)ctxt;
+	mod_timer(&ctxt->get_stats_timer, (jiffies + (HZ * 2)));
+	down((void *)ctxt->get_stat_sem_addr);	/* callback will unblock us */
+
+	/* Adding port0 and port1 stats. */
+	adapter->benet_stats.rx_packets =
+	    adapter->eth_statsp->params.response.p0recvdtotalframes +
+	    adapter->eth_statsp->params.response.p1recvdtotalframes;
+	adapter->benet_stats.tx_packets =
+	    adapter->eth_statsp->params.response.p0xmitunicastframes +
+	    adapter->eth_statsp->params.response.p1xmitunicastframes;
+	adapter->benet_stats.tx_bytes =
+	    adapter->eth_statsp->params.response.p0xmitbyteslsd +
+	    adapter->eth_statsp->params.response.p1xmitbyteslsd;
+	adapter->benet_stats.rx_errors =
+	    adapter->eth_statsp->params.response.p0crcerrors +
+	    adapter->eth_statsp->params.response.p1crcerrors;
+	adapter->benet_stats.rx_errors +=
+	    adapter->eth_statsp->params.response.p0alignmentsymerrs +
+	    adapter->eth_statsp->params.response.p1alignmentsymerrs;
+	adapter->benet_stats.rx_errors +=
+	    adapter->eth_statsp->params.response.p0inrangelenerrors +
+	    adapter->eth_statsp->params.response.p1inrangelenerrors;
+	adapter->benet_stats.rx_bytes =
+	    adapter->eth_statsp->params.response.p0recvdtotalbytesLSD +
+	    adapter->eth_statsp->params.response.p1recvdtotalbytesLSD;
+	adapter->benet_stats.rx_crc_errors =
+	    adapter->eth_statsp->params.response.p0crcerrors +
+	    adapter->eth_statsp->params.response.p1crcerrors;
+
+	adapter->benet_stats.tx_packets +=
+	    adapter->eth_statsp->params.response.p0xmitmulticastframes +
+	    adapter->eth_statsp->params.response.p1xmitmulticastframes;
+	adapter->benet_stats.tx_packets +=
+	    adapter->eth_statsp->params.response.p0xmitbroadcastframes +
+	    adapter->eth_statsp->params.response.p1xmitbroadcastframes;
+	adapter->benet_stats.tx_errors = 0;
+
+	adapter->benet_stats.multicast =
+	    adapter->eth_statsp->params.response.p0xmitmulticastframes +
+	    adapter->eth_statsp->params.response.p1xmitmulticastframes;
+
+	adapter->benet_stats.rx_fifo_errors =
+	    adapter->eth_statsp->params.response.p0rxfifooverflowdropped +
+	    adapter->eth_statsp->params.response.p1rxfifooverflowdropped;
+	adapter->benet_stats.rx_frame_errors =
+	    adapter->eth_statsp->params.response.p0alignmentsymerrs +
+	    adapter->eth_statsp->params.response.p1alignmentsymerrs;
+	adapter->benet_stats.rx_length_errors =
+	    adapter->eth_statsp->params.response.p0inrangelenerrors +
+	    adapter->eth_statsp->params.response.p1inrangelenerrors;
+	adapter->benet_stats.rx_length_errors +=
+	    adapter->eth_statsp->params.response.p0outrangeerrors +
+	    adapter->eth_statsp->params.response.p1outrangeerrors;
+	adapter->benet_stats.rx_length_errors +=
+	    adapter->eth_statsp->params.response.p0frametoolongerrors +
+	    adapter->eth_statsp->params.response.p1frametoolongerrors;
+
+	pci_unmap_single(adapter->pdev, (ulong) adapter->eth_statsp,
+			 sizeof(struct FWCMD_ETH_GET_STATISTICS),
+			 PCI_DMA_FROMDEVICE);
+	return &(adapter->benet_stats);
+
+}
+
+static void be_start_tx(struct be_net_object *pnob, u32 nposted)
+{
+#define CSR_ETH_MAX_SQPOSTS 255
+	struct SQ_DB_AMAP sqdb;
+
+	sqdb.dw[0] = 0;
+
+	AMAP_SET_BITS_PTR(SQ_DB, cid, &sqdb, pnob->tx_q_id);
+	while (nposted) {
+		if (nposted > CSR_ETH_MAX_SQPOSTS) {
+			AMAP_SET_BITS_PTR(SQ_DB, numPosted, &sqdb,
+					  CSR_ETH_MAX_SQPOSTS);
+			nposted -= CSR_ETH_MAX_SQPOSTS;
+		} else {
+			AMAP_SET_BITS_PTR(SQ_DB, numPosted, &sqdb, nposted);
+			nposted = 0;
+		}
+		PD_WRITE(&pnob->fn_obj, etx_sq_db, sqdb.dw[0]);
+	}
+
+	return;
+}
+
+static void update_tx_rate(struct be_adapter *adapter)
+{
+	/* update the rate once in two seconds */
+	if ((jiffies - adapter->eth_tx_jiffies) > 2 * (HZ)) {
+		u32 r;
+		r = adapter->eth_tx_bytes /
+		    ((jiffies - adapter->eth_tx_jiffies) / (HZ));
+		r = (r / 1000000);	/* M bytes/s */
+		adapter->be_stat.bes_eth_tx_rate = (r * 8); /* M bits/s */
+		adapter->eth_tx_jiffies = jiffies;
+		adapter->eth_tx_bytes = 0;
+	}
+}
+
+static int wrb_cnt_in_skb(struct sk_buff *skb)
+{
+	int cnt = 0;
+	while (skb) {
+		if (skb->len > skb->data_len)
+			cnt++;
+		cnt += skb_shinfo(skb)->nr_frags;
+		skb = skb_shinfo(skb)->frag_list;
+	}
+	BUG_ON(cnt > BE_MAX_TX_FRAG_COUNT);
+	return cnt;
+}
+
+static void wrb_fill(struct ETH_WRB_AMAP *wrb, u64 addr, int len)
+{
+	AMAP_SET_BITS_PTR(ETH_WRB, frag_pa_hi, wrb, addr >> 32);
+	AMAP_SET_BITS_PTR(ETH_WRB, frag_pa_lo, wrb, addr & 0xFFFFFFFF);
+	AMAP_SET_BITS_PTR(ETH_WRB, frag_len, wrb, len);
+}
+
+static void wrb_fill_extra(struct ETH_WRB_AMAP *wrb, struct sk_buff *skb,
+			   struct be_net_object *pnob)
+{
+	wrb->dw[2] = wrb->dw[3] = 0;
+	AMAP_SET_BITS_PTR(ETH_WRB, crc, wrb, 1);
+	if (skb_shinfo(skb)->gso_segs > 1 && skb_shinfo(skb)->gso_size) {
+		AMAP_SET_BITS_PTR(ETH_WRB, lso, wrb, 1);
+		AMAP_SET_BITS_PTR(ETH_WRB, lso_mss, wrb,
+				  skb_shinfo(skb)->gso_size);
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		u8 proto = ((struct iphdr *)ip_hdr(skb))->protocol;
+		if (proto == IPPROTO_TCP)
+			AMAP_SET_BITS_PTR(ETH_WRB, tcpcs, wrb, 1);
+		else if (proto == IPPROTO_UDP)
+			AMAP_SET_BITS_PTR(ETH_WRB, udpcs, wrb, 1);
+	}
+	if (pnob->vlan_grp && vlan_tx_tag_present(skb)) {
+		AMAP_SET_BITS_PTR(ETH_WRB, vlan, wrb, 1);
+		AMAP_SET_BITS_PTR(ETH_WRB, vlan_tag, wrb, vlan_tx_tag_get(skb));
+	}
+}
+
+static inline void wrb_copy_extra(struct ETH_WRB_AMAP *to,
+				  struct ETH_WRB_AMAP *from)
+{
+
+	to->dw[2] = from->dw[2];
+	to->dw[3] = from->dw[3];
+}
+
+/* Returns the actual count of wrbs used including a possible dummy */
+static int copy_skb_to_txq(struct be_net_object *pnob, struct sk_buff *skb,
+			   u32 wrb_cnt, u32 *copied)
+{
+	u64 busaddr;
+	struct ETH_WRB_AMAP *wrb = NULL, *first = NULL;
+	u32 i;
+	bool dummy = true;
+	struct pci_dev *pdev = pnob->adapter->pdev;
+
+	if (wrb_cnt & 1)
+		wrb_cnt++;
+	else
+		dummy = false;
+
+	atomic_add(wrb_cnt, &pnob->tx_q_used);
+
+	while (skb) {
+		if (skb->len > skb->data_len) {
+			int len = skb->len - skb->data_len;
+			busaddr = pci_map_single(pdev, skb->data, len,
+						 PCI_DMA_TODEVICE);
+			busaddr = cpu_to_le64(busaddr);
+			wrb = &pnob->tx_q[pnob->tx_q_hd];
+			if (first == NULL) {
+				wrb_fill_extra(wrb, skb, pnob);
+				first = wrb;
+			} else {
+				wrb_copy_extra(wrb, first);
+			}
+			wrb_fill(wrb, busaddr, len);
+			be_adv_txq_hd(pnob);
+			*copied += len;
+		}
+
+		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+			struct skb_frag_struct *frag =
+			    &skb_shinfo(skb)->frags[i];
+			busaddr = pci_map_page(pdev, frag->page,
+					       frag->page_offset, frag->size,
+					       PCI_DMA_TODEVICE);
+			busaddr = cpu_to_le64(busaddr);
+			wrb = &pnob->tx_q[pnob->tx_q_hd];
+			if (first == NULL) {
+				wrb_fill_extra(wrb, skb, pnob);
+				first = wrb;
+			} else {
+				wrb_copy_extra(wrb, first);
+			}
+			wrb_fill(wrb, busaddr, frag->size);
+			be_adv_txq_hd(pnob);
+			*copied += frag->size;
+		}
+		skb = skb_shinfo(skb)->frag_list;
+	}
+
+	if (dummy) {
+		wrb = &pnob->tx_q[pnob->tx_q_hd];
+		BUG_ON(first == NULL);
+		wrb_copy_extra(wrb, first);
+		wrb_fill(wrb, 0, 0);
+		be_adv_txq_hd(pnob);
+	}
+	AMAP_SET_BITS_PTR(ETH_WRB, complete, wrb, 1);
+	AMAP_SET_BITS_PTR(ETH_WRB, last, wrb, 1);
+	return wrb_cnt;
+}
+
+/* For each skb transmitted, tx_ctxt stores the num of wrbs in the
+ * start index and skb pointer in the end index
+ */
+static inline void be_tx_wrb_info_remember(struct be_net_object *pnob,
+					   struct sk_buff *skb, int wrb_cnt,
+					   u32 start)
+{
+	*(u32 *) (&pnob->tx_ctxt[start]) = wrb_cnt;
+	index_adv(&start, wrb_cnt - 1, pnob->tx_q_len);
+	pnob->tx_ctxt[start] = skb;
+}
+
+static int benet_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct be_net_object *pnob = netdev->priv;
+	struct be_adapter *adapter = pnob->adapter;
+	u32 wrb_cnt, copied = 0;
+	u32 start = pnob->tx_q_hd;
+
+	adapter->be_stat.bes_tx_reqs++;
+
+	wrb_cnt = wrb_cnt_in_skb(skb);
+	spin_lock_bh(&adapter->txq_lock);
+	if ((pnob->tx_q_len - 2 - atomic_read(&pnob->tx_q_used)) <= wrb_cnt) {
+		netif_stop_queue(pnob->netdev);
+		spin_unlock_bh(&adapter->txq_lock);
+		adapter->be_stat.bes_tx_fails++;
+		return NETDEV_TX_BUSY;
+	}
+	spin_unlock_bh(&adapter->txq_lock);
+
+	wrb_cnt = copy_skb_to_txq(pnob, skb, wrb_cnt, &copied);
+	be_tx_wrb_info_remember(pnob, skb, wrb_cnt, start);
+
+	be_start_tx(pnob, wrb_cnt);
+
+	adapter->eth_tx_bytes += copied;
+	adapter->be_stat.bes_tx_wrbs += wrb_cnt;
+	update_tx_rate(adapter);
+	netdev->trans_start = jiffies;
+
+	return NETDEV_TX_OK;
+}
+
+/*
+ * This is the driver entry point to change the mtu of the device
+ * Returns 0 for success and errno for failure.
+ */
+static int benet_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	/*
+	 * BE supports jumbo frame size upto 9000 bytes including the link layer
+	 * header. Considering the different variants of frame formats possible
+	 * like VLAN, SNAP/LLC, the maximum possible value for MTU is 8974 bytes
+	 */
+
+	if (new_mtu < (ETH_ZLEN + ETH_FCS_LEN) || (new_mtu > BE_MAX_MTU)) {
+		dev_info(&netdev->dev, "Invalid MTU requested. "
+			       "Must be between %d and %d bytes\n",
+				       (ETH_ZLEN + ETH_FCS_LEN), BE_MAX_MTU);
+		return -EINVAL;
+	}
+	dev_info(&netdev->dev, "MTU changed from %d to %d\n",
+						netdev->mtu, new_mtu);
+	netdev->mtu = new_mtu;
+	return 0;
+}
+
+/*
+ * This is the driver entry point to register a vlan with the device
+ */
+static void benet_vlan_register(struct net_device *netdev,
+				struct vlan_group *grp)
+{
+	struct be_net_object *pnob = netdev->priv;
+
+	be_disable_eq_intr(pnob);
+	pnob->vlan_grp = grp;
+	pnob->num_vlans = 0;
+	be_enable_eq_intr(pnob);
+}
+
+/*
+ * This is the driver entry point to add a vlan vlan_id
+ * with the device netdev
+ */
+static void benet_vlan_add_vid(struct net_device *netdev, u16 vlan_id)
+{
+	struct be_net_object *pnob = netdev->priv;
+
+	if (pnob->num_vlans == (BE_NUM_VLAN_SUPPORTED - 1)) {
+		/* no  way to return an error */
+		dev_info(&netdev->dev,
+		       "BladeEngine: Cannot configure more than %d Vlans\n",
+			       BE_NUM_VLAN_SUPPORTED);
+		return;
+	}
+	/* The new vlan tag will be in the slot indicated by num_vlans. */
+	pnob->vlan_tag[pnob->num_vlans++] = vlan_id;
+	be_rxf_vlan_config(&pnob->fn_obj, false, pnob->num_vlans,
+			   pnob->vlan_tag, NULL, NULL, NULL);
+}
+
+/*
+ * This is the driver entry point to remove a vlan vlan_id
+ * with the device netdev
+ */
+static void benet_vlan_rem_vid(struct net_device *netdev, u16 vlan_id)
+{
+	struct be_net_object *pnob = netdev->priv;
+
+	u32 i, value;
+
+	/*
+	 * In Blade Engine, we support 32 vlan tag filters across both ports.
+	 * To program a vlan tag, the RXF_RTPR_CSR register is used.
+	 * Each 32-bit value of RXF_RTDR_CSR can address 2 vlan tag entries.
+	 * The Vlan table is of depth 16. thus we support 32 tags.
+	 */
+
+	value = vlan_id | VLAN_VALID_BIT;
+	for (i = 0; i < BE_NUM_VLAN_SUPPORTED; i++) {
+		if (pnob->vlan_tag[i] == vlan_id)
+			break;
+	}
+
+	if (i == BE_NUM_VLAN_SUPPORTED)
+		return;
+	/* Now compact the vlan tag array by removing hole created. */
+	while ((i + 1) < BE_NUM_VLAN_SUPPORTED) {
+		pnob->vlan_tag[i] = pnob->vlan_tag[i + 1];
+		i++;
+	}
+	if ((i + 1) == BE_NUM_VLAN_SUPPORTED)
+		pnob->vlan_tag[i] = (u16) 0x0;
+	pnob->num_vlans--;
+	be_rxf_vlan_config(&pnob->fn_obj, false, pnob->num_vlans,
+			   pnob->vlan_tag, NULL, NULL, NULL);
+}
+
+/*
+ * This function is called to program multicast
+ * address in the multicast filter of the ASIC.
+ */
+static void be_set_multicast_filter(struct net_device *netdev)
+{
+	struct be_net_object *pnob = netdev->priv;
+	struct dev_mc_list *mc_ptr;
+	u8 mac_addr[32][ETH_ALEN];
+	int i;
+
+	if (netdev->flags & IFF_ALLMULTI) {
+		/* set BE in Multicast promiscuous */
+		be_rxf_multicast_config(&pnob->fn_obj, true, 0, NULL, NULL,
+					NULL, NULL);
+		return;
+	}
+
+	for (mc_ptr = netdev->mc_list, i = 0; mc_ptr;
+	     mc_ptr = mc_ptr->next, i++) {
+		memcpy(&mac_addr[i][0], mc_ptr->dmi_addr, ETH_ALEN);
+	}
+
+	/* reset the promiscuous mode also. */
+	be_rxf_multicast_config(&pnob->fn_obj, false, i,
+				&mac_addr[0][0], NULL, NULL, NULL);
+}
+
+/*
+ * This is the driver entry point to set multicast list
+ * with the device netdev. This function will be used to
+ * set promiscuous mode or multicast promiscuous mode
+ * or multicast mode....
+ */
+static void benet_set_multicast_list(struct net_device *netdev)
+{
+	struct be_net_object *pnob = netdev->priv;
+
+	if (netdev->flags & IFF_PROMISC) {
+		be_rxf_promiscuous(&pnob->fn_obj, 1, 1, NULL, NULL, NULL);
+	} else {
+		be_rxf_promiscuous(&pnob->fn_obj, 0, 0, NULL, NULL, NULL);
+		be_set_multicast_filter(netdev);
+	}
+}
+
+int benet_init(struct net_device *netdev)
+{
+	struct be_net_object *pnob = netdev->priv;
+	struct be_adapter *adapter = pnob->adapter;
+
+	ether_setup(netdev);
+
+	netdev->open = &benet_open;
+	netdev->stop = &benet_close;
+	netdev->hard_start_xmit = &benet_xmit;
+
+	netdev->get_stats = &benet_get_stats;
+
+	netdev->set_multicast_list = &benet_set_multicast_list;
+
+	netdev->change_mtu = &benet_change_mtu;
+	netdev->set_mac_address = &benet_set_mac_addr;
+
+	netdev->vlan_rx_register = benet_vlan_register;
+	netdev->vlan_rx_add_vid = benet_vlan_add_vid;
+	netdev->vlan_rx_kill_vid = benet_vlan_rem_vid;
+
+	netdev->features =
+	    NETIF_F_SG | NETIF_F_HIGHDMA | NETIF_F_HW_VLAN_RX | NETIF_F_TSO |
+	    NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER | NETIF_F_IP_CSUM;
+
+	netdev->flags |= IFF_MULTICAST;
+
+	/* If device is DAC Capable, set the HIGHDMA flag for netdevice. */
+	if (adapter->dma_64bit_cap)
+		netdev->features |= NETIF_F_HIGHDMA;
+
+	SET_ETHTOOL_OPS(netdev, &be_ethtool_ops);
+	return 0;
+}
-- 
1.5.5

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

