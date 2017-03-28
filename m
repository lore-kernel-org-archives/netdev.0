From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 4/7] net: ipv6: Refactor inet6_netconf_notify_devconf to take event
Date: Tue, 28 Mar 2017 14:28:04 -0700
Message-ID: <1490736487-16020-5-git-send-email-dsa@cumulusnetworks.com>
References: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:38144 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752363AbdC1V3X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 17:29:23 -0400
Received: by mail-it0-f54.google.com with SMTP id y18so36139168itc.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 14:29:12 -0700 (PDT)
In-Reply-To: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor inet6_netconf_notify_devconf to take the event as an input arg.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/addrconf.h |  4 ++--
 net/ipv6/addrconf.c    | 33 ++++++++++++++++++++++-----------
 net/ipv6/ip6mr.c       |  9 +++++----
 3 files changed, 29 insertions(+), 17 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 17c6fd84e287..1aeb25dd42a7 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -262,8 +262,8 @@ int register_inet6addr_notifier(struct notifier_block *nb);
 int unregister_inet6addr_notifier(struct notifier_block *nb);
 int inet6addr_notifier_call_chain(unsigned long val, void *v);
 
-void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
-				  struct ipv6_devconf *devconf);
+void inet6_netconf_notify_devconf(struct net *net, int event, int type,
+				  int ifindex, struct ipv6_devconf *devconf);
 
 /**
  * __in6_dev_get - get inet6_dev pointer from netdevice
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index dff5beb26a01..b8442be85e1b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -575,8 +575,8 @@ static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 	return -EMSGSIZE;
 }
 
-void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
-				  struct ipv6_devconf *devconf)
+void inet6_netconf_notify_devconf(struct net *net, int event, int type,
+				  int ifindex, struct ipv6_devconf *devconf)
 {
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
@@ -586,7 +586,7 @@ void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
 		goto errout;
 
 	err = inet6_netconf_fill_devconf(skb, ifindex, devconf, 0, 0,
-					 RTM_NEWNETCONF, 0, type);
+					 event, 0, type);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in inet6_netconf_msgsize_devconf() */
 		WARN_ON(err == -EMSGSIZE);
@@ -769,7 +769,8 @@ static void dev_forward_change(struct inet6_dev *idev)
 		else
 			addrconf_leave_anycast(ifa);
 	}
-	inet6_netconf_notify_devconf(dev_net(dev), NETCONFA_FORWARDING,
+	inet6_netconf_notify_devconf(dev_net(dev), RTM_NEWNETCONF,
+				     NETCONFA_FORWARDING,
 				     dev->ifindex, &idev->cnf);
 }
 
@@ -804,7 +805,8 @@ static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
 
 	if (p == &net->ipv6.devconf_dflt->forwarding) {
 		if ((!newf) ^ (!old))
-			inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,
+			inet6_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						     NETCONFA_FORWARDING,
 						     NETCONFA_IFINDEX_DEFAULT,
 						     net->ipv6.devconf_dflt);
 		rtnl_unlock();
@@ -816,13 +818,15 @@ static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
 
 		net->ipv6.devconf_dflt->forwarding = newf;
 		if ((!newf) ^ (!old_dflt))
-			inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,
+			inet6_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						     NETCONFA_FORWARDING,
 						     NETCONFA_IFINDEX_DEFAULT,
 						     net->ipv6.devconf_dflt);
 
 		addrconf_forward_change(net, newf);
 		if ((!newf) ^ (!old))
-			inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,
+			inet6_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						     NETCONFA_FORWARDING,
 						     NETCONFA_IFINDEX_ALL,
 						     net->ipv6.devconf_all);
 	} else if ((!newf) ^ (!old))
@@ -847,6 +851,7 @@ static void addrconf_linkdown_change(struct net *net, __s32 newf)
 			idev->cnf.ignore_routes_with_linkdown = newf;
 			if (changed)
 				inet6_netconf_notify_devconf(dev_net(dev),
+							     RTM_NEWNETCONF,
 							     NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
 							     dev->ifindex,
 							     &idev->cnf);
