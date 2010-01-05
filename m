From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] net: packet: option to only pass skb protocol
Date: Tue, 5 Jan 2010 20:57:32 +0200
Message-ID: <20100105185732.GA30346@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50118 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753363Ab0AETAg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2010 14:00:36 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sending packets with a packet socket it is often necessary to set
protocol in msg_name: otherwise the protocol field in the skb will not
be set correctly.  However, currently doing this also requires
supplying the interface index.

The following patch makes it possible to avoid supplying the interface
index by interpreting index 0 as "use device this socket is bound to".

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/packet/af_packet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index e0516a2..a81dae8 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -958,7 +958,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 					+ offsetof(struct sockaddr_ll,
 						sll_addr)))
 			goto out;
-		ifindex	= saddr->sll_ifindex;
+		ifindex	= saddr->sll_ifindex ? : po->ifindex;
 		proto	= saddr->sll_protocol;
 		addr	= saddr->sll_addr;
 	}
@@ -1074,7 +1074,7 @@ static int packet_snd(struct socket *sock,
 			goto out;
 		if (msg->msg_namelen < (saddr->sll_halen + offsetof(struct sockaddr_ll, sll_addr)))
 			goto out;
-		ifindex	= saddr->sll_ifindex;
+		ifindex	= saddr->sll_ifindex ? : po->ifindex;
 		proto	= saddr->sll_protocol;
 		addr	= saddr->sll_addr;
 	}
-- 
1.6.6.rc1.43.gf55cc
