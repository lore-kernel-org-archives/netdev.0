From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 17/20] mib: add net to NET_INC_STATS_BH
Date: Wed, 16 Jul 2008 12:33:37 +0400
Message-ID: <487DB261.603@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56748 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754240AbYGPIdl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:33:41 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/ip.h            |    2 +-
 include/net/tcp.h           |    2 +-
 net/dccp/ipv4.c             |   10 +++---
 net/dccp/ipv6.c             |    8 ++--
 net/dccp/timer.c            |    4 +-
 net/ipv4/arp.c              |    2 +-
 net/ipv4/inet_hashtables.c  |    4 +-
 net/ipv4/syncookies.c       |    6 ++--
 net/ipv4/tcp.c              |    6 ++-
 net/ipv4/tcp_input.c        |   65 ++++++++++++++++++++++---------------------
 net/ipv4/tcp_ipv4.c         |   12 ++++----
 net/ipv4/tcp_minisocks.c    |    6 ++--
 net/ipv4/tcp_output.c       |    4 +-
 net/ipv4/tcp_timer.c        |   12 ++++----
 net/ipv6/inet6_hashtables.c |    4 +-
 net/ipv6/syncookies.c       |    6 ++--
 net/ipv6/tcp_ipv6.c         |   10 +++---
 net/sctp/input.c            |    2 +-
 18 files changed, 84 insertions(+), 81 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index b42a434..21df167 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -162,7 +162,7 @@ DECLARE_SNMP_STAT(struct ipstats_mib, ip_statistics);
 #define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS_BH(ip_statistics, field, val)
 DECLARE_SNMP_STAT(struct linux_mib, net_statistics);
 #define NET_INC_STATS(net, field)	do { (void)net; SNMP_INC_STATS(net_statistics, field); } while (0)
-#define NET_INC_STATS_BH(field)		SNMP_INC_STATS_BH(net_statistics, field)
+#define NET_INC_STATS_BH(net, field)	do { (void)net; SNMP_INC_STATS_BH(net_statistics, field); } while (0)
 #define NET_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(net_statistics, field)
 #define NET_ADD_STATS_BH(field, adnd)	SNMP_ADD_STATS_BH(net_statistics, field, adnd)
 #define NET_ADD_STATS_USER(field, adnd)	SNMP_ADD_STATS_USER(net_statistics, field, adnd)
diff --git a/include/net/tcp.h b/include/net/tcp.h
index c25cb52..60e5be8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -894,7 +894,7 @@ static inline int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 
 			while ((skb1 = __skb_dequeue(&tp->ucopy.prequeue)) != NULL) {
 				sk->sk_backlog_rcv(sk, skb1);
-				NET_INC_STATS_BH(LINUX_MIB_TCPPREQUEUEDROPPED);
+				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPPREQUEUEDROPPED);
 			}
 
 			tp->ucopy.memory = 0;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 9f760a1..2622ace 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -230,7 +230,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	 * servers this needs to be solved differently.
 	 */
 	if (sock_owned_by_user(sk))
-		NET_INC_STATS_BH(LINUX_MIB_LOCKDROPPEDICMPS);
+		NET_INC_STATS_BH(net, LINUX_MIB_LOCKDROPPEDICMPS);
 
 	if (sk->sk_state == DCCP_CLOSED)
 		goto out;
@@ -239,7 +239,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	seq = dccp_hdr_seq(dh);
 	if ((1 << sk->sk_state) & ~(DCCPF_REQUESTING | DCCPF_LISTEN) &&
 	    !between48(seq, dp->dccps_swl, dp->dccps_swh)) {
-		NET_INC_STATS_BH(LINUX_MIB_OUTOFWINDOWICMPS);
+		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 		goto out;
 	}
 
