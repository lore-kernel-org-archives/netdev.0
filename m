From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCHv2 net 2/2] ipv4: update RTNH_F_LINKDOWN flag on UP event
Date: Tue, 27 Oct 2015 14:37:38 -0400
Message-ID: <20151027183737.GH3567@gospo.home.greyhouse.net>
References: <1445896753-14464-1-git-send-email-ja@ssi.bg>
 <1445896753-14464-3-git-send-email-ja@ssi.bg>
 <20151027045203.GG3567@gospo.home.greyhouse.net>
 <alpine.LFD.2.11.1510270905500.1994@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:35912 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754411AbbJ0Shn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 14:37:43 -0400
Received: by qgad10 with SMTP id d10so152587676qga.3
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 11:37:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1510270905500.1994@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015 at 09:42:25AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 27 Oct 2015, Andy Gospodarek wrote:
> 
> > I tested this patch and I now see that your reported problem is a result
> > of dummy never taking carrier down.  There was a presumption that
> > carrier notification would go down when hardware went down (or when the
> > logical device backing the hardware went down, but this is clearly not
> > always the case.
> 
> 	It seems not all devices play with the carrier
> after IFF_UP is set and we can not rely on NETDEV_CHANGE
> to update the flag.
Agreed.

> 
> > > +	if (nh_flags & RTNH_F_DEAD) {
> > > +		unsigned int flags = dev_get_flags(dev);
> > > +
> > > +		if (flags & (IFF_RUNNING | IFF_LOWER_UP))
> > > +			nh_flags |= RTNH_F_LINKDOWN;
> > > +	}
> > > +
> > >  	prev_fi = NULL;
> > >  	hash = fib_devindex_hashfn(dev->ifindex);
> > >  	head = &fib_info_devhash[hash];
> > 
> > Logically this patch makes sense, but I feel as though there may be a
> > slightly better option.  Possibly this:
> > 
> > diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> > index 42778d9..7eb7c40 100644
> > --- a/net/ipv4/fib_semantics.c
> > +++ b/net/ipv4/fib_semantics.c
> > @@ -1376,7 +1376,8 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event)
> >  					nexthop_nh->nh_flags |= RTNH_F_DEAD;
> >  					/* fall through */
> >  				case NETDEV_CHANGE:
> > -					nexthop_nh->nh_flags |= RTNH_F_LINKDOWN;
> > +					if (!netif_carrier_ok(dev))
> > +						nexthop_nh->nh_flags |= RTNH_F_LINKDOWN;
> 
> 	There is a problem with this approach. Once
> the RTNH_F_DEAD flag is set, eg. when last address is removed,
> any NETDEV_CHANGE events are ignored in this function.
> As result, we may miss the link-down event if we first
> remove the addresses, so we will not set RTNH_F_LINKDOWN.
Yes, I see that now.  I verified with dummy by setting carrier after a
flush.  Thanks for pointing that out.

> 	Also, when device link goes UP we (FIB) can not guess
> just based on events what is the actual carrier state
> because the NETDEV_CHANGE notification comes only when
> IFF_UP is set. So, this check.
> 
> 	I also attempted to fully recalculate the flag
> in fib_sync_up, i.e. with the option not just to clear it
> but also to add nexthop_nh->nh_flags |= nh_flags_set logic
> but it complicates the code. So, while we always set
> RTNH_F_LINKDOWN when DEAD is set, the logic to conditionally
> clear RTNH_F_LINKDOWN in fib_sync_up looks the cheapest one.
> 
> 	Of course, we have a semantic problem when setting
> RTNH_F_LINKDOWN on last address removal, i.e. this event
> has nothing to do with the link state. But it works because
> RTNH_F_LINKDOWN is valid for lookups only when DEAD flag
> is not set, so that is why my patch looks this way.
The problem you describe here was a concern of mine as well.  I would
really like the output of 'ip route show' to properly reflect the link
state and fix the problem you describe, but it seems like it will not in
this case with your current patch.  I'll do a bit more testing and let
you know.

> 
> >  					break;
> >  				}
> >  				dead++;
> > @@ -1396,7 +1397,8 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event)
> >  				fi->fib_flags |= RTNH_F_DEAD;
> >  				/* fall through */
> >  			case NETDEV_CHANGE:
> > -				fi->fib_flags |= RTNH_F_LINKDOWN;
> > +				if (!netif_carrier_ok(dev))
> > +					fi->fib_flags |= RTNH_F_LINKDOWN;
> >  				break;
> >  			}
> >  			ret++;
> 
> 	I think, we even do not need the RTNH_F_LINKDOWN flag
> in fib_flags, currently it is set but never used.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
