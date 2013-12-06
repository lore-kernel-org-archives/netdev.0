From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: auto corking
Date: Thu, 05 Dec 2013 22:36:05 -0800
Message-ID: <1386311765.30495.246.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:63767 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754341Ab3LFGgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 01:36:07 -0500
Received: by mail-pb0-f44.google.com with SMTP id rq2so500053pbb.31
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 22:36:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

With the introduction of TCP Small Queues, TSO auto sizing, and TCP
pacing, we can implement Automatic Corking in the kernel, to help
applications doing small write()/sendmsg() to TCP sockets.

Idea is to change tcp_push() to check if the current skb payload is
under skb optimal size (a multiple of MSS bytes)

If under 'size_goal', and at least one packet is still in Qdisc or
NIC TX queues, set the TCP Small Queue Throttled bit, so that the push
will be delayed up to TX completion time.

This delay might allow the application to coalesce more bytes
in the skb in following write()/sendmsg()/sendfile() system calls.

The exact duration of the delay is depending on the dynamics
of the system, and might be zero if no packet for this flow
is actually held in Qdisc or NIC TX ring.

Using FQ/pacing is a way to increase the probability of
autocorking being triggered.

Add a new sysctl (/proc/sys/net/ipv4/tcp_autocorking) to control
this feature and default it to 1 (enabled)

Add a new SNMP counter : nstat -a | grep TcpExtTCPAutoCorking
This counter is incremented every time we detected skb was under used
and its flush was deferred.

Tested:

Interesting effects when using line buffered commands under ssh.

Excellent performance results in term of cpu usage and total throughput.

lpq83:~# echo 1 >/proc/sys/net/ipv4/tcp_autocorking
lpq83:~# perf stat ./super_netperf 4 -t TCP_STREAM -H lpq84 -- -m 128
9410.39

 Performance counter stats for './super_netperf 4 -t TCP_STREAM -H lpq84 -- -m 128':

      35209.439626 task-clock                #    2.901 CPUs utilized          
             2,294 context-switches          #    0.065 K/sec                  
               101 CPU-migrations            #    0.003 K/sec                  
             4,079 page-faults               #    0.116 K/sec                  
    97,923,241,298 cycles                    #    2.781 GHz                     [83.31%]
    51,832,908,236 stalled-cycles-frontend   #   52.93% frontend cycles idle    [83.30%]
    25,697,986,603 stalled-cycles-backend    #   26.24% backend  cycles idle    [66.70%]
   102,225,978,536 instructions              #    1.04  insns per cycle        
                                             #    0.51  stalled cycles per insn [83.38%]
    18,657,696,819 branches                  #  529.906 M/sec                   [83.29%]
        91,679,646 branch-misses             #    0.49% of all branches         [83.40%]

      12.136204899 seconds time elapsed

lpq83:~# echo 0 >/proc/sys/net/ipv4/tcp_autocorking
lpq83:~# perf stat ./super_netperf 4 -t TCP_STREAM -H lpq84 -- -m 128
6624.89

 Performance counter stats for './super_netperf 4 -t TCP_STREAM -H lpq84 -- -m 128':
      40045.864494 task-clock                #    3.301 CPUs utilized          
               171 context-switches          #    0.004 K/sec                  
                53 CPU-migrations            #    0.001 K/sec                  
             4,080 page-faults               #    0.102 K/sec                  
   111,340,458,645 cycles                    #    2.780 GHz                     [83.34%]
    61,778,039,277 stalled-cycles-frontend   #   55.49% frontend cycles idle    [83.31%]
    29,295,522,759 stalled-cycles-backend    #   26.31% backend  cycles idle    [66.67%]
   108,654,349,355 instructions              #    0.98  insns per cycle        
                                             #    0.57  stalled cycles per insn [83.34%]
    19,552,170,748 branches                  #  488.244 M/sec                   [83.34%]
       157,875,417 branch-misses             #    0.81% of all branches         [83.34%]

      12.130267788 seconds time elapsed

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 Documentation/networking/ip-sysctl.txt |   10 +++
 include/net/tcp.h                      |    1 
 include/uapi/linux/snmp.h              |    1 
 net/ipv4/proc.c                        |    1 
 net/ipv4/sysctl_net_ipv4.c             |    9 +++
 net/ipv4/tcp.c                         |   63 ++++++++++++++++++-----
 6 files changed, 72 insertions(+), 13 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 3c12d9a..12ba2cd 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -156,6 +156,16 @@ tcp_app_win - INTEGER
 	buffer. Value 0 is special, it means that nothing is reserved.
 	Default: 31
 
+tcp_autocorking - BOOLEAN
+	Enable TCP auto corking :
+	When applications do consecutive small write()/sendmsg() system calls,
+	we try to coalesce these small writes as much as possible, to lower
+	total amount of sent packets. This is done if at least one prior
+	packet for the flow is waiting in Qdisc queues or device transmit
+	queue. Applications can still use TCP_CORK for optimal behavior
+	when they know how/when to uncork their sockets.
+	Default : 1
+
 tcp_available_congestion_control - STRING
 	Shows the available congestion control choices that are registered.
 	More congestion control algorithms may be available as modules,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 70e55d2..f7e1ab2 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -282,6 +282,7 @@ extern int sysctl_tcp_limit_output_bytes;
 extern int sysctl_tcp_challenge_ack_limit;
 extern unsigned int sysctl_tcp_notsent_lowat;
 extern int sysctl_tcp_min_tso_segs;
