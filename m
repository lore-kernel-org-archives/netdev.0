From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [net-next PATCH 06/16] Handle TCP SYN+ACK/ACK/RST transparency
Date: Wed, 01 Oct 2008 16:24:31 +0200
Message-ID: <20081001142431.4893.64737.stgit@este>
References: <20081001142431.4893.48078.stgit@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:53158 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753110AbYJAPZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 11:25:33 -0400
In-reply-to: <20081001142431.4893.48078.stgit@este>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TCP stack sends out SYN+ACK/ACK/RST reply packets in response to
incoming packets. The non-local source address check on output bites
us again, as replies for transparently redirected traffic won't have a
chance to leave the node.

This patch selectively sets the FLOWI_FLAG_ANYSRC flag when doing
the route lookup for those replies. Transparent replies are enabled if
the listening socket has the transparent socket flag set.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 include/net/inet_sock.h |    8 +++++++-
 net/ipv4/tcp_ipv4.c     |   12 +++++++++---
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 139b78b..dced3f6 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -72,7 +72,8 @@ struct inet_request_sock {
 				sack_ok	   : 1,
 				wscale_ok  : 1,
 				ecn_ok	   : 1,
-				acked	   : 1;
+				acked	   : 1,
+				no_srccheck: 1;
 	struct ip_options	*opt;
 };
 
@@ -204,4 +205,9 @@ static inline struct request_sock *inet_reqsk_alloc(struct request_sock_ops *ops
 	return req;
 }
 
+static inline __u8 inet_sk_flowi_flags(const struct sock *sk)
+{
+	return inet_sk(sk)->transparent ? FLOWI_FLAG_ANYSRC : 0;
+}
+
 #endif	/* _INET_SOCK_H */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 44aef1c..1ac4d05 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -591,6 +591,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 				      ip_hdr(skb)->saddr, /* XXX */
 				      sizeof(struct tcphdr), IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
+	arg.flags = (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRCCHECK : 0;
 
 	net = dev_net(skb->dst->dev);
 	ip_send_reply(net->ipv4.tcp_sock, skb,
@@ -606,7 +607,8 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 
 static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 			    u32 win, u32 ts, int oif,
-			    struct tcp_md5sig_key *key)
+			    struct tcp_md5sig_key *key,
+			    int reply_flags)
 {
 	struct tcphdr *th = tcp_hdr(skb);
 	struct {
@@ -659,6 +661,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 				    ip_hdr(skb)->daddr, &rep.th);
 	}
 #endif
+	arg.flags = reply_flags;
 	arg.csum = csum_tcpudp_nofold(ip_hdr(skb)->daddr,
 				      ip_hdr(skb)->saddr, /* XXX */
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
@@ -681,7 +684,8 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
 			tcptw->tw_ts_recent,
 			tw->tw_bound_dev_if,
-			tcp_twsk_md5_key(tcptw)
+			tcp_twsk_md5_key(tcptw),
+			tw->tw_transparent ? IP_REPLY_ARG_NOSRCCHECK : 0
 			);
 
 	inet_twsk_put(tw);
@@ -694,7 +698,8 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 			tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd,
 			req->ts_recent,
 			0,
-			tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->daddr));
+			tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->daddr),
+			inet_rsk(req)->no_srccheck ? IP_REPLY_ARG_NOSRCCHECK : 0);
 }
 
 /*
@@ -1244,6 +1249,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	ireq->loc_addr = daddr;
 	ireq->rmt_addr = saddr;
+	ireq->no_srccheck = inet_sk(sk)->transparent;
 	ireq->opt = tcp_v4_save_options(sk, skb);
 	if (!want_cookie)
 		TCP_ECN_create_request(req, tcp_hdr(skb));


