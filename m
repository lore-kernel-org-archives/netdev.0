From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 3/8] bna: Support TSO and partial checksum with non-accelerated vlans.
Date: Mon, 25 Aug 2014 10:34:50 -0400
Message-ID: <1408977295-9162-4-git-send-email-vyasevic@redhat.com>
References: <1408977295-9162-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Rasesh Mody <rmody@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:53888 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932749AbaHYOfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 10:35:17 -0400
Received: by mail-qc0-f173.google.com with SMTP id w7so13870160qcr.32
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 07:35:16 -0700 (PDT)
In-Reply-To: <1408977295-9162-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This device claims TSO and checksum support for vlans.  It also
allows a user to control vlan acceleration offloading.  As such,
it is possible to turn off vlan acceleration and configure a vlan
which will continue to support TSO.

In such situation the packet passed down the the device will contain
a vlan header and skb->protocol will be set to ETH_P_8021Q.
The device assumes that skb->protocol contains network protocol
value and uses that value to set up TSO information.  This results
in corrupted frames sent on the wire.

This patch extract the protocol value correctly and corrects TSO
and checksums for non-accelerated traffic.

CC: Rasesh Mody <rmody@brocade.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index ff8cae5..ffc92a4 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2506,7 +2506,7 @@ bnad_tso_prepare(struct bnad *bnad, struct sk_buff *skb)
 	 * For TSO, the TCP checksum field is seeded with pseudo-header sum
 	 * excluding the length field.
 	 */
-	if (skb->protocol == htons(ETH_P_IP)) {
+	if (vlan_get_protocol(skb) == htons(ETH_P_IP)) {
 		struct iphdr *iph = ip_hdr(skb);
 
 		/* Do we really need these? */
@@ -2870,12 +2870,13 @@ bnad_txq_wi_prepare(struct bnad *bnad, struct bna_tcb *tcb,
 		}
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			__be16 net_proto = vlan_get_protocol(skb);
 			u8 proto = 0;
 
-			if (skb->protocol == htons(ETH_P_IP))
+			if (net_proto == htons(ETH_P_IP))
 				proto = ip_hdr(skb)->protocol;
 #ifdef NETIF_F_IPV6_CSUM
-			else if (skb->protocol == htons(ETH_P_IPV6)) {
+			else if (net_proto == htons(ETH_P_IPV6)) {
 				/* nexthdr may not be TCP immediately. */
 				proto = ipv6_hdr(skb)->nexthdr;
 			}
-- 
1.9.3
