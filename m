From: OBATA Noboru <noboru.obata.ar@hitachi.com>
Subject: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Thu, 12 Jul 2007 16:15:10 +0900 (JST)
Message-ID: <20070712.161510.26510093.noboru.obata.ar@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail9.hitachi.co.jp ([133.145.228.44]:41771 "EHLO
	mail9.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760695AbXGLHRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 03:17:05 -0400
Received: from mlsv13.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id 41FCA37C8E
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2007 16:17:04 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Patch (take 2) for making TCP_RTO_MAX a variable.  Suggestions
from Stephen for the first version are merged.  Any comments are
appreciated.

From: OBATA Noboru <noboru.obata.ar@hitachi.com>

Make TCP_RTO_MAX a variable, and allow a user to change it via a
new sysctl entry /proc/sys/net/ipv4/tcp_rto_max.  A user can
then guarantee TCP retransmission to be more controllable, say,
at least once per 10 seconds, by setting it to 10.  This is
quite helpful on failover-capable network devices, such as an
active-backup bonding device.  On such devices, it is desirable
that TCP retransmits a packet shortly after the failover, which
is what I would like to do with this patch.  Please see
Background and Problem below for rationale in detail.

Reading from /proc/sys/net/ipv4/tcp_rto_max shows the current
TCP_RTO_MAX in seconds.  The actual value of TCP_RTO_MAX is
stored in sysctl_tcp_rto_max in jiffies.

Writing to /proc/sys/net/ipv4/tcp_rto_max updates the
TCP_RTO_MAX, only if the new value is not smaller than
TCP_RTO_MIN, which is currently 0.2[sec].  Since tcp_rto_max is
an integer, the minimum value of /proc/sys/net/ipv4/tcp_rto_max
is 1, in substance.  Also the RtoMax entry in /proc/net/snmp is
updated.

Please note that this is effective in IPv6 as well.


Background and Problem
======================

When designing a TCP/IP based network system on failover-capable
network devices, people want to set timeouts hierarchically in
three layers, network device layer, TCP layer, and application
layer (bottom-up order), such that:

1. Network device layer detects a failure first and switch to a
   backup device (say, in 20sec).

2. TCP layer timeout & retransmission comes next, _hopefully_
   before the application layer timeout.

3. Application layer detects a network failure last (by, say,
   30sec timeout) and may trigger a system-level failover.

   * Note 1.  The timeouts for #1 and #2 are handled
     independently and there is no relationship between them.

   * Note 2.  The actual timeout settings (20sec or 30sec in
     this example) are often determined by systems requirement
     and so setting them to certain "safe values" (if any) are
     usually not possible.

If TCP retransmission misses the time frame between event #1
and #3 in Background above (between 20 and 30sec since network
failure), a failure causes the system-level failover where the
network-device-level failover should be enough.

The problem in this hierarchical timeout scheme is that TCP
layer does not guarantee the next retransmission to occur in
certain period of time.  In the above example, people expect TCP
to retransmit a packet between 20 and 30sec since network
failure, but it may not happen.

Starting from RTO=0.5sec for example, retransmission will occur
at time 0.5, 1.5, 3.5, 7.5, 15.5, and 31.5 as indicated by 'o'
in the following diagram, but miss the time frame between time
20 and 30.

       time: 0         10        20        30sec
             |         |         |         |
  App. layer |---------+---------+---------X  ==> system failover
   TCP layer oo-o---o--+----o----+---------+o <== expects retrans. b/w 20~30
Netdev layer |---------+---------X            ==> network failover


Signed-off-by: OBATA Noboru <noboru.obata.ar@hitachi.com>
---

 Documentation/networking/ip-sysctl.txt |    6 ++++
 include/net/tcp.h                      |   11 ++++----
 net/ipv4/sysctl_net_ipv4.c             |   32 +++++++++++++++++++++++++
 net/ipv4/tcp_input.c                   |   14 +++++-----
 net/ipv4/tcp_output.c                  |   14 +++++-----
 net/ipv4/tcp_timer.c                   |   19 ++++++++------
 6 files changed, 69 insertions(+), 27 deletions(-)

diff -uprN -X a/Documentation/dontdiff a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
--- a/Documentation/networking/ip-sysctl.txt	2007-07-07 14:36:14.000000000 +0900
+++ b/Documentation/networking/ip-sysctl.txt	2007-07-07 18:38:59.000000000 +0900
@@ -340,6 +340,12 @@ tcp_rmem - vector of 3 INTEGERs: min, de
 	net.core.rmem_max, "static" selection via SO_RCVBUF does not use this.
 	Default: 87380*2 bytes.
 
