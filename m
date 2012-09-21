From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH] tcp: sysctl for initial receive window
Date: Fri, 21 Sep 2012 10:55:02 +0200
Message-ID: <20120921085502.4534.20232.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4285 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757016Ab2IUIsC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2012 04:48:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it possible to adjust the TCP default initial advertised receive
window, via sysctl /proc/sys/net/ipv4/tcp_init_recv_window.

The window size is this value multiplied by the MSS of the connection.
The default value is (still) 10, as descibed in commit 356f039822b
(TCP: increase default initial receive window.)

Allow minimum value of 1, but recommend against setting value below 2
in the documentation.

Its possible to control/override this value per route table entry via
the iproute2 option initrwnd.  Having the global default exported via
sysctl, helps determine the default setting, and make is easier to
adjust.

Cc: Nandita Dukkipati <nanditad@google.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 Documentation/networking/ip-sysctl.txt |   12 ++++++++++++
 include/net/tcp.h                      |    1 +
 net/ipv4/sysctl_net_ipv4.c             |    9 +++++++++
 net/ipv4/tcp_input.c                   |    6 +++---
 net/ipv4/tcp_output.c                  |    8 +++++---
 5 files changed, 30 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index c7fc107..684131c 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -257,6 +257,18 @@ tcp_frto_response - INTEGER
 		  to the values prior timeout
 	Default: 0 (rate halving based)
 
+tcp_init_recv_window - INTEGER
+	Default initial advertised receive window.  Actual window size
+	is this value multiplied by the MSS of the connection.  Its
+	possible to control/override this value per route table entry
+	via the iproute2 option initrwnd.
+	Minimum value is 1, but 2 is the recommended minimum.
+	The effective max value, is limited by the sockets receive
+	buffer size (default tcp_rmem[1], and possibly scaled by
+	tcp_adv_win_scale), and can further be limited by window
+	clamp.
+	Default: 10
+
 tcp_keepalive_time - INTEGER
 	How often TCP sends out keepalive messages when keepalive is enabled.
 	Default: 2hours.
diff --git a/include/net/tcp.h b/include/net/tcp.h
index a8cb00c..3334852 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -292,6 +292,7 @@ extern int sysctl_tcp_thin_dupack;
 extern int sysctl_tcp_early_retrans;
 extern int sysctl_tcp_limit_output_bytes;
 extern int sysctl_tcp_challenge_ack_limit;
+extern u32 sysctl_tcp_init_recv_window;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 9205e49..9bb6608 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -27,6 +27,7 @@
 #include <net/tcp_memcontrol.h>
 
 static int zero;
+static int one = 1;
 static int two = 2;
 static int tcp_retr1_max = 255;
 static int ip_local_port_range_min[] = { 1, 1 };
@@ -794,6 +795,14 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &zero
 	},
+	{
+		.procname	= "tcp_init_recv_window",
+		.data		= &sysctl_tcp_init_recv_window,
+		.maxlen		= sizeof(sysctl_tcp_init_recv_window),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e2bec81..bbf7a33 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -356,14 +356,14 @@ static void tcp_grow_window(struct sock *sk, const struct sk_buff *skb)
 static void tcp_fixup_rcvbuf(struct sock *sk)
 {
 	u32 mss = tcp_sk(sk)->advmss;
-	u32 icwnd = TCP_DEFAULT_INIT_RCVWND;
+	u32 icwnd = sysctl_tcp_init_recv_window;
 	int rcvmem;
 
-	/* Limit to 10 segments if mss <= 1460,
+	/* Limit to default 10 segments if mss <= 1460,
 	 * or 14600/mss segments, with a minimum of two segments.
 	 */
 	if (mss > 1460)
-		icwnd = max_t(u32, (1460 * TCP_DEFAULT_INIT_RCVWND) / mss, 2);
+		icwnd = max_t(u32, (1460 * icwnd) / mss, 2);
 
 	rcvmem = SKB_TRUESIZE(mss + MAX_TCP_HEADER);
 	while (tcp_win_from_space(rcvmem) < mss)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cfe6ffe..5f3b26d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -59,6 +59,8 @@ int sysctl_tcp_limit_output_bytes __read_mostly = 131072;
  */
 int sysctl_tcp_tso_win_divisor __read_mostly = 3;
 
+u32 sysctl_tcp_init_recv_window __read_mostly = TCP_DEFAULT_INIT_RCVWND;
+
 int sysctl_tcp_mtu_probing __read_mostly = 0;
 int sysctl_tcp_base_mss __read_mostly = TCP_BASE_MSS;
 
@@ -235,14 +237,14 @@ void tcp_select_initial_window(int __space, __u32 mss,
 	}
 
 	/* Set initial window to a value enough for senders starting with
-	 * initial congestion window of TCP_DEFAULT_INIT_RCVWND. Place
+	 * initial congestion window of sysctl_tcp_init_recv_window. Place
 	 * a limit on the initial window when mss is larger than 1460.
 	 */
 	if (mss > (1 << *rcv_wscale)) {
-		int init_cwnd = TCP_DEFAULT_INIT_RCVWND;
+		int init_cwnd = sysctl_tcp_init_recv_window;
 		if (mss > 1460)
 			init_cwnd =
-			max_t(u32, (1460 * TCP_DEFAULT_INIT_RCVWND) / mss, 2);
+			max_t(u32, (1460 * init_cwnd) / mss, 2);
 		/* when initializing use the value from init_rcv_wnd
 		 * rather than the default from above
 		 */
