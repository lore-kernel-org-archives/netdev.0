From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2054 tcp_mark_head_lost()
Date: Mon, 3 Mar 2008 15:40:24 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803031525390.27064@kivilampi-30.cs.helsinki.fi>
References: <858077.97160.qm@web39709.mail.mud.yahoo.com>
 <20080223000310.4630daa8.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802271108290.13029@kivilampi-30.cs.helsinki.fi>
 <3d8471ca0802271056l320a7ee2m5227e114a968d483@mail.gmail.com>
 <Pine.LNX.4.64.0802272120430.1741@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0802281018480.32401@kivilampi-30.cs.helsinki.fi>
 <3d8471ca0803020420ka42319bu1b9888217c869d9d@mail.gmail.com>
 <Pine.LNX.4.64.0803021432200.17919@kivilampi-30.cs.helsinki.fi>
 <3d8471ca0803020515m1e4af9d9xd37a8912e58a4504@mail.gmail.com>
 <Pine.LNX.4.64.0803022145210.18020@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0803031025210.18640@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-662713104-1204487187=:18020"
Cc: Giangiacomo Mariotti <giangiacomo_mariotti@yahoo.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Guillaume Chazarain <guichaz@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ray Lee <ray-lk@madrabbit.org>, Chris Wedgwood <cw@f00f.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42351 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564AbYCCNk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 08:40:26 -0500
In-Reply-To: <Pine.LNX.4.64.0803031025210.18640@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0803031535420.28251@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-662713104-1204487187=:18020
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0803022146411.18020@kivilampi-30.cs.helsinki.fi>

On Mon, 3 Mar 2008, Ilpo Järvinen wrote:

> On Sun, 2 Mar 2008, Ilpo Järvinen wrote:
> 
> > On Sun, 2 Mar 2008, Guillaume Chazarain wrote:
> > 
> > >> On Sun, Mar 2, 2008 at 1:38 PM, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > >>> It does not contain any "KERNEL: assertion (packets <=
> > >> > tp->packets_out) failed at" line, so I'm afraid it's just noise.
> > 
> > Doh, you were right in this one...

I did some filtering among those and found out that some still point out 
bug (there might be indication of tcp_mark_head_lost inconsistency as 
well but it's nearly impossible to track with all the incorporated noise
which is causing which). ...I'll post the patch separately right after 
this.

> > ...I spoke too early, it was just that the verify call was placed into
> > a place where the fackets_out is not yet reduced (I had too many version 
> > of that patch when I first did that and probably picked wrong one of 
> > them as a starting point, I'm sorry about that). I'll send an updated 
> > patch tomorrow for you and also correct it so that I don't need to ask 
> > things like this again (as long as one pastes couple of first occuring 
> > stacktraces):
> 
> Here is the updated version... One of the stacktraces near the beginning 
> (2nd or later) should now contain the line where the trap fired rather 
> than having to figure that out from the stacktrace with eip address.
> 
> Andrew, this is a minor update for it which avoids spurious triggers in 
> tcp_clean_rtx_queue.

Argh, I thought I compile tested it by make net/ipv4/tcp_*.o but found 
typo there even after that... :-(

-- 
 i.

[PATCH] TCP debug S+L (for 2.6.25-rcs, incompatible with 2.6.24.y), v1.2

Debugs sacked & lost skb inconstencies in TCP write queue &
verifies fackets_out related variables.
---
 include/net/tcp.h     |   10 +++-
 net/ipv4/tcp_input.c  |   18 ++++++-
 net/ipv4/tcp_ipv4.c   |  131 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c |   23 ++++++--
 4 files changed, 174 insertions(+), 8 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7de4ea3..19192d8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -272,6 +272,9 @@ DECLARE_SNMP_STAT(struct tcp_mib, tcp_statistics);
 #define TCP_ADD_STATS_BH(field, val)	SNMP_ADD_STATS_BH(tcp_statistics, field, val)
 #define TCP_ADD_STATS_USER(field, val)	SNMP_ADD_STATS_USER(tcp_statistics, field, val)
 
+extern void tcp_print_queue(struct sock *sk);
+extern int			tcp_verify_wq(struct sock *sk);
+
 extern void			tcp_v4_err(struct sk_buff *skb, u32);
 
 extern void			tcp_shutdown (struct sock *sk, int how);
@@ -768,7 +771,12 @@ static inline __u32 tcp_current_ssthresh(const struct sock *sk)
 }
 
 /* Use define here intentionally to get WARN_ON location shown at the caller */
-#define tcp_verify_left_out(tp)	WARN_ON(tcp_left_out(tp) > tp->packets_out)
+#define tcp_verify_left_out(tp)		\
+	do {\
+		int res; \
+		res = tcp_verify_wq((struct sock *)tp); \
+		WARN_ON(res || tcp_left_out(tp) > tp->packets_out); \
+	} while(0)
 
 extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
 extern __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 19c449f..bb0bdda 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1426,8 +1426,10 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb,
 	int first_sack_index;
 
 	if (!tp->sacked_out) {
-		if (WARN_ON(tp->fackets_out))
+		if (WARN_ON(tp->fackets_out)) {
+			tcp_verify_left_out(tp);
 			tp->fackets_out = 0;
+		}
 		tcp_highest_sack_reset(sk);
 	}
 
@@ -2136,6 +2138,8 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int fast_rexmit)
 	struct sk_buff *skb;
 	int cnt;
 
