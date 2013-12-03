From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] mac80211: rx: Neaten ieee80211_deliver_skb, remove
 compare_ether_addr
Date: Tue, 03 Dec 2013 10:29:20 -0800
Message-ID: <1386095360.15309.29.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Remove the unnecessary duplicate test of "if (skb) {"
when !CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.

Remove now unnecessary __maybe_unused, neaten comment
Remove unnecessary parenthesis around align cast.
Substitute reference to deprecated compare_ether_addr
with ether_addr_equal.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 net/mac80211/rx.c | 33 +++++++++++++++------------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index caecef8..b178c8f 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1937,20 +1937,17 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
 		}
 	}
 
-	if (skb) {
-		int align __maybe_unused;
-
 #ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
-		/*
-		 * 'align' will only take the values 0 or 2 here
-		 * since all frames are required to be aligned
-		 * to 2-byte boundaries when being passed to
-		 * mac80211; the code here works just as well if
-		 * that isn't true, but mac80211 assumes it can
-		 * access fields as 2-byte aligned (e.g. for
-		 * compare_ether_addr)
+	if (skb) {
+		/* 'align' will only take the values 0 or 2 here since all
+		 * frames are required to be aligned to 2-byte boundaries
+		 * when being passed to mac80211; the code here works just
+		 * as well if that isn't true, but mac80211 assumes it can
+		 * access fields as 2-byte aligned (e.g. for ether_addr_equal)
 		 */
-		align = ((unsigned long)(skb->data + sizeof(struct ethhdr))) & 3;
+		int align;
+
+		align = (unsigned long)(skb->data + sizeof(struct ethhdr)) & 3;
 		if (align) {
 			if (WARN_ON(skb_headroom(skb) < 3)) {
 				dev_kfree_skb(skb);
@@ -1963,14 +1960,14 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
 				skb_set_tail_pointer(skb, len);
 			}
 		}
+	}
 #endif
 
-		if (skb) {
-			/* deliver to local stack */
-			skb->protocol = eth_type_trans(skb, dev);
-			memset(skb->cb, 0, sizeof(skb->cb));
-			netif_receive_skb(skb);
-		}
+	if (skb) {
+		/* deliver to local stack */
+		skb->protocol = eth_type_trans(skb, dev);
+		memset(skb->cb, 0, sizeof(skb->cb));
+		netif_receive_skb(skb);
 	}
 
 	if (xmit_skb) {


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
