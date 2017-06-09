From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next] bpf: Remove duplicate tcp_filter hook in ipv6
Date: Fri,  9 Jun 2017 12:17:37 -0700
Message-ID: <1497035857-9927-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33502 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751621AbdFITSz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 15:18:55 -0400
Received: by mail-pf0-f193.google.com with SMTP id f27so9474531pfe.0
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 12:18:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

There are two tcp_filter hooks in tcp_ipv6 ingress path currently.
One is at tcp_v6_rcv and another is in tcp_v6_do_rcv. It seems the
tcp_filter() call inside tcp_v6_do_rcv is redundent and some packet
will be filtered twice in this situation. This will cause trouble
when using eBPF filters to account traffic data.

Signed-off-by: Chenbo Feng <fengc@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/tcp_ipv6.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0840543..84ad502 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1249,9 +1249,6 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_do_rcv(sk, skb);
 
-	if (tcp_filter(sk, skb))
-		goto discard;
-
 	/*
 	 *	socket locking is here for SMP purposes as backlog rcv
 	 *	is currently called with bh processing disabled.
-- 
2.7.4
