From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH alt] sky2: transmit ring accounting
Date: Mon, 14 Sep 2009 09:12:55 -0700
Message-ID: <20090914091255.2cda7d24@nehalam>
References: <4AAD7B3D.7010403@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43163 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751276AbZINQNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 12:13:41 -0400
In-Reply-To: <4AAD7B3D.7010403@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Be more accurate about number of transmit list elements required.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Note: this is an optimization, the old code guaranteed more space
than necessary (MAX_SKB_TX_LE was always bigger than needed).

--- a/drivers/net/sky2.c	2009-09-14 08:45:55.730729606 -0700
+++ b/drivers/net/sky2.c	2009-09-14 09:09:42.395712810 -0700
@@ -65,8 +65,8 @@
 #define RX_DEF_PENDING		RX_MAX_PENDING
 
 /* This is the worst case number of transmit list elements for a single skb:
-   VLAN + TSO + CKSUM + Data + skb_frags * DMA */
-#define MAX_SKB_TX_LE	(4 + (sizeof(dma_addr_t)/sizeof(u32))*MAX_SKB_FRAGS)
+   VLAN:GSO + CKSUM + Data + skb_frags * DMA */
+#define MAX_SKB_TX_LE	(2 + (sizeof(dma_addr_t)/sizeof(u32))*(MAX_SKB_FRAGS+1))
 #define TX_MIN_PENDING		(MAX_SKB_TX_LE+1)
 #define TX_MAX_PENDING		4096
 #define TX_DEF_PENDING		127
@@ -1567,11 +1567,13 @@ static unsigned tx_le_req(const struct s
 {
 	unsigned count;
 
-	count = sizeof(dma_addr_t) / sizeof(u32);
-	count += skb_shinfo(skb)->nr_frags * count;
+	count = (skb_shinfo(skb)->nr_frags + 1)
+		* (sizeof(dma_addr_t) / sizeof(u32));
 
 	if (skb_is_gso(skb))
 		++count;
+	else if (sizeof(dma_addr_t) == sizeof(u32))
+		++count;	/* possible vlan */
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		++count;
