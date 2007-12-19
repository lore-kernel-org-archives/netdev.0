From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-2.6.25 19/19] [NETNS] Enable routing configuration in non-initial namespace.
Date: Wed, 19 Dec 2007 18:24:49 +0300
Message-ID: <1198077889-10693-20-git-send-email-den@openvz.org>
References: <4769370F.5020303@openvz.org>
Cc: benjamin.thery@bull.net, dlezcano@fr.ibm.com, devel@openvz.org,
	containers@lists.osdl.org, netdev@vger.kernel.org, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:50601 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754892AbXLSPXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 10:23:17 -0500
In-Reply-To: <4769370F.5020303@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I.e. remove the net != &init_net checks from the places, that now can handle
other-than-init net namespace.

Acked-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/fib_frontend.c |   24 ++++--------------------
 1 files changed, 4 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index a5c47fc..a5e2fb3 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -572,9 +572,6 @@ static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *ar
 	struct fib_table *tb;
 	int err;
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	err = rtm_to_fib_config(net, skb, nlh, &cfg);
 	if (err < 0)
 		goto errout;
@@ -597,9 +594,6 @@ static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *ar
 	struct fib_table *tb;
 	int err;
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	err = rtm_to_fib_config(net, skb, nlh, &cfg);
 	if (err < 0)
 		goto errout;
@@ -625,9 +619,6 @@ static int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 	struct hlist_head *head;
 	int dumped = 0;
 
-	if (net != &init_net)
-		return 0;
-
 	if (nlmsg_len(cb->nlh) >= sizeof(struct rtmsg) &&
 	    ((struct rtmsg *) nlmsg_data(cb->nlh))->rtm_flags & RTM_F_CLONED)
 		return ip_rt_dump(skb, cb);
@@ -931,9 +922,6 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
 	struct net_device *dev = ptr;
 	struct in_device *in_dev = __in_dev_get_rtnl(dev);
 
-	if (dev->nd_net != &init_net)
-		return NOTIFY_DONE;
-
 	if (event == NETDEV_UNREGISTER) {
 		fib_disable_ip(dev, 2);
 		return NOTIFY_DONE;
@@ -1013,10 +1001,6 @@ static int __net_init fib_net_init(struct net *net)
 {
 	int error;
 
-	error = 0;
-	if (net != &init_net)
-		goto out;
-
 	error = ip_fib_net_init(net);
 	if (error < 0)
 		goto out;
-- 
1.5.3.rc5

