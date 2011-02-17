From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH 2/2] bridge: Use IPv6 link-local address for multicast listener queries
Date: Thu, 17 Feb 2011 19:17:52 +0100
Message-ID: <1297966672-3457-3-git-send-email-linus.luessing@web.de>
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
Received: from fmmailgate02.web.de ([217.72.192.227]:43558 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757432Ab1BQSSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 13:18:01 -0500
In-Reply-To: <20110215154128.2a28632c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the bridge multicast snooping feature periodically issues
IPv6 general multicast listener queries to sense the absence of a
listener.

=46or this, it uses :: as its source address - however RFC 2710 require=
s:
"To be valid, the Query message MUST come from a link-local IPv6 Source
Address". Current Linux kernel versions seem to follow this requirement
and ignore our bogus MLD queries.

With this commit a link local address from the bridge interface is bein=
g
used to issue the MLD query, resulting in other Linux devices which are
multicast listeners in the network to respond with a MLD response (whic=
h
was not the case before).

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index f904a2e..2d88861 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -446,7 +446,8 @@ static struct sk_buff *br_ip6_multicast_alloc_query=
(struct net_bridge *br,
 	ip6h->payload_len =3D htons(8 + sizeof(*mldq));
 	ip6h->nexthdr =3D IPPROTO_HOPOPTS;
 	ip6h->hop_limit =3D 1;
-	ipv6_addr_set(&ip6h->saddr, 0, 0, 0, 0);
+	ipv6_dev_get_saddr(dev_net(br->dev), br->dev, &ip6h->daddr, 0,
+			   &ip6h->saddr);
 	ipv6_addr_set(&ip6h->daddr, htonl(0xff020000), 0, 0, htonl(1));
 	ipv6_eth_mc_map(&ip6h->daddr, eth->h_dest);
=20
--=20
1.7.2.3

