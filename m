From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH 1/2] bridge: Fix MLD queries' ethernet source address
Date: Thu, 17 Feb 2011 19:17:51 +0100
Message-ID: <1297966672-3457-2-git-send-email-linus.luessing@web.de>
References: <20110215154128.2a28632c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:54687 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757553Ab1BQSR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 13:17:59 -0500
In-Reply-To: <20110215154128.2a28632c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Map the IPv6 header's destination multicast address to an ethernet
source address instead of the MLD queries multicast address.

=46or instance for a general MLD query (multicast address in the MLD qu=
ery
set to ::), this would wrongly be mapped to 33:33:00:00:00:00, although
an MLD queries destination MAC should always be 33:33:00:00:00:01 which
matches the IPv6 header's multicast destination ff02::1.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index b5eb28a..f904a2e 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -435,7 +435,6 @@ static struct sk_buff *br_ip6_multicast_alloc_query=
(struct net_bridge *br,
 	eth =3D eth_hdr(skb);
=20
 	memcpy(eth->h_source, br->dev->dev_addr, 6);
-	ipv6_eth_mc_map(group, eth->h_dest);
 	eth->h_proto =3D htons(ETH_P_IPV6);
 	skb_put(skb, sizeof(*eth));
=20
@@ -449,6 +448,7 @@ static struct sk_buff *br_ip6_multicast_alloc_query=
(struct net_bridge *br,
 	ip6h->hop_limit =3D 1;
 	ipv6_addr_set(&ip6h->saddr, 0, 0, 0, 0);
 	ipv6_addr_set(&ip6h->daddr, htonl(0xff020000), 0, 0, htonl(1));
+	ipv6_eth_mc_map(&ip6h->daddr, eth->h_dest);
=20
 	hopopt =3D (u8 *)(ip6h + 1);
 	hopopt[0] =3D IPPROTO_ICMPV6;		/* next hdr */
--=20
1.7.2.3

