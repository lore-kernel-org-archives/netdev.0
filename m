From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: If a public address is deleted then also delete all temporary addresses still referring to it
Date: Thu, 27 Mar 2014 03:53:03 +0100
Message-ID: <20140327025303.GJ22086@order.stressinduktion.org>
References: <5328B0B0.7070305@web.de> <20140319202123.GH12291@order.stressinduktion.org> <532A096C.8030200@web.de> <20140319224121.GI12291@order.stressinduktion.org> <53333829.2000806@web.de> <53334B8E.8000807@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Heiner Kallweit <heiner.kallweit@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34117 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbaC0CxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 22:53:04 -0400
Content-Disposition: inline
In-Reply-To: <53334B8E.8000807@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 10:50:06PM +0100, Heiner Kallweit wrote:
> > I spent some thoughts on this topic and it seems to me that deleting a temporary address from user space will break TCP connections most of the time
> > as the newly created temporary address will be different from the old one.

Yes, I can confirm that we will generate new rndid and thus will generate a
new address.

> > Setting a temporary address to deprecated is also not possible from user space currently as netlink RTM_NEWADDR doesn't allow to modify the IFA_F_DEPRECATED flag:
> >
> > /* We ignore other flags so far. */
> > 	ifa_flags &= IFA_F_NODAD | IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR |
> > 		     IFA_F_NOPREFIXROUTE;
> >
> > Having said that your suggestion seems to be the most appropriate way to tackle the issue:
> >
> > "So I would be ok, if we enhance the error case a bit, maybe reparent the
> > old temporary address, drop them and silently generate them anew or only
> > update prefix information from the new received prefix information. This
> > should happen without disturbing TCP connections etc. I think this
> > already works, but I don't know if it is worth the effort."
> >
> > The following patch works fine for me, I'd appreciate if you could have a look at it.
> >
> > Rgds, Heiner
> >
> > diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> > index 344e972..7cc3dae 100644
> > --- a/net/ipv6/addrconf.c
> > +++ b/net/ipv6/addrconf.c
> > @@ -2063,8 +2063,23 @@ static void manage_tempaddrs(struct inet6_dev *idev,
> >      list_for_each_entry(ift, &idev->tempaddr_list, tmp_list) {
> >          int age, max_valid, max_prefered;
> >  
> > -        if (ifp != ift->ifpub)
> > -            continue;
> > +        spin_lock(&ift->lock);
> > +        if (ifp != ift->ifpub) {
> > +            /* reparent if orphaned temporary addresses with same prefix is found */
> > +            if(ift->prefix_len == ifp->prefix_len && ipv6_prefix_equal(&ift->addr,&ifp->addr,ift->prefix_len)) {
> > +                in6_ifa_hold(ifp);
> > +                in6_ifa_put(ift->ifpub);
> > +                ift->ifpub = ifp;
> > +                spin_unlock(&ift->lock);
> > +                create = false;
> > +                pr_info("%s: reparent orphaned temporary address\n", __func__);
> > +            } else {
> > +                spin_unlock(&ift->lock);
> > +                continue;
> > +            }
> > +        } else {
> > +            spin_unlock(&ift->lock);
> > +        }
> >  
> >          /* RFC 4941 section 3.3:
> >           * If a received option will extend the lifetime of a public
> >
> After further checking it seems like the timer of the reparented temporary address was deleted. When the reparented address expires no new address is generated.
> Have to dig deeper into it ..

You need to reset ift->regen_count=0 to avoid that I guess.

The approach seems reasonable to me.

Thanks,

  Hannes
