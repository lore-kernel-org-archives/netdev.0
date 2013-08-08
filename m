From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH] tcp: add server ip to encrypt cookie in fast open
Date: Thu,  8 Aug 2013 14:06:22 -0700
Message-ID: <1375995982-17862-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f74.google.com ([209.85.212.74]:34627 "EHLO
	mail-vb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966588Ab3HHVGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 17:06:48 -0400
Received: by mail-vb0-f74.google.com with SMTP id w16so381058vbf.3
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 14:06:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Encrypt the cookie with both server and client IPv4 addresses,
such that multi-homed server will grant different cookies
based on both the source and destination IPs. No client change
is needed since cookie is opaque to the client.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h       |  3 ++-
 net/ipv4/tcp_fastopen.c | 13 ++++++-------
 net/ipv4/tcp_ipv4.c     | 10 +++++++---
 3 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 27b652f..09cb5c1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1300,7 +1300,8 @@ void tcp_free_fastopen_req(struct tcp_sock *tp);
 
 extern struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
 int tcp_fastopen_reset_cipher(void *key, unsigned int len);
-void tcp_fastopen_cookie_gen(__be32 addr, struct tcp_fastopen_cookie *foc);
+extern void tcp_fastopen_cookie_gen(__be32 src, __be32 dst,
+				    struct tcp_fastopen_cookie *foc);
 
 #define TCP_FASTOPEN_KEY_LENGTH 16
 
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 8f7ef0a..ab7bd35 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -58,23 +58,22 @@ error:		kfree(ctx);
 	return err;
 }
 
-/* Computes the fastopen cookie for the peer.
- * The peer address is a 128 bits long (pad with zeros for IPv4).
+/* Computes the fastopen cookie for the IP path.
+ * The path is a 128 bits long (pad with zeros for IPv4).
  *
  * The caller must check foc->len to determine if a valid cookie
  * has been generated successfully.
 */
-void tcp_fastopen_cookie_gen(__be32 addr, struct tcp_fastopen_cookie *foc)
+void tcp_fastopen_cookie_gen(__be32 src, __be32 dst,
+			     struct tcp_fastopen_cookie *foc)
 {
-	__be32 peer_addr[4] = { addr, 0, 0, 0 };
+	__be32 path[4] = { src, dst, 0, 0 };
 	struct tcp_fastopen_context *ctx;
 
 	rcu_read_lock();
 	ctx = rcu_dereference(tcp_fastopen_ctx);
 	if (ctx) {
-		crypto_cipher_encrypt_one(ctx->tfm,
-					  foc->val,
-					  (__u8 *)peer_addr);
+		crypto_cipher_encrypt_one(ctx->tfm, foc->val, (__u8 *)path);
 		foc->len = TCP_FASTOPEN_COOKIE_SIZE;
 	}
 	rcu_read_unlock();
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 280efe5..ec27028 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1316,9 +1316,11 @@ static bool tcp_fastopen_check(struct sock *sk, struct sk_buff *skb,
 		tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 		return true;
 	}
+
 	if (foc->len == TCP_FASTOPEN_COOKIE_SIZE) {
 		if ((sysctl_tcp_fastopen & TFO_SERVER_COOKIE_NOT_CHKED) == 0) {
-			tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr, valid_foc);
+			tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr,
+						ip_hdr(skb)->daddr, valid_foc);
 			if ((valid_foc->len != TCP_FASTOPEN_COOKIE_SIZE) ||
 			    memcmp(&foc->val[0], &valid_foc->val[0],
 			    TCP_FASTOPEN_COOKIE_SIZE) != 0)
@@ -1329,14 +1331,16 @@ static bool tcp_fastopen_check(struct sock *sk, struct sk_buff *skb,
 		tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 		return true;
 	} else if (foc->len == 0) { /* Client requesting a cookie */
-		tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr, valid_foc);
+		tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr,
+					ip_hdr(skb)->daddr, valid_foc);
 		NET_INC_STATS_BH(sock_net(sk),
 		    LINUX_MIB_TCPFASTOPENCOOKIEREQD);
 	} else {
 		/* Client sent a cookie with wrong size. Treat it
 		 * the same as invalid and return a valid one.
 		 */
-		tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr, valid_foc);
+		tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr,
+					ip_hdr(skb)->daddr, valid_foc);
 	}
 	return false;
 }
-- 
1.8.3
