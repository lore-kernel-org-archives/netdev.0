From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Subject: [PATCH rdma-next v1 10/12] IB/hfi1: OPA_VNIC RDMA netdev support
Date: Tue, 11 Apr 2017 23:40:05 -0700
Message-ID: <1491979207-18686-11-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1491979207-18686-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com, ira.weiny@intel.com,
        Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>,
        Andrzej Kacprowski <andrzej.kacprowski@intel.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:16281 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752547AbdDLGkY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 02:40:24 -0400
In-Reply-To: <1491979207-18686-1-git-send-email-niranjana.vishwanathapura@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to create and free OPA_VNIC rdma netdev devices.
Implement netstack interface functionality including xmit_skb,
receive side NAPI etc. Also implement rdma netdev control functions.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro@intel.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura@intel.com>
Signed-off-by: Andrzej Kacprowski <andrzej.kacprowski@intel.com>
---
 drivers/infiniband/hw/hfi1/Makefile    |   2 +-
 drivers/infiniband/hw/hfi1/driver.c    |  25 +-
 drivers/infiniband/hw/hfi1/hfi.h       |  27 +-
 drivers/infiniband/hw/hfi1/init.c      |   9 +-
 drivers/infiniband/hw/hfi1/vnic.h      | 153 ++++++++
 drivers/infiniband/hw/hfi1/vnic_main.c | 644 +++++++++++++++++++++++++++++++++
 6 files changed, 853 insertions(+), 7 deletions(-)
 create mode 100644 drivers/infiniband/hw/hfi1/vnic.h
 create mode 100644 drivers/infiniband/hw/hfi1/vnic_main.c

diff --git a/drivers/infiniband/hw/hfi1/Makefile b/drivers/infiniband/hw/hfi1/Makefile
index 0cf97a0..2280538 100644
--- a/drivers/infiniband/hw/hfi1/Makefile
+++ b/drivers/infiniband/hw/hfi1/Makefile
@@ -12,7 +12,7 @@ hfi1-y := affinity.o chip.o device.o driver.o efivar.o \
 	init.o intr.o mad.o mmu_rb.o pcie.o pio.o pio_copy.o platform.o \
 	qp.o qsfp.o rc.o ruc.o sdma.o sysfs.o trace.o \
 	uc.o ud.o user_exp_rcv.o user_pages.o user_sdma.o verbs.o \
-	verbs_txreq.o
+	verbs_txreq.o vnic_main.o
 hfi1-$(CONFIG_DEBUG_FS) += debugfs.o
 
 CFLAGS_trace.o = -I$(src)
diff --git a/drivers/infiniband/hw/hfi1/driver.c b/drivers/infiniband/hw/hfi1/driver.c
index 64bdbce..e4dc6a5 100644
--- a/drivers/infiniband/hw/hfi1/driver.c
+++ b/drivers/infiniband/hw/hfi1/driver.c
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 2015, 2016 Intel Corporation.
+ * Copyright(c) 2015-2017 Intel Corporation.
  *
  * This file is provided under a dual BSD/GPLv2 license.  When using or
  * redistributing this file, you may do so under either license.
@@ -60,6 +60,7 @@
 #include "qp.h"
 #include "sdma.h"
 #include "debugfs.h"
+#include "vnic.h"
 
 #undef pr_fmt
 #define pr_fmt(fmt) DRIVER_NAME ": " fmt
@@ -1381,15 +1382,31 @@ int process_receive_ib(struct hfi1_packet *packet)
 	return RHF_RCV_CONTINUE;
 }
 
