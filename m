From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: add a truesize parameter to skb_add_rx_frag()
Date: Fri, 23 Mar 2012 06:17:06 -0700
Message-ID: <1332508626.4858.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59070 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101Ab2CWNRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 09:17:10 -0400
Received: by pbcun15 with SMTP id un15so2546728pbc.19
        for <netdev@vger.kernel.org>; Fri, 23 Mar 2012 06:17:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_add_rx_frag() API is misleading.

Network skbs built with this helper can use uncharged kernel memory and
eventually stress/crash machine in OOM.

Add a 'truesize' parameter and then fix drivers in followup patches.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Wey-Yi Guy <wey-yi.w.guy@intel.com>
---
 drivers/net/usb/cdc-phonet.c              |    6 ++++--
 drivers/net/wireless/iwlegacy/3945.c      |    3 ++-
 drivers/net/wireless/iwlegacy/4965-mac.c  |    3 ++-
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c |    2 +-
 include/linux/skbuff.h                    |    2 +-
 net/core/skbuff.c                         |    4 ++--
 6 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index 790cbde..3886b30 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -164,12 +164,14 @@ static void rx_complete(struct urb *req)
 				/* Can't use pskb_pull() on page in IRQ */
 				memcpy(skb_put(skb, 1), page_address(page), 1);
 				skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
-						page, 1, req->actual_length);
+						page, 1, req->actual_length,
+						req->actual_length);
 				page = NULL;
 			}
 		} else {
 			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
-					page, 0, req->actual_length);
+					page, 0, req->actual_length,
+					req->actual_length);
 			page = NULL;
 		}
 		if (req->actual_length < PAGE_SIZE)
diff --git a/drivers/net/wireless/iwlegacy/3945.c b/drivers/net/wireless/iwlegacy/3945.c
index c5b1d19..b25c01b 100644
--- a/drivers/net/wireless/iwlegacy/3945.c
+++ b/drivers/net/wireless/iwlegacy/3945.c
@@ -499,7 +499,8 @@ il3945_pass_packet_to_mac80211(struct il_priv *il, struct il_rx_buf *rxb,
 				      le32_to_cpu(rx_end->status), stats);
 
 	skb_add_rx_frag(skb, 0, rxb->page,
-			(void *)rx_hdr->payload - (void *)pkt, len);
+			(void *)rx_hdr->payload - (void *)pkt, len,
+			len);
 
 	il_update_stats(il, false, fc, len);
 	memcpy(IEEE80211_SKB_RXCB(skb), stats, sizeof(*stats));
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index 7b54dbb..17f1c68 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -596,7 +596,8 @@ il4965_pass_packet_to_mac80211(struct il_priv *il, struct ieee80211_hdr *hdr,
 		return;
 	}
 
-	skb_add_rx_frag(skb, 0, rxb->page, (void *)hdr - rxb_addr(rxb), len);
+	skb_add_rx_frag(skb, 0, rxb->page, (void *)hdr - rxb_addr(rxb), len,
+			len);
 
 	il_update_stats(il, false, fc, len);
 	memcpy(IEEE80211_SKB_RXCB(skb), stats, sizeof(*stats));
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rx.c b/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
index 44c6f71..f4b84d1 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rx.c
@@ -796,7 +796,7 @@ static void iwlagn_pass_packet_to_mac80211(struct iwl_priv *priv,
 
 	offset = (void *)hdr - rxb_addr(rxb);
 	p = rxb_steal_page(rxb);
-	skb_add_rx_frag(skb, 0, p, offset, len);
+	skb_add_rx_frag(skb, 0, p, offset, len, len);
 
 	iwl_update_stats(priv, false, fc, len);
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a2b9953..681a187 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1244,7 +1244,7 @@ static inline void skb_fill_page_desc(struct sk_buff *skb, int i,
 }
 
 extern void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page,
-			    int off, int size);
+			    int off, int size, unsigned int truesize);
 
 #define SKB_PAGE_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->nr_frags)
 #define SKB_FRAG_ASSERT(skb) 	BUG_ON(skb_has_frag_list(skb))
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6eb656a..a690cae 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -321,12 +321,12 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 EXPORT_SYMBOL(__netdev_alloc_skb);
 
 void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
-		int size)
+		     int size, unsigned int truesize)
 {
 	skb_fill_page_desc(skb, i, page, off, size);
 	skb->len += size;
 	skb->data_len += size;
-	skb->truesize += size;
+	skb->truesize += truesize;
 }
 EXPORT_SYMBOL(skb_add_rx_frag);
 
