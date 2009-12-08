From: chavey@google.com
Subject: [PATCH] Add sysctl to set the advertised TCP initial receive window.
Date: Tue, 08 Dec 2009 14:40:49 -0800
Message-ID: <pvm638hum1a.fsf@chavey.mtv.corp.google.com>
Cc: netdev@vger.kernel.org, therbert@google.com, chavey@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:33981 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966565AbZLHWkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 17:40:49 -0500
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id nB8MesPW017248
	for <netdev@vger.kernel.org>; Tue, 8 Dec 2009 14:40:55 -0800
Received: from ywh26 (ywh26.prod.google.com [10.192.8.26])
	by kpbe15.cbf.corp.google.com with ESMTP id nB8MerRh012627
	for <netdev@vger.kernel.org>; Tue, 8 Dec 2009 14:40:53 -0800
Received: by ywh26 with SMTP id 26so12393775ywh.12
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2009 14:40:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a sysctl, tcp_init_rcv_wnd, to set the TCP initial receive window
size advertised by passive and active TCP connections. 
The current Linux TCP implementation limits the advertised TCP initial
receive window to the one proscribed by slow start. For short leave
TCP connections used for transaction type of traffic (i.e. http
requests), bounding the advertised TCP initial receive window results
in increased latency to complete the transaction. There exists
environments where strict adherence to using the TCP initial receive
window used by slow start is un-necessary. 
The tcp_init_rcv_wnd sysctl allows increasing the TCP initial receive
window for all TCP connections or on a per TCP connection, allowing
for some of the TCP connection to advertise larger TCP receive window
than the ones bounded by slow start.

Signed-off-by: Laurent Chavey <chavey@google.com>
---

 Documentation/networking/ip-sysctl.txt |    6 ++++++
 include/linux/tcp.h                    |    2 ++
 include/net/tcp.h                      |    7 ++++++-
 net/ipv4/inet_connection_sock.c        |    5 +++++
 net/ipv4/syncookies.c                  |    2 +-
 net/ipv4/sysctl_net_ipv4.c             |    8 ++++++++
 net/ipv4/tcp.c                         |   10 ++++++++++
 net/ipv4/tcp_ipv4.c                    |    3 ++-
 net/ipv4/tcp_output.c                  |   20 ++++++++++++++++----
 net/ipv6/syncookies.c                  |    3 +--
 10 files changed, 57 insertions(+), 9 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index fbe427a..7224d12 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -479,6 +479,12 @@ tcp_dma_copybreak - INTEGER
 	and CONFIG_NET_DMA is enabled.
 	Default: 4096
 
