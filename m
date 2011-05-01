From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] ipv6: fix incorrect unregistration of sysctl when last ip deleted
Date: Sun, 01 May 2011 02:59:07 -0700
Message-ID: <m1liyqbv2s.fsf@fess.ebiederm.org>
References: <201104272312.p3RNCcl6002068@jgmyers-vm1.eng.proofpoint.com>
	<20110429.134524.116375005.davem@davemloft.net>
	<4DBB3480.9020708@proofpoint.com>
	<20110430000710.GA26995@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Gardiner Myers <jgmyers@proofpoint.com>,
	David Miller <davem@davemloft.net>, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110430000710.GA26995@ms2.inr.ac.ru> (Alexey Kuznetsov's
	message of "Sat, 30 Apr 2011 04:07:10 +0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> writes:

> On Fri, Apr 29, 2011 at 02:58:24PM -0700, John Gardiner Myers wrote:
>> If the device isn't going away, then the ip6_ptr shouldn't be zeroed, 
>> the /proc/net/dev_snmp6 entry shouldn't be deregistered,
>
> Actually, you are right. Tuned interface parameters and disabling/enabling IPv6
> (or IP, or whatever) should be different things. We just did not have an interface
> to disable protocol, but leave in*_dev, so that they were merged.
>
> When doing this just keep in mind that addrconf_ifdown(how = 0) did _not_ mean
> disabling IPv6. (Probably, it does now in fact, I do not know. But it definitely
> did not mean this in the past).
>
> Look, addrconf_ifdown(how = 0) was executed only when the physical device is down, so that we could
> neither receive nor send over this interface. If the device is UP, addrconf_ifdown(how = 0)
> did not prohibit sending/receiving IPv6. Actually, logically, addrconf_ifdown(how = 0)
> on UP interface must be followed by immediate restart of autoconfiguration,
> because interface is still actually UP. See?
>
> So, to implement this you should verify that IPv6 packets are not sent/received over
> disabled interface (at least over interface with illegal mtu :-)). And add some flag in in6_dev
> meaning that IPv6 is actually disabled. So that f.e. after occasional
> ifconfig eth0 down; ifconfig eth0 up autoconfiguration would not resume IPv6
> (the thing which we could not even implement with destroying in6_dev,
> but definitely wanted).

I played with this a while ago with on 2.6.37 and I cooked up the patch
below.  I don't know if it still applies, but I think something like
this is what we want, as it makes the no ipv6 address case and the
ipv6 mtu too small case match the disable_ipv6 case.

Eric


>From e97b017fe210db4e0a1d5553449da140a0794bb0 Mon Sep 17 00:00:00 2001
From: Eric W. Biederman <ebiederm@xmission.com>
Date: Wed, 8 Dec 2010 11:59:36 -0800
Subject: [PATCH] addrconf:  Force logical down for bad MTU or no ipv6 addresses as well.

Don't loose our ipv6 state (like disable_ipv6) when we delete the last
address from an ipv6 interface or when we set an mtu on the interface
that is smaller than we support.

As well as making things more comprehensible to userspace this
makes the code simpler.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv6/addrconf.c |   79 ++++++++++++++++++++------------------------------
 1 files changed, 32 insertions(+), 47 deletions(-)

Index: linux-2.6.37-rc5.x86_64/net/ipv6/addrconf.c
===================================================================
--- linux-2.6.37-rc5.x86_64.orig/net/ipv6/addrconf.c
+++ linux-2.6.37-rc5.x86_64/net/ipv6/addrconf.c
@@ -147,6 +147,7 @@ static void addrconf_leave_anycast(struc
 static void addrconf_type_change(struct net_device *dev,
 				 unsigned long event);
 static int addrconf_ifdown(struct net_device *dev, int how);
+static void dev_disable_change(struct inet6_dev *idev);
 
 static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags);
 static void addrconf_dad_timer(unsigned long data);
@@ -2221,7 +2222,7 @@ static int inet6_addr_del(struct net *ne
 			   disable IPv6 on this interface.
 			 */
 			if (list_empty(&idev->addr_list))
-				addrconf_ifdown(idev->dev, 1);
+				dev_disable_change(idev);
 			return 0;
 		}
 	}
