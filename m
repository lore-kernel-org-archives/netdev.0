From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] icmp: No need to call sk_write_space()
Date: Fri, 25 Sep 2009 00:16:51 +0200
Message-ID: <4ABBEFD3.6060407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39024 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbZIXWQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 18:16:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can make icmp messages tx completion callback a litle bit faster.

Setting SOCK_USE_WRITE_QUEUE sk flag tells sock_wfree() to
not call sk_write_space() on a socket we know no thread is posssibly
waiting for write space. (on per cpu kernel internal icmp sockets only)

This avoids the sock_def_write_space() call and 
read_lock(&sk->sk_callback_lock)/read_unlock(&sk->sk_callback_lock) calls
as well.

We avoid three atomic ops.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 5bc13fe..84adb57 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -1165,6 +1165,10 @@ static int __net_init icmp_sk_init(struct net *net)
 		sk->sk_sndbuf =
 			(2 * ((64 * 1024) + sizeof(struct sk_buff)));
 
+		/*
+		 * Speedup sock_wfree()
+		 */
+		sock_set_flag(sk, SOCK_USE_WRITE_QUEUE);
 		inet_sk(sk)->pmtudisc = IP_PMTUDISC_DONT;
 	}
 
