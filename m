From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/3 v3] net: track link-status of ipv4 nexthops
Date: Wed, 10 Jun 2015 23:28:28 -0400
Message-ID: <20150611032827.GX588@gospo.home.greyhouse.net>
References: <1433990233-958-1-git-send-email-gospo@cumulusnetworks.com>
 <1433990233-958-2-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bC=bKhMDVc9JT7YeFFDAi8Hn8GySd_b5Oa2uQ=bnbi8_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:33093 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbbFKD2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 23:28:32 -0400
Received: by qcnj1 with SMTP id j1so23280464qcn.0
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 20:28:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bC=bKhMDVc9JT7YeFFDAi8Hn8GySd_b5Oa2uQ=bnbi8_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 07:53:59PM -0700, Scott Feldman wrote:
> On Wed, Jun 10, 2015 at 7:37 PM, Andy Gospodarek
> <gospo@cumulusnetworks.com> wrote:
> 
> > @@ -1129,7 +1142,15 @@ int fib_sync_down_dev(struct net_device *dev, int force)
> >                                 dead++;
> >                         else if (nexthop_nh->nh_dev == dev &&
> >                                  nexthop_nh->nh_scope != scope) {
> > -                               nexthop_nh->nh_flags |= RTNH_F_DEAD;
> > +                               switch (event) {
> > +                               case NETDEV_DOWN:
> > +                               case NETDEV_UNREGISTER:
> > +                                       nexthop_nh->nh_flags |= RTNH_F_DEAD;
> > +                                       /* fall through */
> > +                               case NETDEV_CHANGE:
> > +                                       nexthop_nh->nh_flags |= RTNH_F_LINKDOWN;
> > +                                       break;
> > +                               }
> >  #ifdef CONFIG_IP_ROUTE_MULTIPATH
> >                                 spin_lock_bh(&fib_multipath_lock);
> >                                 fi->fib_power -= nexthop_nh->nh_power;
> > @@ -1139,14 +1160,22 @@ int fib_sync_down_dev(struct net_device *dev, int force)
> >                                 dead++;
> >                         }
> >  #ifdef CONFIG_IP_ROUTE_MULTIPATH
> > -                       if (force > 1 && nexthop_nh->nh_dev == dev) {
> > +                       if (event == NETDEV_UNREGISTER && nexthop_nh->nh_dev == dev) {
> >                                 dead = fi->fib_nhs;
> >                                 break;
> >                         }
> >  #endif
> >                 } endfor_nexthops(fi)
> >                 if (dead == fi->fib_nhs) {
> > -                       fi->fib_flags |= RTNH_F_DEAD;
> > +                       switch (event) {
> > +                       case NETDEV_DOWN:
> > +                       case NETDEV_UNREGISTER:
> > +                               fi->fib_flags |= RTNH_F_DEAD;
> > +                               /* fall through */
> > +                       case NETDEV_CHANGE:
> > +                               fi->fib_flags |= RTNH_F_LINKDOWN;
> 
> RTNH_F_LINKDOWN is to mark linkdown nexthop devs....why is the route
> fi being marked RTNH_F_LINKDOWN?
> 
> The RTNH_F_LINKDOWN comment says:
> 
> #define RTNH_F_LINKDOWN                16      /* carrier-down on nexthop */

This is done with the dead flag already.  I'm actually following the
precedent already set there.

> It's a per-nh flag, not per-route flag, correct?
> 
> Can you show an ECMP example with only a subset of the nexthops dev
> linkdowned?  Show the ip route output after going thru some link
> down/up events on some of the nexthops devs.

Sure!  This is exactly what I've been using for testing.

# ip route show
70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1
80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1
90.0.0.0/24 via 70.0.0.2 dev p7p1
90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 10
100.0.0.0/24
	nexthop via 70.0.0.2  dev p7p1 weight 1
	nexthop via 80.0.0.2  dev p8p1 weight 1
192.168.56.0/24 dev p2p1  proto kernel  scope link  src 192.168.56.2 
# # take p8p1 link down
# ip route show 
70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1 
80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 dead linkdown 
90.0.0.0/24 via 70.0.0.2 dev p7p1 
90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 10 dead linkdown 
100.0.0.0/24 
	nexthop via 70.0.0.2  dev p7p1 weight 1
	nexthop via 80.0.0.2  dev p8p1 weight 1 dead linkdown
192.168.56.0/24 dev p2p1  proto kernel  scope link  src 192.168.56.2 
# ip route get 100.0.0.2 
100.0.0.2 via 70.0.0.2 dev p7p1  src 70.0.0.1 
    cache 
# ip route get 100.0.0.2 
100.0.0.2 via 70.0.0.2 dev p7p1  src 70.0.0.1 
    cache 
# # take p8p1 link up
# ip route show
70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1 
80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1
90.0.0.0/24 via 70.0.0.2 dev p7p1 
90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 10 
100.0.0.0/24 
	nexthop via 70.0.0.2  dev p7p1 weight 1
	nexthop via 80.0.0.2  dev p8p1 weight 1
192.168.56.0/24 dev p2p1  proto kernel  scope link  src 192.168.56.2 
# ip route show 
100.0.0.2 via 70.0.0.2 dev p7p1  src 70.0.0.1 
    cache 
# ip route get 100.0.0.2 
100.0.0.2 via 80.0.0.2 dev p8p1  src 80.0.0.1 
    cache 
# ip route get 100.0.0.2 
100.0.0.2 via 70.0.0.2 dev p7p1  src 70.0.0.1 
    cache 
# ip route get 100.0.0.2 
100.0.0.2 via 80.0.0.2 dev p8p1  src 80.0.0.1 
    cache 
# # you can see the round robin happening
# # take all ports p8p1 and p7p1 down
# ip route show
70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1 dead linkdown 
80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 dead linkdown
90.0.0.0/24 via 70.0.0.2 dev p7p1 dead linkdown
90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 10 dead linkdown
100.0.0.0/24
	nexthop via 70.0.0.2  dev p7p1 weight 1 dead linkdown
	nexthop via 80.0.0.2  dev p8p1 weight 1 dead linkdown
192.168.56.0/24 dev p2p1  proto kernel  scope link  src 192.168.56.2 
# ip route get 100.0.0.2 
RTNETLINK answers: Network is unreachable
# ip route get 80.0.0.2 
RTNETLINK answers: Network is unreachable
# ip route get 80.0.0.1
local 80.0.0.1 dev lo  src 80.0.0.1 
    cache <local> 
# ip route get 70.0.0.1
local 70.0.0.1 dev lo  src 70.0.0.1 
    cache <local> 
# # local addrs are still reachable 
