From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/6] [NETNS]: Process interface address manipulation routines in the namespace.
Date: Thu, 31 Jan 2008 15:00:47 +0300
Message-ID: <1201780850-22216-3-git-send-email-den@openvz.org>
References: <47A1B835.7050600@sw.ru>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:53023 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1764090AbYAaMAs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 07:00:48 -0500
In-Reply-To: <47A1B835.7050600@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The namespace is available when required except rtm_to_ifaddr. Add
namespace argument to it.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/devinet.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index e55c85e..6a6e92e 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -485,7 +485,7 @@ errout:
 	return err;
 }
 
-static struct in_ifaddr *rtm_to_ifaddr(struct nlmsghdr *nlh)
+static struct in_ifaddr *rtm_to_ifaddr(struct net *net, struct nlmsghdr *nlh)
 {
 	struct nlattr *tb[IFA_MAX+1];
 	struct in_ifaddr *ifa;
@@ -503,7 +503,7 @@ static struct in_ifaddr *rtm_to_ifaddr(struct nlmsghdr *nlh)
 	if (ifm->ifa_prefixlen > 32 || tb[IFA_LOCAL] == NULL)
 		goto errout;
 
-	dev = __dev_get_by_index(&init_net, ifm->ifa_index);
+	dev = __dev_get_by_index(net, ifm->ifa_index);
 	err = -ENODEV;
 	if (dev == NULL)
 		goto errout;
@@ -571,7 +571,7 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg
 	if (net != &init_net)
 		return -EINVAL;
 
-	ifa = rtm_to_ifaddr(nlh);
+	ifa = rtm_to_ifaddr(net, nlh);
 	if (IS_ERR(ifa))
 		return PTR_ERR(ifa);
 
@@ -1189,7 +1189,7 @@ static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 
 	s_ip_idx = ip_idx = cb->args[1];
 	idx = 0;
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev(net, dev) {
 		if (idx < s_idx)
 			goto cont;
 		if (idx > s_idx)
@@ -1223,7 +1223,9 @@ static void rtmsg_ifa(int event, struct in_ifaddr* ifa, struct nlmsghdr *nlh,
 	struct sk_buff *skb;
 	u32 seq = nlh ? nlh->nlmsg_seq : 0;
 	int err = -ENOBUFS;
+	struct net *net;
 
+	net = ifa->ifa_dev->dev->nd_net;
 	skb = nlmsg_new(inet_nlmsg_size(), GFP_KERNEL);
 	if (skb == NULL)
 		goto errout;
@@ -1235,10 +1237,10 @@ static void rtmsg_ifa(int event, struct in_ifaddr* ifa, struct nlmsghdr *nlh,
 		kfree_skb(skb);
 		goto errout;
 	}
-	err = rtnl_notify(skb, &init_net, pid, RTNLGRP_IPV4_IFADDR, nlh, GFP_KERNEL);
+	err = rtnl_notify(skb, net, pid, RTNLGRP_IPV4_IFADDR, nlh, GFP_KERNEL);
 errout:
 	if (err < 0)
-		rtnl_set_sk_err(&init_net, RTNLGRP_IPV4_IFADDR, err);
+		rtnl_set_sk_err(net, RTNLGRP_IPV4_IFADDR, err);
 }
 
 #ifdef CONFIG_SYSCTL
-- 
1.5.3.rc5

