From: Phil Hofer <philhofer@igneoussystems.com>
Subject: [PATCH] improve mvneta (Marvell 370) driver TCPv6 performance
Date: Fri, 26 Jun 2015 11:12:03 -0700
Message-ID: <CAEvQe-SY9N3k95BBkq75N4Rz8jfv+t7Q7Bh1ZSEtdHqDQmX2+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Oren Laskin <orenlaskin@igneoussystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:32860 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbbFZSME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 14:12:04 -0400
Received: by ieqy10 with SMTP id y10so80920368ieq.0
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 11:12:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP performance over IPv6 was only about 60% of IPv4 performance. This
patch makes up most (but not all) of the difference.

Signed off by: Thomas Petazzoni (thomas.petazzoni@free-electrons.com)

diff --git a/drivers/net/ethernet/marvell/mvneta.c
b/drivers/net/ethernet/marvell/mvneta.c
index 5bdf782..926c948 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1235,13 +1235,17 @@ static u32 mvneta_txq_desc_csum(int l3_offs,
int l3_proto,
        command =  l3_offs    << MVNETA_TX_L3_OFF_SHIFT;
        command |= ip_hdr_len << MVNETA_TX_IP_HLEN_SHIFT;

-       if (l3_proto == htons(ETH_P_IP))
-               command |= MVNETA_TXD_IP_CSUM;
-       else
+       /* IPv6 packet header checksumming
+        * is not supported, but TCPv6 header
+        * checksumming *is* supported.
+        */
+       if (l3_proto == htons(ETH_P_IPV6))
                command |= MVNETA_TX_L3_IP6;
+       else
+               command |= MVNETA_TXD_IP_CSUM;

        if (l4_proto == IPPROTO_TCP)
-               command |=  MVNETA_TX_L4_CSUM_FULL;
+               command |= MVNETA_TX_L4_CSUM_FULL;
        else if (l4_proto == IPPROTO_UDP)
                command |= MVNETA_TX_L4_UDP | MVNETA_TX_L4_CSUM_FULL;
        else
@@ -1288,13 +1292,11 @@ static void mvneta_rx_error(struct mvneta_port *pp,
 static void mvneta_rx_csum(struct mvneta_port *pp, u32 status,
                           struct sk_buff *skb)
 {
-       if ((status & MVNETA_RXD_L3_IP4) &&
-           (status & MVNETA_RXD_L4_CSUM_OK)) {
+       if (status & MVNETA_RXD_L4_CSUM_OK) {
                skb->csum = 0;
                skb->ip_summed = CHECKSUM_UNNECESSARY;
                return;
        }
-
        skb->ip_summed = CHECKSUM_NONE;
 }

@@ -3129,7 +3131,7 @@ static int mvneta_probe(struct platform_device *pdev)

        netif_napi_add(dev, &pp->napi, mvneta_poll, NAPI_POLL_WEIGHT);

-       dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
+       dev->features = NETIF_F_SG| NETIF_F_IP_CSUM |
NETIF_F_IPV6_CSUM | NETIF_F_TSO;
        dev->hw_features |= dev->features;
        dev->vlan_features |= dev->features;
        dev->priv_flags |= IFF_UNICAST_FLT;
