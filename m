From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: sock: fix TCP_SKB_MIN_TRUESIZE
Date: Wed, 03 Jul 2013 05:02:22 -0700
Message-ID: <1372852942.4979.67.camel@edumazet-glaptop>
References: <1371639080-10699-1-git-send-email-dborkman@redhat.com>
	 <1371644355.3252.307.camel@edumazet-glaptop>
	 <20130619.211721.1594350084165223337.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:42810 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753819Ab3GCMCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 08:02:24 -0400
Received: by mail-pa0-f53.google.com with SMTP id tj12so153144pac.26
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 05:02:23 -0700 (PDT)
In-Reply-To: <20130619.211721.1594350084165223337.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit eea86af6b1e18d ("net: sock: adapt SOCK_MIN_RCVBUF and
SOCK_MIN_SNDBUF") forgot the sk_buff alignment taken into account
in __alloc_skb() : skb->truesize = SKB_TRUESIZE(size);

While above commit fixed the sender issue, the receiver is still
dropping the second packet (on loopback device), because the receiver
socket can not really hold two skbs :
First packet truesize already is above sk_rcvbuf, so even TCP coalescing
cannot help.

On a typical 64bit build, each tcp skb truesize is 2304, instead of 2272

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
Google-Bug-Id: 8124810

 include/net/sock.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index ea6206c..95a5a2c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2052,7 +2052,7 @@ static inline void sk_wake_async(struct sock *sk, int how, int band)
  * Note: for send buffers, TCP works better if we can build two skbs at
  * minimum.
  */
-#define TCP_SKB_MIN_TRUESIZE	(2048 + sizeof(struct sk_buff))
+#define TCP_SKB_MIN_TRUESIZE	(2048 + SKB_DATA_ALIGN(sizeof(struct sk_buff)))
 
 #define SOCK_MIN_SNDBUF		(TCP_SKB_MIN_TRUESIZE * 2)
 #define SOCK_MIN_RCVBUF		 TCP_SKB_MIN_TRUESIZE
