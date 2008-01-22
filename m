From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.24-rc8-mm1 : net tcp_input.c warnings
Date: Tue, 22 Jan 2008 12:47:57 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801221115150.31652@kivilampi-30.cs.helsinki.fi>
References: <20080121075548.GA22177@darkstar.te-china.tietoenator.com>
 <Pine.LNX.4.64.0801212302170.29700@kivilampi-30.cs.helsinki.fi>
 <a8e1da0801212037uaa34a10xc2239ac7309a4ed0@mail.gmail.com>
 <a8e1da0801220109v6bf8931ev50f2210402c3ba41@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1269759706-1200993328=:31652"
Cc: LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50479 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754809AbYAVKsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 05:48:00 -0500
In-Reply-To: <a8e1da0801220109v6bf8931ev50f2210402c3ba41@mail.gmail.com>
Content-ID: <Pine.LNX.4.64.0801221244020.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1269759706-1200993328=:31652
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0801221115411.31652@kivilampi-30.cs.helsinki.fi>

On Tue, 22 Jan 2008, Dave Young wrote:

> On Jan 22, 2008 12:37 PM, Dave Young <hidave.darkstar@gmail.com> wrote:
> >
> > On Jan 22, 2008 5:14 AM, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > >
> > > On Mon, 21 Jan 2008, Dave Young wrote:
> > >
> > > > Please see the kernel messages following,(trigged while using some qemu session)
> > > > BTW, seems there's some e100 error message as well.
> > > >
> > > > PCI: Setting latency timer of device 0000:00:1b.0 to 64
> > > > e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
> > > > e100: Copyright(c) 1999-2006 Intel Corporation
> > > > ACPI: PCI Interrupt 0000:03:08.0[A] -> GSI 20 (level, low) -> IRQ 20
> > > > modprobe:2331 conflicting cache attribute efaff000-efb00000 uncached<->default
> > > > e100: 0000:03:08.0: e100_probe: Cannot map device registers, aborting.
> > > > ACPI: PCI interrupt for device 0000:03:08.0 disabled
> > > > e100: probe of 0000:03:08.0 failed with error -12
> > > > eth0:  setting full-duplex.
> > > > ------------[ cut here ]------------
> > > > WARNING: at net/ipv4/tcp_input.c:2169 tcp_mark_head_lost+0x121/0x150()
> > > > Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss eeprom e100 psmouse snd_hda_intel snd_pcm snd_timer btusb rtc_cmos thermal bluetooth rtc_core serio_raw intel_agp button processor sg snd rtc_lib i2c_i801 evdev agpgart soundcore dcdbas 3c59x pcspkr snd_page_alloc
> > > > Pid: 0, comm: swapper Not tainted 2.6.24-rc8-mm1 #4
> > > >  [<c0132100>] ? printk+0x0/0x20
> > > >  [<c0131834>] warn_on_slowpath+0x54/0x80
> > > >  [<c03e8df8>] ? ip_finish_output+0x128/0x2e0
> > > >  [<c03e9527>] ? ip_output+0xe7/0x100
> > > >  [<c03e8a88>] ? ip_local_out+0x18/0x20
> > > >  [<c03e991c>] ? ip_queue_xmit+0x3dc/0x470
> > > >  [<c043641e>] ? _spin_unlock_irqrestore+0x5e/0x70
> > > >  [<c0186be1>] ? check_pad_bytes+0x61/0x80
> > > >  [<c03f6031>] tcp_mark_head_lost+0x121/0x150
> > > >  [<c03f60ac>] tcp_update_scoreboard+0x4c/0x170
> > > >  [<c03f6e0a>] tcp_fastretrans_alert+0x48a/0x6b0
> > > >  [<c03f7d93>] tcp_ack+0x1b3/0x3a0
> > > >  [<c03fa14b>] tcp_rcv_established+0x3eb/0x710
> > > >  [<c04015c5>] tcp_v4_do_rcv+0xe5/0x100
> > > >  [<c0401bbb>] tcp_v4_rcv+0x5db/0x660
> > >
> > > Doh, once more these S+L things..., the rest are symptom of the first
> > > problem.
> >
> > What is the S+L thing? Could you explain a bit?

It means that one of the skbs is both SACKed and marked as LOST at the
same time in the counters (might be due to miscount of lost/sacked_out
too, not necessarilily in the ->sacked bits). Such state is logically
invalid because it would mean that the sender thinks that the same packet 
both reached the receiver and is lost in the network.

Traditionally TCP has just silently "corrected" over-estimates
(sacked_out+lost_out > packets_out). I changed this couple of releases ago
because those over-estimates often are due to bugs that should be fixed  
(there have been couple of them but it has been very quite on this front  
long time, months or even half year already; but I might have broken
something with the early Dec changes).

These problem may originate from a bug that occurred a number of ACKs
earlier the WARN_ON triggered, therefore they are a bit tricky to track,
those WARN_ON serve just for alerting purposes and usually do not point
out where the bug actually occurred.

I usually just asked people to include exhaustive verifier which compares
->sacked bitmaps with sacked/lost_out counters and report immediately when
the problem shows up, rather than waiting for the cheaper S+L check we do
in the WARN_ON to trigger. I tried to collect tracking patch from the
previous efforts (hopefully got it right after modifications).

> > I'm a bit worried about its
> > > reproducability if it takes this far to see it...
> > >
> 
> It's trigged again in my pc, just while using firefox.

...Good, then there's some chance to catch it.

-- 
 i.

[PATCH] [TCP]: debug S+L

---
 include/net/tcp.h     |    8 +++-
 net/ipv4/tcp_input.c  |    6 +++
 net/ipv4/tcp_ipv4.c   |  101 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c |   21 +++++++---
 4 files changed, 129 insertions(+), 7 deletions(-)

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
index fa2c85c..0bda0e1 100644
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
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9aea88b..21f5888 100644
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
+	WARN_ON(sacked != tp->sacked_out);
+	WARN_ON(packets != tp->packets_out);
+	if ((lost != tp->lost_out) ||
+	    (sacked != tp->sacked_out) ||
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

---696243703-1269759706-1200993328=:31652--
