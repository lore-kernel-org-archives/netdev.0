From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 5/5] rtnl/ipv4: add support of RTM_GETNETCONF
Date: Fri, 26 Oct 2012 10:28:53 +0200
Message-ID: <1351240133-4427-6-git-send-email-nicolas.dichtel@6wind.com>
References: <20121026.021830.1470799532580844849.davem@davemloft.net>
 <1351240133-4427-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38323 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932128Ab2JZITz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 04:19:55 -0400
In-Reply-To: <1351240133-4427-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message allows to get the devconf for an interface.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/devinet.c | 75 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 73 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 020fdd2..f8b1e04 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1448,7 +1448,8 @@ static int inet_netconf_msgsize_devconf(int type)
 	int size = NLMSG_ALIGN(sizeof(struct netconfmsg))
 		   + nla_total_size(4);	/* NETCONFA_IFINDEX */
 
-	if (type == NETCONFA_FORWARDING)
+	/* type -1 is used for ALL */
+	if (type == -1 || type == NETCONFA_FORWARDING)
 		size += nla_total_size(4);
 
 	return size;
@@ -1473,7 +1474,8 @@ static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
 		goto nla_put_failure;
 
-	if (type == NETCONFA_FORWARDING &&
+	/* type -1 is used for ALL */
+	if ((type == -1 || type == NETCONFA_FORWARDING) &&
 	    nla_put_s32(skb, NETCONFA_FORWARDING,
 			IPV4_DEVCONF(*devconf, FORWARDING)) < 0)
 		goto nla_put_failure;
@@ -1510,6 +1512,73 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_IPV4_NETCONF, err);
 }
 
+static const struct nla_policy devconf_ipv4_policy[NETCONFA_MAX+1] = {
+	[NETCONFA_IFINDEX]	= { .len = sizeof(int) },
+	[NETCONFA_FORWARDING]	= { .len = sizeof(int) },
+};
+
+static int inet_netconf_get_devconf(struct sk_buff *in_skb,
+				    struct nlmsghdr *nlh,
+				    void *arg)
+{
+	struct net *net = sock_net(in_skb->sk);
+	struct nlattr *tb[NETCONFA_MAX+1];
+	struct netconfmsg *ncm;
+	struct sk_buff *skb;
+	struct ipv4_devconf *devconf;
+	struct in_device *in_dev;
+	struct net_device *dev;
+	int ifindex;
+	int err;
+
+	err = nlmsg_parse(nlh, sizeof(*ncm), tb, NETCONFA_MAX,
+			  devconf_ipv4_policy);
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
+		devconf = net->ipv4.devconf_all;
+		break;
+	case NETCONFA_IFINDEX_DEFAULT:
+		devconf = net->ipv4.devconf_dflt;
+		break;
+	default:
+		dev = __dev_get_by_index(net, ifindex);
+		if (dev == NULL)
+			goto errout;
+		in_dev = __in_dev_get_rtnl(dev);
+		if (in_dev == NULL)
+			goto errout;
+		devconf = &in_dev->cnf;
+		break;
+	}
+
+	err = -ENOBUFS;
+	skb = nlmsg_new(inet_netconf_msgsize_devconf(-1), GFP_ATOMIC);
+	if (skb == NULL)
+		goto errout;
+
+	err = inet_netconf_fill_devconf(skb, ifindex, devconf,
+					NETLINK_CB(in_skb).portid,
+					nlh->nlmsg_seq, RTM_NEWNETCONF, 0,
+					-1);
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in inet_netconf_msgsize_devconf() */
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
 
 static void devinet_copy_dflt_conf(struct net *net, int i)
@@ -1894,5 +1963,7 @@ void __init devinet_init(void)
 	rtnl_register(PF_INET, RTM_NEWADDR, inet_rtm_newaddr, NULL, NULL);
 	rtnl_register(PF_INET, RTM_DELADDR, inet_rtm_deladdr, NULL, NULL);
 	rtnl_register(PF_INET, RTM_GETADDR, NULL, inet_dump_ifaddr, NULL);
+	rtnl_register(PF_INET, RTM_GETNETCONF, inet_netconf_get_devconf,
+		      NULL, NULL);
 }
 
-- 
1.7.12
