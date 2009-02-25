From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] netlink: change nlmsg_notify() return value logic
Date: Wed, 25 Feb 2009 03:55:02 +0100
Message-ID: <20090225025502.4716.3568.stgit@Decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57481 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753289AbZBYCzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 21:55:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the return value of nlmsg_notify() as follows:

If NETLINK_BROADCAST_ERROR is set by any of the listeners and
an error in the delivery happened, return the broadcast error;
else if there are no listeners apart from the socket that
requested a change with the echo flag, return the result of the
unicast notification. Thus, with this patch, the unicast
notification is handled in the same way of a broadcast listener
that has set the NETLINK_BROADCAST_ERROR socket flag.

This patch is useful in case that the caller of nlmsg_notify()
wants to know the result of the delivery of a netlink notification
(including the broadcast delivery) and take any action in case
that the delivery failed. For example, ctnetlink can drop packets
if the event delivery failed to provide reliable logging and
state-synchronization at the cost of dropping packets.

This patch also modifies the rtnetlink code to ignore the return
value of rtnl_notify() in all callers. The function rtnl_notify()
(before this patch) returned the error of the unicast notification
which makes rtnl_set_sk_err() reports errors to all listeners. This
is not of any help since the origin of the change (the socket that
requested the echoing) notices the ENOBUFS error if the notification
fails and should resync itself.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---

 include/linux/rtnetlink.h |    4 ++--
 net/bridge/br_netlink.c   |    3 ++-
 net/core/fib_rules.c      |    3 ++-
 net/core/neighbour.c      |    3 ++-
 net/core/rtnetlink.c      |    9 +++++----
 net/decnet/dn_dev.c       |    3 ++-
 net/decnet/dn_table.c     |    3 ++-
 net/ipv4/devinet.c        |    3 ++-
 net/ipv4/fib_semantics.c  |    5 +++--
 net/ipv6/addrconf.c       |    9 ++++++---
 net/ipv6/ndisc.c          |    6 +-----
 net/ipv6/route.c          |    5 +++--
 net/netlink/af_netlink.c  |   14 ++++++++++----
 net/phonet/pn_netlink.c   |    5 +++--
 14 files changed, 45 insertions(+), 30 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 1e5f673..35a07c8 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -622,8 +622,8 @@ static __inline__ int rtattr_strcmp(const struct rtattr *rta, const char *str)
 
 extern int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, u32 group, int echo);
 extern int rtnl_unicast(struct sk_buff *skb, struct net *net, u32 pid);
-extern int rtnl_notify(struct sk_buff *skb, struct net *net, u32 pid, u32 group,
-		       struct nlmsghdr *nlh, gfp_t flags);
+extern void rtnl_notify(struct sk_buff *skb, struct net *net, u32 pid,
+			u32 group, struct nlmsghdr *nlh, gfp_t flags);
 extern void rtnl_set_sk_err(struct net *net, u32 group, int error);
 extern int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics);
 extern int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst,
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index ba7be19..fcffb3f 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -98,7 +98,8 @@ void br_ifinfo_notify(int event, struct net_bridge_port *port)
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
+	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
+	return;
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(net, RTNLGRP_LINK, err);
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 32b3a01..98691e1 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -588,7 +588,8 @@ static void notify_rule_change(int event, struct fib_rule *rule,
 		goto errout;
 	}
 
-	err = rtnl_notify(skb, net, pid, ops->nlgroup, nlh, GFP_KERNEL);
+	rtnl_notify(skb, net, pid, ops->nlgroup, nlh, GFP_KERNEL);
+	return;
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(net, ops->nlgroup, err);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 278a142..e1144cb 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2534,7 +2534,8 @@ static void __neigh_notify(struct neighbour *n, int type, int flags)
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, net, 0, RTNLGRP_NEIGH, NULL, GFP_ATOMIC);
+	rtnl_notify(skb, net, 0, RTNLGRP_NEIGH, NULL, GFP_ATOMIC);
+	return;
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 790dd20..d78030f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -455,8 +455,8 @@ int rtnl_unicast(struct sk_buff *skb, struct net *net, u32 pid)
 	return nlmsg_unicast(rtnl, skb, pid);
 }
 
