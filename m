From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ip6tnl: avoid touching dst refcount in ip6_tnl_xmit2()
Date: Thu, 28 Jul 2011 16:32:25 +0200
Message-ID: <1311863545.2346.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55419 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866Ab1G1Oc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 10:32:29 -0400
Received: by wyg8 with SMTP id 8so168934wyg.19
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2011 07:32:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even using percpu stats, we still hit tunnel dst_entry refcount in
ip6_tnl_xmit2()

Since we are in RCU locked section, we can use skb_dst_set_noref() and
avoid these atomic operations, leaving dst shared on cpus.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/ip6_tunnel.c |   27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 0bc9888..6fb1fb3 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -889,7 +889,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	struct net_device_stats *stats = &t->dev->stats;
 	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 	struct ipv6_tel_txoption opt;
-	struct dst_entry *dst;
+	struct dst_entry *dst, *ndst = NULL;
 	struct net_device *tdev;
 	int mtu;
 	unsigned int max_headroom = sizeof(struct ipv6hdr);
@@ -897,19 +897,19 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	int err = -1;
 	int pkt_len;
 
-	if ((dst = ip6_tnl_dst_check(t)) != NULL)
-		dst_hold(dst);
-	else {
-		dst = ip6_route_output(net, NULL, fl6);
+	dst = ip6_tnl_dst_check(t);
+	if (!dst) {
+		ndst = ip6_route_output(net, NULL, fl6);
 
-		if (dst->error)
+		if (ndst->error)
 			goto tx_err_link_failure;
-		dst = xfrm_lookup(net, dst, flowi6_to_flowi(fl6), NULL, 0);
-		if (IS_ERR(dst)) {
-			err = PTR_ERR(dst);
-			dst = NULL;
+		ndst = xfrm_lookup(net, ndst, flowi6_to_flowi(fl6), NULL, 0);
+		if (IS_ERR(ndst)) {
+			err = PTR_ERR(ndst);
+			ndst = NULL;
 			goto tx_err_link_failure;
 		}
+		dst = ndst;
 	}
 
 	tdev = dst->dev;
@@ -955,7 +955,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 		skb = new_skb;
 	}
 	skb_dst_drop(skb);
-	skb_dst_set(skb, dst_clone(dst));
+	skb_dst_set_noref(skb, dst);
 
 	skb->transport_header = skb->network_header;
 
@@ -987,13 +987,14 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 		stats->tx_errors++;
 		stats->tx_aborted_errors++;
 	}
-	ip6_tnl_dst_store(t, dst);
+	if (ndst)
+		ip6_tnl_dst_store(t, ndst);
 	return 0;
 tx_err_link_failure:
 	stats->tx_carrier_errors++;
 	dst_link_failure(skb);
 tx_err_dst_release:
-	dst_release(dst);
+	dst_release(ndst);
 	return err;
 }
 


