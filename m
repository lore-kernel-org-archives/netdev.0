From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] unclamp tcp receive window if doing dynamic receive sizing
Date: Mon, 7 Jun 2004 13:30:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607133056.5ab9e72d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When running tests over higher speed links, the new 2.6 Dynamic Receiver Sizing
code doesn't increase the window large enough.  The problem is that the window
clamp restricts the allowed window to the socket receive buffer size (85k)

Easiest fix is to not restrict window clamp if we want to dynamic receiver stuff.
This is what web100 did.

Thanks to John Heffner for finding this.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2004-06-07 12:45:49 -07:00
+++ b/net/ipv4/tcp_input.c	2004-06-07 12:45:49 -07:00
@@ -300,7 +300,6 @@
 static void tcp_init_buffer_space(struct sock *sk)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
-	int maxwin;
 
 	if (!(sk->sk_userlocks & SOCK_RCVBUF_LOCK))
 		tcp_fixup_rcvbuf(sk);
@@ -309,22 +308,24 @@
 
 	tp->rcvq_space.space = tp->rcv_wnd;
 
-	maxwin = tcp_full_space(sk);
+	if (!sysctl_tcp_moderate_rcvbuf) {
+		int maxwin = tcp_full_space(sk);
 
-	if (tp->window_clamp >= maxwin) {
-		tp->window_clamp = maxwin;
+		if (tp->window_clamp >= maxwin) {
+			tp->window_clamp = maxwin;
 
-		if (sysctl_tcp_app_win && maxwin > 4 * tp->advmss)
-			tp->window_clamp = max(maxwin -
-					       (maxwin >> sysctl_tcp_app_win),
-					       4 * tp->advmss);
+			if (sysctl_tcp_app_win && maxwin > 4 * tp->advmss)
+				tp->window_clamp = max(maxwin -
+						       (maxwin >> sysctl_tcp_app_win),
+						       4 * tp->advmss);
+		}
+
+		/* Force reservation of one segment. */
+		if (sysctl_tcp_app_win &&
+		    tp->window_clamp > 2 * tp->advmss &&
+		    tp->window_clamp + tp->advmss > maxwin)
+			tp->window_clamp = max(2 * tp->advmss, maxwin - tp->advmss);
 	}
-
-	/* Force reservation of one segment. */
-	if (sysctl_tcp_app_win &&
-	    tp->window_clamp > 2 * tp->advmss &&
-	    tp->window_clamp + tp->advmss > maxwin)
-		tp->window_clamp = max(2 * tp->advmss, maxwin - tp->advmss);
 
 	tp->rcv_ssthresh = min(tp->rcv_ssthresh, tp->window_clamp);
 	tp->snd_cwnd_stamp = tcp_time_stamp;
