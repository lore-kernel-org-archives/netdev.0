From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 4/8] net: ipv4: Convert inet_rtm_getroute to rcu versions of route lookup
Date: Wed, 24 May 2017 11:19:07 -0700
Message-ID: <1495649951-30417-5-git-send-email-roopa@cumulusnetworks.com>
References: <1495649951-30417-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        nikolay@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33552 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933795AbdEXSTU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 14:19:20 -0400
Received: by mail-pf0-f177.google.com with SMTP id e193so143308290pfh.0
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 11:19:20 -0700 (PDT)
In-Reply-To: <1495649951-30417-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>

Convert inet_rtm_getroute to use ip_route_input_rcu and
ip_route_output_key_hash_rcu passing the fib_result arg to both.
The rcu lock is held through the creation of the response, so the
rtable/dst does not need to be attached to the skb and is passed
to rt_fill_info directly.

In converting from ip_route_output_key to ip_route_output_key_hash_rcu
the xfrm_lookup_route in ip_route_output_flow is dropped since
flowi4_proto is not set for a route get request.

Signed-off-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/ipv4/route.c | 25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9699e9b..6e0bd40 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2404,7 +2404,7 @@ struct rtable *ip_route_output_key_hash_rcu(struct net *net, struct flowi4 *fl4,
 		}
 
 		/* L3 master device is the loopback for that domain */
-		dev_out = l3mdev_master_dev_rcu(FIB_RES_DEV(res)) ? :
+		dev_out = l3mdev_master_dev_rcu(FIB_RES_DEV(*res)) ? :
 			net->loopback_dev;
 		fl4->flowi4_oif = dev_out->ifindex;
 		flags |= RTCF_LOCAL;
@@ -2435,7 +2435,7 @@ struct rtable *ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 	res.table	= NULL;
 
 	rcu_read_lock();
-	rth = ip_route_output_key_hash_rcu(net, fl4, &res, mp_hash);
+	rth = ip_route_output_key_hash_rcu(net, fl4, skb, &res);
 	rcu_read_unlock();
 
 	return rth;
@@ -2534,11 +2534,11 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 }
 EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
+/* called with rcu_read_lock held */
 static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 			struct flowi4 *fl4, struct sk_buff *skb, u32 portid,
-			u32 seq)
+			u32 seq, struct rtable *rt)
 {
-	struct rtable *rt = skb_rtable(skb);
 	struct rtmsg *r;
 	struct nlmsghdr *nlh;
 	unsigned long expires = 0;
@@ -2653,6 +2653,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 	struct net *net = sock_net(in_skb->sk);
 	struct rtmsg *rtm;
 	struct nlattr *tb[RTA_MAX+1];
+	struct fib_result res = {};
 	struct rtable *rt = NULL;
 	struct flowi4 fl4;
 	__be32 dst = 0;
@@ -2709,10 +2710,12 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 	fl4.flowi4_mark = mark;
 	fl4.flowi4_uid = uid;
 
+	rcu_read_lock();
+
 	if (iif) {
 		struct net_device *dev;
 
-		dev = __dev_get_by_index(net, iif);
+		dev = dev_get_by_index_rcu(net, iif);
 		if (!dev) {
 			err = -ENODEV;
 			goto errout_free;
@@ -2721,14 +2724,14 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 		skb->protocol	= htons(ETH_P_IP);
 		skb->dev	= dev;
 		skb->mark	= mark;
-		err = ip_route_input(skb, dst, src, rtm->rtm_tos, dev);
+		err = ip_route_input_rcu(skb, dst, src, rtm->rtm_tos,
+					 dev, &res);
 
 		rt = skb_rtable(skb);
 		if (err == 0 && rt->dst.error)
 			err = -rt->dst.error;
 	} else {
-		rt = ip_route_output_key(net, &fl4);
-
+		rt = ip_route_output_key_hash_rcu(net, &fl4, skb, &res);
 		err = 0;
 		if (IS_ERR(rt))
 			err = PTR_ERR(rt);
@@ -2737,7 +2740,6 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 	if (err)
 		goto errout_free;
 
-	skb_dst_set(skb, &rt->dst);
 	if (rtm->rtm_flags & RTM_F_NOTIFY)
 		rt->rt_flags |= RTCF_NOTIFY;
 
@@ -2745,15 +2747,18 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 		table_id = rt->rt_table_id;
 
 	err = rt_fill_info(net, dst, src, table_id, &fl4, skb,
-			   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq);
+			   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq, rt);
 	if (err < 0)
 		goto errout_free;
 
+	rcu_read_unlock();
+
 	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
 errout:
 	return err;
 
 errout_free:
+	rcu_read_unlock();
 	kfree_skb(skb);
 	goto errout;
 }
-- 
1.9.1
