From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: speedup tcp_fixup_rcvbuf()
Date: Wed, 15 May 2013 22:25:55 -0700
Message-ID: <1368681955.3301.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:33237 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329Ab3EPFZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 01:25:57 -0400
Received: by mail-da0-f48.google.com with SMTP id h32so1424040dak.35
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 22:25:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_fixup_rcvbuf() contains a loop to estimate initial socket
rcv space needed for a given mss. With large MTU (like 64K on lo),
we can loop ~500 times and consume a lot of cpu cycles.

perf top of 200 concurrent netperf -t TCP_CRR

5.62%  netperf  [kernel.kallsyms]  [k] tcp_init_buffer_space
1.71%  netperf  [kernel.kallsyms]  [k] _raw_spin_lock
1.55%  netperf  [kernel.kallsyms]  [k] kmem_cache_free
1.51%  netperf  [kernel.kallsyms]  [k] tcp_transmit_skb
1.50%  netperf  [kernel.kallsyms]  [k] tcp_ack

Lets use a 100% factor, and remove the loop.

100% is needed anyway for tcp_adv_win_scale=1
default value, and is also the maximum factor.

Refs: commit b49960a05e32 
      ("tcp: change tcp_adv_win_scale and tcp_rmem[2]")

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 08bbe60..b358e8c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -360,9 +360,7 @@ static void tcp_fixup_rcvbuf(struct sock *sk)
 	if (mss > 1460)
 		icwnd = max_t(u32, (1460 * TCP_DEFAULT_INIT_RCVWND) / mss, 2);
 
-	rcvmem = SKB_TRUESIZE(mss + MAX_TCP_HEADER);
-	while (tcp_win_from_space(rcvmem) < mss)
-		rcvmem += 128;
+	rcvmem = 2 * SKB_TRUESIZE(mss + MAX_TCP_HEADER);
 
 	rcvmem *= icwnd;
 
