From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: tcp: fix race in IPV6_2292PKTOPTIONS
Date: Wed, 21 Jan 2015 03:45:42 -0800
Message-ID: <1421840742.4832.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:50167 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbbAULpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 06:45:45 -0500
Received: by mail-ig0-f181.google.com with SMTP id hn18so7898092igb.2
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 03:45:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

IPv6 TCP sockets store in np->pktoptions skbs, and use skb_set_owner_r()
to charge the skb to socket.

It means that destructor must be called while socket is locked.

Therefore, we cannot use skb_get() or atomic_inc(&skb->users)
to protect ourselves : kfree_skb() might race with other users
manipulating sk->sk_forward_alloc

Fix this race by holding socket lock for the duration of
ip6_datagram_recv_ctl()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 Since this bug is very old, feel free to apply on net-next ;)

 net/ipv6/ipv6_sockglue.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 66980d8d98d1f5b3ef7a50dc33cb9b617f25604d..8d766d9100cba408525faf5818b7b0c6b6bc543c 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -996,13 +996,9 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		lock_sock(sk);
 		skb = np->pktoptions;
 		if (skb)
-			atomic_inc(&skb->users);
-		release_sock(sk);
-
-		if (skb) {
 			ip6_datagram_recv_ctl(sk, &msg, skb);
-			kfree_skb(skb);
-		} else {
+		release_sock(sk);
+		if (!skb) {
 			if (np->rxopt.bits.rxinfo) {
 				struct in6_pktinfo src_info;
 				src_info.ipi6_ifindex = np->mcast_oif ? np->mcast_oif :
