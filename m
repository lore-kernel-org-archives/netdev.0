From: Vasily Averin <vvs@parallels.com>
Subject: [PATCH] ipv4: dst_entry leak in ip_append_data()
Date: Mon, 13 Oct 2014 14:17:34 +0400
Message-ID: <543BA6BE.3040509@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:22812 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753327AbaJMKTP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2014 06:19:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 2e77d89b2fa8 ("net: avoid a pair of dst_hold()/dst_release() in ip_append_data()")

If sk_write_queue is empty ip_append_data() executes ip_setup_cork()
that "steals" dst entry from rt to cork. Later it calls __ip_append_data()
that creates skb and adds it to sk_write_queue.

If skb was added successfully following ip_push_pending_frames() call
reassign dst entry from cork to skb, and kfree_skb frees dst_entry.

However nobody frees stolen dst_entry if skb was not added into sk_write_queue.

Signed-off-by: Vasily Averin <vvs@parallels.com>
---
 net/ipv4/ip_output.c | 25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e35b712..cc7b579 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1120,6 +1120,15 @@ static int ip_setup_cork(struct sock *sk, struct inet_cork *cork,
 	return 0;
 }
 
+static void ip_cork_release(struct inet_cork *cork)
+{
+	cork->flags &= ~IPCORK_OPT;
+	kfree(cork->opt);
+	cork->opt = NULL;
+	dst_release(cork->dst);
+	cork->dst = NULL;
+}
+
 /*
  *	ip_append_data() and ip_append_page() can make one large IP datagram
  *	from many pieces of data. Each pieces will be holded on the socket
@@ -1152,9 +1161,14 @@ int ip_append_data(struct sock *sk, struct flowi4 *fl4,
 		transhdrlen = 0;
 	}
 
-	return __ip_append_data(sk, fl4, &sk->sk_write_queue, &inet->cork.base,
+	err = __ip_append_data(sk, fl4, &sk->sk_write_queue, &inet->cork.base,
 				sk_page_frag(sk), getfrag,
 				from, length, transhdrlen, flags);
+
+	if (skb_queue_empty(&sk->sk_write_queue))
+		ip_cork_release(&inet->cork.base);
+
+	return err;
 }
 
 ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
@@ -1304,15 +1318,6 @@ error:
 	return err;
 }
 
-static void ip_cork_release(struct inet_cork *cork)
-{
-	cork->flags &= ~IPCORK_OPT;
-	kfree(cork->opt);
-	cork->opt = NULL;
-	dst_release(cork->dst);
-	cork->dst = NULL;
-}
-
 /*
  *	Combined all pending IP fragments on the socket as one IP datagram
  *	and push them out.
-- 
1.9.1
