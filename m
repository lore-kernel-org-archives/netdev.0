From: Daniele Lacamera <root@danielinux.net>
Subject: TCP Pacing
Date: Tue, 12 Sep 2006 19:58:21 +0200
Message-ID: <200609121958.22820.root@danielinux.net>
Reply-To: root@danielinux.net
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_+UvBFCWTDLxWs6+"
Cc: netdev@vger.kernel.org, Carlo Caini <ccaini@deis.unibo.it>,
	Rosario Firrincieli <rfirrincieli@arces.unibo.it>,
	Giovanni Pau <gpau@cs.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from danielinux.vm.bytemark.co.uk ([80.68.95.85]:3845 "EHLO
	danielinux.vm.bytemark.co.uk") by vger.kernel.org with ESMTP
	id S1030327AbWILR6a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 13:58:30 -0400
To: Stephen Hemminger <shemminger@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_+UvBFCWTDLxWs6+
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,

Please let me insist once again on the importance of adding a TCP Pacing 
mechanism in our TCP, as many people are including this algorithm in 
their congestion control proposals. Recent researches have found out 
that it really can help improving performance in different scenarios, 
like satellites and long-delay high-speed channels (>100ms RTT, Gbit). 
Hybla module itself is cripple without this feature in its natural 
scenario. 

The following patch is totally non-invasive: it has a config option and 
a sysctl switch, both turned off by default. When the config option is 
enabled, it adds only 6B to the tcp_sock.

Signed-off by: Daniele Lacamera <root@danielinux.net>
--- 







--Boundary-00=_+UvBFCWTDLxWs6+
Content-Type: text/x-diff;
  charset="us-ascii";
  name="TCP_Pacing.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="TCP_Pacing.diff"

diff -ruN linux-2.6.18-rc6/Documentation/networking/ip-sysctl.txt linux-pacing/Documentation/networking/ip-sysctl.txt
--- linux-2.6.18-rc6/Documentation/networking/ip-sysctl.txt	2006-09-04 04:19:48.000000000 +0200
+++ linux-pacing/Documentation/networking/ip-sysctl.txt	2006-09-12 16:38:14.000000000 +0200
@@ -369,6 +369,12 @@
 	be timed out after an idle period.
 	Default: 1
 
+tcp_pacing - BOOLEAN
+	If set, enable time-based TCP segment sending, instead of normal
+	ack-based sending. A software timer is set every time a new ack 
+	is received, then packets are spreaded across round-trip time.
+	Default: 0
+
 IP Variables:
 
 ip_local_port_range - 2 INTEGERS
diff -ruN linux-2.6.18-rc6/include/linux/sysctl.h linux-pacing/include/linux/sysctl.h
--- linux-2.6.18-rc6/include/linux/sysctl.h	2006-09-04 04:19:48.000000000 +0200
+++ linux-pacing/include/linux/sysctl.h	2006-09-12 18:13:38.000000000 +0200
@@ -411,6 +411,7 @@
 	NET_IPV4_TCP_WORKAROUND_SIGNED_WINDOWS=115,
 	NET_TCP_DMA_COPYBREAK=116,
 	NET_TCP_SLOW_START_AFTER_IDLE=117,
+	NET_TCP_PACING=118,
 };
 
 enum {
diff -ruN linux-2.6.18-rc6/include/linux/tcp.h linux-pacing/include/linux/tcp.h
--- linux-2.6.18-rc6/include/linux/tcp.h	2006-09-04 04:19:48.000000000 +0200
+++ linux-pacing/include/linux/tcp.h	2006-09-12 16:45:32.000000000 +0200
@@ -356,6 +356,17 @@
 		__u32		  probe_seq_start;
 		__u32		  probe_seq_end;
 	} mtu_probe;
