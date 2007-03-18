From: Dan Aloni <da-x@monatomic.org>
Subject: Re: [PATCH] tcp_sendpage(): fix broken page iteration
Date: Sun, 18 Mar 2007 14:50:29 +0200
Message-ID: <20070318125029.GA6617@localdomain>
References: <20070318124346.GA6396@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Linux Kernel List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from noname.neutralserver.com ([70.84.186.210]:34890 "EHLO
	noname.neutralserver.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752324AbXCRMul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2007 08:50:41 -0400
Content-Disposition: inline
In-Reply-To: <20070318124346.GA6396@localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 18, 2007 at 02:43:46PM +0200, Dan Aloni wrote:
> do_tcp_sendpages() should not iterate 'pages' as an array since 
> it is not an array of 'struct page *', but a pointer to a single 
> entity of 'struct page *' passed on the stack as a parameter to 
> tcp_send_page() (hence it would crash if poffset + psize > PAGE_SIZE,
> because pages[1] and beyond most probably not constitutes a valid 
> 'struct page *').
> 
> Since 'page' points to an array of 'struct page', the obvious fix 
> is to iterate that array instead, and that's what the function
> should have done in the first place.
> 
> Applies to 2.6.21-rc4 and above.

Oops, forgot the obligtory signed-off:

Signed-off-by: Dan Aloni <da-x@monatomic.org>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3834b10..4881c8d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -501,7 +501,7 @@ static inline void tcp_push(struct sock *sk, struct tcp_sock *tp, int flags,
 	}
 }
 
-static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
+static ssize_t do_tcp_sendpages(struct sock *sk, struct page *pages, int poffset,
 			 size_t psize, int flags)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -527,7 +527,7 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 
 	while (psize > 0) {
 		struct sk_buff *skb = sk->sk_write_queue.prev;
-		struct page *page = pages[poffset / PAGE_SIZE];
+		struct page *page = &pages[poffset / PAGE_SIZE];
 		int copy, i, can_coalesce;
 		int offset = poffset % PAGE_SIZE;
 		int size = min_t(size_t, psize, PAGE_SIZE - offset);
@@ -630,7 +630,7 @@ ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
 
 	lock_sock(sk);
 	TCP_CHECK_TIMER(sk);
-	res = do_tcp_sendpages(sk, &page, offset, size, flags);
+	res = do_tcp_sendpages(sk, page, offset, size, flags);
 	TCP_CHECK_TIMER(sk);
 	release_sock(sk);
 	return res;


-- 
Dan Aloni
XIV LTD, http://www.xivstorage.com
da-x (at) monatomic.org, dan (at) xiv.co.il
