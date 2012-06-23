From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Sat, 23 Jun 2012 10:42:42 +0200
Message-ID: <1340440962.17495.39.camel@edumazet-glaptop>
References: <1338501397.2760.1395.camel@edumazet-glaptop>
	 <CAA93jw755V9kJ=P1gFsG2oafddhsebzfT3DuY5NX59GPpheOZg@mail.gmail.com>
	 <1338615992.2760.1665.camel@edumazet-glaptop>
	 <CAGK4HS8Hae_4sNQeGXGc4ocK1-2DVtCUdBAPj7+DY_iF6-2zOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Taht <dave.taht@gmail.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57517 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab2FWImu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2012 04:42:50 -0400
Received: by bkcji2 with SMTP id ji2so2141229bkc.19
        for <netdev@vger.kernel.org>; Sat, 23 Jun 2012 01:42:48 -0700 (PDT)
In-Reply-To: <CAGK4HS8Hae_4sNQeGXGc4ocK1-2DVtCUdBAPj7+DY_iF6-2zOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Sat, 2012-06-23 at 00:34 -0700, Vijay Subramanian wrote:

> This  patch ([PATCH net-next] tcp: avoid tx starvation by SYNACK
> packets)  is neither in net/net-next trees nor on patchwork. Maybe it
> was missed since it was sent during the merge window. Is this not
> needed anymore or is it being tested currently?

You're right, thanks for the reminder !

[PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets

pfifo_fast being the default Qdisc, its pretty easy to fill it with
SYNACK (small) packets while host is under synflood attack.

Packets of established TCP sessions are dropped at Qdisc layer and
host appears almost dead.

Avoid this problem assigning TC_PRIO_FILLER priority to SYNACK
generated in SYNCOOKIE mode, so that these packets are enqueued into
pfifo_fast lowest priority (band 2).

Other packets, queued to band 0 or 1 are dequeued before any SYNACK
packets waiting in band 2.

If not under synflood, SYNACK priority is as requested by listener
sk_priority policy.

Reported-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 net/dccp/ipv4.c                  |    2 ++
 net/ipv4/ip_output.c             |    2 +-
 net/ipv4/tcp_ipv4.c              |    7 ++++++-
 net/ipv6/inet6_connection_sock.c |    1 +
 net/ipv6/ip6_output.c            |    2 +-
 net/ipv6/tcp_ipv6.c              |   11 ++++++++---
 6 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 3eb76b5..045176f 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -515,6 +515,7 @@ static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
 
 		dh->dccph_checksum = dccp_v4_csum_finish(skb, ireq->loc_addr,
 							      ireq->rmt_addr);
+		skb->priority = sk->sk_priority;
 		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
 					    ireq->rmt_addr,
 					    ireq->opt);
@@ -556,6 +557,7 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	skb_dst_set(skb, dst_clone(dst));
 
 	bh_lock_sock(ctl_sk);
+	skb->priority = ctl_sk->sk_priority;
 	err = ip_build_and_send_pkt(skb, ctl_sk,
 				    rxiph->daddr, rxiph->saddr, NULL);
 	bh_unlock_sock(ctl_sk);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 0f3185a..71c6c20 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -155,7 +155,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 		ip_options_build(skb, &opt->opt, daddr, rt, 0);
 	}
 
-	skb->priority = sk->sk_priority;
+	/* skb->priority is set by the caller */
 	skb->mark = sk->sk_mark;
 
 	/* Send it out. */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b52934f..5ef4131 100644
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
 
@@ -821,6 +821,7 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
  *	Send a SYN-ACK after having received a SYN.
  *	This still operates on a request_sock only, not on a big
  *	socket.
+ *	nocache is set for SYN-ACK sent in SYNCOOKIE mode
  */
 static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 			      struct request_sock *req,
@@ -843,6 +844,10 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 		__tcp_v4_send_check(skb, ireq->loc_addr, ireq->rmt_addr);
 
 		skb_set_queue_mapping(skb, queue_mapping);
+
+		/* SYNACK sent in SYNCOOKIE mode have low priority */
+		skb->priority = nocache ? TC_PRIO_FILLER : sk->sk_priority;
+
 		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
 					    ireq->rmt_addr,
 					    ireq->opt);
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
index a233a7c..a93378a 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -228,7 +228,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	hdr->saddr = fl6->saddr;
 	hdr->daddr = *first_hop;
 
-	skb->priority = sk->sk_priority;
+	/* skb->priority is set by the caller */
 	skb->mark = sk->sk_mark;
 
 	mtu = dst_mtu(dst);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 26a8862..f664452 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -43,6 +43,7 @@
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
 #include <linux/random.h>
+#include <linux/pkt_sched.h>
 
 #include <net/tcp.h>
 #include <net/ndisc.h>
@@ -479,7 +480,8 @@ out:
 
 static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 			      struct request_values *rvp,
-			      u16 queue_mapping)
+			      u16 queue_mapping,
+			      bool syncookie)
 {
 	struct inet6_request_sock *treq = inet6_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -515,6 +517,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 	if (skb) {
 		__tcp_v6_send_check(skb, &treq->loc_addr, &treq->rmt_addr);
 
+		skb->priority = syncookie ? TC_PRIO_FILLER : sk->sk_priority;
 		fl6.daddr = treq->rmt_addr;
 		skb_set_queue_mapping(skb, queue_mapping);
 		err = ip6_xmit(sk, skb, &fl6, opt, np->tclass);
@@ -531,7 +534,7 @@ static int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req,
 			     struct request_values *rvp)
 {
 	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
-	return tcp_v6_send_synack(sk, req, rvp, 0);
+	return tcp_v6_send_synack(sk, req, rvp, 0, false);
 }
 
 static void tcp_v6_reqsk_destructor(struct request_sock *req)
@@ -909,6 +912,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	dst = ip6_dst_lookup_flow(ctl_sk, &fl6, NULL, false);
 	if (!IS_ERR(dst)) {
 		skb_dst_set(buff, dst);
+		skb->priority = ctl_sk->sk_priority;
 		ip6_xmit(ctl_sk, buff, &fl6, NULL, tclass);
 		TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
 		if (rst)
@@ -1217,7 +1221,8 @@ have_isn:
 
 	if (tcp_v6_send_synack(sk, req,
 			       (struct request_values *)&tmp_ext,
-			       skb_get_queue_mapping(skb)) ||
+			       skb_get_queue_mapping(skb),
+			       want_cookie) ||
 	    want_cookie)
 		goto drop_and_free;
 
