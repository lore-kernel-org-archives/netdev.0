From: Tom Herbert <therbert@google.com>
Subject: [PATCH] tcp: Socket option to set congestion window
Date: Tue, 25 May 2010 22:01:13 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1005252157150.27170@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, ycheng@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:56154 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab0EZFBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 01:01:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows an application to set the TCP congestion window
for a connection through a socket option.  The maximum value that
may set is specified in a sysctl value.  When the sysctl is set to
zero, the default value, the socket option is disabled.

The socket option is most useful to set the initial congestion
window for a connection to a larger value than the default in
order to improve latency.  This socket option would typically be
used by an "intelligent" application which might have better knowledge
than the kernel as to what an appropriate initial congestion window is.

One use of this might be with an application which maintains per
client path characteristics.  This could allow setting the congestion
window more precisely than which could be achieved through the
route command.

A second use of this might be to reduce the number of simultaneous
connections that a client might open to the server; for instance
when a web browser opens multiple connections to a server.  With multiple
connections the aggregate congestion window is larger than that of a
single connecton (num_conns * cwnd), this effectively can be used to
circumvent slowstart and improve latency.  With this socket option, a
single connection with a large initial congestion window could be used,
which retains the latency properties of multiple connections but
nicely reducing # of connections (load) on the network.

The systctl to enable and control this feature is

  net.ipv4.tcp_user_cwnd_max

The socket option call would be:

  setsockopt(fd, IPPROTO_TCP, TCP_CWND, &val, sizeof (val))

where val is the congestion window in # MSS.


Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index a778ee0..9e9692f 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -105,6 +105,7 @@ enum {
 #define TCP_COOKIE_TRANSACTIONS	15	/* TCP Cookie Transactions */
 #define TCP_THIN_LINEAR_TIMEOUTS 16      /* Use linear timeouts for thin streams*/
 #define TCP_THIN_DUPACK         17      /* Fast retrans. after 1 dupack */
+#define TCP_CWND		18	/* Set congestion window */
 
 /* for TCP_INFO socket option */
 #define TCPI_OPT_TIMESTAMPS	1
diff --git a/include/net/tcp.h b/include/net/tcp.h
index a144914..3d1f934 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -246,6 +246,7 @@ extern int sysctl_tcp_max_ssthresh;
 extern int sysctl_tcp_cookie_size;
 extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
+extern int sysctl_tcp_user_cwnd_max;
 
 extern atomic_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d96c1da..b35d18f 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -597,6 +597,13 @@ static struct ctl_table ipv4_table[] = {
 		.mode           = 0644,
 		.proc_handler   = proc_dointvec
 	},
+        {
+		.procname       = "tcp_user_cwnd_max",
+		.data           = &sysctl_tcp_user_cwnd_max,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec
+	},
 	{
 		.procname	= "udp_mem",
 		.data		= &sysctl_udp_mem,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 6596b4f..0ca9832 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2370,6 +2370,24 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		}
 		break;
 
+	case TCP_CWND:
+		if (sysctl_tcp_user_cwnd_max <= 0)
+			err = -EPERM;
+		else if (val > 0 && sk->sk_state == TCP_ESTABLISHED &&
+		    icsk->icsk_ca_state == TCP_CA_Open) {
+			u32 cwnd = val;
+			cwnd = min(cwnd, (u32)sysctl_tcp_user_cwnd_max);
+			cwnd = min(cwnd, tp->snd_cwnd_clamp);
+
+			if (tp->snd_cwnd != cwnd) {
+				tp->snd_cwnd = cwnd;
+				tp->snd_cwnd_stamp = tcp_time_stamp;
+				tp->snd_cwnd_cnt = 0;
+			}
+		} else
+			err = -EINVAL;
+		break;
+
 #ifdef CONFIG_TCP_MD5SIG
 	case TCP_MD5SIG:
 		/* Read the IP->Key mappings from userspace */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b4ed957..2d10a44 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -60,6 +60,8 @@ int sysctl_tcp_base_mss __read_mostly = 512;
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 
+int sysctl_tcp_user_cwnd_max __read_mostly;
+
 int sysctl_tcp_cookie_size __read_mostly = 0; /* TCP_COOKIE_MAX */
 EXPORT_SYMBOL_GPL(sysctl_tcp_cookie_size);
 
