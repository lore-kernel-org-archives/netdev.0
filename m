From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] TCP Vegas for 2.6
Date: Mon, 8 Mar 2004 13:04:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040308130454.0442c04d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net <linux-net@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is an updated version of the TCP vegas patches for 2.6.4-rc2-bk4.
TCP Vegas provides better congestion control especially over higher speed and
long latency networks. There is lots of research and papers on TCP Vegas so
if you are interested just do a little searching.

This is a consolidation of earlier work done by Neal Cardwell;
and version from David Miller; as well as the version in net100/web100 by 
Florence M Fowler and Tom Dunigan.

It has been tested on 1G Ethernet and over a hybrid Ethernet/PPP network, but
would like people with higher speed or long haul networks to give it a try as well.

To enable vegas you need to:
	echo 1 >/proc/sys/net/ipv4/tcp_vegas_cong_avoid

diff -uprN -X dontdiff linux-2.6/include/linux/sysctl.h tcp-vegas-2.6/include/linux/sysctl.h
--- linux-2.6/include/linux/sysctl.h	2004-03-08 08:32:58.000000000 -0800
+++ tcp-vegas-2.6/include/linux/sysctl.h	2004-03-08 10:12:21.000000000 -0800
@@ -322,6 +322,10 @@ enum
 	NET_IPV4_IPFRAG_SECRET_INTERVAL=94,
 	NET_TCP_WESTWOOD=95,
 	NET_IPV4_IGMP_MAX_MSF=96,
+	NET_TCP_VEGAS=97,
+	NET_TCP_VEGAS_ALPHA=98,
+	NET_TCP_VEGAS_BETA=99,
+	NET_TCP_VEGAS_GAMMA=100,
 };
 
 enum {
diff -uprN -X dontdiff linux-2.6/include/linux/tcp.h tcp-vegas-2.6/include/linux/tcp.h
--- linux-2.6/include/linux/tcp.h	2004-02-05 14:44:29.000000000 -0800
+++ tcp-vegas-2.6/include/linux/tcp.h	2004-03-08 10:01:47.000000000 -0800
@@ -388,6 +388,17 @@ struct tcp_opt {
                 __u32    rtt;
                 __u32    rtt_min;          /* minimum observed RTT */
         } westwood;
+/* Vegas variables */
+	struct {
+		__u32	beg_snd_nxt;	/* right edge during last RTT */
+		__u32	beg_snd_una;	/* left edge  during last RTT */
+		__u32	beg_snd_cwnd;	/* saves the size of the cwnd */
+		__u8	do_vegas;	/* do vegas for this connection */
+		__u8	doing_vegas_now;/* if true, do vegas for this RTT */
+		__u16	cntRTT;		/* # of RTTs measured within last RTT */
+		__u32	minRTT;		/* min of RTTs measured within last RTT (in usec) */
+		__u32	baseRTT;	/* the min of all Vegas RTT measurements seen (in usec) */
+	} vegas;
 };
 
 /* WARNING: don't change the layout of the members in tcp_sock! */
diff -uprN -X dontdiff linux-2.6/include/net/tcp.h tcp-vegas-2.6/include/net/tcp.h
--- linux-2.6/include/net/tcp.h	2004-03-01 08:55:47.000000000 -0800
+++ tcp-vegas-2.6/include/net/tcp.h	2004-03-08 09:43:06.000000000 -0800
@@ -583,6 +583,10 @@ extern int sysctl_tcp_tw_reuse;
 extern int sysctl_tcp_frto;
 extern int sysctl_tcp_low_latency;
 extern int sysctl_tcp_westwood;
+extern int sysctl_tcp_vegas_cong_avoid;
+extern int sysctl_tcp_vegas_alpha;
+extern int sysctl_tcp_vegas_beta;
+extern int sysctl_tcp_vegas_gamma;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
@@ -1211,6 +1215,72 @@ static inline __u32 tcp_recalc_ssthresh(
 	return max(tp->snd_cwnd >> 1U, 2U);
 }
 
