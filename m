From: Phil Hofer <philhofer@igneoussystems.com>
Subject: Re: [PATCH] update mvneta driver to support v6 checksums on TCP/UDP [1]
Date: Fri, 26 Jun 2015 15:26:14 -0700
Message-ID: <CAEvQe-SMC4uFekLELHGqbGnHP2NWchnbN5EtGA9rARiJqCMf4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:36037 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785AbbFZW0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 18:26:15 -0400
Received: by igbiq7 with SMTP id iq7so22227815igb.1
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 15:26:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Hofer <phofer@umich.edu>

The mvneta driver for Marvell 370 had TCP performance problems
over IPv6. (In my tests of 10s runs with 64kB packets, I got about
560Mbps on IPv6 and 950Mbps on IPv4.) After this patch, IPv6
performance jumps up to about 860Mbps.

This patch adds NETIF_F_CSUM_IPV6 to the list of interface
features and uses the IPHeaderOk receive descriptor bit instead
of the L3IP bit to determine whether or not to set CHECKSUM_UNNECESSARY.

One feature that does *not* appear to work (yet) is TSO6.

Signed off by: Phil Hofer <philhofer@igneoussystems.com>

---
 drivers/net/ethernet/marvell/mvneta.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c
b/drivers/net/ethernet/marvell/mvneta.c
index 5bdf782..f8f4667 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -338,7 +338,8 @@ struct mvneta_port {
 #define MVNETA_RXD_ERR_LEN             BIT(18)
 #define MVNETA_RXD_ERR_RESOURCE                (BIT(17) | BIT(18))
 #define MVNETA_RXD_ERR_CODE_MASK       (BIT(17) | BIT(18))
-#define MVNETA_RXD_L3_IP4              BIT(25)
+#define MVNETA_RXD_L3_IP               BIT(24)
+#define MVNETA_RXD_IP_HEAD_OK          BIT(25)
 #define MVNETA_RXD_FIRST_LAST_DESC     (BIT(26) | BIT(27))
 #define MVNETA_RXD_L4_CSUM_OK          BIT(30)

@@ -1235,9 +1236,13 @@ static u32 mvneta_txq_desc_csum(int l3_offs,
int l3_proto,
        command =  l3_offs    << MVNETA_TX_L3_OFF_SHIFT;
        command |= ip_hdr_len << MVNETA_TX_IP_HLEN_SHIFT;

+       /* IPv6 packet header checksumming
+        * is not supported, but TCPv6 header
+        * checksumming *is* supported.
+        */
        if (l3_proto == htons(ETH_P_IP))
                command |= MVNETA_TXD_IP_CSUM;
-       else
+       else if (l3_proto == htons(ETH_P_IPV6))
                command |= MVNETA_TX_L3_IP6;

        if (l4_proto == IPPROTO_TCP)
@@ -1288,13 +1293,16 @@ static void mvneta_rx_error(struct mvneta_port *pp,
 static void mvneta_rx_csum(struct mvneta_port *pp, u32 status,
                           struct sk_buff *skb)
 {
-       if ((status & MVNETA_RXD_L3_IP4) &&
+       /* IPHeadOk will be set for IPv6
+        * and IPv4 packets with proper
+        * checksums.
+        */
+       if ((status & MVNETA_RXD_IP_HEAD_OK) &&
            (status & MVNETA_RXD_L4_CSUM_OK)) {
                skb->csum = 0;
                skb->ip_summed = CHECKSUM_UNNECESSARY;
                return;
        }
-
        skb->ip_summed = CHECKSUM_NONE;
 }

@@ -3129,7 +3137,7 @@ static int mvneta_probe(struct platform_device *pdev)

        netif_napi_add(dev, &pp->napi, mvneta_poll, NAPI_POLL_WEIGHT);

-       dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
+       dev->features = NETIF_F_SG | NETIF_F_IP_CSUM |
NETIF_F_IPV6_CSUM | NETIF_F_TSO;
        dev->hw_features |= dev->features;
        dev->vlan_features |= dev->features;
        dev->priv_flags |= IFF_UNICAST_FLT;
--
2.1.4