@@ -286,7 +286,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 		BUG_TRAP(!req->sk);
 
 		if (seq != dccp_rsk(req)->dreq_iss) {
-			NET_INC_STATS_BH(LINUX_MIB_OUTOFWINDOWICMPS);
+			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 			goto out;
 		}
 		/*
@@ -409,9 +409,9 @@ struct sock *dccp_v4_request_recv_sock(struct sock *sk, struct sk_buff *skb,
 	return newsk;
 
 exit_overflow:
-	NET_INC_STATS_BH(LINUX_MIB_LISTENOVERFLOWS);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
 exit:
-	NET_INC_STATS_BH(LINUX_MIB_LISTENDROPS);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	dst_release(dst);
 	return NULL;
 }
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 83cc9bb..b74e8b2 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -111,7 +111,7 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk))
-		NET_INC_STATS_BH(LINUX_MIB_LOCKDROPPEDICMPS);
+		NET_INC_STATS_BH(net, LINUX_MIB_LOCKDROPPEDICMPS);
 
 	if (sk->sk_state == DCCP_CLOSED)
 		goto out;
@@ -189,7 +189,7 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		BUG_TRAP(req->sk == NULL);
 
 		if (seq != dccp_rsk(req)->dreq_iss) {
-			NET_INC_STATS_BH(LINUX_MIB_OUTOFWINDOWICMPS);
+			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 			goto out;
 		}
 
@@ -630,9 +630,9 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 	return newsk;
 
 out_overflow:
-	NET_INC_STATS_BH(LINUX_MIB_LISTENOVERFLOWS);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
 out:
-	NET_INC_STATS_BH(LINUX_MIB_LISTENDROPS);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	if (opt != NULL && opt != np->opt)
 		sock_kfree_s(sk, opt, opt->tot_len);
 	dst_release(dst);
diff --git a/net/dccp/timer.c b/net/dccp/timer.c
index 8703a79..3608d53 100644
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -224,7 +224,7 @@ static void dccp_delack_timer(unsigned long data)
 	if (sock_owned_by_user(sk)) {
 		/* Try again later. */
 		icsk->icsk_ack.blocked = 1;
-		NET_INC_STATS_BH(LINUX_MIB_DELAYEDACKLOCKED);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOCKED);
 		sk_reset_timer(sk, &icsk->icsk_delack_timer,
 			       jiffies + TCP_DELACK_MIN);
 		goto out;
@@ -254,7 +254,7 @@ static void dccp_delack_timer(unsigned long data)
 			icsk->icsk_ack.ato = TCP_ATO_MIN;
 		}
 		dccp_send_ack(sk);
-		NET_INC_STATS_BH(LINUX_MIB_DELAYEDACKS);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKS);
 	}
 out:
 	bh_unlock_sock(sk);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index aab98b8..b043eda 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -426,7 +426,7 @@ static int arp_filter(__be32 sip, __be32 tip, struct net_device *dev)
 	if (ip_route_output_key(net, &rt, &fl) < 0)
 		return 1;
 	if (rt->u.dst.dev != dev) {
-		NET_INC_STATS_BH(LINUX_MIB_ARPFILTER);
+		NET_INC_STATS_BH(net, LINUX_MIB_ARPFILTER);
 		flag = 1;
 	}
 	ip_rt_put(rt);
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index eca5899..115f537 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -312,11 +312,11 @@ unique:
 
 	if (twp) {
 		*twp = tw;
-		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
+		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
 	} else if (tw) {
 		/* Silly. Should hash-dance instead... */
 		inet_twsk_deschedule(tw, death_row);
-		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
+		NET_INC_STATS_BH(net, LINUX_MIB_TIMEWAITRECYCLED);
 
 		inet_twsk_put(tw);
 	}
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index fdde2ae..51bc24d 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -173,7 +173,7 @@ __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
 		;
 	*mssp = msstab[mssind] + 1;
 
-	NET_INC_STATS_BH(LINUX_MIB_SYNCOOKIESSENT);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
 
 	return secure_tcp_syn_cookie(iph->saddr, iph->daddr,
 				     th->source, th->dest, ntohl(th->seq),
@@ -269,11 +269,11 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 
 	if (time_after(jiffies, tp->last_synq_overflow + TCP_TIMEOUT_INIT) ||
 	    (mss = cookie_check(skb, cookie)) == 0) {
-		NET_INC_STATS_BH(LINUX_MIB_SYNCOOKIESFAILED);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESFAILED);
 		goto out;
 	}
 
