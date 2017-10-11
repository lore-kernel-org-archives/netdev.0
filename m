From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 1/2] ipv6: addrconf: don't use rtnl mutex in RTM_GETNETCONF
Date: Wed, 11 Oct 2017 10:28:00 +0200
Message-ID: <20171011082801.12715-2-fw@strlen.de>
References: <20171011082801.12715-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:38990 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757275AbdJKI1r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 04:27:47 -0400
In-Reply-To: <20171011082801.12715-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of relying on rtnl mutex bump device reference count.
After this change, values reported can change in parallel, but thats not
much different from current state, as anyone can change the settings
right after rtnl_unlock (and before userspace processed reply).

While at it, switch to GFP_KERNEL allocation.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/addrconf.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d9f6226694eb..5207f567ef28 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -616,23 +616,23 @@ static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct nlattr *tb[NETCONFA_MAX+1];
+	struct inet6_dev *in6_dev = NULL;
+	struct net_device *dev = NULL;
 	struct netconfmsg *ncm;
 	struct sk_buff *skb;
 	struct ipv6_devconf *devconf;
-	struct inet6_dev *in6_dev;
-	struct net_device *dev;
 	int ifindex;
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ncm), tb, NETCONFA_MAX,
 			  devconf_ipv6_policy, extack);
 	if (err < 0)
-		goto errout;
+		return err;
 
-	err = -EINVAL;
 	if (!tb[NETCONFA_IFINDEX])
-		goto errout;
+		return -EINVAL;
 
+	err = -EINVAL;
 	ifindex = nla_get_s32(tb[NETCONFA_IFINDEX]);
 	switch (ifindex) {
 	case NETCONFA_IFINDEX_ALL:
@@ -642,10 +642,10 @@ static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
 		devconf = net->ipv6.devconf_dflt;
 		break;
 	default:
-		dev = __dev_get_by_index(net, ifindex);
+		dev = dev_get_by_index(net, ifindex);
 		if (!dev)
-			goto errout;
-		in6_dev = __in6_dev_get(dev);
+			return -EINVAL;
+		in6_dev = in6_dev_get(dev);
 		if (!in6_dev)
 			goto errout;
 		devconf = &in6_dev->cnf;
@@ -653,7 +653,7 @@ static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
 	}
 
 	err = -ENOBUFS;
-	skb = nlmsg_new(inet6_netconf_msgsize_devconf(NETCONFA_ALL), GFP_ATOMIC);
+	skb = nlmsg_new(inet6_netconf_msgsize_devconf(NETCONFA_ALL), GFP_KERNEL);
 	if (!skb)
 		goto errout;
 
@@ -669,6 +669,10 @@ static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
 	}
 	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
 errout:
+	if (in6_dev)
+		in6_dev_put(in6_dev);
+	if (dev)
+		dev_put(dev);
 	return err;
 }
 
@@ -6570,7 +6574,7 @@ int __init addrconf_init(void)
 	__rtnl_register(PF_INET6, RTM_GETANYCAST, NULL,
 			inet6_dump_ifacaddr, 0);
 	__rtnl_register(PF_INET6, RTM_GETNETCONF, inet6_netconf_get_devconf,
-			inet6_netconf_dump_devconf, 0);
+			inet6_netconf_dump_devconf, RTNL_FLAG_DOIT_UNLOCKED);
 
 	ipv6_addr_label_rtnl_register();
 
-- 
2.13.6
