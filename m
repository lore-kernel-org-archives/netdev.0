From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] sock: honor GFP_ATOMIC when allocating send skbs
Date: Mon, 29 Jun 2015 15:06:56 +0200
Message-ID: <1435583216-19877-1-git-send-email-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some sockets set sock->sk->sk_allocation = GFP_ATOMIC. In spite of this,
functions that call sock_alloc_send_skb will then call
sock_alloc_send_pskb, which very often results in sleeping. Since the
intention of callers setting sk_allocation = GFP_ATOMIC might be to be
able to send from atomic context, we need to honor this and not sleep.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 net/core/sock.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/sock.c b/net/core/sock.c
index 1e1fe9a..f00e691 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1804,34 +1804,37 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 				     unsigned long data_len, int noblock,
 				     int *errcode, int max_page_order)
 {
 	struct sk_buff *skb;
 	long timeo;
 	int err;
 
 	timeo = sock_sndtimeo(sk, noblock);
 	for (;;) {
 		err = sock_error(sk);
 		if (err != 0)
 			goto failure;
 
 		err = -EPIPE;
 		if (sk->sk_shutdown & SEND_SHUTDOWN)
 			goto failure;
 
+		if (sk->sk_allocation & GFP_ATOMIC)
+			break;
+
 		if (sk_wmem_alloc_get(sk) < sk->sk_sndbuf)
 			break;
 
 		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
 		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 		err = -EAGAIN;
 		if (!timeo)
 			goto failure;
 		if (signal_pending(current))
 			goto interrupted;
 		timeo = sock_wait_for_wmem(sk, timeo);
 	}
 	skb = alloc_skb_with_frags(header_len, data_len, max_page_order,
 				   errcode, sk->sk_allocation);
 	if (skb)
 		skb_set_owner_w(skb, sk);
 	return skb;
-- 
2.4.2
