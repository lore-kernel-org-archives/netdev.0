From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 01/10] ftgmac100: Upgrade to NETIF_F_HW_CSUM
Date: Tue, 11 Apr 2017 11:04:27 +1000
Message-ID: <20170411010436.23290-2-benh@kernel.crashing.org>
References: <20170411010436.23290-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39770 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751932AbdDKBFN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 21:05:13 -0400
In-Reply-To: <20170411010436.23290-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The documentation describes NETIF_F_IP_CSUM as deprecated
so let's switch to NETIF_F_HW_CSUM and use the helper to
handle unhandled protocols.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 98b8956..85b650a 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -637,7 +637,8 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
 				csum_vlan |= FTGMAC100_TXDES1_TCP_CHKSUM;
 			else if (ip_proto == IPPROTO_UDP)
 				csum_vlan |= FTGMAC100_TXDES1_UDP_CHKSUM;
-		}
+		} else if (skb_checksum_help(skb))
+			goto drop;
 	}
 	txdes->txdes1 = cpu_to_le32(csum_vlan);
 
@@ -1463,11 +1464,11 @@ static int ftgmac100_probe(struct platform_device *pdev)
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
