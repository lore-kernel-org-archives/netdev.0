From: Benjamin Poirier <bpoirier@suse.com>
Subject: Re: [PATCH] mld, igmp: Fix reserved tailroom calculation
Date: Mon, 29 Feb 2016 10:08:35 -0800
Message-ID: <20160229180835.GA6224@f1.synalogic.ca>
References: <1456603028-12589-2-git-send-email-bpoirier@suse.com>
 <56D45C6A.5040606@iogearbox.net>
 <20160229151920.GA5474@f1.synalogic.ca>
 <56D4670C.40902@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46183 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871AbcB2SIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 13:08:47 -0500
Content-Disposition: inline
In-Reply-To: <56D4670C.40902@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/02/29 16:43, Hannes Frederic Sowa wrote:
> On 29.02.2016 16:19, Benjamin Poirier wrote:
> >On 2016/02/29 15:57, Daniel Borkmann wrote:
> >[...]
> >>
> >>[ cutting the IPv4 part off as diff is the same ]
> >>
> >>>diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> >>>index 5ee56d0..c157edc 100644
> >>>--- a/net/ipv6/mcast.c
> >>>+++ b/net/ipv6/mcast.c
> >>>@@ -1574,9 +1574,9 @@ static struct sk_buff *mld_newpack(struct inet6_dev *idev, unsigned int mtu)
> >>>  		return NULL;
> >>>
> >>>  	skb->priority = TC_PRIO_CONTROL;
> >>>-	skb->reserved_tailroom = skb_end_offset(skb) -
> >>>-				 min(mtu, skb_end_offset(skb));
> >>>  	skb_reserve(skb, hlen);
> >>>+	skb->reserved_tailroom = skb_tailroom(skb) -
> >>>+		min_t(int, mtu, skb_tailroom(skb) - tlen);
> >>
> >>Are you sure this is correct? Wouldn't that mean (assuming we allocated
> >>enough space), that I could now fill a larger than MTU frame?
> >
> >Quoting back a part of the log:
> >
> >>>The maximum space available for ip headers and payload without
> >>>fragmentation is min(mtu, data + extra). Therefore,
> >>>reserved_tailroom
> >>>= data + extra + tlen - min(mtu, data + extra)
> >>>= skb_end_offset - hlen - min(mtu, skb_end_offset - hlen - tlen)
> >>>= skb_tailroom - min(mtu, skb_tailroom - tlen) ; after skb_reserve(hlen)
> >
> >The min() takes care of the situation you describe, ie. if the allocated
> >space is large, reserved_tailroom will be large enough that we do not
> >use more space than the mtu.
> >
> >I tested the mld and igmp code with different driver parameters, mtu
> >values, number of multicast address records and even allocation
> >failures. If you think the formula is wrong, please provide a
> >counter-example with hlen, tlen, mtu and size values.
> 
> I think the code is fine albeit I think we should remove the min macro and
> just do something:
> 
> if (skb_tailroom(skb) > mtu)
> 	skb->reserved_tailroom = skb_tailroom(skb) - mtu;
> 
> Does that make sense? I think it is much more readable.

That is not equivalent. It fails to take tlen into account.

For igmp, consider this case:
with hlen = 16, mtu = 9000, tlen = 8,
additionally, suppose that the first iteration of the allocation loop
(alloc_skb(9000 + 16 + 8, ...) which requires 4 pages) fails and the
second iteration (alloc_skb((9000 >> 1) + 16 + 8, ...) which requires 2
pages) succeeds:
	size = (9000 >> 1) + 16 + 8 = 4524
	skb_end_offset = 8192 - 320 = 7872
	tailroom = 7872 - 16 = 7856

	data = 9000 >> 1 = 4500
	extra = 7872 - 4524 = 3348

	reserved tailroom (patch version)
		= 4500 + 3348 + 8 - min(9000, 4500 + 3348)
		= 8
	reserved tailroom (your version)
		= 0

	Headers are ipv4 + igmpv3 = 24 + 8 = 32, records are 8 bytes
	With 978 igmpv3 records, with your version, we would output an
	skb that has less tailroom (0) than dev->needed_tailroom (8).

For mld, consider this case:
with hlen = 16, mtu = 9000, tlen = 8:
	size = 3776 (SKB_MAX_ORDER case)
	skb_end_offset = 3776
	tailroom = 3776 - 16 = 3760

	data = 3776 - 16 - 8 = 3752
	extra = 0

	reserved tailroom (patch version)
		= 3752 + 0 + 8 - min(9000, 3752 + 0)
		= 8
	reserved tailroom (your version)
		= 0

	Headers are ipv6 + icmpv6 = 48 + 8 = 56, records are 20 bytes
	With 185 mld records, with your formula, we would output an skb that
	has less tailroom (4) than dev->needed_tailroom (8).

If you think we should write the expression with "if" instead of "min",
instead of the current

+	skb->reserved_tailroom = skb_tailroom(skb) -
+		min_t(int, mtu, skb_tailroom(skb) - tlen);

it should be:

+	if (mtu < skb_tailroom(skb) - tlen)
+		skb->reserved_tailroom = skb_tailroom(skb) - mtu;
+	else
+		skb->reserved_tailroom = tlen;

The second alternative does not look more readable to me but I have been
looking at that expression for a while. If you think that it is more
readable, I will resend the patch expressed that way. Please let me
know.