+extern int sysctl_tcp_autocorking;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index 1bdb4a3..bbaba22 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -258,6 +258,7 @@ enum
 	LINUX_MIB_TCPFASTOPENCOOKIEREQD,	/* TCPFastOpenCookieReqd */
 	LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES, /* TCPSpuriousRtxHostQueues */
 	LINUX_MIB_BUSYPOLLRXPACKETS,		/* BusyPollRxPackets */
+	LINUX_MIB_TCPAUTOCORKING,		/* TCPAutoCorking */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 4a03358..8ecd7ad 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -279,6 +279,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPFastOpenCookieReqd", LINUX_MIB_TCPFASTOPENCOOKIEREQD),
 	SNMP_MIB_ITEM("TCPSpuriousRtxHostQueues", LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES),
 	SNMP_MIB_ITEM("BusyPollRxPackets", LINUX_MIB_BUSYPOLLRXPACKETS),
+	SNMP_MIB_ITEM("TCPAutoCorking", LINUX_MIB_TCPAUTOCORKING),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 3d69ec8..38c8ec9 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -733,6 +733,15 @@ static struct ctl_table ipv4_table[] = {
 		.extra2		= &gso_max_segs,
 	},
 	{
+		.procname	= "tcp_autocorking",
+		.data		= &sysctl_tcp_autocorking,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
+	{
 		.procname	= "udp_mem",
 		.data		= &sysctl_udp_mem,
 		.maxlen		= sizeof(sysctl_udp_mem),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c4638e6..0ca8754 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -285,6 +285,8 @@ int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
 
 int sysctl_tcp_min_tso_segs __read_mostly = 2;
 
+int sysctl_tcp_autocorking __read_mostly = 1;
+
 struct percpu_counter tcp_orphan_count;
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
 
@@ -619,19 +621,52 @@ static inline void tcp_mark_urg(struct tcp_sock *tp, int flags)
 		tp->snd_up = tp->write_seq;
 }
 
-static inline void tcp_push(struct sock *sk, int flags, int mss_now,
-			    int nonagle)
+/* If a not yet filled skb is pushed, do not send it if
+ * we have packets in Qdisc or NIC queues :
+ * Because TX completion will happen shortly, it gives a chance
+ * to coalesce future sendmsg() payload into this skb, without
+ * need for a timer, and with no latency trade off.
+ * As packets containing data payload have a bigger truesize
+ * than pure acks (dataless) packets, the last check prevents
+ * autocorking if we only have an ACK in Qdisc/NIC queues.
+ */
+static bool tcp_should_autocork(struct sock *sk, struct sk_buff *skb,
+				int size_goal)
 {
-	if (tcp_send_head(sk)) {
-		struct tcp_sock *tp = tcp_sk(sk);
+	return skb->len < size_goal &&
+	       sysctl_tcp_autocorking &&
+	       atomic_read(&sk->sk_wmem_alloc) > skb->truesize;
+}
+
+static void tcp_push(struct sock *sk, int flags, int mss_now,
+		     int nonagle, int size_goal)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb;
 
-		if (!(flags & MSG_MORE) || forced_push(tp))
-			tcp_mark_push(tp, tcp_write_queue_tail(sk));
+	if (!tcp_send_head(sk))
+		return;
+
+	skb = tcp_write_queue_tail(sk);
+	if (!(flags & MSG_MORE) || forced_push(tp))
+		tcp_mark_push(tp, skb);
+
+	tcp_mark_urg(tp, flags);
+
+	if (tcp_should_autocork(sk, skb, size_goal)) {
 
-		tcp_mark_urg(tp, flags);
-		__tcp_push_pending_frames(sk, mss_now,
-					  (flags & MSG_MORE) ? TCP_NAGLE_CORK : nonagle);
+		/* avoid atomic op if TSQ_THROTTLED bit is already set */
+		if (!test_bit(TSQ_THROTTLED, &tp->tsq_flags)) {
+			NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPAUTOCORKING);
+			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
+		}
+		return;
 	}
+
+	if (flags & MSG_MORE)
+		nonagle = TCP_NAGLE_CORK;
+
+	__tcp_push_pending_frames(sk, mss_now, nonagle);
 }
 
 static int tcp_splice_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb,
@@ -934,7 +969,8 @@ new_segment:
 wait_for_sndbuf:
 		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 wait_for_memory:
-		tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
+		tcp_push(sk, flags & ~MSG_MORE, mss_now,
+			 TCP_NAGLE_PUSH, size_goal);
 
 		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
 			goto do_error;
@@ -944,7 +980,7 @@ wait_for_memory:
 
 out:
 	if (copied && !(flags & MSG_SENDPAGE_NOTLAST))
-		tcp_push(sk, flags, mss_now, tp->nonagle);
+		tcp_push(sk, flags, mss_now, tp->nonagle, size_goal);
 	return copied;
 
 do_error:
@@ -1225,7 +1261,8 @@ wait_for_sndbuf:
 			set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 wait_for_memory:
 			if (copied)
-				tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
+				tcp_push(sk, flags & ~MSG_MORE, mss_now,
+					 TCP_NAGLE_PUSH, size_goal);
 
 			if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
 				goto do_error;
@@ -1236,7 +1273,7 @@ wait_for_memory:
 
 out:
 	if (copied)
-		tcp_push(sk, flags, mss_now, tp->nonagle);
+		tcp_push(sk, flags, mss_now, tp->nonagle, size_goal);
 	release_sock(sk);
 	return copied + copied_syn;
 
