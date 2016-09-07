From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fastopen: avoid negative sk_forward_alloc
Date: Wed, 07 Sep 2016 08:34:11 -0700
Message-ID: <1473262451.10725.43.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Josh Hunt <johunt@akamai.com>,
        Jerry Chu <hkchu@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36066 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753974AbcIGPeM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 11:34:12 -0400
Received: by mail-pf0-f196.google.com with SMTP id x24so1108264pfa.3
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 08:34:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When DATA and/or FIN are carried in a SYN/ACK message or SYN message,
we append an skb in socket receive queue, but we forget to call
sk_forced_mem_schedule().

Effect is that the socket has a negative sk->sk_forward_alloc as long as
the message is not read by the application.

Josh Hunt fixed a similar issue in commit d22e15371811 ("tcp: fix tcp
fin memory accounting")
 
Fixes: 168a8f58059a ("tcp: TCP Fast Open Server - main code path")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_fastopen.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 62a5751d4fe1..4e777a3243f9 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -150,6 +150,7 @@ void tcp_fastopen_add_skb(struct sock *sk, struct sk_buff *skb)
 	tp->segs_in = 0;
 	tcp_segs_in(tp, skb);
 	__skb_pull(skb, tcp_hdrlen(skb));
+	sk_forced_mem_schedule(sk, skb->truesize);
 	skb_set_owner_r(skb, sk);
 
 	TCP_SKB_CB(skb)->seq++;
