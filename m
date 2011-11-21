From: kaber@trash.net
Subject: [PATCH 10/17] netfilter: ipv6: expand skb head in ip6_route_me_harder after oif change
Date: Mon, 21 Nov 2011 06:46:02 +0100
Message-ID: <1321854369-3432-11-git-send-email-kaber@trash.net>
References: <1321854369-3432-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61107 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474Ab1KUFrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 00:47:46 -0500
In-Reply-To: <1321854369-3432-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Expand the skb headroom if the oif changed due to rerouting similar to
how IPv4 packets are handled.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 30fcee4..d39e954 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -14,6 +14,7 @@ int ip6_route_me_harder(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	unsigned int hh_len;
 	struct dst_entry *dst;
 	struct flowi6 fl6 = {
 		.flowi6_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0,
@@ -46,6 +47,12 @@ int ip6_route_me_harder(struct sk_buff *skb)
 	}
 #endif
 
+	/* Change in oif may mean change in hh_len. */
+	hh_len = skb_dst(skb)->dev->hard_header_len;
+	if (skb_headroom(skb) < hh_len &&
+	    pskb_expand_head(skb, hh_len - skb_headroom(skb), 0, GFP_ATOMIC))
+		return -1;
+
 	return 0;
 }
 EXPORT_SYMBOL(ip6_route_me_harder);
-- 
1.7.1
