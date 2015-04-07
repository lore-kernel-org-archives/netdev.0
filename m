From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 6/6] via-rhine: beautify vlan receive code.
Date: Wed,  8 Apr 2015 00:40:53 +0200
Message-ID: <27c91a561eb5bc0f498051f4805f923e4de5fabd.1428445141.git.romieu@fr.zoreil.com>
References: <cover.1428445141.git.romieu@fr.zoreil.com>
Cc: "Nix" <nix@esperi.org.uk>, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, "Bjarke Istrup Pedersen" <gurligebis@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54411 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306AbbDGWlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 18:41:07 -0400
In-Reply-To: <cover.1428445141.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1428445141.git.romieu@fr.zoreil.com>
References: <cover.1428445141.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index fede9fc..3e6fdbb 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1993,6 +1993,17 @@ static inline u16 rhine_get_vlan_tci(struct sk_buff *skb, int data_size)
 	return be16_to_cpup((__be16 *)trailer);
 }
 
+static inline void rhine_rx_vlan_tag(struct sk_buff *skb, struct rx_desc *desc,
+				     int data_size)
+{
+	if (unlikely(desc->desc_length & cpu_to_le32(DescTag))) {
+		u16 vlan_tci;
+
+		vlan_tci = rhine_get_vlan_tci(skb, data_size);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tci);
+	}
+}
+
 /* Process up to limit frames from receive ring */
 static int rhine_rx(struct net_device *dev, int limit)
 {
@@ -2008,7 +2019,6 @@ static int rhine_rx(struct net_device *dev, int limit)
 	for (count = 0; count < limit; ++count) {
 		struct rx_desc *desc = rp->rx_ring + entry;
 		u32 desc_status = le32_to_cpu(desc->rx_status);
-		u32 desc_length = le32_to_cpu(desc->desc_length);
 		int data_size = desc_status >> 16;
 
 		if (desc_status & DescOwn)
@@ -2048,7 +2058,6 @@ static int rhine_rx(struct net_device *dev, int limit)
 			/* Length should omit the CRC */
 			int pkt_len = data_size - 4;
 			struct sk_buff *skb;
-			u16 vlan_tci = 0;
 
 			/* Check if the packet is long enough to accept without
 			   copying to a minimally-sized skbuff. */
@@ -2086,14 +2095,10 @@ static int rhine_rx(struct net_device *dev, int limit)
 			}
 
 			skb_put(skb, pkt_len);
-
-			if (unlikely(desc_length & DescTag))
-				vlan_tci = rhine_get_vlan_tci(skb, data_size);
-
 			skb->protocol = eth_type_trans(skb, dev);
 
-			if (unlikely(desc_length & DescTag))
-				__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tci);
+			rhine_rx_vlan_tag(skb, desc, data_size);
+
 			netif_receive_skb(skb);
 
 			u64_stats_update_begin(&rp->rx_stats.syncp);
-- 
2.1.0
