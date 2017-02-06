From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v3 11/12] bnxt_en: Add basic XDP support.
Date: Mon,  6 Feb 2017 16:55:42 -0500
Message-ID: <1486418143-8958-12-git-send-email-michael.chan@broadcom.com>
References: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33110 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752139AbdBFV4L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 16:56:11 -0500
Received: by mail-pg0-f50.google.com with SMTP id 204so31843375pge.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 13:56:11 -0800 (PST)
In-Reply-To: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add basic ndo_xdp support to setup and query program, configure the NIC
to run in rx page mode, and support XDP_PASS, XDP_DROP, XDP_ABORTED
actions only.

v3: Pass modified offset and length to stack for XDP_PASS.
    Remove Kconfig option.

v2: Added trace_xdp_exception()
    Added dma_syncs.
    Added XDP headroom support.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
Tested-by: Andy Gospodarek <gospo@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/Makefile   |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c     |  36 +++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h     |   9 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c | 157 ++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h |  18 +++
 5 files changed, 214 insertions(+), 8 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h

diff --git a/drivers/net/ethernet/broadcom/bnxt/Makefile b/drivers/net/ethernet/broadcom/bnxt/Makefile
index 6082ed1..a7ca45b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/Makefile
+++ b/drivers/net/ethernet/broadcom/bnxt/Makefile
@@ -1,3 +1,3 @@
 obj-$(CONFIG_BNXT) += bnxt_en.o
 
-bnxt_en-y := bnxt.o bnxt_sriov.o bnxt_ethtool.o bnxt_dcb.o bnxt_ulp.o
+bnxt_en-y := bnxt.o bnxt_sriov.o bnxt_ethtool.o bnxt_dcb.o bnxt_ulp.o bnxt_xdp.o
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 64dc94d..665fe4f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -33,6 +33,7 @@
 #include <linux/if.h>
 #include <linux/if_vlan.h>
 #include <linux/rtc.h>
+#include <linux/bpf.h>
 #include <net/ip.h>
 #include <net/tcp.h>
 #include <net/udp.h>
@@ -53,6 +54,7 @@
 #include "bnxt_sriov.h"
 #include "bnxt_ethtool.h"
 #include "bnxt_dcb.h"
+#include "bnxt_xdp.h"
 
 #define BNXT_TX_TIMEOUT		(5 * HZ)
 
@@ -642,8 +644,7 @@ static inline int bnxt_alloc_rx_data(struct bnxt *bp,
 	return 0;
 }
 
