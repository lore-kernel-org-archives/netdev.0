From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re : Oops preceded by WARNING: at net/ipv4/tcp_input.c:1571
 tcp_remove_reno_sacks()
Date: Mon, 12 Nov 2007 00:40:39 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711111216170.12719@kivilampi-30.cs.helsinki.fi>
References: <902344.71635.qm@web26211.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-191333392-1194819809=:20846"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Chazarain Guillaume <guichaz@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56467 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755532AbXKKWkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 17:40:42 -0500
In-Reply-To: <902344.71635.qm@web26211.mail.ukl.yahoo.com>
Content-ID: <Pine.LNX.4.64.0711120039480.20846@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-191333392-1194819809=:20846
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0711120023341.20846@kivilampi-30.cs.helsinki.fi>

On Sun, 11 Nov 2007, Chazarain Guillaume wrote:

> > Do you have GSO enabled?
>
> According to ethtool -k, no.

Ok, thanks, it excludes lot of possibilities...

> > Is this reproducable?
>
> Unfortunately not, I saw it only once.

The messages you had in the other mail are very likely symptom of the 
same problem, it's just hard to tell from them where it really originates 
from (because it would requires expensive verification that nobody wants 
to do by default after simple operations). In many cases that WARN_ON is 
simply too late to tell when the problem causing adjustment/corruption 
occurred but it's still better than nothing as a starting point :-).

> > You can try to provoke it by setting tcp_sack sysctl 
> >  to 0 as this seems to be non-SACK related... If so, you could try the 
> > debug patch below
>
> > > # CONFIG_DEBUG_LIST is not set

> I'm currently running bittorrent with all of this, I just saw this (for 
> the first time ever), but otherwise it works fine:

WARNING: at net/ipv4/tcp_output.c:1807 tcp_simple_retransmit()
 [<c0104cb3>] show_trace_log_lvl+0x1a/0x2f
 [<c0105563>] show_trace+0x12/0x14
 [<c0105668>] dump_stack+0x15/0x17
 [<c02f6a79>] tcp_simple_retransmit+0xfa/0x185
 [<c02fa072>] tcp_v4_err+0x35d/0x4cb
 [<c0301f7d>] icmp_unreach+0x327/0x352

Hmm, that's related to path MTU things... It might have something to do 
with this... I'm not at all sure how it handles pcounts...

> > Have you run memtest recently?
>
> Just ran it with no errors for 6 minutes 30. The box is otherwise stable though.

Yeah, it's more likely a miscount somewhere rather than corruption but 
that wasn't obvious from the first mail...

...but alas, I haven't yet been able to come up with any theory on how 
a miscount could occur....

> I forgot to say that I have a kdump image of the crash (I had to 
> recompile this
>
> 2.6.24-rc2 kernel as I deleted its vmlinux), so I could check that you 
> are right on track with your assertions at the time of the crash.
>
> > +    if (WARN_ON(tcp_write_queue_head(sk) == NULL))
> > +        return;
> 
> (gdb) p sk->sk_write_queue.next
> $11 = (struct sk_buff *) 0xe43a04b0
> (gdb) p &sk->sk_write_queue
> $12 = (struct sk_buff_head *) 0xe43a04b0
> 
> 
> > +    if (WARN_ON(!tp->packets_out))
> > +        return;
> 
> (gdb) p ((struct tcp_sock *) sk)->packets_out
> $13 = 0

Yeah, they are expected, the write_queue is empty. Another cause for 
those could have been corrupted write_queue (that's why I asked for the 
list debugging).

> > +    if (tp->lost_out > tp->packets_out)
> > +        printk(KERN_ERR "Lost underflowed to %u\n", tp->lost_out);
>
> (gdb) p ((struct tcp_sock *) sk)->lost_out
> $14 = 4294967295

Underflows by one. ...We should just find out what causes this and fix 
that and we're done with it. :-)


> Some more gdb output for information:

Thanks about them, though they're not that useful because the problem 
occurred prior to its detection... :-)

> My naive attempt at understanding what's going on:
> 
> My oops starts with:
> BUG: unable to handle kernel NULL pointer dereference at virtual address 
> 00000045
>
>
> gdb tells me the crash is in:
> #0  tcp_xmit_retransmit_queue (sk=0xe43a0440) at 
> net/ipv4/tcp_output.c:1962
> 1962                            __u8 sacked = TCP_SKB_CB(skb)->sacked;
>
> (gdb) p ((struct tcp_skb_cb *)((struct sk_buff *)0)->cb)->sacked
> Cannot access memory at address 0x45
> 
> A 0x45 offset is definitely a ->sacked on a null skb, but:

This is right.

> (gdb) p skb
> $5 = (struct sk_buff *) 0xe43a04b0
>
> which is sk->sk_write_queue so I don't understand why the 
> tcp_for_write_queue_from made an iteration.
>
> I don't know if gdb is playing tricks or if it's because I had to 
> recompile the crashing kernel.

