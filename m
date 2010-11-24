From: Anders Franzen <anders.franzen@ericsson.com>
Subject: [PATCH] Make the ip6_tunnel reflect the true mtu.
Date: Wed, 24 Nov 2010 16:47:18 +0100
Message-ID: <1290613638-8700-1-git-send-email-anders.franzen@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<davem@davemloft.net>, Anders Franzen <anders.franzen@ericsson.com>
To: <vnuorval@tcs.hut.fi>, <kozakai@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:61114 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930Ab0KXPrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 10:47:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ip6_tunnel always assumes it consumes 40 bytes (ip6 hdr) of the mtu of the
underlaying device. So for a normal ethernet bearer, the mtu of the ip6_tunnel is
1460.
However, when creating a tunnel the encap limit option is enabled by default, and it
consumes 8 bytes more, so the true mtu shall be 1452.

I dont really know if this breaks some statement in some RFC, so this is a request for
comments.

Signed-off-by: Anders Franzen <anders.franzen@ericsson.com>
---
 net/ipv6/ip6_tunnel.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2a59610..df948e8 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1175,6 +1175,8 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 				sizeof (struct ipv6hdr);
 
 			dev->mtu = rt->rt6i_dev->mtu - sizeof (struct ipv6hdr);
+			if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
+				dev->mtu-=8;
 
 			if (dev->mtu < IPV6_MIN_MTU)
 				dev->mtu = IPV6_MIN_MTU;
@@ -1363,12 +1365,17 @@ static const struct net_device_ops ip6_tnl_netdev_ops = {
 
 static void ip6_tnl_dev_setup(struct net_device *dev)
 {
+	struct ip6_tnl *t = NULL;
+
 	dev->netdev_ops = &ip6_tnl_netdev_ops;
 	dev->destructor = ip6_dev_free;
 
 	dev->type = ARPHRD_TUNNEL6;
 	dev->hard_header_len = LL_MAX_HEADER + sizeof (struct ipv6hdr);
 	dev->mtu = ETH_DATA_LEN - sizeof (struct ipv6hdr);
+	t = netdev_priv(dev);
+	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
+		dev->mtu-=8;
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
 	dev->features |= NETIF_F_NETNS_LOCAL;
-- 
1.7.2.3

