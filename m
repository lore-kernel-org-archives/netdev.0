From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix crashes in do_tcp_sendpages()
Date: Sat, 01 Dec 2012 15:07:02 -0800
Message-ID: <1354403222.20109.539.camel@edumazet-glaptop>
References: <20121115222812.GA647@1wt.eu>
	 <1353023344.10798.8.camel@edumazet-glaptop> <20121201194304.GI25450@1wt.eu>
	 <20121201205227.GA28390@1wt.eu>
	 <1354398458.20109.528.camel@edumazet-glaptop>
	 <1354401121.20109.531.camel@edumazet-glaptop>
	 <20121201224044.GL25450@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:37202 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753714Ab2LAXHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 18:07:08 -0500
Received: by mail-vb0-f46.google.com with SMTP id b13so586683vby.19
        for <netdev@vger.kernel.org>; Sat, 01 Dec 2012 15:07:07 -0800 (PST)
In-Reply-To: <20121201224044.GL25450@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Recent network changes allowed high order pages being used
for skb fragments.

This uncovered a bug in do_tcp_sendpages() which was assuming its caller
provided an array of order-0 page pointers.

We only have to deal with a single page in this function, and its order
is irrelevant.

Reported-by: Willy Tarreau <w@1wt.eu>
Tested-by: Willy Tarreau <w@1wt.eu>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c |   15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 083092e..e457c7a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -830,8 +830,8 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
 	return mss_now;
 }
 
-static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
-			 size_t psize, int flags)
+static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
+				size_t size, int flags)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int mss_now, size_goal;
@@ -858,12 +858,9 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 		goto out_err;
 
-	while (psize > 0) {
+	while (size > 0) {
 		struct sk_buff *skb = tcp_write_queue_tail(sk);
-		struct page *page = pages[poffset / PAGE_SIZE];
 		int copy, i;
-		int offset = poffset % PAGE_SIZE;
-		int size = min_t(size_t, psize, PAGE_SIZE - offset);
 		bool can_coalesce;
 
 		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0) {
@@ -912,8 +909,8 @@ new_segment:
 			TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_PSH;
 
 		copied += copy;
-		poffset += copy;
-		if (!(psize -= copy))
+		offset += copy;
+		if (!(size -= copy))
 			goto out;
 
 		if (skb->len < size_goal || (flags & MSG_OOB))
@@ -960,7 +957,7 @@ int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 					flags);
 
 	lock_sock(sk);
-	res = do_tcp_sendpages(sk, &page, offset, size, flags);
+	res = do_tcp_sendpages(sk, page, offset, size, flags);
 	release_sock(sk);
 	return res;
 }