@@ -2499,7 +2500,7 @@ static int addrconf_notify(struct notifi
 
 	switch (event) {
 	case NETDEV_REGISTER:
-		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
+		if (!idev) {
 			idev = ipv6_add_dev(dev);
 			if (!idev)
 				return notifier_from_errno(-ENOMEM);
@@ -2520,26 +2521,18 @@ static int addrconf_notify(struct notifi
 					dev->name);
 				break;
 			}
-
-			if (!idev && dev->mtu >= IPV6_MIN_MTU)
-				idev = ipv6_add_dev(dev);
-
-			if (idev) {
-				idev->if_flags |= IF_READY;
-				run_pending = 1;
-			}
+			idev->if_flags |= IF_READY;
+			run_pending = 1;
 		} else {
 			if (!addrconf_qdisc_ok(dev)) {
 				/* device is still not ready. */
 				break;
 			}
 
-			if (idev) {
-				if (idev->if_flags & IF_READY)
-					/* device is already configured. */
-					break;
-				idev->if_flags |= IF_READY;
-			}
+			if (idev->if_flags & IF_READY)
+				/* device is already configured. */
+				break;
+			idev->if_flags |= IF_READY;
 
 			printk(KERN_INFO
 					"ADDRCONF(NETDEV_CHANGE): %s: "
@@ -2567,45 +2560,37 @@ static int addrconf_notify(struct notifi
 			break;
 		}
 
-		if (idev) {
-			if (run_pending)
-				addrconf_dad_run(idev);
-
-			/*
-			 * If the MTU changed during the interface down,
-			 * when the interface up, the changed MTU must be
-			 * reflected in the idev as well as routers.
-			 */
-			if (idev->cnf.mtu6 != dev->mtu &&
-			    dev->mtu >= IPV6_MIN_MTU) {
-				rt6_mtu_change(dev, dev->mtu);
-				idev->cnf.mtu6 = dev->mtu;
-			}
-			idev->tstamp = jiffies;
-			inet6_ifinfo_notify(RTM_NEWLINK, idev);
+		if (run_pending)
+			addrconf_dad_run(idev);
 
-			/*
-			 * If the changed mtu during down is lower than
-			 * IPV6_MIN_MTU stop IPv6 on this interface.
-			 */
-			if (dev->mtu < IPV6_MIN_MTU)
-				addrconf_ifdown(dev, 1);
+		/*
+		 * If the MTU changed during the interface down,
+		 * when the interface up, the changed MTU must be
+		 * reflected in the idev as well as routers.
+		 */
+		if (idev->cnf.mtu6 != dev->mtu &&
+		    dev->mtu >= IPV6_MIN_MTU) {
+			rt6_mtu_change(dev, dev->mtu);
+			idev->cnf.mtu6 = dev->mtu;
 		}
+		idev->tstamp = jiffies;
+		inet6_ifinfo_notify(RTM_NEWLINK, idev);
+
+		/*
+		 * If the changed mtu during down is lower than
+		 * IPV6_MIN_MTU stop IPv6 on this interface.
+		 */
+		if (dev->mtu < IPV6_MIN_MTU)
+			dev_disable_change(idev);
 		break;
 
 	case NETDEV_CHANGEMTU:
-		if (idev && dev->mtu >= IPV6_MIN_MTU) {
+		if (dev->mtu >= IPV6_MIN_MTU) {
 			rt6_mtu_change(dev, dev->mtu);
 			idev->cnf.mtu6 = dev->mtu;
 			break;
 		}
 
-		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
-			idev = ipv6_add_dev(dev);
-			if (idev)
-				break;
-		}
-
 		/*
 		 * MTU falled under IPV6_MIN_MTU.
 		 * Stop IPv6 on this interface.
@@ -2616,7 +2601,7 @@ static int addrconf_notify(struct notifi
 		/*
 		 *	Remove all addresses from this interface.
 		 */
-		addrconf_ifdown(dev, event != NETDEV_DOWN);
+		addrconf_ifdown(dev, event == NETDEV_UNREGISTER);
 		break;
 
 	case NETDEV_CHANGENAME:
@@ -4137,6 +4122,18 @@ static void ipv6_ifa_notify(int event, s
 	rcu_read_unlock_bh();
 }
 
+static void dev_disable_change(struct inet6_dev *idev)
+{
+	if (!idev || !idev->dev)
+		return;
+
+	if (idev->cnf.disable_ipv6 || (list_empty(&idev->addr_list)) ||
+	    (idev->dev->mtu < IPV6_MIN_MTU))
+		addrconf_notify(NULL, NETDEV_DOWN, idev->dev);
+	else
+		addrconf_notify(NULL, NETDEV_UP, idev->dev);
+}
+
 #ifdef CONFIG_SYSCTL
 
 static
@@ -4157,17 +4154,6 @@ int addrconf_sysctl_forward(ctl_table *c
 	return ret;
 }
 
-static void dev_disable_change(struct inet6_dev *idev)
-{
-	if (!idev || !idev->dev)
-		return;
-
-	if (idev->cnf.disable_ipv6)
-		addrconf_notify(NULL, NETDEV_DOWN, idev->dev);
-	else
-		addrconf_notify(NULL, NETDEV_UP, idev->dev);
-}
-
 static void addrconf_disable_change(struct net *net, __s32 newf)
 {
 	struct net_device *dev;
