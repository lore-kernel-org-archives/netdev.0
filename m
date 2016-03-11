From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Sat, 12 Mar 2016 00:59:12 +0300
Message-ID: <20160311215912.GI1989@uranus.lan>
References: <20160310215959.GE1989@uranus.lan>
 <20160310.173630.525547775491939864.davem@davemloft.net>
 <20160310224056.GF1989@uranus.lan>
 <20160311.154046.890043899835986091.davem@davemloft.net>
 <20160311212247.GH1989@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160311212247.GH1989@uranus.lan>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 12, 2016 at 12:22:47AM +0300, Cyrill Gorcunov wrote:
> On Fri, Mar 11, 2016 at 03:40:46PM -0500, David Miller wrote:
> > > Thanks a lot, David!
> > 
> > Cyrill please retest this final patch and let me know if it still works
> > properly.
> > 
> > I looked at ipv6, and it's more complicated.  The problem is that ipv6
> > doesn't mark the inet6dev object as dead in the NETDEV_DOWN case, in
> > fact it keeps the object around.  It only releases it and marks it
> > dead in the NETDEV_UNREGISTER case.
> > 
> > We pay a very large price for having allowed the behavior of ipv6 and
> > ipv4 to diverge so greatly in these areas :-(
> > 
> > Nevertheless we should try to fix it somehow, maybe we can detect the
> > situation in another way for the ipv6 side.
> 
> David, thanks a huge! But you forgot to merge your patch #2
> (once I add it manually on top, it works quite well :)

Here is a cumulative one, which works just brilliant! Thanks a lot, David!
(I cahcnged reported-by tag, since it's Solar Designer who tell us
 about the issue, I forgot to mentioned it in first report, very
 sorry).
---
From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Don't do expensive useless work during inetdev destroy.

When an inetdev is destroyed, every address assigned to the interface
is removed.  And in this scenerio we do two pointless things which can
be very expensive if the number of assigned interfaces is large:

1) Address promotion.  We are deleting all addresses, so there is no
   point in doing this.

2) A full nf conntrack table purge for every address.  We only need to
   do this once, as is already caught by the existing
   masq_dev_notifier so masq_inet_event() can skip this.

Reported-by: Solar Designer <solar@openwall.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Tested-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 net/ipv4/devinet.c                          |    4 ++++
 net/ipv4/fib_frontend.c                     |    4 ++++
 net/ipv4/netfilter/nf_nat_masquerade_ipv4.c |   12 ++++++++++--
 3 files changed, 18 insertions(+), 2 deletions(-)

Index: linux-ml.git/net/ipv4/devinet.c
===================================================================
--- linux-ml.git.orig/net/ipv4/devinet.c
+++ linux-ml.git/net/ipv4/devinet.c
@@ -334,6 +334,9 @@ static void __inet_del_ifa(struct in_dev
 
 	ASSERT_RTNL();
 
+	if (in_dev->dead)
+		goto no_promotions;
+
 	/* 1. Deleting primary ifaddr forces deletion all secondaries
 	 * unless alias promotion is set
 	 **/
@@ -380,6 +383,7 @@ static void __inet_del_ifa(struct in_dev
 			fib_del_ifaddr(ifa, ifa1);
 	}
 
+no_promotions:
 	/* 2. Unlink it */
 
 	*ifap = ifa1->ifa_next;
Index: linux-ml.git/net/ipv4/fib_frontend.c
===================================================================
--- linux-ml.git.orig/net/ipv4/fib_frontend.c
+++ linux-ml.git/net/ipv4/fib_frontend.c
@@ -922,6 +922,9 @@ void fib_del_ifaddr(struct in_ifaddr *if
 		subnet = 1;
 	}
 
+	if (in_dev->dead)
+		goto no_promotions;
+
 	/* Deletion is more complicated than add.
 	 * We should take care of not to delete too much :-)
 	 *
@@ -997,6 +1000,7 @@ void fib_del_ifaddr(struct in_ifaddr *if
 		}
 	}
 
+no_promotions:
 	if (!(ok & BRD_OK))
 		fib_magic(RTM_DELROUTE, RTN_BROADCAST, ifa->ifa_broadcast, 32, prim);
 	if (subnet && ifa->ifa_prefixlen < 31) {
Index: linux-ml.git/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
===================================================================
--- linux-ml.git.orig/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
+++ linux-ml.git/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
@@ -108,10 +108,18 @@ static int masq_inet_event(struct notifi
 			   unsigned long event,
 			   void *ptr)
 {
-	struct net_device *dev = ((struct in_ifaddr *)ptr)->ifa_dev->dev;
+	struct in_device *idev = ((struct in_ifaddr *)ptr)->ifa_dev;
 	struct netdev_notifier_info info;
 
-	netdev_notifier_info_init(&info, dev);
+	/* The masq_dev_notifier will catch the case of the device going
+	 * down.  So if the inetdev is dead and being destroyed we have
+	 * no work to do.  Otherwise this is an individual address removal
+	 * and we have to perform the flush.
+	 */
+	if (idev->dead)
+		return NOTIFY_DONE;
+
+	netdev_notifier_info_init(&info, idev->dev);
 	return masq_device_event(this, event, &info);
 }
 
