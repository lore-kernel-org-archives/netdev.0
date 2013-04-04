From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] tcp: add a global sysctl to control TCP delayed ack
Date: Thu,  4 Apr 2013 18:16:00 +0800
Message-ID: <1365070560-11544-1-git-send-email-amwang@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	David Laight <David.Laight@ACULAB.COM>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27375 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758599Ab3DDKQj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 06:16:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Change from RFC:
* make the sysctl per netns

According to previous discussion, it seems there is no
reasonable heuristics.

Similar to TCP_QUICK_ACK option, but for people who can't
modify the source code and still wants to control
TCP delayed ACK behavior.

David, do you still have any objection?

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Rick Jones <rick.jones2@hp.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
CC: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f98ca63..9b39681 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -572,6 +572,11 @@ tcp_challenge_ack_limit - INTEGER
 	in RFC 5961 (Improving TCP's Robustness to Blind In-Window Attacks)
 	Default: 100
 
+tcp_quick_ack - BOOLEAN
+	Globally enables or disables TCP delayed ACK. The applications
+	can still change the quick ACK mode by TCP_QUICK_ACK option.
+	Default: off
+
 UDP variables:
 
 udp_mem - vector of 3 INTEGERs: min, pressure, max
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 2ba9de8..f03298a 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -63,6 +63,7 @@ struct netns_ipv4 {
 	int sysctl_icmp_errors_use_inbound_ifaddr;
 
 	int sysctl_tcp_ecn;
+	int sysctl_tcp_quick_ack;
 
 	kgid_t sysctl_ping_group_range[2];
 	long sysctl_tcp_mem[3];
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index fa2f63f..1db1780 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -837,6 +837,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= ipv4_tcp_mem,
 	},
+	{
+		.procname	= "tcp_quick_ack",
+		.data		= &init_net.ipv4.sysctl_tcp_quick_ack,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
@@ -866,6 +873,8 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 			&net->ipv4.sysctl_ping_group_range;
 		table[7].data =
 			&net->ipv4.sysctl_tcp_ecn;
+		table[9].data =
+			&net->ipv4.sysctl_tcp_quick_ack;
 
 		/* Don't export sysctls to unprivileged users */
 		if (net->user_ns != &init_user_ns)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6d9ca35..a1b44f3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3781,7 +3781,8 @@ static void tcp_fin(struct sock *sk)
 	case TCP_ESTABLISHED:
 		/* Move to CLOSE_WAIT */
 		tcp_set_state(sk, TCP_CLOSE_WAIT);
-		inet_csk(sk)->icsk_ack.pingpong = 1;
+		if (!sock_net(sk)->ipv4.sysctl_tcp_quick_ack)
+			inet_csk(sk)->icsk_ack.pingpong = 1;
 		break;
 
 	case TCP_CLOSE_WAIT:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index af354c98..130fc99 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -169,8 +169,9 @@ static void tcp_event_data_sent(struct tcp_sock *tp,
 	/* If it is a reply for ato after last received
 	 * packet, enter pingpong mode.
 	 */
-	if ((u32)(now - icsk->icsk_ack.lrcvtime) < icsk->icsk_ack.ato)
-		icsk->icsk_ack.pingpong = 1;
+	if ((u32)(now - icsk->icsk_ack.lrcvtime) < icsk->icsk_ack.ato &&
+	    !sock_net(sk)->ipv4.sysctl_tcp_quick_ack)
+			icsk->icsk_ack.pingpong = 1;
 }
 
 /* Account for an ACK we sent. */
