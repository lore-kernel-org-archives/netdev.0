From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] automatically compute tcp_default_win_scale
Date: Thu, 26 Aug 2004 13:07:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040826130702.2d421680@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, John Heffner <jheffner@psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch gets rid of the tcp_default_win_scale sysctl and instead
computes the optimum maximum window scale.  It just means one less
thing to have to tune.  I also moved the code out of the inline because
it gets called three places and isn't in the critical path.

As a side effect, it will cause a smaller window scale for many people
since the default tcp_rmem fits in a win_scale of 2.  This is allows for
finer grain windows (good), but may mask some of the problems with bad
implementations we have already seen (bad).

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2004-08-26 13:03:22 -07:00
+++ b/include/net/tcp.h	2004-08-26 13:03:22 -07:00
@@ -611,7 +611,6 @@
 extern int sysctl_tcp_bic;
 extern int sysctl_tcp_bic_fast_convergence;
 extern int sysctl_tcp_bic_low_window;
-extern int sysctl_tcp_default_win_scale;
 extern int sysctl_tcp_moderate_rcvbuf;
 
 extern atomic_t tcp_memory_allocated;
@@ -1690,68 +1689,10 @@
 		*ptr++ = htonl((TCPOPT_NOP << 24) | (TCPOPT_WINDOW << 16) | (TCPOLEN_WINDOW << 8) | (wscale));
 }
 
-/* Determine a window scaling and initial window to offer.
- * Based on the assumption that the given amount of space
- * will be offered. Store the results in the tp structure.
- * NOTE: for smooth operation initial space offering should
- * be a multiple of mss if possible. We assume here that mss >= 1.
- * This MUST be enforced by all callers.
- */
-static inline void tcp_select_initial_window(int __space, __u32 mss,
-	__u32 *rcv_wnd,
-	__u32 *window_clamp,
-	int wscale_ok,
-	__u8 *rcv_wscale)
-{
-	unsigned int space = (__space < 0 ? 0 : __space);
-
-	/* If no clamp set the clamp to the max possible scaled window */
-	if (*window_clamp == 0)
-		(*window_clamp) = (65535 << 14);
-	space = min(*window_clamp, space);
-
-	/* Quantize space offering to a multiple of mss if possible. */
-	if (space > mss)
-		space = (space / mss) * mss;
-
-	/* NOTE: offering an initial window larger than 32767
-	 * will break some buggy TCP stacks. We try to be nice.
-	 * If we are not window scaling, then this truncates
-	 * our initial window offering to 32k. There should also
-	 * be a sysctl option to stop being nice.
-	 */
-	(*rcv_wnd) = min(space, MAX_TCP_WINDOW);
-	(*rcv_wscale) = 0;
-	if (wscale_ok) {
-		/* See RFC1323 for an explanation of the limit to 14 */
-		while (space > 65535 && (*rcv_wscale) < 14) {
-			space >>= 1;
-			(*rcv_wscale)++;
-		}
-		if (*rcv_wscale && sysctl_tcp_app_win && space>=mss &&
-		    space - max((space>>sysctl_tcp_app_win), mss>>*rcv_wscale) < 65536/2)
-			(*rcv_wscale)--;
-
-		*rcv_wscale = max((__u8)sysctl_tcp_default_win_scale,
-				  *rcv_wscale);
-	}
-
-	/* Set initial window to value enough for senders,
-	 * following RFC1414. Senders, not following this RFC,
-	 * will be satisfied with 2.
-	 */
-	if (mss > (1<<*rcv_wscale)) {
-		int init_cwnd = 4;
-		if (mss > 1460*3)
-			init_cwnd = 2;
-		else if (mss > 1460)
-			init_cwnd = 3;
-		if (*rcv_wnd > init_cwnd*mss)
-			*rcv_wnd = init_cwnd*mss;
-	}
-	/* Set the clamp no higher than max representable value */
-	(*window_clamp) = min(65535U << (*rcv_wscale), *window_clamp);
-}
+/* Determine a window scaling and initial window to offer. */
+extern void tcp_select_initial_window(int __space, __u32 mss,
+				      __u32 *rcv_wnd, __u32 *window_clamp,
+				      int wscale_ok, __u8 *rcv_wscale);
 
 static inline int tcp_win_from_space(int space)
 {
@@ -1761,13 +1702,13 @@
 }
 
 /* Note: caller must be prepared to deal with negative returns */ 
