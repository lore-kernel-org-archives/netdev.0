From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fix TCP_SYNCNT flakes
Date: Tue, 23 May 2017 12:38:35 -0700
Message-ID: <1495568315.6465.71.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33898 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965180AbdEWTis (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 15:38:48 -0400
Received: by mail-pf0-f193.google.com with SMTP id w69so29585811pfk.1
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 12:38:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After the mentioned commit, some of our packetdrill tests became flaky.

TCP_SYNCNT socket option can limit the number of SYN retransmits.

retransmits_timed_out() has to compare times computations based on
local_clock() while timers are based on jiffies. With NTP adjustments
and roundings we can observe 999 ms delay for 1000 ms timers.
We end up sending one extra SYN packet.

Gimmick added in commit 6fa12c850314 ("Revert Backoff [v3]: Calculate
TCP's connection close threshold as a time value") makes no
real sense for TCP_SYN_SENT sockets where no RTO backoff can happen at
all.

Lets use a simpler logic for TCP_SYN_SENT sockets and remove @syn_set
parameter from retransmits_timed_out()

Fixes: 9a568de4818d ("tcp: switch TCP TS option (RFC 7323) to 1ms clock")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_timer.c |   26 +++++++++++---------------
 1 file changed, 11 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index c4a35ba7f8ed0dac573c864900b081b4847927d8..c0feeeef962aa31401ee90f8bd015c2aae2ef932 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -139,21 +139,17 @@ static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
  *  @timeout:  A custom timeout value.
  *             If set to 0 the default timeout is calculated and used.
  *             Using TCP_RTO_MIN and the number of unsuccessful retransmits.
- *  @syn_set:  true if the SYN Bit was set.
  *
  * The default "timeout" value this function can calculate and use
  * is equivalent to the timeout of a TCP Connection
  * after "boundary" unsuccessful, exponentially backed-off
- * retransmissions with an initial RTO of TCP_RTO_MIN or TCP_TIMEOUT_INIT if
- * syn_set flag is set.
- *
+ * retransmissions with an initial RTO of TCP_RTO_MIN.
  */
 static bool retransmits_timed_out(struct sock *sk,
 				  unsigned int boundary,
-				  unsigned int timeout,
-				  bool syn_set)
+				  unsigned int timeout)
 {
-	unsigned int rto_base = syn_set ? TCP_TIMEOUT_INIT : TCP_RTO_MIN;
+	const unsigned int rto_base = TCP_RTO_MIN;
 	unsigned int linear_backoff_thresh, start_ts;
 
 	if (!inet_csk(sk)->icsk_retransmits)
@@ -181,8 +177,8 @@ static int tcp_write_timeout(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct net *net = sock_net(sk);
+	bool expired, do_reset;
 	int retry_until;
-	bool do_reset, syn_set = false;
 
 	if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
 		if (icsk->icsk_retransmits) {
@@ -196,9 +192,9 @@ static int tcp_write_timeout(struct sock *sk)
 			sk_rethink_txhash(sk);
 		}
 		retry_until = icsk->icsk_syn_retries ? : net->ipv4.sysctl_tcp_syn_retries;
-		syn_set = true;
+		expired = icsk->icsk_retransmits >= retry_until;
 	} else {
-		if (retransmits_timed_out(sk, net->ipv4.sysctl_tcp_retries1, 0, 0)) {
+		if (retransmits_timed_out(sk, net->ipv4.sysctl_tcp_retries1, 0)) {
 			/* Some middle-boxes may black-hole Fast Open _after_
 			 * the handshake. Therefore we conservatively disable
 			 * Fast Open on this path on recurring timeouts after
@@ -224,15 +220,15 @@ static int tcp_write_timeout(struct sock *sk)
 
 			retry_until = tcp_orphan_retries(sk, alive);
 			do_reset = alive ||
-				!retransmits_timed_out(sk, retry_until, 0, 0);
+				!retransmits_timed_out(sk, retry_until, 0);
 
 			if (tcp_out_of_resources(sk, do_reset))
 				return 1;
 		}
+		expired = retransmits_timed_out(sk, retry_until,
+						icsk->icsk_user_timeout);
 	}
-
-	if (retransmits_timed_out(sk, retry_until,
-				  syn_set ? 0 : icsk->icsk_user_timeout, syn_set)) {
+	if (expired) {
 		/* Has it gone just too far? */
 		tcp_write_err(sk);
 		return 1;
@@ -540,7 +536,7 @@ void tcp_retransmit_timer(struct sock *sk)
 		icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
 	}
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
-	if (retransmits_timed_out(sk, net->ipv4.sysctl_tcp_retries1 + 1, 0, 0))
+	if (retransmits_timed_out(sk, net->ipv4.sysctl_tcp_retries1 + 1, 0))
 		__sk_dst_reset(sk);
 
 out:;
