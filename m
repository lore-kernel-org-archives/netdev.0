From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Sat, 5 Mar 2016 00:39:20 +0300
Message-ID: <20160304213920.GJ4184@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Solar Designer <solar@openwall.com>,
	Vasily Averin <vvs@virtuozzo.com>,
	Andrey Vagin <avagin@virtuozzo.com>,
	Pavel Emelianov <xemul@virtuozzo.com>,
	Vladimir Davydov <vdavydov@virtuozzo.com>,
	Konstantin Khorenko <khorenko@virtuozzo.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:36131 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759678AbcCDVj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 16:39:28 -0500
Received: by mail-lb0-f175.google.com with SMTP id x1so75665235lbj.3
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 13:39:27 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currenlty all the kernels (including vanilla) free ifa
list under rtln_lock() taken which takes a huge time
to release all entries when we stop the container.
Moreover it's allowed to create unlimited number
of addresses from inside of net-namespace if
CAP-NET_ADMIN granted (which is common for containers).

Lets introduce per-net limit (4096 by default)
of addresses, which can be tuned up via sysfs
entry /proc/sys/net/ipv4/ifa_limit.

Reported-by: Solar Designer <solar@openwall.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@virtuozzo.com>
CC: Vasily Averin <vvs@virtuozzo.com>
CC: Andrey Vagin <avagin@virtuozzo.com>
CC: Pavel Emelianov <xemul@virtuozzo.com>
CC: Vladimir Davydov <vdavydov@virtuozzo.com>
CC: Konstantin Khorenko <khorenko@virtuozzo.com>
CC: David Miller <davem@davemloft.net>
CC: Eric Dumazet <eric.dumazet@gmail.com>
---

Please share the idea if there some more elegant way exist
to fix this problem, maybe I miss something obvious. Thanks!

 include/net/netns/ipv4.h   |    3 +++
 net/ipv4/devinet.c         |   34 +++++++++++++++++++---------------
 net/ipv4/sysctl_net_ipv4.c |    8 ++++++++
 3 files changed, 30 insertions(+), 15 deletions(-)