+	
+#ifdef CONFIG_TCP_PACING
+/* TCP Pacing structure */
+	struct {
+		struct timer_list timer;
+		__u16   count;
+		__u16   burst;
+		__u8    lock;
+		__u8    delta;
+	} pacing;
+#endif
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
diff -ruN linux-2.6.18-rc6/include/net/tcp.h linux-pacing/include/net/tcp.h
--- linux-2.6.18-rc6/include/net/tcp.h	2006-09-04 04:19:48.000000000 +0200
+++ linux-pacing/include/net/tcp.h	2006-09-12 17:07:49.000000000 +0200
@@ -227,6 +227,9 @@
 extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
+#ifdef CONFIG_TCP_PACING
+extern int sysctl_tcp_pacing;
+#endif
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
@@ -449,6 +452,11 @@
 extern unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu);
 extern unsigned int tcp_current_mss(struct sock *sk, int large);
 
+#ifdef CONFIG_TCP_PACING
+extern void tcp_pacing_recalc_delta(struct sock *sk);
+extern void tcp_pacing_reset_timer(struct sock *sk);
+#endif
+
 /* tcp.c */
 extern void tcp_get_info(struct sock *, struct tcp_info *);
 
diff -ruN linux-2.6.18-rc6/net/ipv4/Kconfig linux-pacing/net/ipv4/Kconfig
--- linux-2.6.18-rc6/net/ipv4/Kconfig	2006-09-04 04:19:48.000000000 +0200
+++ linux-pacing/net/ipv4/Kconfig	2006-09-12 16:59:37.000000000 +0200
@@ -572,6 +572,20 @@
 	loss packets.
 	See http://www.ntu.edu.sg/home5/ZHOU0022/papers/CPFu03a.pdf
 
+config TCP_PACING
+	bool "TCP Pacing"
+	depends on EXPERIMENTAL
+	select HZ_1000
+	default n
+	---help---
+	Many researchers have observed that TCP's congestion control mechanisms 
+	can lead to bursty traffic flows on modern high-speed networks, with a 
+	negative impact on overall network efficiency. A proposed solution to this 
+	problem is to evenly space, or "pace", data sent into the network over an 
+	entire round-trip time, so that data is not sent in a burst.
+	To enable this feature, please refer to Documentation/networking/ip-sysctl.txt.
+	If unsure, say N.
+	
 endmenu
 
 config TCP_CONG_BIC
diff -ruN linux-2.6.18-rc6/net/ipv4/sysctl_net_ipv4.c linux-pacing/net/ipv4/sysctl_net_ipv4.c
--- linux-2.6.18-rc6/net/ipv4/sysctl_net_ipv4.c	2006-09-04 04:19:48.000000000 +0200
+++ linux-pacing/net/ipv4/sysctl_net_ipv4.c	2006-09-12 18:33:36.000000000 +0200
@@ -697,6 +697,16 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+#ifdef CONFIG_TCP_PACING
+	{
+		.ctl_name	= NET_TCP_PACING,
+		.procname	= "tcp_pacing",
+		.data		= &sysctl_tcp_pacing,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
+#endif
 	{ .ctl_name = 0 }
 };
 
diff -ruN linux-2.6.18-rc6/net/ipv4/tcp_input.c linux-pacing/net/ipv4/tcp_input.c
--- linux-2.6.18-rc6/net/ipv4/tcp_input.c	2006-09-04 04:19:48.000000000 +0200
+++ linux-pacing/net/ipv4/tcp_input.c	2006-09-12 17:11:38.000000000 +0200
@@ -2569,6 +2569,11 @@
 			tcp_cong_avoid(sk, ack, seq_rtt, prior_in_flight, 1);
 	}
 
+#ifdef CONFIG_TCP_PACING
+	if(sysctl_tcp_pacing)
+		tcp_pacing_recalc_delta(sk);
+#endif
+
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag&FLAG_NOT_DUP))
 		dst_confirm(sk->sk_dst_cache);
 
