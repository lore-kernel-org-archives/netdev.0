From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: fix ip header ident selection in __ip_make_skb()
Date: Mon, 20 Aug 2012 19:26:45 +0200
Message-ID: <1345483605.5158.345.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Christian Casteyde <casteyde.christian@free.fr>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59606 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845Ab2HTR0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 13:26:51 -0400
Received: by bkwj10 with SMTP id j10so1937607bkw.19
        for <netdev@vger.kernel.org>; Mon, 20 Aug 2012 10:26:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Christian Casteyde reported a kmemcheck 32-bit read from uninitialized
memory in __ip_select_ident().

It turns out that __ip_make_skb() called ip_select_ident() before
properly initializing iph->daddr.

This is a bug uncovered by commit 1d861aa4b3fb (inet: Minimize use of
cached route inetpeer.)

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=46131

Reported-by: Christian Casteyde <casteyde.christian@free.fr>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
---
 net/ipv4/ip_output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 147ccc3..c196d74 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1338,10 +1338,10 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	iph->ihl = 5;
 	iph->tos = inet->tos;
 	iph->frag_off = df;
-	ip_select_ident(iph, &rt->dst, sk);
 	iph->ttl = ttl;
 	iph->protocol = sk->sk_protocol;
 	ip_copy_addrs(iph, fl4);
+	ip_select_ident(iph, &rt->dst, sk);
 
 	if (opt) {
 		iph->ihl += opt->optlen>>2;