+tcp_rto_max - INTEGER
+	Maximum time in seconds to which RTO can grow.  Exponential
+	backoff of RTO is bounded by this value.  The value must not be
+	smaller than 1.  Note this parameter is also effective for IPv6.
+	Default: 120
+
 tcp_sack - BOOLEAN
 	Enable select acknowledgments (SACKS).
 
diff -uprN -X a/Documentation/dontdiff a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2007-07-07 14:36:24.000000000 +0900
+++ b/include/net/tcp.h	2007-07-11 18:36:49.000000000 +0900
@@ -121,7 +121,7 @@ extern void tcp_time_wait(struct sock *s
 #define TCP_DELACK_MIN	4U
 #define TCP_ATO_MIN	4U
 #endif
-#define TCP_RTO_MAX	((unsigned)(120*HZ))
+#define TCP_RTO_MAX_DEFAULT	((unsigned)(120*HZ))
 #define TCP_RTO_MIN	((unsigned)(HZ/5))
 #define TCP_TIMEOUT_INIT ((unsigned)(3*HZ))	/* RFC 1122 initial RTO value	*/
 
@@ -203,6 +203,7 @@ extern int sysctl_tcp_synack_retries;
 extern int sysctl_tcp_retries1;
 extern int sysctl_tcp_retries2;
 extern int sysctl_tcp_orphan_retries;
+extern unsigned int sysctl_tcp_rto_max;
 extern int sysctl_tcp_syncookies;
 extern int sysctl_tcp_retrans_collapse;
 extern int sysctl_tcp_stdurg;
@@ -608,7 +609,7 @@ static inline void tcp_packets_out_inc(s
 	tp->packets_out += tcp_skb_pcount(skb);
 	if (!orig)
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-					  inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
+					  inet_csk(sk)->icsk_rto, sysctl_tcp_rto_max);
 }
 
 static inline void tcp_packets_out_dec(struct tcp_sock *tp, 
@@ -793,7 +794,7 @@ static inline void tcp_check_probe_timer
 
 	if (!tp->packets_out && !icsk->icsk_pending)
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
-					  icsk->icsk_rto, TCP_RTO_MAX);
+					  icsk->icsk_rto, sysctl_tcp_rto_max);
 }
 
 static inline void tcp_push_pending_frames(struct sock *sk)
@@ -880,7 +881,7 @@ static inline int tcp_prequeue(struct so
 			if (!inet_csk_ack_scheduled(sk))
 				inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
 						          (3 * TCP_RTO_MIN) / 4,
-							  TCP_RTO_MAX);
+							  sysctl_tcp_rto_max);
 		}
 		return 1;
 	}
@@ -1038,7 +1039,7 @@ static inline void tcp_mib_init(void)
 	/* See RFC 2012 */
 	TCP_ADD_STATS_USER(TCP_MIB_RTOALGORITHM, 1);
 	TCP_ADD_STATS_USER(TCP_MIB_RTOMIN, TCP_RTO_MIN*1000/HZ);
-	TCP_ADD_STATS_USER(TCP_MIB_RTOMAX, TCP_RTO_MAX*1000/HZ);
+	TCP_ADD_STATS_USER(TCP_MIB_RTOMAX, sysctl_tcp_rto_max*1000/HZ);
 	TCP_ADD_STATS_USER(TCP_MIB_MAXCONN, -1);
 }
 
diff -uprN -X a/Documentation/dontdiff a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
--- a/net/ipv4/sysctl_net_ipv4.c	2007-07-07 14:36:24.000000000 +0900
+++ b/net/ipv4/sysctl_net_ipv4.c	2007-07-11 19:55:02.000000000 +0900
@@ -186,6 +186,30 @@ static int strategy_allowed_congestion_c
 
 }
 
