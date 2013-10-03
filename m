From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] tcp: rcvbuf autotuning improvements
Date: Thu,  3 Oct 2013 09:56:43 +0200
Message-ID: <1380787003-20488-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	Francesco Fusco <ffusco@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11086 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448Ab3JCH4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Oct 2013 03:56:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a complementary patch for commit 6ae705323 ("tcp: sndbuf
autotuning improvements") that fixes a performance regression on
receiver side in setups with low to mid latency, high throughput,
and senders with TSO/GSO off (receivers w/ default settings).

The following measurements in Mbit/s were done for 60sec w/ netperf
on virtio w/ TSO/GSO off:

(ms)    1)              2)              3)
  0     2762.11         1150.32         2906.17
 10     1083.61          538.89         1091.03
 25      471.81          313.18          474.60
 50      242.33          187.84          242.36
 75      162.14          134.45          161.95
100      121.55          101.96          121.49
150       80.64           57.75           80.48
200       58.97           54.11           59.90
250       47.10           46.92           47.31

Same setup w/ TSO/GSO on:

(ms)    1)              2)              3)
  0     12225.91        12366.89        16514.37
 10      1526.64         1525.79         2176.63
 25       655.13          647.79          871.52
 50       338.51          377.88          439.46
 75       246.49          278.46          295.62
100       210.93          207.56          217.34
150       127.88          129.56          141.33
200        94.95           94.50          107.29
250        67.39           73.88           88.35

Similarly as in 6ae705323, we fixed up power-of-two rounding and
took cached mss into account, thus bringing per_mss calculations
closer to each other, the rest stays as is.

We also renamed tcp_fixup_rcvbuf() to tcp_rcvbuf_expand() to be
consistent with tcp_sndbuf_expand().

While we do think that 6ae705323b71 is the right way to go, also
this follow-up seems necessary to restore performance for
receivers.

For the evaluation, same kernels on each host were used:

1) net-next (4fbef95af), which is before 6ae705323
2) net-next (6ae705323), which is sndbuf improvements
3) net-next (6ae705323), plus this patch on top

This was done in joint work with Francesco Fusco.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Francesco Fusco <ffusco@redhat.com>
---
 net/ipv4/tcp_input.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cd65674..ed37b1d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -367,13 +367,19 @@ static void tcp_grow_window(struct sock *sk, const struct sk_buff *skb)
 }
 
 /* 3. Tuning rcvbuf, when connection enters established state. */
-static void tcp_fixup_rcvbuf(struct sock *sk)
+static void tcp_rcvbuf_expand(struct sock *sk)
 {
-	u32 mss = tcp_sk(sk)->advmss;
-	int rcvmem;
+	const struct tcp_sock *tp = tcp_sk(sk);
+	int rcvmem, per_mss;
+
+	per_mss = max_t(u32, tp->advmss, tp->mss_cache) +
+		  MAX_TCP_HEADER +
+		  SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+
+	per_mss = roundup_pow_of_two(per_mss) +
+		  SKB_DATA_ALIGN(sizeof(struct sk_buff));
 
-	rcvmem = 2 * SKB_TRUESIZE(mss + MAX_TCP_HEADER) *
-		 tcp_default_init_rwnd(mss);
+	rcvmem = 2 * tcp_default_init_rwnd(per_mss) * per_mss;
 
 	/* Dynamic Right Sizing (DRS) has 2 to 3 RTT latency
 	 * Allow enough cushion so that sender is not limited by our window
@@ -394,7 +400,7 @@ void tcp_init_buffer_space(struct sock *sk)
 	int maxwin;
 
 	if (!(sk->sk_userlocks & SOCK_RCVBUF_LOCK))
-		tcp_fixup_rcvbuf(sk);
+		tcp_rcvbuf_expand(sk);
 	if (!(sk->sk_userlocks & SOCK_SNDBUF_LOCK))
 		tcp_sndbuf_expand(sk);
 
-- 
1.7.11.7
