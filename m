From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: use correct req pointer in tcp_move_syn() calls
Date: Thu, 05 Nov 2015 12:50:19 -0800
Message-ID: <1446756619.4184.57.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1446750433.4184.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446755819.4184.52.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Ying Cai <ycai@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35464 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336AbbKEUuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 15:50:21 -0500
Received: by pasz6 with SMTP id z6so101563644pas.2
        for <netdev@vger.kernel.org>; Thu, 05 Nov 2015 12:50:20 -0800 (PST)
In-Reply-To: <1446755819.4184.52.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I mistakenly took wrong request sock pointer when calling tcp_move_syn()

@req_unhash is either a copy of @req, or a NULL value for
FastOpen connexions (as we do not expect to unhash the temporary
request sock from ehash table)

Fixes: 805c4bc05705 ("tcp: fix req->saved_syn race")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ying Cai <ycai@google.com>
---
 net/ipv4/tcp_ipv4.c |    2 +-
 net/ipv6/tcp_ipv6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 59aff63b1776..950e28c0cdf2 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1327,7 +1327,7 @@ struct sock *tcp_v4_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 		goto put_and_exit;
 	*own_req = inet_ehash_nolisten(newsk, req_to_sk(req_unhash));
 	if (*own_req)
-		tcp_move_syn(newtp, req_unhash);
+		tcp_move_syn(newtp, req);
 
 	return newsk;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c509e5562429..5baa8e754e41 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1141,7 +1141,7 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 	}
 	*own_req = inet_ehash_nolisten(newsk, req_to_sk(req_unhash));
 	if (*own_req) {
-		tcp_move_syn(newtp, req_unhash);
+		tcp_move_syn(newtp, req);
 
 		/* Clone pktoptions received with SYN, if we own the req */
 		if (ireq->pktopts) {