Index: linux-ml.git/include/net/netns/ipv4.h
===================================================================
--- linux-ml.git.orig/include/net/netns/ipv4.h
+++ linux-ml.git/include/net/netns/ipv4.h
@@ -77,6 +77,8 @@ struct netns_ipv4 {
 
 	struct local_ports ip_local_ports;
 
+	int sysctl_ifa_limit;
+
 	int sysctl_tcp_ecn;
 	int sysctl_tcp_ecn_fallback;
 
@@ -101,6 +103,7 @@ struct netns_ipv4 {
 	struct ping_group_range ping_group_range;
 
 	atomic_t dev_addr_genid;
+	atomic_t ifa_nr;
 
 #ifdef CONFIG_SYSCTL
 	unsigned long *sysctl_local_reserved_ports;
Index: linux-ml.git/net/ipv4/devinet.c
===================================================================
--- linux-ml.git.orig/net/ipv4/devinet.c
+++ linux-ml.git/net/ipv4/devinet.c
@@ -194,8 +194,11 @@ static void devinet_sysctl_unregister(st
 
 /* Locks all the inet devices. */
 
-static struct in_ifaddr *inet_alloc_ifa(void)
+static struct in_ifaddr *inet_alloc_ifa(struct net *net)
 {
+	if (atomic_add_return(1, &net->ipv4.ifa_nr) >
+	    net->ipv4.sysctl_ifa_limit)
+		return NULL;
 	return kzalloc(sizeof(struct in_ifaddr), GFP_KERNEL);
 }
 
@@ -207,8 +210,9 @@ static void inet_rcu_free_ifa(struct rcu
 	kfree(ifa);
 }
 
-static void inet_free_ifa(struct in_ifaddr *ifa)
+static void inet_free_ifa(struct net *net, struct in_ifaddr *ifa)
 {
+	atomic_dec(&net->ipv4.ifa_nr);
 	call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
 }
 
@@ -296,7 +300,7 @@ static void inetdev_destroy(struct in_de
 
 	while ((ifa = in_dev->ifa_list) != NULL) {
 		inet_del_ifa(in_dev, &in_dev->ifa_list, 0);
-		inet_free_ifa(ifa);
+		inet_free_ifa(dev_net(dev), ifa);
 	}
 
 	RCU_INIT_POINTER(dev->ip_ptr, NULL);
@@ -361,7 +365,7 @@ static void __inet_del_ifa(struct in_dev
 				rtmsg_ifa(RTM_DELADDR, ifa, nlh, portid);
 				blocking_notifier_call_chain(&inetaddr_chain,
 						NETDEV_DOWN, ifa);
-				inet_free_ifa(ifa);
+				inet_free_ifa(dev_net(in_dev->dev), ifa);
 			} else {
 				promote = ifa;
 				break;
@@ -420,7 +424,7 @@ static void __inet_del_ifa(struct in_dev
 
 	}
 	if (destroy)
-		inet_free_ifa(ifa1);
+		inet_free_ifa(dev_net(in_dev->dev), ifa1);
 }
 
 static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
@@ -442,7 +446,7 @@ static int __inet_insert_ifa(struct in_i
 	ASSERT_RTNL();
 
 	if (!ifa->ifa_local) {
-		inet_free_ifa(ifa);
+		inet_free_ifa(dev_net(in_dev->dev), ifa);
 		return 0;
 	}
 
@@ -457,11 +461,11 @@ static int __inet_insert_ifa(struct in_i
 		if (ifa1->ifa_mask == ifa->ifa_mask &&
 		    inet_ifa_match(ifa1->ifa_address, ifa)) {
 			if (ifa1->ifa_local == ifa->ifa_local) {
-				inet_free_ifa(ifa);
+				inet_free_ifa(dev_net(in_dev->dev), ifa);
 				return -EEXIST;
 			}
 			if (ifa1->ifa_scope != ifa->ifa_scope) {
-				inet_free_ifa(ifa);
+				inet_free_ifa(dev_net(in_dev->dev), ifa);
 				return -EINVAL;
 			}
 			ifa->ifa_flags |= IFA_F_SECONDARY;
@@ -502,7 +506,7 @@ static int inet_set_ifa(struct net_devic
 	ASSERT_RTNL();
 
 	if (!in_dev) {
-		inet_free_ifa(ifa);
+		inet_free_ifa(dev_net(dev), ifa);
 		return -ENOBUFS;
 	}
 	ipv4_devconf_setall(in_dev);
@@ -768,7 +772,7 @@ static struct in_ifaddr *rtm_to_ifaddr(s
 	if (!in_dev)
 		goto errout;
 
-	ifa = inet_alloc_ifa();
+	ifa = inet_alloc_ifa(net);
 	if (!ifa)
 		/*
 		 * A potential indev allocation can be left alive, it stays
@@ -817,7 +821,7 @@ static struct in_ifaddr *rtm_to_ifaddr(s
 	return ifa;
 
 errout_free:
-	inet_free_ifa(ifa);
+	inet_free_ifa(net, ifa);
 errout:
 	return ERR_PTR(err);
 }
@@ -865,13 +869,13 @@ static int inet_rtm_newaddr(struct sk_bu
 					       true, ifa);
 
 			if (ret < 0) {
-				inet_free_ifa(ifa);
+				inet_free_ifa(net, ifa);
 				return ret;
 			}
 		}
 		return __inet_insert_ifa(ifa, nlh, NETLINK_CB(skb).portid);
 	} else {
-		inet_free_ifa(ifa);
+		inet_free_ifa(net, ifa);
 
 		if (nlh->nlmsg_flags & NLM_F_EXCL ||
 		    !(nlh->nlmsg_flags & NLM_F_REPLACE))
@@ -1055,7 +1059,7 @@ int devinet_ioctl(struct net *net, unsig
 
 		if (!ifa) {
 			ret = -ENOBUFS;
-			ifa = inet_alloc_ifa();
+			ifa = inet_alloc_ifa(net);
 			if (!ifa)
 				break;
 			INIT_HLIST_NODE(&ifa->hash);
@@ -1408,7 +1412,7 @@ static int inetdev_event(struct notifier
 		if (!inetdev_valid_mtu(dev->mtu))
 			break;
 		if (dev->flags & IFF_LOOPBACK) {
-			struct in_ifaddr *ifa = inet_alloc_ifa();
+			struct in_ifaddr *ifa = inet_alloc_ifa(dev_net(dev));
 
 			if (ifa) {
 				INIT_HLIST_NODE(&ifa->hash);
Index: linux-ml.git/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- linux-ml.git.orig/net/ipv4/sysctl_net_ipv4.c
+++ linux-ml.git/net/ipv4/sysctl_net_ipv4.c
@@ -960,6 +960,13 @@ static struct ctl_table ipv4_net_table[]
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
+	{
+		.procname	= "ifa_limit",
+		.data		= &init_net.ipv4.sysctl_ifa_limit,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
@@ -988,6 +995,7 @@ static __net_init int ipv4_sysctl_init_n
 	if (!net->ipv4.sysctl_local_reserved_ports)
 		goto err_ports;
 
+	net->ipv4.sysctl_ifa_limit = 4096;
 	return 0;
 
 err_ports:
