From: Ben Woodard <woodard@redhat.com>
Subject: Re: [PATCH] Customizable TCP backoff patch
Date: Tue, 10 Oct 2006 18:46:58 -0700
Message-ID: <452C4D12.9060102@redhat.com>
References: <451AC889.5000407@redhat.com>	<20060927.161638.62343616.davem@davemloft.net>	<4522A88E.2070200@redhat.com> <20061004.000722.99203823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050000010604020409090703"
Cc: netdev@vger.kernel.org, mgrondona@llnl.gov, behlendorf1@llnl.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50661 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1030744AbWJKBrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2006 21:47:03 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061004.000722.99203823.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050000010604020409090703
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Ben Woodard <woodard@redhat.com>
> Date: Tue, 03 Oct 2006 11:14:38 -0700
> 
>>> Other issues:
>>>
>>> 1) 2 "u32" in the tcp_sock is a lot of space to devote to this
>>>    new state.  If it can fit in 2 "u16"'s or even less space,
>>>    please use that.
>>>
>>> 2) the expression "(tp->foo ? : sysctl_foo)" is repeated many times
>>>    in the patch, please encapsulate it into an inline function
>>>    or similar
>>>
>> How does this look to you for answering your two complaints above.
> 
> It looks a lot better.  I'd like you to take #2 further,
> put the inline function into net/tcp.h and use it in the
> tcp.c instances too.

Done. I orginally didn't want to grow the header files with two more 
functions that weren't use many places. Anyway this is fixed.

> 
> Also, please don't format code like this:
> 
> +static inline __u16 rto_max(struct tcp_sock *tp){
> +        return tp->rto_max ? : sysctl_tcp_rto_max;
> +}
> +
> +static inline __u16 rto_init(struct tcp_sock *tp){
> +        return tp->rto_init ? : sysctl_tcp_rto_init;
> +}
> 
> The opening brace of each functions belongs on a line by itself,
> thanks.

Fixed.

> 
> Finally, I'm not so sure "seconds" is the best unit for the
> socket option.  In fact you use "seconds" as the unit for
> the socket option and the sysctl is raw jiffies.  That's
> inconsistency is really problematic.
> 
> At the very least, seconds might not be fine enough granularity
> for some circumstances.  Heck, the default RTO_MIN is 1/5 of a
> second. :-)
> 
> I also understand that going to milliseconds or microseconds would
> make the size of the in-socket struct members an issue again.  These
> things are never easy are they? :-/
> 
> Any better ideas?

Here is what I've done. I store the values in the socket structure as ms 
so that they will fit into 16 bits and as jiffies in the global 
variables. Then I populate the global variables using 
proc_doulongvec_ms_jiffies()

How does that look to you?

-ben



--------------050000010604020409090703
Content-Type: text/x-patch;
 name="tcp-backoff-18-4.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcp-backoff-18-4.diff"

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
diff -ru linux-2.6.18/include/linux/tcp.h linux-2.6.18.new/include/linux/tcp.h
--- linux-2.6.18/include/linux/tcp.h	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/include/linux/tcp.h	2006-10-10 17:01:25.000000000 -0700
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
+        __u16   rto_max;        /* Maximum backoff value in ms          */
+        __u16   rto_init;       /* Initial backoff value in ms          */
 
 /* RTT measurement */
 	__u32	srtt;		/* smoothed round trip time << 3	*/
diff -ru linux-2.6.18/include/net/tcp.h linux-2.6.18.new/include/net/tcp.h
--- linux-2.6.18/include/net/tcp.h	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/include/net/tcp.h	2006-10-10 18:42:00.000000000 -0700
@@ -227,11 +227,23 @@
 extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
+extern unsigned long sysctl_tcp_rto_max;
+extern unsigned long sysctl_tcp_rto_init;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
 extern int tcp_memory_pressure;
 
+static inline unsigned long tcp_rto_max(struct tcp_sock *tp)
+{
+        return tp->rto_max ? tp->rto_max*HZ/1000 : sysctl_tcp_rto_max;
+}
+
+static inline unsigned long tcp_rto_init(struct tcp_sock *tp)
+{
+        return tp->rto_init ? tp->rto_init*HZ/1000 : sysctl_tcp_rto_init;
+}
+
 /*
  * The next routines deal with comparing 32 bit unsigned ints
  * and worry about wraparound (automatic with unsigned arithmetic).
diff -ru linux-2.6.18/net/ipv4/sysctl_net_ipv4.c linux-2.6.18.new/net/ipv4/sysctl_net_ipv4.c
--- linux-2.6.18/net/ipv4/sysctl_net_ipv4.c	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/net/ipv4/sysctl_net_ipv4.c	2006-10-10 16:32:08.000000000 -0700
@@ -128,6 +128,8 @@
 	return ret;
 }
 
+static unsigned long tcp_rto_min=0;
+static unsigned long tcp_rto_max=65535;
 
 ctl_table ipv4_table[] = {
         {
@@ -697,6 +699,26 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+	{
+	        .ctl_name       = NET_TCP_RTO_MAX,
+		.procname       = "tcp_rto_max",
+		.data           = &sysctl_tcp_rto_max,
+		.maxlen         = sizeof(unsigned),
+		.mode           = 0644,
+		.proc_handler   = &proc_doulongvec_ms_jiffies,
+		.extra1         = &tcp_rto_min_constant,
+		.extra2         = &tcp_rto_max_constant,
+	},
+	{
+	        .ctl_name       = NET_TCP_RTO_INIT,
+		.procname       = "tcp_rto_init",
+		.data           = &sysctl_tcp_rto_init,
+		.maxlen         = sizeof(unsigned),
+		.mode           = 0644,
+		.proc_handler   = &proc_doulongvec_ms_jiffies,
+		.extra1         = &tcp_rto_min_constant,
+		.extra2         = &tcp_rto_max_constant,
+	},
 	{ .ctl_name = 0 }
 };
 
diff -ru linux-2.6.18/net/ipv4/tcp.c linux-2.6.18.new/net/ipv4/tcp.c
--- linux-2.6.18/net/ipv4/tcp.c	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/net/ipv4/tcp.c	2006-10-10 18:37:40.000000000 -0700
@@ -1764,6 +1764,8 @@
 	return err;
 }
 
+#define TCP_BACKOFF_MAXVAL 65535
+
 /*
  *	Socket option code for TCP.
  */