-	NET_INC_STATS_BH(LINUX_MIB_SYNCOOKIESRECV);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESRECV);
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9c420da..9aa4a0e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1871,7 +1871,8 @@ adjudge_to_death:
 		if (tp->linger2 < 0) {
 			tcp_set_state(sk, TCP_CLOSE);
 			tcp_send_active_reset(sk, GFP_ATOMIC);
-			NET_INC_STATS_BH(LINUX_MIB_TCPABORTONLINGER);
+			NET_INC_STATS_BH(sock_net(sk),
+					LINUX_MIB_TCPABORTONLINGER);
 		} else {
 			const int tmo = tcp_fin_time(sk);
 
@@ -1893,7 +1894,8 @@ adjudge_to_death:
 				       "sockets\n");
 			tcp_set_state(sk, TCP_CLOSE);
 			tcp_send_active_reset(sk, GFP_ATOMIC);
-			NET_INC_STATS_BH(LINUX_MIB_TCPABORTONMEMORY);
+			NET_INC_STATS_BH(sock_net(sk),
+					LINUX_MIB_TCPABORTONMEMORY);
 		}
 	}
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f50d843..fac49a6 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -961,7 +961,7 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
 		else
 			mib_idx = LINUX_MIB_TCPSACKREORDER;
 
-		NET_INC_STATS_BH(mib_idx);
+		NET_INC_STATS_BH(sock_net(sk), mib_idx);
 #if FASTRETRANS_DEBUG > 1
 		printk(KERN_DEBUG "Disorder%d %d %u f%u s%u rr%d\n",
 		       tp->rx_opt.sack_ok, inet_csk(sk)->icsk_ca_state,
@@ -1157,7 +1157,7 @@ static void tcp_mark_lost_retrans(struct sock *sk)
 				tp->lost_out += tcp_skb_pcount(skb);
 				TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
 			}
-			NET_INC_STATS_BH(LINUX_MIB_TCPLOSTRETRANSMIT);
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSTRETRANSMIT);
 		} else {
 			if (before(ack_seq, new_low_seq))
 				new_low_seq = ack_seq;
@@ -1181,7 +1181,7 @@ static int tcp_check_dsack(struct sock *sk, struct sk_buff *ack_skb,
 	if (before(start_seq_0, TCP_SKB_CB(ack_skb)->ack_seq)) {
 		dup_sack = 1;
 		tcp_dsack_seen(tp);
-		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPDSACKRECV);
 	} else if (num_sacks > 1) {
 		u32 end_seq_1 = get_unaligned_be32(&sp[1].end_seq);
 		u32 start_seq_1 = get_unaligned_be32(&sp[1].start_seq);
@@ -1190,7 +1190,8 @@ static int tcp_check_dsack(struct sock *sk, struct sk_buff *ack_skb,
 		    !before(start_seq_0, start_seq_1)) {
 			dup_sack = 1;
 			tcp_dsack_seen(tp);
-			NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFORECV);
+			NET_INC_STATS_BH(sock_net(sk),
+					LINUX_MIB_TCPDSACKOFORECV);
 		}
 	}
 
@@ -1476,7 +1477,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 				mib_idx = LINUX_MIB_TCPSACKDISCARD;
 			}
 
-			NET_INC_STATS_BH(mib_idx);
+			NET_INC_STATS_BH(sock_net(sk), mib_idx);
 			if (i == 0)
 				first_sack_index = -1;
 			continue;
