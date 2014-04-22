From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/2] gre: add x-netns support
Date: Tue, 22 Apr 2014 10:15:23 +0200
Message-ID: <1398154524-5928-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1398154524-5928-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, mzero@google.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:50000 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754468AbaDVIPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 04:15:44 -0400
In-Reply-To: <1398154524-5928-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to switch the netns when packet is encapsulated or
decapsulated. In other word, the encapsulated packet is received in a netns,
where the lookup is done to find the tunnel. Once the tunnel is found, the
packet is decapsulated and injecting into the corresponding interface which
stands to another netns.

When one of the two netns is removed, the tunnel is destroyed.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ip_gre.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 94213c891565..c5a557a06a31 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -410,7 +410,7 @@ static int ipgre_open(struct net_device *dev)
 		struct flowi4 fl4;
 		struct rtable *rt;
 
-		rt = ip_route_output_gre(dev_net(dev), &fl4,
+		rt = ip_route_output_gre(t->net, &fl4,
 					 t->parms.iph.daddr,
 					 t->parms.iph.saddr,
 					 t->parms.o_key,
@@ -434,7 +434,7 @@ static int ipgre_close(struct net_device *dev)
 
 	if (ipv4_is_multicast(t->parms.iph.daddr) && t->mlink) {
 		struct in_device *in_dev;
-		in_dev = inetdev_by_index(dev_net(dev), t->mlink);
+		in_dev = inetdev_by_index(t->net, t->mlink);
 		if (in_dev)
 			ip_mc_dec_group(in_dev, t->parms.iph.daddr);
 	}
@@ -478,7 +478,7 @@ static void __gre_tunnel_init(struct net_device *dev)
 	dev->needed_headroom	= LL_MAX_HEADER + sizeof(struct iphdr) + 4;
 	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr) - 4;
 
-	dev->features		|= NETIF_F_NETNS_LOCAL | GRE_FEATURES;
+	dev->features		|= GRE_FEATURES;
 	dev->hw_features	|= GRE_FEATURES;
 
 	if (!(tunnel->parms.o_flags & TUNNEL_SEQ)) {
-- 
1.9.0
