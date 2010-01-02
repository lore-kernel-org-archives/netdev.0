From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/3] qlge: Add RX frame handlers for non-split frames.
Date: Sat,  2 Jan 2010 12:37:43 -0800
Message-ID: <1262464664-14996-3-git-send-email-ron.mercer@qlogic.com>
References: <1262464664-14996-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:37005 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567Ab0ABUp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2010 15:45:29 -0500
In-Reply-To: <1262464664-14996-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New handlers are added here to handle:
1) Small frames (<256 bytes) in a single small buffer.  Allocate a new
skb and copy the frame.

2) Large frame (>256 bytes) in a page chunk. Allocate an skb, tack it on frags,
post to napi_gro_receive().

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |  261 +++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 257 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c303478..109bd0a 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1433,6 +1433,209 @@ map_error:
 	return NETDEV_TX_BUSY;
 }
 
+/* Process an inbound completion from an rx ring. */
+static void ql_process_mac_rx_page(struct ql_adapter *qdev,
+					struct rx_ring *rx_ring,
+					struct ib_mac_iocb_rsp *ib_mac_rsp,
+					u32 length,
+					u16 vlan_id)
+{
+	struct net_device *ndev = qdev->ndev;
+	struct sk_buff *skb = NULL;
+	void *addr;
+	struct bq_desc *lbq_desc = ql_get_curr_lchunk(qdev, rx_ring);
+	struct napi_struct *napi = &rx_ring->napi;
+
+	skb = netdev_alloc_skb(ndev, length);
+	if (!skb) {
+		QPRINTK(qdev, DRV, ERR, "Couldn't get an skb, "
+				"need to unwind!.\n");
+		rx_ring->rx_dropped++;
+		put_page(lbq_desc->p.pg_chunk.page);
+		return;
+	}
+
+	addr = lbq_desc->p.pg_chunk.va;
+	prefetch(addr);
+
+
+	/* Frame error, so drop the packet. */
+	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
+		QPRINTK(qdev, DRV, ERR, "Receive error, flags2 = 0x%x\n",
+				ib_mac_rsp->flags2);
+		rx_ring->rx_errors++;
+		goto err_out;
+	}
+
+	/* The max framesize filter on this chip is set higher than
+	 * MTU since FCoE uses 2k frames.
+	 */
+	if (skb->len > ndev->mtu + ETH_HLEN) {
+		QPRINTK(qdev, DRV, ERR, "Segment too small, dropping.\n");
+		rx_ring->rx_dropped++;
+		goto err_out;
+	}
+	memcpy(skb_put(skb, ETH_HLEN), addr, ETH_HLEN);
+	QPRINTK(qdev, RX_STATUS, DEBUG,
+		"%d bytes of headers and data in large. Chain "
+		"page to new skb and pull tail.\n", length);
+	skb_fill_page_desc(skb, 0, lbq_desc->p.pg_chunk.page,
+				lbq_desc->p.pg_chunk.offset+ETH_HLEN,
+				length-ETH_HLEN);
+	skb->len += length-ETH_HLEN;
+	skb->data_len += length-ETH_HLEN;
+	skb->truesize += length-ETH_HLEN;
+
+	rx_ring->rx_packets++;
+	rx_ring->rx_bytes += skb->len;
+	skb->protocol = eth_type_trans(skb, ndev);
+	skb->ip_summed = CHECKSUM_NONE;
+
+	if (qdev->rx_csum &&
+		!(ib_mac_rsp->flags1 & IB_MAC_CSUM_ERR_MASK)) {
+		/* TCP frame. */
+		if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_T) {
+			QPRINTK(qdev, RX_STATUS, DEBUG,
+					"TCP checksum done!\n");
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		} else if ((ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_U) &&
+				(ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_V4)) {
+			/* Unfragmented ipv4 UDP frame. */
+			struct iphdr *iph = (struct iphdr *) skb->data;
+			if (!(iph->frag_off &
+				cpu_to_be16(IP_MF|IP_OFFSET))) {
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+				QPRINTK(qdev, RX_STATUS, DEBUG,
+						"TCP checksum done!\n");
+			}
+		}
+	}
+
+	skb_record_rx_queue(skb, rx_ring->cq_id);
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
+		if (qdev->vlgrp && (vlan_id != 0xffff))
+			vlan_gro_receive(napi, qdev->vlgrp, vlan_id, skb);
+		else
+			napi_gro_receive(napi, skb);
+	} else {
+		if (qdev->vlgrp && (vlan_id != 0xffff))
+			vlan_hwaccel_receive_skb(skb, qdev->vlgrp, vlan_id);
+		else
+			netif_receive_skb(skb);
+	}
+	return;
+err_out:
+	dev_kfree_skb_any(skb);
+	put_page(lbq_desc->p.pg_chunk.page);
+}
+
+/* Process an inbound completion from an rx ring. */
+static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
+					struct rx_ring *rx_ring,
+					struct ib_mac_iocb_rsp *ib_mac_rsp,
+					u32 length,
+					u16 vlan_id)
+{
+	struct net_device *ndev = qdev->ndev;
+	struct sk_buff *skb = NULL;
+	struct sk_buff *new_skb = NULL;
+	struct bq_desc *sbq_desc = ql_get_curr_sbuf(rx_ring);
+
+	skb = sbq_desc->p.skb;
+	/* Allocate new_skb and copy */
+	new_skb = netdev_alloc_skb(qdev->ndev, length + NET_IP_ALIGN);
+	if (new_skb == NULL) {
+		QPRINTK(qdev, PROBE, ERR,
+			"No skb available, drop the packet.\n");
+		rx_ring->rx_dropped++;
+		return;
+	}
+	skb_reserve(new_skb, NET_IP_ALIGN);
+	memcpy(skb_put(new_skb, length), skb->data, length);
+	skb = new_skb;
+
+	/* Frame error, so drop the packet. */
+	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
+		QPRINTK(qdev, DRV, ERR, "Receive error, flags2 = 0x%x\n",
+					ib_mac_rsp->flags2);
+		dev_kfree_skb_any(skb);
+		rx_ring->rx_errors++;
+		return;
+	}
+
+	/* loopback self test for ethtool */
+	if (test_bit(QL_SELFTEST, &qdev->flags)) {
+		ql_check_lb_frame(qdev, skb);
+		dev_kfree_skb_any(skb);
+		return;
+	}
+
+	/* The max framesize filter on this chip is set higher than
+	 * MTU since FCoE uses 2k frames.
+	 */
+	if (skb->len > ndev->mtu + ETH_HLEN) {
+		dev_kfree_skb_any(skb);
+		rx_ring->rx_dropped++;
+		return;
+	}
+
+	prefetch(skb->data);
+	skb->dev = ndev;
+	if (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) {
+		QPRINTK(qdev, RX_STATUS, DEBUG, "%s%s%s Multicast.\n",
+			(ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
+			IB_MAC_IOCB_RSP_M_HASH ? "Hash" : "",
+			(ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
+			IB_MAC_IOCB_RSP_M_REG ? "Registered" : "",
+			(ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) ==
+			IB_MAC_IOCB_RSP_M_PROM ? "Promiscuous" : "");
+	}
+	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_P)
+		QPRINTK(qdev, RX_STATUS, DEBUG, "Promiscuous Packet.\n");
+
+	rx_ring->rx_packets++;
+	rx_ring->rx_bytes += skb->len;
+	skb->protocol = eth_type_trans(skb, ndev);
+	skb->ip_summed = CHECKSUM_NONE;
+
+	/* If rx checksum is on, and there are no
+	 * csum or frame errors.
+	 */
+	if (qdev->rx_csum &&
+		!(ib_mac_rsp->flags1 & IB_MAC_CSUM_ERR_MASK)) {
+		/* TCP frame. */
+		if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_T) {
+			QPRINTK(qdev, RX_STATUS, DEBUG,
+					"TCP checksum done!\n");
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		} else if ((ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_U) &&
+				(ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_V4)) {
+			/* Unfragmented ipv4 UDP frame. */
+			struct iphdr *iph = (struct iphdr *) skb->data;
+			if (!(iph->frag_off &
+				cpu_to_be16(IP_MF|IP_OFFSET))) {
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+				QPRINTK(qdev, RX_STATUS, DEBUG,
+						"TCP checksum done!\n");
+			}
+		}
+	}
+
+	skb_record_rx_queue(skb, rx_ring->cq_id);
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
+		if (qdev->vlgrp && (vlan_id != 0xffff))
+			vlan_gro_receive(&rx_ring->napi, qdev->vlgrp,
+						vlan_id, skb);
+		else
+			napi_gro_receive(&rx_ring->napi, skb);
+	} else {
+		if (qdev->vlgrp && (vlan_id != 0xffff))
+			vlan_hwaccel_receive_skb(skb, qdev->vlgrp, vlan_id);
+		else
+			netif_receive_skb(skb);
+	}
+}
+
 static void ql_realign_skb(struct sk_buff *skb, int len)
 {
 	void *temp_addr = skb->data;
@@ -1646,14 +1849,13 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 }
 
 /* Process an inbound completion from an rx ring. */
