From: Tom Quetchenbach <virtualphtn@gmail.com>
Subject: [PATCH][BUG] tcp: advertise MSS requested by user
Date: Tue, 26 Aug 2008 11:11:52 -0700
Message-ID: <48B44768.3030208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Lachlan Andrew <lachlan.andrew@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outgoing-mail.its.caltech.edu ([131.215.239.19]:60441 "EHLO
	outgoing-mail.its.caltech.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756171AbYHZSX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 14:23:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to use the TCP_MAXSEG option to setsockopt() to set the MSS
for both sides of a bidirectional connection.

man tcp says: "If this option is set before connection establishment, it
also changes the MSS value announced to the other end in the initial
packet."

However, the kernel only uses the MTU/route cache to set the advertised
MSS. That means if I set the MSS to, say, 500 before calling connect(),
I will send at most 500-byte packets, but I will still receive 1500-byte
packets in reply.

This is a bug, either in the kernel or the documentation.

This patch (applies to latest net-2.6) reduces the advertised value to
that requested by the user as long as setsockopt() is called before
connect() or accept(). This seems like the behavior that one would expect
as well as that which is documented.

I've tried to make sure that things that depend on the advertised MSS
are set correctly, but please correct me if I've broken something.

Currently there's no way for the user to change the MSS of an established
connection--calling setsockopt() after the connection is established has
no effect. Is this something that should be changed?

Thanks,
-Tom

Signed-off-by: Tom Quetchenbach <virtualphtn@gmail.com>
---

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 44c1e93..8bc8b36 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1364,6 +1364,11 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	tcp_mtup_init(newsk);
 	tcp_sync_mss(newsk, dst_mtu(dst));
 	newtp->advmss = dst_metric(dst, RTAX_ADVMSS);
+
+	if (tcp_sk(sk)->rx_opt.user_mss &&
+				tcp_sk(sk)->rx_opt.user_mss < newtp->advmss)
+		newtp->advmss = tcp_sk(sk)->rx_opt.user_mss;
+
 	tcp_initialize_rcv_mss(newsk);
 
 #ifdef CONFIG_TCP_MD5SIG
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a00532d..50536e1 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2239,6 +2239,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	struct sk_buff *skb;
 	struct tcp_md5sig_key *md5;
 	__u8 *md5_hash_location;
+	int mss;
 
 	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1, GFP_ATOMIC);
 	if (skb == NULL)
@@ -2249,13 +2250,17 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 	skb->dst = dst_clone(dst);
 
+	mss = dst_metric(dst, RTAX_ADVMSS);
+	if (tp->rx_opt.user_mss && tp->rx_opt.user_mss < mss)
+		mss = tp->rx_opt.user_mss;
+
 	if (req->rcv_wnd == 0) { /* ignored for retransmitted syns */
 		__u8 rcv_wscale;
 		/* Set this up on the first call only */
 		req->window_clamp = tp->window_clamp ? : dst_metric(dst, RTAX_WINDOW);
 		/* tcp_full_space because it is guaranteed to be the first packet */
 		tcp_select_initial_window(tcp_full_space(sk),
-			dst_metric(dst, RTAX_ADVMSS) - (ireq->tstamp_ok ? TCPOLEN_TSTAMP_ALIGNED : 0),
+			mss - (ireq->tstamp_ok ? TCPOLEN_TSTAMP_ALIGNED : 0),
 			&req->rcv_wnd,
 			&req->window_clamp,
 			ireq->wscale_ok,
@@ -2265,8 +2270,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 	memset(&opts, 0, sizeof(opts));
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
-	tcp_header_size = tcp_synack_options(sk, req,
-					     dst_metric(dst, RTAX_ADVMSS),
+	tcp_header_size = tcp_synack_options(sk, req, mss,
 					     skb, &opts, &md5) +
 			  sizeof(struct tcphdr);
 
@@ -2340,6 +2344,11 @@ static void tcp_connect_init(struct sock *sk)
 	if (!tp->window_clamp)
 		tp->window_clamp = dst_metric(dst, RTAX_WINDOW);
 	tp->advmss = dst_metric(dst, RTAX_ADVMSS);
+
+	if (tp->rx_opt.user_mss && tp->rx_opt.user_mss < tp->advmss){
+		tp->advmss = tp->rx_opt.user_mss;
+	}
+
 	tcp_initialize_rcv_mss(sk);
 
 	tcp_select_initial_window(tcp_full_space(sk),
