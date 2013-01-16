From: Cong Wang <amwang@redhat.com>
Subject: [RFC Patch net-next] tcp: add a global sysctl to control TCP delayed ack
Date: Wed, 16 Jan 2013 19:05:45 +0800
Message-ID: <1358334345-28980-1-git-send-email-amwang@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	David Laight <David.Laight@ACULAB.COM>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106Ab3APLGK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 06:06:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to previous discussion, it seems there is no
reasonable heuristics.

Similar to TCP_QUICK_ACK option, but for people who can't
modify the source code and still wants to control
TCP delayed ACK behavior.

Makes any sense?

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Rick Jones <rick.jones2@hp.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
CC: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 4976564..8fc96f2 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -605,6 +605,11 @@ tcp_challenge_ack_limit - INTEGER
 	in RFC 5961 (Improving TCP's Robustness to Blind In-Window Attacks)
 	Default: 100
 
+tcp_quick_ack - BOOLEAN
+	Globally enables or disables TCP delayed ACK. The applications
+	can still change the quick ACK mode by TCP_QUICK_ACK option.
+	Default: off
+
 UDP variables:
 
 udp_mem - vector of 3 INTEGERs: min, pressure, max
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 614af8b..0ba0c26 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -291,6 +291,7 @@ extern int sysctl_tcp_thin_dupack;
 extern int sysctl_tcp_early_retrans;
 extern int sysctl_tcp_limit_output_bytes;
 extern int sysctl_tcp_challenge_ack_limit;
+extern int sysctl_tcp_quick_ack;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index a25e1d2..9b4bb75 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -767,6 +767,13 @@ static struct ctl_table ipv4_table[] = {
 		.extra2		= &two,
 	},
 	{
+		.procname	= "tcp_quick_ack",
+		.data		= &sysctl_tcp_quick_ack,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "udp_mem",
 		.data		= &sysctl_udp_mem,
 		.maxlen		= sizeof(sysctl_udp_mem),
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0905997..3f68482 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -100,6 +100,7 @@ int sysctl_tcp_thin_dupack __read_mostly;
 int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
 int sysctl_tcp_abc __read_mostly;
 int sysctl_tcp_early_retrans __read_mostly = 2;
+int sysctl_tcp_quick_ack __read_mostly;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
@@ -4081,7 +4082,8 @@ static void tcp_fin(struct sock *sk)
 	case TCP_ESTABLISHED:
 		/* Move to CLOSE_WAIT */
 		tcp_set_state(sk, TCP_CLOSE_WAIT);
-		inet_csk(sk)->icsk_ack.pingpong = 1;
+		if (!sysctl_tcp_quick_ack)
+			inet_csk(sk)->icsk_ack.pingpong = 1;
 		break;
 
 	case TCP_CLOSE_WAIT:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 667a6ad..44eff34 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -174,8 +174,9 @@ static void tcp_event_data_sent(struct tcp_sock *tp,
 	/* If it is a reply for ato after last received
 	 * packet, enter pingpong mode.
 	 */
-	if ((u32)(now - icsk->icsk_ack.lrcvtime) < icsk->icsk_ack.ato)
-		icsk->icsk_ack.pingpong = 1;
+	if ((u32)(now - icsk->icsk_ack.lrcvtime) < icsk->icsk_ack.ato &&
+	    !sysctl_tcp_quick_ack)
+			icsk->icsk_ack.pingpong = 1;
 }
 
 /* Account for an ACK we sent. */
