From: vyasevich@gmail.com
Subject: [PATCH 7/8] mvneta: Fix TSO and checksum for non-acceleration vlan traffic
Date: Fri, 22 Aug 2014 22:17:09 -0400
Message-ID: <1408760230-7457-8-git-send-email-vysevich@gmail.com>
References: <1408760230-7457-1-git-send-email-vysevich@gmail.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:53375 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035AbaHWCRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 22:17:38 -0400
Received: by mail-qa0-f46.google.com with SMTP id v10so10241872qac.33
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 19:17:37 -0700 (PDT)
In-Reply-To: <1408760230-7457-1-git-send-email-vysevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevic@redhat.com>

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
