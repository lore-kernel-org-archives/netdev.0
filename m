From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: fix syncookie regression
Date: Sat, 10 Mar 2012 11:20:21 -0800
Message-ID: <1331407221.2453.42.camel@edumazet-laptop>
References: <20120310122725.GA31129@hostway.ca>
	 <1331401490.2453.28.camel@edumazet-laptop>
	 <1331402182.2453.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Simon Kirby <sim@netnation.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:56511 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826Ab2CJTU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 14:20:29 -0500
Received: by wibhq7 with SMTP id hq7so1879389wib.1
        for <netdev@vger.kernel.org>; Sat, 10 Mar 2012 11:20:28 -0800 (PST)
In-Reply-To: <1331402182.2453.30.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ea4fc0d619 (ipv4: Don't use rt->rt_{src,dst} in ip_queue_xmit())
added a serious regression on synflood handling.

Simon Kirby discovered a successful connection was delayed by 20 seconds
before being responsive.

In my tests, I discovered that xmit frames were lost, and needed ~4
retransmits and a socket dst rebuild before being really sent.

In case of syncookie initiated connection, we use a different path to
initialize the socket dst, and inet->cork.fl.u.ip4 is left cleared.

As ip_queue_xmit() now depends on inet flow being setup, fix this by
copying the temp flowi4 we use in cookie_v4_check().

Reported-by: Simon Kirby <sim@netnation.com>
Bisected-by: Simon Kirby <sim@netnation.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Tested-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/syncookies.c |   30 ++++++++++++++++--------------
 net/ipv4/tcp_ipv4.c   |   10 +++++++---
 2 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 51fdbb4..eab2a7f 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -278,6 +278,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	struct rtable *rt;
 	__u8 rcv_wscale;
 	bool ecn_ok = false;
+	struct flowi4 fl4;
 
 	if (!sysctl_tcp_syncookies || !th->ack || th->rst)
 		goto out;
@@ -346,20 +347,16 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	 * hasn't changed since we received the original syn, but I see
 	 * no easy way to do this.
 	 */
-	{
-		struct flowi4 fl4;
-
-		flowi4_init_output(&fl4, 0, sk->sk_mark, RT_CONN_FLAGS(sk),
-				   RT_SCOPE_UNIVERSE, IPPROTO_TCP,
-				   inet_sk_flowi_flags(sk),
-				   (opt && opt->srr) ? opt->faddr : ireq->rmt_addr,
-				   ireq->loc_addr, th->source, th->dest);
-		security_req_classify_flow(req, flowi4_to_flowi(&fl4));
-		rt = ip_route_output_key(sock_net(sk), &fl4);
-		if (IS_ERR(rt)) {
-			reqsk_free(req);
-			goto out;
-		}
+	flowi4_init_output(&fl4, 0, sk->sk_mark, RT_CONN_FLAGS(sk),
+			   RT_SCOPE_UNIVERSE, IPPROTO_TCP,
+			   inet_sk_flowi_flags(sk),
+			   (opt && opt->srr) ? opt->faddr : ireq->rmt_addr,
+			   ireq->loc_addr, th->source, th->dest);
+	security_req_classify_flow(req, flowi4_to_flowi(&fl4));
+	rt = ip_route_output_key(sock_net(sk), &fl4);
+	if (IS_ERR(rt)) {
+		reqsk_free(req);
+		goto out;
 	}
 
 	/* Try to redo what tcp_v4_send_synack did. */
@@ -373,5 +370,10 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	ireq->rcv_wscale  = rcv_wscale;
 
 	ret = get_cookie_sock(sk, skb, req, &rt->dst);
+	/* ip_queue_xmit() depends on our flow being setup
+	 * Normal sockets get it right from inet_csk_route_child_sock()
+	 */
+	if (ret)
+		inet_sk(ret)->cork.fl.u.ip4 = fl4;
 out:	return ret;
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 94d683a..fd54c5f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1466,9 +1466,13 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		inet_csk(newsk)->icsk_ext_hdr_len = inet_opt->opt.optlen;
 	newinet->inet_id = newtp->write_seq ^ jiffies;
 
-	if (!dst && (dst = inet_csk_route_child_sock(sk, newsk, req)) == NULL)
-		goto put_and_exit;
-
+	if (!dst) {
+		dst = inet_csk_route_child_sock(sk, newsk, req);
+		if (!dst)
+			goto put_and_exit;
+	} else {
+		/* syncookie case : see end of cookie_v4_check() */
+	}
 	sk_setup_caps(newsk, dst);
 
 	tcp_mtup_init(newsk);
