From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] tcp: make undo_cwnd mandatory for congestion modules
Date: Thu, 17 Nov 2016 13:56:51 +0100
Message-ID: <1479387411-9830-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:55674 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753719AbcKQSSv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 13:18:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The undo_cwnd fallback in the stack doubles cwnd based on ssthresh,
which un-does reno halving behaviour.

It seems more appropriate to let congctl algorithms pair .ssthresh
and .undo_cwnd properly. Add a 'tcp_reno_undo_cwnd' function and wire it
up for all congestion algorithms that used to rely on the fallback.

highspeed, illinois, scalable, veno and yeah use 'reno undo' while their
.ssthresh implementation doesn't halve the slowstart threshold, this
might point to similar issue as the one fixed for dctcp in
ce6dd23329b1e ("dctcp: avoid bogus doubling of cwnd after loss").

Cc: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/tcp.h        |  1 +
 net/ipv4/tcp_cong.c      | 14 ++++++++++++--
 net/ipv4/tcp_dctcp.c     |  1 +
 net/ipv4/tcp_highspeed.c |  2 +-
 net/ipv4/tcp_hybla.c     |  1 +
 net/ipv4/tcp_illinois.c  |  1 +
 net/ipv4/tcp_input.c     |  5 +----
 net/ipv4/tcp_lp.c        |  1 +
 net/ipv4/tcp_scalable.c  |  1 +
 net/ipv4/tcp_vegas.c     |  1 +
 net/ipv4/tcp_veno.c      |  1 +
 net/ipv4/tcp_westwood.c  |  1 +
 net/ipv4/tcp_yeah.c      |  1 +
 13 files changed, 24 insertions(+), 7 deletions(-)

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
index 1294af4e0127..38905ec5f508 100644
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
@@ -441,10 +442,19 @@ u32 tcp_reno_ssthresh(struct sock *sk)
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
diff --git a/net/ipv4/tcp_highspeed.c b/net/ipv4/tcp_highspeed.c
index db7842495a64..1eb8fefd9bd0 100644
--- a/net/ipv4/tcp_highspeed.c
+++ b/net/ipv4/tcp_highspeed.c
@@ -161,7 +161,7 @@ static struct tcp_congestion_ops tcp_highspeed __read_mostly = {
 	.init		= hstcp_init,
 	.ssthresh	= hstcp_ssthresh,
 	.cong_avoid	= hstcp_cong_avoid,
-
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 	.owner		= THIS_MODULE,
 	.name		= "highspeed"
 };
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
 
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index c8e6d86be114..7c843578f233 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -327,6 +327,7 @@ static size_t tcp_illinois_info(struct sock *sk, u32 ext, int *attr,
 static struct tcp_congestion_ops tcp_illinois __read_mostly = {
 	.init		= tcp_illinois_init,
 	.ssthresh	= tcp_illinois_ssthresh,
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 	.cong_avoid	= tcp_illinois_cong_avoid,
 	.set_state	= tcp_illinois_state,
 	.get_info	= tcp_illinois_info,
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
 
diff --git a/net/ipv4/tcp_scalable.c b/net/ipv4/tcp_scalable.c
index bf5ea9e9bbc1..addc122f8818 100644
--- a/net/ipv4/tcp_scalable.c
+++ b/net/ipv4/tcp_scalable.c
@@ -38,6 +38,7 @@ static u32 tcp_scalable_ssthresh(struct sock *sk)
 
 static struct tcp_congestion_ops tcp_scalable __read_mostly = {
 	.ssthresh	= tcp_scalable_ssthresh,
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 	.cong_avoid	= tcp_scalable_cong_avoid,
 
 	.owner		= THIS_MODULE,
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
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index 40171e163cff..6fcf482d611b 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -204,6 +204,7 @@ static u32 tcp_veno_ssthresh(struct sock *sk)
 static struct tcp_congestion_ops tcp_veno __read_mostly = {
 	.init		= tcp_veno_init,
 	.ssthresh	= tcp_veno_ssthresh,
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 	.cong_avoid	= tcp_veno_cong_avoid,
 	.pkts_acked	= tcp_veno_pkts_acked,
 	.set_state	= tcp_veno_state,
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
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index 9c5fc973267f..56ed4257c706 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -226,6 +226,7 @@ static u32 tcp_yeah_ssthresh(struct sock *sk)
 static struct tcp_congestion_ops tcp_yeah __read_mostly = {
 	.init		= tcp_yeah_init,
 	.ssthresh	= tcp_yeah_ssthresh,
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 	.cong_avoid	= tcp_yeah_cong_avoid,
 	.set_state	= tcp_vegas_state,
 	.cwnd_event	= tcp_vegas_cwnd_event,
-- 
2.7.3
