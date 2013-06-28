From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] iwl3945: better skb management in rx path
Date: Fri, 28 Jun 2013 07:50:24 -0700
Message-ID: <1372431024.3301.277.camel@edumazet-glaptop>
References: <1372421021.3301.263.camel@edumazet-glaptop>
	 <CAMcMvshEdsFZ2PVEpaq0e2P4L+cksshjB56x2YvA4wt3T+3__w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Steinar H. Gunderson" <sesse-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Paul Stewart <pstew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMcMvshEdsFZ2PVEpaq0e2P4L+cksshjB56x2YvA4wt3T+3__w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

On Fri, 2013-06-28 at 07:38 -0700, Paul Stewart wrote:

> Presumably this 256 is related to the "dev_alloc_skb(256)"?  It might
> be worth making this a constant of some sort so they don't
> inadvertently drift apart in the future.

Hi Paul !

Well, I can do that, but the 128 was not a constant to begin with ;)

Thanks

[PATCH v2] iwl3945: better skb management in rx path

Steinar reported reallocations of skb->head with IPv6, leading to
a warning in skb_try_coalesce()

It turns out iwl3945 has several problems :

1) skb->truesize is underestimated. 
   We really consume PAGE_SIZE bytes for a fragment,
   not the frame length.
2) 128 bytes of initial headroom is a bit low and forces reallocations.
3) We can avoid consuming a full page for small enough frames.

Reported-by: Steinar H. Gunderson <sesse-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Paul Stewart <pstew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
v2: use a SMALL_PACKET_SIZE macro

 drivers/net/wireless/iwlegacy/3945.c |   32 +++++++++++++++----------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/3945.c b/drivers/net/wireless/iwlegacy/3945.c
index c092033..38e6be6 100644
--- a/drivers/net/wireless/iwlegacy/3945.c
+++ b/drivers/net/wireless/iwlegacy/3945.c
@@ -475,6 +475,8 @@ il3945_is_network_packet(struct il_priv *il, struct ieee80211_hdr *header)
 	}
 }
 
+#define SMALL_PACKET_SIZE 256
+
 static void
 il3945_pass_packet_to_mac80211(struct il_priv *il, struct il_rx_buf *rxb,
 			       struct ieee80211_rx_status *stats)
@@ -483,14 +485,13 @@ il3945_pass_packet_to_mac80211(struct il_priv *il, struct il_rx_buf *rxb,
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
@@ -506,26 +507,33 @@ il3945_pass_packet_to_mac80211(struct il_priv *il, struct il_rx_buf *rxb,
 		D_INFO("Woke queues - frame received on passive channel\n");
 	}
 
-	skb = dev_alloc_skb(128);
+	skb = dev_alloc_skb(SMALL_PACKET_SIZE);
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
