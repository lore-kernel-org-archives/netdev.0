From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 2/2 v2 net-next] tcp: consolidate congestion control undo functions
Date: Thu,  3 Aug 2017 20:38:52 -0700
Message-ID: <20170804033852.97986-3-ycheng@google.com>
References: <20170804033852.97986-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, unlcsewsun@gmail.com,
        stephen@networkplumber.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35388 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751948AbdHDDjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 23:39:10 -0400
Received: by mail-pg0-f42.google.com with SMTP id v189so2700560pgd.2
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 20:39:10 -0700 (PDT)
In-Reply-To: <20170804033852.97986-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most TCP congestion controls are using identical logic to undo
cwnd except BBR. This patch consolidates these similar functions
to the one used currently by Reno and others.

Suggested-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_bic.c       | 14 +-------------
 net/ipv4/tcp_cdg.c       | 12 +-----------
 net/ipv4/tcp_cubic.c     | 13 +------------
 net/ipv4/tcp_highspeed.c | 11 +----------
 net/ipv4/tcp_illinois.c  | 11 +----------
 net/ipv4/tcp_nv.c        | 13 +------------
 net/ipv4/tcp_scalable.c  | 16 +---------------
 net/ipv4/tcp_veno.c      | 11 +----------
 net/ipv4/tcp_yeah.c      | 11 +----------
 9 files changed, 9 insertions(+), 103 deletions(-)

diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
index 609965f0e298..fc3614377413 100644
--- a/net/ipv4/tcp_bic.c
+++ b/net/ipv4/tcp_bic.c
@@ -49,7 +49,6 @@ MODULE_PARM_DESC(smooth_part, "log(B/(B*Smin))/log(B/(B-1))+B, # of RTT from Wma
 struct bictcp {
 	u32	cnt;		/* increase cwnd by 1 after ACKs */
 	u32	last_max_cwnd;	/* last maximum snd_cwnd */
-	u32	loss_cwnd;	/* congestion window at last loss */
 	u32	last_cwnd;	/* the last snd_cwnd */
 	u32	last_time;	/* time when updated last_cwnd */
 	u32	epoch_start;	/* beginning of an epoch */
@@ -72,7 +71,6 @@ static void bictcp_init(struct sock *sk)
 	struct bictcp *ca = inet_csk_ca(sk);
 
 	bictcp_reset(ca);
-	ca->loss_cwnd = 0;
 
 	if (initial_ssthresh)
 		tcp_sk(sk)->snd_ssthresh = initial_ssthresh;
@@ -172,22 +170,12 @@ static u32 bictcp_recalc_ssthresh(struct sock *sk)
 	else
 		ca->last_max_cwnd = tp->snd_cwnd;
 
-	ca->loss_cwnd = tp->snd_cwnd;
-
 	if (tp->snd_cwnd <= low_window)
 		return max(tp->snd_cwnd >> 1U, 2U);
 	else
 		return max((tp->snd_cwnd * beta) / BICTCP_BETA_SCALE, 2U);
 }
 
-static u32 bictcp_undo_cwnd(struct sock *sk)
-{
-	const struct tcp_sock *tp = tcp_sk(sk);
-	const struct bictcp *ca = inet_csk_ca(sk);
-
-	return max(tp->snd_cwnd, ca->loss_cwnd);
-}
-
 static void bictcp_state(struct sock *sk, u8 new_state)
 {
 	if (new_state == TCP_CA_Loss)
@@ -214,7 +202,7 @@ static struct tcp_congestion_ops bictcp __read_mostly = {
 	.ssthresh	= bictcp_recalc_ssthresh,
 	.cong_avoid	= bictcp_cong_avoid,
 	.set_state	= bictcp_state,
-	.undo_cwnd	= bictcp_undo_cwnd,
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 	.pkts_acked     = bictcp_acked,
 	.owner		= THIS_MODULE,
 	.name		= "bic",
diff --git a/net/ipv4/tcp_cdg.c b/net/ipv4/tcp_cdg.c
index 50a0f3e51d5b..66ac69f7bd19 100644
--- a/net/ipv4/tcp_cdg.c
+++ b/net/ipv4/tcp_cdg.c
@@ -85,7 +85,6 @@ struct cdg {
 	u8  state;
 	u8  delack;
 	u32 rtt_seq;
-	u32 undo_cwnd;
 	u32 shadow_wnd;
 	u16 backoff_cnt;
 	u16 sample_cnt;
@@ -330,8 +329,6 @@ static u32 tcp_cdg_ssthresh(struct sock *sk)
 	struct cdg *ca = inet_csk_ca(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	ca->undo_cwnd = tp->snd_cwnd;
-
 	if (ca->state == CDG_BACKOFF)
 		return max(2U, (tp->snd_cwnd * min(1024U, backoff_beta)) >> 10);
 
@@ -344,13 +341,6 @@ static u32 tcp_cdg_ssthresh(struct sock *sk)
 	return max(2U, tp->snd_cwnd >> 1);
 }
 
-static u32 tcp_cdg_undo_cwnd(struct sock *sk)
-{
-	struct cdg *ca = inet_csk_ca(sk);
-
-	return max(tcp_sk(sk)->snd_cwnd, ca->undo_cwnd);
-}
-
 static void tcp_cdg_cwnd_event(struct sock *sk, const enum tcp_ca_event ev)
 {
 	struct cdg *ca = inet_csk_ca(sk);
@@ -403,7 +393,7 @@ struct tcp_congestion_ops tcp_cdg __read_mostly = {
 	.cong_avoid = tcp_cdg_cong_avoid,
 	.cwnd_event = tcp_cdg_cwnd_event,
 	.pkts_acked = tcp_cdg_acked,
-	.undo_cwnd = tcp_cdg_undo_cwnd,
+	.undo_cwnd = tcp_reno_undo_cwnd,
 	.ssthresh = tcp_cdg_ssthresh,
 	.release = tcp_cdg_release,
 	.init = tcp_cdg_init,
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 57ae5b5ae643..78bfadfcf342 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -83,7 +83,6 @@ MODULE_PARM_DESC(hystart_ack_delta, "spacing between ack's indicating train (mse
 struct bictcp {
 	u32	cnt;		/* increase cwnd by 1 after ACKs */
 	u32	last_max_cwnd;	/* last maximum snd_cwnd */
-	u32	loss_cwnd;	/* congestion window at last loss */
 	u32	last_cwnd;	/* the last snd_cwnd */
 	u32	last_time;	/* time when updated last_cwnd */
 	u32	bic_origin_point;/* origin point of bic function */
@@ -142,7 +141,6 @@ static void bictcp_init(struct sock *sk)
 	struct bictcp *ca = inet_csk_ca(sk);
 
 	bictcp_reset(ca);
-	ca->loss_cwnd = 0;
 
 	if (hystart)
 		bictcp_hystart_reset(sk);
@@ -366,18 +364,9 @@ static u32 bictcp_recalc_ssthresh(struct sock *sk)
 	else
 		ca->last_max_cwnd = tp->snd_cwnd;
 
-	ca->loss_cwnd = tp->snd_cwnd;
-
 	return max((tp->snd_cwnd * beta) / BICTCP_BETA_SCALE, 2U);
 }
 
-static u32 bictcp_undo_cwnd(struct sock *sk)
-{
-	struct bictcp *ca = inet_csk_ca(sk);
-
-	return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
-}
-
 static void bictcp_state(struct sock *sk, u8 new_state)
 {
 	if (new_state == TCP_CA_Loss) {
@@ -470,7 +459,7 @@ static struct tcp_congestion_ops cubictcp __read_mostly = {
 	.ssthresh	= bictcp_recalc_ssthresh,
 	.cong_avoid	= bictcp_cong_avoid,
 	.set_state	= bictcp_state,
-	.undo_cwnd	= bictcp_undo_cwnd,
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 	.cwnd_event	= bictcp_cwnd_event,
 	.pkts_acked     = bictcp_acked,
 	.owner		= THIS_MODULE,
diff --git a/net/ipv4/tcp_highspeed.c b/net/ipv4/tcp_highspeed.c
index 6d9879e93648..d1c33c91eadc 100644
--- a/net/ipv4/tcp_highspeed.c
+++ b/net/ipv4/tcp_highspeed.c
@@ -94,7 +94,6 @@ static const struct hstcp_aimd_val {
 
 struct hstcp {
 	u32	ai;
-	u32	loss_cwnd;
 };
 
 static void hstcp_init(struct sock *sk)
@@ -153,22 +152,14 @@ static u32 hstcp_ssthresh(struct sock *sk)
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct hstcp *ca = inet_csk_ca(sk);
 
-	ca->loss_cwnd = tp->snd_cwnd;
 	/* Do multiplicative decrease */
 	return max(tp->snd_cwnd - ((tp->snd_cwnd * hstcp_aimd_vals[ca->ai].md) >> 8), 2U);
 }
 
-static u32 hstcp_cwnd_undo(struct sock *sk)
-{
-	const struct hstcp *ca = inet_csk_ca(sk);
-
-	return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
-}
-
 static struct tcp_congestion_ops tcp_highspeed __read_mostly = {
 	.init		= hstcp_init,
 	.ssthresh	= hstcp_ssthresh,
-	.undo_cwnd	= hstcp_cwnd_undo,
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 	.cong_avoid	= hstcp_cong_avoid,
 
 	.owner		= THIS_MODULE,
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 60352ff4f5a8..7c843578f233 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -48,7 +48,6 @@ struct illinois {
 	u32	end_seq;	/* right edge of current RTT */
 	u32	alpha;		/* Additive increase */
 	u32	beta;		/* Muliplicative decrease */
-	u32	loss_cwnd;	/* cwnd on loss */
 	u16	acked;		/* # packets acked by current ACK */
 	u8	rtt_above;	/* average rtt has gone above threshold */
 	u8	rtt_low;	/* # of rtts measurements below threshold */
@@ -297,18 +296,10 @@ static u32 tcp_illinois_ssthresh(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct illinois *ca = inet_csk_ca(sk);
 
-	ca->loss_cwnd = tp->snd_cwnd;
 	/* Multiplicative decrease */
 	return max(tp->snd_cwnd - ((tp->snd_cwnd * ca->beta) >> BETA_SHIFT), 2U);
 }
 
-static u32 tcp_illinois_cwnd_undo(struct sock *sk)
-{
-	const struct illinois *ca = inet_csk_ca(sk);
-
-	return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
-}
-
 /* Extract info for Tcp socket info provided via netlink. */
 static size_t tcp_illinois_info(struct sock *sk, u32 ext, int *attr,
 				union tcp_cc_info *info)
@@ -336,7 +327,7 @@ static size_t tcp_illinois_info(struct sock *sk, u32 ext, int *attr,
 static struct tcp_congestion_ops tcp_illinois __read_mostly = {
 	.init		= tcp_illinois_init,
 	.ssthresh	= tcp_illinois_ssthresh,
-	.undo_cwnd	= tcp_illinois_cwnd_undo,
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 	.cong_avoid	= tcp_illinois_cong_avoid,
 	.set_state	= tcp_illinois_state,
 	.get_info	= tcp_illinois_info,
diff --git a/net/ipv4/tcp_nv.c b/net/ipv4/tcp_nv.c
index 6d650ed3cb59..1ff73982e28c 100644
--- a/net/ipv4/tcp_nv.c
+++ b/net/ipv4/tcp_nv.c
@@ -86,7 +86,6 @@ struct tcpnv {
 				 * < 0 => less than 1 packet/RTT */
 	u8  available8;
 	u16 available16;
-	u32 loss_cwnd;	/* cwnd at last loss */
 	u8  nv_allow_cwnd_growth:1, /* whether cwnd can grow */
 		nv_reset:1,	    /* whether to reset values */
 		nv_catchup:1;	    /* whether we are growing because
@@ -121,7 +120,6 @@ static inline void tcpnv_reset(struct tcpnv *ca, struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	ca->nv_reset = 0;
-	ca->loss_cwnd = 0;
 	ca->nv_no_cong_cnt = 0;
 	ca->nv_rtt_cnt = 0;
 	ca->nv_last_rtt = 0;
@@ -177,19 +175,10 @@ static void tcpnv_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 static u32 tcpnv_recalc_ssthresh(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
-	struct tcpnv *ca = inet_csk_ca(sk);
 
-	ca->loss_cwnd = tp->snd_cwnd;
 	return max((tp->snd_cwnd * nv_loss_dec_factor) >> 10, 2U);
 }
 
-static u32 tcpnv_undo_cwnd(struct sock *sk)
-{
-	struct tcpnv *ca = inet_csk_ca(sk);
-
-	return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
-}
-
 static void tcpnv_state(struct sock *sk, u8 new_state)
 {
 	struct tcpnv *ca = inet_csk_ca(sk);
@@ -446,7 +435,7 @@ static struct tcp_congestion_ops tcpnv __read_mostly = {
 	.ssthresh	= tcpnv_recalc_ssthresh,
 	.cong_avoid	= tcpnv_cong_avoid,
 	.set_state	= tcpnv_state,
-	.undo_cwnd	= tcpnv_undo_cwnd,
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 	.pkts_acked     = tcpnv_acked,
 	.get_info	= tcpnv_get_info,
 
diff --git a/net/ipv4/tcp_scalable.c b/net/ipv4/tcp_scalable.c
index f2123075ce6e..addc122f8818 100644
--- a/net/ipv4/tcp_scalable.c
+++ b/net/ipv4/tcp_scalable.c
@@ -15,10 +15,6 @@
 #define TCP_SCALABLE_AI_CNT	50U
 #define TCP_SCALABLE_MD_SCALE	3
 
-struct scalable {
-	u32 loss_cwnd;
-};
-
 static void tcp_scalable_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -36,23 +32,13 @@ static void tcp_scalable_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 static u32 tcp_scalable_ssthresh(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
-	struct scalable *ca = inet_csk_ca(sk);
-
-	ca->loss_cwnd = tp->snd_cwnd;
 
 	return max(tp->snd_cwnd - (tp->snd_cwnd>>TCP_SCALABLE_MD_SCALE), 2U);
 }
 
-static u32 tcp_scalable_cwnd_undo(struct sock *sk)
-{
-	const struct scalable *ca = inet_csk_ca(sk);
-
-	return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
-}
-
 static struct tcp_congestion_ops tcp_scalable __read_mostly = {
 	.ssthresh	= tcp_scalable_ssthresh,
-	.undo_cwnd	= tcp_scalable_cwnd_undo,
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 	.cong_avoid	= tcp_scalable_cong_avoid,
 
 	.owner		= THIS_MODULE,
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index 76005d4b8dfc..6fcf482d611b 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -30,7 +30,6 @@ struct veno {
 	u32 basertt;		/* the min of all Veno rtt measurements seen (in usec) */
 	u32 inc;		/* decide whether to increase cwnd */
 	u32 diff;		/* calculate the diff rate */
-	u32 loss_cwnd;		/* cwnd when loss occured */
 };
 
 /* There are several situations when we must "re-start" Veno:
@@ -194,7 +193,6 @@ static u32 tcp_veno_ssthresh(struct sock *sk)
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct veno *veno = inet_csk_ca(sk);
 
-	veno->loss_cwnd = tp->snd_cwnd;
 	if (veno->diff < beta)
 		/* in "non-congestive state", cut cwnd by 1/5 */
 		return max(tp->snd_cwnd * 4 / 5, 2U);
@@ -203,17 +201,10 @@ static u32 tcp_veno_ssthresh(struct sock *sk)
 		return max(tp->snd_cwnd >> 1U, 2U);
 }
 
-static u32 tcp_veno_cwnd_undo(struct sock *sk)
-{
-	const struct veno *veno = inet_csk_ca(sk);
-
-	return max(tcp_sk(sk)->snd_cwnd, veno->loss_cwnd);
-}
-
 static struct tcp_congestion_ops tcp_veno __read_mostly = {
 	.init		= tcp_veno_init,
 	.ssthresh	= tcp_veno_ssthresh,
-	.undo_cwnd	= tcp_veno_cwnd_undo,
+	.undo_cwnd	= tcp_reno_undo_cwnd,
 	.cong_avoid	= tcp_veno_cong_avoid,
 	.pkts_acked	= tcp_veno_pkts_acked,
 	.set_state	= tcp_veno_state,
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index e6ff99c4bd3b..96e829b2e2fc 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -37,7 +37,6 @@ struct yeah {
 	u32 fast_count;
 
 	u32 pkts_acked;
-	u32 loss_cwnd;
 };
 
 static void tcp_yeah_init(struct sock *sk)
@@ -220,22 +219,14 @@ static u32 tcp_yeah_ssthresh(struct sock *sk)
 
 	yeah->fast_count = 0;
 	yeah->reno_count = max(yeah->reno_count>>1, 2U);
-	yeah->loss_cwnd = tp->snd_cwnd;
 
 	return max_t(int, tp->snd_cwnd - reduction, 2);
 }
 
-static u32 tcp_yeah_cwnd_undo(struct sock *sk)
-{
-	const struct yeah *yeah = inet_csk_ca(sk);
-
-	return max(tcp_sk(sk)->snd_cwnd, yeah->loss_cwnd);
-}
-
 static struct tcp_congestion_ops tcp_yeah __read_mostly = {
 	.init		= tcp_yeah_init,
 	.ssthresh	= tcp_yeah_ssthresh,
-	.undo_cwnd      = tcp_yeah_cwnd_undo,
+	.undo_cwnd      = tcp_reno_undo_cwnd,
 	.cong_avoid	= tcp_yeah_cong_avoid,
 	.set_state	= tcp_vegas_state,
 	.cwnd_event	= tcp_vegas_cwnd_event,
-- 
2.14.0.rc1.383.gd1ce394fe2-goog