-static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
+static void ql_process_mac_split_rx_intr(struct ql_adapter *qdev,
 				   struct rx_ring *rx_ring,
-				   struct ib_mac_iocb_rsp *ib_mac_rsp)
+				   struct ib_mac_iocb_rsp *ib_mac_rsp,
+				   u16 vlan_id)
 {
 	struct net_device *ndev = qdev->ndev;
 	struct sk_buff *skb = NULL;
-	u16 vlan_id = (le16_to_cpu(ib_mac_rsp->vlan_id) &
-			IB_MAC_IOCB_RSP_VLAN_MASK)
 
 	QL_DUMP_IB_MAC_RSP(ib_mac_rsp);
 
@@ -1753,6 +1955,57 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 	}
 }
 
+/* Process an inbound completion from an rx ring. */
+static unsigned long ql_process_mac_rx_intr(struct ql_adapter *qdev,
+					struct rx_ring *rx_ring,
+					struct ib_mac_iocb_rsp *ib_mac_rsp)
+{
+	u32 length = le32_to_cpu(ib_mac_rsp->data_len);
+	u16 vlan_id = (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) ?
+			((le16_to_cpu(ib_mac_rsp->vlan_id) &
+			IB_MAC_IOCB_RSP_VLAN_MASK)) : 0xffff;
+
+	QL_DUMP_IB_MAC_RSP(ib_mac_rsp);
+
+	if (ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HV) {
+		/* The data and headers are split into
+		 * separate buffers.
+		 */
+		ql_process_mac_split_rx_intr(qdev, rx_ring, ib_mac_rsp,
+						vlan_id);
+	} else if (ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_DS) {
+		/* The data fit in a single small buffer.
+		 * Allocate a new skb, copy the data and
+		 * return the buffer to the free pool.
+		 */
+		ql_process_mac_rx_skb(qdev, rx_ring, ib_mac_rsp,
+						length, vlan_id);
+	} else if (ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_DL) {
+		/* Non-TCP packet in a page chunk. Allocate an
+		 * skb, tack it on frags, and send it up.
+		 */
+		ql_process_mac_rx_page(qdev, rx_ring, ib_mac_rsp,
+						length, vlan_id);
+	} else {
+		struct bq_desc *lbq_desc;
+
+		/* Free small buffer that holds the IAL */
+		lbq_desc = ql_get_curr_sbuf(rx_ring);
+		QPRINTK(qdev, RX_ERR, ERR, "Dropping frame, len %d > mtu %d\n",
+			length, qdev->ndev->mtu);
+
+		/* Unwind the large buffers for this frame. */
+		while (length > 0) {
+			lbq_desc = ql_get_curr_lchunk(qdev, rx_ring);
+			length -= (length < rx_ring->lbq_buf_size) ?
+				length : rx_ring->lbq_buf_size;
+			put_page(lbq_desc->p.pg_chunk.page);
+		}
+	}
+
+	return (unsigned long)length;
+}
+
 /* Process an outbound completion from an rx ring. */
 static void ql_process_mac_tx_intr(struct ql_adapter *qdev,
 				   struct ob_mac_iocb_rsp *mac_rsp)
-- 
1.6.0.2

