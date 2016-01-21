From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix NULL deref in tcp_v4_send_ack()
Date: Thu, 21 Jan 2016 08:02:54 -0800
Message-ID: <1453392174.1223.363.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Jerry Chu <hkchu@google.com>, Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33051 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965482AbcAUQC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 11:02:57 -0500
Received: by mail-pa0-f53.google.com with SMTP id cy9so25307512pac.0
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2016 08:02:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Neal reported crashes with this stack trace :

 RIP: 0010:[<ffffffff8c57231b>] tcp_v4_send_ack+0x41/0x20f
...
 CR2: 0000000000000018 CR3: 000000044005c000 CR4: 00000000001427e0
...
  [<ffffffff8c57258e>] tcp_v4_reqsk_send_ack+0xa5/0xb4
  [<ffffffff8c1a7caa>] tcp_check_req+0x2ea/0x3e0
  [<ffffffff8c19e420>] tcp_rcv_state_process+0x850/0x2500
  [<ffffffff8c1a6d21>] tcp_v4_do_rcv+0x141/0x330
  [<ffffffff8c56cdb2>] sk_backlog_rcv+0x21/0x30
  [<ffffffff8c098bbd>] tcp_recvmsg+0x75d/0xf90
  [<ffffffff8c0a8700>] inet_recvmsg+0x80/0xa0
  [<ffffffff8c17623e>] sock_aio_read+0xee/0x110
  [<ffffffff8c066fcf>] do_sync_read+0x6f/0xa0
  [<ffffffff8c0673a1>] SyS_read+0x1e1/0x290
  [<ffffffff8c5ca262>] system_call_fastpath+0x16/0x1b

The problem here is the skb we provide to tcp_v4_send_ack() had to
be parked in the backlog of a new TCP fastopen child because this child
was owned by the user at the time an out of window packet arrived.

Before queuing a packet, TCP has to set skb->dev to NULL as the device
could disappear before packet is removed from the queue.

Fix this issue by using the net pointer provided by the socket (being a
timewait or a request socket).

IPv6 is immune to the bug : tcp_v6_send_response() already gets the net
pointer from the socket if provided.

Fixes: 168a8f58059a ("tcp: TCP Fast Open Server - main code path")
Reported-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jerry Chu <hkchu@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_ipv4.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c7d1fb50f381..2a67244f97ca 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -708,7 +708,8 @@ release_sk1:
    outside socket context is ugly, certainly. What can I do?
  */
 
-static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
+static void tcp_v4_send_ack(struct net *net,
+			    struct sk_buff *skb, u32 seq, u32 ack,
 			    u32 win, u32 tsval, u32 tsecr, int oif,
 			    struct tcp_md5sig_key *key,
 			    int reply_flags, u8 tos)
@@ -723,7 +724,6 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 			];
 	} rep;
 	struct ip_reply_arg arg;
-	struct net *net = dev_net(skb_dst(skb)->dev);
 
 	memset(&rep.th, 0, sizeof(struct tcphdr));
 	memset(&arg, 0, sizeof(arg));
@@ -785,7 +785,8 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 	struct inet_timewait_sock *tw = inet_twsk(sk);
 	struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
 
-	tcp_v4_send_ack(skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
+	tcp_v4_send_ack(sock_net(sk), skb,
+			tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
 			tcp_time_stamp + tcptw->tw_ts_offset,
 			tcptw->tw_ts_recent,
@@ -804,8 +805,10 @@ static void tcp_v4_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
 	/* sk->sk_state == TCP_LISTEN -> for regular TCP_SYN_RECV
 	 * sk->sk_state == TCP_SYN_RECV -> for Fast Open.
 	 */
-	tcp_v4_send_ack(skb, (sk->sk_state == TCP_LISTEN) ?
-			tcp_rsk(req)->snt_isn + 1 : tcp_sk(sk)->snd_nxt,
+	u32 seq = (sk->sk_state == TCP_LISTEN) ? tcp_rsk(req)->snt_isn + 1 :
+					     tcp_sk(sk)->snd_nxt;
+
+	tcp_v4_send_ack(sock_net(sk), skb, seq,
 			tcp_rsk(req)->rcv_nxt, req->rsk_rcv_wnd,
 			tcp_time_stamp,
 			req->ts_recent,
