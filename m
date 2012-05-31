From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: avoid tx starvation by SYNACK packets
Date: Thu, 31 May 2012 23:56:37 +0200
Message-ID: <1338501397.2760.1395.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:52669 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886Ab2EaV4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 17:56:42 -0400
Received: by wibhm6 with SMTP id hm6so31345wib.1
        for <netdev@vger.kernel.org>; Thu, 31 May 2012 14:56:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

pfifo_fast being the default Qdisc, its pretty easy to fill it with
SYNACK (small) packets while host is under SYNFLOOD attack.

Packets of established TCP sessions are dropped and host appears almost
dead.

Avoid this problem assigning TC_PRIO_FILLER priority to SYNACK
generated in SYNCOOKIE mode, so that these packets are enqueued into
pfifo_fast band 2.

Other packets, queued to band 0 or 1 are dequeued before any SYNACK
packets waiting in band 2.

Reported-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
---
 net/dccp/ipv4.c                  |    3 +++
 net/ipv4/ip_output.c             |    2 +-
 net/ipv4/tcp_ipv4.c              |   13 +++++++++----
 net/ipv6/inet6_connection_sock.c |    1 +
 net/ipv6/ip6_output.c            |    2 +-
 net/ipv6/tcp_ipv6.c              |   10 +++++++---
 6 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 07f5579..d8a3d87 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -515,6 +515,8 @@ static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
 
 		dh->dccph_checksum = dccp_v4_csum_finish(skb, ireq->loc_addr,
 							      ireq->rmt_addr);
+		
+		skb->priority = sk->sk_priority;
 		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
 					    ireq->rmt_addr,
 					    ireq->opt);
@@ -556,6 +558,7 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	skb_dst_set(skb, dst_clone(dst));
 
 	bh_lock_sock(ctl_sk);
+	skb->priority = ctl_sk->sk_priority;
 	err = ip_build_and_send_pkt(skb, ctl_sk,
 				    rxiph->daddr, rxiph->saddr, NULL);
 	bh_unlock_sock(ctl_sk);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 451f97c..407e2fc 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -168,7 +168,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 		ip_options_build(skb, &opt->opt, daddr, rt, 0);
 	}
 
-	skb->priority = sk->sk_priority;
+	/* skb->priority is set by the caller */
 	skb->mark = sk->sk_mark;
 
 	/* Send it out. */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a43b87d..613e713 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -81,7 +81,7 @@
 #include <linux/stddef.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
-
+#include <linux/pkt_sched.h>
 #include <linux/crypto.h>
 #include <linux/scatterlist.h>
 
@@ -824,7 +824,8 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
  */
 static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 			      struct request_sock *req,
-			      struct request_values *rvp)
+			      struct request_values *rvp,
+			      bool syncookie)
 {
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct flowi4 fl4;
@@ -840,6 +841,9 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 	if (skb) {
 		__tcp_v4_send_check(skb, ireq->loc_addr, ireq->rmt_addr);
 
+		/* SYNACK sent in SYNCOOKIE mode have low priority */
+		skb->priority = syncookie ? TC_PRIO_FILLER : sk->sk_priority;
+
 		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
 					    ireq->rmt_addr,
 					    ireq->opt);
@@ -854,7 +858,7 @@ static int tcp_v4_rtx_synack(struct sock *sk, struct request_sock *req,
 			      struct request_values *rvp)
 {
 	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
-	return tcp_v4_send_synack(sk, NULL, req, rvp);
+	return tcp_v4_send_synack(sk, NULL, req, rvp, false);
 }
 
 /*
@@ -1422,7 +1426,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_rsk(req)->snt_synack = tcp_time_stamp;
 
 	if (tcp_v4_send_synack(sk, dst, req,
-			       (struct request_values *)&tmp_ext) ||
+			       (struct request_values *)&tmp_ext,
+			       want_cookie) ||
 	    want_cookie)
 		goto drop_and_free;
 
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index e6cee52..5812a74 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -248,6 +248,7 @@ int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl_unused)
 	/* Restore final destination back after routing done */
 	fl6.daddr = np->daddr;
 
+	skb->priority = sk->sk_priority;
 	res = ip6_xmit(sk, skb, &fl6, np->opt, np->tclass);
 	rcu_read_unlock();
 	return res;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 17b8c67..61c0ea8 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -241,7 +241,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	hdr->saddr = fl6->saddr;
 	hdr->daddr = *first_hop;
 
-	skb->priority = sk->sk_priority;
+	/* skb->priority is set by the caller */
 	skb->mark = sk->sk_mark;
 
 	mtu = dst_mtu(dst);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 554d599..b618413 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -43,6 +43,7 @@
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
 #include <linux/random.h>
+#include <linux/pkt_sched.h>
 
 #include <net/tcp.h>
 #include <net/ndisc.h>
@@ -476,7 +477,7 @@ out:
 
 
 static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
-			      struct request_values *rvp)
+			      struct request_values *rvp, bool syncookie)
 {
 	struct inet6_request_sock *treq = inet6_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -512,6 +513,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	if (skb) {
 		__tcp_v6_send_check(skb, &treq->loc_addr, &treq->rmt_addr);
 
+		skb->priority = syncookie ? TC_PRIO_FILLER : sk->sk_priority;
 		fl6.daddr = treq->rmt_addr;
 		err = ip6_xmit(sk, skb, &fl6, opt, np->tclass);
 		err = net_xmit_eval(err);
@@ -528,7 +530,7 @@ static int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req,
 			     struct request_values *rvp)
 {
 	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
-	return tcp_v6_send_synack(sk, req, rvp);
+	return tcp_v6_send_synack(sk, req, rvp, false);
 }
 
 static void tcp_v6_reqsk_destructor(struct request_sock *req)
@@ -906,6 +908,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	dst = ip6_dst_lookup_flow(ctl_sk, &fl6, NULL, false);
 	if (!IS_ERR(dst)) {
 		skb_dst_set(buff, dst);
+		skb->priority = ctl_sk->sk_priority;
 		ip6_xmit(ctl_sk, buff, &fl6, NULL, tclass);
 		TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
 		if (rst)
@@ -1213,7 +1216,8 @@ have_isn:
 	security_inet_conn_request(sk, skb, req);
 
 	if (tcp_v6_send_synack(sk, req,
-			       (struct request_values *)&tmp_ext) ||
+			       (struct request_values *)&tmp_ext,
+			       want_cookie) ||
 	    want_cookie)
 		goto drop_and_free;
 
