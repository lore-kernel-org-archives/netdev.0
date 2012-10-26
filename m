From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 3/5] rtnl/ipv6: add support of RTM_GETNETCONF
Date: Fri, 26 Oct 2012 10:28:51 +0200
Message-ID: <1351240133-4427-4-git-send-email-nicolas.dichtel@6wind.com>
References: <20121026.021830.1470799532580844849.davem@davemloft.net>
 <1351240133-4427-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38317 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139Ab2JZITw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 04:19:52 -0400
In-Reply-To: <1351240133-4427-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message allows to get the devconf for an interface.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c | 75 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 73 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0c57a8f..8f0b12a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -466,7 +466,8 @@ static int inet6_netconf_msgsize_devconf(int type)
 	int size =  NLMSG_ALIGN(sizeof(struct netconfmsg))
 		    + nla_total_size(4);	/* NETCONFA_IFINDEX */
 
-	if (type == NETCONFA_FORWARDING)
+	/* type -1 is used for ALL */
+	if (type == -1 || type == NETCONFA_FORWARDING)
 		size += nla_total_size(4);
 
 	return size;
@@ -491,7 +492,8 @@ static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
 		goto nla_put_failure;
 
-	if (type == NETCONFA_FORWARDING &&
+	/* type -1 is used for ALL */
+	if ((type == -1 || type == NETCONFA_FORWARDING) &&
 	    nla_put_s32(skb, NETCONFA_FORWARDING, devconf->forwarding) < 0)
 		goto nla_put_failure;
 
@@ -527,6 +529,73 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_IPV6_NETCONF, err);
 }
 
+static const struct nla_policy devconf_ipv6_policy[NETCONFA_MAX+1] = {
+	[NETCONFA_IFINDEX]	= { .len = sizeof(int) },
+	[NETCONFA_FORWARDING]	= { .len = sizeof(int) },
+};
+
+static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
+				     struct nlmsghdr *nlh,
+				     void *arg)
+{
+	struct net *net = sock_net(in_skb->sk);
+	struct nlattr *tb[NETCONFA_MAX+1];
+	struct netconfmsg *ncm;
+	struct sk_buff *skb;
+	struct ipv6_devconf *devconf;
+	struct inet6_dev *in6_dev;
+	struct net_device *dev;
+	int ifindex;
+	int err;
+
+	err = nlmsg_parse(nlh, sizeof(*ncm), tb, NETCONFA_MAX,
+			  devconf_ipv6_policy);
+	if (err < 0)
+		goto errout;
+
+	err = EINVAL;
+	if (!tb[NETCONFA_IFINDEX])
+		goto errout;
+
+	ifindex = nla_get_s32(tb[NETCONFA_IFINDEX]);
+	switch (ifindex) {
+	case NETCONFA_IFINDEX_ALL:
+		devconf = net->ipv6.devconf_all;
+		break;
+	case NETCONFA_IFINDEX_DEFAULT:
+		devconf = net->ipv6.devconf_dflt;
+		break;
+	default:
+		dev = __dev_get_by_index(net, ifindex);
+		if (dev == NULL)
+			goto errout;
+		in6_dev = __in6_dev_get(dev);
+		if (in6_dev == NULL)
+			goto errout;
+		devconf = &in6_dev->cnf;
+		break;
+	}
+
+	err = -ENOBUFS;
+	skb = nlmsg_new(inet6_netconf_msgsize_devconf(-1), GFP_ATOMIC);
+	if (skb == NULL)
+		goto errout;
+
+	err = inet6_netconf_fill_devconf(skb, ifindex, devconf,
+					 NETLINK_CB(in_skb).portid,
+					 nlh->nlmsg_seq, RTM_NEWNETCONF, 0,
+					 -1);
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in inet6_netconf_msgsize_devconf() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
+errout:
+	return err;
+}
+
 #ifdef CONFIG_SYSCTL
 static void dev_forward_change(struct inet6_dev *idev)
 {
@@ -4861,6 +4930,8 @@ int __init addrconf_init(void)
 			inet6_dump_ifmcaddr, NULL);
 	__rtnl_register(PF_INET6, RTM_GETANYCAST, NULL,
 			inet6_dump_ifacaddr, NULL);
+	__rtnl_register(PF_INET6, RTM_GETNETCONF, inet6_netconf_get_devconf,
+			NULL, NULL);
 
 	ipv6_addr_label_rtnl_register();
 
-- 
1.7.12
