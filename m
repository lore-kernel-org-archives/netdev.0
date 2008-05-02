From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Fri, 02 May 2008 16:33:34 -0700 (PDT)
Message-ID: <20080502.163334.148944203.davem@davemloft.net>
References: <1209639500.7067.0.camel@johannes.berg>
	<20080501110341.GD7490@gondor.apana.org.au>
	<1209760731.3608.17.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1209760731.3608.17.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Fri, 02 May 2008 22:38:51 +0200

> I'm confused. The area should be used say with encryption when it's
> actually necessary. Maybe there's always enough headroom for some
> reason now?

That's possible.

There are paths, that, although they could take advantage of the
fact that all of the non-header packet data is going to come from
pages, they don't and allocate a full MTU skb->data area anyways.

> On another note, why is this truesize mismatch a bug anyway? I mean, the
> field could just be called "socket_charged_size" and simply be required
> to have the same value throughout the skb lifetime, the slight mismatch
> between charged bytes and actually used bytes wouldn't usually matter
> too much, would it?

Sure the name could change, but the problem wouldn't.

We can't update skb->truesize during arbitray skb->data reallocations,
because it could corrupt the socket accounting.

On the other hand, if we provide ways for users to subvert the socket
buffer limits, we might as well not try to limit anything.

Take a look at some ethernet drivers that implement TSO in a way that
requires munging the IP headers for whatever reason.  If they need to
COW the packet data in order to modify it, they always do this with
pskb_expand_head(skb, 0, 0, GFP_*) exactly so that they don't modify
the SKB data size, and exactly so that the skb->truesize value stays
accurate.

Try to find out exactly what's going wrong here, you seem to be
close.  Once we know the precise issue we can talk about real
changes to make this easier to cope with and debug in the future.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
