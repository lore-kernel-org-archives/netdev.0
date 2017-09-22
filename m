From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 06/11] ip/route: factor out helper for local route creation
Date: Fri, 22 Sep 2017 23:06:30 +0200
Message-ID: <49b182d5f4690cff36a3aa6cbe06d7b3565eda54.1506114055.git.pabeni@redhat.com>
References: <cover.1506114055.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37322 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752710AbdIVVHI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 17:07:08 -0400
In-Reply-To: <cover.1506114055.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will be used by a later patch to build the ifaddr dst cache.
No functional changes are introduced here.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/route.h |  2 ++
 net/ipv4/route.c    | 30 ++++++++++++++++++++++--------
 2 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 1b09a9368c68..ec09c3d73581 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -176,6 +176,8 @@ static inline struct rtable *ip_route_output_gre(struct net *net, struct flowi4
 	return ip_route_output_key(net, fl4);
 }
 
+struct rtable *ip_local_route_alloc(struct net_device *dev, unsigned int flags,
+				    u32 itag, unsigned char type, bool docache);
 int ip_route_input_noref(struct sk_buff *skb, __be32 dst, __be32 src,
 			 u8 tos, struct net_device *devin);
 int ip_route_input_rcu(struct sk_buff *skb, __be32 dst, __be32 src,
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 94d4cd2d5ea4..515589f1b3d1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1859,6 +1859,27 @@ static int ip_mkroute_input(struct sk_buff *skb,
 	return __mkroute_input(skb, res, in_dev, daddr, saddr, tos);
 }
 
+struct rtable *ip_local_route_alloc(struct net_device *dev, unsigned int flags,
+				    u32 itag, unsigned char type, bool do_cache)
+{
+	struct in_device *in_dev = __in_dev_get_rcu(dev);
+	struct net *net = dev_net(dev);
+	struct rtable *rth;
+
+	rth = rt_dst_alloc(l3mdev_master_dev_rcu(dev) ? : net->loopback_dev,
+			   flags | RTCF_LOCAL, type,
+			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, do_cache);
+	if (!rth)
+		return NULL;
+
+	rth->dst.output= ip_rt_bug;
+#ifdef CONFIG_IP_ROUTE_CLASSID
+	rth->dst.tclassid = itag;
+#endif
+	rth->rt_is_input = 1;
+	return rth;
+}
+
 /*
  *	NOTE. We drop all the packets that has local source
  *	addresses, because every properly looped back packet
@@ -1996,17 +2017,10 @@ out:	return err;
 		}
 	}
 
-	rth = rt_dst_alloc(l3mdev_master_dev_rcu(dev) ? : net->loopback_dev,
-			   flags | RTCF_LOCAL, res->type,
-			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, do_cache);
+	rth = ip_local_route_alloc(dev, flags, itag, res->type, do_cache);
 	if (!rth)
 		goto e_nobufs;
 
-	rth->dst.output= ip_rt_bug;
-#ifdef CONFIG_IP_ROUTE_CLASSID
-	rth->dst.tclassid = itag;
-#endif
-	rth->rt_is_input = 1;
 	if (res->table)
 		rth->rt_table_id = res->table->tb_id;
 
-- 
2.13.5
