From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 21/30] ipv6: Only compute net once in ip6_finish_output2
Date: Tue, 15 Sep 2015 20:04:09 -0500
Message-ID: <1442365458-16349-21-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv6/ip6_output.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a80502c64523..12d0166a64cd 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -60,6 +60,7 @@ static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *dev = dst->dev;
+	struct net *net = dev_net(dev);
 	struct neighbour *neigh;
 	struct in6_addr *nexthop;
 	int ret;
@@ -71,7 +72,7 @@ static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 
 		if (!(dev->flags & IFF_LOOPBACK) && sk_mc_loop(sk) &&
-		    ((mroute6_socket(dev_net(dev), skb) &&
+		    ((mroute6_socket(net, skb) &&
 		     !(IP6CB(skb)->flags & IP6SKB_FORWARDED)) ||
 		     ipv6_chk_mcast_addr(dev, &ipv6_hdr(skb)->daddr,
 					 &ipv6_hdr(skb)->saddr))) {
@@ -86,15 +87,14 @@ static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 					dev_loopback_xmit);
 
 			if (ipv6_hdr(skb)->hop_limit == 0) {
-				IP6_INC_STATS(dev_net(dev), idev,
+				IP6_INC_STATS(net, idev,
 					      IPSTATS_MIB_OUTDISCARDS);
 				kfree_skb(skb);
 				return 0;
 			}
 		}
 
-		IP6_UPD_PO_STATS(dev_net(dev), idev, IPSTATS_MIB_OUTMCAST,
-				skb->len);
+		IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUTMCAST, skb->len);
 
 		if (IPV6_ADDR_MC_SCOPE(&ipv6_hdr(skb)->daddr) <=
 		    IPV6_ADDR_SCOPE_NODELOCAL &&
@@ -116,8 +116,7 @@ static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 	}
 	rcu_read_unlock_bh();
 
-	IP6_INC_STATS(dev_net(dst->dev),
-		      ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
+	IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
 	return -EINVAL;
 }
-- 
2.2.1

