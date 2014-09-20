From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v2 3/5] net: tcp: split ack slow/fast events from cwnd_event
Date: Sat, 20 Sep 2014 23:29:20 +0200
Message-ID: <1411248562-26581-4-git-send-email-fw@strlen.de>
References: <1411248562-26581-1-git-send-email-fw@strlen.de>
Cc: hagen@jauu.net, lars@netapp.com, eric.dumazet@gmail.com,
	fontana@sharpeleven.org, hannes@stressinduktion.org,
	glenn.judd@morganstanley.com, dborkman@redhat.com,
	netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:38440 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755266AbaITV3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 17:29:47 -0400
In-Reply-To: <1411248562-26581-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The congestion control ops "cwnd_event" currently supports
CA_EVENT_FAST_ACK and CA_EVENT_SLOW_ACK events (among others).
Both FAST and SLOW_ACK are only used by Westwood congestion
control algorithm.

This removes both flags from cwnd_event and adds a new
in_ack_event callback for this. The goal is to be able to
provide more detailed information about ACKs, such as whether
ECE flag was set, or whether the ACK resulted in a window
update.

It is required for DataCenter TCP (DCTCP) congestion control
algorithm as it makes a different choice depending on ECE being
set or not.

Joint work with Daniel Borkmann and Glenn Judd.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Glenn Judd <glenn.judd@morganstanley.com>
---
 include/net/tcp.h       |  8 ++++++--
 net/ipv4/tcp_input.c    | 12 ++++++++++--
 net/ipv4/tcp_westwood.c | 28 ++++++++++++++++------------
 3 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 82d012e..e71884a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -744,8 +744,10 @@ enum tcp_ca_event {
 	CA_EVENT_CWND_RESTART,	/* congestion window restart */
 	CA_EVENT_COMPLETE_CWR,	/* end of congestion recovery */
 	CA_EVENT_LOSS,		/* loss timeout */
-	CA_EVENT_FAST_ACK,	/* in sequence ack */
-	CA_EVENT_SLOW_ACK,	/* other ack */
+};
+
+enum tcp_ca_ack_event_flags {
+	CA_ACK_SLOWPATH = (1 << 0),
 };
 
 /*
@@ -777,6 +779,8 @@ struct tcp_congestion_ops {
 	void (*set_state)(struct sock *sk, u8 new_state);
 	/* call when cwnd event occurs (optional) */
 	void (*cwnd_event)(struct sock *sk, enum tcp_ca_event ev);
+	/* call when ack arrives (optional) */
+	void (*in_ack_event)(struct sock *sk, u32 flags);
 	/* new value of cwnd after loss (optional) */
 	u32  (*undo_cwnd)(struct sock *sk);
 	/* hook for packet ack accounting (optional) */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0af12a4..14dc3ee 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3361,6 +3361,14 @@ static void tcp_process_tlp_ack(struct sock *sk, u32 ack, int flag)
 	}
 }
 
+static inline void tcp_in_ack_event(struct sock *sk, u32 flags)
+{
+	const struct inet_connection_sock *icsk = inet_csk(sk);
+
+	if (icsk->icsk_ca_ops->in_ack_event)
+		icsk->icsk_ca_ops->in_ack_event(sk, flags);
+}
+
 /* This routine deals with incoming acks, but not outgoing ones. */
 static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 {
@@ -3420,7 +3428,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 		tp->snd_una = ack;
 		flag |= FLAG_WIN_UPDATE;
 
-		tcp_ca_event(sk, CA_EVENT_FAST_ACK);
+		tcp_in_ack_event(sk, 0);
 
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPHPACKS);
 	} else {
@@ -3438,7 +3446,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 		if (TCP_ECN_rcv_ecn_echo(tp, tcp_hdr(skb)))
 			flag |= FLAG_ECE;
 
-		tcp_ca_event(sk, CA_EVENT_SLOW_ACK);
+		tcp_in_ack_event(sk, CA_ACK_SLOWPATH);
 	}
 
 	/* We passed data and got it acked, remove any soft error
diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index 81911a9..bb63fba 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -220,32 +220,35 @@ static u32 tcp_westwood_bw_rttmin(const struct sock *sk)
 	return max_t(u32, (w->bw_est * w->rtt_min) / tp->mss_cache, 2);
 }
 
+static void tcp_westwood_ack(struct sock *sk, u32 ack_flags)
+{
+	if (ack_flags & CA_ACK_SLOWPATH) {
+		struct westwood *w = inet_csk_ca(sk);
+
+		westwood_update_window(sk);
+		w->bk += westwood_acked_count(sk);
+
+		update_rtt_min(w);
+		return;
+	}
+
+	westwood_fast_bw(sk);
+}
+
 static void tcp_westwood_event(struct sock *sk, enum tcp_ca_event event)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct westwood *w = inet_csk_ca(sk);
 
 	switch (event) {
-	case CA_EVENT_FAST_ACK:
-		westwood_fast_bw(sk);
-		break;
-
 	case CA_EVENT_COMPLETE_CWR:
 		tp->snd_cwnd = tp->snd_ssthresh = tcp_westwood_bw_rttmin(sk);
 		break;
-
 	case CA_EVENT_LOSS:
 		tp->snd_ssthresh = tcp_westwood_bw_rttmin(sk);
 		/* Update RTT_min when next ack arrives */
 		w->reset_rtt_min = 1;
 		break;
-
-	case CA_EVENT_SLOW_ACK:
-		westwood_update_window(sk);
-		w->bk += westwood_acked_count(sk);
-		update_rtt_min(w);
-		break;
-
 	default:
 		/* don't care */
 		break;
@@ -274,6 +277,7 @@ static struct tcp_congestion_ops tcp_westwood __read_mostly = {
 	.ssthresh	= tcp_reno_ssthresh,
 	.cong_avoid	= tcp_reno_cong_avoid,
 	.cwnd_event	= tcp_westwood_event,
+	.in_ack_event	= tcp_westwood_ack,
 	.get_info	= tcp_westwood_info,
 	.pkts_acked	= tcp_westwood_pkts_acked,
 
-- 
1.7.11.7
