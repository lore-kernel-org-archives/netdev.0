From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH v2 net-next 13/16] tcp: allow congestion control to expand send buffer differently
Date: Sat, 17 Sep 2016 13:35:46 -0400
Message-ID: <1474133749-12895-14-git-send-email-ncardwell@google.com>
References: <1474133749-12895-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
        Van Jacobson <vanj@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34279 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754274AbcIQRgb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 13:36:31 -0400
Received: by mail-qk0-f181.google.com with SMTP id h8so109673363qka.1
        for <netdev@vger.kernel.org>; Sat, 17 Sep 2016 10:36:31 -0700 (PDT)
In-Reply-To: <1474133749-12895-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>

Currently the TCP send buffer expands to twice cwnd, in order to allow
limited transmits in the CA_Recovery state. This assumes that cwnd
does not increase in the CA_Recovery.

For some congestion control algorithms, like the upcoming BBR module,
if the losses in recovery do not indicate congestion then we may
continue to raise cwnd multiplicatively in recovery. In such cases the
current multiplier will falsely limit the sending rate, much as if it
were limited by the application.

This commit adds an optional congestion control callback to use a
different multiplier to expand the TCP send buffer. For congestion
control modules that do not specificy this callback, TCP continues to
use the previous default of 2.

Signed-off-by: Van Jacobson <vanj@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/net/tcp.h    | 2 ++
 net/ipv4/tcp_input.c | 4 +++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3492041..1aa9628 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -917,6 +917,8 @@ struct tcp_congestion_ops {
 	void (*pkts_acked)(struct sock *sk, const struct ack_sample *sample);
 	/* suggest number of segments for each skb to transmit (optional) */
 	u32 (*tso_segs_goal)(struct sock *sk);
+	/* returns the multiplier used in tcp_sndbuf_expand (optional) */
+	u32 (*sndbuf_expand)(struct sock *sk);
 	/* get info for inet_diag (optional) */
 	size_t (*get_info)(struct sock *sk, u32 ext, int *attr,
 			   union tcp_cc_info *info);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index df26af0..a134e66 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -289,6 +289,7 @@ static bool tcp_ecn_rcv_ecn_echo(const struct tcp_sock *tp, const struct tcphdr
 static void tcp_sndbuf_expand(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_congestion_ops *ca_ops = inet_csk(sk)->icsk_ca_ops;
 	int sndmem, per_mss;
 	u32 nr_segs;
 
@@ -309,7 +310,8 @@ static void tcp_sndbuf_expand(struct sock *sk)
 	 * Cubic needs 1.7 factor, rounded to 2 to include
 	 * extra cushion (application might react slowly to POLLOUT)
 	 */
-	sndmem = 2 * nr_segs * per_mss;
+	sndmem = ca_ops->sndbuf_expand ? ca_ops->sndbuf_expand(sk) : 2;
+	sndmem *= nr_segs * per_mss;
 
 	if (sk->sk_sndbuf < sndmem)
 		sk->sk_sndbuf = min(sndmem, sysctl_tcp_wmem[2]);
-- 
2.8.0.rc3.226.g39d4020
