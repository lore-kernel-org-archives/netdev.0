From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 1/3] ipv6: fix route cache dump
Date: Tue, 17 Oct 2017 19:40:56 +0200
Message-ID: <e54ccbb0c97570a8c1a9c97a3c7bc8a910f02083.1508261949.git.pabeni@redhat.com>
References: <cover.1508261949.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37648 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757836AbdJQRvj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 13:51:39 -0400
In-Reply-To: <cover.1508261949.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the commit 2b760fcf5cfb ("ipv6: hook up exception table to
store dst cache"), entries in the routing cache are not shown by:

ip route show cache

because the per route exception table containing such routes is not
traversed by rt6_dump_route().
Fix it by explicitly dumping all routes present into the
rt6i_exception_bucket.

Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv6/route.c | 30 ++++++++++++++++++++++++++----
 1 file changed, 26 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 01a103c23a6c..5bb53dbd4fd3 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -4190,10 +4190,14 @@ static int rt6_fill_node(struct net *net,
 	return -EMSGSIZE;
 }
 
+/* this is called under the RCU lock */
 int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 {
 	struct rt6_rtnl_dump_arg *arg = (struct rt6_rtnl_dump_arg *) p_arg;
+	struct rt6_exception_bucket *bucket;
+	struct rt6_exception *rt6_ex;
 	struct net *net = arg->net;
+	int err, port_id, seq, i;
 
 	if (rt == net->ipv6.ip6_null_entry)
 		return 0;
@@ -4209,10 +4213,28 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 		}
 	}
 
-	return rt6_fill_node(net,
-		     arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
-		     NETLINK_CB(arg->cb->skb).portid, arg->cb->nlh->nlmsg_seq,
-		     NLM_F_MULTI);
+	/* dump execeptions table, if available */
+	port_id = NETLINK_CB(arg->cb->skb).portid;
+	seq = arg->cb->nlh->nlmsg_seq;
+	bucket = rcu_dereference(rt->rt6i_exception_bucket);
+	if (!bucket)
+		goto no_exceptions;
+
+	for (i = 0; i < FIB6_EXCEPTION_BUCKET_SIZE; i++) {
+		hlist_for_each_entry_rcu(rt6_ex, &bucket->chain, hlist) {
+			err = rt6_fill_node(net, arg->skb, rt6_ex->rt6i, NULL,
+					    NULL, 0, RTM_NEWROUTE, port_id, seq,
+					    NLM_F_MULTI);
+			if (err)
+				return err;
+		}
+
+		bucket++;
+	}
+
+no_exceptions:
+	return rt6_fill_node(net, arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
+			     port_id, seq, NLM_F_MULTI);
 }
 
 static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
-- 
2.13.6
