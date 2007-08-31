From: Rick Jones <rick.jones2@hp.com>
Subject: [PATCH] make _minimum_ TCP retransmission timeout configurable take 2
Date: Thu, 30 Aug 2007 17:09:04 -0700 (PDT)
Message-ID: <200708310009.RAA04175@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=X-roman8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:52666 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755270AbXHaAJW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 20:09:22 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel11.hp.com (Postfix) with ESMTP id 26A2138FA2
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2007 17:09:12 -0700 (PDT)
Received: (from raj@localhost)
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) id RAA04175
	for netdev@vger.kernel.org; Thu, 30 Aug 2007 17:09:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable configuration of the minimum TCP Retransmission Timeout via
a new sysctl "tcp_rto_min" to help those who's networks (eg cellular)
have quite variable RTTs avoid spurrious RTOs.

Signed-off-by: Rick Jones <rick.jones2@hp.com>
Signed-off-by: Lamont Jones <lamont@hp.com>
---

diff -r 06d7322848a3 Documentation/networking/ip-sysctl.txt
--- a/Documentation/networking/ip-sysctl.txt	Mon Aug 27 18:32:35 2007 -0700
+++ b/Documentation/networking/ip-sysctl.txt	Thu Aug 30 17:06:16 2007 -0700
@@ -339,6 +339,13 @@ tcp_rmem - vector of 3 INTEGERs: min, de
 	selected receiver buffers for TCP socket. This value does not override
 	net.core.rmem_max, "static" selection via SO_RCVBUF does not use this.
 	Default: 87380*2 bytes.
+
+tcp_rto_min - INTEGER
+	The minimum value for the TCP Retransmission Timeout, expressed
+	in milliseconds for the convenience of the user.
+	This is bounded at the low-end by TCP_RTO_MIN and by TCP_RTO_MAX at
+	the high-end.	
+	Default: 200.
 
 tcp_sack - BOOLEAN
 	Enable select acknowledgments (SACKS).
diff -r 06d7322848a3 include/net/tcp.h
--- a/include/net/tcp.h	Mon Aug 27 18:32:35 2007 -0700
+++ b/include/net/tcp.h	Thu Aug 30 17:06:16 2007 -0700
@@ -232,6 +232,7 @@ extern int sysctl_tcp_workaround_signed_
 extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_max_ssthresh;
+extern unsigned int sysctl_tcp_rto_min;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
diff -r 06d7322848a3 net/ipv4/sysctl_net_ipv4.c
--- a/net/ipv4/sysctl_net_ipv4.c	Mon Aug 27 18:32:35 2007 -0700
+++ b/net/ipv4/sysctl_net_ipv4.c	Thu Aug 30 17:06:16 2007 -0700
@@ -186,6 +186,32 @@ static int strategy_allowed_congestion_c
 
 }
 
+/* if there is ever a proc_dointvec_ms_jiffies_minmax we can get rid
+   of this routine */
+
+static int proc_tcp_rto_min(ctl_table *ctl, int write, struct file *filp,
+			    void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	u32 *valp = ctl->data;
+	u32 oldval = *valp;
+	int ret;
+
+	ret = proc_dointvec_ms_jiffies(ctl, write, filp, buffer, lenp, ppos);
+	if (ret)
+		return ret;
+
+	/* some bounds checking would be in order */   
+	if (write && *valp != oldval) {
+		if (*valp < TCP_RTO_MIN || *valp > TCP_RTO_MAX) {
+			*valp = oldval;
+			return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
+
 ctl_table ipv4_table[] = {
 	{
 		.ctl_name	= NET_IPV4_TCP_TIMESTAMPS,
@@ -819,6 +845,14 @@ ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "tcp_rto_min",
+		.data		= &sysctl_tcp_rto_min,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_tcp_rto_min
+	},
 	{ .ctl_name = 0 }
 };
 
diff -r 06d7322848a3 net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	Mon Aug 27 18:32:35 2007 -0700
+++ b/net/ipv4/tcp_input.c	Thu Aug 30 17:06:16 2007 -0700
@@ -91,6 +91,8 @@ int sysctl_tcp_nometrics_save __read_mos
 
 int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
 int sysctl_tcp_abc __read_mostly;
+
+unsigned int sysctl_tcp_rto_min __read_mostly = TCP_RTO_MIN;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
@@ -616,13 +618,13 @@ static void tcp_rtt_estimator(struct soc
 			if (tp->mdev_max < tp->rttvar)
 				tp->rttvar -= (tp->rttvar-tp->mdev_max)>>2;
 			tp->rtt_seq = tp->snd_nxt;
-			tp->mdev_max = TCP_RTO_MIN;
+			tp->mdev_max = sysctl_tcp_rto_min;
 		}
 	} else {
 		/* no previous measure. */
 		tp->srtt = m<<3;	/* take the measured time to be rtt */
 		tp->mdev = m<<1;	/* make sure rto = 3*rtt */
-		tp->mdev_max = tp->rttvar = max(tp->mdev, TCP_RTO_MIN);
+		tp->mdev_max = tp->rttvar = max(tp->mdev, sysctl_tcp_rto_min);
 		tp->rtt_seq = tp->snd_nxt;
 	}
 }
@@ -851,7 +853,7 @@ static void tcp_init_metrics(struct sock
 	}
 	if (dst_metric(dst, RTAX_RTTVAR) > tp->mdev) {
 		tp->mdev = dst_metric(dst, RTAX_RTTVAR);
-		tp->mdev_max = tp->rttvar = max(tp->mdev, TCP_RTO_MIN);
+		tp->mdev_max = tp->rttvar = max(tp->mdev, sysctl_tcp_rto_min);
 	}
 	tcp_set_rto(sk);
 	tcp_bound_rto(sk);
