From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] BIC tcp congestion calculation timestamp
Date: Thu, 29 Jul 2004 11:29:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040729112934.32002c24@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Small change to bictcp based on the BIC 1.1 patches for web100.
Keep track of last time congestion was computed, and recompute
if cwnd changes or every 1/32 of a second.

Also changes the initialization location for the parameters.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -urN -X dontdiff linux-2.6/include/linux/tcp.h tcp-2.6/include/linux/tcp.h
--- linux-2.6/include/linux/tcp.h	2004-06-23 09:29:47.000000000 -0700
+++ tcp-2.6/include/linux/tcp.h	2004-07-27 10:26:52.000000000 -0700
@@ -420,6 +420,7 @@
 		__u32	cnt;		/* increase cwnd by 1 after this number of ACKs */
 		__u32 	last_max_cwnd;	/* last maximium snd_cwnd */
 		__u32	last_cwnd;	/* the last snd_cwnd */
+		__u32   last_stamp;     /* time when updated last_cwnd */
 	} bictcp;
 };
 
diff -urN -X dontdiff linux-2.6/net/ipv4/tcp_input.c tcp-2.6/net/ipv4/tcp_input.c
--- linux-2.6/net/ipv4/tcp_input.c	2004-07-23 09:36:18.000000000 -0700
+++ tcp-2.6/net/ipv4/tcp_input.c	2004-07-28 13:52:50.000000000 -0700
@@ -330,6 +330,15 @@
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
+static void init_bictcp(struct tcp_opt *tp)
+{
+	tp->bictcp.cnt = 0;
+
+	tp->bictcp.last_max_cwnd = 0;
+	tp->bictcp.last_cwnd = 0;
+	tp->bictcp.last_stamp = 0;
+}
+
 /* 5. Recalculate window clamp after socket hit its memory bounds. */
 static void tcp_clamp_window(struct sock *sk, struct tcp_opt *tp)
 {
@@ -1233,6 +1242,8 @@
 	tcp_set_ca_state(tp, TCP_CA_Loss);
 	tp->high_seq = tp->frto_highmark;
 	TCP_ECN_queue_cwr(tp);
+
+	init_bictcp(tp);
 }
 
 void tcp_clear_retrans(struct tcp_opt *tp)
@@ -2011,10 +2022,12 @@
 	if (!sysctl_tcp_bic)
 		return tp->snd_cwnd;
 
-	if (tp->bictcp.last_cwnd == tp->snd_cwnd)
-		return tp->bictcp.cnt; /*  same cwnd, no update */
-      
+	if (tp->bictcp.last_cwnd == tp->snd_cwnd &&
+	   (s32)(tcp_time_stamp - tp->bictcp.last_stamp) <= (HZ>>5))
+		return tp->bictcp.cnt;
+
 	tp->bictcp.last_cwnd = tp->snd_cwnd;
+	tp->bictcp.last_stamp = tcp_time_stamp;
       
 	/* start off normal */
 	if (tp->snd_cwnd <= sysctl_tcp_bic_low_window)
@@ -4612,6 +4625,7 @@
 				return 1;
 
 			init_westwood(sk);
+			init_bictcp(tp);
 
 			/* Now we have several options: In theory there is 
 			 * nothing else in the frame. KA9Q has an option to 
@@ -4635,6 +4649,7 @@
 
 	case TCP_SYN_SENT:
 		init_westwood(sk);
+		init_bictcp(tp);
 
 		queued = tcp_rcv_synsent_state_process(sk, skb, th, len);
 		if (queued >= 0)
diff -urN -X dontdiff linux-2.6/net/ipv4/tcp_minisocks.c tcp-2.6/net/ipv4/tcp_minisocks.c
--- linux-2.6/net/ipv4/tcp_minisocks.c	2004-07-23 09:36:18.000000000 -0700
+++ tcp-2.6/net/ipv4/tcp_minisocks.c	2004-07-23 09:48:07.000000000 -0700
@@ -767,9 +767,6 @@
 		newtp->snd_cwnd = 2;
 		newtp->snd_cwnd_cnt = 0;
 
-		newtp->bictcp.cnt = 0;
-		newtp->bictcp.last_max_cwnd = newtp->bictcp.last_cwnd = 0;
-
 		newtp->frto_counter = 0;
 		newtp->frto_highmark = 0;
 
