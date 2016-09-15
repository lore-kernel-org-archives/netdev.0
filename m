From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix overflow in __tcp_retransmit_skb()
Date: Thu, 15 Sep 2016 08:12:33 -0700
Message-ID: <1473952353.22679.25.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33721 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751570AbcIOPMg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 11:12:36 -0400
Received: by mail-pa0-f65.google.com with SMTP id oz2so2225049pac.0
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:12:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If a TCP socket gets a large write queue, an overflow can happen
in a test in __tcp_retransmit_skb() preventing all retransmits.

The flow then stalls and resets after timeouts.

Tested:

sysctl -w net.core.wmem_max=1000000000
netperf -H dest -- -s 1000000000

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bdaef7fd6e47..f53d0cca5fa4 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2605,7 +2605,8 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs)
 	 * copying overhead: fragmentation, tunneling, mangling etc.
 	 */
 	if (atomic_read(&sk->sk_wmem_alloc) >
-	    min(sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2), sk->sk_sndbuf))
+	    min_t(u32, sk->sk_wmem_queued + (sk->sk_wmem_queued >> 2),
+		  sk->sk_sndbuf))
 		return -EAGAIN;
 
 	if (skb_still_in_host_queue(sk, skb))
