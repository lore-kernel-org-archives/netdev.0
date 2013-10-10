From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] inet: rename ir_loc_port to ir_num
Date: Thu, 10 Oct 2013 00:04:37 -0700
Message-ID: <1381388677.4971.65.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:64123 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752861Ab3JJHEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 03:04:39 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so2152014pde.38
        for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 00:04:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit 634fb979e8f ("inet: includes a sock_common in request_sock")
I forgot that the two ports in sock_common do not have same byte order :

skc_dport is __be16 (network order), but skc_num is __u16 (host order)

So sparse complains because ir_loc_port (mapped into skc_num) is
considered as __u16 while it should be __be16

Let rename ir_loc_port to ireq->ir_num (analogy with inet->inet_num),
and perform appropriate htons/ntohs conversions.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/net/inet_sock.h          |    2 +-
 include/net/tcp.h                |    2 +-
 net/dccp/ipv6.c                  |    4 ++--
 net/dccp/minisocks.c             |    8 ++++----
 net/dccp/output.c                |    2 +-
 net/ipv4/inet_connection_sock.c  |    4 ++--
 net/ipv4/syncookies.c            |    8 ++++----
 net/ipv4/tcp_output.c            |    2 +-
 net/ipv6/inet6_connection_sock.c |    2 +-
 net/ipv6/syncookies.c            |    2 +-
 net/ipv6/tcp_ipv6.c              |    2 +-
 11 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index f912044..06da91e 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -72,7 +72,7 @@ struct inet_request_sock {
 	struct request_sock	req;
 #define ir_loc_addr		req.__req_common.skc_rcv_saddr
 #define ir_rmt_addr		req.__req_common.skc_daddr
-#define ir_loc_port		req.__req_common.skc_num
+#define ir_num			req.__req_common.skc_num
 #define ir_rmt_port		req.__req_common.skc_dport
 #define ir_v6_rmt_addr		req.__req_common.skc_v6_daddr
 #define ir_v6_loc_addr		req.__req_common.skc_v6_rcv_saddr
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 24a0616..1db3a01 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1110,7 +1110,7 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->acked = 0;
 	ireq->ecn_ok = 0;
 	ireq->ir_rmt_port = tcp_hdr(skb)->source;
-	ireq->ir_loc_port = tcp_hdr(skb)->dest;
+	ireq->ir_num = ntohs(tcp_hdr(skb)->dest);
 }
 
 void tcp_enter_memory_pressure(struct sock *sk);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 5cc5b24..4ac71ff 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -231,7 +231,7 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req)
 	fl6.flowlabel = 0;
 	fl6.flowi6_oif = ireq->ir_iif;
 	fl6.fl6_dport = ireq->ir_rmt_port;
-	fl6.fl6_sport = ireq->ir_loc_port;
+	fl6.fl6_sport = htons(ireq->ir_num);
 	security_req_classify_flow(req, flowi6_to_flowi(&fl6));
 
 
@@ -509,7 +509,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 		fl6.saddr = ireq->ir_v6_loc_addr;
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
 		fl6.fl6_dport = ireq->ir_rmt_port;