+tcp_init_rcv_wnd - INTEGER
+	Initial receive window, in MSS, advertised by an active or passive
+	tcp socket. Use a value from 0 to TCP_INIT_RCV_WND_MAX. When
+	set to 0, use an initial receive window following RFC2414.
+	Default: 0
+
 UDP variables:
 
 udp_mem - vector of 3 INTEGERs: min, pressure, max
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 61723a7..4a622a0 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -96,6 +96,7 @@ enum {
 #define TCP_QUICKACK		12	/* Block/reenable quick acks */
 #define TCP_CONGESTION		13	/* Congestion control algorithm */
 #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
+#define TCP_INIT_RCV_WND	15	/* Passive connection receive window */
 
 #define TCPI_OPT_TIMESTAMPS	1
 #define TCPI_OPT_SACK		2
@@ -221,6 +222,7 @@ struct tcp_options_received {
 	u8	num_sacks;	/* Number of SACK blocks		*/
 	u16	user_mss;  	/* mss requested by user in ioctl */
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
+	u8	init_rcv_wnd;	/* TCP initial receive window in MSS */
 };
 
 /* This is the max number of SACKS that we'll generate and process. It's safe
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 03a49c7..5c2e3db 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -65,6 +65,9 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 /* Minimal RCV_MSS. */
 #define TCP_MIN_RCVMSS		536U
 
+/* TCP initial receive window. Maximum number of mss allowed. */
+#define TCP_INIT_RCV_WND_MAX	16
+
 /* The least MTU to use for probing */
 #define TCP_BASE_MSS		512
 
@@ -237,6 +240,7 @@ extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_max_ssthresh;
+extern int sysctl_tcp_init_rcv_wnd;
 
 extern atomic_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
@@ -972,7 +976,8 @@ static inline void tcp_sack_reset(struct tcp_options_received *rx_opt)
 /* Determine a window scaling and initial window to offer. */
 extern void tcp_select_initial_window(int __space, __u32 mss,
 				      __u32 *rcv_wnd, __u32 *window_clamp,
-				      int wscale_ok, __u8 *rcv_wscale);
+				      int wscale_ok, __u8 *rcv_wscale,
+				      struct tcp_sock *tp);
 
 static inline int tcp_win_from_space(int space)
 {
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 537731b..9766d43 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -20,6 +20,7 @@
 #include <net/inet_hashtables.h>
 #include <net/inet_timewait_sock.h>
 #include <net/ip.h>
+#include <net/tcp.h>
 #include <net/route.h>
 #include <net/tcp_states.h>
 #include <net/xfrm.h>
@@ -628,11 +629,15 @@ int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int rc = reqsk_queue_alloc(&icsk->icsk_accept_queue, nr_table_entries);
 
 	if (rc != 0)
 		return rc;
 
+	if (tp->rx_opt.init_rcv_wnd == 0)
+		tp->rx_opt.init_rcv_wnd = sysctl_tcp_init_rcv_wnd;
+
 	sk->sk_max_ack_backlog = 0;
 	sk->sk_ack_backlog = 0;
 	inet_csk_delack_init(sk);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index a6e0e07..fa4ed8c 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -356,7 +356,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
 				  &req->rcv_wnd, &req->window_clamp,
-				  ireq->wscale_ok, &rcv_wscale);
+				  ireq->wscale_ok, &rcv_wscale, tp);
 
 	ireq->rcv_wscale  = rcv_wscale;
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 2dcf04d..85232fc 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -656,6 +656,14 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "tcp_init_rcv_wnd",
+		.data 		= &sysctl_tcp_init_rcv_wnd,
+		.maxlen 	= sizeof(int),
+		.mode 		= 0644,
+		.proc_handler 	= &proc_dointvec,
+	},
 #ifdef CONFIG_NETLABEL
 	{
 		.ctl_name	= NET_CIPSOV4_CACHE_ENABLE,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f1813bc..7567edd 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2248,6 +2248,11 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		break;
 #endif
 
+	case TCP_INIT_RCV_WND:
+		val = min_t(int, val, TCP_INIT_RCV_WND_MAX);
+		tp->rx_opt.init_rcv_wnd = val;
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -2425,6 +2430,11 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		if (copy_to_user(optval, icsk->icsk_ca_ops->name, len))
 			return -EFAULT;
 		return 0;
+
+	case TCP_INIT_RCV_WND:
+		val = tp->rx_opt.init_rcv_wnd;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7cda24b..1611e95 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1829,6 +1829,8 @@ static int tcp_v4_init_sock(struct sock *sk)
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
+	tp->rx_opt.init_rcv_wnd = sysctl_tcp_init_rcv_wnd;
+
 	local_bh_disable();
 	percpu_counter_inc(&tcp_sockets_allocated);
 	local_bh_enable();
@@ -2493,4 +2495,3 @@ EXPORT_SYMBOL(tcp_proc_register);
 EXPORT_SYMBOL(tcp_proc_unregister);
 #endif
 EXPORT_SYMBOL(sysctl_tcp_low_latency);
-
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fcd278a..ec8b153 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -59,6 +59,9 @@ int sysctl_tcp_base_mss __read_mostly = 512;
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 
+/* Initial advertised receive window. Enabled using a non '0' value.*/
+int sysctl_tcp_init_rcv_wnd __read_mostly = 0;
+
 /* Account for new data that has been sent to the network. */
 static void tcp_event_new_data_sent(struct sock *sk, struct sk_buff *skb)
 {
@@ -179,7 +182,8 @@ static inline void tcp_event_ack_sent(struct sock *sk, unsigned int pkts)
  */
 void tcp_select_initial_window(int __space, __u32 mss,
 			       __u32 *rcv_wnd, __u32 *window_clamp,
-			       int wscale_ok, __u8 *rcv_wscale)
+			       int wscale_ok, __u8 *rcv_wscale,
+			       struct tcp_sock *tp)
 {
 	unsigned int space = (__space < 0 ? 0 : __space);
 
@@ -228,7 +232,13 @@ void tcp_select_initial_window(int __space, __u32 mss,
 			init_cwnd = 2;
 		else if (mss > 1460)
 			init_cwnd = 3;
-		if (*rcv_wnd > init_cwnd * mss)
+		/* when initializing use the value from init_rcv_wnd
+		 * rather than the default from above
+		 */
+		if (tp && tp->rx_opt.init_rcv_wnd &&
+		    (*rcv_wnd > tp->rx_opt.init_rcv_wnd * mss))
+			*rcv_wnd = tp->rx_opt.init_rcv_wnd * mss;
+		else if (*rcv_wnd > init_cwnd * mss)
 			*rcv_wnd = init_cwnd * mss;
 	}
 
@@ -2254,7 +2264,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 			&req->rcv_wnd,
 			&req->window_clamp,
 			ireq->wscale_ok,
-			&rcv_wscale);
+			&rcv_wscale,
+			tp);
 		ireq->rcv_wscale = rcv_wscale;
 	}
 
@@ -2342,7 +2353,8 @@ static void tcp_connect_init(struct sock *sk)
 				  &tp->rcv_wnd,
 				  &tp->window_clamp,
 				  sysctl_tcp_window_scaling,
-				  &rcv_wscale);
+				  &rcv_wscale,
+				  tp);
 
 	tp->rx_opt.rcv_wscale = rcv_wscale;
 	tp->rcv_ssthresh = tp->rcv_wnd;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 6b6ae91..062c730 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -267,7 +267,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	req->window_clamp = tp->window_clamp ? :dst_metric(dst, RTAX_WINDOW);
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
 				  &req->rcv_wnd, &req->window_clamp,
-				  ireq->wscale_ok, &rcv_wscale);
+				  ireq->wscale_ok, &rcv_wscale, tp);
 
 	ireq->rcv_wscale = rcv_wscale;
 
@@ -278,4 +278,3 @@ out_free:
 	reqsk_free(req);
 	return NULL;
 }
-
