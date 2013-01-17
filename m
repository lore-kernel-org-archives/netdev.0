From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Thu, 17 Jan 2013 17:17:55 +0100
Message-ID: <20130117161755.GA974@order.stressinduktion.org>
References: <20130117033258.GA23782@order.stressinduktion.org> <50F81C4B.3050406@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34016 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756903Ab3AQQR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 11:17:56 -0500
Content-Disposition: inline
In-Reply-To: <50F81C4B.3050406@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 18, 2013 at 12:44:11AM +0900, YOSHIFUJI Hideaki wrote:
> Hannes Frederic Sowa wrote:
> > This patch adds anti-spoofing checks in sit.c as specified in RFC3964
> > section 5.2 for 6to4 and RFC5969 section 12 for 6rd. I left out the
> > checks which could easily be implemented with netfilter.
> > 
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> >  net/ipv6/sit.c | 27 +++++++++++++++++++++++++--
> >  1 file changed, 25 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> > index cfba99b..2b4c15a 100644
> > --- a/net/ipv6/sit.c
> > +++ b/net/ipv6/sit.c
> > @@ -590,6 +590,22 @@ out:
> >  	return err;
> >  }
> >  
> > +static int sit_chksrc(struct ip_tunnel *tunnel, const __be32 *addr,
> > +		const struct in6_addr *addr6)
> > +{
> > +#ifdef CONFIG_IPV6_SIT_6RD
> > +	if (ipv6_prefix_equal(addr6, &tunnel->ip6rd.prefix,
> > +				tunnel->ip6rd.prefixlen) &&
> > +		memcmp(addr, &addr6->s6_addr16[1], 4))
> > +		return 0;
> > +#else
> > +	if (addr6->s6_addr16[0] == htons(0x2002) &&
> > +		memcmp(addr, &addr6->s6_addr16[1], 4))
> > +		return 0;
> > +#endif
> > +	return 1;
> >
> 
> It seems wrong.  Check should be done for
> - inner source prefix

I intentionally skipped this check because it could be easily checked
with netfilter (after decapsulation) and I am a bit afraid breaking
already working setups with non-standard prefixes. Do you think I should
add this check anyway?

> - embedded source with relay_prefix.

I'll use try_6rd to extract the ipv4 address and check it against the
outer address. I will check this later if I have access to my test setup.

> - inner destination prefix.
>
> Note: embedded destination is not being checked.

Also left these checks out because of the same reasons I stated above. Should
they be added?

Thanks for the review!
