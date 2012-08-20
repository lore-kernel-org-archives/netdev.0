From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 07/18] netfilter: ipv6: expand skb head in ip6_route_me_harder after oif change
Date: Mon, 20 Aug 2012 05:39:55 +0200
Message-ID: <1345434006-16549-8-git-send-email-kaber@trash.net>
References: <1345434006-16549-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345434006-16549-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Expand the skb headroom if the oif changed due to rerouting similar to
how IPv4 packets are handled.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index db31561..429089c 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -15,6 +15,7 @@ int ip6_route_me_harder(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	unsigned int hh_len;
 	struct dst_entry *dst;
 	struct flowi6 fl6 = {
 		.flowi6_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0,
@@ -47,6 +48,13 @@ int ip6_route_me_harder(struct sk_buff *skb)
 	}
 #endif
 
+	/* Change in oif may mean change in hh_len. */
+	hh_len = skb_dst(skb)->dev->hard_header_len;
+	if (skb_headroom(skb) < hh_len &&
+	    pskb_expand_head(skb, HH_DATA_ALIGN(hh_len - skb_headroom(skb)),
+			     0, GFP_ATOMIC))
+		return -1;
+
 	return 0;
 }
 EXPORT_SYMBOL(ip6_route_me_harder);
-- 
1.7.1

