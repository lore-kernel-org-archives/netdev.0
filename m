From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 04/10] ftgmac100: Cleanup rx checksum handling
Date: Thu,  6 Apr 2017 11:02:46 +1000
Message-ID: <20170406010252.29208-5-benh@kernel.crashing.org>
References: <20170406010252.29208-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37931 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756375AbdDFBD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 21:03:27 -0400
In-Reply-To: <20170406010252.29208-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Read the descriptor field only once and check for IP header
checksum errors as well

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 63 +++++++++++++-------------------
 1 file changed, 25 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index a03cc03..60c2860 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -350,31 +350,11 @@ static dma_addr_t ftgmac100_rxdes_get_dma_addr(struct ftgmac100_rxdes *rxdes)
 	return le32_to_cpu(rxdes->rxdes3);
 }
 
-static bool ftgmac100_rxdes_is_tcp(struct ftgmac100_rxdes *rxdes)
+static inline bool ftgmac100_rxdes_csum_err(struct ftgmac100_rxdes *rxdes)
 {
-	return (rxdes->rxdes1 & cpu_to_le32(FTGMAC100_RXDES1_PROT_MASK)) ==
-	       cpu_to_le32(FTGMAC100_RXDES1_PROT_TCPIP);
-}
-
-static bool ftgmac100_rxdes_is_udp(struct ftgmac100_rxdes *rxdes)
-{
-	return (rxdes->rxdes1 & cpu_to_le32(FTGMAC100_RXDES1_PROT_MASK)) ==
-	       cpu_to_le32(FTGMAC100_RXDES1_PROT_UDPIP);
-}
-
-static bool ftgmac100_rxdes_tcpcs_err(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes1 & cpu_to_le32(FTGMAC100_RXDES1_TCP_CHKSUM_ERR);
-}
-
-static bool ftgmac100_rxdes_udpcs_err(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes1 & cpu_to_le32(FTGMAC100_RXDES1_UDP_CHKSUM_ERR);
-}
-
-static bool ftgmac100_rxdes_ipcs_err(struct ftgmac100_rxdes *rxdes)
-{
-	return rxdes->rxdes1 & cpu_to_le32(FTGMAC100_RXDES1_IP_CHKSUM_ERR);
+	return !!(rxdes->rxdes1 & cpu_to_le32(FTGMAC100_RXDES1_TCP_CHKSUM_ERR |
+					      FTGMAC100_RXDES1_UDP_CHKSUM_ERR |
+					      FTGMAC100_RXDES1_IP_CHKSUM_ERR));
 }
 
 static inline struct page **ftgmac100_rxdes_page_slot(struct ftgmac100 *priv,
@@ -484,11 +464,6 @@ static bool ftgmac100_rx_packet_error(struct ftgmac100 *priv,
 
 		netdev->stats.rx_crc_errors++;
 		error = true;
-	} else if (unlikely(ftgmac100_rxdes_ipcs_err(rxdes))) {
-		if (net_ratelimit())
-			netdev_info(netdev, "rx IP checksum err\n");
-
-		error = true;
 	}
 
 	if (unlikely(ftgmac100_rxdes_frame_too_long(rxdes))) {
@@ -580,14 +555,23 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	if (unlikely(ftgmac100_rxdes_multicast(rxdes)))
 		netdev->stats.multicast++;
 
-	/*
-	 * It seems that HW does checksum incorrectly with fragmented packets,
-	 * so we are conservative here - if HW checksum error, let software do
-	 * the checksum again.
+	/* If the HW found checksum errors, bounce it to software.
+	 *
+	 * If we didn't, we need to see if the packet was recognized
+	 * by HW as one of the supported checksummed protocols before
+	 * we accept the HW test results.
 	 */
-	if ((ftgmac100_rxdes_is_tcp(rxdes) && !ftgmac100_rxdes_tcpcs_err(rxdes)) ||
-	    (ftgmac100_rxdes_is_udp(rxdes) && !ftgmac100_rxdes_udpcs_err(rxdes)))
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	if (netdev->features & NETIF_F_RXCSUM) {
+		__le32 csum_vlan = rxdes->rxdes1;
+		__le32 err_bits = cpu_to_le32(FTGMAC100_RXDES1_TCP_CHKSUM_ERR |
+					      FTGMAC100_RXDES1_UDP_CHKSUM_ERR |
+					      FTGMAC100_RXDES1_IP_CHKSUM_ERR);
+		if ((csum_vlan & err_bits) ||
+		    !(csum_vlan & cpu_to_le32(FTGMAC100_RXDES1_PROT_MASK)))
+			skb->ip_summed = CHECKSUM_NONE;
+		else
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+	}
 
 	map = ftgmac100_rxdes_get_dma_addr(rxdes);
 
@@ -619,7 +603,10 @@ static bool ftgmac100_rx_packet(struct ftgmac100 *priv, int *processed)
 	netdev->stats.rx_bytes += skb->len;
 
 	/* push packet to protocol stack */
-	napi_gro_receive(&priv->napi, skb);
+	if (skb->ip_summed == CHECKSUM_NONE)
+		netif_receive_skb(skb);
+	else
+		napi_gro_receive(&priv->napi, skb);
 
 	(*processed)++;
 	return true;
@@ -1573,7 +1560,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	 * when NCSI is enabled on the interface. It doesn't work
 	 * in that case.
 	 */
-	netdev->features = NETIF_F_IP_CSUM | NETIF_F_GRO;
+	netdev->features = NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_GRO;
 	if (priv->use_ncsi &&
 	    of_get_property(pdev->dev.of_node, "no-hw-checksum", NULL))
 		netdev->features &= ~NETIF_F_IP_CSUM;
-- 
2.9.3