@@ -1969,7 +1970,7 @@ static int tcp_check_sack_reneging(struct sock *sk, int flag)
 {
 	if (flag & FLAG_SACK_RENEGING) {
 		struct inet_connection_sock *icsk = inet_csk(sk);
-		NET_INC_STATS_BH(LINUX_MIB_TCPSACKRENEGING);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSACKRENEGING);
 
 		tcp_enter_loss(sk, 1);
 		icsk->icsk_retransmits++;
@@ -2401,7 +2402,7 @@ static int tcp_try_undo_recovery(struct sock *sk)
 		else
 			mib_idx = LINUX_MIB_TCPFULLUNDO;
 
-		NET_INC_STATS_BH(mib_idx);
+		NET_INC_STATS_BH(sock_net(sk), mib_idx);
 		tp->undo_marker = 0;
 	}
 	if (tp->snd_una == tp->high_seq && tcp_is_reno(tp)) {
@@ -2424,7 +2425,7 @@ static void tcp_try_undo_dsack(struct sock *sk)
 		DBGUNDO(sk, "D-SACK");
 		tcp_undo_cwr(sk, 1);
 		tp->undo_marker = 0;
-		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKUNDO);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPDSACKUNDO);
 	}
 }
 
@@ -2447,7 +2448,7 @@ static int tcp_try_undo_partial(struct sock *sk, int acked)
 
 		DBGUNDO(sk, "Hoe");
 		tcp_undo_cwr(sk, 0);
-		NET_INC_STATS_BH(LINUX_MIB_TCPPARTIALUNDO);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPPARTIALUNDO);
 
 		/* So... Do not make Hoe's retransmit yet.
 		 * If the first packet was delayed, the rest
@@ -2476,7 +2477,7 @@ static int tcp_try_undo_loss(struct sock *sk)
 		DBGUNDO(sk, "partial loss");
 		tp->lost_out = 0;
 		tcp_undo_cwr(sk, 1);
-		NET_INC_STATS_BH(LINUX_MIB_TCPLOSSUNDO);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSSUNDO);
 		inet_csk(sk)->icsk_retransmits = 0;
 		tp->undo_marker = 0;
 		if (tcp_is_sack(tp))
@@ -2595,7 +2596,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	    icsk->icsk_ca_state != TCP_CA_Open &&
 	    tp->fackets_out > tp->reordering) {
 		tcp_mark_head_lost(sk, tp->fackets_out - tp->reordering);
-		NET_INC_STATS_BH(LINUX_MIB_TCPLOSS);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSS);
 	}
 
 	/* D. Check consistency of the current state. */
@@ -2700,7 +2701,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 		else
 			mib_idx = LINUX_MIB_TCPSACKRECOVERY;
 
-		NET_INC_STATS_BH(mib_idx);
+		NET_INC_STATS_BH(sock_net(sk), mib_idx);
 
 		tp->high_seq = tp->snd_nxt;
 		tp->prior_ssthresh = 0;
@@ -3211,7 +3212,7 @@ static int tcp_process_frto(struct sock *sk, int flag)
 		}
 		tp->frto_counter = 0;
 		tp->undo_marker = 0;
-		NET_INC_STATS_BH(LINUX_MIB_TCPSPURIOUSRTOS);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSPURIOUSRTOS);
 	}
 	return 0;
 }
@@ -3264,12 +3265,12 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 
 		tcp_ca_event(sk, CA_EVENT_FAST_ACK);
 
-		NET_INC_STATS_BH(LINUX_MIB_TCPHPACKS);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPHPACKS);
 	} else {
 		if (ack_seq != TCP_SKB_CB(skb)->end_seq)
 			flag |= FLAG_DATA;
 		else
-			NET_INC_STATS_BH(LINUX_MIB_TCPPUREACKS);
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPPUREACKS);
 
 		flag |= tcp_ack_update_window(sk, skb, ack, ack_seq);
 
@@ -3724,7 +3725,7 @@ static void tcp_dsack_set(struct sock *sk, u32 seq, u32 end_seq)
 		else
 			mib_idx = LINUX_MIB_TCPDSACKOFOSENT;
 
-		NET_INC_STATS_BH(mib_idx);
+		NET_INC_STATS_BH(sock_net(sk), mib_idx);
 
 		tp->rx_opt.dsack = 1;
 		tp->duplicate_sack[0].start_seq = seq;
