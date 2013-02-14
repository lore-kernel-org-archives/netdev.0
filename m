From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/3] ipv6: use newly introduced __ipv6_addr_needs_scope_id and ipv6_iface_scope_id
Date: Thu, 14 Feb 2013 19:53:26 +0100
Message-ID: <20130214185326.GB8611@order.stressinduktion.org>
References: <20130212221634.GA7212@order.stressinduktion.org> <20130213001357.GB1096@order.stressinduktion.org> <511AFF9A.8040506@hp.com> <511BC3B3.3070405@linux-ipv6.org> <20130214042543.GB24534@order.stressinduktion.org> <511D01FA.8080506@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35809 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758544Ab3BNSx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 13:53:27 -0500
Content-Disposition: inline
In-Reply-To: <511D01FA.8080506@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 14, 2013 at 10:25:46AM -0500, Brian Haley wrote:
> > [PATCH net-next RFC] ipv6: introduce new type ipv6_addr_props to hold type and scope
> > 
> > ---
> >  include/net/ipv6.h       | 16 +++++---
> >  net/ipv6/addrconf.c      | 27 +++++++-------
> >  net/ipv6/addrconf_core.c | 97 +++++++++++++++++++++++++++++++-----------------
> >  net/ipv6/datagram.c      | 12 +++---
> >  4 files changed, 95 insertions(+), 57 deletions(-)
> > 
> > diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> > index 851d541..3a3ec1cc 100644
> > --- a/include/net/ipv6.h
> > +++ b/include/net/ipv6.h
> > @@ -298,20 +298,26 @@ static inline int ip6_frag_mem(struct net *net)
> >  #define IPV6_FRAG_LOW_THRESH	(3 * 1024*1024)	/* 3145728 */
> >  #define IPV6_FRAG_TIMEOUT	(60 * HZ)	/* 60 seconds */
> >  
> > -extern int __ipv6_addr_type(const struct in6_addr *addr);
> > +struct ipv6_addr_props {
> > +	u16 type;
> > +	s16 scope;
> > +};
> 
> Seeing this makes me think we should unify the flags and scope members of
> inet6_ifaddr to something like this, moving to a single set of values for IPv6
> addresses.  Then ipv6_dev_get_saddr() wouldn't have to use __ipv6_adr_type() as
> much since the address struct would already have the values.  Possible future
> work...

Thanks for your feedback. I will incooperate it in my patch.

> >  	if ((st & htonl(0xFFC00000)) == htonl(0xFEC00000))
> > -		return (IPV6_ADDR_SITELOCAL | IPV6_ADDR_UNICAST |
> > -			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_SITELOCAL));		/* addr-select 3.1 */
> > +		/* addr-select 3.1 */
> > +		return (struct ipv6_addr_props){
> > +			.type = IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST,
> > +			.scope = IPV6_ADDR_SCOPE_SITELOCAL,
> > +		};
> 
> type here is wrong, should be IPV6_ADDR_SITELOCAL not linklocal.

Oops, of course. :)

> > @@ -653,13 +653,15 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
> >  					rcu_read_unlock();
> >  					return -ENODEV;
> >  				}
> > -			} else if (addr_type & IPV6_ADDR_LINKLOCAL) {
> > +			} else if (addr_props.type & IPV6_ADDR_LINKLOCAL) {
> 
> Could be (addr_props.scope == IPV6_ADDR_SCOPE_LINKLOCAL), right?

This code will be changed by my other patches (see the series I posted
about introducing helper functions for checking for sin6_scope_id, patch
1/2). I think I will let it as is for the time being.

Thanks,

  Hannes
