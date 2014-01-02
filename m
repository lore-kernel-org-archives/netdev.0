From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: don't call addrconf_dst_alloc again when enable lo
Date: Thu, 2 Jan 2014 09:23:25 +0100
Message-ID: <20140102082325.GC22494@order.stressinduktion.org>
References: <1371352470-3226-1-git-send-email-gaofeng@cn.fujitsu.com> <20130619.230532.1329281330568271336.davem@davemloft.net> <20131231035718.GB27636@order.stressinduktion.org> <52C4FDBE.5030607@huawei.com> <20140102065429.GB22494@order.stressinduktion.org> <52C51C1E.9040603@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, gaofeng@cn.fujitsu.com,
	kumaran.4353@gmail.com, netdev@vger.kernel.org
To: chenweilong <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34659 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbaABIX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 03:23:26 -0500
Content-Disposition: inline
In-Reply-To: <52C51C1E.9040603@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 02, 2014 at 03:58:22PM +0800, chenweilong wrote:
> On 2014/1/2 14:54, Hannes Frederic Sowa wrote:
> > On Thu, Jan 02, 2014 at 01:48:46PM +0800, chenweilong wrote:
> >> On 2013/12/31 11:57, Hannes Frederic Sowa wrote:
> >>> On Wed, Jun 19, 2013 at 11:05:32PM -0700, David Miller wrote:
> >>>> From: Gao feng <gaofeng@cn.fujitsu.com>
> >>>> Date: Sun, 16 Jun 2013 11:14:30 +0800
> >>>>
> >>>>> If we disable all of the net interfaces, and enable
> >>>>> un-lo interface before lo interface, we already allocated
> >>>>> the addrconf dst in ipv6_add_addr. So we shouldn't allocate
> >>>>> it again when we enable lo interface.
> >>>>>
> >>>>> Otherwise the message below will be triggered.
> >>>>> unregister_netdevice: waiting for sit1 to become free. Usage count = 1
> >>>>>
> >>>>> This problem is introduced by commit 25fb6ca4ed9cad72f14f61629b68dc03c0d9713f
> >>>>> "net IPv6 : Fix broken IPv6 routing table after loopback down-up"
> >>>>>
> >>>>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> >>>>
> >>>> This is the second such regression added by that commit :-/
> >>>>
> >>>> Applied and queue up for -stable, thanks.
> >>>
> >>> Hmm, and this change also has a regression and breaks the original fix. :/
> >>>
> >>> https://bugzilla.kernel.org/show_bug.cgi?id=67951
> >>>
> >>> I tried to track it down but it seems pretty complicated. Maybe we have to
> >>> special-case the take-down of the loopback device.
> >>>
> >>>
> >>>
> >>
> >> When I did the tests,If 'ifconfig lo down',all IPv6 connection broken,
> >> but IPv4 connection were still OK.
> >>
> >> Is it designed like that or a bug?
> > 
> > This seems to solve the loopback up/down problem, but there are still
> > some issues with up/down of interfaces and routing table interactions.
> > 
> > We enable routes over interfaces when interface is actually down and
> > kick manually specified on-link routes when we actually should try to
> > keep them and just disable them.
> > 
> > diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> > index 6c16345..61d752a 100644
> > --- a/net/ipv6/addrconf.c
> > +++ b/net/ipv6/addrconf.c
> > @@ -2629,8 +2629,10 @@ static void init_loopback(struct net_device *dev)
> >  			if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
> >  				continue;
> >  
> > -			if (sp_ifa->rt)
> > +			if (sp_ifa->rt) {
> > +				ip6_ins_rt(sp_ifa->rt);
> >  				continue;
> > +			}
> >  
> >  			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, false);
> >  
> > 
> > .
> > 
> I test the patch,it has the problem Gao feng reported.

Thanks for testing. I wonder why.

> How about this:
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index d5fa5b8..5e2db6e 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2609,10 +2609,13 @@ static void init_loopback(struct net_device *dev)
> 
>                         if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
>                                 continue;
> 
> -                       if (sp_ifa->rt)
> -                               continue;
> +                       if (sp_ifa->rt && sp_ifa->rt->dst.dev == dev){
> +                               ip6_del_rt(sp_ifa->rt);
> +                       }
> 

It could work, but it looks like a band-aid for another problem to me. I am
not sure if it is in init_loopback, yet.
