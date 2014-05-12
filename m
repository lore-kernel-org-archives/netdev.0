From: Kirill Tkhai <ktkhai@parallels.com>
Subject: net: unix: Align send data_len up to PAGE_SIZE
Date: Mon, 12 May 2014 18:52:12 +0400
Message-ID: <1399906332.31472.1.camel@tkhai>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:55079 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758712AbaELOwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 10:52:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using whole of allocated pages reduces requested skb->data size.
This is just a more thriftily allocation.
    
netperf does not show difference with the current performance.
    
Signed-off-by: Kirill Tkhai <ktkhai@parallels.com>
---
 net/unix/af_unix.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 749f80c..0830005 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1492,10 +1492,14 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (len > sk->sk_sndbuf - 32)
 		goto out;
 
-	if (len > SKB_MAX_ALLOC)
+	if (len > SKB_MAX_ALLOC) {
 		data_len = min_t(size_t,
 				 len - SKB_MAX_ALLOC,
 				 MAX_SKB_FRAGS * PAGE_SIZE);
+		data_len = min_t(size_t,
+				 len,
+				 PAGE_ALIGN(data_len));
+	}
 
 	skb = sock_alloc_send_pskb(sk, len - data_len, data_len,
 				   msg->msg_flags & MSG_DONTWAIT, &err,
@@ -1670,6 +1674,8 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 
 		data_len = max_t(int, 0, size - SKB_MAX_HEAD(0));
 
+		data_len = min_t(size_t, size, PAGE_ALIGN(data_len));
+
 		skb = sock_alloc_send_pskb(sk, size - data_len, data_len,
 					   msg->msg_flags & MSG_DONTWAIT, &err,
 					   get_order(UNIX_SKB_FRAGS_SZ));
