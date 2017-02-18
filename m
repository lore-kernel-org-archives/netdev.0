From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: [PATCH 1/2] tcp: setup random timestamp offset when write_seq already set
Date: Sat, 18 Feb 2017 03:56:11 +0300
Message-ID: <1487379372-28199-1-git-send-email-alexey.kodanev@oracle.com>
Cc: netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Alexey Kodanev <alexey.kodanev@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37050 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752141AbdBRAvF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 19:51:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found that when random offset enabled (default) TCP client can
still start new connections with and without random offsets. Later,
if server does active close and re-use sockets in TIME-WAIT state,
new SYN from client can be rejected on PAWS check inside
tcp_timewait_state_process().

Here is how to reproduce it with LTP netstress tool:
    netstress -R 1 &
    netstress -H 127.0.0.1 -lr 1000000 -a1

    [...]
    < S  seq 1956977072 win 43690 TS val 295618 ecr 459956970
    > .  ack 1956911535 win 342 TS val 459967184 ecr 1547117608
    < R  seq 1956911535 win 0 length 0
+1. < S  seq 1956977072 win 43690 TS val 296640 ecr 459956970
    > S. seq 657450664 ack 1956977073 win 43690 TS val 459968205 ecr 296640

Fixes: 95a22caee396 ("tcp: randomize tcp timestamp offsets for each connection")
Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
---
 net/ipv4/tcp_ipv4.c |    7 ++++++-
 net/ipv6/tcp_ipv6.c |    8 +++++++-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index fe9da4f..7269e9e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -232,12 +232,17 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	sk->sk_gso_type = SKB_GSO_TCPV4;
 	sk_setup_caps(sk, &rt->dst);
 
-	if (!tp->write_seq && likely(!tp->repair))
+	if (!tp->write_seq && likely(!tp->repair)) {
 		tp->write_seq = secure_tcp_sequence_number(inet->inet_saddr,
 							   inet->inet_daddr,
 							   inet->inet_sport,
 							   usin->sin_port,
 							   &tp->tsoffset);
+	} else if (likely(!tp->repair)) {
+		secure_tcp_sequence_number(inet->inet_saddr, inet->inet_daddr,
+					   inet->inet_sport, usin->sin_port,
+					   &tp->tsoffset);
+	}
 
 	inet->inet_id = tp->write_seq ^ jiffies;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4c60c6f..1eceeb9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -284,12 +284,18 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 	sk_set_txhash(sk);
 
-	if (!tp->write_seq && likely(!tp->repair))
+	if (!tp->write_seq && likely(!tp->repair)) {
 		tp->write_seq = secure_tcpv6_sequence_number(np->saddr.s6_addr32,
 							     sk->sk_v6_daddr.s6_addr32,
 							     inet->inet_sport,
 							     inet->inet_dport,
 							     &tp->tsoffset);
+	} else if (likely(!tp->repair)) {
+		secure_tcpv6_sequence_number(np->saddr.s6_addr32,
+					     sk->sk_v6_daddr.s6_addr32,
+					     inet->inet_sport, inet->inet_dport,
+					     &tp->tsoffset);
+	}
 
 	err = tcp_connect(sk);
 	if (err)
-- 
1.7.1