@@ -869,6 +874,7 @@ static int addrconf_fixup_linkdown(struct ctl_table *table, int *p, int newf)
 	if (p == &net->ipv6.devconf_dflt->ignore_routes_with_linkdown) {
 		if ((!newf) ^ (!old))
 			inet6_netconf_notify_devconf(net,
+						     RTM_NEWNETCONF,
 						     NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
 						     NETCONFA_IFINDEX_DEFAULT,
 						     net->ipv6.devconf_dflt);
@@ -881,6 +887,7 @@ static int addrconf_fixup_linkdown(struct ctl_table *table, int *p, int newf)
 		addrconf_linkdown_change(net, newf);
 		if ((!newf) ^ (!old))
 			inet6_netconf_notify_devconf(net,
+						     RTM_NEWNETCONF,
 						     NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
 						     NETCONFA_IFINDEX_ALL,
 						     net->ipv6.devconf_all);
@@ -5675,17 +5682,20 @@ int addrconf_sysctl_proxy_ndp(struct ctl_table *ctl, int write,
 			return restart_syscall();
 
 		if (valp == &net->ipv6.devconf_dflt->proxy_ndp)
-			inet6_netconf_notify_devconf(net, NETCONFA_PROXY_NEIGH,
+			inet6_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						     NETCONFA_PROXY_NEIGH,
 						     NETCONFA_IFINDEX_DEFAULT,
 						     net->ipv6.devconf_dflt);
 		else if (valp == &net->ipv6.devconf_all->proxy_ndp)
-			inet6_netconf_notify_devconf(net, NETCONFA_PROXY_NEIGH,
+			inet6_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						     NETCONFA_PROXY_NEIGH,
 						     NETCONFA_IFINDEX_ALL,
 						     net->ipv6.devconf_all);
 		else {
 			struct inet6_dev *idev = ctl->extra1;
 
-			inet6_netconf_notify_devconf(net, NETCONFA_PROXY_NEIGH,
+			inet6_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						     NETCONFA_PROXY_NEIGH,
 						     idev->dev->ifindex,
 						     &idev->cnf);
 		}
@@ -6348,7 +6358,8 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 		ifindex = NETCONFA_IFINDEX_DEFAULT;
 	else
 		ifindex = idev->dev->ifindex;
-	inet6_netconf_notify_devconf(net, NETCONFA_ALL, ifindex, p);
+	inet6_netconf_notify_devconf(net, RTM_NEWNETCONF, NETCONFA_ALL,
+				     ifindex, p);
 	return 0;
 
 free:
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 6ba6c900ebcf..fb4546e80c82 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -815,7 +815,7 @@ static int mif6_delete(struct mr6_table *mrt, int vifi, struct list_head *head)
 	in6_dev = __in6_dev_get(dev);
 	if (in6_dev) {
 		in6_dev->cnf.mc_forwarding--;
-		inet6_netconf_notify_devconf(dev_net(dev),
+		inet6_netconf_notify_devconf(dev_net(dev), RTM_NEWNETCONF,
 					     NETCONFA_MC_FORWARDING,
 					     dev->ifindex, &in6_dev->cnf);
 	}
@@ -974,7 +974,7 @@ static int mif6_add(struct net *net, struct mr6_table *mrt,
 	in6_dev = __in6_dev_get(dev);
 	if (in6_dev) {
 		in6_dev->cnf.mc_forwarding++;
-		inet6_netconf_notify_devconf(dev_net(dev),
+		inet6_netconf_notify_devconf(dev_net(dev), RTM_NEWNETCONF,
 					     NETCONFA_MC_FORWARDING,
 					     dev->ifindex, &in6_dev->cnf);
 	}
@@ -1599,7 +1599,8 @@ static int ip6mr_sk_init(struct mr6_table *mrt, struct sock *sk)
 	write_unlock_bh(&mrt_lock);
 
 	if (!err)
-		inet6_netconf_notify_devconf(net, NETCONFA_MC_FORWARDING,
+		inet6_netconf_notify_devconf(net, RTM_NEWNETCONF,
+					     NETCONFA_MC_FORWARDING,
 					     NETCONFA_IFINDEX_ALL,
 					     net->ipv6.devconf_all);
 	rtnl_unlock();
@@ -1620,7 +1621,7 @@ int ip6mr_sk_done(struct sock *sk)
 			mrt->mroute6_sk = NULL;
 			net->ipv6.devconf_all->mc_forwarding--;
 			write_unlock_bh(&mrt_lock);
-			inet6_netconf_notify_devconf(net,
+			inet6_netconf_notify_devconf(net, RTM_NEWNETCONF,
 						     NETCONFA_MC_FORWARDING,
 						     NETCONFA_IFINDEX_ALL,
 						     net->ipv6.devconf_all);
-- 
2.1.4
