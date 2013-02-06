From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Wed, 6 Feb 2013 17:04:09 +0100
Message-ID: <20130206160409.GB18040@order.stressinduktion.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <20130206130739.GA1305@eerihug-hybrid.ki.sw.ericsson.se> <20130206134950.GD10290@order.stressinduktion.org> <51127781.2000504@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47756 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755083Ab3BFQEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 11:04:10 -0500
Content-Disposition: inline
In-Reply-To: <51127781.2000504@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 07, 2013 at 12:32:17AM +0900, YOSHIFUJI Hideaki wrote:
> Hannes Frederic Sowa wrote:
> > On Wed, Feb 06, 2013 at 02:07:39PM +0100, Erik Hugne wrote:
> >> On Wed, Feb 06, 2013 at 01:12:48PM +0100, Hannes Frederic Sowa wrote:
> >>> Fixing the output path should be relatively straightforward, please test
> >>> the following patch.
> >>
> >> Tested OK.
> >>
> >>> Looking at the input path, I think there is also no input protection
> >>> for ff01::/16 addresses from the wire if you bind such an address.
> >>
> >> Yes, this needs to be filtered on the input side aswell.
> > 
> > This patch should do the trick. Perhaps you could also take it for a test
> > drive? Thanks!
> > 
> > [PATCH net-next] ipv6: don't accept node local multicast traffic from the wire
> > 
> > Cc: Erik Hugne <erik.hugne@ericsson.com>
> > Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> >  net/ipv6/ip6_input.c | 10 ++++++++++
> >  1 file changed, 10 insertions(+)
> > 
> > diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> > index 4ac5bf3..a2f71d2 100644
> > --- a/net/ipv6/ip6_input.c
> > +++ b/net/ipv6/ip6_input.c
> > @@ -126,6 +126,16 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
> >  	if (ipv6_addr_is_multicast(&hdr->saddr))
> >  		goto err;
> >  
> > +	/*
> > +	 * RFC4291 2.7
> > +	 * Interface-Local scope spans only a single interface on a node
> > +         * and is useful only for loopback transmission of multicast.
> > +	 */
> > +	if (ipv6_addr_is_multicast(&hdr->daddr) &&
> > +	    IPV6_ADDR_MC_SCOPE(&hdr->daddr) <= IPV6_ADDR_SCOPE_NODELOCAL &&
> > +	    skb->pkt_type != PACKET_LOOPBACK)
> > +		goto err;
> > +
> >  	skb->transport_header = skb->network_header + sizeof(*hdr);
> >  	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
> 
> NAK.
> 
> Well, do you have relevant RFC?
> RFC4291 says that we should drop ff00::/16, but not ff01::/16.

I know what you mean, the RFC does not state it directly. Hm, the BSDs seem to
drop such destination addresses, too, if they don't originate from a loopback
interface. Or did you mean that there is a flaw in the skb->pkt_type !=
PACKET_LOOPBACK condition?