-int rtnl_notify(struct sk_buff *skb, struct net *net, u32 pid, u32 group,
-		struct nlmsghdr *nlh, gfp_t flags)
+void rtnl_notify(struct sk_buff *skb, struct net *net, u32 pid, u32 group,
+		 struct nlmsghdr *nlh, gfp_t flags)
 {
 	struct sock *rtnl = net->rtnl;
 	int report = 0;
@@ -464,7 +464,7 @@ int rtnl_notify(struct sk_buff *skb, struct net *net, u32 pid, u32 group,
 	if (nlh)
 		report = nlmsg_report(nlh);
 
-	return nlmsg_notify(rtnl, skb, pid, group, report, flags);
+	nlmsg_notify(rtnl, skb, pid, group, report, flags);
 }
 
 void rtnl_set_sk_err(struct net *net, u32 group, int error)
@@ -1246,7 +1246,8 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_KERNEL);
+	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_KERNEL);
+	return;
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(net, RTNLGRP_LINK, err);
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index daf2b98..e457769 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -769,7 +769,8 @@ static void dn_ifaddr_notify(int event, struct dn_ifaddr *ifa)
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, &init_net, 0, RTNLGRP_DECnet_IFADDR, NULL, GFP_KERNEL);
+	rtnl_notify(skb, &init_net, 0, RTNLGRP_DECnet_IFADDR, NULL, GFP_KERNEL);
+	return;
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(&init_net, RTNLGRP_DECnet_IFADDR, err);
diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index 69ad928..67054b0 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -375,7 +375,8 @@ static void dn_rtmsg_fib(int event, struct dn_fib_node *f, int z, u32 tb_id,
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, &init_net, pid, RTNLGRP_DECnet_ROUTE, nlh, GFP_KERNEL);
+	rtnl_notify(skb, &init_net, pid, RTNLGRP_DECnet_ROUTE, nlh, GFP_KERNEL);
+	return;
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(&init_net, RTNLGRP_DECnet_ROUTE, err);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index d519a6a..126bb91 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1216,7 +1216,8 @@ static void rtmsg_ifa(int event, struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, net, pid, RTNLGRP_IPV4_IFADDR, nlh, GFP_KERNEL);
+	rtnl_notify(skb, net, pid, RTNLGRP_IPV4_IFADDR, nlh, GFP_KERNEL);
+	return;
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(net, RTNLGRP_IPV4_IFADDR, err);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 4817dea..f831df5 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -322,8 +322,9 @@ void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, info->nl_net, info->pid, RTNLGRP_IPV4_ROUTE,
-			  info->nlh, GFP_KERNEL);
+	rtnl_notify(skb, info->nl_net, info->pid, RTNLGRP_IPV4_ROUTE,
+		    info->nlh, GFP_KERNEL);
+	return;
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(info->nl_net, RTNLGRP_IPV4_ROUTE, err);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 03e2a1a..f8f76d6 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3638,7 +3638,8 @@ static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa)
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, net, 0, RTNLGRP_IPV6_IFADDR, NULL, GFP_ATOMIC);
+	rtnl_notify(skb, net, 0, RTNLGRP_IPV6_IFADDR, NULL, GFP_ATOMIC);
+	return;
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(net, RTNLGRP_IPV6_IFADDR, err);
@@ -3849,7 +3850,8 @@ void inet6_ifinfo_notify(int event, struct inet6_dev *idev)
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, net, 0, RTNLGRP_IPV6_IFADDR, NULL, GFP_ATOMIC);
+	rtnl_notify(skb, net, 0, RTNLGRP_IPV6_IFADDR, NULL, GFP_ATOMIC);
+	return;
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(net, RTNLGRP_IPV6_IFADDR, err);
@@ -3919,7 +3921,8 @@ static void inet6_prefix_notify(int event, struct inet6_dev *idev,
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, net, 0, RTNLGRP_IPV6_PREFIX, NULL, GFP_ATOMIC);
+	rtnl_notify(skb, net, 0, RTNLGRP_IPV6_PREFIX, NULL, GFP_ATOMIC);
+	return;
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(net, RTNLGRP_IPV6_PREFIX, err);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 3cd83b8..9f061d1 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1095,11 +1095,7 @@ static void ndisc_ra_useropt(struct sk_buff *ra, struct nd_opt_hdr *opt)
 		&ipv6_hdr(ra)->saddr);
 	nlmsg_end(skb, nlh);
 
-	err = rtnl_notify(skb, net, 0, RTNLGRP_ND_USEROPT, NULL,
-			  GFP_ATOMIC);
-	if (err < 0)
-		goto errout;
-
+	rtnl_notify(skb, net, 0, RTNLGRP_ND_USEROPT, NULL, GFP_ATOMIC);
 	return;
 
 nla_put_failure:
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c3d486a..1394ddb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2400,8 +2400,9 @@ void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info)
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, net, info->pid, RTNLGRP_IPV6_ROUTE,
-			  info->nlh, gfp_any());
+	rtnl_notify(skb, net, info->pid, RTNLGRP_IPV6_ROUTE,
+		    info->nlh, gfp_any());
+	return;
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(net, RTNLGRP_IPV6_ROUTE, err);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ed587be..2760b62 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1760,12 +1760,18 @@ int nlmsg_notify(struct sock *sk, struct sk_buff *skb, u32 pid,
 			exclude_pid = pid;
 		}
 
-		/* errors reported via destination sk->sk_err */
-		nlmsg_multicast(sk, skb, exclude_pid, group, flags);
+		/* errors reported via destination sk->sk_err, but propagate
+		 * delivery errors if NETLINK_BROADCAST_ERROR flag is set */
+		err = nlmsg_multicast(sk, skb, exclude_pid, group, flags);
 	}
 
-	if (report)
-		err = nlmsg_unicast(sk, skb, pid);
+	if (report) {
+		int err2;
+
+		err2 = nlmsg_unicast(sk, skb, pid);
+		if (!err || err == -ESRCH)
+			err = err2;
+	}
 
 	return err;
 }
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index 1ceea1f..cec4e59 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -47,8 +47,9 @@ static void rtmsg_notify(int event, struct net_device *dev, u8 addr)
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, dev_net(dev), 0,
-			  RTNLGRP_PHONET_IFADDR, NULL, GFP_KERNEL);
+	rtnl_notify(skb, dev_net(dev), 0,
+		    RTNLGRP_PHONET_IFADDR, NULL, GFP_KERNEL);
+	return;
 errout:
 	if (err < 0)
 		rtnl_set_sk_err(dev_net(dev), RTNLGRP_PHONET_IFADDR, err);

