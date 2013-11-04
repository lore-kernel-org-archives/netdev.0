From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/20] bridge: netfilter: orphan skb before invoking ip netfilter hooks
Date: Mon,  4 Nov 2013 22:50:38 +0100
Message-ID: <1383601842-4570-17-git-send-email-pablo@netfilter.org>
References: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55736 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753819Ab3KDVvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 16:51:04 -0500
In-Reply-To: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Westphal <fw@strlen.de>

Pekka Pietik=C3=A4inen reports xt_socket behavioural change after commi=
t
00028aa37098o (netfilter: xt_socket: use IP early demux).

Reason is xt_socket now no longer does an unconditional sk lookup -
it re-uses existing skb->sk if possible, assuming ->sk was set by
ip early demux.

However, when netfilter is invoked via bridge, this can cause 'bogus'
sockets to be examined by the match, e.g. a 'tun' device socket.

bridge netfilter should orphan the skb just like the routing path
before invoking ipv4/ipv6 netfilter hooks to avoid this.

Reported-and-tested-by: Pekka Pietik=C3=A4inen <pp@ee.oulu.fi>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index f877362..3d55312 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -559,6 +559,8 @@ static struct net_device *setup_pre_routing(struct =
sk_buff *skb)
 	else if (skb->protocol =3D=3D htons(ETH_P_PPP_SES))
 		nf_bridge->mask |=3D BRNF_PPPoE;
=20
+	/* Must drop socket now because of tproxy. */
+	skb_orphan(skb);
 	return skb->dev;
 }
=20
--=20
1.7.10.4
