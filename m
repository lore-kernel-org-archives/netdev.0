From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: RTA_MARK addition
Date: Wed, 21 Jul 2010 10:03:14 +0200
Message-ID: <1279699394.2452.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43748 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755065Ab0GUIDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 04:03:18 -0400
Received: by wwj40 with SMTP id 40so1947924wwj.1
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 01:03:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new rt attribute, RTA_MARK, and use it in
rt_fill_info()/inet_rtm_getroute() to support following commands :

ip route get 192.168.20.110 mark NUMBER
ip route get 192.168.20.108 from 192.168.20.110 iif eth1 mark NUMBER
ip route list cache [192.168.20.110] mark NUMBER

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/rtnetlink.h |    1 +
 net/ipv4/route.c          |    7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index fbc8cb0..58d4449 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -282,6 +282,7 @@ enum rtattr_type_t {
 	RTA_SESSION, /* no longer used */
 	RTA_MP_ALGO, /* no longer used */
 	RTA_TABLE,
+	RTA_MARK,
 	__RTA_MAX
 };
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 562ce92..3f56b6e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2878,6 +2878,9 @@ static int rt_fill_info(struct net *net,
 	if (rtnetlink_put_metrics(skb, rt->dst.metrics) < 0)
 		goto nla_put_failure;
 
+	if (rt->fl.mark)
+		NLA_PUT_BE32(skb, RTA_MARK, rt->fl.mark);
+
 	error = rt->dst.error;
 	expires = rt->dst.expires ? rt->dst.expires - jiffies : 0;
 	if (rt->peer) {
@@ -2933,6 +2936,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	__be32 src = 0;
 	u32 iif;
 	int err;
+	int mark;
 	struct sk_buff *skb;
 
 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv4_policy);
@@ -2960,6 +2964,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 	src = tb[RTA_SRC] ? nla_get_be32(tb[RTA_SRC]) : 0;
 	dst = tb[RTA_DST] ? nla_get_be32(tb[RTA_DST]) : 0;
 	iif = tb[RTA_IIF] ? nla_get_u32(tb[RTA_IIF]) : 0;
+	mark = tb[RTA_MARK] ? nla_get_u32(tb[RTA_MARK]) : 0;
 
 	if (iif) {
 		struct net_device *dev;
@@ -2972,6 +2977,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 
 		skb->protocol	= htons(ETH_P_IP);
 		skb->dev	= dev;
+		skb->mark	= mark;
 		local_bh_disable();
 		err = ip_route_input(skb, dst, src, rtm->rtm_tos, dev);
 		local_bh_enable();
@@ -2989,6 +2995,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void
 				},
 			},
 			.oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0,
+			.mark = mark,
 		};
 		err = ip_route_output_key(net, &rt, &fl);
 	}


