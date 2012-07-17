From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: implement RFC 5961 4.2
Date: Tue, 17 Jul 2012 13:41:30 +0200
Message-ID: <1342525290.2626.459.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Kiran Kumar Kella <kkiran@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41620 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415Ab2GQLlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 07:41:35 -0400
Received: by eaak11 with SMTP id k11so117422eaa.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 04:41:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Implement the RFC 5691 mitigation against Blind
Reset attack using SYN bit.

Section 4.2 of RFC 5961 advises to send a Challenge ACK and drop
incoming packet, instead of resetting the session.

Add a new SNMP counter to count number of challenge acks sent
in response to SYN packets.
(netstat -s | grep TCPSYNChallenge)

Remove obsolete TCPAbortOnSyn, since we no longer abort a TCP session
because of a SYN flag.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Kiran Kumar Kella <kkiran@broadcom.com>
---
 include/linux/snmp.h |    2 +-
 net/ipv4/proc.c      |    2 +-
 net/ipv4/tcp_input.c |   32 +++++++++++++++-----------------
 3 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 673e0e9..e5fcbd0 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -208,7 +208,6 @@ enum
 	LINUX_MIB_TCPDSACKOFOSENT,		/* TCPDSACKOfoSent */
 	LINUX_MIB_TCPDSACKRECV,			/* TCPDSACKRecv */
 	LINUX_MIB_TCPDSACKOFORECV,		/* TCPDSACKOfoRecv */
-	LINUX_MIB_TCPABORTONSYN,		/* TCPAbortOnSyn */
 	LINUX_MIB_TCPABORTONDATA,		/* TCPAbortOnData */
 	LINUX_MIB_TCPABORTONCLOSE,		/* TCPAbortOnClose */
 	LINUX_MIB_TCPABORTONMEMORY,		/* TCPAbortOnMemory */
@@ -238,6 +237,7 @@ enum
 	LINUX_MIB_TCPOFODROP,			/* TCPOFODrop */
 	LINUX_MIB_TCPOFOMERGE,			/* TCPOFOMerge */
 	LINUX_MIB_TCPCHALLENGEACK,		/* TCPChallengeACK */
+	LINUX_MIB_TCPSYNCHALLENGE,		/* TCPSYNChallenge */
 	__LINUX_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 3e8e78f..2a5240b 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -232,7 +232,6 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPDSACKOfoSent", LINUX_MIB_TCPDSACKOFOSENT),
 	SNMP_MIB_ITEM("TCPDSACKRecv", LINUX_MIB_TCPDSACKRECV),
 	SNMP_MIB_ITEM("TCPDSACKOfoRecv", LINUX_MIB_TCPDSACKOFORECV),
-	SNMP_MIB_ITEM("TCPAbortOnSyn", LINUX_MIB_TCPABORTONSYN),
 	SNMP_MIB_ITEM("TCPAbortOnData", LINUX_MIB_TCPABORTONDATA),
 	SNMP_MIB_ITEM("TCPAbortOnClose", LINUX_MIB_TCPABORTONCLOSE),
 	SNMP_MIB_ITEM("TCPAbortOnMemory", LINUX_MIB_TCPABORTONMEMORY),
@@ -262,6 +261,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPOFODrop", LINUX_MIB_TCPOFODROP),
 	SNMP_MIB_ITEM("TCPOFOMerge", LINUX_MIB_TCPOFOMERGE),
 	SNMP_MIB_ITEM("TCPChallengeACK", LINUX_MIB_TCPCHALLENGEACK),
+	SNMP_MIB_ITEM("TCPSYNChallenge", LINUX_MIB_TCPSYNCHALLENGE),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c841a89..8aaec55 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5270,8 +5270,8 @@ static void tcp_send_challenge_ack(struct sock *sk)
 /* Does PAWS and seqno based validation of an incoming segment, flags will
  * play significant role here.
  */
-static int tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
-			      const struct tcphdr *th, int syn_inerr)
+static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
+				  const struct tcphdr *th, int syn_inerr)
 {
 	const u8 *hash_location;
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -5323,20 +5323,22 @@ static int tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 
 	/* step 3: check security and precedence [ignored] */
 
-	/* step 4: Check for a SYN in window. */
-	if (th->syn && !before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt)) {
+	/* step 4: Check for a SYN
+	 * RFC 5691 4.2 : Send a challenge ack
+	 */
+	if (th->syn) {
 		if (syn_inerr)
 			TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPABORTONSYN);
-		tcp_reset(sk);
-		return -1;
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNCHALLENGE);
+		tcp_send_challenge_ack(sk);
+		goto discard;
 	}
 
-	return 1;
+	return true;
 
 discard:
 	__kfree_skb(skb);
-	return 0;
+	return false;
 }
 
 /*
@@ -5366,7 +5368,6 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			const struct tcphdr *th, unsigned int len)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	int res;
 
 	if (sk->sk_rx_dst) {
 		struct dst_entry *dst = sk->sk_rx_dst;
@@ -5555,9 +5556,8 @@ slow_path:
 	 *	Standard slow path.
 	 */
 
-	res = tcp_validate_incoming(sk, skb, th, 1);
-	if (res <= 0)
-		return -res;
+	if (!tcp_validate_incoming(sk, skb, th, 1))
+		return 0;
 
 step5:
 	if (th->ack && tcp_ack(sk, skb, FLAG_SLOWPATH) < 0)
@@ -5877,7 +5877,6 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int queued = 0;
-	int res;
 
 	tp->rx_opt.saw_tstamp = 0;
 
@@ -5932,9 +5931,8 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		return 0;
 	}
 
-	res = tcp_validate_incoming(sk, skb, th, 0);
-	if (res <= 0)
-		return -res;
+	if (!tcp_validate_incoming(sk, skb, th, 0))
+		return 0;
 
 	/* step 5: check the ACK field */
 	if (th->ack) {
