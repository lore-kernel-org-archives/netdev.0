From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: fix a race in sock_queue_err_skb()
Date: Fri, 06 Apr 2012 10:49:10 +0200
Message-ID: <1333702150.5312.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:44527 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005Ab2DFItP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 04:49:15 -0400
Received: by wejx9 with SMTP id x9so1338187wej.19
        for <netdev@vger.kernel.org>; Fri, 06 Apr 2012 01:49:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As soon as an skb is queued into socket error queue, another thread
can consume it, so we are not allowed to reference skb anymore, or risk
use after free.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/skbuff.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f223cdc..baf8d28 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3161,6 +3161,8 @@ static void sock_rmem_free(struct sk_buff *skb)
  */
 int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
 {
+	int len = skb->len;
+
 	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
 	    (unsigned)sk->sk_rcvbuf)
 		return -ENOMEM;
@@ -3175,7 +3177,7 @@ int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb)
 
 	skb_queue_tail(&sk->sk_error_queue, skb);
 	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_data_ready(sk, skb->len);
+		sk->sk_data_ready(sk, len);
 	return 0;
 }
 EXPORT_SYMBOL(sock_queue_err_skb);
