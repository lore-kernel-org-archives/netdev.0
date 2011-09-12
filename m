From: Florian Westphal <fw@strlen.de>
Subject: [RFC PATCH 2/5] net: ipv4: move ip_rcv route error counter handling into helper function
Date: Mon, 12 Sep 2011 21:42:29 +0200
Message-ID: <1315856552-1422-3-git-send-email-fw@strlen.de>
References: <1315856552-1422-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1315856552-1422-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This will avoid code duplication and messing with mib counters
in the planned netfilter reverse path filter match.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/ip.h    |    1 +
 net/ipv4/ip_input.c |   21 ++++++++++++---------
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index e9ea7c7..0001633 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -95,6 +95,7 @@ extern int		ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 					      struct ip_options_rcu *opt);
 extern int		ip_rcv(struct sk_buff *skb, struct net_device *dev,
 			       struct packet_type *pt, struct net_device *orig_dev);
+extern void		ip_rcv_inc_route_err_stats(struct net *net, int err);
 extern int		ip_local_deliver(struct sk_buff *skb);
 extern int		ip_mr_input(struct sk_buff *skb);
 extern int		ip_output(struct sk_buff *skb);
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index c8f48ef..43679f4 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -314,6 +314,17 @@ drop:
 	return -1;
 }
 
+void ip_rcv_inc_route_err_stats(struct net *net, int err)
+{
+	if (err == -EHOSTUNREACH)
+		IP_INC_STATS_BH(net, IPSTATS_MIB_INADDRERRORS);
+	else if (err == -ENETUNREACH)
+		IP_INC_STATS_BH(net, IPSTATS_MIB_INNOROUTES);
+	else if (err == -EXDEV)
+		NET_INC_STATS_BH(net, LINUX_MIB_IPRPFILTER);
+}
+EXPORT_SYMBOL_GPL(ip_rcv_inc_route_err_stats);
+
 static int ip_rcv_finish(struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
@@ -327,15 +338,7 @@ static int ip_rcv_finish(struct sk_buff *skb)
 		int err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
 					       iph->tos, skb->dev);
 		if (unlikely(err)) {
-			if (err == -EHOSTUNREACH)
-				IP_INC_STATS_BH(dev_net(skb->dev),
-						IPSTATS_MIB_INADDRERRORS);
-			else if (err == -ENETUNREACH)
-				IP_INC_STATS_BH(dev_net(skb->dev),
-						IPSTATS_MIB_INNOROUTES);
-			else if (err == -EXDEV)
-				NET_INC_STATS_BH(dev_net(skb->dev),
-						 LINUX_MIB_IPRPFILTER);
+			ip_rcv_inc_route_err_stats(dev_net(skb->dev), err);
 			goto drop;
 		}
 	}
-- 
1.7.3.4