-static inline int tcp_space(struct sock *sk)
+static inline int tcp_space(const struct sock *sk)
 {
 	return tcp_win_from_space(sk->sk_rcvbuf -
 				  atomic_read(&sk->sk_rmem_alloc));
 } 
 
-static inline int tcp_full_space( struct sock *sk)
+static inline int tcp_full_space(const struct sock *sk)
 {
 	return tcp_win_from_space(sk->sk_rcvbuf); 
 }
diff -Nru a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
--- a/net/ipv4/sysctl_net_ipv4.c	2004-08-26 13:03:22 -07:00
+++ b/net/ipv4/sysctl_net_ipv4.c	2004-08-26 13:03:22 -07:00
@@ -667,14 +667,6 @@
 		.proc_handler	= &proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_TCP_DEFAULT_WIN_SCALE,
-		.procname	= "tcp_default_win_scale",
-		.data		= &sysctl_tcp_default_win_scale,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-	},
-	{
 		.ctl_name	= NET_TCP_MODERATE_RCVBUF,
 		.procname	= "tcp_moderate_rcvbuf",
 		.data		= &sysctl_tcp_moderate_rcvbuf,
diff -Nru a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	2004-08-26 13:03:22 -07:00
+++ b/net/ipv4/tcp.c	2004-08-26 13:03:22 -07:00
@@ -276,8 +276,6 @@
 
 atomic_t tcp_orphan_count = ATOMIC_INIT(0);
 
-int sysctl_tcp_default_win_scale = 7;
-
 int sysctl_tcp_mem[3];
 int sysctl_tcp_wmem[3] = { 4 * 1024, 16 * 1024, 128 * 1024 };
 int sysctl_tcp_rmem[3] = { 4 * 1024, 87380, 87380 * 2 };
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-08-26 13:03:22 -07:00
+++ b/net/ipv4/tcp_output.c	2004-08-26 13:03:22 -07:00
@@ -143,6 +143,65 @@
 	tcp_clear_xmit_timer(sk, TCP_TIME_DACK);
 }
 
+/* Determine a window scaling and initial window to offer.
+ * Based on the assumption that the given amount of space
+ * will be offered. Store the results in the tp structure.
+ * NOTE: for smooth operation initial space offering should
+ * be a multiple of mss if possible. We assume here that mss >= 1.
+ * This MUST be enforced by all callers.
+ */
+void tcp_select_initial_window(int __space, __u32 mss,
+			       __u32 *rcv_wnd, __u32 *window_clamp,
+			       int wscale_ok, __u8 *rcv_wscale)
+{
+	unsigned int space = (__space < 0 ? 0 : __space);
+
+	/* If no clamp set the clamp to the max possible scaled window */
+	if (*window_clamp == 0)
+		(*window_clamp) = (65535 << 14);
+	space = min(*window_clamp, space);
+
+	/* Quantize space offering to a multiple of mss if possible. */
+	if (space > mss)
+		space = (space / mss) * mss;
+
+	/* NOTE: offering an initial window larger than 32767
+	 * will break some buggy TCP stacks. We try to be nice.
+	 * If we are not window scaling, then this truncates
+	 * our initial window offering to 32k. There should also
+	 * be a sysctl option to stop being nice.
+	 */
+	(*rcv_wnd) = min(space, MAX_TCP_WINDOW);
+	(*rcv_wscale) = 0;
+	if (wscale_ok) {
+		/* Set window scaling on max possible window
+		 * See RFC1323 for an explanation of the limit to 14 
+		 */
+		space = max_t(u32, sysctl_tcp_rmem[2], sysctl_rmem_max);
+		while (space > 65535 && (*rcv_wscale) < 14) {
+			space >>= 1;
+			(*rcv_wscale)++;
+		}
+	}
+
+	/* Set initial window to value enough for senders,
+	 * following RFC1414. Senders, not following this RFC,
+	 * will be satisfied with 2.
+	 */
+	if (mss > (1<<*rcv_wscale)) {
+		int init_cwnd = 4;
+		if (mss > 1460*3)
+			init_cwnd = 2;
+		else if (mss > 1460)
+			init_cwnd = 3;
+		if (*rcv_wnd > init_cwnd*mss)
+			*rcv_wnd = init_cwnd*mss;
+	}
+
+	/* Set the clamp no higher than max representable value */
+	(*window_clamp) = min(65535U << (*rcv_wscale), *window_clamp);
+}
+
 /* Chose a new window to advertise, update state in tcp_opt for the
  * socket, and return result with RFC1323 scaling applied.  The return
  * value can be stuffed directly into th->window for an outgoing
