From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: gre: correct calculation of max_headroom
Date: Sun, 29 Sep 2013 05:40:50 +0200
Message-ID: <20130929034050.GB8602@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: xeb@mail.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57847 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564Ab3I2Dkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 23:40:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gre_hlen already accounts for sizeof(struct ipv6_hdr) + gre header,
so initialize max_headroom to zero. Otherwise the

	if (encap_limit >= 0) {
		max_headroom += 8;
		mtu -= 8;
	}

increments an uninitialized variable before max_headroom was reset.

Found with coverity: 728539

Cc: Dmitry Kozlov <xeb@mail.ru>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_gre.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 6b26e9f..7bb5446 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -618,7 +618,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	struct ip6_tnl *tunnel = netdev_priv(dev);
 	struct net_device *tdev;    /* Device to other host */
 	struct ipv6hdr  *ipv6h;     /* Our new IP header */
-	unsigned int max_headroom;  /* The extra header space needed */
+	unsigned int max_headroom = 0; /* The extra header space needed */
 	int    gre_hlen;
 	struct ipv6_tel_txoption opt;
 	int    mtu;
@@ -693,7 +693,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 
 	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(dev)));
 
-	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen + dst->header_len;
+	max_headroom += LL_RESERVED_SPACE(tdev) + gre_hlen + dst->header_len;
 
 	if (skb_headroom(skb) < max_headroom || skb_shared(skb) ||
 	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
-- 
1.8.3.1
