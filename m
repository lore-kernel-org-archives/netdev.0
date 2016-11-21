From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next 1/2] tcp: add cwnd_undo functions to various tcp cc algorithms
Date: Mon, 21 Nov 2016 14:18:37 +0100
Message-ID: <1479734318-30607-2-git-send-email-fw@strlen.de>
References: <1479734318-30607-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:38104 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754546AbcKUNSZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 08:18:25 -0500
In-Reply-To: <1479734318-30607-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

congestion control algorithms that do not halve cwnd in their .ssthresh
should provide a .cwnd_undo rather than rely on current fallback which
assumes reno halving (and thus doubles the cwnd).

All of these do 'something else' in their .ssthresh implementation, thus
store the cwnd on loss and provide .undo_cwnd to restore it again.

A followup patch will remove the fallback and all algorithms will
need to provide a .cwnd_undo function.

Signed-off-by: Florian Westphal <fw@strlen.de>
---

 net/ipv4/tcp_highspeed.c | 11 ++++++++++-
 net/ipv4/tcp_illinois.c  | 10 ++++++++++
 net/ipv4/tcp_scalable.c  | 15 +++++++++++++++
 net/ipv4/tcp_veno.c      | 10 ++++++++++
 net/ipv4/tcp_yeah.c      | 10 ++++++++++
 5 files changed, 55 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_highspeed.c b/net/ipv4/tcp_highspeed.c