diff -ruN linux-2.6.18-rc6/net/ipv4/tcp_output.c linux-pacing/net/ipv4/tcp_output.c
--- linux-2.6.18-rc6/net/ipv4/tcp_output.c	2006-09-04 04:19:48.000000000 +0200
+++ linux-pacing/net/ipv4/tcp_output.c	2006-09-12 18:12:38.000000000 +0200
@@ -62,6 +62,10 @@
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle = 1;
 
+#ifdef CONFIG_TCP_PACING
+int sysctl_tcp_pacing=0;
+#endif
+
 static void update_send_head(struct sock *sk, struct tcp_sock *tp,
 			     struct sk_buff *skb)
 {
@@ -414,7 +418,13 @@
 		
 	if (tcp_packets_in_flight(tp) == 0)
 		tcp_ca_event(sk, CA_EVENT_TX_START);
-
+	
+#ifdef CONFIG_TCP_PACING
+	if(sysctl_tcp_pacing) {
+		tcp_pacing_reset_timer(sk);
+		tp->pacing.lock = 1;
+	}
+#endif
 	th = (struct tcphdr *) skb_push(skb, tcp_header_size);
 	skb->h.th = th;
 	skb_set_owner_w(skb, sk);
@@ -1085,7 +1095,15 @@
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	u32 send_win, cong_win, limit, in_flight;
-
+	
+#ifdef CONFIG_TCP_PACING
+	/* TCP Pacing conflicts with this algorithm.
+	 * When Pacing is enabled, don't try to defer.
+	 */
+	if(sysctl_tcp_pacing)
+		return 0;
+#endif
+	
 	if (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)
 		return 0;
 
@@ -1308,7 +1326,12 @@
 
 		if (unlikely(!tcp_snd_wnd_test(tp, skb, mss_now)))
 			break;
-
+		
+#ifdef CONFIG_TCP_PACING
+		if (sysctl_tcp_pacing && tp->pacing.lock)
+			return 0;
+#endif
+		
 		if (tso_segs == 1) {
 			if (unlikely(!tcp_nagle_test(tp, skb, mss_now,
 						     (tcp_skb_is_last(sk, skb) ?
@@ -1323,6 +1346,10 @@
 		if (tso_segs > 1) {
 			limit = tcp_window_allows(tp, skb,
 						  mss_now, cwnd_quota);
+#ifdef CONFIG_TCP_PACING
+		if (sysctl_tcp_pacing && sent_pkts >= tp->pacing.burst)
+			tp->pacing.lock=1;
+#endif
 
 			if (skb->len < limit) {
 				unsigned int trim = skb->len % mss_now;
@@ -1733,6 +1760,11 @@
 		}
 	}
 
+#ifdef CONFIG_TCP_PACING
+	if (sysctl_tcp_pacing && tp->pacing.lock)
+		return -EAGAIN;
+#endif
+
 	/* Make a copy, if the first transmission SKB clone we made
 	 * is still in somebody's hands, else make a clone.
 	 */
diff -ruN linux-2.6.18-rc6/net/ipv4/tcp_timer.c linux-pacing/net/ipv4/tcp_timer.c
--- linux-2.6.18-rc6/net/ipv4/tcp_timer.c	2006-09-04 04:19:48.000000000 +0200
+++ linux-pacing/net/ipv4/tcp_timer.c	2006-09-12 18:03:17.000000000 +0200
@@ -36,10 +36,21 @@
 static void tcp_delack_timer(unsigned long);
 static void tcp_keepalive_timer (unsigned long data);
 
+#ifdef CONFIG_TCP_PACING
+static void tcp_pacing_timer(unsigned long data);
+#endif
+
 void tcp_init_xmit_timers(struct sock *sk)
 {
 	inet_csk_init_xmit_timers(sk, &tcp_write_timer, &tcp_delack_timer,
 				  &tcp_keepalive_timer);
+	
+#ifdef CONFIG_TCP_PACING
+	init_timer(&(tcp_sk(sk)->pacing.timer));
+	tcp_sk(sk)->pacing.timer.function=&tcp_pacing_timer;
+	tcp_sk(sk)->pacing.timer.data = (unsigned long) sk;
+#endif
+
 }
 
 EXPORT_SYMBOL(tcp_init_xmit_timers);
@@ -522,3 +533,115 @@
 	bh_unlock_sock(sk);
 	sock_put(sk);
 }
+
+#ifdef CONFIG_TCP_PACING
+/*
+ * This is the timer used to spread packets.
+ * a delta value is computed on rtt/cwnd,
+ * and will be our expire interval.
+ * The timer has to be restarted when a segment is sent out.
+ */
+static void tcp_pacing_timer(unsigned long data)
+{
+	struct sock *sk = (struct sock*)data;
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if(!sysctl_tcp_pacing)
+		return;
+
+	bh_lock_sock(sk);
+	if (sock_owned_by_user(sk)) {
+		/* Try again later */
+		if (!mod_timer(&tp->pacing.timer, jiffies + 1))
+			sock_hold(sk);
+		goto out_unlock;
+	}
+
+	if (sk->sk_state == TCP_CLOSE)
+		goto out;
+
+	/* Unlock sending, so when next ack is received it will pass.
+	 *If there are no packets scheduled, do nothing.
+	 */
+	tp->pacing.lock=0;
+	
+	if(!sk->sk_send_head){
+		/* Sending queue empty */
+		goto out;
+	}
+	
+	/*  Handler */
+	tcp_push_pending_frames(sk,tp);
+
+	out:
+	if (tcp_memory_pressure)
+		sk_stream_mem_reclaim(sk);
+
+	out_unlock:
+		bh_unlock_sock(sk);
+		sock_put(sk);
+}
+
+void tcp_pacing_reset_timer(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	__u32 timeout = jiffies+tp->pacing.delta;
+
+	if(!sysctl_tcp_pacing)
+		return;
+	if (!mod_timer(&tp->pacing.timer, timeout))
+			sock_hold(sk);
+}
+EXPORT_SYMBOL(tcp_pacing_reset_timer);
+
+/*
+ * This routine computes tcp_pacing delay, using
+ * a simplified uniform pacing policy.
+ */
+void tcp_pacing_recalc_delta(struct sock *sk)
+{
+       struct tcp_sock *tp=tcp_sk(sk);
+       __u32 window=(tp->snd_cwnd)<<3;
+       __u32 srtt = tp->srtt;
+       __u32 round=0;
+       __u32 curmss=tp->mss_cache;
+       int state=inet_csk(sk)->icsk_ca_state;
+
+       if( (state==TCP_CA_Recovery) &&(tp->snd_cwnd < tp->snd_ssthresh))
+		window=(tp->snd_ssthresh)<<3;
+
+       if( (tp->snd_wnd/curmss) < tp->snd_cwnd )
+		window = (tp->snd_wnd/curmss)<<3;
+
+       if (window>1 && srtt){
+               if (window <= srtt){
+                       tp->pacing.delta=(srtt/window);
+			if(srtt%window)
+				round=( (srtt/(srtt%window)) / tp->pacing.delta);
+			if (tp->pacing.count >= (round-1) &&(round>1)){
+				tp->pacing.delta++;
+				tp->pacing.count=0;
+			}
+			tp->pacing.burst=1;
+		} else {
+			tp->pacing.delta=1;
+			tp->pacing.burst=(window/srtt);
+			if(window%srtt)
+				round=( (window/(window%srtt)) * tp->pacing.burst);
+			if (tp->pacing.count >= (round-1) && (round>1)){
+				tp->pacing.burst++;
+				tp->pacing.count=0;
+			}
+		}
+	} else {
+		tp->pacing.delta=0;
+		tp->pacing.burst=1;
+       }
+}
+
+EXPORT_SYMBOL(tcp_pacing_recalc_delta);
+
+#endif
+
+
+

--Boundary-00=_+UvBFCWTDLxWs6+--
