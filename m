From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-2.6] bridge: fix br_multicast_ipv6_rcv for paged
 skbs
Date: Thu, 30 Dec 2010 11:06:09 -0800
Message-ID: <20101230110609.08b7ee38@nehalam>
References: <AANLkTi=XQ2DE==ggJHfokUE1=opDVOFxQNeqwY1xZN_8@mail.gmail.com>
	<1293708753-17728-1-git-send-email-tomas.winkler@intel.com>
	<20101230104656.6c5a4b4e@nehalam>
	<1293735134.21956.1.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1293735134.21956.1.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Dec 2010 19:52:14 +0100
Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:

> On Thu, 2010-12-30 at 10:46 -0800, Stephen Hemminger wrote:
> 
> > This doesn't look correct. The calculation of the offset doesn't look correct.
> > Just following the skb_clone(), the skb_pull value is "offset".
> > Also, the other checks return -EINVAL for incorrectly formed packet.
> > 
> > --- a/net/bridge/br_multicast.c	2010-12-30 10:29:58.579510488 -0800
> > +++ b/net/bridge/br_multicast.c	2010-12-30 10:43:27.273386691 -0800
> > @@ -1464,6 +1464,9 @@ static int br_multicast_ipv6_rcv(struct
> >  	if (offset < 0 || nexthdr != IPPROTO_ICMPV6)
> >  		return 0;
> >  
> > +	if (!pskb_may_pull(skb, offset))
> > +		return -EINVAL;
> > +
> >  	/* Okay, we found ICMPv6 header */
> >  	skb2 = skb_clone(skb, GFP_ATOMIC);
> >  	if (!skb2)
> 
> Wouldn't that make more sense after the clone anyway? But if you look at
> my email, you'll find that there's potentially, and conditionally, more
> stuff that will be read from the skb's header, which hasn't necessarily
> been pulled in, so I think this still won't fix all the issues.
> 
> Seeing how this only affects some ICMPv6 packets, maybe we should just
> use skb_copy() instead?

It comes out cleaner, and the check can be simplified.

--- a/net/bridge/br_multicast.c	2010-12-30 10:47:12.031733855 -0800
+++ b/net/bridge/br_multicast.c	2010-12-30 11:00:12.135801266 -0800
@@ -1465,19 +1465,19 @@ static int br_multicast_ipv6_rcv(struct
 		return 0;
 
 	/* Okay, we found ICMPv6 header */
-	skb2 = skb_clone(skb, GFP_ATOMIC);
+	skb2 = skb_copy(skb, GFP_ATOMIC);
 	if (!skb2)
 		return -ENOMEM;
 
+	err = -EINVAL;
+	if (skb2->len < offset + sizeof(*icmp6h))
+		goto out;
+
 	len -= offset - skb_network_offset(skb2);
 
 	__skb_pull(skb2, offset);
 	skb_reset_transport_header(skb2);
 
-	err = -EINVAL;
-	if (!pskb_may_pull(skb2, sizeof(*icmp6h)))
-		goto out;
