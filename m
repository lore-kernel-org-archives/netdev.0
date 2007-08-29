From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 4/7] s390: Announce tx checksumming for qeth devices in TSO/EDDP mode
Date: Wed, 29 Aug 2007 11:26:55 +0200
Message-ID: <20070829101849.213027000@linux.vnet.ibm.com>
References: <20070829092651.411517000@linux.vnet.ibm.com>
Cc: frank.blaschka@de.ibm.com
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:39522 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932105AbXH2KSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 06:18:53 -0400
Content-Disposition: inline; filename=706-qeth-tx-chksum.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frank Blaschka <frank.blaschka@de.ibm.com>

TSO requires tx checksumming. For non GSO frames in TSO/EDDP mode we
have to manually calculate the checksum. 

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---


Subject: [patch 4/7] [PATCH] qeth: Announce tx checksumming for qeth devices in TSO/EDDP mode

From: Frank Blaschka <frank.blaschka@de.ibm.com>

TSO requires tx checksumming. For non GSO frames in TSO/EDDP mode we
have to manually calculate the checksum. 

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/qeth_main.c |   82 +++++++++++++++++++++++++++++++++++--------
 1 file changed, 68 insertions(+), 14 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/qeth_main.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth_main.c
+++ linux-2.6-uschi/drivers/s390/net/qeth_main.c
@@ -4555,6 +4555,53 @@ qeth_get_elements_no(struct qeth_card *c
         return elements_needed;
 }
 
+static void qeth_tx_csum(struct sk_buff *skb)
+{
+	int tlen;
+
+	if (skb->protocol == htons(ETH_P_IP)) {
+		tlen = ntohs(ip_hdr(skb)->tot_len) - (ip_hdr(skb)->ihl << 2);
+		switch (ip_hdr(skb)->protocol) {
+		case IPPROTO_TCP:
+			tcp_hdr(skb)->check = 0;
+			tcp_hdr(skb)->check = csum_tcpudp_magic(
+				ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
+				tlen, ip_hdr(skb)->protocol,
+				skb_checksum(skb, skb_transport_offset(skb),
+					tlen, 0));
+			break;
+		case IPPROTO_UDP:
+			udp_hdr(skb)->check = 0;
+			udp_hdr(skb)->check = csum_tcpudp_magic(
+				ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
+				tlen, ip_hdr(skb)->protocol,
+				skb_checksum(skb, skb_transport_offset(skb),
+					tlen, 0));
+			break;
+		}
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		switch (ipv6_hdr(skb)->nexthdr) {
+		case IPPROTO_TCP:
+			tcp_hdr(skb)->check = 0;
+			tcp_hdr(skb)->check = csum_ipv6_magic(
+				&ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
+				ipv6_hdr(skb)->payload_len,
+				ipv6_hdr(skb)->nexthdr,
+				skb_checksum(skb, skb_transport_offset(skb),
+					ipv6_hdr(skb)->payload_len, 0));
+			break;
+		case IPPROTO_UDP:
+			udp_hdr(skb)->check = 0;
+			udp_hdr(skb)->check = csum_ipv6_magic(
+				&ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
+				ipv6_hdr(skb)->payload_len,
+				ipv6_hdr(skb)->nexthdr,
+				skb_checksum(skb, skb_transport_offset(skb),
+					ipv6_hdr(skb)->payload_len, 0));
+			break;
+		}
+	}
+}
 
 static int
 qeth_send_packet(struct qeth_card *card, struct sk_buff *skb)
@@ -4640,6 +4687,10 @@ qeth_send_packet(struct qeth_card *card,
 		elements_needed += elems;
 	}
 
+	if ((large_send == QETH_LARGE_SEND_NO) &&
+	    (skb->ip_summed == CHECKSUM_PARTIAL))
+		qeth_tx_csum(new_skb);
+
 	if (card->info.type != QETH_CARD_TYPE_IQD)
 		rc = qeth_do_send_packet(card, queue, new_skb, hdr,
 					 elements_needed, ctx);
@@ -6387,20 +6438,18 @@ qeth_deregister_addr_entry(struct qeth_c
 static u32
 qeth_ethtool_get_tx_csum(struct net_device *dev)
 {
-	/* We may need to say that we support tx csum offload if
-	 * we do EDDP or TSO. There are discussions going on to
-	 * enforce rules in the stack and in ethtool that make
-	 * SG and TSO depend on HW_CSUM. At the moment there are
-	 * no such rules....
-	 * If we say yes here, we have to checksum outbound packets
-	 * any time. */
-	return 0;
+	return (dev->features & NETIF_F_HW_CSUM) != 0;
 }
 
 static int
 qeth_ethtool_set_tx_csum(struct net_device *dev, u32 data)
 {
-	return -EINVAL;
+	if (data)
+		dev->features |= NETIF_F_HW_CSUM;
+	else
+		dev->features &= ~NETIF_F_HW_CSUM;
+
+	return 0;
 }
 
 static u32
@@ -7414,7 +7463,8 @@ qeth_start_ipa_tso(struct qeth_card *car
 	}
 	if (rc && (card->options.large_send == QETH_LARGE_SEND_TSO)){
 		card->options.large_send = QETH_LARGE_SEND_NO;
-		card->dev->features &= ~ (NETIF_F_TSO | NETIF_F_SG);
+		card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
+						NETIF_F_HW_CSUM);
 	}
 	return rc;
 }
@@ -7554,22 +7604,26 @@ qeth_set_large_send(struct qeth_card *ca
 	card->options.large_send = type;
 	switch (card->options.large_send) {
 	case QETH_LARGE_SEND_EDDP:
-		card->dev->features |= NETIF_F_TSO | NETIF_F_SG;
+		card->dev->features |= NETIF_F_TSO | NETIF_F_SG |
+					NETIF_F_HW_CSUM;
 		break;
 	case QETH_LARGE_SEND_TSO:
 		if (qeth_is_supported(card, IPA_OUTBOUND_TSO)){
-			card->dev->features |= NETIF_F_TSO | NETIF_F_SG;
+			card->dev->features |= NETIF_F_TSO | NETIF_F_SG |
+						NETIF_F_HW_CSUM;
 		} else {
 			PRINT_WARN("TSO not supported on %s. "
 				   "large_send set to 'no'.\n",
 				   card->dev->name);
-			card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG);
+			card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
+						NETIF_F_HW_CSUM);
 			card->options.large_send = QETH_LARGE_SEND_NO;
 			rc = -EOPNOTSUPP;
 		}
 		break;
 	default: /* includes QETH_LARGE_SEND_NO */
-		card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG);
+		card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
+					NETIF_F_HW_CSUM);
 		break;
 	}
 	if (card->state == CARD_STATE_UP)

-- 
