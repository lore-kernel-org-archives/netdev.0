From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/3] qlge: Add napi gro frags interface.
Date: Sat,  2 Jan 2010 12:37:44 -0800
Message-ID: <1262464664-14996-4-git-send-email-ron.mercer@qlogic.com>
References: <1262464664-14996-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:37005 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047Ab0ABUpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2010 15:45:30 -0500
In-Reply-To: <1262464664-14996-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   53 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 109bd0a..e9d6481 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1434,6 +1434,51 @@ map_error:
 }
 
 /* Process an inbound completion from an rx ring. */
+static void ql_process_mac_rx_gro_page(struct ql_adapter *qdev,
+					struct rx_ring *rx_ring,
+					struct ib_mac_iocb_rsp *ib_mac_rsp,
+					u32 length,
+					u16 vlan_id)
+{
+	struct sk_buff *skb;
+	struct bq_desc *lbq_desc = ql_get_curr_lchunk(qdev, rx_ring);
+	struct skb_frag_struct *rx_frag;
+	int nr_frags;
+	struct napi_struct *napi = &rx_ring->napi;
+
+	napi->dev = qdev->ndev;
+
+	skb = napi_get_frags(napi);
+	if (!skb) {
+		QPRINTK(qdev, DRV, ERR, "Couldn't get an skb, exiting.\n");
+		rx_ring->rx_dropped++;
+		put_page(lbq_desc->p.pg_chunk.page);
+		return;
+	}
+	prefetch(lbq_desc->p.pg_chunk.va);
+	rx_frag = skb_shinfo(skb)->frags;
+	nr_frags = skb_shinfo(skb)->nr_frags;
+	rx_frag += nr_frags;
+	rx_frag->page = lbq_desc->p.pg_chunk.page;
+	rx_frag->page_offset = lbq_desc->p.pg_chunk.offset;
+	rx_frag->size = length;
+
+	skb->len += length;
+	skb->data_len += length;
+	skb->truesize += length;
+	skb_shinfo(skb)->nr_frags++;
+
+	rx_ring->rx_packets++;
+	rx_ring->rx_bytes += length;
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	skb_record_rx_queue(skb, rx_ring->cq_id);
+	if (qdev->vlgrp && (vlan_id != 0xffff))
+		vlan_gro_frags(&rx_ring->napi, qdev->vlgrp, vlan_id);
+	else
+		napi_gro_frags(napi);
+}
+
+/* Process an inbound completion from an rx ring. */
 static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 					struct rx_ring *rx_ring,
 					struct ib_mac_iocb_rsp *ib_mac_rsp,
@@ -1980,6 +2025,14 @@ static unsigned long ql_process_mac_rx_intr(struct ql_adapter *qdev,
 		 */
 		ql_process_mac_rx_skb(qdev, rx_ring, ib_mac_rsp,
 						length, vlan_id);
+	} else if ((ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_DL) &&
+		!(ib_mac_rsp->flags1 & IB_MAC_CSUM_ERR_MASK) &&
+		(ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_T)) {
+		/* TCP packet in a page chunk that's been checksummed.
+		 * Tack it on to our GRO skb and let it go.
+		 */
+		ql_process_mac_rx_gro_page(qdev, rx_ring, ib_mac_rsp,
+						length, vlan_id);
 	} else if (ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_DL) {
 		/* Non-TCP packet in a page chunk. Allocate an
 		 * skb, tack it on frags, and send it up.
-- 
1.6.0.2

