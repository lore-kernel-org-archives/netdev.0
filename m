From: <jeroen.de_wachter.ext@nokia.com>
Subject: [PATCH 1/2] encx24j600: bugfix - always move ERXTAIL to next packet in encx24j600_rx_packets
Date: Mon, 12 Dec 2016 14:29:08 +0100
Message-ID: <1481549349-8199-1-git-send-email-jeroen.de_wachter.ext@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,
        <netdev@vger.kernel.org>,
        Jeroen De Wachter <jeroen.de_wachter.ext@nokia.com>
To: David Miller <davem@davemloft.net>,
        Jon Ringle <jringle@gridpoint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fr-hpida-esg-02.alcatel-lucent.com ([135.245.210.21]:40030 "EHLO
        smtp-fr.alcatel-lucent.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750712AbcLLNkL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 08:40:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeroen De Wachter <jeroen.de_wachter.ext@nokia.com>

Before, encx24j600_rx_packets did not update encx24j600_priv's next_packet
member when an error occurred during packet handling (either because the
packet's RSV header indicates an error or because the encx24j600_receive_packet
method can't allocate an sk_buff).

If the next_packet member is not updated, the ERXTAIL register will be set to
the same value it had before, which means the bad packet remains in the
component's memory and its RSV header will be read again when a new packet
arrives. If the RSV header indicates a bad packet or if sk_buff allocation
continues to fail, new packets will be stored in the component's memory until
that memory is full, after which packets will be dropped.

The SETPKTDEC command is always executed though, so the encx24j600 hardware has
an incorrect count of the packets in its memory.

To prevent this, the next_packet member should always be updated, allowing the
packet to be skipped (either because it's bad, as indicated in its RSV header,
or because allocating an sk_buff failed). In the allocation failure case, this
does mean dropping a valid packet, but dropping the oldest packet to keep as
much memory as possible available for new packets seems preferable to keeping
old (but valid) packets around while dropping new ones.

Signed-off-by: Jeroen De Wachter <jeroen.de_wachter.ext@nokia.com>
---
 drivers/net/ethernet/microchip/encx24j600.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/microchip/encx24j600.c b/drivers/net/ethernet/microchip/encx24j600.c
index b14f030..5251aa3 100644
--- a/drivers/net/ethernet/microchip/encx24j600.c
+++ b/drivers/net/ethernet/microchip/encx24j600.c
@@ -346,7 +346,6 @@ static int encx24j600_receive_packet(struct encx24j600_priv *priv,
 	/* Maintain stats */
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += rsv->len;
-	priv->next_packet = rsv->next_packet;
 
 	netif_rx(skb);
 
@@ -383,6 +382,8 @@ static void encx24j600_rx_packets(struct encx24j600_priv *priv, u8 packet_count)
 			encx24j600_receive_packet(priv, &rsv);
 		}
 
+		priv->next_packet = rsv.next_packet;
+
 		newrxtail = priv->next_packet - 2;
 		if (newrxtail == ENC_RX_BUF_START)
 			newrxtail = SRAM_SIZE - 2;
-- 
1.8.3.1
