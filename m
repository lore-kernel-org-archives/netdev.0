From: Michal Humpula <michal.humpula@web4u.cz>
Subject: Re: [PATCH net-next-2.6] ipv6: adding ip_nonlocal_bind option from ipv4
Date: Mon, 5 Jul 2010 08:56:12 +0200
Message-ID: <201007050856.12576.michal.humpula@web4u.cz>
References: <201007032238.28344.michal.humpula@web4u.cz> <20100705020333.GA14260@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hudrydum.cz ([88.208.90.178]:58927 "EHLO hudrydum.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753163Ab0GEG4R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 02:56:17 -0400
In-Reply-To: <20100705020333.GA14260@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 05 of July 2010 04:03:36 Simon Horman wrote:
> On Sat, Jul 03, 2010 at 10:38:28PM +0200, Michal Humpula wrote:
> > Adds ability to bind non-local IPv6 address the same way as for IPv4
> > 
> > Signed-off-by: Michal Humpula <michal.humpula@web4u.cz>
> > 
> > diff --git a/Documentation/networking/ip-sysctl.txt
> > b/Documentation/networking/ip-sysctl.txt index f350c69..27fa09a 100644
> > --- a/Documentation/networking/ip-sysctl.txt
> > +++ b/Documentation/networking/ip-sysctl.txt
> > @@ -962,6 +962,10 @@ bindv6only - BOOLEAN
> > 
> >  		FALSE: enable IPv4-mapped address feature
> >  	
> >  	Default: FALSE (as specified in RFC2553bis)
> 
> I think a blank line here would be nice.
> 
> > +ipv6_nonlocal_bind - BOOLEAN
> > +	If set, allows processes to bind() to non-local IPv6 addresses,
> > +	which can be quite useful - but may break some applications.
> > +	Default: 0
> > 
> >  IPv6 Fragmentation:
> > 
> > diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> > index e830cd4..55b3552 100644
> > --- a/net/ipv6/af_inet6.c
> > +++ b/net/ipv6/af_inet6.c
> > 
> > @@ -345,8 +347,10 @@ int inet6_bind(struct socket *sock, struct sockaddr
> > *uaddr, int addr_len)
> > 
> >  			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
> >  			
> >  				if (!ipv6_chk_addr(net, &addr->sin6_addr,
> >  				
> >  						   dev, 0)) {
> > 
> > -					err = -EADDRNOTAVAIL;
> > -					goto out_unlock;
> > +					if (!sysctl_ipv6_nonlocal_bind) {
> > +						err = -EADDRNOTAVAIL;
> > +						goto out_unlock;
> > +					}
> > 
> >  				}
> >  			
> >  			}
> >  			rcu_read_unlock();
> 
> Perhaps the inner two if statements could be combined to remove
> unnecessary nesting? And perhaps check for sysctl_ipv6_nonlocal_bind first,
> as presumably its a cheaper, though less likely to succeed check.
> 
> 			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
> 				if (!sysctl_ipv6_nonlocal_bind &&
> 				    !ipv6_chk_addr(net, &addr->sin6_addr,
> 						   dev, 0)) {
> 					err = -EADDRNOTAVAIL;
> 					goto out_unlock;
> 				}
> 			}
> 
> Actually, I wonder if all three if statements could be combined.
> 
> 			if (!(addr_type & IPV6_ADDR_MULTICAST) &&
> 		            !sysctl_ipv6_nonlocal_bind &&
> 			    !ipv6_chk_addr(net, &addr->sin6_addr, dev, 0)) {
> 				err = -EADDRNOTAVAIL;
> 				goto out_unlock;
> 			}
> 

Thanks you for review, I agree with the objections. I'll send a corrected version.