No, it won't happen like that. ...I'd say that gdb is just confused. In 
case packets_out is zero (it occurs after a cumulative ACK only), for sure 
skb will become NULL because the retransmit_skb_hint was cleared due to 
cumulative ACK.

The crash location is the expected one in case packets_out gets zero 
during recovery and lost_out is miscounted/corrupt, as your dump shows.

Anyway, thanks for digging these out.


Here's a bruteforce patch below... Since you had couple of them during 
your overnight test, I'm sure it's relatively easy to catch... The 
first place where the tcp_verify_lost is triggered is the most 
interesting, rest are likely ripples due to that earlier corruption... 
(Hopefully I've placed them this time to places where both queue and 
lost_out states should agree, once did similar patch that had
incorrectly placed some verification calls which caused lot of spurious 
stacktraces :-))

...I left those !packets_out things there to prevent crashing when it 
occurs though it's not the main problem itself.

Please keep the tcp_sack set to 0, and once you have at least one 
stacktrace with it, you could try also with tcp_sack if the same thing 
occurs there as well.

--
[PATCH] TCP DEBUG

- Check if empty queue is passed to xmit_retrans...
- Print lost_out underflow value
- Track lost_out and LOST discrepancies everywhere (costs a bit).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    2 ++
 net/ipv4/tcp_input.c  |   21 +++++++++++++++++++++
 net/ipv4/tcp_ipv4.c   |   19 +++++++++++++++++++
 net/ipv4/tcp_output.c |   14 ++++++++++++++
 4 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index d695cea..a939bd5 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -272,6 +272,8 @@ DECLARE_SNMP_STAT(struct tcp_mib, tcp_statistics);
 #define TCP_ADD_STATS_BH(field, val)	SNMP_ADD_STATS_BH(tcp_statistics, field, val)
 #define TCP_ADD_STATS_USER(field, val)	SNMP_ADD_STATS_USER(tcp_statistics, field, val)
 
+extern void			tcp_verify_lost(struct sock *sk);
+
 extern void			tcp_v4_err(struct sk_buff *skb, u32);
 
 extern void			tcp_shutdown (struct sock *sk, int how);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ca9590f..588b105 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1512,6 +1512,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 		flag |= tcp_mark_lost_retrans(sk, highest_sack_end_seq);
 
 	tcp_verify_left_out(tp);
+	tcp_verify_lost(sk);
 
 	if ((reord < tp->fackets_out) && icsk->icsk_ca_state != TCP_CA_Loss &&
 	    (!tp->frto_highmark || after(tp->snd_una, tp->frto_highmark)))
@@ -1552,6 +1553,7 @@ static void tcp_add_reno_sack(struct sock *sk)
 	tp->sacked_out++;
 	tcp_check_reno_reordering(sk, 0);
 	tcp_verify_left_out(tp);
+	tcp_verify_lost(sk);
 }
 
 /* Account for ACK, ACKing some data in Reno Recovery phase. */
@@ -1569,6 +1571,7 @@ static void tcp_remove_reno_sacks(struct sock *sk, int acked)
 	}
 	tcp_check_reno_reordering(sk, acked);
 	tcp_verify_left_out(tp);
+	tcp_verify_lost(sk);
 }
 
 static inline void tcp_reset_reno_sack(struct tcp_sock *tp)
@@ -1670,6 +1673,7 @@ void tcp_enter_frto(struct sock *sk)
 		tp->retrans_out -= tcp_skb_pcount(skb);
 	}
 	tcp_verify_left_out(tp);
+	tcp_verify_lost(sk);
 
 	/* Earlier loss recovery underway (see RFC4138; Appendix B).
 	 * The last condition is necessary at least in tp->frto_counter case.
@@ -1727,6 +1731,7 @@ static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments, int flag)
 		}
 	}
 	tcp_verify_left_out(tp);
+	tcp_verify_lost(sk);
 
 	tp->snd_cwnd = tcp_packets_in_flight(tp) + allowed_segments;
 	tp->snd_cwnd_cnt = 0;
@@ -1812,6 +1817,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 		}
 	}
 	tcp_verify_left_out(tp);
+	tcp_verify_lost(sk);
 
 	tp->reordering = min_t(unsigned int, tp->reordering,
 					     sysctl_tcp_reordering);
@@ -2044,6 +2050,7 @@ static void tcp_mark_head_lost(struct sock *sk, int packets)
 		}
 	}
 	tcp_verify_left_out(tp);
+	tcp_verify_lost(sk);
 }
 
 /* Account newly detected lost packet(s) */
@@ -2088,6 +2095,7 @@ static void tcp_update_scoreboard(struct sock *sk)
 		tp->scoreboard_skb_hint = skb;
 
 		tcp_verify_left_out(tp);
+		tcp_verify_lost(sk);
 	}
 }
 
