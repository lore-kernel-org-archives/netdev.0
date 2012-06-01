From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: reflect SYN queue_mapping into SYNACK packets
Date: Fri, 01 Jun 2012 12:01:21 +0200
Message-ID: <1338544881.2760.1502.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Tom Herbert <therbert@google.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34246 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932579Ab2FAKB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 06:01:26 -0400
Received: by bkcji2 with SMTP id ji2so1674340bkc.19
        for <netdev@vger.kernel.org>; Fri, 01 Jun 2012 03:01:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While testing how linux behaves on SYNFLOOD attack on multiqueue device
(ixgbe), I found that SYNACK messages were dropped at Qdisc level
because we send them all on a single queue.

Obvious choice is to reflect incoming SYN packet @queue_mapping to
SYNACK packet.

Under stress, my machine could only send 25.000 SYNACK per second (for
200.000 incoming SYN per second). NIC : ixgbe with 16 rx/tx queues.

After patch, not a single SYNACK is dropped.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
---
 net/ipv4/tcp_ipv4.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a43b87d..c8d28c4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -824,7 +824,8 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
  */
 static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 			      struct request_sock *req,
-			      struct request_values *rvp)
+			      struct request_values *rvp,
+			      u16 queue_mapping)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct flowi4 fl4;
@@ -840,6 +841,7 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 	if (skb) {
 		__tcp_v4_send_check(skb, ireq->loc_addr, ireq->rmt_addr);
 
+		skb_set_queue_mapping(skb, queue_mapping);
 		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
 					    ireq->rmt_addr,
 					    ireq->opt);
@@ -854,7 +856,7 @@ static int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req,
 			      struct request_values *rvp)
 {
 	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
-	return tcp_v4_send_synack(sk, NULL, req, rvp);
+	return tcp_v4_send_synack(sk, NULL, req, rvp, 0);
 }
 
 /*
@@ -1422,7 +1424,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_rsk(req)->snt_synack = tcp_time_stamp;
 
 	if (tcp_v4_send_synack(sk, dst, req,
-			       (struct request_values *)&tmp_ext) ||
+			       (struct request_values *)&tmp_ext,
+			       skb_get_queue_mapping(skb)) ||
 	    want_cookie)
 		goto drop_and_free;
 