@@ -1939,6 +1941,21 @@
 		}
 		break;
 
+        case TCP_BACKOFF_MAX:
+                if (val < 1 || val > TCP_BACKOFF_MAXVAL)
+                        err = -EINVAL;
+                else
+                        tp->rto_max = val;
+                break;
+ 
+        case TCP_BACKOFF_INIT:
+                if (val < 1 || val > TCP_BACKOFF_MAXVAL)
+                        err = -EINVAL;
+                else
+                        tp->rto_init = val;
+                break;
+ 
+ 
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -2110,6 +2127,12 @@
 		if (copy_to_user(optval, icsk->icsk_ca_ops->name, len))
 			return -EFAULT;
 		return 0;
+        case TCP_BACKOFF_MAX:
+	        val = tcp_rto_max(tp)*1000/HZ;
+                break;
+        case TCP_BACKOFF_INIT:
+	        val = tcp_rto_init(tp)*1000/HZ;
+                break;
 	default:
 		return -ENOPROTOOPT;
 	};
diff -ru linux-2.6.18/net/ipv4/tcp_timer.c linux-2.6.18.new/net/ipv4/tcp_timer.c
--- linux-2.6.18/net/ipv4/tcp_timer.c	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/net/ipv4/tcp_timer.c	2006-10-10 16:25:10.000000000 -0700
@@ -31,6 +31,8 @@
 int sysctl_tcp_retries1 = TCP_RETR1;
 int sysctl_tcp_retries2 = TCP_RETR2;
 int sysctl_tcp_orphan_retries;
+unsigned long sysctl_tcp_rto_max  = TCP_RTO_MAX;
+unsigned long sysctl_tcp_rto_init = TCP_TIMEOUT_INIT;
 
 static void tcp_write_timer(unsigned long);
 static void tcp_delack_timer(unsigned long);
@@ -71,7 +73,8 @@
 
 	/* If peer does not open window for long time, or did not transmit 
 	 * anything for long time, penalize it. */
-	if ((s32)(tcp_time_stamp - tp->lsndtime) > 2*TCP_RTO_MAX || !do_reset)
+	if ((s32)(tcp_time_stamp - tp->lsndtime) > 2*tcp_rto_max(tp) || 
+	    !do_reset)
 		orphans <<= 1;
 
 	/* If some dubious ICMP arrived, penalize even more. */
@@ -256,8 +259,8 @@
 	max_probes = sysctl_tcp_retries2;
 
 	if (sock_flag(sk, SOCK_DEAD)) {
-		const int alive = ((icsk->icsk_rto << icsk->icsk_backoff) < TCP_RTO_MAX);
- 
+		const int alive = ((icsk->icsk_rto << icsk->icsk_backoff) < 
+				   tcp_rto_max(tp));
 		max_probes = tcp_orphan_retries(sk, alive);
 
 		if (tcp_out_of_resources(sk, alive || icsk->icsk_probes_out <= max_probes))
@@ -301,7 +304,7 @@
 			       inet->num, tp->snd_una, tp->snd_nxt);
 		}
 #endif
-		if (tcp_time_stamp - tp->rcv_tstamp > TCP_RTO_MAX) {
+		if (tcp_time_stamp - tp->rcv_tstamp > tcp_rto_max(tp)) {
 			tcp_write_err(sk);
 			goto out;
 		}
@@ -373,7 +376,8 @@
 
 out_reset_timer:
 	icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
-	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
+	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, 
+				  tcp_rto_max(tp));
 	if (icsk->icsk_retransmits > sysctl_tcp_retries1)
 		__sk_dst_reset(sk);
 
@@ -427,8 +431,8 @@
 
 static void tcp_synack_timer(struct sock *sk)
 {
-	inet_csk_reqsk_queue_prune(sk, TCP_SYNQ_INTERVAL,
-				   TCP_TIMEOUT_INIT, TCP_RTO_MAX);
+	inet_csk_reqsk_queue_prune(sk, TCP_SYNQ_INTERVAL, TCP_TIMEOUT_INIT, 
+				   tcp_rto_max(tcp_sk(sk)));
 }
 
 void tcp_set_keepalive(struct sock *sk, int val)

--------------050000010604020409090703--
