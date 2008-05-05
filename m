From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 05 May 2008 16:39:16 -0700 (PDT)
Message-ID: <20080505.163916.239187195.davem@davemloft.net>
References: <1210027447.8012.15.camel@johannes.berg>
	<20080505.161458.46071527.davem@davemloft.net>
	<1210029835.8012.30.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1210029835.8012.30.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Tue, 06 May 2008 01:23:55 +0200

[ Herbert CC:'d ]

> On Mon, 2008-05-05 at 16:14 -0700, David Miller wrote:
> 
> > If it is cloned, it makes sure the data reference count allows
> > for modification of the buffer.
> 
> Which buffer? skb->data..skb->tail? And isn't that, in mac80211's case,
> at least currently all the buffer anyway?

Right.

For TSO or cases using frag lists of frag page vectors, it gets
more complicated.

Basically, skb_header_cloned()==false means that you can modify
anything covered by skb->data..skb->tail

> Interesting point. I'll have to see when socket filters are run,
> wpa_supplicant could have a tap open I think. Maybe that's why I'm
> seeing so many cloned packets. I think I'll stacktrace skb_clone and
> print that out.

Note that we can even optimize that case even further if we really
have to.

But try to see why the filter used by WPA Supplicant is not effective.
If the filter fails to match, the packet is free'd immediately using
kfree_skb() which should undo clone'age.

Actually, I think I see a potential problem with how the
->dataref bit fields are managed in this situation.  This is
Herbert's creation, so let's ask him :-)

It seems that if we have a TCP packet for which skb_header_cloned()
is false, and this enters dev_hard_start_xmit(), if any network
taps take the packet, we'll never return to skb_header_cloned()==false
state even if every tap immediately kfree_skb(skb)'s the packet.

When we clone, we'll increment only the low 16-bit part of ->dataref.

On free, since skb->nohdr is set, we'll decrement both of (1 <<
SKB_DATAREF_SHIFT) and the low 16-bit counter.

Therefore the packet never becomes re-writable, right?  Is there some
easy way to cure this Herbert?  Apparently having a tap registered
constantly merely to watch for filtered traffic is quite common. :-/

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
