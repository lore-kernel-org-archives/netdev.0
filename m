From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.24-rc8-mm1 : net tcp_input.c warnings
Date: Wed, 23 Jan 2008 10:41:14 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801231034300.31652@kivilampi-30.cs.helsinki.fi>
References: <a8e1da0801220109v6bf8931ev50f2210402c3ba41@mail.gmail.com>
 <Pine.LNX.4.64.0801221115150.31652@kivilampi-30.cs.helsinki.fi>
 <a8e1da0801221744m37021e88h5c188e5b31ea42bf@mail.gmail.com>
 <20080122.190137.206066966.davem@davemloft.net>
 <Pine.LNX.4.64.0801230937270.31652@kivilampi-30.cs.helsinki.fi>
 <a8e1da0801222344l101c2b90s363821c26bc8cb55@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-2498209-1201077674=:31652"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36973 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbYAWIlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 03:41:17 -0500
In-Reply-To: <a8e1da0801222344l101c2b90s363821c26bc8cb55@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2498209-1201077674=:31652
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 23 Jan 2008, Dave Young wrote:

> On Jan 23, 2008 3:41 PM, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> >
> > On Tue, 22 Jan 2008, David Miller wrote:
> >
> > > From: "Dave Young" <hidave.darkstar@gmail.com>
> > > Date: Wed, 23 Jan 2008 09:44:30 +0800
> > >
> > > > On Jan 22, 2008 6:47 PM, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > > > > [PATCH] [TCP]: debug S+L
> > > >
> > > > Thanks, If there's new findings I will let you know.
> > >
> > > Thanks for helping with this bug Dave.
> >
> > I noticed btw that there thing might (is likely to) spuriously trigger at
> > WARN_ON(sacked != tp->sacked_out); because those won't be equal when SACK
> > is not enabled. If that does happen too often, I send a fixed patch for
> > it, yet, the fact that I print print tp->rx_opt.sack_ok allows
> > identification of those cases already as it's zero when SACK is not
> > enabled.
> >
> > Just ask if you need the updated debug patch.
> 
> Thanks,  please send, I would like to get it.

There you go. I fixed non-SACK case by adding tcp_is_sack checks there and 
also added two verifys to tcp_ack to see if there's corruption outside of 
TCP.

-- 
 i.

[PATCH] [TCP]: debug S+L

---
 include/net/tcp.h     |    8 +++-
 net/ipv4/tcp_input.c  |   10 +++++
 net/ipv4/tcp_ipv4.c   |  101 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c |   21 +++++++---
 4 files changed, 133 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 7de4ea3..0685035 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -272,6 +272,8 @@ DECLARE_SNMP_STAT(struct tcp_mib, tcp_statistics);
 #define TCP_ADD_STATS_BH(field, val)	SNMP_ADD_STATS_BH(tcp_statistics, field, val)
 #define TCP_ADD_STATS_USER(field, val)	SNMP_ADD_STATS_USER(tcp_statistics, field, val)
 
+extern void			tcp_verify_wq(struct sock *sk);
+
 extern void			tcp_v4_err(struct sk_buff *skb, u32);
 
 extern void			tcp_shutdown (struct sock *sk, int how);
@@ -768,7 +770,11 @@ static inline __u32 tcp_current_ssthresh(const struct sock *sk)
 }
 
 /* Use define here intentionally to get WARN_ON location shown at the caller */
-#define tcp_verify_left_out(tp)	WARN_ON(tcp_left_out(tp) > tp->packets_out)
+#define tcp_verify_left_out(tp)	\
+	do { \
+		WARN_ON(tcp_left_out(tp) > tp->packets_out); \
+		tcp_verify_wq((struct sock *)tp); \
+	} while(0)
 
 extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
 extern __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fa2c85c..cdacf70 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2645,6 +2645,10 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	if (do_lost || (tcp_is_fack(tp) && tcp_head_timedout(sk)))
 		tcp_update_scoreboard(sk, fast_rexmit);
 	tcp_cwnd_down(sk, flag);
+
+	WARN_ON(tcp_write_queue_head(sk) == NULL);
+	WARN_ON(!tp->packets_out);
+
 	tcp_xmit_retransmit_queue(sk);
 }
 
@@ -2848,6 +2852,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets)
 		tcp_clear_all_retrans_hints(tp);
 	}
 
+	tcp_verify_left_out(tp);
+
 	if (skb && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
 		flag |= FLAG_SACK_RENEGING;
 
@@ -3175,6 +3181,8 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	prior_fackets = tp->fackets_out;
 	prior_in_flight = tcp_packets_in_flight(tp);
 
+	tcp_verify_left_out(tp);
+
 	if (!(flag & FLAG_SLOWPATH) && after(ack, prior_snd_una)) {
 		/* Window is constant, pure forward advance.
 		 * No more checks are required.
@@ -3237,6 +3245,8 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP))
 		dst_confirm(sk->sk_dst_cache);
 
+	tcp_verify_left_out(tp);
+
 	return 1;
 
 no_queue:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9aea88b..7e8ab40 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -108,6 +108,107 @@ struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
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
+				if (TCP_SKB_CB(skb)->seq == tcp_highest_sack_seq(tp))
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
+void tcp_verify_wq(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	u32 lost = 0;
+	u32 sacked = 0;
+	u32 packets = 0;
+	struct sk_buff *skb;
+
+	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
+
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) {
+			sacked += tcp_skb_pcount(skb);
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+			printk(KERN_ERR "Sacked bitmap S+L: %u %u-%u/%u\n",
+				TCP_SKB_CB(skb)->sacked,
+				TCP_SKB_CB(skb)->end_seq - tp->snd_una,
+				TCP_SKB_CB(skb)->seq - tp->snd_una,
+				tp->snd_una);
+		}
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+			lost += tcp_skb_pcount(skb);
+
+		packets += tcp_skb_pcount(skb);
+	}
+
+	WARN_ON(lost != tp->lost_out);
+	WARN_ON(tcp_is_sack(tp) && (sacked != tp->sacked_out));
+	WARN_ON(packets != tp->packets_out);
+	if ((lost != tp->lost_out) ||
+	    (tcp_is_sack(tp) && (sacked != tp->sacked_out)) ||
+	    (packets != tp->packets_out)) {
+		printk(KERN_ERR "P: %u L: %u vs %u S: %u vs %u w: %u-%u (%u)\n",
+			tp->packets_out,
+			lost, tp->lost_out,
+			sacked, tp->sacked_out,
+			tp->snd_una, tp->snd_nxt,
+		       	tp->rx_opt.sack_ok);
+		tcp_print_queue(sk);
+	}
+}
+
 static int tcp_v4_get_port(struct sock *sk, unsigned short snum)
 {
 	return inet_csk_get_port(&tcp_hashinfo, sk, snum,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 89f0188..648340f 100644
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
@@ -1970,8 +1973,10 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
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
@@ -1997,6 +2002,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		}
 	}
 
+	tcp_verify_left_out(tp);
+
 	/* OK, demanded retransmission is finished. */
 
 	/* Forward retransmissions are possible only during Recovery. */
@@ -2054,6 +2061,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 
 		NET_INC_STATS_BH(LINUX_MIB_TCPFORWARDRETRANS);
 	}
+
+	tcp_verify_left_out(tp);
 }
 
 /* Send a fin.  The caller locks the socket for us.  This cannot be
-- 
1.5.2.2

---696243703-2498209-1201077674=:31652--