+static int proc_tcp_rto_max(ctl_table *ctl, int write, struct file *filp,
+			    void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int *valp = ctl->data;
+	int oldval = *valp;
+	int ret;
+
+	/* Using dointvec conversion for an unsigned variable.  */
+	ret = proc_dointvec_jiffies(ctl, write, filp, buffer, lenp, ppos);
+	if (ret)
+		return ret;
+
+	if (write && *valp != oldval) {
+		if (*valp < (int)TCP_RTO_MIN) {
+			*valp = oldval;
+			return -EINVAL;
+		}
+		TCP_ADD_STATS_USER(TCP_MIB_RTOMAX,
+				   (*valp - oldval) * 1000 / HZ);
+	}
+
+	return 0;
+}
+
 ctl_table ipv4_table[] = {
 	{
 		.ctl_name	= NET_IPV4_TCP_TIMESTAMPS,
@@ -363,6 +387,14 @@ ctl_table ipv4_table[] = {
 		.proc_handler	= &proc_dointvec
 	},
 	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "tcp_rto_max",
+		.data		= &sysctl_tcp_rto_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_tcp_rto_max
+	},
+	{
 		.ctl_name	= NET_IPV4_TCP_FIN_TIMEOUT,
 		.procname	= "tcp_fin_timeout",
 		.data		= &sysctl_tcp_fin_timeout,
diff -uprN -X a/Documentation/dontdiff a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2007-07-07 14:36:24.000000000 +0900
+++ b/net/ipv4/tcp_input.c	2007-07-07 18:39:00.000000000 +0900
@@ -654,8 +654,8 @@ static inline void tcp_set_rto(struct so
  */
 static inline void tcp_bound_rto(struct sock *sk)
 {
-	if (inet_csk(sk)->icsk_rto > TCP_RTO_MAX)
-		inet_csk(sk)->icsk_rto = TCP_RTO_MAX;
+	if (inet_csk(sk)->icsk_rto > sysctl_tcp_rto_max)
+		inet_csk(sk)->icsk_rto = sysctl_tcp_rto_max;
 }
 
 /* Save metrics learned by this TCP session.
@@ -1527,7 +1527,7 @@ static int tcp_check_sack_reneging(struc
 		icsk->icsk_retransmits++;
 		tcp_retransmit_skb(sk, tcp_write_queue_head(sk));
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-					  icsk->icsk_rto, TCP_RTO_MAX);
+					  icsk->icsk_rto, sysctl_tcp_rto_max);
 		return 1;
 	}
 	return 0;
@@ -2340,7 +2340,7 @@ static void tcp_ack_packets_out(struct s
 	if (!tp->packets_out) {
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
 	} else {
-		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
+		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, inet_csk(sk)->icsk_rto, sysctl_tcp_rto_max);
 	}
 }
 
@@ -2539,8 +2539,8 @@ static void tcp_ack_probe(struct sock *s
 		 */
 	} else {
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
-					  min(icsk->icsk_rto << icsk->icsk_backoff, TCP_RTO_MAX),
-					  TCP_RTO_MAX);
+					  min(icsk->icsk_rto << icsk->icsk_backoff, sysctl_tcp_rto_max),
+					  sysctl_tcp_rto_max);
 	}
 }
 
@@ -4552,7 +4552,7 @@ static int tcp_rcv_synsent_state_process
 			tcp_incr_quickack(sk);
 			tcp_enter_quickack_mode(sk);
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
-						  TCP_DELACK_MAX, TCP_RTO_MAX);
+						  TCP_DELACK_MAX, sysctl_tcp_rto_max);
 
 discard:
 			__kfree_skb(skb);
diff -uprN -X a/Documentation/dontdiff a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2007-07-07 14:36:24.000000000 +0900
+++ b/net/ipv4/tcp_output.c	2007-07-11 18:39:53.000000000 +0900
@@ -1913,7 +1913,7 @@ void tcp_xmit_retransmit_queue(struct so
 					if (skb == tcp_write_queue_head(sk))
 						inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 									  inet_csk(sk)->icsk_rto,
-									  TCP_RTO_MAX);
+									  sysctl_tcp_rto_max);
 				}
 
 				packet_cnt += tcp_skb_pcount(skb);
@@ -1981,7 +1981,7 @@ void tcp_xmit_retransmit_queue(struct so
 		if (skb == tcp_write_queue_head(sk))
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 						  inet_csk(sk)->icsk_rto,
-						  TCP_RTO_MAX);
+						  sysctl_tcp_rto_max);
 
 		NET_INC_STATS_BH(LINUX_MIB_TCPFORWARDRETRANS);
 	}
@@ -2305,7 +2305,7 @@ int tcp_connect(struct sock *sk)
 
 	/* Timer for repeating the SYN until an answer. */
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-				  inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
+				  inet_csk(sk)->icsk_rto, sysctl_tcp_rto_max);
 	return 0;
 }
 
@@ -2380,7 +2380,7 @@ void tcp_send_ack(struct sock *sk)
 			inet_csk_schedule_ack(sk);
 			inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
-						  TCP_DELACK_MAX, TCP_RTO_MAX);
+						  TCP_DELACK_MAX, sysctl_tcp_rto_max);
 			return;
 		}
 
