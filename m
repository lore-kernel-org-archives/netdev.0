From: Ben Woodard <woodard@redhat.com>
Subject: [PATCH] Customizable TCP backoff patch
Date: Wed, 27 Sep 2006 11:52:57 -0700
Message-ID: <451AC889.5000407@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060906030201020206020307"
Cc: "Mark A. Grondona" <mgrondona@llnl.gov>,
	Brian Behlendorf <behlendorf1@llnl.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:5321 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S965147AbWI0SxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 14:53:01 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060906030201020206020307
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Here at LLNL we have a rather challenging network environment on our 
clusters. We basically have 1000's of gigE links attached to an 
oversubscribed federated network. Most of the time this network is idle 
but the expected workload is for regular spikes extremely heavy activity 
lasting a few minutes. All end-points in a highly coordinated manor, 
typically after exiting an MPI barrier, start pushing as much data as 
possible through the oversubscribed core.  The result is a wave of TCP 
back-offs where all the TCP streams back-off in lock step. The network 
oscillates from highly congested for brief moments to largely idle. 
Given enough time TCP will settle down in to something mostly reasonable 
but even then it causes us a few problems:

1) It takes a long time for the network to settle in to a steady state 
and while it does network utilization is very poor.

2) Many of the sockets will rapidly back off to the maximum value.  This 
can lead to application level timeouts being triggered because we also 
initially calibrated the timeouts with the notion that 2 minute 
back-offs would be the exception and not the norm.

3) Once we reach steady state there's no guarantee of fairness between 
TCP streams.  For our workload this is particularly undesirable since 
the parallel job which kicked off all this activity must wait until the 
slowest transaction completes.  This translates in to 1000's of nodes 
sitting idle.

By knowing this is the expected workload on this dedicated network we
can safely make the back-offs more aggressive to mitigate most of these
issues.

We also played around with using a random seed when selecting the 
back-off interval to avoid all the sockets backing-off in lock step. 
That worked reasonably well but was more invasive then simply adding a 
few more tunable.

Because these are general utility clusters we run many different 
programs and so trying to fix this problem in the application is not 
possible since there are literally hundreds if not thousands of them.

We're more than willing to consider other approaches to handling this
particular workload better.  We've even considered that TCP isn't at all 
the right protocol but this affects several protocols including NFS and 
the benefits of running NFS over TCP are too great.

The original patch was prepared by Brian Behlendorf. He asked me to 
adapt it for current kernels keep it up to date and send upstream.

This may also help people like Andrew Athan which reported a similar 
problem a couple of days ago on the linux-net mailing list: 
http://www.uwsg.iu.edu/hypermail/linux/net/0609.3/0005.html I suspect 
that it is more common a case than is widely recognized.

Signed-off-by: Ben Woodard <woodard@redhat.com>
Signed-off-by: Brian Behlendorf <behlendorf1@llnl.gov>

--------------060906030201020206020307
Content-Type: text/x-patch;
 name="tcp-backoff-18.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcp-backoff-18.patch"

diff -ru linux-2.6.18/include/linux/sysctl.h linux-2.6.18.new/include/linux/sysctl.h
--- linux-2.6.18/include/linux/sysctl.h	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/include/linux/sysctl.h	2006-09-26 17:10:36.000000000 -0700
@@ -411,6 +411,8 @@
 	NET_IPV4_TCP_WORKAROUND_SIGNED_WINDOWS=115,
 	NET_TCP_DMA_COPYBREAK=116,
 	NET_TCP_SLOW_START_AFTER_IDLE=117,
+	NET_TCP_RTO_MAX=118,
+	NET_TCP_RTO_INIT=119,
 };
 
 enum {
Only in linux-2.6.18.new/include/linux: sysctl.h.orig
Only in linux-2.6.18.new/include/linux: sysctl.h.rej
diff -ru linux-2.6.18/include/linux/tcp.h linux-2.6.18.new/include/linux/tcp.h
--- linux-2.6.18/include/linux/tcp.h	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/include/linux/tcp.h	2006-09-26 17:08:33.000000000 -0700
@@ -94,6 +94,8 @@
 #define TCP_INFO		11	/* Information about this connection. */
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
 #define TCP_CONGESTION		13	/* Congestion control algorithm */
+#define TCP_BACKOFF_MAX         14      /* Maximum backoff value */
+#define TCP_BACKOFF_INIT        15      /* Initial backoff value */
 
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
@@ -257,6 +259,8 @@
 	__u8	frto_counter;	/* Number of new acks after RTO */
 	__u8	nonagle;	/* Disable Nagle algorithm?             */
 	__u8	keepalive_probes; /* num of allowed keep alive probes	*/
+        __u32   rto_max;        /* Maximum backoff value                */
+        __u32   rto_init;       /* Initial backoff value                */
 
 /* RTT measurement */
 	__u32	srtt;		/* smoothed round trip time << 3	*/
Only in linux-2.6.18.new/include/linux: tcp.h.orig
diff -ru linux-2.6.18/include/net/tcp.h linux-2.6.18.new/include/net/tcp.h
--- linux-2.6.18/include/net/tcp.h	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/include/net/tcp.h	2006-09-26 17:12:04.000000000 -0700
@@ -227,6 +227,8 @@
 extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
+extern int sysctl_tcp_rto_max;
+extern int sysctl_tcp_rto_init;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
Only in linux-2.6.18.new/include/net: tcp.h.orig
Only in linux-2.6.18.new/include/net: tcp.h.rej
diff -ru linux-2.6.18/net/ipv4/sysctl_net_ipv4.c linux-2.6.18.new/net/ipv4/sysctl_net_ipv4.c
--- linux-2.6.18/net/ipv4/sysctl_net_ipv4.c	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/net/ipv4/sysctl_net_ipv4.c	2006-09-26 17:08:33.000000000 -0700
@@ -697,6 +697,22 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+	{
+	        .ctl_name       = NET_TCP_RTO_MAX,
+		.procname       = "tcp_rto_max",
+		.data           = &sysctl_tcp_rto_max,
+		.maxlen         = sizeof(unsigned),
+		.mode           = 0644,
+		.proc_handler   = &proc_dointvec
+	},
+	{
+	        .ctl_name       = NET_TCP_RTO_INIT,
+		.procname       = "tcp_rto_init",
+		.data           = &sysctl_tcp_rto_init,
+		.maxlen         = sizeof(unsigned),
+		.mode           = 0644,
+		.proc_handler   = &proc_dointvec
+	},
 	{ .ctl_name = 0 }
 };
 
