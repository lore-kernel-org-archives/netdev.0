From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 12/17] tcp: constify tcp_make_synack() socket argument
Date: Fri, 25 Sep 2015 07:39:19 -0700
Message-ID: <1443191964-923-13-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34328 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbbIYOkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:40:22 -0400
Received: by padhy16 with SMTP id hy16so107772533pad.1
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:40:22 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

listener socket is not locked when tcp_make_synack() is called.

We better make sure no field is written.

There is one exception : Since SYNACK packets are attached to the listener
at this moment (or SYN_RECV child in case of Fast Open),
sock_wmalloc() needs to update sk->sk_wmem_alloc, but this is done using
atomic operations so this is safe.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h     |  2 +-
 net/ipv4/tcp_output.c | 24 +++++++++++++++---------
 2 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 70aea203545e..fde20acb3328 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -461,7 +461,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb);
 int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
 int tcp_connect(struct sock *sk);
-struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
+struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 				struct request_sock *req,
 				struct tcp_fastopen_cookie *foc);
 int tcp_disconnect(struct sock *sk, int flags);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index dcb5c144f8fa..0831dcae6d03 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2945,20 +2945,25 @@ int tcp_send_synack(struct sock *sk)
  * Allocate one skb and build a SYNACK packet.
  * @dst is consumed : Caller should not use it again.
  */
-struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
+struct sk_buff *tcp_make_synack(const struct sock *sk, struct dst_entry *dst,
 				struct request_sock *req,
 				struct tcp_fastopen_cookie *foc)
 {
-	struct tcp_out_options opts;
 	struct inet_request_sock *ireq = inet_rsk(req);
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct tcphdr *th;
-	struct sk_buff *skb;
+	const struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_md5sig_key *md5 = NULL;
+	struct tcp_out_options opts;
+	struct sk_buff *skb;
 	int tcp_header_size;
+	struct tcphdr *th;
+	u16 user_mss;
 	int mss;
 
-	skb = sock_wmalloc(sk, MAX_TCP_HEADER, 1, GFP_ATOMIC);
+	/* sk is a const pointer, because we want to express multiple cpus
+	 * might call us concurrently.
+	 * sock_wmalloc() will change sk->sk_wmem_alloc in an atomic way.
+	 */
+	skb = sock_wmalloc((struct sock *)sk, MAX_TCP_HEADER, 1, GFP_ATOMIC);
 	if (unlikely(!skb)) {
 		dst_release(dst);
 		return NULL;
@@ -2969,8 +2974,9 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	skb_dst_set(skb, dst);
 
 	mss = dst_metric_advmss(dst);
-	if (tp->rx_opt.user_mss && tp->rx_opt.user_mss < mss)
-		mss = tp->rx_opt.user_mss;
+	user_mss = READ_ONCE(tp->rx_opt.user_mss);
+	if (user_mss && user_mss < mss)
+		mss = user_mss;
 
 	memset(&opts, 0, sizeof(opts));
 #ifdef CONFIG_SYN_COOKIES
@@ -3010,7 +3016,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 	/* RFC1323: The window in SYN & SYN/ACK segments is never scaled. */
 	th->window = htons(min(req->rcv_wnd, 65535U));
-	tcp_options_write((__be32 *)(th + 1), tp, &opts);
+	tcp_options_write((__be32 *)(th + 1), NULL, &opts);
 	th->doff = (tcp_header_size >> 2);
 	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_OUTSEGS);
 
-- 
2.6.0.rc2.230.g3dd15c0
