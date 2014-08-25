From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 7/8] mvneta: Fix TSO and checksum for non-acceleration vlan traffic
Date: Mon, 25 Aug 2014 10:34:54 -0400
Message-ID: <1408977295-9162-8-git-send-email-vyasevic@redhat.com>
References: <1408977295-9162-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:62234 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932749AbaHYOf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 10:35:26 -0400
Received: by mail-qg0-f53.google.com with SMTP id z60so9656459qgd.40
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 07:35:25 -0700 (PDT)
In-Reply-To: <1408977295-9162-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver doesn't appear to support vlan acceleration at
all.  However, it does claim to support TSO and IP checksums
for vlan devices.  Thus any configured vlan device would
end up passing down partial checksums or TSO frames.

The driver also uses the value from skb->protocol to
determine TSO and checksum offload information, but assumes
that skb->protocol holds the l3 protocol information.
As a result, vlan traffic with partial checksums or TSO
will fail those checks and TSO will not happen.

Fix this by using vlan_get_protocol() helper.

CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index c9f1d1b..133f8c6 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1371,15 +1371,16 @@ static u32 mvneta_skb_tx_csum(struct mvneta_port *pp, struct sk_buff *skb)
 {
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		int ip_hdr_len = 0;
+		__be16 l3_proto = vlan_get_protocol(skb);
 		u8 l4_proto;
 
-		if (skb->protocol == htons(ETH_P_IP)) {
+		if (l3_proto == htons(ETH_P_IP)) {
 			struct iphdr *ip4h = ip_hdr(skb);
 
 			/* Calculate IPv4 checksum and L4 checksum */
 			ip_hdr_len = ip4h->ihl;
 			l4_proto = ip4h->protocol;
-		} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		} else if (l3_proto == htons(ETH_P_IPV6)) {
 			struct ipv6hdr *ip6h = ipv6_hdr(skb);
 
 			/* Read l4_protocol from one of IPv6 extra headers */
@@ -1390,7 +1391,7 @@ static u32 mvneta_skb_tx_csum(struct mvneta_port *pp, struct sk_buff *skb)
 			return MVNETA_TX_L4_CSUM_NOT;
 
 		return mvneta_txq_desc_csum(skb_network_offset(skb),
-				skb->protocol, ip_hdr_len, l4_proto);
+					    l3_proto, ip_hdr_len, l4_proto);
 	}
 
 	return MVNETA_TX_L4_CSUM_NOT;
-- 
1.9.3