+	tcp_verify_left_out(tp);
+
 	BUG_TRAP(packets <= tp->packets_out);
 	if (tp->lost_skb_hint) {
 		skb = tp->lost_skb_hint;
@@ -2501,6 +2505,8 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 				    (tcp_fackets_out(tp) > tp->reordering));
 	int fast_rexmit = 0;
 
+	tcp_verify_left_out(tp);
+
 	if (WARN_ON(!tp->packets_out && tp->sacked_out))
 		tp->sacked_out = 0;
 	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
@@ -2645,6 +2651,10 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	if (do_lost || (tcp_is_fack(tp) && tcp_head_timedout(sk)))
 		tcp_update_scoreboard(sk, fast_rexmit);
 	tcp_cwnd_down(sk, flag);
+
+	WARN_ON(tcp_write_queue_head(sk) == NULL);
+	WARN_ON(!tp->packets_out);
+
 	tcp_xmit_retransmit_queue(sk);
 }
 
@@ -2887,6 +2897,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets)
 		}
 	}
 
+	tcp_verify_left_out(tp);
+
 #if FASTRETRANS_DEBUG > 0
 	BUG_TRAP((int)tp->sacked_out >= 0);
 	BUG_TRAP((int)tp->lost_out >= 0);
@@ -3175,6 +3187,8 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	prior_fackets = tp->fackets_out;
 	prior_in_flight = tcp_packets_in_flight(tp);
 
+	tcp_verify_left_out(tp);
+
 	if (!(flag & FLAG_SLOWPATH) && after(ack, prior_snd_una)) {
 		/* Window is constant, pure forward advance.
 		 * No more checks are required.
@@ -3237,6 +3251,8 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP))
 		dst_confirm(sk->sk_dst_cache);
 
+	tcp_verify_left_out(tp);
+
 	return 1;
 
 no_queue:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 00156bf..d36c67c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -108,6 +108,137 @@ struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
 	.lhash_wait  = __WAIT_QUEUE_HEAD_INITIALIZER(tcp_hashinfo.lhash_wait),
 };
 
+void tcp_print_queue(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb;
+	char s[50+1];
+	char h[50+1];
+	int idx = 0;
+	int i;
+
+	i = 0;
+	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			printk(KERN_ERR "head %u %p\n", i, skb);
+		else
+			printk(KERN_ERR "skb %u %p\n", i, skb);
+		i++;
+	}
+
+	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
+
+		for (i = 0; i < tcp_skb_pcount(skb); i++) {
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) {
+				s[idx] = 'S';
+				if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+					s[idx] = 'B';
+
+			} else if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST) {
+				s[idx] = 'L';
+			} else {
+				s[idx] = ' ';
+			}
+			if (s[idx] != ' ' && skb->len < tp->mss_cache)
+				s[idx] += 'a' - 'A';
+
+			if (i == 0) {
+				if (skb == tcp_highest_sack(sk))
+					h[idx] = 'h';
+				else
+					h[idx] = '+';
+			} else {
+				h[idx] = '-';
+			}
+
+			if (++idx >= 50) {
+				s[idx] = 0;
+				h[idx] = 0;
+				printk(KERN_ERR "TCP wq(s) %s\n", s);
+				printk(KERN_ERR "TCP wq(h) %s\n", h);
+				idx = 0;
+			}
+		}
+	}
+	if (idx) {
+		s[idx] = '<';
+		s[idx+1] = 0;
+		h[idx] = '<';
+		h[idx+1] = 0;
+		printk(KERN_ERR "TCP wq(s) %s\n", s);
+		printk(KERN_ERR "TCP wq(h) %s\n", h);
+	}
+	printk(KERN_ERR "l%u s%u f%u p%u seq: su%u hs%u sn%u\n",
+		tp->lost_out, tp->sacked_out, tp->fackets_out, tp->packets_out,
+		tp->snd_una, tcp_highest_sack_seq(tp), tp->snd_nxt);
+}
+
+int tcp_verify_wq(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	u32 lost = 0;
+	u32 sacked = 0;
+	u32 packets = 0;
+	u32 fackets = 0;
+	int hs_valid = 0;
+	int inconsistent = 0;
+	struct sk_buff *skb;
+
+	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
+
+		if ((fackets == packets) && (skb == tp->highest_sack))
+			hs_valid = 1;
+
+		packets += tcp_skb_pcount(skb);
+
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) {
+			sacked += tcp_skb_pcount(skb);
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+				printk(KERN_ERR "Sacked bitmap S+L: %u %u-%u/%u\n",
+					TCP_SKB_CB(skb)->sacked,
+					TCP_SKB_CB(skb)->end_seq - tp->snd_una,
+					TCP_SKB_CB(skb)->seq - tp->snd_una,
+					tp->snd_una);
+			fackets = packets;
+			hs_valid = 0;
+		}
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+			lost += tcp_skb_pcount(skb);
+	}
+
+	if ((fackets == packets) && (tp->highest_sack == tcp_send_head(sk)))
+		hs_valid = 1;
+
+	if ((lost != tp->lost_out) ||
+	    (tcp_is_sack(tp) && (sacked != tp->sacked_out)) ||
+	    ((sacked || (tcp_is_sack(tp) && tp->sacked_out)) && !hs_valid) ||
+	    (packets != tp->packets_out) ||
+	    (fackets != tp->fackets_out) ||
+	    tcp_left_out(tp) > tp->packets_out) {
+		printk(KERN_ERR "P: %u L: %u vs %u S: %u vs %u F: %u vs %u w: %u-%u (%u)\n",
+			tp->packets_out,
+			lost, tp->lost_out,
+			sacked, tp->sacked_out,
+			fackets, tp->fackets_out,
+			tp->snd_una, tp->snd_nxt,
+			tp->rx_opt.sack_ok);
+		tcp_print_queue(sk);
+		inconsistent = 1;
+	}
+
+	WARN_ON(lost != tp->lost_out);
+	WARN_ON(tcp_is_sack(tp) && (sacked != tp->sacked_out));
+	WARN_ON(packets != tp->packets_out);
+	WARN_ON(fackets != tp->fackets_out);
+	WARN_ON(tcp_left_out(tp) > tp->packets_out);
+
+	return inconsistent;
+}
+
 static inline __u32 tcp_v4_init_sequence(struct sk_buff *skb)
 {
 	return secure_tcp_sequence_number(ip_hdr(skb)->daddr,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ed750f9..257de86 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -779,10 +779,9 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 			tp->lost_out -= diff;
 
 		/* Adjust Reno SACK estimate. */
-		if (tcp_is_reno(tp) && diff > 0) {
+		if (tcp_is_reno(tp) && diff > 0)
 			tcp_dec_pcount_approx_int(&tp->sacked_out, diff);
-			tcp_verify_left_out(tp);
-		}
+
 		tcp_adjust_fackets_out(sk, skb, diff);
 	}
 
