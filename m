From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 4/5] be2net: Fix TX stats for TSO packets
Date: Sun,  9 Oct 2016 09:58:52 +0530
Message-ID: <20161009042853.20601-5-sriharsha.basavapatna@broadcom.com>
References: <20161009042853.20601-1-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:1200 "EHLO
        CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752360AbcJIE3f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 00:29:35 -0400
In-Reply-To: <20161009042853.20601-1-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TX stats update does not take into account headers which get duplicated
when the TSO packet is split into segments by HW. Fix this for both
tunneled (vxlan) and non-tunneled TSO packets.

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index dcb930a..cece8a0 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -724,14 +724,24 @@ void be_link_status_update(struct be_adapter *adapter, u8 link_status)
 	netdev_info(netdev, "Link is %s\n", link_status ? "Up" : "Down");
 }
 
+static int be_gso_hdr_len(struct sk_buff *skb)
+{
+	if (skb->encapsulation)
+		return skb_inner_transport_offset(skb) +
+		       inner_tcp_hdrlen(skb);
+	return skb_transport_offset(skb) + tcp_hdrlen(skb);
+}
+
 static void be_tx_stats_update(struct be_tx_obj *txo, struct sk_buff *skb)
 {
 	struct be_tx_stats *stats = tx_stats(txo);
-	u64 tx_pkts = skb_shinfo(skb)->gso_segs ? : 1;
+	u32 tx_pkts = skb_shinfo(skb)->gso_segs ? : 1;
+	/* Account for headers which get duplicated in TSO pkt */
+	u32 dup_hdr_len = tx_pkts > 1 ? be_gso_hdr_len(skb) * (tx_pkts - 1) : 0;
 
 	u64_stats_update_begin(&stats->sync);
 	stats->tx_reqs++;
-	stats->tx_bytes += skb->len;
+	stats->tx_bytes += skb->len + dup_hdr_len;
 	stats->tx_pkts += tx_pkts;
 	if (skb->encapsulation && skb->ip_summed == CHECKSUM_PARTIAL)
 		stats->tx_vxlan_offload_pkts += tx_pkts;
-- 
2.10.0.478.g3ef7618
