From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 01/10] ftgmac100: Upgrade to NETIF_F_HW_CSUM
Date: Wed, 12 Apr 2017 13:27:01 +1000
Message-ID: <20170412032710.17546-2-benh@kernel.crashing.org>
References: <20170412032710.17546-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41857 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752585AbdDLD1k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 23:27:40 -0400
In-Reply-To: <20170412032710.17546-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The documentation describes NETIF_F_IP_CSUM as deprecated
so let's switch to NETIF_F_HW_CSUM and use the helper to
handle unhandled protocols.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
--

v2. - Properly fallback on unknown IP protocols (side effect
      of fixing a reported coding style issue as well).
---
 drivers/net/ethernet/faraday/ftgmac100.c | 40 ++++++++++++++++++++------------
 1 file changed, 25 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 98b8956..bfa7d0a 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -570,6 +570,26 @@ static void ftgmac100_tx_complete(struct ftgmac100 *priv)
 	}
 }
 
+static bool ftgmac100_prep_tx_csum(struct sk_buff *skb, u32 *csum_vlan)
+{
+	if (skb->protocol == cpu_to_be16(ETH_P_IP)) {
+		u8 ip_proto = ip_hdr(skb)->protocol;
+
+		*csum_vlan |= FTGMAC100_TXDES1_IP_CHKSUM;
+		switch(ip_proto) {
+		case IPPROTO_TCP:
+			*csum_vlan |= FTGMAC100_TXDES1_TCP_CHKSUM;
+			return true;
+		case IPPROTO_UDP:
+			*csum_vlan |= FTGMAC100_TXDES1_UDP_CHKSUM;
+			return true;
+		case IPPROTO_IP:
+			return true;
+		}
+	}
+	return skb_checksum_help(skb) == 0;
+}
+
 static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 				     struct net_device *netdev)
 {
@@ -626,19 +646,9 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 
 	/* Setup HW checksumming */
 	csum_vlan = 0;
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		__be16 protocol = skb->protocol;
-
-		if (protocol == cpu_to_be16(ETH_P_IP)) {
-			u8 ip_proto = ip_hdr(skb)->protocol;
-
-			csum_vlan |= FTGMAC100_TXDES1_IP_CHKSUM;
-			if (ip_proto == IPPROTO_TCP)
-				csum_vlan |= FTGMAC100_TXDES1_TCP_CHKSUM;
-			else if (ip_proto == IPPROTO_UDP)
-				csum_vlan |= FTGMAC100_TXDES1_UDP_CHKSUM;
-		}
-	}
+	if (skb->ip_summed == CHECKSUM_PARTIAL &&
+	    !ftgmac100_prep_tx_csum(skb, &csum_vlan))
+		goto drop;
 	txdes->txdes1 = cpu_to_le32(csum_vlan);
 
 	/* Next descriptor */
@@ -1463,11 +1473,11 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	 * when NCSI is enabled on the interface. It doesn't work
 	 * in that case.
 	 */
-	netdev->features = NETIF_F_RXCSUM | NETIF_F_IP_CSUM |
+	netdev->features = NETIF_F_RXCSUM | NETIF_F_HW_CSUM |
 		NETIF_F_GRO | NETIF_F_SG;
 	if (priv->use_ncsi &&
 	    of_get_property(pdev->dev.of_node, "no-hw-checksum", NULL))
-		netdev->features &= ~NETIF_F_IP_CSUM;
+		netdev->features &= ~NETIF_F_HW_CSUM;
 
 	/* register network device */
 	err = register_netdev(netdev);
-- 
2.9.3
