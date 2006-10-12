From: Ben Woodard <woodard@redhat.com>
Subject: Re: [PATCH] Customizable TCP backoff patch
Date: Thu, 12 Oct 2006 08:49:25 -0700
Message-ID: <452E6405.1010607@redhat.com>
References: <452C4D12.9060102@redhat.com>	<452CF94B.9000309@hp.com>	<452D918C.6050300@redhat.com> <20061012.100615.18914547.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020401060103040301000405"
Cc: vladislav.yasevich@hp.com, davem@davemloft.net,
	netdev@vger.kernel.org, mgrondona@llnl.gov, behlendorf1@llnl.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58267 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1422714AbWJLPtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 11:49:42 -0400
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20061012.100615.18914547.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020401060103040301000405
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

YOSHIFUJI Hideaki / 吉藤英明 wrote:
>> +		.data		= &sysctl_tcp_rto_max,
>> +		.maxlen		= sizeof(unsigned),
> 
> sizeof(unsigned long)

Good catch. That would have corrupted things badly on some 64b 
platforms. With all the flux in the area I forgot to change the size of 
that but would have been OK on the ia32 boxes.

>> diff -ru linux-2.6.18/net/ipv4/tcp.c linux-2.6.18.new/net/ipv4/tcp.c
>> --- linux-2.6.18/net/ipv4/tcp.c	2006-09-19 20:42:06.000000000 -0700
>> +++ linux-2.6.18.new/net/ipv4/tcp.c	2006-10-11 16:00:37.000000000 -0700
>> @@ -2110,6 +2126,12 @@
>>  		if (copy_to_user(optval, icsk->icsk_ca_ops->name, len))
>>  			return -EFAULT;
>>  		return 0;
>> +	case TCP_BACKOFF_MAX:
>> +		val = jiffies_to_msecs(tcp_rto_max(tp));
>> +		break;
> 
> tp->rto_max
> 
>> +	case TCP_BACKOFF_INIT:
>> +		val = jiffies_to_msecs(tcp_rto_init(tp));
>> +		break;
>>  	default:
> 
> tp->rto_init

OK I get it now.

> 
> --yoshfuji


--------------020401060103040301000405
Content-Type: text/x-patch;
 name="tcp-backoff-18-6.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcp-backoff-18-6.diff"

diff -ru linux-2.6.18/include/linux/sysctl.h linux-2.6.18.new/include/linux/sysctl.h
--- linux-2.6.18/include/linux/sysctl.h	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/include/linux/sysctl.h	2006-10-11 10:27:52.000000000 -0700
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
+++ linux-2.6.18.new/include/linux/tcp.h	2006-10-12 08:28:52.645411000 -0700
@@ -94,6 +94,8 @@
 #define TCP_INFO		11	/* Information about this connection. */
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
 #define TCP_CONGESTION		13	/* Congestion control algorithm */
+#define TCP_BACKOFF_MAX		14	/* Maximum backoff value */
+#define TCP_BACKOFF_INIT	15	/* Initial backoff value */
 
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
@@ -257,6 +259,8 @@
 	__u8	frto_counter;	/* Number of new acks after RTO */
 	__u8	nonagle;	/* Disable Nagle algorithm?             */
 	__u8	keepalive_probes; /* num of allowed keep alive probes	*/
+	__u16	rto_max;	/* Maximum backoff value in ms		*/
+	__u16	rto_init;	/* Initial backoff value in ms		*/
 
 /* RTT measurement */
 	__u32	srtt;		/* smoothed round trip time << 3	*/
Only in linux-2.6.18.new/include/linux: tcp.h~
diff -ru linux-2.6.18/include/net/tcp.h linux-2.6.18.new/include/net/tcp.h
--- linux-2.6.18/include/net/tcp.h	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/include/net/tcp.h	2006-10-11 17:43:23.091431000 -0700
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
+	return tp->rto_max ? msecs_to_jiffies(tp->rto_max) : sysctl_tcp_rto_max;
+}
+
+static inline unsigned long tcp_rto_init(struct tcp_sock *tp)
+{
+	return tp->rto_init ? msecs_to_jiffies(tp->rto_init) : sysctl_tcp_rto_init;
+}
+
 /*
  * The next routines deal with comparing 32 bit unsigned ints
  * and worry about wraparound (automatic with unsigned arithmetic).
Only in linux-2.6.18.new/include/net: tcp.h~
diff -ru linux-2.6.18/net/ipv4/sysctl_net_ipv4.c linux-2.6.18.new/net/ipv4/sysctl_net_ipv4.c
--- linux-2.6.18/net/ipv4/sysctl_net_ipv4.c	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/net/ipv4/sysctl_net_ipv4.c	2006-10-12 07:14:41.871910000 -0700
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
+		.ctl_name	= NET_TCP_RTO_MAX,
+		.procname	= "tcp_rto_max",
+		.data		= &sysctl_tcp_rto_max,
+		.maxlen		= sizeof(unsigned long),
+		.mode		= 0644,
+		.proc_handler	= &proc_doulongvec_ms_jiffies_minmax,
+		.extra1		= &tcp_rto_min_constant,
+		.extra2		= &tcp_rto_max_constant,
+	},
+	{
+		.ctl_name	= NET_TCP_RTO_INIT,
+		.procname	= "tcp_rto_init",
+		.data		= &sysctl_tcp_rto_init,
+		.maxlen		= sizeof(unsigned long),
+		.mode		= 0644,
+		.proc_handler	= &proc_doulongvec_ms_jiffies_minmax,
+		.extra1		= &tcp_rto_min_constant,
+		.extra2		= &tcp_rto_max_constant,
+	},
 	{ .ctl_name = 0 }
 };
 
Only in linux-2.6.18.new/net/ipv4: sysctl_net_ipv4.c~
diff -ru linux-2.6.18/net/ipv4/tcp.c linux-2.6.18.new/net/ipv4/tcp.c
--- linux-2.6.18/net/ipv4/tcp.c	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/net/ipv4/tcp.c	2006-10-12 07:18:01.193083000 -0700
@@ -1764,6 +1764,8 @@
 	return err;
 }
 
+#define TCP_BACKOFF_MAXVAL 65535
+
 /*
  *	Socket option code for TCP.
  */
@@ -1939,6 +1941,20 @@
 		}
 		break;
 
+	case TCP_BACKOFF_MAX:
+		if (val < 1 || val > TCP_BACKOFF_MAXVAL)
+			err = -EINVAL;
+		else
+			tp->rto_max = val;
+		break;
+ 
+	case TCP_BACKOFF_INIT:
+		if (val < 1 || val > TCP_BACKOFF_MAXVAL)
+			err = -EINVAL;
+		else
+			tp->rto_init = val;
+		break;
+ 
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -2110,6 +2126,12 @@
 		if (copy_to_user(optval, icsk->icsk_ca_ops->name, len))
 			return -EFAULT;
 		return 0;
+	case TCP_BACKOFF_MAX:
+		val = tp->rto_max;
+		break;
+	case TCP_BACKOFF_INIT:
+		val = tp->rto_init;
+		break;
 	default:
 		return -ENOPROTOOPT;
 	};
Only in linux-2.6.18.new/net/ipv4: tcp.c~
diff -ru linux-2.6.18/net/ipv4/tcp_timer.c linux-2.6.18.new/net/ipv4/tcp_timer.c
--- linux-2.6.18/net/ipv4/tcp_timer.c	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18.new/net/ipv4/tcp_timer.c	2006-10-11 10:41:39.000000000 -0700
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

--------------020401060103040301000405--