+/* Stop taking Vegas samples for now. */
+#define tcp_vegas_disable(__tp)	((__tp)->vegas.doing_vegas_now = 0)
+
+/* Is this TCP connection using Vegas (regardless of whether it is taking
+ * Vegas measurements at the current time)?
+ */
+#define tcp_is_vegas(__tp)	((__tp)->vegas.do_vegas)
+    
+static inline void tcp_vegas_enable(struct tcp_opt *tp)
+{
+	/* There are several situations when we must "re-start" Vegas:
+	 *
+	 *  o when a connection is established
+	 *  o after an RTO
+	 *  o after fast recovery
+	 *  o when we send a packet and there is no outstanding
+	 *    unacknowledged data (restarting an idle connection)
+	 *
+	 * In these circumstances we cannot do a Vegas calculation at the
+	 * end of the first RTT, because any calculation we do is using
+	 * stale info -- both the saved cwnd and congestion feedback are
+	 * stale.
+	 *
+	 * Instead we must wait until the completion of an RTT during
+	 * which we actually receive ACKs.
+	 */
+    
+	/* Begin taking Vegas samples next time we send something. */
+	tp->vegas.doing_vegas_now = 1;
+     
+	/* Set the beginning of the next send window. */
+	tp->vegas.beg_snd_nxt = tp->snd_nxt;
+
+	tp->vegas.cntRTT = 0;
+	tp->vegas.minRTT = 0x7fffffff;
+}
+
+static inline void tcp_set_ca_state(struct tcp_opt *tp, u8 ca_state)
+{
+	if (tcp_is_vegas(tp)) {
+		if (ca_state == TCP_CA_Open) 
+			tcp_vegas_enable(tp);
+		else
+			tcp_vegas_disable(tp);
+	}
+	tp->ca_state = ca_state;
+}
+
+/* Should we be taking Vegas samples right now? */
+#define tcp_vegas_enabled(__tp)	((__tp)->vegas.doing_vegas_now)
+
+static inline void tcp_vegas_init(struct tcp_opt *tp)
+{
+	/* Set up a new TCP connection, depending on whether it should be
+	 * using Vegas or not.
+	 */    
+	if (sysctl_tcp_vegas_cong_avoid) {
+		tp->vegas.do_vegas = 1;
+		tp->vegas.baseRTT = 0x7fffffff;
+		tcp_vegas_enable(tp);
+	} else {
+		tp->vegas.do_vegas = 0;
+		tcp_vegas_disable(tp);
+	}
+}
+
 /* If cwnd > ssthresh, we may raise ssthresh to be half-way to cwnd.
  * The exception is rate halving phase, when cwnd is decreasing towards
  * ssthresh.
@@ -1270,7 +1340,7 @@ static inline void tcp_enter_cwr(struct 
 	tp->prior_ssthresh = 0;
 	if (tp->ca_state < TCP_CA_CWR) {
 		__tcp_enter_cwr(tp);
-		tp->ca_state = TCP_CA_CWR;
+		tcp_set_ca_state(tp, TCP_CA_CWR);
 	}
 }
 
@@ -2086,4 +2156,5 @@ static inline int tcp_westwood_cwnd(stru
 
 	return (cwnd != 0);
 }
+ 
 #endif	/* _TCP_H */
diff -uprN -X dontdiff linux-2.6/net/ipv4/sysctl_net_ipv4.c tcp-vegas-2.6/net/ipv4/sysctl_net_ipv4.c
--- linux-2.6/net/ipv4/sysctl_net_ipv4.c	2004-03-08 08:32:59.000000000 -0800
+++ tcp-vegas-2.6/net/ipv4/sysctl_net_ipv4.c	2004-03-08 10:12:22.000000000 -0800
@@ -601,6 +601,38 @@ ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_TCP_VEGAS,
+		.procname	= "tcp_vegas_cong_avoid",
+		.data		= &sysctl_tcp_vegas_cong_avoid,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_TCP_VEGAS_ALPHA,
+		.procname	= "tcp_vegas_alpha",
+		.data		= &sysctl_tcp_vegas_alpha,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_TCP_VEGAS_BETA,
+		.procname	= "tcp_vegas_beta",
+		.data		= &sysctl_tcp_vegas_beta,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_TCP_VEGAS_GAMMA,
+		.procname	= "tcp_vegas_gamma",
+		.data		= &sysctl_tcp_vegas_gamma,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };
 
