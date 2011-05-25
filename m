From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: hold rtnl again in dump callbacks
Date: Wed, 25 May 2011 19:34:04 +0200
Message-ID: <1306344844.11400.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40650 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441Ab1EYReK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 13:34:10 -0400
Received: by wya21 with SMTP id 21so5957893wya.19
        for <netdev@vger.kernel.org>; Wed, 25 May 2011 10:34:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e67f88dd12f6 (dont hold rtnl mutex during netlink dump callbacks)
missed fact that rtnl_fill_ifinfo() must be called with rtnl held.

Because of possible deadlocks between two mutexes (cb_mutex and rtnl),
its not easy to solve this problem, so revert this part of the patch.

It also forgot one rcu_read_unlock() in FIB dump_rules()

Add one ASSERT_RTNL() in rtnl_fill_ifinfo() to remind us the rule.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Stephen Hemminger <shemminger@vyatta.com>
---
I tried to solve this problem differently but failed. We need more
preliminary steps.

 net/core/fib_rules.c |    1 +
 net/core/rtnetlink.c |    9 +++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 3911586..008dc70 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -602,6 +602,7 @@ static int dump_rules(struct sk_buff *skb, struct netlink_callback *cb,
 skip:
 		idx++;
 	}
+	rcu_read_unlock();
 	cb->args[1] = idx;
 	rules_ops_put(ops);
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d1644e3..2d56cb9 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -850,6 +850,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	struct nlattr *attr, *af_spec;
 	struct rtnl_af_ops *af_ops;
 
+	ASSERT_RTNL();
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
@@ -1876,6 +1877,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int min_len;
 	int family;
 	int type;
+	int err;
 
 	type = nlh->nlmsg_type;
 	if (type > RTM_MAX)
@@ -1902,8 +1904,11 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (dumpit == NULL)
 			return -EOPNOTSUPP;
 
+		__rtnl_unlock();
 		rtnl = net->rtnl;
-		return netlink_dump_start(rtnl, skb, nlh, dumpit, NULL);
+		err = netlink_dump_start(rtnl, skb, nlh, dumpit, NULL);
+		rtnl_lock();
+		return err;
 	}
 
 	memset(rta_buf, 0, (rtattr_max * sizeof(struct rtattr *)));
@@ -1975,7 +1980,7 @@ static int __net_init rtnetlink_net_init(struct net *net)
 {
 	struct sock *sk;
 	sk = netlink_kernel_create(net, NETLINK_ROUTE, RTNLGRP_MAX,
-				   rtnetlink_rcv, NULL, THIS_MODULE);
+				   rtnetlink_rcv, &rtnl_mutex, THIS_MODULE);
 	if (!sk)
 		return -ENOMEM;
 	net->rtnl = sk;


