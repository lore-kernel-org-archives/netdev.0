From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH] bridge: mcast snooping, fix IPv6 MLD checksum calculation
Date: Sun, 27 Mar 2011 08:27:23 +0200
Message-ID: <1301207244-10428-2-git-send-email-linus.luessing@web.de>
References: <20110327034404.GC31916@Sellars>
 <1301207244-10428-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org,
	=?utf-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:50390 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373Ab1C0G1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 02:27:35 -0400
In-Reply-To: <1301207244-10428-1-git-send-email-linus.luessing@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In contrast to IGMP, the MLDv1/2 message checksum needs to include an
IPv6 "pseudo-header" in the calculations (see RFC2710, section 3.3;
RFC3810, section 5.1.2).

The multicast snooping feature of the bridge code however did not take
this "pseudo-header" into consideration for the checksum validation whe=
n
parsing a snooped IPv6 MLDv1/2 message of another host, leading to
possibly ignored, though valid MLDv1/2 messages. This commit shall fix
this issue.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index f61eb2e..47fae4f 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1525,7 +1525,10 @@ static int br_multicast_ipv6_rcv(struct net_brid=
ge *br,
 			break;
 		/*FALLTHROUGH*/
 	case CHECKSUM_NONE:
-		skb2->csum =3D 0;
+		skb2->csum =3D ~csum_unfold(csum_ipv6_magic(&ip6h->saddr,
+							  &ip6h->daddr,
+							  skb2->len,
+							  nexthdr, 0));
 		if (skb_checksum_complete(skb2))
 			goto out;
 	}
--=20
1.5.6.5