diff -uprN -X dontdiff linux-2.6/net/ipv4/tcp.c tcp-vegas-2.6/net/ipv4/tcp.c
--- linux-2.6/net/ipv4/tcp.c	2004-03-02 08:59:43.000000000 -0800
+++ tcp-vegas-2.6/net/ipv4/tcp.c	2004-03-02 13:41:22.000000000 -0800
@@ -2158,7 +2158,7 @@ int tcp_disconnect(struct sock *sk, int 
 	tp->packets_out = 0;
 	tp->snd_ssthresh = 0x7fffffff;
 	tp->snd_cwnd_cnt = 0;
-	tp->ca_state = TCP_CA_Open;
+	tcp_set_ca_state(tp, TCP_CA_Open);
 	tcp_clear_retrans(tp);
 	tcp_delack_init(tp);
 	tp->send_head = NULL;
diff -uprN -X dontdiff linux-2.6/net/ipv4/tcp_input.c tcp-vegas-2.6/net/ipv4/tcp_input.c
--- linux-2.6/net/ipv4/tcp_input.c	2004-02-05 14:44:30.000000000 -0800
+++ tcp-vegas-2.6/net/ipv4/tcp_input.c	2004-03-08 12:40:41.000000000 -0800
@@ -91,6 +91,15 @@ int sysctl_tcp_rfc1337;
 int sysctl_tcp_max_orphans = NR_FILE;
 int sysctl_tcp_frto;
 int sysctl_tcp_westwood;
+int sysctl_tcp_vegas_cong_avoid;
+
+/* Default values of the Vegas variables, in fixed-point representation
+ * with V_PARAM_SHIFT bits to the right of the binary point.
+ */
+#define V_PARAM_SHIFT 1
+int sysctl_tcp_vegas_alpha = 1<<V_PARAM_SHIFT;
+int sysctl_tcp_vegas_beta  = 3<<V_PARAM_SHIFT;
+int sysctl_tcp_vegas_gamma = 1<<V_PARAM_SHIFT;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
@@ -407,6 +416,29 @@ static void tcp_event_data_recv(struct s
 		tcp_grow_window(sk, tp, skb);
 }
 
+/* Do RTT sampling needed for Vegas.
+ * Basically we:
+ *   o min-filter RTT samples from within an RTT to get the current
+ *     propagation delay + queuing delay (we are min-filtering to try to
+ *     avoid the effects of delayed ACKs)
+ *   o min-filter RTT samples from a much longer window (forever for now)
+ *     to find the propagation delay (baseRTT)
+ */
+static inline void vegas_rtt_calc(struct tcp_opt *tp, __u32 rtt)
+{
+	__u32 vrtt = rtt + 1; /* Never allow zero rtt or baseRTT */
+
+	/* Filter to find propagation delay: */
+	if (vrtt < tp->vegas.baseRTT) 
+		tp->vegas.baseRTT = vrtt;
+
+	/* Find the min RTT during the last RTT to find
+	 * the current prop. delay + queuing delay:
+	 */
+	tp->vegas.minRTT = min(tp->vegas.minRTT, vrtt);
+	tp->vegas.cntRTT++;
+}
+
 /* Called to compute a smoothed rtt estimate. The data fed to this
  * routine either comes from timestamps, or from segments that were
  * known _not_ to have been retransmitted [see Karn/Partridge
@@ -420,6 +452,9 @@ static void tcp_rtt_estimator(struct tcp
 {
 	long m = mrtt; /* RTT */
 
+	if (tcp_vegas_enabled(tp))
+		vegas_rtt_calc(tp, mrtt);
+
 	/*	The following amusing code comes from Jacobson's
 	 *	article in SIGCOMM '88.  Note that rtt and mdev
 	 *	are scaled versions of rtt and mean deviation.
@@ -1003,7 +1038,7 @@ void tcp_enter_frto(struct sock *sk)
 	}
 	tcp_sync_left_out(tp);
 
-	tp->ca_state = TCP_CA_Open;
+	tcp_set_ca_state(tp, TCP_CA_Open);
 	tp->frto_highmark = tp->snd_nxt;
 }
 
@@ -1049,7 +1084,7 @@ void tcp_enter_frto_loss(struct sock *sk
 
 	tp->reordering = min_t(unsigned int, tp->reordering,
 					     sysctl_tcp_reordering);
-	tp->ca_state = TCP_CA_Loss;
+	tcp_set_ca_state(tp, TCP_CA_Loss);
 	tp->high_seq = tp->frto_highmark;
 	TCP_ECN_queue_cwr(tp);
 }
@@ -1112,7 +1147,7 @@ void tcp_enter_loss(struct sock *sk, int
 
 	tp->reordering = min_t(unsigned int, tp->reordering,
 					     sysctl_tcp_reordering);
-	tp->ca_state = TCP_CA_Loss;
+	tcp_set_ca_state(tp, TCP_CA_Loss);
 	tp->high_seq = tp->snd_nxt;
 	TCP_ECN_queue_cwr(tp);
 }
@@ -1489,7 +1524,7 @@ static int tcp_try_undo_recovery(struct 
 		tcp_moderate_cwnd(tp);
 		return 1;
 	}
-	tp->ca_state = TCP_CA_Open;
+	tcp_set_ca_state(tp, TCP_CA_Open);
 	return 0;
 }
 
@@ -1549,7 +1584,7 @@ static int tcp_try_undo_loss(struct sock
 		tp->retransmits = 0;
 		tp->undo_marker = 0;
 		if (!IsReno(tp))
-			tp->ca_state = TCP_CA_Open;
+			tcp_set_ca_state(tp, TCP_CA_Open);
 		return 1;
 	}
 	return 0;
@@ -1583,7 +1618,7 @@ static void tcp_try_to_open(struct sock 
 			state = TCP_CA_Disorder;
 
 		if (tp->ca_state != state) {
-			tp->ca_state = state;
+			tcp_set_ca_state(tp, state);
 			tp->high_seq = tp->snd_nxt;
 		}
 		tcp_moderate_cwnd(tp);
@@ -1658,7 +1693,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 			 * is ACKed for CWR bit to reach receiver. */
 			if (tp->snd_una != tp->high_seq) {
 				tcp_complete_cwr(tp);
-				tp->ca_state = TCP_CA_Open;
+				tcp_set_ca_state(tp, TCP_CA_Open);
 			}
 			break;
 
@@ -1669,7 +1704,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 			     * catching for all duplicate ACKs. */
 			    IsReno(tp) || tp->snd_una != tp->high_seq) {
 				tp->undo_marker = 0;
-				tp->ca_state = TCP_CA_Open;
+				tcp_set_ca_state(tp, TCP_CA_Open);
 			}
 			break;
 
