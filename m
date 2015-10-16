From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: do not set queue_mapping on SYNACK
Date: Fri, 16 Oct 2015 13:00:01 -0700
Message-ID: <1445025601.30896.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34401 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932325AbbJPUAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 16:00:03 -0400
Received: by pacez2 with SMTP id ez2so13146413pac.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 13:00:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

At the time of commit fff326990789 ("tcp: reflect SYN queue_mapping into
SYNACK packets") we had little ways to cope with SYN floods.

We no longer need to reflect incoming skb queue mappings, and instead
can pick a TX queue based on cpu cooking the SYNACK, with normal XPS
affinities.

Note that all SYNACK retransmits were picking TX queue 0, this no longer
is a win given that SYNACK rtx are now distributed on all cpus.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h     |    2 +-
 net/ipv4/ip_output.c  |    1 -
 net/ipv4/tcp_input.c  |    4 ++--
 net/ipv4/tcp_ipv4.c   |    2 --
 net/ipv4/tcp_output.c |    2 +-
 net/ipv6/tcp_ipv6.c   |    2 --
 6 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index a6be56d5f0e3..eed94fc355c1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1716,7 +1716,7 @@ struct tcp_request_sock_ops {
 	__u32 (*init_seq)(const struct sk_buff *skb);
 	int (*send_synack)(const struct sock *sk, struct dst_entry *dst,
 			   struct flowi *fl, struct request_sock *req,
-			   u16 queue_mapping, struct tcp_fastopen_cookie *foc,
+			   struct tcp_fastopen_cookie *foc,
 			   bool attach_req);
 };
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 67404e1fe7d4..50e29737b584 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1596,7 +1596,6 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 			  arg->csumoffset) = csum_fold(csum_add(nskb->csum,
 								arg->csum));
 		nskb->ip_summed = CHECKSUM_NONE;
-		skb_set_queue_mapping(nskb, skb_get_queue_mapping(skb));
 		ip_push_pending_frames(sk, &fl4);
 	}
 out:
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3b35c3f4d268..944eaca69115 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6236,7 +6236,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 	}
 	if (fastopen_sk) {
 		af_ops->send_synack(fastopen_sk, dst, &fl, req,
-				    skb_get_queue_mapping(skb), &foc, false);
+				    &foc, false);
 		/* Add the child socket directly into the accept queue */
 		inet_csk_reqsk_queue_add(sk, req, fastopen_sk);
 		sk->sk_data_ready(sk);
@@ -6247,7 +6247,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		if (!want_cookie)
 			inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
 		af_ops->send_synack(sk, dst, &fl, req,
-				    skb_get_queue_mapping(skb), &foc, !want_cookie);
+				    &foc, !want_cookie);
 		if (want_cookie)
 			goto drop_and_free;
 	}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9c68cf3762c4..30dd45c1f568 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -821,7 +821,6 @@ static void tcp_v4_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
 static int tcp_v4_send_synack(const struct sock *sk, struct dst_entry *dst,
 			      struct flowi *fl,
 			      struct request_sock *req,
-			      u16 queue_mapping,
 			      struct tcp_fastopen_cookie *foc,
 				  bool attach_req)
 {
@@ -839,7 +838,6 @@ static int tcp_v4_send_synack(const struct sock *sk, struct dst_entry *dst,
 	if (skb) {
 		__tcp_v4_send_check(skb, ireq->ir_loc_addr, ireq->ir_rmt_addr);
 
-		skb_set_queue_mapping(skb, queue_mapping);
 		err = ip_build_and_send_pkt(skb, sk, ireq->ir_loc_addr,
 					    ireq->ir_rmt_addr,
 					    ireq->opt);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 6e79fcb0addb..19adedb8c5cc 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3518,7 +3518,7 @@ int tcp_rtx_synack(const struct sock *sk, struct request_sock *req)
 	int res;
 
 	tcp_rsk(req)->txhash = net_tx_rndhash();
-	res = af_ops->send_synack(sk, NULL, &fl, req, 0, NULL, true);
+	res = af_ops->send_synack(sk, NULL, &fl, req, NULL, true);
 	if (!res) {
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index acb06f86f372..f495d189f5e0 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -437,7 +437,6 @@ out:
 static int tcp_v6_send_synack(const struct sock *sk, struct dst_entry *dst,
 			      struct flowi *fl,
 			      struct request_sock *req,
-			      u16 queue_mapping,
 			      struct tcp_fastopen_cookie *foc,
 			      bool attach_req)
 {
@@ -462,7 +461,6 @@ static int tcp_v6_send_synack(const struct sock *sk, struct dst_entry *dst,
 		if (np->repflow && ireq->pktopts)
 			fl6->flowlabel = ip6_flowlabel(ipv6_hdr(ireq->pktopts));
 
-		skb_set_queue_mapping(skb, queue_mapping);
 		err = ip6_xmit(sk, skb, fl6, np->opt, np->tclass);
 		err = net_xmit_eval(err);
 	}
