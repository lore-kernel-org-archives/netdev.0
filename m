From: David Miller <davem@davemloft.net>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Thu, 04 Jan 2007 12:33:33 -0800 (PST)
Message-ID: <20070104.123333.91315611.davem@davemloft.net>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com>
	<E1H2M3X-0001HE-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, greearb@candelatech.com, jarkao2@o2.pl,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39020
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030190AbXADUde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 15:33:34 -0500
To: herbert@gondor.apana.org.au
In-Reply-To: <E1H2M3X-0001HE-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 04 Jan 2007 17:26:27 +1100

> David Stevens <dlstevens@us.ibm.com> wrote:
> >        You're right, I don't know whether it'll fix the problem Ben saw
> > or not, but it looks like the original code can do a receive before the
> > in_device is fully initialized, and that, of course, is bad.
> >        If the device for ip_rcv() is not the same one we were
> > initializing when the receive interrupted, then the patch should have
> > no effect either way -- I don't think it'll hide other problems.
> >        If it's hard to reproduce (which I guess is true), then you're
> > right, no soft lockup doesn't really tell us if it's fixed or not.
> 
> Actually I missed your point that the multicast locks aren't even
> initialised at that point.  So this does explain the soft lock-up
> and therefore your patch is clearly the correct solution.

I agree too, therefore I've added David's patch as below.

I'll push this to the -stable branches as well.  This fix is
correct even if it does not entirely clear up the soft lockup
bug being discussed in this thread, but I think it will :-)

commit 30c4cf577fb5b68c16e5750d6bdbd7072e42b279
Author: David L Stevens <dlstevens@us.ibm.com>
Date:   Thu Jan 4 12:31:14 2007 -0800

    [IPV4/IPV6]: Fix inet{,6} device initialization order.
    
    It is important that we only assign dev->ip{,6}_ptr
    only after all portions of the inet{,6} are setup.
    
    Otherwise we can receive packets before the multicast
    spinlocks et al. are initialized.
    
    Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 84bed40..25c8a42 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -165,9 +165,8 @@ struct in_device *inetdev_init(struct net_device *dev)
 			      NET_IPV4_NEIGH, "ipv4", NULL, NULL);
 #endif
 
-	/* Account for reference dev->ip_ptr */
+	/* Account for reference dev->ip_ptr (below) */
 	in_dev_hold(in_dev);
-	rcu_assign_pointer(dev->ip_ptr, in_dev);
 
 #ifdef CONFIG_SYSCTL
 	devinet_sysctl_register(in_dev, &in_dev->cnf);
@@ -176,6 +175,8 @@ struct in_device *inetdev_init(struct net_device *dev)
 	if (dev->flags & IFF_UP)
 		ip_mc_up(in_dev);
 out:
+	/* we can receive as soon as ip_ptr is set -- do this last */
+	rcu_assign_pointer(dev->ip_ptr, in_dev);
 	return in_dev;
 out_kfree:
 	kfree(in_dev);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9b0a906..171e5b5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -413,8 +413,6 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	if (netif_carrier_ok(dev))
 		ndev->if_flags |= IF_READY;
 
-	/* protected by rtnl_lock */
-	rcu_assign_pointer(dev->ip6_ptr, ndev);
 
 	ipv6_mc_init_dev(ndev);
 	ndev->tstamp = jiffies;
@@ -425,6 +423,8 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 			      NULL);
 	addrconf_sysctl_register(ndev, &ndev->cnf);
 #endif
+	/* protected by rtnl_lock */
+	rcu_assign_pointer(dev->ip6_ptr, ndev);
 	return ndev;
 }
 
