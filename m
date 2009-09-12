From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Account for VLAN tag in tx_le_req
Date: Sat, 12 Sep 2009 12:17:29 +0900
Message-ID: <4AAB12C9.3070707@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f190.google.com ([209.85.222.190]:47271 "EHLO
	mail-pz0-f190.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbZILDVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 23:21:54 -0400
Received: by pzk28 with SMTP id 28so1319276pzk.20
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2009 20:21:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With VLAN enabled, tx_le_req would return on less list elements than required,
 leading to a potential wrap around of the transmit ring buffer.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 00bc65a..018aa58 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -66,7 +66,7 @@
 
 /* This is the worst case number of transmit list elements for a single skb:
    VLAN + TSO + CKSUM + Data + skb_frags * DMA */
-#define MAX_SKB_TX_LE	(4 + (sizeof(dma_addr_t)/sizeof(u32))*MAX_SKB_FRAGS)
+#define MAX_SKB_TX_LE	(5 + (sizeof(dma_addr_t)/sizeof(u32))*MAX_SKB_FRAGS)
 #define TX_MIN_PENDING		(MAX_SKB_TX_LE+1)
 #define TX_MAX_PENDING		4096
 #define TX_DEF_PENDING		127
@@ -1576,6 +1576,11 @@ static unsigned tx_le_req(const struct sk_buff *skb)
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		++count;
 
+#ifdef SKY2_VLAN_TAG_USED
+	if (vlan_tx_tag_present(skb))
+		++count;
+#endif
+
 	return count;
 }
 
-- 
1.5.6.5


