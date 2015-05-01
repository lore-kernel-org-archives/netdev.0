From: Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Allow TCP connections to cache SYN packet for userspace inspection
Date: Fri,  1 May 2015 13:43:57 -0400
Message-ID: <1430502237-5619-1-git-send-email-emunson@akamai.com>
Cc: Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In order to enable policy decisions in userspace, the data contained in
the SYN packet would be useful for tracking or identifying connections.
Only parts of this data are available to userspace after the hand shake
is completed.  This patch exposes a new setsockopt() option that will,
when used with a listening socket, ask the kernel to cache the skb
holding the SYN packet for retrieval later.  The SYN skbs will not be
saved while the kernel is in syn cookie mode.

The same option will ask the kernel for the packet headers when used
with getsockopt() with the socket returned from accept().  The cached
packet will only be available for the first getsockopt() call, the skb
is consumed after the requested data is copied to userspace.  Subsequent
calls will return -ENOENT.  Because of this behavior, getsockopt() will
return -E2BIG if the caller supplied a buffer that is too small to hold
the skb header.

Signed-off-by: Eric B Munson <emunson-JqFfY2XvxFXQT0dZR+AlfA@public.gmane.org>
Cc: Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>
Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
Cc: Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>
Cc: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 include/linux/tcp.h             |  4 +++-
 include/net/inet_sock.h         |  1 +
 include/uapi/linux/tcp.h        |  1 +
 net/ipv4/inet_connection_sock.c | 33 +++++++++++++++++++--------------
 net/ipv4/tcp.c                  | 41 +++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_input.c            |  4 ++++
 net/ipv4/tcp_ipv4.c             |  1 +
 net/ipv4/tcp_minisocks.c        |  1 +
 net/ipv6/tcp_ipv6.c             |  1 +
 9 files changed, 72 insertions(+), 15 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 0caa3a2..2c39d07 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -191,7 +191,8 @@ struct tcp_sock {
 		syn_fastopen:1,	/* SYN includes Fast Open option */
 		syn_fastopen_exp:1,/* SYN includes Fast Open exp. option */
 		syn_data_acked:1,/* data in SYN is acked by SYN-ACK */
-		is_cwnd_limited:1;/* forward progress limited by snd_cwnd? */
+		is_cwnd_limited:1,/* forward progress limited by snd_cwnd? */
+		saved_syn:1;/* keep a copy of the syn packet */
 	u32	tlp_high_seq;	/* snd_nxt at the time of TLP retransmit. */
 
 /* RTT measurement */
@@ -318,6 +319,7 @@ struct tcp_sock {
 	 * socket. Used to retransmit SYNACKs etc.
 	 */
 	struct request_sock *fastopen_rsk;
+	struct sk_buff *syn_skb;
 };
 
 enum tsq_flags {
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index b6c3737..cc0c18b 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -98,6 +98,7 @@ struct inet_request_sock {
 		struct ip_options_rcu	*opt;
 		struct sk_buff		*pktopts;
 	};
+	struct sk_buff		*syn_skb;
 };
 
 static inline struct inet_request_sock *inet_rsk(const struct request_sock *sk)
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 3b97183..5d32550 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -112,6 +112,7 @@ enum {
 #define TCP_FASTOPEN		23	/* Enable FastOpen on listeners */
 #define TCP_TIMESTAMP		24
 #define TCP_NOTSENT_LOWAT	25	/* limit number of unsent bytes in write queue */
+#define TCP_SAVED_SYN		26	/* cache SYN packets for retrieval by userspace */
 
 struct tcp_repair_opt {
 	__u32	opt_code;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 8976ca4..2abcd50 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -325,21 +325,26 @@ struct sock *inet_csk_accept(struct sock *sk, int flags, int *err)
 	newsk = req->sk;
 
 	sk_acceptq_removed(sk);
-	if (sk->sk_protocol == IPPROTO_TCP &&
-	    tcp_rsk(req)->tfo_listener &&
-	    queue->fastopenq) {
-		spin_lock_bh(&queue->fastopenq->lock);
-		if (tcp_rsk(req)->tfo_listener) {
-			/* We are still waiting for the final ACK from 3WHS
-			 * so can't free req now. Instead, we set req->sk to
-			 * NULL to signify that the child socket is taken
-			 * so reqsk_fastopen_remove() will free the req
-			 * when 3WHS finishes (or is aborted).
-			 */
-			req->sk = NULL;
-			req = NULL;
+	if (sk->sk_protocol == IPPROTO_TCP) {
+		tcp_sk(newsk)->saved_syn = tcp_sk(sk)->saved_syn;
+		if (inet_rsk(req)->syn_skb)
+			tcp_sk(newsk)->syn_skb = skb_get(inet_rsk(req)->syn_skb);
+
+		if (tcp_rsk(req)->tfo_listener && queue->fastopenq) {
+			spin_lock_bh(&queue->fastopenq->lock);
+			if (tcp_rsk(req)->tfo_listener) {
+				/* We are still waiting for the final ACK from
+				 * 3WHS so can't free req now. Instead, we set
+				 * req->sk to NULL to signify that the child
+				 * socket is taken so reqsk_fastopen_remove()
+				 * will free the req when 3WHS finishes (or is
+				 * aborted).
+				 */
+				req->sk = NULL;
+				req = NULL;
+			}
+			spin_unlock_bh(&queue->fastopenq->lock);
 		}
-		spin_unlock_bh(&queue->fastopenq->lock);
 	}
 out:
 	release_sock(sk);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8c5cd9e..dcfc0b7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2227,6 +2227,8 @@ EXPORT_SYMBOL(tcp_disconnect);
 
 void tcp_sock_destruct(struct sock *sk)
 {
+	consume_skb(tcp_sk(sk)->syn_skb);
+
 	inet_sock_destruct(sk);
 
 	kfree(inet_csk(sk)->icsk_accept_queue.fastopenq);
@@ -2558,6 +2560,11 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		tp->notsent_lowat = val;
 		sk->sk_write_space(sk);
 		break;
+	case TCP_SAVED_SYN:
+		if (!((1 << sk->sk_state) & TCPF_LISTEN))
+			err = -EINVAL;
+		tp->saved_syn = !!(val);
+		break;
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -2738,6 +2745,40 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		val = !icsk->icsk_ack.pingpong;
 		break;
 
+	case TCP_SAVED_SYN: {
+		struct sk_buff *syn = xchg(&tp->syn_skb, NULL);
+		int bufsz;
+		int ret = -EFAULT;
+
+		if (get_user(len, optlen))
+			goto reset;
+
+		ret = -EINVAL;
+		if ((1 << sk->sk_state) & TCPF_LISTEN)
+			goto reset;
+		if (!tp->saved_syn)
+			goto reset;
+		ret = -ENOENT;
+		if (!syn)
+			goto reset;
+		bufsz = (unsigned long)skb_tail_pointer(syn) - (unsigned long)eth_hdr(syn);
+		ret = -E2BIG;
+		if (len < bufsz)
+			goto reset;
+
+		ret = -EFAULT;
+		if (put_user(bufsz, optlen))
+			goto reset;
+		if (copy_to_user(optval, eth_hdr(syn), bufsz))
+			goto reset;
+		consume_skb(syn);
+
+		return 0;
+reset:
+		tp->syn_skb = syn;
+		return ret;
+	}
+
 	case TCP_CONGESTION:
 		if (get_user(len, optlen))
 			return -EFAULT;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3a4d9b34..b5a61d2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6005,6 +6005,7 @@ struct request_sock *inet_reqsk_alloc(const struct request_sock_ops *ops,
 
 		kmemcheck_annotate_bitfield(ireq, flags);
 		ireq->opt = NULL;
+		ireq->syn_skb = NULL;
 		atomic64_set(&ireq->ir_cookie, 0);
 		ireq->ireq_state = TCP_NEW_SYN_RECV;
 		write_pnet(&ireq->ireq_net, sock_net(sk_listener));
@@ -6163,6 +6164,9 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 			inet_rsk(req)->ecn_ok = 0;
 	}
 
+	if (!want_cookie && tp->saved_syn)
+		inet_rsk(req)->syn_skb = skb_get(skb);
+
 	tcp_rsk(req)->snt_isn = isn;
 	tcp_openreq_init_rwin(req, sk, dst);
 	fastopen = !want_cookie &&
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index fc1c658..c63661d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -853,6 +853,7 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
  */
 static void tcp_v4_reqsk_destructor(struct request_sock *req)
 {
+	consume_skb(inet_rsk(req)->syn_skb);
 	kfree(inet_rsk(req)->opt);
 }
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index e5d7649..b3ffa73 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -535,6 +535,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		tcp_ecn_openreq_child(newtp, req);
 		newtp->fastopen_rsk = NULL;
 		newtp->syn_data_acked = 0;
+		newtp->syn_skb = NULL;
 
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_PASSIVEOPENS);
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b6575d6..400ea2e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -475,6 +475,7 @@ done:
 
 static void tcp_v6_reqsk_destructor(struct request_sock *req)
 {
+	consume_skb(inet_rsk(req)->syn_skb);
 	kfree_skb(inet_rsk(req)->pktopts);
 }
 
-- 
1.9.1
