From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GRO + splice panics in 3.7.0-rc5
Date: Sat, 01 Dec 2012 14:32:01 -0800
Message-ID: <1354401121.20109.531.camel@edumazet-glaptop>
References: <20121115222812.GA647@1wt.eu>
	 <1353023344.10798.8.camel@edumazet-glaptop> <20121201194304.GI25450@1wt.eu>
	 <20121201205227.GA28390@1wt.eu>
	 <1354398458.20109.528.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:59271 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873Ab2LAWcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 17:32:07 -0500
Received: by mail-vc0-f174.google.com with SMTP id d16so766580vcd.19
        for <netdev@vger.kernel.org>; Sat, 01 Dec 2012 14:32:06 -0800 (PST)
In-Reply-To: <1354398458.20109.528.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-12-01 at 13:47 -0800, Eric Dumazet wrote:

> Thanks a lot Willy
> 
> I believe do_tcp_sendpages() needs a fix, I'll send a patch asap 
> 

Could you try the following patch ?

do_tcp_sendpages() looks really wrong, as only one page is provided by
the caller.

Thanks !

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index e6eace1..6976dba 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -831,8 +831,8 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
 	return mss_now;
 }
 
-static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
-			 size_t psize, int flags)
+static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
+				size_t size, int flags)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int mss_now, size_goal;
@@ -859,12 +859,9 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
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
@@ -913,8 +910,8 @@ new_segment:
 			TCP_SKB_CB(skb)->tcp_flags &= ~TCPHDR_PSH;
 
 		copied += copy;
-		poffset += copy;
-		if (!(psize -= copy))
+		offset += copy;
+		if (!(size -= copy))
 			goto out;
 
 		if (skb->len < size_goal || (flags & MSG_OOB))
@@ -961,7 +958,7 @@ int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 					flags);
 
 	lock_sock(sk);
-	res = do_tcp_sendpages(sk, &page, offset, size, flags);
+	res = do_tcp_sendpages(sk, page, offset, size, flags);
 	release_sock(sk);
 	return res;
 }
