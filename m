From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] inet: fix possible request socket leak
Date: Mon, 10 Aug 2015 15:07:34 -0700
Message-ID: <1439244454.1084.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35808 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932741AbbHJWHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 18:07:36 -0400
Received: by pacgr6 with SMTP id gr6so35336128pac.2
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 15:07:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit b357a364c57c9 ("inet: fix possible panic in
reqsk_queue_unlink()"), I missed fact that tcp_check_req()
can return the listener socket in one case, and that we must
release the request socket refcount or we leak it.

Tested:

 Following packetdrill test template shows the issue

0     socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0    setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0    bind(3, ..., ...) = 0
+0    listen(3, 1) = 0

+0    < S 0:0(0) win 2920 <mss 1460,sackOK,nop,nop>
+0    > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK>
+.002 < . 1:1(0) ack 21 win 2920
+0    > R 21:21(0)

Fixes: b357a364c57c9 ("inet: fix possible panic in reqsk_queue_unlink()")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c |    2 +-
 net/ipv6/tcp_ipv6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d7d4c2b79cf2..0ea2e1c5d395 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1348,7 +1348,7 @@ static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 	req = inet_csk_search_req(sk, th->source, iph->saddr, iph->daddr);
 	if (req) {
 		nsk = tcp_check_req(sk, skb, req, false);
-		if (!nsk)
+		if (!nsk || nsk == sk)
 			reqsk_put(req);
 		return nsk;
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6748c4277aff..7a6cea5e4274 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -943,7 +943,7 @@ static struct sock *tcp_v6_hnd_req(struct sock *sk, struct sk_buff *skb)
 				   &ipv6_hdr(skb)->daddr, tcp_v6_iif(skb));
 	if (req) {
 		nsk = tcp_check_req(sk, skb, req, false);
-		if (!nsk)
+		if (!nsk || nsk == sk)
 			reqsk_put(req);
 		return nsk;
 	}