@@ -3750,7 +3751,7 @@ static void tcp_send_dupack(struct sock *sk, struct sk_buff *skb)
 
 	if (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
 	    before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt)) {
-		NET_INC_STATS_BH(LINUX_MIB_DELAYEDACKLOST);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOST);
 		tcp_enter_quickack_mode(sk);
 
 		if (tcp_is_sack(tp) && sysctl_tcp_dsack) {
@@ -4039,7 +4040,7 @@ queue_and_out:
 
 	if (!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt)) {
 		/* A retransmit, 2nd most common case.  Force an immediate ack. */
-		NET_INC_STATS_BH(LINUX_MIB_DELAYEDACKLOST);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOST);
 		tcp_dsack_set(sk, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq);
 
 out_of_window:
@@ -4181,7 +4182,7 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list,
 			struct sk_buff *next = skb->next;
 			__skb_unlink(skb, list);
 			__kfree_skb(skb);
-			NET_INC_STATS_BH(LINUX_MIB_TCPRCVCOLLAPSED);
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOLLAPSED);
 			skb = next;
 			continue;
 		}
@@ -4249,7 +4250,7 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list,
 				struct sk_buff *next = skb->next;
 				__skb_unlink(skb, list);
 				__kfree_skb(skb);
-				NET_INC_STATS_BH(LINUX_MIB_TCPRCVCOLLAPSED);
+				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOLLAPSED);
 				skb = next;
 				if (skb == tail ||
 				    tcp_hdr(skb)->syn ||
@@ -4312,7 +4313,7 @@ static int tcp_prune_ofo_queue(struct sock *sk)
 	int res = 0;
 
 	if (!skb_queue_empty(&tp->out_of_order_queue)) {
-		NET_INC_STATS_BH(LINUX_MIB_OFOPRUNED);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_OFOPRUNED);
 		__skb_queue_purge(&tp->out_of_order_queue);
 
 		/* Reset SACK state.  A conforming SACK implementation will
@@ -4341,7 +4342,7 @@ static int tcp_prune_queue(struct sock *sk)
 
 	SOCK_DEBUG(sk, "prune_queue: c=%x\n", tp->copied_seq);
 
-	NET_INC_STATS_BH(LINUX_MIB_PRUNECALLED);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PRUNECALLED);
 
 	if (atomic_read(&sk->sk_rmem_alloc) >= sk->sk_rcvbuf)
 		tcp_clamp_window(sk);
@@ -4370,7 +4371,7 @@ static int tcp_prune_queue(struct sock *sk)
 	 * drop receive data on the floor.  It will get retransmitted
 	 * and hopefully then we'll have sufficient space.
 	 */
-	NET_INC_STATS_BH(LINUX_MIB_RCVPRUNED);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_RCVPRUNED);
 
 	/* Massive buffer overcommit. */
 	tp->pred_flags = 0;
@@ -4837,7 +4838,7 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 
 					__skb_pull(skb, tcp_header_len);
 					tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
-					NET_INC_STATS_BH(LINUX_MIB_TCPHPHITSTOUSER);
+					NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPHPHITSTOUSER);
 				}
 				if (copied_early)
 					tcp_cleanup_rbuf(sk, skb->len);
@@ -4860,7 +4861,7 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				if ((int)skb->truesize > sk->sk_forward_alloc)
 					goto step5;
 
-				NET_INC_STATS_BH(LINUX_MIB_TCPHPHITS);
+				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPHPHITS);
 
 				/* Bulk data transfer: receiver */
 				__skb_pull(skb, tcp_header_len);
@@ -4904,7 +4905,7 @@ slow_path:
 	if (tcp_fast_parse_options(skb, th, tp) && tp->rx_opt.saw_tstamp &&
 	    tcp_paws_discard(sk, skb)) {
 		if (!th->rst) {
-			NET_INC_STATS_BH(LINUX_MIB_PAWSESTABREJECTED);
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSESTABREJECTED);
 			tcp_send_dupack(sk, skb);
 			goto discard;
 		}
