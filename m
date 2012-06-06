From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible deadlock in ipv6?
Date: Wed, 06 Jun 2012 17:58:34 +0200
Message-ID: <1338998314.26966.12.camel@edumazet-glaptop>
References: <4FCF6DF4.2090304@parallels.com>
	 <1338998019.26966.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vladimir Davydov <vdavydov@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33587 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756631Ab2FFP6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 11:58:40 -0400
Received: by eeit10 with SMTP id t10so2396963eei.19
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 08:58:39 -0700 (PDT)
In-Reply-To: <1338998019.26966.10.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 17:53 +0200, Eric Dumazet wrote:
> On Wed, 2012-06-06 at 18:49 +0400, Vladimir Davydov wrote:
> > I'm not familiar with the linux net subsystem, so I would appreciate if 
> > someone could clarify if the following call chain is possible:
> > 
> > addrconf_ifdown() calls neigh_ifdown(nd_tbl) which locks nd_tbl.lock for 
> > writing and calls
> > 
> >      pneigh_ifdown
> >      pndisc_destructor
> >      ipv6_dev_mc_dec
> >      __ipv6_dev_mc_dec
> >      igmp6_group_dropped
> >      igmp6_leave_group
> >      igmp6_send
> >      icmp6_dst_alloc
> >      ip6_neigh_lookup
> >      neigh_create
> > 
> > and neigh_create() locks nd_tbl.lock for writing again resulting in a 
> > deadlock.
> 
> It seems a deadlock is possible indeed, good catch !
> 
> 

And it seems this neigh_down() can be removed, its called later
(after dev->ip6_ptr is cleared)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8f6411c..62c4c00 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2750,7 +2750,6 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	ASSERT_RTNL();
 
 	rt6_ifdown(net, dev);
-	neigh_ifdown(&nd_tbl, dev);
 
 	idev = __in6_dev_get(dev);
 	if (idev == NULL)
