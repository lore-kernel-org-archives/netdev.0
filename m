From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 05 May 2008 15:37:30 -0700 (PDT)
Message-ID: <20080505.153730.186617868.davem@davemloft.net>
References: <1210018214.4181.27.camel@johannes.berg>
	<20080505.134420.194001886.davem@davemloft.net>
	<1210021066.4181.41.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1210021066.4181.41.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Mon, 05 May 2008 22:57:46 +0200

> But I cannot modify the ethernet header that'll live on in the skb data
> so that's not useful.

Actually, you can, if skb_header_cloned() returns false.

When skb_header_cloned() returns false you can change the
headers however you like.

I'm not sure if it helps the bridging case or not, but in
any event, the following patch should work and reduce the
number of cases where pskb_expand_head() is necessary on
TX.

diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index f35eaea..86f0e36 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1562,13 +1562,13 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	 * be cloned. This could happen, e.g., with Linux bridge code passing
 	 * us broadcast frames. */
 
-	if (head_need > 0 || skb_cloned(skb)) {
+	if (head_need > 0 || skb_header_cloned(skb)) {
 #if 0
 		printk(KERN_DEBUG "%s: need to reallocate buffer for %d bytes "
 		       "of headroom\n", dev->name, head_need);
 #endif
 
-		if (skb_cloned(skb))
+		if (skb_header_cloned(skb))
 			I802_DEBUG_INC(local->tx_expand_skb_head_cloned);
 		else
 			I802_DEBUG_INC(local->tx_expand_skb_head);
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