@@ -4940,7 +4941,7 @@ slow_path:
 
 	if (th->syn && !before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt)) {
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
-		NET_INC_STATS_BH(LINUX_MIB_TCPABORTONSYN);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPABORTONSYN);
 		tcp_reset(sk);
 		return 1;
 	}
@@ -4996,7 +4997,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		if (tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
 		    !between(tp->rx_opt.rcv_tsecr, tp->retrans_stamp,
 			     tcp_time_stamp)) {
-			NET_INC_STATS_BH(LINUX_MIB_PAWSACTIVEREJECTED);
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSACTIVEREJECTED);
 			goto reset_and_undo;
 		}
 
@@ -5280,7 +5281,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 	if (tcp_fast_parse_options(skb, th, tp) && tp->rx_opt.saw_tstamp &&
 	    tcp_paws_discard(sk, skb)) {
 		if (!th->rst) {
-			NET_INC_STATS_BH(LINUX_MIB_PAWSESTABREJECTED);
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSESTABREJECTED);
 			tcp_send_dupack(sk, skb);
 			goto discard;
 		}
@@ -5309,7 +5310,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 	 *	Check for a SYN in window.
 	 */
 	if (th->syn && !before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt)) {
-		NET_INC_STATS_BH(LINUX_MIB_TCPABORTONSYN);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPABORTONSYN);
 		tcp_reset(sk);
 		return 1;
 	}
@@ -5391,7 +5392,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 					    (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
 					     after(TCP_SKB_CB(skb)->end_seq - th->fin, tp->rcv_nxt))) {
 						tcp_done(sk);
-						NET_INC_STATS_BH(LINUX_MIB_TCPABORTONDATA);
+						NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPABORTONDATA);
 						return 1;
 					}
 
@@ -5451,7 +5452,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		if (sk->sk_shutdown & RCV_SHUTDOWN) {
 			if (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
 			    after(TCP_SKB_CB(skb)->end_seq - th->fin, tp->rcv_nxt)) {
-				NET_INC_STATS_BH(LINUX_MIB_TCPABORTONDATA);
+				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPABORTONDATA);
 				tcp_reset(sk);
 				return 1;
 			}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e876312..29adc66 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -366,7 +366,7 @@ void tcp_v4_err(struct sk_buff *skb, u32 info)
 	 * servers this needs to be solved differently.
 	 */
 	if (sock_owned_by_user(sk))
-		NET_INC_STATS_BH(LINUX_MIB_LOCKDROPPEDICMPS);
+		NET_INC_STATS_BH(net, LINUX_MIB_LOCKDROPPEDICMPS);
 
 	if (sk->sk_state == TCP_CLOSE)
 		goto out;
@@ -375,7 +375,7 @@ void tcp_v4_err(struct sk_buff *skb, u32 info)
 	seq = ntohl(th->seq);
 	if (sk->sk_state != TCP_LISTEN &&
 	    !between(seq, tp->snd_una, tp->snd_nxt)) {
-		NET_INC_STATS_BH(LINUX_MIB_OUTOFWINDOWICMPS);
+		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 		goto out;
 	}
 
@@ -422,7 +422,7 @@ void tcp_v4_err(struct sk_buff *skb, u32 info)
 		BUG_TRAP(!req->sk);
 
 		if (seq != tcp_rsk(req)->snt_isn) {
-			NET_INC_STATS_BH(LINUX_MIB_OUTOFWINDOWICMPS);
+			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 			goto out;
 		}
 
@@ -1251,7 +1251,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 			if (get_seconds() < peer->tcp_ts_stamp + TCP_PAWS_MSL &&
 			    (s32)(peer->tcp_ts - req->ts_recent) >
 							TCP_PAWS_WINDOW) {
-				NET_INC_STATS_BH(LINUX_MIB_PAWSPASSIVEREJECTED);
+				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
 				goto drop_and_release;
 			}
 		}
@@ -1365,9 +1365,9 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	return newsk;
 
 exit_overflow:
