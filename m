From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/7] netconf: advertise mc_forwarding status
Date: Tue,  4 Dec 2012 12:13:35 +0100
Message-ID: <1354619621-16016-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56624 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731Ab2LDLNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 06:13:49 -0500
In-Reply-To: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch advertise the MC_FORWARDING status for IPv4 and IPv6.
This field is readonly, only multicast engine in the kernel updates it.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/inetdevice.h   |  3 +++
 include/net/addrconf.h       |  3 +++
 include/uapi/linux/netconf.h |  1 +
 net/ipv4/devinet.c           | 10 ++++++++--
 net/ipv4/ipmr.c              | 12 ++++++++++++
 net/ipv6/addrconf.c          | 10 ++++++++--
 net/ipv6/ip6mr.c             | 20 ++++++++++++++++++--
 7 files changed, 53 insertions(+), 6 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index d032780..a9d8289 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -171,6 +171,9 @@ struct in_ifaddr {
 extern int register_inetaddr_notifier(struct notifier_block *nb);
 extern int unregister_inetaddr_notifier(struct notifier_block *nb);
 
+extern void inet_netconf_notify_devconf(struct net *net, int type, int ifindex,
+					struct ipv4_devconf *devconf);
+
 extern struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref);
 static inline struct net_device *ip_dev_find(struct net *net, __be32 addr)
 {
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 9e63e76..df4ef94 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -172,6 +172,9 @@ extern bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
 extern int register_inet6addr_notifier(struct notifier_block *nb);
 extern int unregister_inet6addr_notifier(struct notifier_block *nb);
 
+extern void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
+					 struct ipv6_devconf *devconf);
+
 /**
  * __in6_dev_get - get inet6_dev pointer from netdevice
  * @dev: network device
diff --git a/include/uapi/linux/netconf.h b/include/uapi/linux/netconf.h
index 75dcbc5..64804a7 100644
--- a/include/uapi/linux/netconf.h
+++ b/include/uapi/linux/netconf.h
@@ -13,6 +13,7 @@ enum {
 	NETCONFA_IFINDEX,
 	NETCONFA_FORWARDING,
 	NETCONFA_RP_FILTER,
+	NETCONFA_MC_FORWARDING,
 	__NETCONFA_MAX
 };
 #define NETCONFA_MAX	(__NETCONFA_MAX - 1)
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index e13183a..cc06a47 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1453,6 +1453,8 @@ static int inet_netconf_msgsize_devconf(int type)
 		size += nla_total_size(4);
 	if (type == -1 || type == NETCONFA_RP_FILTER)
 		size += nla_total_size(4);
+	if (type == -1 || type == NETCONFA_MC_FORWARDING)
+		size += nla_total_size(4);
 
 	return size;
 }
@@ -1485,6 +1487,10 @@ static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 	    nla_put_s32(skb, NETCONFA_RP_FILTER,
 			IPV4_DEVCONF(*devconf, RP_FILTER)) < 0)
 		goto nla_put_failure;
+	if ((type == -1 || type == NETCONFA_MC_FORWARDING) &&
+	    nla_put_s32(skb, NETCONFA_MC_FORWARDING,
+			IPV4_DEVCONF(*devconf, MC_FORWARDING)) < 0)
+		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
 
@@ -1493,8 +1499,8 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static void inet_netconf_notify_devconf(struct net *net, int type, int ifindex,
-					struct ipv4_devconf *devconf)
+void inet_netconf_notify_devconf(struct net *net, int type, int ifindex,
+				 struct ipv4_devconf *devconf)
 {
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 58e4160..0c452e3 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -65,6 +65,7 @@
 #include <net/checksum.h>
 #include <net/netlink.h>
 #include <net/fib_rules.h>
+#include <linux/netconf.h>
 
 #if defined(CONFIG_IP_PIMSM_V1) || defined(CONFIG_IP_PIMSM_V2)
 #define CONFIG_IP_PIMSM	1
@@ -582,6 +583,9 @@ static int vif_delete(struct mr_table *mrt, int vifi, int notify,
 	in_dev = __in_dev_get_rtnl(dev);
 	if (in_dev) {
 		IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)--;
+		inet_netconf_notify_devconf(dev_net(dev),
+					    NETCONFA_MC_FORWARDING,
+					    dev->ifindex, &in_dev->cnf);
 		ip_rt_multicast_event(in_dev);
 	}
 
@@ -772,6 +776,8 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 		return -EADDRNOTAVAIL;
 	}
 	IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)++;
+	inet_netconf_notify_devconf(net, NETCONFA_MC_FORWARDING, dev->ifindex,
+				    &in_dev->cnf);
 	ip_rt_multicast_event(in_dev);
 
 	/* Fill in the VIF structures */
