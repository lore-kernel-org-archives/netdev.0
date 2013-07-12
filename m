From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Fri, 12 Jul 2013 21:20:23 +0200
Message-ID: <20130712192023.GP12611@order.stressinduktion.org>
References: <51DD6B72.1050700@6wind.com> <20130710212149.GA26122@order.stressinduktion.org> <51DE671F.5050706@6wind.com> <20130711102441.GC5207@order.stressinduktion.org> <20130711144623.GA5707@order.stressinduktion.org> <51DEC7E6.8000500@6wind.com> <20130712085113.GI12611@order.stressinduktion.org> <51DFF0DD.5050601@6wind.com> <20130712161935.GB31912@order.stressinduktion.org> <51E0527D.2030205@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:42181 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757320Ab3GLTUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 15:20:25 -0400
Content-Disposition: inline
In-Reply-To: <51E0527D.2030205@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 12, 2013 at 09:01:17PM +0200, Nicolas Dichtel wrote:
> Le 12/07/2013 18:19, Hannes Frederic Sowa a =C3=A9crit :
> >On Fri, Jul 12, 2013 at 02:04:45PM +0200, Nicolas Dichtel wrote:
> >>It's possible to add a glue to check this counter when we play with=
 these
> >>flags, but it's ugly.
> >>
> >>Maybe the check against RTF_EXPIRES is fundamentally wrong. Checkin=
g
> >>RTF_ADDRCONF|RTF_DYNAMIC should be enough, what do you think?
> >
> >Yes, this seems to be the best option now. I will audit the source i=
f
> >RTF_ADDRCONF and RTF_DYNAMIC are immutable after dst construction an=
d
> >if other errors could arise for that and would go with this solution=
 then.
> >
> >What do you think about making ecmp routes explicit by adding RTF_EC=
MP
> >flag?
> Why not, but you will have to be careful on insertion and deletion. N=
ext=20
> hop can be added one by one and deleted one by one.

Ok, we can have a look to do so in -next.

> >
> >>In another hand, we can discuss about the initial assumption, that =
was
> >>"only static routes are part of ECMP routes". I'm thinking of what =
are the
> >>consequence if we accept to accept all routes, without checking any=
 flags.
> >
> >I don't have a good feeling about that. But I may be wrong.
> Same for me, but for now, I don't have any argument ;-) The above sol=
ution=20
> is probably the better way for now.

To go without RTF_EXPIRES seems the way to go. I still am unsure if we =
need to
propagate the RTF_DYNAMIC flag in case we update the expiration date on=
 a
route.

--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -682,6 +682,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, s=
truct rt6_info *rt,
                                        rt->rt6i_nsiblings =3D 0;
                                if (!(iter->rt6i_flags & RTF_EXPIRES))
                                        return -EEXIST;
+                               iter->rt6i_flags |=3D rt->rt6i_flags & =
RTF_DYNAMIC;
                                if (!(rt->rt6i_flags & RTF_EXPIRES))
                                        rt6_clean_expires(iter);
                                else

I hope to have identified all possible site-effects later today.

Thanks,

  Hannes
