From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH] bridge: Fix possibly wrong MLD queries' ethernet source address
Date: Tue, 22 Mar 2011 22:40:32 +0100
Message-ID: <1300830032-6727-2-git-send-email-linus.luessing@web.de>
References: <4D80BC5B0200007800036D85@vpn.id2.novell.com>
 <1300830032-6727-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <shemminger@linux-foundation.org>,
	<bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
	=?utf-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: Jan Beulich <JBeulich@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:54524 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755364Ab1CVVkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 17:40:53 -0400
In-Reply-To: <1300830032-6727-1-git-send-email-linus.luessing@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipv6_dev_get_saddr() is currently called with an uninitialized
destination address. Although in tests it usually seemed to nevertheles=
s
always fetch the right source address, there seems to be a possible rac=
e
condition.

Therefore this commit changes this, first setting the destination
address and only after that fetching the source address.

Reported-by: Jan Beulich <JBeulich@novell.com>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 030a002..f61eb2e 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -445,9 +445,9 @@ static struct sk_buff *br_ip6_multicast_alloc_query=
(struct net_bridge *br,
 	ip6h->payload_len =3D htons(8 + sizeof(*mldq));
 	ip6h->nexthdr =3D IPPROTO_HOPOPTS;
 	ip6h->hop_limit =3D 1;
+	ipv6_addr_set(&ip6h->daddr, htonl(0xff020000), 0, 0, htonl(1));
 	ipv6_dev_get_saddr(dev_net(br->dev), br->dev, &ip6h->daddr, 0,
 			   &ip6h->saddr);
-	ipv6_addr_set(&ip6h->daddr, htonl(0xff020000), 0, 0, htonl(1));
 	ipv6_eth_mc_map(&ip6h->daddr, eth->h_dest);
=20
 	hopopt =3D (u8 *)(ip6h + 1);
--=20
1.5.6.5

