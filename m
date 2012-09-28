From: David Miller <davem@davemloft.net>
Subject: Re: Possible networking regression in 3.6.0
Date: Fri, 28 Sep 2012 02:53:51 -0400 (EDT)
Message-ID: <20120928.025351.156118608293844465.davem@davemloft.net>
References: <50649567.2010704@googlemail.com>
	<1348779826.5093.1750.camel@edumazet-glaptop>
	<1348780624.5093.1767.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chris2553@googlemail.com, netdev@vger.kernel.org, gpiez@web.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34830 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442Ab2I1Gxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 02:53:54 -0400
In-Reply-To: <1348780624.5093.1767.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 Sep 2012 23:17:04 +0200

> Yes it seems the problem. On the host I tried :
> 
> # ip ro get 8.8.8.8 from 192.168.200.1 iif tap1
> 8.8.8.8 from 192.168.200.1 via 172.30.42.1 dev eth0 
>     cache  iif *
> 
> So if the guest tries to send a frame to 8.8.8.8 we are going to forward
> the packet to eth0
> 
> But if the guest tries to send to 255.255.255.255, we try to deliver the
> packet to the host itself, instead of broadcasting to eth0
> 
> # ip ro get 255.255.255.255 from 192.168.200.1 iif tap1
> broadcast 255.255.255.255 from 192.168.200.1 dev lo 
>     cache <local,brd>  iif *
> 
> David, maybe you'll have an idea ?

Perhaps this was introduced by:

commit 7bd86cc282a458b66c41e3f6676de6656c99b8db
Author: Yan, Zheng <zheng.z.yan@intel.com>
Date:   Sun Aug 12 20:09:59 2012 +0000

    ipv4: Cache local output routes
    
    Commit caacf05e5ad1abf causes big drop of UDP loop back performance.
    The cause of the regression is that we do not cache the local output
    routes. Each time we send a datagram from unconnected UDP socket,
    the kernel allocates a dst_entry and adds it to the rt_uncached_list.
    It creates lock contention on the rt_uncached_lock.
    
    Reported-by: Alex Shi <alex.shi@intel.com>
    Signed-off-by: Yan, Zheng <zheng.z.yan@intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e4ba974..fd9ecb5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2028,7 +2028,6 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		}
 		dev_out = net->loopback_dev;
 		fl4->flowi4_oif = dev_out->ifindex;
-		res.fi = NULL;
 		flags |= RTCF_LOCAL;
 		goto make_route;
 	}
