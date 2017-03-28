From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/7] net: devinet: Refactor inet_netconf_notify_devconf to take event
Date: Tue, 28 Mar 2017 14:28:02 -0700
Message-ID: <1490736487-16020-3-git-send-email-dsa@cumulusnetworks.com>
References: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:37684 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932548AbdC1V2U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 17:28:20 -0400
Received: by mail-it0-f44.google.com with SMTP id 190so34845806itm.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 14:28:19 -0700 (PDT)
In-Reply-To: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor inet_netconf_notify_devconf to take the event as an input arg.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/inetdevice.h |  4 ++--
 net/ipv4/devinet.c         | 32 ++++++++++++++++++++------------
 net/ipv4/ipmr.c            | 12 +++++++-----
 3 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index ee971f335a8b..a2e9d6ea1349 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -153,8 +153,8 @@ struct in_ifaddr {
 int register_inetaddr_notifier(struct notifier_block *nb);
 int unregister_inetaddr_notifier(struct notifier_block *nb);
 
-void inet_netconf_notify_devconf(struct net *net, int type, int ifindex,
-				 struct ipv4_devconf *devconf);
+void inet_netconf_notify_devconf(struct net *net, int event, int type,
+				 int ifindex, struct ipv4_devconf *devconf);
 
 struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref);
 static inline struct net_device *ip_dev_find(struct net *net, __be32 addr)
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 927f1d4b8c80..fd3218cd1870 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1831,8 +1831,8 @@ static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 	return -EMSGSIZE;
 }
 
