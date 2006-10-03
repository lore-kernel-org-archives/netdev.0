From: Ben Woodard <woodard@redhat.com>
Subject: Re: [PATCH] Customizable TCP backoff patch
Date: Tue, 03 Oct 2006 11:14:38 -0700
Message-ID: <4522A88E.2070200@redhat.com>
References: <451AC889.5000407@redhat.com> <20060927.161638.62343616.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010801010704080303060904"
Cc: netdev@vger.kernel.org, mgrondona@llnl.gov, behlendorf1@llnl.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52360 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751024AbWJCSOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 14:14:47 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060927.161638.62343616.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010801010704080303060904
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Ben Woodard <woodard@redhat.com>
> Date: Wed, 27 Sep 2006 11:52:57 -0700
> 
>> Because these are general utility clusters we run many different 
>> programs and so trying to fix this problem in the application is not 
>> possible since there are literally hundreds if not thousands of them.
> 
> Then why add a socket option setting as your patch does? :-)
> 
> I also object to the socket option setting being allowed for
> any user because this can have awful effects if allowed by
> arbitrary users on arbitrary networks.
> 
>> We're more than willing to consider other approaches to handling this
>> particular workload better.  We've even considered that TCP isn't at all 
>> the right protocol but this affects several protocols including NFS and 
>> the benefits of running NFS over TCP are too great.
>>
>> The original patch was prepared by Brian Behlendorf. He asked me to 
>> adapt it for current kernels keep it up to date and send upstream.
>>
>> This may also help people like Andrew Athan which reported a similar 
>> problem a couple of days ago on the linux-net mailing list: 
>> http://www.uwsg.iu.edu/hypermail/linux/net/0609.3/0005.html I suspect 
>> that it is more common a case than is widely recognized.
>>
>> Signed-off-by: Ben Woodard <woodard@redhat.com>
>> Signed-off-by: Brian Behlendorf <behlendorf1@llnl.gov>
> 
> Other issues:
> 
> 1) 2 "u32" in the tcp_sock is a lot of space to devote to this
>    new state.  If it can fit in 2 "u16"'s or even less space,
>    please use that.
> 
> 2) the expression "(tp->foo ? : sysctl_foo)" is repeated many times
>    in the patch, please encapsulate it into an inline function
>    or similar
> 

How does this look to you for answering your two complaints above.

> I'm still torn on the fundamental issues of this patch.  I think
> random backoff is a better generic solution to this kind of problem.
> If it works for ethernet, it might just work for TCP too :-)

I haven't taken this on in this patch. I'd have to think more about how 
to do that and I'm not sure that introducing randomness here will allow 
us to settle into a steady state faster than configuring a shorter 
timeout in the environments that need it.

> 
> Thanks.


--------------010801010704080303060904
Content-Type: text/x-patch;
 name="tcp-backoff-18-2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcp-backoff-18-2.diff"

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
+++ linux-2.6.18.new/include/linux/tcp.h	2006-09-28 13:18:12.000000000 -0700
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
+        __u16   rto_max;        /* Maximum backoff value                */
+        __u16   rto_init;       /* Initial backoff value                */
 
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
+++ linux-2.6.18.new/net/ipv4/tcp.c	2006-09-28 13:56:24.000000000 -0700
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
+                        tp->rto_max = val * HZ;
+                break;
+ 
+        case TCP_BACKOFF_INIT:
+                if (val < 1 || val > TCP_BACKOFF_MAXVAL)
+                        err = -EINVAL;
+                else
+                        tp->rto_init = val * HZ;
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
+++ linux-2.6.18.new/net/ipv4/tcp_timer.c	2006-09-28 16:41:39.000000000 -0700
@@ -31,11 +31,21 @@
 int sysctl_tcp_retries1 = TCP_RETR1;
 int sysctl_tcp_retries2 = TCP_RETR2;
 int sysctl_tcp_orphan_retries;
+int sysctl_tcp_rto_max  = TCP_RTO_MAX;
+int sysctl_tcp_rto_init = TCP_TIMEOUT_INIT;
 
 static void tcp_write_timer(unsigned long);
 static void tcp_delack_timer(unsigned long);
 static void tcp_keepalive_timer (unsigned long data);
 
+static inline __u16 rto_max(struct tcp_sock *tp){
+        return tp->rto_max ? : sysctl_tcp_rto_max;
+}
+
+static inline __u16 rto_init(struct tcp_sock *tp){
+        return tp->rto_init ? : sysctl_tcp_rto_init;
+}
+
 void tcp_init_xmit_timers(struct sock *sk)
 {
 	inet_csk_init_xmit_timers(sk, &tcp_write_timer, &tcp_delack_timer,
@@ -71,7 +81,7 @@
 
 	/* If peer does not open window for long time, or did not transmit 
 	 * anything for long time, penalize it. */
-	if ((s32)(tcp_time_stamp - tp->lsndtime) > 2*TCP_RTO_MAX || !do_reset)
+	if ((s32)(tcp_time_stamp - tp->lsndtime) > 2*rto_max(tp) || !do_reset)
 		orphans <<= 1;
 
 	/* If some dubious ICMP arrived, penalize even more. */
@@ -256,8 +266,8 @@
 	max_probes = sysctl_tcp_retries2;
 
 	if (sock_flag(sk, SOCK_DEAD)) {
-		const int alive = ((icsk->icsk_rto << icsk->icsk_backoff) < TCP_RTO_MAX);
- 
+		const int alive = ((icsk->icsk_rto << icsk->icsk_backoff) < 
+				   rto_max(tp));
 		max_probes = tcp_orphan_retries(sk, alive);
 
 		if (tcp_out_of_resources(sk, alive || icsk->icsk_probes_out <= max_probes))
@@ -301,7 +311,7 @@
 			       inet->num, tp->snd_una, tp->snd_nxt);
 		}
 #endif
-		if (tcp_time_stamp - tp->rcv_tstamp > TCP_RTO_MAX) {
+		if (tcp_time_stamp - tp->rcv_tstamp > rto_max(tp)) {
 			tcp_write_err(sk);
 			goto out;
 		}
@@ -373,7 +383,8 @@
 
 out_reset_timer:
 	icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
-	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
+	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, 
+				  rto_max(tp));
 	if (icsk->icsk_retransmits > sysctl_tcp_retries1)
 		__sk_dst_reset(sk);
 
@@ -427,8 +438,8 @@
 
 static void tcp_synack_timer(struct sock *sk)
 {
-	inet_csk_reqsk_queue_prune(sk, TCP_SYNQ_INTERVAL,
-				   TCP_TIMEOUT_INIT, TCP_RTO_MAX);
+	inet_csk_reqsk_queue_prune(sk, TCP_SYNQ_INTERVAL, 
+				   TCP_TIMEOUT_INIT, rto_max(tcp_sk(sk)));
 }
 
 void tcp_set_keepalive(struct sock *sk, int val)

--------------010801010704080303060904--
