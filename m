From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next v2] tcp: implement RFC 5961 3.2
Date: Tue, 17 Jul 2012 10:13:05 +0200
Message-ID: <1342512785.2626.230.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Kiran Kumar Kella <kkiran@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40874 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626Ab2GQINK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 04:13:10 -0400
Received: by eaak11 with SMTP id k11so42910eaa.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 01:13:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Implement the RFC 5691 mitigation against Blind
Reset attack using RST bit.

Idea is to validate incoming RST sequence,
to match RCV.NXT value, instead of previouly accepted
window : (RCV.NXT <= SEG.SEQ < RCV.NXT+RCV.WND)

If sequence is in window but not an exact match, send
a "challenge ACK", so that the other part can resend an
RST with the appropriate sequence.

Add a new sysctl, tcp_challenge_ack_limit, to limit
number of challenge ACK sent per second.

Add a new SNMP counter to count number of challenge acks sent.
(netstat -s | grep TCPChallengeACK)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Kiran Kumar Kella <kkiran@broadcom.com>
---
v2: respin to net-next, better changelog
    tcp_challengeack_limit -> tcp_challenge_ack_limit
    tcp_time_stamp -> jiffies

 Documentation/networking/ip-sysctl.txt |    5 +++
 include/linux/snmp.h                   |    1 
 include/net/tcp.h                      |    1 
 net/ipv4/proc.c                        |    1 
 net/ipv4/sysctl_net_ipv4.c             |    7 +++++
 net/ipv4/tcp_input.c                   |   31 ++++++++++++++++++++++-
 6 files changed, 45 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index e20c17a..e1e0215 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -565,6 +565,11 @@ tcp_limit_output_bytes - INTEGER
 	reduce the size of individual GSO packet (64KB being the max)
 	Default: 131072
 
+tcp_challenge_ack_limit - INTEGER
+	Limits number of Challenge ACK sent per second, as recommended
+	in RFC 5961 (Improving TCP's Robustness to Blind In-Window Attacks)
+	Default: 100
+
 UDP variables:
 
 udp_mem - vector of 3 INTEGERs: min, pressure, max
diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 6e4c511..673e0e9 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -237,6 +237,7 @@ enum
 	LINUX_MIB_TCPOFOQUEUE,			/* TCPOFOQueue */
 	LINUX_MIB_TCPOFODROP,			/* TCPOFODrop */
 	LINUX_MIB_TCPOFOMERGE,			/* TCPOFOMerge */
+	LINUX_MIB_TCPCHALLENGEACK,		/* TCPChallengeACK */
 	__LINUX_MIB_MAX
 };
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 439984b..85c5090 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -254,6 +254,7 @@ extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
 extern int sysctl_tcp_early_retrans;
 extern int sysctl_tcp_limit_output_bytes;
+extern int sysctl_tcp_challenge_ack_limit;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index dae25e76..3e8e78f 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -261,6 +261,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPOFOQueue", LINUX_MIB_TCPOFOQUEUE),
 	SNMP_MIB_ITEM("TCPOFODrop", LINUX_MIB_TCPOFODROP),
 	SNMP_MIB_ITEM("TCPOFOMerge", LINUX_MIB_TCPOFOMERGE),
+	SNMP_MIB_ITEM("TCPChallengeACK", LINUX_MIB_TCPCHALLENGEACK),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 70730f7..3f6a1e7 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -605,6 +605,13 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_challenge_ack_limit",
+		.data		= &sysctl_tcp_challenge_ack_limit,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 #ifdef CONFIG_NET_DMA
 	{
 		.procname	= "tcp_dma_copybreak",
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cc4e12f..c841a89 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -88,6 +88,9 @@ int sysctl_tcp_app_win __read_mostly = 31;
 int sysctl_tcp_adv_win_scale __read_mostly = 1;
 EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
 
+/* rfc5961 challenge ack rate limiting */
+int sysctl_tcp_challenge_ack_limit = 100;
+
 int sysctl_tcp_stdurg __read_mostly;
 int sysctl_tcp_rfc1337 __read_mostly;
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
@@ -5247,6 +5250,23 @@ out:
 }
 #endif /* CONFIG_NET_DMA */
 
+static void tcp_send_challenge_ack(struct sock *sk)
+{
+	/* unprotected vars, we dont care of overwrites */
+	static u32 challenge_timestamp;
+	static unsigned int challenge_count;
+	u32 now = jiffies / HZ;
+
+	if (now != challenge_timestamp) {
+		challenge_timestamp = now;
+		challenge_count = 0;
+	}
+	if (++challenge_count <= sysctl_tcp_challenge_ack_limit) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPCHALLENGEACK);
+		tcp_send_ack(sk);
+	}
+}
+
 /* Does PAWS and seqno based validation of an incoming segment, flags will
  * play significant role here.
  */
@@ -5283,7 +5303,16 @@ static int tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 
 	/* Step 2: check RST bit */
 	if (th->rst) {
-		tcp_reset(sk);
+		/* RFC 5961 3.2 :
+		 * If sequence number exactly matches RCV.NXT, then
+		 *     RESET the connection
+		 * else
+		 *     Send a challenge ACK
+		 */
+		if (TCP_SKB_CB(skb)->seq == tp->rcv_nxt)
+			tcp_reset(sk);
+		else
+			tcp_send_challenge_ack(sk);
 		goto discard;
 	}
 
