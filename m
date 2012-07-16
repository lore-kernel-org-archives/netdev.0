From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Is TCP vulneribility patch (as in RFC 5961) done in linux?
Date: Mon, 16 Jul 2012 15:46:51 +0200
Message-ID: <1342446411.23494.76.camel@edumazet-glaptop>
References: <68700EDA775E5E47B5EBA9FF8AC0F15C076B03@SJEXCHMB09.corp.ad.broadcom.com>
	 <68700EDA775E5E47B5EBA9FF8AC0F15C077FF3@SJEXCHMB09.corp.ad.broadcom.com>
	 <1342427617.4812.0.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kiran (Kiran Kumar) Kella" <kkiran@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:56864 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284Ab2GPNq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 09:46:56 -0400
Received: by eekc13 with SMTP id c13so186699eek.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 06:46:55 -0700 (PDT)
In-Reply-To: <1342427617.4812.0.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-16 at 10:33 +0200, Eric Dumazet wrote:
> On Mon, 2012-07-16 at 07:06 +0000, Kiran (Kiran Kumar) Kella wrote:
> > Looking into the file tcp_input.c in the latest stable linux release 3.4.4 source, I understand the fix for this recommendation is not implemented in Linux.
> > Any reason why it was not addressed?
> 
> Nobody cared ?
> 
> Are you planning to send a patch ?
> 


Here is an RFC patch implementing RFC 5961 3.2

[PATCH net-next] tcp: implement RFC 5961 3.2

Implement the RFC 5691 mitigation against Blind
Reset attack using RST bit.

Add a new sysctl, tcp_challengeack_limit, to limit
number of challenge ACK sent per second.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Kiran Kumar Kella <kkiran@broadcom.com>
---
 Documentation/networking/ip-sysctl.txt |    5 +++
 include/linux/snmp.h                   |    1 
 include/net/tcp.h                      |    1 
 net/ipv4/proc.c                        |    1 
 net/ipv4/sysctl_net_ipv4.c             |    7 +++++
 net/ipv4/tcp_input.c                   |   31 ++++++++++++++++++++++-
 6 files changed, 45 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index e20c17a..f785fd1 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -565,6 +565,11 @@ tcp_limit_output_bytes - INTEGER
 	reduce the size of individual GSO packet (64KB being the max)
 	Default: 131072
 
+tcp_challengeack_limit - INTEGER
+	Limits number of Challenge ACK sent per second, as recommended
+	in RFC 5961 (Improving TCP's Robustness to Blind In-Window Attacks)
+	Default: 100
+
 UDP variables:
 
 udp_mem - vector of 3 INTEGERs: min, pressure, max
diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 2e68f5b..594638e 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -234,6 +234,7 @@ enum
 	LINUX_MIB_TCPREQQFULLDROP,		/* TCPReqQFullDrop */
 	LINUX_MIB_TCPRETRANSFAIL,		/* TCPRetransFail */
 	LINUX_MIB_TCPRCVCOALESCE,			/* TCPRcvCoalesce */
+	LINUX_MIB_TCPCHALLENGEACK,		/* TCPChallengeACK */
 	__LINUX_MIB_MAX
 };
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 439984b..fc14419 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -254,6 +254,7 @@ extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
 extern int sysctl_tcp_early_retrans;
 extern int sysctl_tcp_limit_output_bytes;
+extern int sysctl_tcp_challengeack_limit;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 8af0d44..d589468 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -258,6 +258,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPReqQFullDrop", LINUX_MIB_TCPREQQFULLDROP),
 	SNMP_MIB_ITEM("TCPRetransFail", LINUX_MIB_TCPRETRANSFAIL),
 	SNMP_MIB_ITEM("TCPRcvCoalesce", LINUX_MIB_TCPRCVCOALESCE),
+	SNMP_MIB_ITEM("TCPChallengeACK", LINUX_MIB_TCPCHALLENGEACK),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 70730f7..12df8e8 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -605,6 +605,13 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_challengeack_limit",
+		.data		= &sysctl_tcp_challengeack_limit,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 #ifdef CONFIG_NET_DMA
 	{
 		.procname	= "tcp_dma_copybreak",
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 055ac49..8e7edff 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -88,6 +88,9 @@ int sysctl_tcp_app_win __read_mostly = 31;
 int sysctl_tcp_adv_win_scale __read_mostly = 1;
 EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
 
+/* rfc5961 challenge ack rate limiting */
+int sysctl_tcp_challengeack_limit = 100;
+
 int sysctl_tcp_stdurg __read_mostly;
 int sysctl_tcp_rfc1337 __read_mostly;
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
@@ -5244,6 +5247,23 @@ out:
 }
 #endif /* CONFIG_NET_DMA */
 
+static void tcp_send_challenge_ack(struct sock *sk)
+{
+	/* unprotected vars, we dont care of overwrites */
+	static u32 challenge_time;
+	static unsigned int challenge_count;
+	u32 now = tcp_time_stamp / HZ;
+
+	if (now != challenge_time) {
+		challenge_time = now;
+		challenge_count = 0;
+	}
+	if (++challenge_count <= sysctl_tcp_challengeack_limit) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPCHALLENGEACK);
+		tcp_send_ack(sk);
+	}
+}
+
 /* Does PAWS and seqno based validation of an incoming segment, flags will
  * play significant role here.
  */
@@ -5280,7 +5300,16 @@ static int tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 
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
 
