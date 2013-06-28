From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] iwl3945: better skb management in rx path
Date: Fri, 28 Jun 2013 05:03:41 -0700
Message-ID: <1372421021.3301.263.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Steinar H. Gunderson" <sesse@google.com>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:51069 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813Ab3F1MDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 08:03:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Steinar reported reallocations of skb->head with IPv6, leading to
a warning in skb_try_coalesce()

It turns out iwl3945 has several problems :

1) skb->truesize is underestimated. 
   We really consume PAGE_SIZE bytes for a fragment,
   not the frame length.
2) 128 bytes of initial headroom is a bit low and forces reallocations.
3) We can avoid consuming a full page for small enough frames.

Reported-by: Steinar H. Gunderson <sesse@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Note : compiled only, I do not have this hardware.

 drivers/net/wireless/iwlegacy/3945.c |   30 +++++++++++++++----------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/3945.c b/drivers/net/wireless/iwlegacy/3945.c
index c092033..ad7294f 100644
--- a/drivers/net/wireless/iwlegacy/3945.c
+++ b/drivers/net/wireless/iwlegacy/3945.c
@@ -483,14 +483,13 @@ il3945_pass_packet_to_mac80211(struct il_priv *il, struct il_rx_buf *rxb,
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)IL_RX_DATA(pkt);
 	struct il3945_rx_frame_hdr *rx_hdr = IL_RX_HDR(pkt);
 	struct il3945_rx_frame_end *rx_end = IL_RX_END(pkt);
-	u16 len = le16_to_cpu(rx_hdr->len);
+	u32 len = le16_to_cpu(rx_hdr->len);
 	struct sk_buff *skb;
 	__le16 fc = hdr->frame_control;
+	u32 fraglen = PAGE_SIZE << il->hw_params.rx_page_order;
 
 	/* We received data from the HW, so stop the watchdog */
-	if (unlikely
-	    (len + IL39_RX_FRAME_SIZE >
-	     PAGE_SIZE << il->hw_params.rx_page_order)) {
+	if (unlikely(len + IL39_RX_FRAME_SIZE > fraglen)) {
 		D_DROP("Corruption detected!\n");
 		return;
 	}
@@ -506,26 +505,33 @@ il3945_pass_packet_to_mac80211(struct il_priv *il, struct il_rx_buf *rxb,
 		D_INFO("Woke queues - frame received on passive channel\n");
 	}
 
-	skb = dev_alloc_skb(128);
+	skb = dev_alloc_skb(256);
 	if (!skb) {
 		IL_ERR("dev_alloc_skb failed\n");
 		return;
 	}
 
 	if (!il3945_mod_params.sw_crypto)
-		il_set_decrypted_flag(il, (struct ieee80211_hdr *)rxb_addr(rxb),
+		il_set_decrypted_flag(il, (struct ieee80211_hdr *)pkt,
 				      le32_to_cpu(rx_end->status), stats);
 
-	skb_add_rx_frag(skb, 0, rxb->page,
-			(void *)rx_hdr->payload - (void *)pkt, len,
-			len);
-
+	/* If frame is small enough to fit into skb->head, copy it
+	 * and do not consume a full page
+	 */
+	if (len <= 256) {
+		skb_copy_to_linear_data(skb, rx_hdr->payload, len);
+		skb->tail += len;
+	} else {
+		skb_add_rx_frag(skb, 0, rxb->page,
+				(void *)rx_hdr->payload - (void *)pkt, len,
+				fraglen);
+		il->alloc_rxb_page--;
+		rxb->page = NULL;
+	}
 	il_update_stats(il, false, fc, len);
 	memcpy(IEEE80211_SKB_RXCB(skb), stats, sizeof(*stats));
 
 	ieee80211_rx(il->hw, skb);
-	il->alloc_rxb_page--;
-	rxb->page = NULL;
 }
 
 #define IL_DELAY_NEXT_SCAN_AFTER_ASSOC (HZ*6)