@@ -1743,7 +1778,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 		}
 
 		tp->snd_cwnd_cnt = 0;
-		tp->ca_state = TCP_CA_Recovery;
+		tcp_set_ca_state(tp, TCP_CA_Recovery);
 	}
 
 	if (is_dupack || tcp_head_timedout(sk, tp))
@@ -1814,7 +1849,7 @@ tcp_ack_update_rtt(struct tcp_opt *tp, i
 /* This is Jacobson's slow start and congestion avoidance. 
  * SIGCOMM '88, p. 328.
  */
-static __inline__ void tcp_cong_avoid(struct tcp_opt *tp)
+static __inline__ void reno_cong_avoid(struct tcp_opt *tp)
 {
         if (tp->snd_cwnd <= tp->snd_ssthresh) {
                 /* In "safe" area, increase. */
@@ -1834,6 +1869,236 @@ static __inline__ void tcp_cong_avoid(st
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
+/* This is based on the congestion detection/avoidance scheme described in
+ *    Lawrence S. Brakmo and Larry L. Peterson.
+ *    "TCP Vegas: End to end congestion avoidance on a global internet."
+ *    IEEE Journal on Selected Areas in Communication, 13(8):1465--1480,
+ *    October 1995. Available from:
+ *	ftp://ftp.cs.arizona.edu/xkernel/Papers/jsac.ps
+ *
+ * See http://www.cs.arizona.edu/xkernel/ for their implementation.
+ * The main aspects that distinguish this implementation from the
+ * Arizona Vegas implementation are:
+ *   o We do not change the loss detection or recovery mechanisms of
+ *     Linux in any way. Linux already recovers from losses quite well,
+ *     using fine-grained timers, NewReno, and FACK.
+ *   o To avoid the performance penalty imposed by increasing cwnd
+ *     only every-other RTT during slow start, we increase during
+ *     every RTT during slow start, just like Reno.
+ *   o Largely to allow continuous cwnd growth during slow start,
+ *     we use the rate at which ACKs come back as the "actual"
+ *     rate, rather than the rate at which data is sent.
+ *   o To speed convergence to the right rate, we set the cwnd
+ *     to achieve the right ("actual") rate when we exit slow start.
+ *   o To filter out the noise caused by delayed ACKs, we use the
+ *     minimum RTT sample observed during the last RTT to calculate
+ *     the actual rate.
+ *   o When the sender re-starts from idle, it waits until it has
+ *     received ACKs for an entire flight of new data before making
+ *     a cwnd adjustment decision. The original Vegas implementation
+ *     assumed senders never went idle.
+ */
+static void vegas_cong_avoid(struct tcp_opt *tp, u32 ack, u32 seq_rtt)
+{
+	/* The key players are v_beg_snd_una and v_beg_snd_nxt.
+	 *
+	 * These are so named because they represent the approximate values
+	 * of snd_una and snd_nxt at the beginning of the current RTT. More
+	 * precisely, they represent the amount of data sent during the RTT.
+	 * At the end of the RTT, when we receive an ACK for v_beg_snd_nxt,
+	 * we will calculate that (v_beg_snd_nxt - v_beg_snd_una) outstanding
+	 * bytes of data have been ACKed during the course of the RTT, giving
+	 * an "actual" rate of:
+	 *
+	 *     (v_beg_snd_nxt - v_beg_snd_una) / (rtt duration)
+	 *
+	 * Unfortunately, v_beg_snd_una is not exactly equal to snd_una,
+	 * because delayed ACKs can cover more than one segment, so they
+	 * don't line up nicely with the boundaries of RTTs.
+	 *
+	 * Another unfortunate fact of life is that delayed ACKs delay the
+	 * advance of the left edge of our send window, so that the number
+	 * of bytes we send in an RTT is often less than our cwnd will allow.
+	 * So we keep track of our cwnd separately, in v_beg_snd_cwnd.
+	 */
+
+	if (after(ack, tp->vegas.beg_snd_nxt)) {
+		/* Do the Vegas once-per-RTT cwnd adjustment. */
+		u32 old_wnd, old_snd_cwnd;
+
+		
+		/* Here old_wnd is essentially the window of data that was
+		 * sent during the previous RTT, and has all
+		 * been acknowledged in the course of the RTT that ended
+		 * with the ACK we just received. Likewise, old_snd_cwnd
+		 * is the cwnd during the previous RTT.
+		 */
+		old_wnd = (tp->vegas.beg_snd_nxt - tp->vegas.beg_snd_una) /
+			tp->mss_cache;
+		old_snd_cwnd = tp->vegas.beg_snd_cwnd;
+
+		/* Save the extent of the current window so we can use this
+		 * at the end of the next RTT.
+		 */
+		tp->vegas.beg_snd_una  = tp->vegas.beg_snd_nxt;
+		tp->vegas.beg_snd_nxt  = tp->snd_nxt;
+		tp->vegas.beg_snd_cwnd = tp->snd_cwnd;
+
+		/* Take into account the current RTT sample too, to
+		 * decrease the impact of delayed acks. This double counts
+		 * this sample since we count it for the next window as well,
+		 * but that's not too awful, since we're taking the min,
+		 * rather than averaging.
+		 */
+		vegas_rtt_calc(tp, seq_rtt);
+
+		/* We do the Vegas calculations only if we got enough RTT
+		 * samples that we can be reasonably sure that we got
+		 * at least one RTT sample that wasn't from a delayed ACK.
+		 * If we only had 2 samples total,
+		 * then that means we're getting only 1 ACK per RTT, which
+		 * means they're almost certainly delayed ACKs.
+		 * If  we have 3 samples, we should be OK.
+		 */
+
+		if (tp->vegas.cntRTT <= 2) {
+			/* We don't have enough RTT samples to do the Vegas
+			 * calculation, so we'll behave like Reno.
+			 */
+			if (tp->snd_cwnd > tp->snd_ssthresh)
+				tp->snd_cwnd++;
+		} else {
+			u32 rtt, target_cwnd, diff;
+
+			/* We have enough RTT samples, so, using the Vegas
+			 * algorithm, we determine if we should increase or
+			 * decrease cwnd, and by how much.
+			 */
+
+			/* Pluck out the RTT we are using for the Vegas
+			 * calculations. This is the min RTT seen during the
+			 * last RTT. Taking the min filters out the effects
+			 * of delayed ACKs, at the cost of noticing congestion
+			 * a bit later.
+			 */
+			rtt = tp->vegas.minRTT;
+
+			/* Calculate the cwnd we should have, if we weren't
+			 * going too fast.
+			 *
+			 * This is:
+			 *     (actual rate in segments) * baseRTT
+			 * We keep it as a fixed point number with
+			 * V_PARAM_SHIFT bits to the right of the binary point.
+			 */
+			target_cwnd = ((old_wnd * tp->vegas.baseRTT)
+				       << V_PARAM_SHIFT) / rtt;
+
+			/* Calculate the difference between the window we had,
+			 * and the window we would like to have. This quantity
+			 * is the "Diff" from the Arizona Vegas papers.
+			 *
+			 * Again, this is a fixed point number with
+			 * V_PARAM_SHIFT bits to the right of the binary
+			 * point.
+			 */
+			diff = (old_wnd << V_PARAM_SHIFT) - target_cwnd;
+
+			if (tp->snd_cwnd < tp->snd_ssthresh) {
+				/* Slow start.  */
+				if (diff > sysctl_tcp_vegas_gamma) {
+					/* Going too fast. Time to slow down
+					 * and switch to congestion avoidance.
+					 */
+					tp->snd_ssthresh = 2;
+
+					/* Set cwnd to match the actual rate
+					 * exactly:
+					 *   cwnd = (actual rate) * baseRTT
+					 * Then we add 1 because the integer
+					 * truncation robs us of full link
+					 * utilization.
+					 */
+					tp->snd_cwnd = min(tp->snd_cwnd,
+							   (target_cwnd >>
+							    V_PARAM_SHIFT)+1);
+
+				}
+			} else {
+				/* Congestion avoidance. */
+				u32 next_snd_cwnd;
+
+				/* Figure out where we would like cwnd
+				 * to be.
+				 */
+				if (diff > sysctl_tcp_vegas_beta) {
+					/* The old window was too fast, so
+					 * we slow down.
+					 */
+					next_snd_cwnd = old_snd_cwnd - 1;
+				} else if (diff < sysctl_tcp_vegas_alpha) {
+					/* We don't have enough extra packets
+					 * in the network, so speed up.
+					 */
+					next_snd_cwnd = old_snd_cwnd + 1;
+				} else {
+					/* Sending just as fast as we
+					 * should be.
+					 */
+					next_snd_cwnd = old_snd_cwnd;
+				}
+
+				/* Adjust cwnd upward or downward, toward the
+				 * desired value.
+				 */
+				if (next_snd_cwnd > tp->snd_cwnd)
+					tp->snd_cwnd++;
+				else if (next_snd_cwnd < tp->snd_cwnd)
+					tp->snd_cwnd--;
+			}
+		}
+
+		/* Wipe the slate clean for the next RTT. */
+		tp->vegas.cntRTT = 0;
+		tp->vegas.minRTT = 0x7fffffff;
+	}
+
+	/* The following code is executed for every ack we receive,
+	 * except for conditions checked in should_advance_cwnd()
+	 * before the call to tcp_cong_avoid(). Mainly this means that
+	 * we only execute this code if the ack actually acked some
+	 * data.
+	 */
+
+	/* If we are in slow start, increase our cwnd in response to this ACK.
+	 * (If we are not in slow start then we are in congestion avoidance,
+	 * and adjust our congestion window only once per RTT. See the code
+	 * above.)
+	 */
+	if (tp->snd_cwnd <= tp->snd_ssthresh) 
+		tp->snd_cwnd++;
+
+	/* to keep cwnd from growing without bound */
+	tp->snd_cwnd = min_t(u32, tp->snd_cwnd, tp->snd_cwnd_clamp);
+
+	/* Make sure that we are never so timid as to reduce our cwnd below
+	 * 2 MSS.
+	 *
+	 * Going below 2 MSS would risk huge delayed ACKs from our receiver.
+	 */
+	tp->snd_cwnd = max(tp->snd_cwnd, 2U);
+
+	tp->snd_cwnd_stamp = tcp_time_stamp;
+}
+
+static inline void tcp_cong_avoid(struct tcp_opt *tp, u32 ack, u32 seq_rtt)
+{
+	if (tcp_vegas_enabled(tp))
+		vegas_cong_avoid(tp, ack, seq_rtt);
+	else
+		reno_cong_avoid(tp);
+}
+
 /* Restart timer after forward progress on connection.
  * RFC2988 recommends to restart timer to now+rto.
  */
@@ -1848,7 +2113,7 @@ static __inline__ void tcp_ack_packets_o
 }
 
 /* Remove acknowledged frames from the retransmission queue. */
-static int tcp_clean_rtx_queue(struct sock *sk)
+static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct sk_buff *skb;
@@ -1934,6 +2199,7 @@ static int tcp_clean_rtx_queue(struct so
 		}
 	}
 #endif
+	*seq_rtt_p = seq_rtt;
 	return acked;
 }
 
@@ -2294,6 +2560,7 @@ static int tcp_ack(struct sock *sk, stru
 	u32 ack_seq = TCP_SKB_CB(skb)->seq;
 	u32 ack = TCP_SKB_CB(skb)->ack_seq;
 	u32 prior_in_flight;
+	s32 seq_rtt;
 	int prior_packets;
 
 	/* If the ack is newer than sent or older than previous acks
@@ -2345,7 +2612,7 @@ static int tcp_ack(struct sock *sk, stru
 	prior_in_flight = tcp_packets_in_flight(tp);
 
 	/* See if we can take anything off of the retransmit queue. */
-	flag |= tcp_clean_rtx_queue(sk);
+	flag |= tcp_clean_rtx_queue(sk, &seq_rtt);
 
 	if (tp->frto_counter)
 		tcp_process_frto(sk, prior_snd_una);
@@ -2355,11 +2622,11 @@ static int tcp_ack(struct sock *sk, stru
 		if ((flag & FLAG_DATA_ACKED) &&
 		    prior_in_flight >= tp->snd_cwnd &&
 		    tcp_may_raise_cwnd(tp, flag))
-			tcp_cong_avoid(tp);
+			tcp_cong_avoid(tp, ack, seq_rtt);
 		tcp_fastretrans_alert(sk, prior_snd_una, prior_packets, flag);
 	} else {
 		if ((flag & FLAG_DATA_ACKED) && prior_in_flight >= tp->snd_cwnd)
-			tcp_cong_avoid(tp);
+			tcp_cong_avoid(tp, ack, seq_rtt);
 	}
 
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag&FLAG_NOT_DUP))
diff -uprN -X dontdiff linux-2.6/net/ipv4/tcp_minisocks.c tcp-vegas-2.6/net/ipv4/tcp_minisocks.c
--- linux-2.6/net/ipv4/tcp_minisocks.c	2004-03-01 08:55:47.000000000 -0800
+++ tcp-vegas-2.6/net/ipv4/tcp_minisocks.c	2004-03-08 09:33:16.000000000 -0800
@@ -769,7 +769,7 @@ struct sock *tcp_create_openreq_child(st
 		newtp->frto_counter = 0;
 		newtp->frto_highmark = 0;
 
-		newtp->ca_state = TCP_CA_Open;
+		tcp_set_ca_state(newtp, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
 		skb_queue_head_init(&newtp->out_of_order_queue);
 		newtp->send_head = NULL;
@@ -841,6 +841,8 @@ struct sock *tcp_create_openreq_child(st
 		if (newtp->ecn_flags&TCP_ECN_OK)
 			newsk->sk_no_largesend = 1;
 
+		tcp_vegas_init(newtp);
+
 		TCP_INC_STATS_BH(TcpPassiveOpens);
 	}
 	return newsk;
diff -uprN -X dontdiff linux-2.6/net/ipv4/tcp_output.c tcp-vegas-2.6/net/ipv4/tcp_output.c
--- linux-2.6/net/ipv4/tcp_output.c	2004-01-23 09:39:28.000000000 -0800
+++ tcp-vegas-2.6/net/ipv4/tcp_output.c	2004-03-08 10:20:19.000000000 -0800
@@ -105,7 +105,9 @@ static void tcp_cwnd_restart(struct tcp_
 	s32 delta = tcp_time_stamp - tp->lsndtime;
 	u32 restart_cwnd = tcp_init_cwnd(tp, dst);
 	u32 cwnd = tp->snd_cwnd;
-
+	
+	if (tcp_is_vegas(tp)) 
+		tcp_vegas_enable(tp);
 	tp->snd_ssthresh = tcp_current_ssthresh(tp);
 	restart_cwnd = min(restart_cwnd, cwnd);
 
@@ -225,6 +227,19 @@ int tcp_transmit_skb(struct sock *sk, st
 			tcp_header_size += (TCPOLEN_SACK_BASE_ALIGNED +
 					    (tp->eff_sacks * TCPOLEN_SACK_PERBLOCK));
 		}
+		
+		/*
+		 * If the connection is idle and we are restarting,
+		 * then we don't want to do any Vegas calculations
+		 * until we get fresh RTT samples.  So when we
+		 * restart, we reset our Vegas state to a clean
+		 * slate. After we get acks for this flight of
+		 * packets, _then_ we can make Vegas calculations
+		 * again.
+		 */
+		if (tcp_is_vegas(tp) && tcp_packets_in_flight(tp) == 0)
+			tcp_vegas_enable(tp);
+
 		th = (struct tcphdr *) skb_push(skb, tcp_header_size);
 		skb->h.th = th;
 		skb_set_owner_w(skb, sk);
@@ -869,7 +884,7 @@ void tcp_simple_retransmit(struct sock *
 		tp->snd_ssthresh = tcp_current_ssthresh(tp);
 		tp->prior_ssthresh = 0;
 		tp->undo_marker = 0;
-		tp->ca_state = TCP_CA_Loss;
+		tcp_set_ca_state(tp, TCP_CA_Loss);
 	}
 	tcp_xmit_retransmit_queue(sk);
 }
@@ -1268,6 +1283,7 @@ static inline void tcp_connect_init(stru
 		tp->window_clamp = dst_metric(dst, RTAX_WINDOW);
 	tp->advmss = dst_metric(dst, RTAX_ADVMSS);
 	tcp_initialize_rcv_mss(sk);
+	tcp_vegas_init(tp);
 
 	tcp_select_initial_window(tcp_full_space(sk),
 				  tp->advmss - (tp->ts_recent_stamp ? tp->tcp_header_len - sizeof(struct tcphdr) : 0),
@@ -1318,6 +1334,7 @@ int tcp_connect(struct sock *sk)
 	TCP_SKB_CB(buff)->end_seq = tp->write_seq;
 	tp->snd_nxt = tp->write_seq;
 	tp->pushed_seq = tp->write_seq;
+	tcp_vegas_init(tp);
 
 	/* Send it off. */
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