-	NET_INC_STATS_BH(LINUX_MIB_LISTENOVERFLOWS);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
 exit:
-	NET_INC_STATS_BH(LINUX_MIB_LISTENDROPS);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	dst_release(dst);
 	return NULL;
 }
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 8b02b10..204c421 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -244,7 +244,7 @@ kill:
 	}
 
 	if (paws_reject)
-		NET_INC_STATS_BH(LINUX_MIB_PAWSESTABREJECTED);
+		NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_PAWSESTABREJECTED);
 
 	if (!th->rst) {
 		/* In this case we must reset the TIMEWAIT timer.
@@ -611,7 +611,7 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 		if (!(flg & TCP_FLAG_RST))
 			req->rsk_ops->send_ack(skb, req);
 		if (paws_reject)
-			NET_INC_STATS_BH(LINUX_MIB_PAWSESTABREJECTED);
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSESTABREJECTED);
 		return NULL;
 	}
 
@@ -695,7 +695,7 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 		}
 
 	embryonic_reset:
-		NET_INC_STATS_BH(LINUX_MIB_EMBRYONICRSTS);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_EMBRYONICRSTS);
 		if (!(flg & TCP_FLAG_RST))
 			req->rsk_ops->send_reset(sk, skb);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 176f070..36a1970 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1995,7 +1995,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 						mib_idx = LINUX_MIB_TCPFASTRETRANS;
 					else
 						mib_idx = LINUX_MIB_TCPSLOWSTARTRETRANS;
-					NET_INC_STATS_BH(mib_idx);
+					NET_INC_STATS_BH(sock_net(sk), mib_idx);
 
 					if (skb == tcp_write_queue_head(sk))
 						inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
@@ -2065,7 +2065,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 						  inet_csk(sk)->icsk_rto,
 						  TCP_RTO_MAX);
 
-		NET_INC_STATS_BH(LINUX_MIB_TCPFORWARDRETRANS);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPFORWARDRETRANS);
 	}
 }
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 6a480d1..328e0cf 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -48,7 +48,7 @@ static void tcp_write_err(struct sock *sk)
 	sk->sk_error_report(sk);
 
 	tcp_done(sk);
-	NET_INC_STATS_BH(LINUX_MIB_TCPABORTONTIMEOUT);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPABORTONTIMEOUT);
 }
 
 /* Do not allow orphaned sockets to eat all our resources.
@@ -89,7 +89,7 @@ static int tcp_out_of_resources(struct sock *sk, int do_reset)
 		if (do_reset)
 			tcp_send_active_reset(sk, GFP_ATOMIC);
 		tcp_done(sk);
-		NET_INC_STATS_BH(LINUX_MIB_TCPABORTONMEMORY);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPABORTONMEMORY);
 		return 1;
 	}
 	return 0;
@@ -179,7 +179,7 @@ static void tcp_delack_timer(unsigned long data)
 	if (sock_owned_by_user(sk)) {
 		/* Try again later. */
 		icsk->icsk_ack.blocked = 1;
-		NET_INC_STATS_BH(LINUX_MIB_DELAYEDACKLOCKED);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOCKED);
 		sk_reset_timer(sk, &icsk->icsk_delack_timer, jiffies + TCP_DELACK_MIN);
 		goto out_unlock;
 	}
@@ -198,7 +198,7 @@ static void tcp_delack_timer(unsigned long data)
 	if (!skb_queue_empty(&tp->ucopy.prequeue)) {
 		struct sk_buff *skb;
 
-		NET_INC_STATS_BH(LINUX_MIB_TCPSCHEDULERFAILED);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSCHEDULERFAILED);
 
 		while ((skb = __skb_dequeue(&tp->ucopy.prequeue)) != NULL)
 			sk->sk_backlog_rcv(sk, skb);
@@ -218,7 +218,7 @@ static void tcp_delack_timer(unsigned long data)
 			icsk->icsk_ack.ato      = TCP_ATO_MIN;
 		}
 		tcp_send_ack(sk);
