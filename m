From: "Winkler, Tomas" <tomas.winkler@intel.com>
Subject: RE: [PATCH net-2.6] bridge: fix br_multicast_ipv6_rcv for paged skbs
Date: Thu, 30 Dec 2010 23:00:13 +0200
Message-ID: <6F5C1D715B2DA5498A628E6B9C124F04019BF36A8D@hasmsx504.ger.corp.intel.com>
References: <AANLkTi=XQ2DE==ggJHfokUE1=opDVOFxQNeqwY1xZN_8@mail.gmail.com>
	<1293708753-17728-1-git-send-email-tomas.winkler@intel.com>
	<20101230104656.6c5a4b4e@nehalam>
	<1293735134.21956.1.camel@jlt3.sipsolutions.net>
 <20101230110609.08b7ee38@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:13721 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755249Ab0L3VAV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Dec 2010 16:00:21 -0500
In-Reply-To: <20101230110609.08b7ee38@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Thursday, December 30, 2010 9:06 PM
> To: Johannes Berg
> Cc: Winkler, Tomas; davem@davemloft.net; netdev@vger.kernel.org; linux-
> wireless@vger.kernel.org
> Subject: Re: [PATCH net-2.6] bridge: fix br_multicast_ipv6_rcv for paged
> skbs
> 
> On Thu, 30 Dec 2010 19:52:14 +0100
> Johannes Berg <johannes@sipsolutions.net> wrote:
> 
> > On Thu, 2010-12-30 at 10:46 -0800, Stephen Hemminger wrote:
> >
> > > This doesn't look correct. The calculation of the offset doesn't look
> correct.
> > > Just following the skb_clone(), the skb_pull value is "offset".
> > > Also, the other checks return -EINVAL for incorrectly formed packet.
> > >
> > > --- a/net/bridge/br_multicast.c	2010-12-30 10:29:58.579510488 -0800
> > > +++ b/net/bridge/br_multicast.c	2010-12-30 10:43:27.273386691 -0800
> > > @@ -1464,6 +1464,9 @@ static int br_multicast_ipv6_rcv(struct
> > >  	if (offset < 0 || nexthdr != IPPROTO_ICMPV6)
> > >  		return 0;
> > >
> > > +	if (!pskb_may_pull(skb, offset))
> > > +		return -EINVAL;
> > > +
> > >  	/* Okay, we found ICMPv6 header */
> > >  	skb2 = skb_clone(skb, GFP_ATOMIC);
> > >  	if (!skb2)
> >
> > Wouldn't that make more sense after the clone anyway? But if you look at
> > my email, you'll find that there's potentially, and conditionally, more
> > stuff that will be read from the skb's header, which hasn't necessarily
> > been pulled in, so I think this still won't fix all the issues.
> >
> > Seeing how this only affects some ICMPv6 packets, maybe we should just
> > use skb_copy() instead?
> 
> It comes out cleaner, and the check can be simplified.
> 
> --- a/net/bridge/br_multicast.c	2010-12-30 10:47:12.031733855 -0800
> +++ b/net/bridge/br_multicast.c	2010-12-30 11:00:12.135801266 -0800
> @@ -1465,19 +1465,19 @@ static int br_multicast_ipv6_rcv(struct
>  		return 0;
> 
>  	/* Okay, we found ICMPv6 header */
> -	skb2 = skb_clone(skb, GFP_ATOMIC);
> +	skb2 = skb_copy(skb, GFP_ATOMIC);
>  	if (!skb2)
>  		return -ENOMEM;
> 
> +	err = -EINVAL;
> +	if (skb2->len < offset + sizeof(*icmp6h))
> +		goto out;
> +
>  	len -= offset - skb_network_offset(skb2);
> 
>  	__skb_pull(skb2, offset);
>  	skb_reset_transport_header(skb2);
> 
> -	err = -EINVAL;
> -	if (!pskb_may_pull(skb2, sizeof(*icmp6h)))
> -		goto out;
> -
>  	icmp6h = icmp6_hdr(skb2);
> 
>  	switch (icmp6h->icmp6_type) {
> 
>
Sorry for dump question but isn't there performance penalty on using skb_copy vs. skb_clone?

Anyhow Below is a code snippet from ip6_input.c so you probably would want to fix it all over. 
BTW offset and the pointer arithmetic really gives the same number +1, I'm not surly why the original author would thought it be safer than just using offset.

					offset = ipv6_skip_exthdr(skb, sizeof(*hdr),
                                                          &nexthdr);
                                if (offset < 0)
                                        goto out;
 
                                if (nexthdr != IPPROTO_ICMPV6)
                                        goto out;
 
                                if (!pskb_may_pull(skb, (skb_network_header(skb) +
                                                   offset + 1 - skb->data)))
                                        goto out;
 
                                icmp6 = (struct icmp6hdr *)(skb_network_header(skb) + offset);



Thanks
Tomas


---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