@@ -2304,6 +2312,7 @@ static void tcp_try_to_open(struct sock *sk, int flag)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	tcp_verify_left_out(tp);
+	tcp_verify_lost(sk);
 
 	if (tp->retrans_out == 0)
 		tp->retrans_stamp = 0;
@@ -2403,6 +2412,7 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 
 	/* D. Check consistency of the current state. */
 	tcp_verify_left_out(tp);
+	tcp_verify_lost(sk);
 
 	/* E. Check state exit conditions. State can be terminated
 	 *    when high_seq is ACKed. */
@@ -2521,6 +2531,12 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	if (do_lost || tcp_head_timedout(sk))
 		tcp_update_scoreboard(sk);
 	tcp_cwnd_down(sk, flag);
+	
+	if (WARN_ON(tcp_write_queue_head(sk) == NULL))
+		return;
+	if (WARN_ON(!tp->packets_out))
+		return;
+	
 	tcp_xmit_retransmit_queue(sk);
 }
 
@@ -2721,6 +2737,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p)
 		sk_stream_free_skb(sk, skb);
 		tcp_clear_all_retrans_hints(tp);
 	}
+	
+	tcp_verify_lost(sk);
 
 	if (flag & FLAG_ACKED) {
 		u32 pkts_acked = prior_packets - tp->packets_out;
@@ -2759,6 +2777,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p)
 #if FASTRETRANS_DEBUG > 0
 	BUG_TRAP((int)tp->sacked_out >= 0);
 	BUG_TRAP((int)tp->lost_out >= 0);
+	if (tp->lost_out > tp->packets_out)
+		printk(KERN_ERR "Lost underflowed to %u\n", tp->lost_out);
 	BUG_TRAP((int)tp->retrans_out >= 0);
 	if (!tp->packets_out && tcp_is_sack(tp)) {
 		icsk = inet_csk(sk);
@@ -2931,6 +2951,7 @@ static int tcp_process_frto(struct sock *sk, int flag)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	tcp_verify_left_out(tp);
+	tcp_verify_lost(sk);
 
 	/* Duplicate the behavior from Loss state (fastretrans_alert) */
 	if (flag&FLAG_DATA_ACKED)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e566f3c..5e10d90 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -108,6 +108,25 @@ struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
 	.lhash_wait  = __WAIT_QUEUE_HEAD_INITIALIZER(tcp_hashinfo.lhash_wait),
 };
 
+void tcp_verify_lost(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	u32 lost = 0;
+	struct sk_buff *skb;
+
+	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+			lost += tcp_skb_pcount(skb);
+	}
+	
+	if (WARN_ON(lost != tp->lost_out)) {
+		printk(KERN_ERR "Lost: %u vs %u, %u (%d)\n", lost, tp->lost_out,
+		       tp->packets_out, tcp_is_sack(tp));
+	}
+}
+
 static int tcp_v4_get_port(struct sock *sk, unsigned short snum)
 {
 	return inet_csk_get_port(&tcp_hashinfo, sk, snum,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 324b420..09260ac 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -779,6 +779,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len, unsigned int mss
 	skb_header_release(buff);
 	tcp_insert_write_queue_after(skb, buff, sk);
 
+	tcp_verify_lost(sk);
+
 	return 0;
 }
 
@@ -1443,10 +1445,12 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle)
 
 	/* Do MTU probing. */
 	if ((result = tcp_mtu_probe(sk)) == 0) {
+		tcp_verify_lost(sk);
 		return 0;
 	} else if (result > 0) {
 		sent_pkts = 1;
 	}
+	tcp_verify_lost(sk);
 
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
@@ -1767,6 +1771,8 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb, int m
 		}
 
 		sk_stream_free_skb(sk, next_skb);
+		
+		tcp_verify_lost(sk);
 	}
 }
 
@@ -1798,6 +1804,8 @@ void tcp_simple_retransmit(struct sock *sk)
 			}
 		}
 	}
+	
+	tcp_verify_lost(sk);
 
 	tcp_clear_all_retrans_hints(tp);
 
@@ -1819,6 +1827,8 @@ void tcp_simple_retransmit(struct sock *sk)
 		tcp_set_ca_state(sk, TCP_CA_Loss);
 	}
 	tcp_xmit_retransmit_queue(sk);
+	
+	tcp_verify_lost(sk);
 }
 
 /* This retransmits one SKB.  Policy decisions and retransmit queue
@@ -2000,6 +2010,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 			}
 		}
 	}
+	
+	tcp_verify_lost(sk);
 
 	/* OK, demanded retransmission is finished. */
 
@@ -2058,6 +2070,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 
 		NET_INC_STATS_BH(LINUX_MIB_TCPFORWARDRETRANS);
 	}
+	
+	tcp_verify_lost(sk);
 }
 
 
-- 
1.5.0.6
---696243703-191333392-1194819809=:20846--
