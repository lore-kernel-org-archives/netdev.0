From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 10903] New: ssh connections hang with
 2.6.26-rc5
Date: Wed, 18 Jun 2008 01:26:58 -0700 (PDT)
Message-ID: <20080618.012658.264455870.davem@davemloft.net>
References: <Pine.LNX.4.64.0806180152410.32420@wrl-59.cs.helsinki.fi>
	<1213773887.3803.158.camel@johannes.berg>
	<20080618.010528.05757230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org, didier-efQUOpnRmEvQT0dZR+AlfA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080618.010528.05757230.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date: Wed, 18 Jun 2008 01:05:28 -0700 (PDT)

> If we can't figure out what's going on here soon (like, in less than a
> day) we should revert that changeset.
> 
> Actually, I think I see how the changeset might be wrong.  I think
> the encryption layer of mac80211 assumes it can write over the
> data area of the SKB it's working on, not just the headers.
> 
> Once this happens, any retransmits done by SKB will fail because the
> master packet data on TCP's retransmit queue is now this encrypted
> garbage.

After some discussion about this with Johannes on IRC, we are
absolutely convinced this is exactly the problem.

I intend to send the following revert to Linus tonight so we
can close this:

--------------------
Revert "mac80211: Use skb_header_cloned() on TX path."

This reverts commit 608961a5eca8d3c6bd07172febc27b5559408c5d.

The problem is that the mac80211 stack not only needs to be able to
muck with the link-level headers, it also might need to mangle all of
the packet data if doing sw wireless encryption.

This fixes kernel bugzilla #10903.  Thanks to Didier Raboud (for the
bugzilla report), Andrew Prince (for bisecting), Johannes Berg (for
bringing this bisection analysis to my attention), and Ilpo (for
trying to analyze this purely from the TCP side).

In 2.6.27 we can take another stab at this, by using something like
skb_cow_data() when the TX path of mac80211 ends up with a non-NULL
tx->key.  The ESP protocol code in the IPSEC stack can be used as a
model for implementation.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/mac80211/tx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 1d7dd54..28d8bd5 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1562,13 +1562,13 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	 * be cloned. This could happen, e.g., with Linux bridge code passing
 	 * us broadcast frames. */
 
-	if (head_need > 0 || skb_header_cloned(skb)) {
+	if (head_need > 0 || skb_cloned(skb)) {
 #if 0
 		printk(KERN_DEBUG "%s: need to reallocate buffer for %d bytes "
 		       "of headroom\n", dev->name, head_need);
 #endif
 
-		if (skb_header_cloned(skb))
+		if (skb_cloned(skb))
 			I802_DEBUG_INC(local->tx_expand_skb_head_cloned);
 		else
 			I802_DEBUG_INC(local->tx_expand_skb_head);
-- 
1.5.5.1.308.g1fbb5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
