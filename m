From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH 2/2] be2net: Fix CSO for UDP packets
Date: Mon, 25 Oct 2010 16:41:58 +0530
Message-ID: <20101025111158.GA2009@emulex.com>
Reply-To: Somnath Kotur <somnath.kotur@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:44725 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752723Ab0JYLMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 07:12:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're setting skb->ip_summed to CHECKSUM_NONE for all non-TCP pkts, making the stack
recompute checksum.This is a bug for UDP pkts for which cso must be used.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/benet/be_main.c |   20 ++++++++------------
 1 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 8767355..6b80a06 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -849,20 +849,16 @@ static void be_rx_stats_update(struct be_rx_obj *rxo,
 		stats->rx_mcast_pkts++;
 }
 
-static inline bool do_pkt_csum(struct be_eth_rx_compl *rxcp, bool cso)
+static inline bool csum_passed(struct be_eth_rx_compl *rxcp)
 {
-	u8 l4_cksm, ip_version, ipcksm, tcpf = 0, udpf = 0, ipv6_chk;
+	u8 l4_cksm, ipv6, ipcksm;
 
 	l4_cksm = AMAP_GET_BITS(struct amap_eth_rx_compl, l4_cksm, rxcp);
 	ipcksm = AMAP_GET_BITS(struct amap_eth_rx_compl, ipcksm, rxcp);
-	ip_version = AMAP_GET_BITS(struct amap_eth_rx_compl, ip_version, rxcp);
-	if (ip_version) {
-		tcpf = AMAP_GET_BITS(struct amap_eth_rx_compl, tcpf, rxcp);
-		udpf = AMAP_GET_BITS(struct amap_eth_rx_compl, udpf, rxcp);
-	}
-	ipv6_chk = (ip_version && (tcpf || udpf));
+	ipv6 = AMAP_GET_BITS(struct amap_eth_rx_compl, ip_version, rxcp);
 
-	return ((l4_cksm && ipv6_chk && ipcksm) && cso) ? false : true;
+	/* Ignore ipcksm for ipv6 pkts */
+	return l4_cksm && (ipcksm || ipv6);
 }
 
 static struct be_rx_page_info *
@@ -1017,10 +1013,10 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 
 	skb_fill_rx_data(adapter, rxo, skb, rxcp, num_rcvd);
 
-	if (do_pkt_csum(rxcp, adapter->rx_csum))
-		skb_checksum_none_assert(skb);
-	else
+	if (likely(adapter->rx_csum && csum_passed(rxcp)))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	else
+		skb_checksum_none_assert(skb);
 
 	skb->truesize = skb->len + sizeof(struct sk_buff);
 	skb->protocol = eth_type_trans(skb, adapter->netdev);
-- 
1.5.6.1