-static void bnxt_reuse_rx_data(struct bnxt_rx_ring_info *rxr, u16 cons,
-			       void *data)
+void bnxt_reuse_rx_data(struct bnxt_rx_ring_info *rxr, u16 cons, void *data)
 {
 	u16 prod = rxr->rx_prod;
 	struct bnxt_sw_rx_bd *cons_rx_buf, *prod_rx_buf;
@@ -1480,6 +1481,11 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 	len = le32_to_cpu(rxcmp->rx_cmp_len_flags_type) >> RX_CMP_LEN_SHIFT;
 	dma_addr = rx_buf->mapping;
 
+	if (bnxt_rx_xdp(bp, rxr, cons, data, &data_ptr, &len, event)) {
+		rc = 1;
+		goto next_rx;
+	}
+
 	if (len <= bp->rx_copy_thresh) {
 		skb = bnxt_copy_skb(bnapi, data_ptr, len, dma_addr);
 		bnxt_reuse_rx_data(rxr, cons, data);
@@ -1490,7 +1496,10 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 	} else {
 		u32 payload;
 
-		payload = misc & RX_CMP_PAYLOAD_OFFSET;
+		if (rx_buf->data_ptr == data_ptr)
+			payload = misc & RX_CMP_PAYLOAD_OFFSET;
+		else
+			payload = 0;
 		skb = bp->rx_skb_func(bp, rxr, cons, data, data_ptr, dma_addr,
 				      payload | len);
 		if (!skb) {
@@ -2080,6 +2089,9 @@ static void bnxt_free_rx_rings(struct bnxt *bp)
 		struct bnxt_rx_ring_info *rxr = &bp->rx_ring[i];
 		struct bnxt_ring_struct *ring;
 
+		if (rxr->xdp_prog)
+			bpf_prog_put(rxr->xdp_prog);
+
 		kfree(rxr->rx_tpa);
 		rxr->rx_tpa = NULL;
 
@@ -2367,6 +2379,15 @@ static int bnxt_init_one_rx_ring(struct bnxt *bp, int ring_nr)
 	ring = &rxr->rx_ring_struct;
 	bnxt_init_rxbd_pages(ring, type);
 
+	if (BNXT_RX_PAGE_MODE(bp) && bp->xdp_prog) {
+		rxr->xdp_prog = bpf_prog_add(bp->xdp_prog, 1);
+		if (IS_ERR(rxr->xdp_prog)) {
+			int rc = PTR_ERR(rxr->xdp_prog);
+
+			rxr->xdp_prog = NULL;
+			return rc;
+		}
+	}
 	prod = rxr->rx_prod;
 	for (i = 0; i < bp->rx_ring_size; i++) {
 		if (bnxt_alloc_rx_data(bp, rxr, prod, GFP_KERNEL) != 0) {
@@ -2430,8 +2451,8 @@ static int bnxt_init_rx_rings(struct bnxt *bp)
 	int i, rc = 0;
 
 	if (BNXT_RX_PAGE_MODE(bp)) {
-		bp->rx_offset = NET_IP_ALIGN;
-		bp->rx_dma_offset = 0;
+		bp->rx_offset = NET_IP_ALIGN + XDP_PACKET_HEADROOM;
+		bp->rx_dma_offset = XDP_PACKET_HEADROOM;
 	} else {
 		bp->rx_offset = BNXT_RX_OFFSET;
 		bp->rx_dma_offset = BNXT_RX_DMA_OFFSET;
@@ -2560,7 +2581,7 @@ static int bnxt_calc_nr_ring_pages(u32 ring_size, int desc_per_pg)
 	return pages;
 }
 
-static void bnxt_set_tpa_flags(struct bnxt *bp)
+void bnxt_set_tpa_flags(struct bnxt *bp)
 {
 	bp->flags &= ~BNXT_FLAG_TPA;
 	if (bp->flags & BNXT_FLAG_NO_AGG_RINGS)
@@ -7107,6 +7128,7 @@ static void bnxt_udp_tunnel_del(struct net_device *dev,
 #endif
 	.ndo_udp_tunnel_add	= bnxt_udp_tunnel_add,
 	.ndo_udp_tunnel_del	= bnxt_udp_tunnel_del,
+	.ndo_xdp		= bnxt_xdp,
 };
 
 static void bnxt_remove_one(struct pci_dev *pdev)
@@ -7131,6 +7153,8 @@ static void bnxt_remove_one(struct pci_dev *pdev)
 	pci_iounmap(pdev, bp->bar0);
 	kfree(bp->edev);
 	bp->edev = NULL;
+	if (bp->xdp_prog)
+		bpf_prog_put(bp->xdp_prog);
 	free_netdev(dev);
 
 	pci_release_regions(pdev);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 6dc43f5..db4a410 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -418,7 +418,8 @@ struct rx_tpa_end_cmp_ext {
 
 #define BNXT_MAX_MTU		9500
 #define BNXT_MAX_PAGE_MODE_MTU	\
-	((unsigned int)PAGE_SIZE - VLAN_ETH_HLEN - NET_IP_ALIGN)
+	((unsigned int)PAGE_SIZE - VLAN_ETH_HLEN - NET_IP_ALIGN -	\
+	 XDP_PACKET_HEADROOM)
 
 #define BNXT_MIN_PKT_SIZE	52
 
@@ -618,6 +619,8 @@ struct bnxt_rx_ring_info {
 	void __iomem		*rx_doorbell;
 	void __iomem		*rx_agg_doorbell;
 
+	struct bpf_prog		*xdp_prog;
+
 	struct rx_bd		*rx_desc_ring[MAX_RX_PAGES];
 	struct bnxt_sw_rx_bd	*rx_buf_ring;
 
@@ -1167,6 +1170,8 @@ struct bnxt {
 
 	u8			num_leds;
 	struct bnxt_led_info	leds[BNXT_MAX_LED];
+
+	struct bpf_prog		*xdp_prog;
 };
 
 #define BNXT_RX_STATS_OFFSET(counter)			\
@@ -1186,6 +1191,8 @@ struct bnxt {
 #define SFF_MODULE_ID_QSFP28			0x11
 #define BNXT_MAX_PHY_I2C_RESP_SIZE		64
 
+void bnxt_reuse_rx_data(struct bnxt_rx_ring_info *rxr, u16 cons, void *data);
+void bnxt_set_tpa_flags(struct bnxt *bp);
 void bnxt_set_ring_params(struct bnxt *);
 int bnxt_set_rx_skb_mode(struct bnxt *bp, bool page_mode);
 void bnxt_hwrm_cmd_hdr_init(struct bnxt *, void *, u16, u16, u16);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
new file mode 100644
index 0000000..b822e46
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
@@ -0,0 +1,157 @@
+/* Broadcom NetXtreme-C/E network driver.
+ *
+ * Copyright (c) 2016-2017 Broadcom Limited
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ */
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/if_vlan.h>
+#include <linux/bpf.h>
+#include <linux/bpf_trace.h>
+#include <linux/filter.h>
+#include "bnxt_hsi.h"
+#include "bnxt.h"
+#include "bnxt_xdp.h"
+
+/* returns the following:
+ * true    - packet consumed by XDP and new buffer is allocated.
+ * false   - packet should be passed to the stack.
+ */
+bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
+		 struct page *page, u8 **data_ptr, unsigned int *len, u8 *event)
+{
+	struct bpf_prog *xdp_prog = READ_ONCE(rxr->xdp_prog);
+	struct bnxt_sw_rx_bd *rx_buf;
+	struct pci_dev *pdev;
+	struct xdp_buff xdp;
+	dma_addr_t mapping;
+	void *orig_data;
+	u32 offset;
+	u32 act;
+
+	if (!xdp_prog)
+		return false;
+
+	pdev = bp->pdev;
+	rx_buf = &rxr->rx_buf_ring[cons];
+	offset = bp->rx_offset;
+
+	xdp.data_hard_start = *data_ptr - offset;
+	xdp.data = *data_ptr;
+	xdp.data_end = *data_ptr + *len;
+	orig_data = xdp.data;
+	mapping = rx_buf->mapping - bp->rx_dma_offset;
+
+	dma_sync_single_for_cpu(&pdev->dev, mapping + offset, *len, bp->rx_dir);
+
+	rcu_read_lock();
+	act = bpf_prog_run_xdp(xdp_prog, &xdp);
+	rcu_read_unlock();
+
+	if (orig_data != xdp.data) {
+		offset = xdp.data - xdp.data_hard_start;
+		*data_ptr = xdp.data_hard_start + offset;
+		*len = xdp.data_end - xdp.data;
+	}
+	switch (act) {
+	case XDP_PASS:
+		return false;
+
+	default:
+		bpf_warn_invalid_xdp_action(act);
+		/* Fall thru */
+	case XDP_ABORTED:
+		trace_xdp_exception(bp->dev, xdp_prog, act);
+		/* Fall thru */
+	case XDP_DROP:
+		bnxt_reuse_rx_data(rxr, cons, page);
+		break;
+	}
+	return true;
+}
+
+/* Under rtnl_lock */
+static int bnxt_xdp_set(struct bnxt *bp, struct bpf_prog *prog)
+{
+	struct net_device *dev = bp->dev;
+	int tx_xdp = 0, rc, tc;
+	struct bpf_prog *old;
+
+	if (prog && bp->dev->mtu > BNXT_MAX_PAGE_MODE_MTU) {
+		netdev_warn(dev, "MTU %d larger than largest XDP supported MTU %d.\n",
+			    bp->dev->mtu, BNXT_MAX_PAGE_MODE_MTU);
+		return -EOPNOTSUPP;
+	}
+	if (!(bp->flags & BNXT_FLAG_SHARED_RINGS)) {
+		netdev_warn(dev, "ethtool rx/tx channels must be combined to support XDP.\n");
+		return -EOPNOTSUPP;
+	}
+	if (prog)
+		tx_xdp = bp->rx_nr_rings;
+
+	tc = netdev_get_num_tc(dev);
+	if (!tc)
+		tc = 1;
+	rc = bnxt_reserve_rings(bp, bp->tx_nr_rings_per_tc, bp->rx_nr_rings,
+				tc, tx_xdp);
+	if (rc) {
+		netdev_warn(dev, "Unable to reserve enough TX rings to support XDP.\n");
+		return rc;
+	}
+	if (netif_running(dev))
+		bnxt_close_nic(bp, true, false);
+
+	old = xchg(&bp->xdp_prog, prog);
+	if (old)
+		bpf_prog_put(old);
+
+	if (prog) {
+		bnxt_set_rx_skb_mode(bp, true);
+	} else {
+		int rx, tx;
+
+		bnxt_set_rx_skb_mode(bp, false);
+		bnxt_get_max_rings(bp, &rx, &tx, true);
+		if (rx > 1) {
+			bp->flags &= ~BNXT_FLAG_NO_AGG_RINGS;
+			bp->dev->hw_features |= NETIF_F_LRO;
+		}
+	}
+	bp->tx_nr_rings_xdp = tx_xdp;
+	bp->tx_nr_rings = bp->tx_nr_rings_per_tc * tc + tx_xdp;
+	bp->cp_nr_rings = max_t(int, bp->tx_nr_rings, bp->rx_nr_rings);
+	bp->num_stat_ctxs = bp->cp_nr_rings;
+	bnxt_set_tpa_flags(bp);
+	bnxt_set_ring_params(bp);
+
+	if (netif_running(dev))
+		return bnxt_open_nic(bp, true, false);
+
+	return 0;
+}
+
+int bnxt_xdp(struct net_device *dev, struct netdev_xdp *xdp)
+{
+	struct bnxt *bp = netdev_priv(dev);
+	int rc;
+
+	switch (xdp->command) {
+	case XDP_SETUP_PROG:
+		rc = bnxt_xdp_set(bp, xdp->prog);
+		break;
+	case XDP_QUERY_PROG:
+		xdp->prog_attached = !!bp->xdp_prog;
+		rc = 0;
+		break;
+	default:
+		rc = -EINVAL;
+		break;
+	}
+	return rc;
+}
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h
new file mode 100644
index 0000000..0bb7b7d
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h
@@ -0,0 +1,18 @@
+/* Broadcom NetXtreme-C/E network driver.
+ *
+ * Copyright (c) 2016-2017 Broadcom Limited
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ */
+
+#ifndef BNXT_XDP_H
+#define BNXT_XDP_H
+
+bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
+		 struct page *page, u8 **data_ptr, unsigned int *len,
+		 u8 *event);
+int bnxt_xdp(struct net_device *dev, struct netdev_xdp *xdp);
+
+#endif
-- 
1.8.3.1
