From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Mon, 12 Jan 2009 13:15:17 +0000
Message-ID: <20090112131517.GD5901@ff.dom.local>
References: <20090106094138.GE25644@1wt.eu> <20090106100112.GB9513@ff.dom.local> <20090106155715.GA28783@1wt.eu> <20090107093915.GA6899@ff.dom.local> <20090107122205.GA6051@1wt.eu> <20090107123153.GA9597@ff.dom.local> <20090107123504.GN32491@kernel.dk> <20090107124946.GA9677@ff.dom.local> <20090107125217.GA26235@gondor.apana.org.au> <20090112120257.GA5697@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jens Axboe <jens.axboe@oracle.com>, Willy Tarreau <w@1wt.eu>,
	Changli Gao <xiaosuo@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:4535 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbZALNPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 08:15:24 -0500
Content-Disposition: inline
In-Reply-To: <20090112120257.GA5697@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2009 at 11:02:57PM +1100, Herbert Xu wrote:
> On Wed, Jan 07, 2009 at 11:52:17PM +1100, Herbert Xu wrote:
> > On Wed, Jan 07, 2009 at 12:49:46PM +0000, Jarek Poplawski wrote:
> > > 
> > > Hmm... in any case: take 3
> > 
> > Yes this should fix the corruption but it kind of defeats the
> > purpose of splice by copying the data.
> 
> However, as we don't have a better fix yet, we probably should
> take Jarek's patch for now since data corruption is bad.
> 

I've wondered if something like this could work as a temporary hack?

!!! not compiled/tested !!!
---

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ce572f9..99b0876 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -264,6 +264,7 @@
 #include <linux/cache.h>
 #include <linux/err.h>
 #include <linux/crypto.h>
+#include <linux/page-flags.h>
 
 #include <net/icmp.h>
 #include <net/tcp.h>
@@ -776,7 +777,8 @@ ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
 	struct sock *sk = sock->sk;
 
 	if (!(sk->sk_route_caps & NETIF_F_SG) ||
-	    !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
+	    !(sk->sk_route_caps & NETIF_F_ALL_CSUM) ||
+	    PageSlab(page))
 		return sock_no_sendpage(sock, page, offset, size, flags);
 
 	lock_sock(sk);
