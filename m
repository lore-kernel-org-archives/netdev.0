From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Fix regression caused by efe4208 in
 udp_v6_mcast_next()
Date: Mon, 26 May 2014 21:03:14 -0700
Message-ID: <1401163394.5367.235.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.LNX.2.11.1405251611020.22222@titan.int.lan.stealer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Sven Wegener <sven.wegener@stealer.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:60157 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbaE0EDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 00:03:16 -0400
Received: by mail-pb0-f53.google.com with SMTP id md12so8536799pbc.12
        for <netdev@vger.kernel.org>; Mon, 26 May 2014 21:03:16 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.11.1405251611020.22222@titan.int.lan.stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-05-25 at 16:14 +0200, Sven Wegener wrote:
> Commit efe4208 ("ipv6: make lookups simpler and faster") introduced a
> regression in udp_v6_mcast_next(), resulting in multicast packets not
> reaching the destination sockets under certain conditions.
> 
> The packet's IPv6 addresses are wrongly compared to the IPv6 addresses
> from the function's socket argument, which indicates the starting point
> for looping, instead of the loop variable. If the addresses from the
> first socket do not match the packet's addresses, no socket in the list
> will match.
> 
> Fix this by shrinking the function to use one variable for the socket to
> avoid confusion in the future.

Thanks for fixing this bug.

Please do not mix a cleanup and a fix in same patch, especially for
a stable candidate.

Your fix is obvious when reduced to this :

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1e586d92260e..20b63d2ab70f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -716,15 +716,15 @@ static struct sock *udp_v6_mcast_next(struct net *net, struct sock *sk,
 				if (inet->inet_dport != rmt_port)
 					continue;
 			}
-			if (!ipv6_addr_any(&sk->sk_v6_daddr) &&
-			    !ipv6_addr_equal(&sk->sk_v6_daddr, rmt_addr))
+			if (!ipv6_addr_any(&s->sk_v6_daddr) &&
+			    !ipv6_addr_equal(&s->sk_v6_daddr, rmt_addr))
 				continue;
 
 			if (s->sk_bound_dev_if && s->sk_bound_dev_if != dif)
 				continue;
 
-			if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
-				if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, loc_addr))
+			if (!ipv6_addr_any(&s->sk_v6_rcv_saddr)) {
+				if (!ipv6_addr_equal(&s->sk_v6_rcv_saddr, loc_addr))
 					continue;
 			}
 			if (!inet6_mc_check(s, loc_addr, rmt_addr))