-		fl6.fl6_sport = ireq->ir_loc_port;
+		fl6.fl6_sport = htons(ireq->ir_num);
 		security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
 		dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 66afbce..9e2f78b 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -266,10 +266,10 @@ int dccp_reqsk_init(struct request_sock *req,
 {
 	struct dccp_request_sock *dreq = dccp_rsk(req);
 
-	inet_rsk(req)->ir_rmt_port	  = dccp_hdr(skb)->dccph_sport;
-	inet_rsk(req)->ir_loc_port	  = dccp_hdr(skb)->dccph_dport;
-	inet_rsk(req)->acked	  = 0;
-	dreq->dreq_timestamp_echo = 0;
+	inet_rsk(req)->ir_rmt_port = dccp_hdr(skb)->dccph_sport;
+	inet_rsk(req)->ir_num	   = ntohs(dccp_hdr(skb)->dccph_dport);
+	inet_rsk(req)->acked	   = 0;
+	dreq->dreq_timestamp_echo  = 0;
 
 	/* inherit feature negotiation options from listening socket */
 	return dccp_feat_clone_list(&dp->dccps_featneg, &dreq->dreq_featneg);
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 9bf195d..8876078 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -424,7 +424,7 @@ struct sk_buff *dccp_make_response(struct sock *sk, struct dst_entry *dst,
 	/* Build and checksum header */
 	dh = dccp_zeroed_hdr(skb, dccp_header_size);
 
-	dh->dccph_sport	= inet_rsk(req)->ir_loc_port;
+	dh->dccph_sport	= htons(inet_rsk(req)->ir_num);
 	dh->dccph_dport	= inet_rsk(req)->ir_rmt_port;
 	dh->dccph_doff	= (dccp_header_size +
 			   DCCP_SKB_CB(skb)->dccpd_opt_len) / 4;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 2ffd931..fc0e649 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -676,8 +676,8 @@ struct sock *inet_csk_clone_lock(const struct sock *sk,
 		newicsk->icsk_bind_hash = NULL;
 
 		inet_sk(newsk)->inet_dport = inet_rsk(req)->ir_rmt_port;
-		inet_sk(newsk)->inet_num = ntohs(inet_rsk(req)->ir_loc_port);
-		inet_sk(newsk)->inet_sport = inet_rsk(req)->ir_loc_port;
+		inet_sk(newsk)->inet_num = inet_rsk(req)->ir_num;
+		inet_sk(newsk)->inet_sport = htons(inet_rsk(req)->ir_num);
 		newsk->sk_write_space = sk_stream_write_space;
 
 		newicsk->icsk_retransmits = 0;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 984e21c..3b64c59 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -304,10 +304,10 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	treq->rcv_isn		= ntohl(th->seq) - 1;
 	treq->snt_isn		= cookie;
 	req->mss		= mss;
-	ireq->ir_loc_port		= th->dest;
-	ireq->ir_rmt_port		= th->source;
-	ireq->ir_loc_addr		= ip_hdr(skb)->daddr;
-	ireq->ir_rmt_addr		= ip_hdr(skb)->saddr;
+	ireq->ir_num		= ntohs(th->dest);
+	ireq->ir_rmt_port	= th->source;
+	ireq->ir_loc_addr	= ip_hdr(skb)->daddr;
+	ireq->ir_rmt_addr	= ip_hdr(skb)->saddr;
 	ireq->ecn_ok		= ecn_ok;
 	ireq->snd_wscale	= tcp_opt.snd_wscale;
 	ireq->sack_ok		= tcp_opt.sack_ok;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index faec813..2822ad0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2734,7 +2734,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	th->syn = 1;
 	th->ack = 1;
 	TCP_ECN_make_synack(req, th);
-	th->source = ireq->ir_loc_port;
+	th->source = htons(ireq->ir_num);
 	th->dest = ireq->ir_rmt_port;
 	/* Setting of flags are superfluous here for callers (and ECE is
 	 * not even correctly set)
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 1317c56..77bb8af 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -83,7 +83,7 @@ struct dst_entry *inet6_csk_route_req(struct sock *sk,
 	fl6->flowi6_oif = ireq->ir_iif;
 	fl6->flowi6_mark = sk->sk_mark;
 	fl6->fl6_dport = ireq->ir_rmt_port;
-	fl6->fl6_sport = ireq->ir_loc_port;
+	fl6->fl6_sport = htons(ireq->ir_num);
 	security_req_classify_flow(req, flowi6_to_flowi(fl6));
 
 	dst = ip6_dst_lookup_flow(sk, fl6, final_p, false);
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index bc5698f9..d04d3f1 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -194,7 +194,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	req->mss = mss;
 	ireq->ir_rmt_port = th->source;
-	ireq->ir_loc_port = th->dest;
+	ireq->ir_num = ntohs(th->dest);
 	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
 	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
 	if (ipv6_opt_accepted(sk, skb) ||
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index db234d6..b996ee2 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1735,7 +1735,7 @@ static void get_openreq6(struct seq_file *seq,
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3],
-		   ntohs(inet_rsk(req)->ir_loc_port),
+		   inet_rsk(req)->ir_num,
 		   dest->s6_addr32[0], dest->s6_addr32[1],
 		   dest->s6_addr32[2], dest->s6_addr32[3],
 		   ntohs(inet_rsk(req)->ir_rmt_port),