-void inet_netconf_notify_devconf(struct net *net, int type, int ifindex,
-				 struct ipv4_devconf *devconf)
+void inet_netconf_notify_devconf(struct net *net, int event, int type,
+				 int ifindex, struct ipv4_devconf *devconf)
 {
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
@@ -1842,7 +1842,7 @@ void inet_netconf_notify_devconf(struct net *net, int type, int ifindex,
 		goto errout;
 
 	err = inet_netconf_fill_devconf(skb, ifindex, devconf, 0, 0,
-					RTM_NEWNETCONF, 0, type);
+					event, 0, type);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in inet_netconf_msgsize_devconf() */
 		WARN_ON(err == -EMSGSIZE);
@@ -2021,10 +2021,12 @@ static void inet_forward_change(struct net *net)
 
 	IPV4_DEVCONF_ALL(net, ACCEPT_REDIRECTS) = !on;
 	IPV4_DEVCONF_DFLT(net, FORWARDING) = on;
-	inet_netconf_notify_devconf(net, NETCONFA_FORWARDING,
+	inet_netconf_notify_devconf(net, RTM_NEWNETCONF,
+				    NETCONFA_FORWARDING,
 				    NETCONFA_IFINDEX_ALL,
 				    net->ipv4.devconf_all);
-	inet_netconf_notify_devconf(net, NETCONFA_FORWARDING,
+	inet_netconf_notify_devconf(net, RTM_NEWNETCONF,
+				    NETCONFA_FORWARDING,
 				    NETCONFA_IFINDEX_DEFAULT,
 				    net->ipv4.devconf_dflt);
 
@@ -2037,7 +2039,8 @@ static void inet_forward_change(struct net *net)
 		in_dev = __in_dev_get_rtnl(dev);
 		if (in_dev) {
 			IN_DEV_CONF_SET(in_dev, FORWARDING, on);
-			inet_netconf_notify_devconf(net, NETCONFA_FORWARDING,
+			inet_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						    NETCONFA_FORWARDING,
 						    dev->ifindex, &in_dev->cnf);
 		}
 	}
@@ -2082,19 +2085,22 @@ static int devinet_conf_proc(struct ctl_table *ctl, int write,
 		if (i == IPV4_DEVCONF_RP_FILTER - 1 &&
 		    new_value != old_value) {
 			ifindex = devinet_conf_ifindex(net, cnf);
-			inet_netconf_notify_devconf(net, NETCONFA_RP_FILTER,
+			inet_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						    NETCONFA_RP_FILTER,
 						    ifindex, cnf);
 		}
 		if (i == IPV4_DEVCONF_PROXY_ARP - 1 &&
 		    new_value != old_value) {
 			ifindex = devinet_conf_ifindex(net, cnf);
-			inet_netconf_notify_devconf(net, NETCONFA_PROXY_NEIGH,
+			inet_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						    NETCONFA_PROXY_NEIGH,
 						    ifindex, cnf);
 		}
 		if (i == IPV4_DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN - 1 &&
 		    new_value != old_value) {
 			ifindex = devinet_conf_ifindex(net, cnf);
-			inet_netconf_notify_devconf(net, NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
+			inet_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						    NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
 						    ifindex, cnf);
 		}
 	}
@@ -2129,7 +2135,7 @@ static int devinet_sysctl_forward(struct ctl_table *ctl, int write,
 					container_of(cnf, struct in_device, cnf);
 				if (*valp)
 					dev_disable_lro(idev->dev);
-				inet_netconf_notify_devconf(net,
+				inet_netconf_notify_devconf(net, RTM_NEWNETCONF,
 							    NETCONFA_FORWARDING,
 							    idev->dev->ifindex,
 							    cnf);
@@ -2137,7 +2143,8 @@ static int devinet_sysctl_forward(struct ctl_table *ctl, int write,
 			rtnl_unlock();
 			rt_cache_flush(net);
 		} else
-			inet_netconf_notify_devconf(net, NETCONFA_FORWARDING,
+			inet_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						    NETCONFA_FORWARDING,
 						    NETCONFA_IFINDEX_DEFAULT,
 						    net->ipv4.devconf_dflt);
 	}
@@ -2259,7 +2266,8 @@ static int __devinet_sysctl_register(struct net *net, char *dev_name,
 
 	p->sysctl = t;
 
-	inet_netconf_notify_devconf(net, NETCONFA_ALL, ifindex, p);
+	inet_netconf_notify_devconf(net, RTM_NEWNETCONF, NETCONFA_ALL,
+				    ifindex, p);
 	return 0;
 
 free:
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index c0317c940bcd..5bca64fc71b7 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -631,7 +631,7 @@ static int vif_delete(struct mr_table *mrt, int vifi, int notify,
 	in_dev = __in_dev_get_rtnl(dev);
 	if (in_dev) {
 		IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)--;
-		inet_netconf_notify_devconf(dev_net(dev),
+		inet_netconf_notify_devconf(dev_net(dev), RTM_NEWNETCONF,
 					    NETCONFA_MC_FORWARDING,
 					    dev->ifindex, &in_dev->cnf);
 		ip_rt_multicast_event(in_dev);
@@ -820,8 +820,8 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 		return -EADDRNOTAVAIL;
 	}
 	IPV4_DEVCONF(in_dev->cnf, MC_FORWARDING)++;
-	inet_netconf_notify_devconf(net, NETCONFA_MC_FORWARDING, dev->ifindex,
-				    &in_dev->cnf);
+	inet_netconf_notify_devconf(net, RTM_NEWNETCONF, NETCONFA_MC_FORWARDING,
+				    dev->ifindex, &in_dev->cnf);
 	ip_rt_multicast_event(in_dev);
 
 	/* Fill in the VIF structures */
@@ -1282,7 +1282,8 @@ static void mrtsock_destruct(struct sock *sk)
 	ipmr_for_each_table(mrt, net) {
 		if (sk == rtnl_dereference(mrt->mroute_sk)) {
 			IPV4_DEVCONF_ALL(net, MC_FORWARDING)--;
-			inet_netconf_notify_devconf(net, NETCONFA_MC_FORWARDING,
+			inet_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						    NETCONFA_MC_FORWARDING,
 						    NETCONFA_IFINDEX_ALL,
 						    net->ipv4.devconf_all);
 			RCU_INIT_POINTER(mrt->mroute_sk, NULL);
@@ -1344,7 +1345,8 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 		if (ret == 0) {
 			rcu_assign_pointer(mrt->mroute_sk, sk);
 			IPV4_DEVCONF_ALL(net, MC_FORWARDING)++;
-			inet_netconf_notify_devconf(net, NETCONFA_MC_FORWARDING,
+			inet_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						    NETCONFA_MC_FORWARDING,
 						    NETCONFA_IFINDEX_ALL,
 						    net->ipv4.devconf_all);
 		}
-- 
2.1.4