Only in linux-2.6.18.new/net/ipv4: sysctl_net_ipv4.c.orig
diff -ru linux-2.6.18/net/ipv4/tcp.c linux-2.6.18.new/net/ipv4/tcp.c
--- linux-2.6.18/net/ipv4/tcp.c	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/net/ipv4/tcp.c	2006-09-26 17:08:33.000000000 -0700
@@ -1939,6 +1939,21 @@
 		}
 		break;
 
+        case TCP_BACKOFF_MAX:
+                if (val < 1)
+                        err = -EINVAL;
+                else
+                        tp->rto_max = val * HZ;
+                break;
+ 
+        case TCP_BACKOFF_INIT:
+                if (val < 1)
+                        err = -EINVAL;
+                else
+                        tp->rto_init = val * HZ;
+                break;
+ 
+ 
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -2110,6 +2125,12 @@
 		if (copy_to_user(optval, icsk->icsk_ca_ops->name, len))
 			return -EFAULT;
 		return 0;
+        case TCP_BACKOFF_MAX:
+                val = (tp->rto_max ? : sysctl_tcp_rto_max) / HZ;
+                break;
+        case TCP_BACKOFF_INIT:
+                val = (tp->rto_init ? : sysctl_tcp_rto_init) / HZ;
+                break;
 	default:
 		return -ENOPROTOOPT;
 	};
Only in linux-2.6.18.new/net/ipv4: tcp.c.orig
diff -ru linux-2.6.18/net/ipv4/tcp_timer.c linux-2.6.18.new/net/ipv4/tcp_timer.c
--- linux-2.6.18/net/ipv4/tcp_timer.c	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/net/ipv4/tcp_timer.c	2006-09-26 17:08:33.000000000 -0700
@@ -31,6 +31,8 @@
 int sysctl_tcp_retries1 = TCP_RETR1;
 int sysctl_tcp_retries2 = TCP_RETR2;
 int sysctl_tcp_orphan_retries;
+int sysctl_tcp_rto_max  = TCP_RTO_MAX;
+int sysctl_tcp_rto_init = TCP_TIMEOUT_INIT;
 
 static void tcp_write_timer(unsigned long);
 static void tcp_delack_timer(unsigned long);
@@ -71,7 +73,8 @@
 
 	/* If peer does not open window for long time, or did not transmit 
 	 * anything for long time, penalize it. */
-	if ((s32)(tcp_time_stamp - tp->lsndtime) > 2*TCP_RTO_MAX || !do_reset)
+	if ((s32)(tcp_time_stamp - tp->lsndtime) >
+	    2 * (tp->rto_max ? : sysctl_tcp_rto_max) || !do_reset)
 		orphans <<= 1;
 
 	/* If some dubious ICMP arrived, penalize even more. */
@@ -256,8 +259,8 @@
 	max_probes = sysctl_tcp_retries2;
 
 	if (sock_flag(sk, SOCK_DEAD)) {
-		const int alive = ((icsk->icsk_rto << icsk->icsk_backoff) < TCP_RTO_MAX);
- 
+		const int alive = ((icsk->icsk_rto << icsk->icsk_backoff) < 
+				   (tp->rto_max ? : sysctl_tcp_rto_max));
 		max_probes = tcp_orphan_retries(sk, alive);
 
 		if (tcp_out_of_resources(sk, alive || icsk->icsk_probes_out <= max_probes))
@@ -301,7 +304,8 @@
 			       inet->num, tp->snd_una, tp->snd_nxt);
 		}
 #endif
-		if (tcp_time_stamp - tp->rcv_tstamp > TCP_RTO_MAX) {
+		if (tcp_time_stamp - tp->rcv_tstamp > 
+		    (tp->rto_max ? : sysctl_tcp_rto_max)) {
 			tcp_write_err(sk);
 			goto out;
 		}
@@ -373,7 +377,8 @@
 
 out_reset_timer:
 	icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
-	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
+	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, 
+				  (tp->rto_max ? : sysctl_tcp_rto_max));
 	if (icsk->icsk_retransmits > sysctl_tcp_retries1)
 		__sk_dst_reset(sk);
 
@@ -428,7 +433,8 @@
 static void tcp_synack_timer(struct sock *sk)
 {
 	inet_csk_reqsk_queue_prune(sk, TCP_SYNQ_INTERVAL,
-				   TCP_TIMEOUT_INIT, TCP_RTO_MAX);
+				   TCP_TIMEOUT_INIT, 
+				   ((tp->rto_init ? : sysctl_tcp_rto_init)));
 }
 
 void tcp_set_keepalive(struct sock *sk, int val)

--------------060906030201020206020307--
