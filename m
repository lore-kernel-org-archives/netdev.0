From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Fri, 11 Mar 2016 15:40:46 -0500 (EST)
Message-ID: <20160311.154046.890043899835986091.davem@davemloft.net>
References: <20160310215959.GE1989@uranus.lan>
	<20160310.173630.525547775491939864.davem@davemloft.net>
	<20160310224056.GF1989@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: gorcunov@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160310224056.GF1989@uranus.lan>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Fri, 11 Mar 2016 01:40:56 +0300

> On Thu, Mar 10, 2016 at 05:36:30PM -0500, David Miller wrote:
>> > 
>> > Works like a charm! So David, what are the next steps then?
>> > Mind to gather all your patches into one (maybe)?
>> 
>> I'll re-review all of the changes tomorrow and also look into ipv6
>> masq, to see if it needs the same treatment, as well.
>> 
>> Thanks for all of your help and testing so far.
> 
> Thanks a lot, David!

Cyrill please retest this final patch and let me know if it still works
properly.

I looked at ipv6, and it's more complicated.  The problem is that ipv6
doesn't mark the inet6dev object as dead in the NETDEV_DOWN case, in
fact it keeps the object around.  It only releases it and marks it
dead in the NETDEV_UNREGISTER case.

We pay a very large price for having allowed the behavior of ipv6 and
ipv4 to diverge so greatly in these areas :-(

Nevertheless we should try to fix it somehow, maybe we can detect the
situation in another way for the ipv6 side.

====================
ipv4: Don't do expensive useless work during inetdev destroy.

When an inetdev is destroyed, every address assigned to the interface
is removed.  And in this scenerio we do two pointless things which can
be very expensive if the number of assigned interfaces is large:

1) Address promotion.  We are deleting all addresses, so there is no
   point in doing this.

2) A full nf conntrack table purge for every address.  We only need to
   do this once, as is already caught by the existing
   masq_dev_notifier so masq_inet_event() can skip this.

Reported-by: Cyrill Gorcunov <gorcunov@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index f6303b1..0212591 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -334,6 +334,9 @@ static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 
 	ASSERT_RTNL();
 
+	if (in_dev->dead)
+		goto no_promotions;
+
 	/* 1. Deleting primary ifaddr forces deletion all secondaries
 	 * unless alias promotion is set
 	 **/
@@ -380,6 +383,7 @@ static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 			fib_del_ifaddr(ifa, ifa1);
 	}
 
+no_promotions:
 	/* 2. Unlink it */
 
 	*ifap = ifa1->ifa_next;
diff --git a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
index c6eb421..ea91058 100644
--- a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
@@ -108,10 +108,18 @@ static int masq_inet_event(struct notifier_block *this,
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
 
