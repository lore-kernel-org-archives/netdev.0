From: Ulrich Weber <ulrich.weber@sophos.com>
Subject: [PATCH] bridge: check return value of ipv6_dev_get_saddr()
Date: Mon, 5 Mar 2012 15:52:44 +0100
Message-ID: <20120305145244.GA10621@WS-uweber>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx5.sophos.com ([213.31.172.35]:50812 "EHLO mx5.sophos.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932150Ab2CEPAm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 10:00:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

otherwise source IPv6 address of ICMPV6_MGM_QUERY packet
might be random junk if IPv6 is disabled on interface or
link-local address is not yet ready (DAD).

Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
---
 net/bridge/br_multicast.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 568d5bf..702a1ae 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -446,8 +446,11 @@ static struct sk_buff *br_ip6_multicast_alloc_query(struct net_bridge *br,
 	ip6h->nexthdr = IPPROTO_HOPOPTS;
 	ip6h->hop_limit = 1;
 	ipv6_addr_set(&ip6h->daddr, htonl(0xff020000), 0, 0, htonl(1));
-	ipv6_dev_get_saddr(dev_net(br->dev), br->dev, &ip6h->daddr, 0,
-			   &ip6h->saddr);
+	if (ipv6_dev_get_saddr(dev_net(br->dev), br->dev, &ip6h->daddr, 0,
+			       &ip6h->saddr)) {
+		kfree_skb(skb);
+		return NULL;
+	}
 	ipv6_eth_mc_map(&ip6h->daddr, eth->h_dest);
 
 	hopopt = (u8 *)(ip6h + 1);
-- 
1.7.4.1
