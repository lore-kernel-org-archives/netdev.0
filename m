From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH net] IPv6: Fix broken IPv6 routing table after loopback down-up
Date: Thu, 23 Jan 2014 02:01:23 +0100
Message-ID: <20140123010123.GF7269@order.stressinduktion.org>
References: <1390404908-3914-1-git-send-email-sd@queasysnail.net> <20140122213446.GD7269@order.stressinduktion.org> <52E068C5.2050405@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59293 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbaAWBBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 20:01:24 -0500
Content-Disposition: inline
In-Reply-To: <52E068C5.2050405@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 23, 2014 at 08:56:37AM +0800, Gao feng wrote:
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 1a341f7..4dca886 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2610,8 +2610,16 @@ static void init_loopback(struct net_device *dev)
>                         if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
>                                 continue;
> 
> -                       if (sp_ifa->rt)
> -                               continue;
> +                       if (sp_ifa->rt) {
> +                               /* This dst has been added to garbage list when
> +                                * lo device down, delete this obsolete dst and
> +                                * reallocate new router for ifa. */
> +                               if (sp_ifa->rt->dst.obsolete > 0) {
> +                                       ip6_del_rt(sp_ifa->rt);
> +                                       sp_ifa->rt = NULL;
> +                               } else
> +                                       continue;
> +                       }
> 
>                         sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, false);

I agree, this seems a lot simpler. In the end I would like to replace this
conditional loopback up/down thing with something like below. I haven't done
the correct hookups into the relevant places, but I hope you get the idea:

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 017badb..1648a59a 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -114,7 +114,8 @@ struct rt6_rtnl_dump_arg {
 };
 
 int rt6_dump_route(struct rt6_info *rt, void *p_arg);
-void rt6_ifdown(struct net *net, struct net_device *dev);
+void rt6_ifdown(struct net *net, struct net_device *dev, bool unregister);
+void rt6_ifup(struct net_device *dev);
 void rt6_mtu_change(struct net_device *dev, unsigned int mtu);
 void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
 
diff --git a/include/uapi/linux/ipv6_route.h b/include/uapi/linux/ipv6_route.h
index 2be7bd1..5dd40ed 100644
--- a/include/uapi/linux/ipv6_route.h
+++ b/include/uapi/linux/ipv6_route.h
@@ -15,6 +15,7 @@
 
 #include <linux/types.h>
 
+#define RTF_DEAD	0x00008000	/* route dead bcs interface down */
 #define RTF_DEFAULT	0x00010000	/* default - learned via ND	*/
 #define RTF_ALLONLINK	0x00020000	/* (deprecated and will be removed)
 					   fallback, no routers on link */
diff --git a/include/uapi/linux/route.h b/include/uapi/linux/route.h
index 6600708..9099a5f 100644
--- a/include/uapi/linux/route.h
+++ b/include/uapi/linux/route.h
@@ -60,7 +60,7 @@ struct rtentry {
 #define RTF_REJECT	0x0200		/* Reject route			*/
 
 /*
- *	<linux/ipv6_route.h> uses RTF values >= 64k
+ *	<linux/ipv6_route.h> uses RTF values >= 32k
  */
 
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6913a82..e2df0f9 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -143,7 +143,7 @@ static void addrconf_leave_anycast(struct inet6_ifaddr *ifp);
 
 static void addrconf_type_change(struct net_device *dev,
 				 unsigned long event);
-static int addrconf_ifdown(struct net_device *dev, int how);
+static int addrconf_ifdown(struct net_device *dev, bool unregister);
 
 static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 						  int plen,
@@ -2882,7 +2882,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			 * IPV6_MIN_MTU stop IPv6 on this interface.
 			 */
 			if (dev->mtu < IPV6_MIN_MTU)
-				addrconf_ifdown(dev, 1);
+				addrconf_ifdown(dev, true);
 		}
 		break;
 
@@ -2952,7 +2952,7 @@ static void addrconf_type_change(struct net_device *dev, unsigned long event)
 		ipv6_mc_unmap(idev);
 }
 