@@ -2508,8 +2508,8 @@ void tcp_send_probe0(struct sock *sk)
 			icsk->icsk_backoff++;
 		icsk->icsk_probes_out++;
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
-					  min(icsk->icsk_rto << icsk->icsk_backoff, TCP_RTO_MAX),
-					  TCP_RTO_MAX);
+					  min(icsk->icsk_rto << icsk->icsk_backoff, sysctl_tcp_rto_max),
+					  sysctl_tcp_rto_max);
 	} else {
 		/* If packet was not sent due to local congestion,
 		 * do not backoff and do not remember icsk_probes_out.
@@ -2522,7 +2522,7 @@ void tcp_send_probe0(struct sock *sk)
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
 					  min(icsk->icsk_rto << icsk->icsk_backoff,
 					      TCP_RESOURCE_PROBE_INTERVAL),
-					  TCP_RTO_MAX);
+					  sysctl_tcp_rto_max);
 	}
 }
 
diff -uprN -X a/Documentation/dontdiff a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
--- a/net/ipv4/tcp_timer.c	2007-07-07 14:36:24.000000000 +0900
+++ b/net/ipv4/tcp_timer.c	2007-07-11 18:46:12.000000000 +0900
@@ -31,6 +31,9 @@ int sysctl_tcp_keepalive_intvl __read_mo
 int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
 int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
 int sysctl_tcp_orphan_retries __read_mostly;
+unsigned int sysctl_tcp_rto_max __read_mostly = TCP_RTO_MAX_DEFAULT;
+
+EXPORT_SYMBOL(sysctl_tcp_rto_max);
 
 static void tcp_write_timer(unsigned long);
 static void tcp_delack_timer(unsigned long);
@@ -71,7 +74,7 @@ static int tcp_out_of_resources(struct s
 
 	/* If peer does not open window for long time, or did not transmit
 	 * anything for long time, penalize it. */
-	if ((s32)(tcp_time_stamp - tp->lsndtime) > 2*TCP_RTO_MAX || !do_reset)
+	if ((s32)(tcp_time_stamp - tp->lsndtime) > 2*sysctl_tcp_rto_max || !do_reset)
 		orphans <<= 1;
 
 	/* If some dubious ICMP arrived, penalize even more. */
@@ -147,7 +150,7 @@ static int tcp_write_timeout(struct sock
 
 		retry_until = sysctl_tcp_retries2;
 		if (sock_flag(sk, SOCK_DEAD)) {
-			const int alive = (icsk->icsk_rto < TCP_RTO_MAX);
+			const int alive = (icsk->icsk_rto < sysctl_tcp_rto_max);
 
 			retry_until = tcp_orphan_retries(sk, alive);
 
@@ -254,7 +257,7 @@ static void tcp_probe_timer(struct sock 
 	max_probes = sysctl_tcp_retries2;
 
 	if (sock_flag(sk, SOCK_DEAD)) {
-		const int alive = ((icsk->icsk_rto << icsk->icsk_backoff) < TCP_RTO_MAX);
+		const int alive = ((icsk->icsk_rto << icsk->icsk_backoff) < sysctl_tcp_rto_max);
 
 		max_probes = tcp_orphan_retries(sk, alive);
 
@@ -299,7 +302,7 @@ static void tcp_retransmit_timer(struct 
 			       inet->num, tp->snd_una, tp->snd_nxt);
 		}
 #endif
-		if (tcp_time_stamp - tp->rcv_tstamp > TCP_RTO_MAX) {
+		if (tcp_time_stamp - tp->rcv_tstamp > sysctl_tcp_rto_max) {
 			tcp_write_err(sk);
 			goto out;
 		}
@@ -347,7 +350,7 @@ static void tcp_retransmit_timer(struct 
 			icsk->icsk_retransmits = 1;
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 					  min(icsk->icsk_rto, TCP_RESOURCE_PROBE_INTERVAL),
-					  TCP_RTO_MAX);
+					  sysctl_tcp_rto_max);
 		goto out;
 	}
 
@@ -370,8 +373,8 @@ static void tcp_retransmit_timer(struct 
 	icsk->icsk_retransmits++;
 
 out_reset_timer:
-	icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
-	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
+	icsk->icsk_rto = min(icsk->icsk_rto << 1, sysctl_tcp_rto_max);
+	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, sysctl_tcp_rto_max);
 	if (icsk->icsk_retransmits > sysctl_tcp_retries1)
 		__sk_dst_reset(sk);
 
@@ -426,7 +429,7 @@ out_unlock:
 static void tcp_synack_timer(struct sock *sk)
 {
 	inet_csk_reqsk_queue_prune(sk, TCP_SYNQ_INTERVAL,
-				   TCP_TIMEOUT_INIT, TCP_RTO_MAX);
+				   TCP_TIMEOUT_INIT, sysctl_tcp_rto_max);
 }
 
 void tcp_set_keepalive(struct sock *sk, int val)
