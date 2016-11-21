From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next v2 2/2] tcp: make undo_cwnd mandatory for congestion modules
Date: Mon, 21 Nov 2016 14:18:38 +0100
Message-ID: <1479734318-30607-3-git-send-email-fw@strlen.de>
References: <1479734318-30607-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:38106 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754563AbcKUNS0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 08:18:26 -0500
In-Reply-To: <1479734318-30607-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The undo_cwnd fallback in the stack doubles cwnd based on ssthresh,
which un-does reno halving behaviour.

It seems more appropriate to let congctl algorithms pair .ssthresh
and .undo_cwnd properly. Add a 'tcp_reno_undo_cwnd' function and wire it
up for all congestion algorithms that used to rely on the fallback.

Cc: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Changes since v1:
  - only use tcp_reno_undo_cwnd in algorithms that use
  tcp_reno_ssthresh.  The other algorithms that did not
  meet this requirement were changed in patch 1 of this
  series.

 include/net/tcp.h       |  1 +
 net/ipv4/tcp_cong.c     | 14 ++++++++++++--
 net/ipv4/tcp_dctcp.c    |  1 +
 net/ipv4/tcp_hybla.c    |  1 +
 net/ipv4/tcp_input.c    |  5 +----
 net/ipv4/tcp_lp.c       |  1 +
 net/ipv4/tcp_vegas.c    |  1 +
 net/ipv4/tcp_westwood.c |  1 +
 8 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 123979fe12bf..7de80739adab 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -958,6 +958,7 @@ u32 tcp_slow_start(struct tcp_sock *tp, u32 acked);
 void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w, u32 acked);
 
 u32 tcp_reno_ssthresh(struct sock *sk);
+u32 tcp_reno_undo_cwnd(struct sock *sk);
 void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked);
 extern struct tcp_congestion_ops tcp_reno;
 
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index f9038d6b109e..79c4817abc94 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -68,8 +68,9 @@ int tcp_register_congestion_control(struct tcp_congestion_ops *ca)
 {
 	int ret = 0;
 
-	/* all algorithms must implement ssthresh and cong_avoid ops */
-	if (!ca->ssthresh || !(ca->cong_avoid || ca->cong_control)) {
+	/* all algorithms must implement these */
+	if (!ca->ssthresh || !ca->undo_cwnd ||
+	    !(ca->cong_avoid || ca->cong_control)) {
 		pr_err("%s does not implement required ops\n", ca->name);
 		return -EINVAL;
 	}
@@ -443,10 +444,19 @@ u32 tcp_reno_ssthresh(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(tcp_reno_ssthresh);
 
+u32 tcp_reno_undo_cwnd(struct sock *sk)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+
+	return max(tp->snd_cwnd, tp->snd_ssthresh << 1);
+}
+EXPORT_SYMBOL_GPL(tcp_reno_undo_cwnd);
+
 struct tcp_congestion_ops tcp_reno = {
 	.flags		= TCP_CONG_NON_RESTRICTED,
 	.name		= "reno",
 	.owner		= THIS_MODULE,
 	.ssthresh	= tcp_reno_ssthresh,
 	.cong_avoid	= tcp_reno_cong_avoid,
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 };
diff --git a/net/ipv4/tcp_dctcp.c b/net/ipv4/tcp_dctcp.c
index 51139175bf61..bde22ebb92a8 100644
--- a/net/ipv4/tcp_dctcp.c
+++ b/net/ipv4/tcp_dctcp.c
@@ -342,6 +342,7 @@ static struct tcp_congestion_ops dctcp __read_mostly = {
 static struct tcp_congestion_ops dctcp_reno __read_mostly = {
 	.ssthresh	= tcp_reno_ssthresh,
 	.cong_avoid	= tcp_reno_cong_avoid,
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 	.get_info	= dctcp_get_info,
 	.owner		= THIS_MODULE,
 	.name		= "dctcp-reno",
diff --git a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
index 083831e359df..0f7175c3338e 100644
--- a/net/ipv4/tcp_hybla.c
+++ b/net/ipv4/tcp_hybla.c
@@ -166,6 +166,7 @@ static void hybla_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 static struct tcp_congestion_ops tcp_hybla __read_mostly = {
 	.init		= hybla_init,
 	.ssthresh	= tcp_reno_ssthresh,
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 	.cong_avoid	= hybla_cong_avoid,
 	.set_state	= hybla_state,
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a70046fea0e8..22e6a2097ff6 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2394,10 +2394,7 @@ static void tcp_undo_cwnd_reduction(struct sock *sk, bool unmark_loss)
 	if (tp->prior_ssthresh) {
 		const struct inet_connection_sock *icsk = inet_csk(sk);
 
-		if (icsk->icsk_ca_ops->undo_cwnd)
-			tp->snd_cwnd = icsk->icsk_ca_ops->undo_cwnd(sk);
-		else
-			tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh << 1);
+		tp->snd_cwnd = icsk->icsk_ca_ops->undo_cwnd(sk);
 
 		if (tp->prior_ssthresh > tp->snd_ssthresh) {
 			tp->snd_ssthresh = tp->prior_ssthresh;
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index c67ece1390c2..046fd3910873 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -316,6 +316,7 @@ static void tcp_lp_pkts_acked(struct sock *sk, const struct ack_sample *sample)
 static struct tcp_congestion_ops tcp_lp __read_mostly = {
 	.init = tcp_lp_init,
 	.ssthresh = tcp_reno_ssthresh,
+	.undo_cwnd = tcp_reno_undo_cwnd,
 	.cong_avoid = tcp_lp_cong_avoid,
 	.pkts_acked = tcp_lp_pkts_acked,
 
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 4c4bac1b5eab..218cfcc77650 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -307,6 +307,7 @@ EXPORT_SYMBOL_GPL(tcp_vegas_get_info);
 static struct tcp_congestion_ops tcp_vegas __read_mostly = {
 	.init		= tcp_vegas_init,
 	.ssthresh	= tcp_reno_ssthresh,
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 	.cong_avoid	= tcp_vegas_cong_avoid,
 	.pkts_acked	= tcp_vegas_pkts_acked,
 	.set_state	= tcp_vegas_state,
diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index 4b03a2e2a050..fed66dc0e0f5 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -278,6 +278,7 @@ static struct tcp_congestion_ops tcp_westwood __read_mostly = {
 	.init		= tcp_westwood_init,
 	.ssthresh	= tcp_reno_ssthresh,
 	.cong_avoid	= tcp_reno_cong_avoid,
+	.undo_cwnd      = tcp_reno_undo_cwnd,
 	.cwnd_event	= tcp_westwood_event,
 	.in_ack_event	= tcp_westwood_ack,
 	.get_info	= tcp_westwood_info,
-- 
2.7.3
