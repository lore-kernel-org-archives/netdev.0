From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: initialize icsk_ack.lrcvtime at session start time
Date: Wed, 22 Mar 2017 08:10:21 -0700
Message-ID: <1490195421.16816.157.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34952 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758814AbdCVPLB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 11:11:01 -0400
Received: by mail-pf0-f194.google.com with SMTP id n11so15896002pfg.2
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 08:10:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

icsk_ack.lrcvtime has a 0 value at socket creation time.

tcpi_last_data_recv can have bogus value if no payload is ever received.

This patch initializes icsk_ack.lrcvtime for active sessions
in tcp_finish_connect(), and for passive sessions in
tcp_create_openreq_child()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c     |    2 +-
 net/ipv4/tcp_minisocks.c |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 39c393cc0fd3c17130cd5d8d8b37f31ad3aeafd9..c43119726a62e494063fd940001b483215d0fe26 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5541,6 +5541,7 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
 	tcp_set_state(sk, TCP_ESTABLISHED);
+	icsk->icsk_ack.lrcvtime = tcp_time_stamp;
 
 	if (skb) {
 		icsk->icsk_af_ops->sk_rx_dst_set(sk, skb);
@@ -5759,7 +5760,6 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 			 * to stand against the temptation 8)     --ANK
 			 */
 			inet_csk_schedule_ack(sk);
-			icsk->icsk_ack.lrcvtime = tcp_time_stamp;
 			tcp_enter_quickack_mode(sk);
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
 						  TCP_DELACK_MAX, TCP_RTO_MAX);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 7e16243cdb58c830f869fe483730e86400e2eb00..65c0f3d13eca47c6394c09925decf54287d01b48 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -460,6 +460,7 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 		newtp->mdev_us = jiffies_to_usecs(TCP_TIMEOUT_INIT);
 		minmax_reset(&newtp->rtt_min, tcp_time_stamp, ~0U);
 		newicsk->icsk_rto = TCP_TIMEOUT_INIT;
+		newicsk->icsk_ack.lrcvtime = tcp_time_stamp;
 
 		newtp->packets_out = 0;
 		newtp->retrans_out = 0;