@@ -790,6 +789,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 	skb_header_release(buff);
 	tcp_insert_write_queue_after(skb, buff, sk);
 
+	tcp_verify_left_out(tp);
+
 	return 0;
 }
 
@@ -1463,6 +1464,7 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle)
 	} else if (result > 0) {
 		sent_pkts = 1;
 	}
+	tcp_verify_left_out(tp);
 
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
@@ -1764,6 +1766,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb,
 	tcp_clear_retrans_hints_partial(tp);
 
 	sk_wmem_free_skb(sk, next_skb);
+	tcp_verify_left_out(tp);
 }
 
 /* Do a simple retransmit without using the backoff mechanisms in
@@ -1795,13 +1798,13 @@ void tcp_simple_retransmit(struct sock *sk)
 		}
 	}
 
+	tcp_verify_left_out(tp);
+
 	tcp_clear_all_retrans_hints(tp);
 
 	if (!lost)
 		return;
 
-	tcp_verify_left_out(tp);
-
 	/* Don't muck with the congestion window here.
 	 * Reason is that we do not increase amount of _data_
 	 * in network, but units changed and effective
@@ -1888,6 +1891,8 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 			tcp_init_nondata_skb(skb, TCP_SKB_CB(skb)->end_seq - 1,
 					     TCP_SKB_CB(skb)->flags);
 			skb->ip_summed = CHECKSUM_NONE;
+
+			tcp_verify_left_out(tp);
 		}
 	}
 
@@ -1970,8 +1975,10 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 			 * packet to be MSS sized and all the
 			 * packet counting works out.
 			 */
-			if (tcp_packets_in_flight(tp) >= tp->snd_cwnd)
+			if (tcp_packets_in_flight(tp) >= tp->snd_cwnd) {
+				tcp_verify_left_out(tp);
 				return;
+			}
 
 			if (sacked & TCPCB_LOST) {
 				if (!(sacked & (TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))) {
@@ -1997,6 +2004,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		}
 	}
 
+	tcp_verify_left_out(tp);
+
 	/* OK, demanded retransmission is finished. */
 
 	/* Forward retransmissions are possible only during Recovery. */
@@ -2054,6 +2063,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 
 		NET_INC_STATS_BH(LINUX_MIB_TCPFORWARDRETRANS);
 	}
+
+	tcp_verify_left_out(tp);
 }
 
 /* Send a fin.  The caller locks the socket for us.  This cannot be
-- 
1.5.2.2

---696243703-662713104-1204487187=:18020--
