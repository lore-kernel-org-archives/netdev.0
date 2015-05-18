From: Henning Rogge <hrogge@gmail.com>
Subject: [PATCH] net/ipv6/udp: Fix ipv6 multicast socket filter regression
Date: Mon, 18 May 2015 21:08:49 +0200
Message-ID: <1431976129-28032-1-git-send-email-hrogge@gmail.com>
Cc: Henning Rogge <hrogge@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:33272 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754905AbbERTI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 15:08:58 -0400
Received: by wgjc11 with SMTP id c11so37925153wgj.0
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 12:08:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit <5cf3d46192fc> ("udp: Simplify__udp*_lib_mcast_deliver")
simplified the filter for incoming IPv6 multicast but removed
the check of the local socket address and the UDP destination
address.

This patch restores the filter to prevent sockets bound to a IPv6
multicast IP to receive other UDP traffic link unicast.

Signed-off-by: Henning Rogge <hrogge@gmail.com>
Fixes: 5cf3d46192fc ("udp: Simplify__udp*_lib_mcast_deliver")
Cc: "David S. Miller" <davem@davemloft.net>
---
The commit above was found by me with a git bisect. I think the
patch should be included into the stable kernel trees.
---
 net/ipv6/udp.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 3477c919fcc8..c2ec41617a35 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -731,7 +731,9 @@ static bool __udp_v6_is_mcast_sock(struct net *net, struct sock *sk,
 	    (inet->inet_dport && inet->inet_dport != rmt_port) ||
 	    (!ipv6_addr_any(&sk->sk_v6_daddr) &&
 		    !ipv6_addr_equal(&sk->sk_v6_daddr, rmt_addr)) ||
-	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
+	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif) ||
+	    (!ipv6_addr_any(&sk->sk_v6_rcv_saddr) &&
+		    !ipv6_addr_equal(&sk->sk_v6_rcv_saddr, loc_addr)))
 		return false;
 	if (!inet6_mc_check(sk, loc_addr, rmt_addr))
 		return false;
-- 
2.1.0