-static int addrconf_ifdown(struct net_device *dev, int how)
+static int addrconf_ifdown(struct net_device *dev, bool unregister)
 {
 	struct net *net = dev_net(dev);
 	struct inet6_dev *idev;
@@ -2961,7 +2961,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 	ASSERT_RTNL();
 
-	rt6_ifdown(net, dev);
+	rt6_ifdown(net, dev, unregister);
 	neigh_ifdown(&nd_tbl, dev);
 
 	idev = __in6_dev_get(dev);
@@ -2972,7 +2972,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	 * Step 1: remove reference to ipv6 device from parent device.
 	 *	   Do not dev_put!
 	 */
-	if (how) {
+	if (unregister) {
 		idev->dead = 1;
 
 		/* protected by rtnl_lock */
@@ -3004,10 +3004,10 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	addrconf_del_rs_timer(idev);
 
 	/* Step 2: clear flags for stateless addrconf */
-	if (!how)
+	if (!unregister)
 		idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD|IF_READY);
 
-	if (how && del_timer(&idev->regen_timer))
+	if (unregister && del_timer(&idev->regen_timer))
 		in6_dev_put(idev);
 
 	/* Step 3: clear tempaddr list */
@@ -3053,7 +3053,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	write_unlock_bh(&idev->lock);
 
 	/* Step 5: Discard multicast list */
-	if (how)
+	if (unregister)
 		ipv6_mc_destroy_dev(idev);
 	else
 		ipv6_mc_down(idev);
@@ -3061,7 +3061,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	idev->tstamp = jiffies;
 
 	/* Last: Shot the device (if unregistered) */
-	if (how) {
+	if (unregister) {
 		addrconf_sysctl_unregister(idev);
 		neigh_parms_release(&nd_tbl, idev->nd_parms);
 		neigh_ifdown(&nd_tbl, dev);
@@ -5309,9 +5309,9 @@ void addrconf_cleanup(void)
 	for_each_netdev(&init_net, dev) {
 		if (__in6_dev_get(dev) == NULL)
 			continue;
-		addrconf_ifdown(dev, 1);
+		addrconf_ifdown(dev, true);
 	}
-	addrconf_ifdown(init_net.loopback_dev, 2);
+	addrconf_ifdown(init_net.loopback_dev, true);
 
 	/*
 	 *	Check hash table.
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 075602f..1132cfb 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1,3 +1,4 @@
+
 /*
  *	Linux INET6 implementation
  *	Forwarding Information Database
@@ -1711,7 +1712,7 @@ out_timer:
 
 static void fib6_net_exit(struct net *net)
 {
-	rt6_ifdown(net, NULL);
+	rt6_ifdown(net, NULL, true);
 	del_timer_sync(&net->ipv6.ip6_fib_timer);
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 11dac21..fb69e8b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2259,32 +2259,70 @@ void rt6_remove_prefsrc(struct inet6_ifaddr *ifp)
 	fib6_clean_all(net, fib6_remove_prefsrc, &adni);
 }
 
+enum arg_dev_net_action {
+	ARG_DEV_NET_REMOVE = 0,
+	ARG_DEV_NET_DISABLE,
+	ARG_DEV_NET_ENABLE,
+};
+
 struct arg_dev_net {
 	struct net_device *dev;
 	struct net *net;
+	enum arg_dev_net_action action;
 };
 
-static int fib6_ifdown(struct rt6_info *rt, void *arg)
+static int __fib6_match_or_update_if(struct rt6_info *rt, void *arg)
 {
 	const struct arg_dev_net *adn = arg;
 	const struct net_device *dev = adn->dev;
 
 	if ((rt->dst.dev == dev || !dev) &&
-	    rt != adn->net->ipv6.ip6_null_entry)
-		return -1;
+	    rt != adn->net->ipv6.ip6_null_entry) {
+		switch (adn->action) {
+		case ARG_DEV_NET_REMOVE:
+			/* remove rt */
+			return -1;
+		case ARG_DEV_NET_DISABLE:
+			WARN_ON(rt->rt6i_flags & RTF_DEAD);
+			rt->rt6i_flags |= RTF_DEAD;
+			return 0;
+		case ARG_DEV_NET_ENABLE:
+			WARN_ON(!(rt->rt6i_flags & RTF_DEAD));
+			rt->rt6i_flags &= ~RTF_DEAD;
+			return 0;
+		}
+	}
 
 	return 0;
 }
 
-void rt6_ifdown(struct net *net, struct net_device *dev)
+
+static void __rt6_fib_action(struct net *net, struct net_device *dev,
+			     enum arg_dev_net_action action)
 {
 	struct arg_dev_net adn = {
 		.dev = dev,
 		.net = net,
+		.action = action,
 	};
 
-	fib6_clean_all(net, fib6_ifdown, &adn);
-	icmp6_clean_all(fib6_ifdown, &adn);
+	fib6_clean_all(net, __fib6_match_or_update_if, &adn);
+	if (action == ARG_DEV_NET_REMOVE ||
+	    action == ARG_DEV_NET_DISABLE) {
+		adn.action = ARG_DEV_NET_REMOVE;
+		icmp6_clean_all(__fib6_match_or_update_if, &adn);
+	}
+}
+
+void rt6_ifdown(struct net *net, struct net_device *dev, bool unregister)
+{
+	__rt6_fib_action(net, dev, unregister ? ARG_DEV_NET_REMOVE :
+				       ARG_DEV_NET_DISABLE);
+}
+
+void rt6_ifup(struct net_device *dev)
+{
+	__rt6_fib_action(dev_net(dev), dev, ARG_DEV_NET_ENABLE);
 }
 
 struct rt6_mtu_change_arg {