index db7842495a64..6d9879e93648 100644
--- a/net/ipv4/tcp_highspeed.c
+++ b/net/ipv4/tcp_highspeed.c
@@ -94,6 +94,7 @@ static const struct hstcp_aimd_val {
 
 struct hstcp {
 	u32	ai;
+	u32	loss_cwnd;
 };
 
 static void hstcp_init(struct sock *sk)
@@ -150,16 +151,24 @@ static void hstcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 static u32 hstcp_ssthresh(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
-	const struct hstcp *ca = inet_csk_ca(sk);
+	struct hstcp *ca = inet_csk_ca(sk);
 
+	ca->loss_cwnd = tp->snd_cwnd;
 	/* Do multiplicative decrease */
 	return max(tp->snd_cwnd - ((tp->snd_cwnd * hstcp_aimd_vals[ca->ai].md) >> 8), 2U);
 }
 
+static u32 hstcp_cwnd_undo(struct sock *sk)
+{
+	const struct hstcp *ca = inet_csk_ca(sk);
+
+	return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
+}
 
 static struct tcp_congestion_ops tcp_highspeed __read_mostly = {
 	.init		= hstcp_init,
 	.ssthresh	= hstcp_ssthresh,
+	.undo_cwnd	= hstcp_cwnd_undo,
 	.cong_avoid	= hstcp_cong_avoid,
 
 	.owner		= THIS_MODULE,
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index c8e6d86be114..60352ff4f5a8 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -48,6 +48,7 @@ struct illinois {
 	u32	end_seq;	/* right edge of current RTT */
 	u32	alpha;		/* Additive increase */
 	u32	beta;		/* Muliplicative decrease */
+	u32	loss_cwnd;	/* cwnd on loss */
 	u16	acked;		/* # packets acked by current ACK */
 	u8	rtt_above;	/* average rtt has gone above threshold */
 	u8	rtt_low;	/* # of rtts measurements below threshold */
@@ -296,10 +297,18 @@ static u32 tcp_illinois_ssthresh(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct illinois *ca = inet_csk_ca(sk);
 
+	ca->loss_cwnd = tp->snd_cwnd;
 	/* Multiplicative decrease */
 	return max(tp->snd_cwnd - ((tp->snd_cwnd * ca->beta) >> BETA_SHIFT), 2U);
 }
 
+static u32 tcp_illinois_cwnd_undo(struct sock *sk)
+{
+	const struct illinois *ca = inet_csk_ca(sk);
+
+	return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
+}
+
 /* Extract info for Tcp socket info provided via netlink. */
 static size_t tcp_illinois_info(struct sock *sk, u32 ext, int *attr,
 				union tcp_cc_info *info)
@@ -327,6 +336,7 @@ static size_t tcp_illinois_info(struct sock *sk, u32 ext, int *attr,
 static struct tcp_congestion_ops tcp_illinois __read_mostly = {
 	.init		= tcp_illinois_init,
 	.ssthresh	= tcp_illinois_ssthresh,
+	.undo_cwnd	= tcp_illinois_cwnd_undo,
 	.cong_avoid	= tcp_illinois_cong_avoid,
 	.set_state	= tcp_illinois_state,
 	.get_info	= tcp_illinois_info,
diff --git a/net/ipv4/tcp_scalable.c b/net/ipv4/tcp_scalable.c
index bf5ea9e9bbc1..f2123075ce6e 100644
--- a/net/ipv4/tcp_scalable.c
+++ b/net/ipv4/tcp_scalable.c
@@ -15,6 +15,10 @@
 #define TCP_SCALABLE_AI_CNT	50U
 #define TCP_SCALABLE_MD_SCALE	3
 
+struct scalable {
+	u32 loss_cwnd;
+};
+
 static void tcp_scalable_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -32,12 +36,23 @@ static void tcp_scalable_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 static u32 tcp_scalable_ssthresh(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
+	struct scalable *ca = inet_csk_ca(sk);
+
+	ca->loss_cwnd = tp->snd_cwnd;
 
 	return max(tp->snd_cwnd - (tp->snd_cwnd>>TCP_SCALABLE_MD_SCALE), 2U);
 }
 
+static u32 tcp_scalable_cwnd_undo(struct sock *sk)
+{
+	const struct scalable *ca = inet_csk_ca(sk);
+
+	return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
+}
+
 static struct tcp_congestion_ops tcp_scalable __read_mostly = {
 	.ssthresh	= tcp_scalable_ssthresh,
+	.undo_cwnd	= tcp_scalable_cwnd_undo,
 	.cong_avoid	= tcp_scalable_cong_avoid,
 
 	.owner		= THIS_MODULE,
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index 40171e163cff..76005d4b8dfc 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -30,6 +30,7 @@ struct veno {
 	u32 basertt;		/* the min of all Veno rtt measurements seen (in usec) */
 	u32 inc;		/* decide whether to increase cwnd */
 	u32 diff;		/* calculate the diff rate */
+	u32 loss_cwnd;		/* cwnd when loss occured */
 };
 
 /* There are several situations when we must "re-start" Veno:
@@ -193,6 +194,7 @@ static u32 tcp_veno_ssthresh(struct sock *sk)
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct veno *veno = inet_csk_ca(sk);
 
+	veno->loss_cwnd = tp->snd_cwnd;
 	if (veno->diff < beta)
 		/* in "non-congestive state", cut cwnd by 1/5 */
 		return max(tp->snd_cwnd * 4 / 5, 2U);
@@ -201,9 +203,17 @@ static u32 tcp_veno_ssthresh(struct sock *sk)
 		return max(tp->snd_cwnd >> 1U, 2U);
 }
 
+static u32 tcp_veno_cwnd_undo(struct sock *sk)
+{
+	const struct veno *veno = inet_csk_ca(sk);
+
+	return max(tcp_sk(sk)->snd_cwnd, veno->loss_cwnd);
+}
+
 static struct tcp_congestion_ops tcp_veno __read_mostly = {
 	.init		= tcp_veno_init,
 	.ssthresh	= tcp_veno_ssthresh,
+	.undo_cwnd	= tcp_veno_cwnd_undo,
 	.cong_avoid	= tcp_veno_cong_avoid,
 	.pkts_acked	= tcp_veno_pkts_acked,
 	.set_state	= tcp_veno_state,
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index 9c5fc973267f..e6ff99c4bd3b 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -37,6 +37,7 @@ struct yeah {
 	u32 fast_count;
 
 	u32 pkts_acked;
+	u32 loss_cwnd;
 };
 
 static void tcp_yeah_init(struct sock *sk)
@@ -219,13 +220,22 @@ static u32 tcp_yeah_ssthresh(struct sock *sk)
 
 	yeah->fast_count = 0;
 	yeah->reno_count = max(yeah->reno_count>>1, 2U);
+	yeah->loss_cwnd = tp->snd_cwnd;
 
 	return max_t(int, tp->snd_cwnd - reduction, 2);
 }
 
+static u32 tcp_yeah_cwnd_undo(struct sock *sk)
+{
+	const struct yeah *yeah = inet_csk_ca(sk);
+
+	return max(tcp_sk(sk)->snd_cwnd, yeah->loss_cwnd);
+}
+
 static struct tcp_congestion_ops tcp_yeah __read_mostly = {
 	.init		= tcp_yeah_init,
 	.ssthresh	= tcp_yeah_ssthresh,
+	.undo_cwnd      = tcp_yeah_cwnd_undo,
 	.cong_avoid	= tcp_yeah_cong_avoid,
 	.set_state	= tcp_vegas_state,
 	.cwnd_event	= tcp_vegas_cwnd_event,
-- 
2.7.3