+static inline bool hfi1_is_vnic_packet(struct hfi1_packet *packet)
+{
+	/* Packet received in VNIC context via RSM */
+	if (packet->rcd->is_vnic)
+		return true;
+
+	if ((HFI1_GET_L2_TYPE(packet->ebuf) == OPA_VNIC_L2_TYPE) &&
+	    (HFI1_GET_L4_TYPE(packet->ebuf) == OPA_VNIC_L4_ETHR))
+		return true;
+
+	return false;
+}
+
 int process_receive_bypass(struct hfi1_packet *packet)
 {
 	struct hfi1_devdata *dd = packet->rcd->dd;
 
-	if (unlikely(rhf_err_flags(packet->rhf)))
+	if (unlikely(rhf_err_flags(packet->rhf))) {
 		handle_eflags(packet);
+	} else if (hfi1_is_vnic_packet(packet)) {
+		hfi1_vnic_bypass_rcv(packet);
+		return RHF_RCV_CONTINUE;
+	}
 
-	dd_dev_err(dd,
-		   "Bypass packets are not supported in normal operation. Dropping\n");
+	dd_dev_err(dd, "Unsupported bypass packet. Dropping\n");
 	incr_cntr64(&dd->sw_rcv_bypass_packet_errors);
 	if (!(dd->err_info_rcvport.status_and_code & OPA_EI_STATUS_SMASK)) {
 		u64 *flits = packet->ebuf;
diff --git a/drivers/infiniband/hw/hfi1/hfi.h b/drivers/infiniband/hw/hfi1/hfi.h
index a31638c..f85e8f4 100644
--- a/drivers/infiniband/hw/hfi1/hfi.h
+++ b/drivers/infiniband/hw/hfi1/hfi.h
@@ -1,7 +1,7 @@
 #ifndef _HFI1_KERNEL_H
 #define _HFI1_KERNEL_H
 /*
- * Copyright(c) 2015, 2016 Intel Corporation.
+ * Copyright(c) 2015-2017 Intel Corporation.
  *
  * This file is provided under a dual BSD/GPLv2 license.  When using or
  * redistributing this file, you may do so under either license.
@@ -337,6 +337,12 @@ struct hfi1_ctxtdata {
 	 * packets with the wrong interrupt handler.
 	 */
 	int (*do_interrupt)(struct hfi1_ctxtdata *rcd, int threaded);
+
+	/* Indicates that this is vnic context */
+	bool is_vnic;
+
+	/* vnic queue index this context is mapped to */
+	u8 vnic_q_idx;
 };
 
 /*
@@ -808,6 +814,19 @@ struct hfi1_asic_data {
 	struct hfi1_i2c_bus *i2c_bus1;
 };
 
+/*
+ * Number of VNIC contexts used. Ensure it is less than or equal to
+ * max queues supported by VNIC (HFI1_VNIC_MAX_QUEUE).
+ */
+#define HFI1_NUM_VNIC_CTXT   8
+
+/* Virtual NIC information */
+struct hfi1_vnic_data {
+	struct idr vesw_idr;
+};
+
+struct hfi1_vnic_vport_info;
+
 /* device data struct now contains only "general per-device" info.
  * fields related to a physical IB port are in a hfi1_pportdata struct.
  */
@@ -1115,6 +1134,9 @@ struct hfi1_devdata {
 	send_routine process_dma_send;
 	void (*pio_inline_send)(struct hfi1_devdata *dd, struct pio_buf *pbuf,
 				u64 pbc, const void *from, size_t count);
+	int (*process_vnic_dma_send)(struct hfi1_devdata *dd, u8 q_idx,
+				     struct hfi1_vnic_vport_info *vinfo,
+				     struct sk_buff *skb, u64 pbc, u8 plen);
 	/* hfi1_pportdata, points to array of (physical) port-specific
 	 * data structs, indexed by pidx (0..n-1)
 	 */
@@ -1170,6 +1192,9 @@ struct hfi1_devdata {
 	struct rhashtable *sdma_rht;
 
 	struct kobject kobj;
+
+	/* vnic data */
+	struct hfi1_vnic_data vnic;
 };
 
 /* 8051 firmware version helper */
diff --git a/drivers/infiniband/hw/hfi1/init.c b/drivers/infiniband/hw/hfi1/init.c
index 9bfb8eb..e84f95d 100644
--- a/drivers/infiniband/hw/hfi1/init.c
+++ b/drivers/infiniband/hw/hfi1/init.c
@@ -1,5 +1,5 @@
 /*
- * Copyright(c) 2015, 2016 Intel Corporation.
+ * Copyright(c) 2015-2017 Intel Corporation.
  *
  * This file is provided under a dual BSD/GPLv2 license.  When using or
  * redistributing this file, you may do so under either license.
@@ -65,6 +65,7 @@
 #include "verbs.h"
 #include "aspm.h"
 #include "affinity.h"
+#include "vnic.h"
 
 #undef pr_fmt
 #define pr_fmt(fmt) DRIVER_NAME ": " fmt
@@ -1498,6 +1499,9 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* do the generic initialization */
 	initfail = hfi1_init(dd, 0);
 
+	/* setup vnic */
+	hfi1_vnic_setup(dd);
+
 	ret = hfi1_register_ib_device(dd);
 
 	/*
@@ -1575,6 +1579,9 @@ static void remove_one(struct pci_dev *pdev)
 	/* unregister from IB core */
 	hfi1_unregister_ib_device(dd);
 
+	/* cleanup vnic */
+	hfi1_vnic_cleanup(dd);
+
 	/*
 	 * Disable the IB link, disable interrupts on the device,
 	 * clear dma engines, etc.
diff --git a/drivers/infiniband/hw/hfi1/vnic.h b/drivers/infiniband/hw/hfi1/vnic.h
new file mode 100644
index 0000000..04723b1
--- /dev/null
+++ b/drivers/infiniband/hw/hfi1/vnic.h
@@ -0,0 +1,153 @@
+#ifndef _HFI1_VNIC_H
+#define _HFI1_VNIC_H
+/*
+ * Copyright(c) 2017 Intel Corporation.
+ *
+ * This file is provided under a dual BSD/GPLv2 license.  When using or
+ * redistributing this file, you may do so under either license.
+ *
+ * GPL LICENSE SUMMARY
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * BSD LICENSE
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *  - Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ *  - Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *  - Neither the name of Intel Corporation nor the names of its
+ *    contributors may be used to endorse or promote products derived
+ *    from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+#include <rdma/opa_vnic.h>
+#include "hfi.h"
+
+#define HFI1_VNIC_MAX_TXQ     16
+#define HFI1_VNIC_MAX_PAD     12
+
+/* L2 header definitions */
+#define HFI1_L2_TYPE_OFFSET     0x7
+#define HFI1_L2_TYPE_SHFT       0x5
+#define HFI1_L2_TYPE_MASK       0x3
+
+#define HFI1_GET_L2_TYPE(hdr)                                            \
+	((*((u8 *)(hdr) + HFI1_L2_TYPE_OFFSET) >> HFI1_L2_TYPE_SHFT) &   \
+	 HFI1_L2_TYPE_MASK)
+
+/* L4 type definitions */
+#define HFI1_L4_TYPE_OFFSET 8
+
+#define HFI1_GET_L4_TYPE(data)   \
+	(*((u8 *)(data) + HFI1_L4_TYPE_OFFSET))
+
+/* L4 header definitions */
+#define HFI1_VNIC_L4_HDR_OFFSET  OPA_VNIC_L2_HDR_LEN
+
+#define HFI1_VNIC_GET_L4_HDR(data)   \
+	(*((u16 *)((u8 *)(data) + HFI1_VNIC_L4_HDR_OFFSET)))
+
+#define HFI1_VNIC_GET_VESWID(data)   \
+	(HFI1_VNIC_GET_L4_HDR(data) & 0xFFF)
+
+/* Service class */
+#define HFI1_VNIC_SC_OFFSET_LOW 6
+#define HFI1_VNIC_SC_OFFSET_HI  7
+#define HFI1_VNIC_SC_SHIFT      4
+
+#define HFI1_VNIC_MAX_QUEUE 16
+
+/**
+ * struct hfi1_vnic_rx_queue - HFI1 VNIC receive queue
+ * @idx: queue index
+ * @vinfo: pointer to vport information
+ * @netdev: network device
+ * @napi: netdev napi structure
+ * @skbq: queue of received socket buffers
+ */
+struct hfi1_vnic_rx_queue {
+	u8                           idx;
+	struct hfi1_vnic_vport_info *vinfo;
+	struct net_device           *netdev;
+	struct napi_struct           napi;
+	struct sk_buff_head          skbq;
+};
+
+/**
+ * struct hfi1_vnic_vport_info - HFI1 VNIC virtual port information
+ * @dd: device data pointer
+ * @netdev: net device pointer
+ * @flags: state flags
+ * @lock: vport lock
+ * @num_tx_q: number of transmit queues
+ * @num_rx_q: number of receive queues
+ * @vesw_id: virtual switch id
+ * @rxq: Array of receive queues
+ * @stats: per queue stats
+ */
+struct hfi1_vnic_vport_info {
+	struct hfi1_devdata *dd;
+	struct net_device   *netdev;
+	unsigned long        flags;
+
+	/* Lock used around state updates */
+	struct mutex         lock;
+
+	u8  num_tx_q;
+	u8  num_rx_q;
+	u16 vesw_id;
+	struct hfi1_vnic_rx_queue rxq[HFI1_NUM_VNIC_CTXT];
+
+	struct opa_vnic_stats  stats[HFI1_VNIC_MAX_QUEUE];
+};
+
+#define v_dbg(format, arg...) \
+	netdev_dbg(vinfo->netdev, format, ## arg)
+#define v_err(format, arg...) \
+	netdev_err(vinfo->netdev, format, ## arg)
+#define v_info(format, arg...) \
+	netdev_info(vinfo->netdev, format, ## arg)
+
+/* vnic hfi1 internal functions */
+void hfi1_vnic_setup(struct hfi1_devdata *dd);
+void hfi1_vnic_cleanup(struct hfi1_devdata *dd);
+
+void hfi1_vnic_bypass_rcv(struct hfi1_packet *packet);
+
+/* vnic rdma netdev operations */
+struct net_device *hfi1_vnic_alloc_rn(struct ib_device *device,
+				      u8 port_num,
+				      enum rdma_netdev_t type,
+				      const char *name,
+				      unsigned char name_assign_type,
+				      void (*setup)(struct net_device *));
+void hfi1_vnic_free_rn(struct net_device *netdev);
+
+#endif /* _HFI1_VNIC_H */
diff --git a/drivers/infiniband/hw/hfi1/vnic_main.c b/drivers/infiniband/hw/hfi1/vnic_main.c
new file mode 100644
index 0000000..26effb2
--- /dev/null
+++ b/drivers/infiniband/hw/hfi1/vnic_main.c
@@ -0,0 +1,644 @@
+/*
+ * Copyright(c) 2017 Intel Corporation.
+ *
+ * This file is provided under a dual BSD/GPLv2 license.  When using or
+ * redistributing this file, you may do so under either license.
+ *
+ * GPL LICENSE SUMMARY
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * BSD LICENSE
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *  - Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ *  - Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *  - Neither the name of Intel Corporation nor the names of its
+ *    contributors may be used to endorse or promote products derived
+ *    from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+/*
+ * This file contains HFI1 support for VNIC functionality
+ */
+
+#include <linux/io.h>
+#include <linux/if_vlan.h>
+
+#include "vnic.h"
+
+#define HFI_TX_TIMEOUT_MS 1000
+
+#define HFI1_VNIC_RCV_Q_SIZE   1024
+
+#define HFI1_VNIC_UP 0
+
+static DEFINE_SPINLOCK(vport_cntr_lock);
+
+void hfi1_vnic_setup(struct hfi1_devdata *dd)
+{
+	idr_init(&dd->vnic.vesw_idr);
+}
+
+void hfi1_vnic_cleanup(struct hfi1_devdata *dd)
+{
+	idr_destroy(&dd->vnic.vesw_idr);
+}
+
+#define SUM_GRP_COUNTERS(stats, qstats, x_grp) do {            \
+		u64 *src64, *dst64;                            \
+		for (src64 = &qstats->x_grp.unicast,           \
+			dst64 = &stats->x_grp.unicast;         \
+			dst64 <= &stats->x_grp.s_1519_max;) {  \
+			*dst64++ += *src64++;                  \
+		}                                              \
+	} while (0)
+
+/* hfi1_vnic_update_stats - update statistics */
+static void hfi1_vnic_update_stats(struct hfi1_vnic_vport_info *vinfo,
+				   struct opa_vnic_stats *stats)
+{
+	struct net_device *netdev = vinfo->netdev;
+	u8 i;
+
+	/* add tx counters on different queues */
+	for (i = 0; i < vinfo->num_tx_q; i++) {
+		struct opa_vnic_stats *qstats = &vinfo->stats[i];
+		struct rtnl_link_stats64 *qnstats = &vinfo->stats[i].netstats;
+
+		stats->netstats.tx_fifo_errors += qnstats->tx_fifo_errors;
+		stats->netstats.tx_carrier_errors += qnstats->tx_carrier_errors;
+		stats->tx_drop_state += qstats->tx_drop_state;
+		stats->tx_dlid_zero += qstats->tx_dlid_zero;
+
+		SUM_GRP_COUNTERS(stats, qstats, tx_grp);
+		stats->netstats.tx_packets += qnstats->tx_packets;
+		stats->netstats.tx_bytes += qnstats->tx_bytes;
+	}
+
+	/* add rx counters on different queues */
+	for (i = 0; i < vinfo->num_rx_q; i++) {
+		struct opa_vnic_stats *qstats = &vinfo->stats[i];
+		struct rtnl_link_stats64 *qnstats = &vinfo->stats[i].netstats;
+
+		stats->netstats.rx_fifo_errors += qnstats->rx_fifo_errors;
+		stats->netstats.rx_nohandler += qnstats->rx_nohandler;
+		stats->rx_drop_state += qstats->rx_drop_state;
+		stats->rx_oversize += qstats->rx_oversize;
+		stats->rx_runt += qstats->rx_runt;
+
+		SUM_GRP_COUNTERS(stats, qstats, rx_grp);
+		stats->netstats.rx_packets += qnstats->rx_packets;
+		stats->netstats.rx_bytes += qnstats->rx_bytes;
+	}
+
+	stats->netstats.tx_errors = stats->netstats.tx_fifo_errors +
+				    stats->netstats.tx_carrier_errors +
+				    stats->tx_drop_state + stats->tx_dlid_zero;
+	stats->netstats.tx_dropped = stats->netstats.tx_errors;
+
+	stats->netstats.rx_errors = stats->netstats.rx_fifo_errors +
+				    stats->netstats.rx_nohandler +
+				    stats->rx_drop_state + stats->rx_oversize +
+				    stats->rx_runt;
+	stats->netstats.rx_dropped = stats->netstats.rx_errors;
+
+	netdev->stats.tx_packets = stats->netstats.tx_packets;
+	netdev->stats.tx_bytes = stats->netstats.tx_bytes;
+	netdev->stats.tx_fifo_errors = stats->netstats.tx_fifo_errors;
+	netdev->stats.tx_carrier_errors = stats->netstats.tx_carrier_errors;
+	netdev->stats.tx_errors = stats->netstats.tx_errors;
+	netdev->stats.tx_dropped = stats->netstats.tx_dropped;
+
+	netdev->stats.rx_packets = stats->netstats.rx_packets;
+	netdev->stats.rx_bytes = stats->netstats.rx_bytes;
+	netdev->stats.rx_fifo_errors = stats->netstats.rx_fifo_errors;
+	netdev->stats.multicast = stats->rx_grp.mcastbcast;
+	netdev->stats.rx_length_errors = stats->rx_oversize + stats->rx_runt;
+	netdev->stats.rx_errors = stats->netstats.rx_errors;
+	netdev->stats.rx_dropped = stats->netstats.rx_dropped;
+}
+
+/* update_len_counters - update pkt's len histogram counters */
+static inline void update_len_counters(struct opa_vnic_grp_stats *grp,
+				       int len)
+{
+	/* account for 4 byte FCS */
+	if (len >= 1515)
+		grp->s_1519_max++;
+	else if (len >= 1020)
+		grp->s_1024_1518++;
+	else if (len >= 508)
+		grp->s_512_1023++;
+	else if (len >= 252)
+		grp->s_256_511++;
+	else if (len >= 124)
+		grp->s_128_255++;
+	else if (len >= 61)
+		grp->s_65_127++;
+	else
+		grp->s_64++;
+}
+
+/* hfi1_vnic_update_tx_counters - update transmit counters */
+static void hfi1_vnic_update_tx_counters(struct hfi1_vnic_vport_info *vinfo,
+					 u8 q_idx, struct sk_buff *skb, int err)
+{
+	struct ethhdr *mac_hdr = (struct ethhdr *)skb_mac_header(skb);
+	struct opa_vnic_stats *stats = &vinfo->stats[q_idx];
+	struct opa_vnic_grp_stats *tx_grp = &stats->tx_grp;
+	u16 vlan_tci;
+
+	stats->netstats.tx_packets++;
+	stats->netstats.tx_bytes += skb->len + ETH_FCS_LEN;
+
+	update_len_counters(tx_grp, skb->len);
+
+	/* rest of the counts are for good packets only */
+	if (unlikely(err))
+		return;
+
+	if (is_multicast_ether_addr(mac_hdr->h_dest))
+		tx_grp->mcastbcast++;
+	else
+		tx_grp->unicast++;
+
+	if (!__vlan_get_tag(skb, &vlan_tci))
+		tx_grp->vlan++;
+	else
+		tx_grp->untagged++;
+}
+
+/* hfi1_vnic_update_rx_counters - update receive counters */
+static void hfi1_vnic_update_rx_counters(struct hfi1_vnic_vport_info *vinfo,
+					 u8 q_idx, struct sk_buff *skb, int err)
+{
+	struct ethhdr *mac_hdr = (struct ethhdr *)skb->data;
+	struct opa_vnic_stats *stats = &vinfo->stats[q_idx];
+	struct opa_vnic_grp_stats *rx_grp = &stats->rx_grp;
+	u16 vlan_tci;
+
+	stats->netstats.rx_packets++;
+	stats->netstats.rx_bytes += skb->len + ETH_FCS_LEN;
+
+	update_len_counters(rx_grp, skb->len);
+
+	/* rest of the counts are for good packets only */
+	if (unlikely(err))
+		return;
+
+	if (is_multicast_ether_addr(mac_hdr->h_dest))
+		rx_grp->mcastbcast++;
+	else
+		rx_grp->unicast++;
+
+	if (!__vlan_get_tag(skb, &vlan_tci))
+		rx_grp->vlan++;
+	else
+		rx_grp->untagged++;
+}
+
+/* This function is overloaded for opa_vnic specific implementation */
+static void hfi1_vnic_get_stats64(struct net_device *netdev,
+				  struct rtnl_link_stats64 *stats)
+{
+	struct opa_vnic_stats *vstats = (struct opa_vnic_stats *)stats;
+	struct hfi1_vnic_vport_info *vinfo = opa_vnic_dev_priv(netdev);
+
+	hfi1_vnic_update_stats(vinfo, vstats);
+}
+
+static u64 create_bypass_pbc(u32 vl, u32 dw_len)
+{
+	u64 pbc;
+
+	pbc = ((u64)PBC_IHCRC_NONE << PBC_INSERT_HCRC_SHIFT)
+		| PBC_INSERT_BYPASS_ICRC | PBC_CREDIT_RETURN
+		| PBC_PACKET_BYPASS
+		| ((vl & PBC_VL_MASK) << PBC_VL_SHIFT)
+		| (dw_len & PBC_LENGTH_DWS_MASK) << PBC_LENGTH_DWS_SHIFT;
+
+	return pbc;
+}
+
+/* hfi1_vnic_maybe_stop_tx - stop tx queue if required */
+static void hfi1_vnic_maybe_stop_tx(struct hfi1_vnic_vport_info *vinfo,
+				    u8 q_idx)
+{
+	netif_stop_subqueue(vinfo->netdev, q_idx);
+}
+
+static netdev_tx_t hfi1_netdev_start_xmit(struct sk_buff *skb,
+					  struct net_device *netdev)
+{
+	struct hfi1_vnic_vport_info *vinfo = opa_vnic_dev_priv(netdev);
+	u8 pad_len, q_idx = skb->queue_mapping;
+	struct hfi1_devdata *dd = vinfo->dd;
+	struct opa_vnic_skb_mdata *mdata;
+	u32 pkt_len, total_len;
+	int err = -EINVAL;
+	u64 pbc;
+
+	v_dbg("xmit: queue %d skb len %d\n", q_idx, skb->len);
+	if (unlikely(!netif_oper_up(netdev))) {
+		vinfo->stats[q_idx].tx_drop_state++;
+		goto tx_finish;
+	}
+
+	/* take out meta data */
+	mdata = (struct opa_vnic_skb_mdata *)skb->data;
+	skb_pull(skb, sizeof(*mdata));
+	if (unlikely(mdata->flags & OPA_VNIC_SKB_MDATA_ENCAP_ERR)) {
+		vinfo->stats[q_idx].tx_dlid_zero++;
+		goto tx_finish;
+	}
+
+	/* add tail padding (for 8 bytes size alignment) and icrc */
+	pad_len = -(skb->len + OPA_VNIC_ICRC_TAIL_LEN) & 0x7;
+	pad_len += OPA_VNIC_ICRC_TAIL_LEN;
+
+	/*
+	 * pkt_len is how much data we have to write, includes header and data.
+	 * total_len is length of the packet in Dwords plus the PBC should not
+	 * include the CRC.
+	 */
+	pkt_len = (skb->len + pad_len) >> 2;
+	total_len = pkt_len + 2; /* PBC + packet */
+
+	pbc = create_bypass_pbc(mdata->vl, total_len);
+
+	skb_get(skb);
+	v_dbg("pbc 0x%016llX len %d pad_len %d\n", pbc, skb->len, pad_len);
+	err = dd->process_vnic_dma_send(dd, q_idx, vinfo, skb, pbc, pad_len);
+	if (unlikely(err)) {
+		if (err == -ENOMEM)
+			vinfo->stats[q_idx].netstats.tx_fifo_errors++;
+		else if (err != -EBUSY)
+			vinfo->stats[q_idx].netstats.tx_carrier_errors++;
+	}
+	/* remove the header before updating tx counters */
+	skb_pull(skb, OPA_VNIC_HDR_LEN);
+
+	if (unlikely(err == -EBUSY)) {
+		hfi1_vnic_maybe_stop_tx(vinfo, q_idx);
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_BUSY;
+	}
+
+tx_finish:
+	/* update tx counters */
+	hfi1_vnic_update_tx_counters(vinfo, q_idx, skb, err);
+	dev_kfree_skb_any(skb);
+	return NETDEV_TX_OK;
+}
+
+static u16 hfi1_vnic_select_queue(struct net_device *netdev,
+				  struct sk_buff *skb,
+				  void *accel_priv,
+				  select_queue_fallback_t fallback)
+{
+	return 0;
+}
+
+/* hfi1_vnic_decap_skb - strip OPA header from the skb (ethernet) packet */
+static inline int hfi1_vnic_decap_skb(struct hfi1_vnic_rx_queue *rxq,
+				      struct sk_buff *skb)
+{
+	struct hfi1_vnic_vport_info *vinfo = rxq->vinfo;
+	int max_len = vinfo->netdev->mtu + VLAN_ETH_HLEN;
+	int rc = -EFAULT;
+
+	skb_pull(skb, OPA_VNIC_HDR_LEN);
+
+	/* Validate Packet length */
+	if (unlikely(skb->len > max_len))
+		vinfo->stats[rxq->idx].rx_oversize++;
+	else if (unlikely(skb->len < ETH_ZLEN))
+		vinfo->stats[rxq->idx].rx_runt++;
+	else
+		rc = 0;
+	return rc;
+}
+
+static inline struct sk_buff *hfi1_vnic_get_skb(struct hfi1_vnic_rx_queue *rxq)
+{
+	unsigned char *pad_info;
+	struct sk_buff *skb;
+
+	skb = skb_dequeue(&rxq->skbq);
+	if (unlikely(!skb))
+		return NULL;
+
+	/* remove tail padding and icrc */
+	pad_info = skb->data + skb->len - 1;
+	skb_trim(skb, (skb->len - OPA_VNIC_ICRC_TAIL_LEN -
+		       ((*pad_info) & 0x7)));
+
+	return skb;
+}
+
+/* hfi1_vnic_handle_rx - handle skb receive */
+static void hfi1_vnic_handle_rx(struct hfi1_vnic_rx_queue *rxq,
+				int *work_done, int work_to_do)
+{
+	struct hfi1_vnic_vport_info *vinfo = rxq->vinfo;
+	struct sk_buff *skb;
+	int rc;
+
+	while (1) {
+		if (*work_done >= work_to_do)
+			break;
+
+		skb = hfi1_vnic_get_skb(rxq);
+		if (unlikely(!skb))
+			break;
+
+		rc = hfi1_vnic_decap_skb(rxq, skb);
+		/* update rx counters */
+		hfi1_vnic_update_rx_counters(vinfo, rxq->idx, skb, rc);
+		if (unlikely(rc)) {
+			dev_kfree_skb_any(skb);
+			continue;
+		}
+
+		skb_checksum_none_assert(skb);
+		skb->protocol = eth_type_trans(skb, rxq->netdev);
+
+		napi_gro_receive(&rxq->napi, skb);
+		(*work_done)++;
+	}
+}
+
+/* hfi1_vnic_napi - napi receive polling callback function */
+static int hfi1_vnic_napi(struct napi_struct *napi, int budget)
+{
+	struct hfi1_vnic_rx_queue *rxq = container_of(napi,
+					      struct hfi1_vnic_rx_queue, napi);
+	struct hfi1_vnic_vport_info *vinfo = rxq->vinfo;
+	int work_done = 0;
+
+	v_dbg("napi %d budget %d\n", rxq->idx, budget);
+	hfi1_vnic_handle_rx(rxq, &work_done, budget);
+
+	v_dbg("napi %d work_done %d\n", rxq->idx, work_done);
+	if (work_done < budget)
+		napi_complete(napi);
+
+	return work_done;
+}
+
+void hfi1_vnic_bypass_rcv(struct hfi1_packet *packet)
+{
+	struct hfi1_devdata *dd = packet->rcd->dd;
+	struct hfi1_vnic_vport_info *vinfo = NULL;
+	struct hfi1_vnic_rx_queue *rxq;
+	struct sk_buff *skb;
+	int l4_type, vesw_id = -1;
+	u8 q_idx;
+
+	l4_type = HFI1_GET_L4_TYPE(packet->ebuf);
+	if (likely(l4_type == OPA_VNIC_L4_ETHR)) {
+		vesw_id = HFI1_VNIC_GET_VESWID(packet->ebuf);
+		vinfo = idr_find(&dd->vnic.vesw_idr, vesw_id);
+
+		/*
+		 * In case of invalid vesw id, count the error on
+		 * the first available vport.
+		 */
+		if (unlikely(!vinfo)) {
+			struct hfi1_vnic_vport_info *vinfo_tmp;
+			int id_tmp = 0;
+
+			vinfo_tmp =  idr_get_next(&dd->vnic.vesw_idr, &id_tmp);
+			if (vinfo_tmp) {
+				spin_lock(&vport_cntr_lock);
+				vinfo_tmp->stats[0].netstats.rx_nohandler++;
+				spin_unlock(&vport_cntr_lock);
+			}
+		}
+	}
+
+	if (unlikely(!vinfo)) {
+		dd_dev_warn(dd, "vnic rcv err: l4 %d vesw id %d ctx %d\n",
+			    l4_type, vesw_id, packet->rcd->ctxt);
+		return;
+	}
+
+	q_idx = packet->rcd->vnic_q_idx;
+	rxq = &vinfo->rxq[q_idx];
+	if (unlikely(!netif_oper_up(vinfo->netdev))) {
+		vinfo->stats[q_idx].rx_drop_state++;
+		skb_queue_purge(&rxq->skbq);
+		return;
+	}
+
+	if (unlikely(skb_queue_len(&rxq->skbq) > HFI1_VNIC_RCV_Q_SIZE)) {
+		vinfo->stats[q_idx].netstats.rx_fifo_errors++;
+		return;
+	}
+
+	skb = netdev_alloc_skb(vinfo->netdev, packet->tlen);
+	if (unlikely(!skb)) {
+		vinfo->stats[q_idx].netstats.rx_fifo_errors++;
+		return;
+	}
+
+	memcpy(skb->data, packet->ebuf, packet->tlen);
+	skb_put(skb, packet->tlen);
+	skb_queue_tail(&rxq->skbq, skb);
+
+	if (napi_schedule_prep(&rxq->napi)) {
+		v_dbg("napi %d scheduling\n", q_idx);
+		__napi_schedule(&rxq->napi);
+	}
+}
+
+static int hfi1_vnic_up(struct hfi1_vnic_vport_info *vinfo)
+{
+	struct hfi1_devdata *dd = vinfo->dd;
+	struct net_device *netdev = vinfo->netdev;
+	int i, rc;
+
+	/* ensure virtual eth switch id is valid */
+	if (!vinfo->vesw_id)
+		return -EINVAL;
+
+	rc = idr_alloc(&dd->vnic.vesw_idr, vinfo, vinfo->vesw_id,
+		       vinfo->vesw_id + 1, GFP_NOWAIT);
+	if (rc < 0)
+		return rc;
+
+	for (i = 0; i < vinfo->num_rx_q; i++) {
+		struct hfi1_vnic_rx_queue *rxq = &vinfo->rxq[i];
+
+		skb_queue_head_init(&rxq->skbq);
+		napi_enable(&rxq->napi);
+	}
+
+	netif_carrier_on(netdev);
+	netif_tx_start_all_queues(netdev);
+	set_bit(HFI1_VNIC_UP, &vinfo->flags);
+
+	return 0;
+}
+
+static void hfi1_vnic_down(struct hfi1_vnic_vport_info *vinfo)
+{
+	struct hfi1_devdata *dd = vinfo->dd;
+	u8 i;
+
+	clear_bit(HFI1_VNIC_UP, &vinfo->flags);
+	netif_carrier_off(vinfo->netdev);
+	netif_tx_disable(vinfo->netdev);
+	idr_remove(&dd->vnic.vesw_idr, vinfo->vesw_id);
+
+	/* remove unread skbs */
+	for (i = 0; i < vinfo->num_rx_q; i++) {
+		struct hfi1_vnic_rx_queue *rxq = &vinfo->rxq[i];
+
+		napi_disable(&rxq->napi);
+		skb_queue_purge(&rxq->skbq);
+	}
+}
+
+static int hfi1_netdev_open(struct net_device *netdev)
+{
+	struct hfi1_vnic_vport_info *vinfo = opa_vnic_dev_priv(netdev);
+	int rc;
+
+	mutex_lock(&vinfo->lock);
+	rc = hfi1_vnic_up(vinfo);
+	mutex_unlock(&vinfo->lock);
+	return rc;
+}
+
+static int hfi1_netdev_close(struct net_device *netdev)
+{
+	struct hfi1_vnic_vport_info *vinfo = opa_vnic_dev_priv(netdev);
+
+	mutex_lock(&vinfo->lock);
+	if (test_bit(HFI1_VNIC_UP, &vinfo->flags))
+		hfi1_vnic_down(vinfo);
+	mutex_unlock(&vinfo->lock);
+	return 0;
+}
+
+static void hfi1_vnic_set_vesw_id(struct net_device *netdev, int id)
+{
+	struct hfi1_vnic_vport_info *vinfo = opa_vnic_dev_priv(netdev);
+	bool reopen = false;
+
+	/*
+	 * If vesw_id is being changed, and if the vnic port is up,
+	 * reset the vnic port to ensure new vesw_id gets picked up
+	 */
+	if (id != vinfo->vesw_id) {
+		mutex_lock(&vinfo->lock);
+		if (test_bit(HFI1_VNIC_UP, &vinfo->flags)) {
+			hfi1_vnic_down(vinfo);
+			reopen = true;
+		}
+
+		vinfo->vesw_id = id;
+		if (reopen)
+			hfi1_vnic_up(vinfo);
+
+		mutex_unlock(&vinfo->lock);
+	}
+}
+
+/* netdev ops */
+static const struct net_device_ops hfi1_netdev_ops = {
+	.ndo_open = hfi1_netdev_open,
+	.ndo_stop = hfi1_netdev_close,
+	.ndo_start_xmit = hfi1_netdev_start_xmit,
+	.ndo_select_queue = hfi1_vnic_select_queue,
+	.ndo_get_stats64 = hfi1_vnic_get_stats64,
+};
+
+struct net_device *hfi1_vnic_alloc_rn(struct ib_device *device,
+				      u8 port_num,
+				      enum rdma_netdev_t type,
+				      const char *name,
+				      unsigned char name_assign_type,
+				      void (*setup)(struct net_device *))
+{
+	struct hfi1_devdata *dd = dd_from_ibdev(device);
+	struct hfi1_vnic_vport_info *vinfo;
+	struct net_device *netdev;
+	struct rdma_netdev *rn;
+	int i, size;
+
+	if (!port_num || (port_num > dd->num_pports))
+		return ERR_PTR(-EINVAL);
+
+	if (type != RDMA_NETDEV_OPA_VNIC)
+		return ERR_PTR(-ENOTSUPP);
+
+	size = sizeof(struct opa_vnic_rdma_netdev) + sizeof(*vinfo);
+	netdev = alloc_netdev_mqs(size, name, name_assign_type, setup,
+				  dd->chip_sdma_engines, HFI1_NUM_VNIC_CTXT);
+	if (!netdev)
+		return ERR_PTR(-ENOMEM);
+
+	rn = netdev_priv(netdev);
+	vinfo = opa_vnic_dev_priv(netdev);
+	vinfo->dd = dd;
+	vinfo->num_tx_q = dd->chip_sdma_engines;
+	vinfo->num_rx_q = HFI1_NUM_VNIC_CTXT;
+	vinfo->netdev = netdev;
+	rn->set_id = hfi1_vnic_set_vesw_id;
+
+	netdev->features = NETIF_F_HIGHDMA | NETIF_F_SG;
+	netdev->hw_features = netdev->features;
+	netdev->vlan_features = netdev->features;
+	netdev->watchdog_timeo = msecs_to_jiffies(HFI_TX_TIMEOUT_MS);
+	netdev->netdev_ops = &hfi1_netdev_ops;
+	mutex_init(&vinfo->lock);
+
+	for (i = 0; i < vinfo->num_rx_q; i++) {
+		struct hfi1_vnic_rx_queue *rxq = &vinfo->rxq[i];
+
+		rxq->idx = i;
+		rxq->vinfo = vinfo;
+		rxq->netdev = netdev;
+		netif_napi_add(netdev, &rxq->napi, hfi1_vnic_napi, 64);
+	}
+
+	return netdev;
+}
+
+void hfi1_vnic_free_rn(struct net_device *netdev)
+{
+	struct hfi1_vnic_vport_info *vinfo = opa_vnic_dev_priv(netdev);
+
+	mutex_destroy(&vinfo->lock);
+	free_netdev(netdev);
+}
-- 
1.8.3.1