@@ -1185,6 +1191,9 @@ static void mrtsock_destruct(struct sock *sk)
 	ipmr_for_each_table(mrt, net) {
 		if (sk == rtnl_dereference(mrt->mroute_sk)) {
 			IPV4_DEVCONF_ALL(net, MC_FORWARDING)--;
+			inet_netconf_notify_devconf(net, NETCONFA_MC_FORWARDING,
+						    NETCONFA_IFINDEX_ALL,
+						    net->ipv4.devconf_all);
 			RCU_INIT_POINTER(mrt->mroute_sk, NULL);
 			mroute_clean_tables(mrt);
 		}
@@ -1236,6 +1245,9 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		if (ret == 0) {
 			rcu_assign_pointer(mrt->mroute_sk, sk);
 			IPV4_DEVCONF_ALL(net, MC_FORWARDING)++;
+			inet_netconf_notify_devconf(net, NETCONFA_MC_FORWARDING,
+						    NETCONFA_IFINDEX_ALL,
+						    net->ipv4.devconf_all);
 		}
 		rtnl_unlock();
 		return ret;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4b644f6..976543d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -469,6 +469,8 @@ static int inet6_netconf_msgsize_devconf(int type)
 	/* type -1 is used for ALL */
 	if (type == -1 || type == NETCONFA_FORWARDING)
 		size += nla_total_size(4);
+	if (type == -1 || type == NETCONFA_MC_FORWARDING)
+		size += nla_total_size(4);
 
 	return size;
 }
@@ -496,6 +498,10 @@ static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 	if ((type == -1 || type == NETCONFA_FORWARDING) &&
 	    nla_put_s32(skb, NETCONFA_FORWARDING, devconf->forwarding) < 0)
 		goto nla_put_failure;
+	if ((type == -1 || type == NETCONFA_MC_FORWARDING) &&
+	    nla_put_s32(skb, NETCONFA_MC_FORWARDING,
+			devconf->mc_forwarding) < 0)
+		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
 
@@ -504,8 +510,8 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
-					 struct ipv6_devconf *devconf)
+void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
+				  struct ipv6_devconf *devconf)
 {
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index d7c7e90..efc6d91 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -52,6 +52,7 @@
 #include <linux/netfilter_ipv6.h>
 #include <linux/export.h>
 #include <net/ip6_checksum.h>
+#include <linux/netconf.h>
 
 struct mr6_table {
 	struct list_head	list;
@@ -805,8 +806,12 @@ static int mif6_delete(struct mr6_table *mrt, int vifi, struct list_head *head)
 	dev_set_allmulti(dev, -1);
 
 	in6_dev = __in6_dev_get(dev);
-	if (in6_dev)
+	if (in6_dev) {
 		in6_dev->cnf.mc_forwarding--;
+		inet6_netconf_notify_devconf(dev_net(dev),
+					     NETCONFA_MC_FORWARDING,
+					     dev->ifindex, &in6_dev->cnf);
+	}
 
 	if (v->flags & MIFF_REGISTER)
 		unregister_netdevice_queue(dev, head);
@@ -958,8 +963,12 @@ static int mif6_add(struct net *net, struct mr6_table *mrt,
 	}
 
 	in6_dev = __in6_dev_get(dev);
-	if (in6_dev)
+	if (in6_dev) {
 		in6_dev->cnf.mc_forwarding++;
+		inet6_netconf_notify_devconf(dev_net(dev),
+					     NETCONFA_MC_FORWARDING,
+					     dev->ifindex, &in6_dev->cnf);
+	}
 
 	/*
 	 *	Fill in the VIF structures
@@ -1513,6 +1522,9 @@ static int ip6mr_sk_init(struct mr6_table *mrt, struct sock *sk)
 	if (likely(mrt->mroute6_sk == NULL)) {
 		mrt->mroute6_sk = sk;
 		net->ipv6.devconf_all->mc_forwarding++;
+		inet6_netconf_notify_devconf(net, NETCONFA_MC_FORWARDING,
+					     NETCONFA_IFINDEX_ALL,
+					     net->ipv6.devconf_all);
 	}
 	else
 		err = -EADDRINUSE;
@@ -1535,6 +1547,10 @@ int ip6mr_sk_done(struct sock *sk)
 			write_lock_bh(&mrt_lock);
 			mrt->mroute6_sk = NULL;
 			net->ipv6.devconf_all->mc_forwarding--;
+			inet6_netconf_notify_devconf(net,
+						     NETCONFA_MC_FORWARDING,
+						     NETCONFA_IFINDEX_ALL,
+						     net->ipv6.devconf_all);
 			write_unlock_bh(&mrt_lock);
 
 			mroute_clean_tables(mrt);
-- 
1.8.0.1