-		NET_INC_STATS_BH(LINUX_MIB_DELAYEDACKS);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKS);
 	}
 	TCP_CHECK_TIMER(sk);
 
@@ -346,7 +346,7 @@ static void tcp_retransmit_timer(struct sock *sk)
 		} else {
 			mib_idx = LINUX_MIB_TCPTIMEOUTS;
 		}
-		NET_INC_STATS_BH(mib_idx);
+		NET_INC_STATS_BH(sock_net(sk), mib_idx);
 	}
 
 	if (tcp_use_frto(sk)) {
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index a9cc8ab..00a8a5f 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -210,11 +210,11 @@ unique:
 
 	if (twp != NULL) {
 		*twp = tw;
-		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
+		NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITRECYCLED);
 	} else if (tw != NULL) {
 		/* Silly. Should hash-dance instead... */
 		inet_twsk_deschedule(tw, death_row);
-		NET_INC_STATS_BH(LINUX_MIB_TIMEWAITRECYCLED);
+		NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITRECYCLED);
 
 		inet_twsk_put(tw);
 	}
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 3ecc115..6a68eeb 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -137,7 +137,7 @@ __u32 cookie_v6_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
 		;
 	*mssp = msstab[mssind] + 1;
 
-	NET_INC_STATS_BH(LINUX_MIB_SYNCOOKIESSENT);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
 
 	return secure_tcp_syn_cookie(&iph->saddr, &iph->daddr, th->source,
 				     th->dest, ntohl(th->seq),
@@ -177,11 +177,11 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	if (time_after(jiffies, tp->last_synq_overflow + TCP_TIMEOUT_INIT) ||
 		(mss = cookie_check(skb, cookie)) == 0) {
-		NET_INC_STATS_BH(LINUX_MIB_SYNCOOKIESFAILED);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESFAILED);
 		goto out;
 	}
 
-	NET_INC_STATS_BH(LINUX_MIB_SYNCOOKIESRECV);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESRECV);
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d58b83a..ca5b93a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -340,7 +340,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk))
-		NET_INC_STATS_BH(LINUX_MIB_LOCKDROPPEDICMPS);
+		NET_INC_STATS_BH(net, LINUX_MIB_LOCKDROPPEDICMPS);
 
 	if (sk->sk_state == TCP_CLOSE)
 		goto out;
@@ -349,7 +349,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	seq = ntohl(th->seq);
 	if (sk->sk_state != TCP_LISTEN &&
 	    !between(seq, tp->snd_una, tp->snd_nxt)) {
-		NET_INC_STATS_BH(LINUX_MIB_OUTOFWINDOWICMPS);
+		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 		goto out;
 	}
 
@@ -424,7 +424,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		BUG_TRAP(req->sk == NULL);
 
 		if (seq != tcp_rsk(req)->snt_isn) {
-			NET_INC_STATS_BH(LINUX_MIB_OUTOFWINDOWICMPS);
+			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 			goto out;
 		}
 
@@ -1449,9 +1449,9 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	return newsk;
 
 out_overflow:
-	NET_INC_STATS_BH(LINUX_MIB_LISTENOVERFLOWS);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
 out:
-	NET_INC_STATS_BH(LINUX_MIB_LISTENDROPS);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	if (opt && opt != np->opt)
 		sock_kfree_s(sk, opt, opt->tot_len);
 	dst_release(dst);
diff --git a/net/sctp/input.c b/net/sctp/input.c
index ed8834e..5ed93c0 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -486,7 +486,7 @@ struct sock *sctp_err_lookup(int family, struct sk_buff *skb,
 	 * servers this needs to be solved differently.
 	 */
 	if (sock_owned_by_user(sk))
-		NET_INC_STATS_BH(LINUX_MIB_LOCKDROPPEDICMPS);
+		NET_INC_STATS_BH(&init_net, LINUX_MIB_LOCKDROPPEDICMPS);
 
 	*app = asoc;
 	*tpp = transport;
-- 
1.5.5.1

