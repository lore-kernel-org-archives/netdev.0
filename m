From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Tue, 20 Jan 2009 08:37:26 +0000
Message-ID: <20090120083726.GA13806@ff.dom.local>
References: <20090114.012919.117682429.davem@davemloft.net> <20090115230331.GB1123@1wt.eu> <20090115231934.GA8328@gondor.apana.org.au> <20090115.152608.89323697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, w@1wt.eu, zbr@ioremap.net,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f20.google.com ([209.85.219.20]:40795 "EHLO
	mail-ew0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516AbZATIhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 03:37:35 -0500
Content-Disposition: inline
In-Reply-To: <20090115.152608.89323697.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 03:26:08PM -0800, David Miller wrote:
...
> net: Fix data corruption when splicing from sockets.
> 
> From: Jarek Poplawski <jarkao2@gmail.com>
> 
> The trick in socket splicing where we try to convert the skb->data
> into a page based reference using virt_to_page() does not work so
> well.
...
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 65eac77..56272ac 100644
...

Here is a tiny upgrade to save some memory by reusing a page for more
chunks if possible, which I think could be considered, after the
testing of the main patch is finished. (There could be also added an
additional freeing of this cached page before socket destruction,
maybe in tcp_splice_read(), if somebody finds good place.)

Thanks,
Jarek P.

---

 include/net/sock.h  |    4 ++++
 net/core/skbuff.c   |   32 ++++++++++++++++++++++++++------
 net/core/sock.c     |    2 ++
 net/ipv4/tcp_ipv4.c |    8 ++++++++
 4 files changed, 40 insertions(+), 6 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 5a3a151..4ded741 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -190,6 +190,8 @@ struct sock_common {
   *	@sk_user_data: RPC layer private data
   *	@sk_sndmsg_page: cached page for sendmsg
   *	@sk_sndmsg_off: cached offset for sendmsg
+  *	@sk_splice_page: cached page for splice
+  *	@sk_splice_off: cached offset for splice
   *	@sk_send_head: front of stuff to transmit
   *	@sk_security: used by security modules
   *	@sk_mark: generic packet mark
@@ -279,6 +281,8 @@ struct sock {
 	struct page		*sk_sndmsg_page;
 	struct sk_buff		*sk_send_head;
 	__u32			sk_sndmsg_off;
+	struct page		*sk_splice_page;
+	__u32			sk_splice_off;
 	int			sk_write_pending;
 #ifdef CONFIG_SECURITY
 	void			*sk_security;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 56272ac..74adc79 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1334,13 +1334,33 @@ static void sock_spd_release(struct splice_pipe_desc *spd, unsigned int i)
 }
 
 static inline struct page *linear_to_page(struct page *page, unsigned int len,
-					  unsigned int offset)
+					  unsigned int *offset,
+					  struct sk_buff *skb)
 {
-	struct page *p = alloc_pages(GFP_KERNEL, 0);
+	struct sock *sk = skb->sk;
+	struct page *p = sk->sk_splice_page;
+	unsigned int off;
 
-	if (!p)
-		return NULL;
-	memcpy(page_address(p) + offset, page_address(page) + offset, len);
+	if (!p) {
+new_page:
+		p = sk->sk_splice_page = alloc_pages(sk->sk_allocation, 0);
+		if (!p)
+			return NULL;
+
+		off = sk->sk_splice_off = 0;
+		/* hold this page until it's full or unneeded */
+		get_page(p);
+	} else {
+		off = sk->sk_splice_off;
+		if (off + len > PAGE_SIZE) {
+			put_page(p);
+			goto new_page;
+		}
+	}
+
+	memcpy(page_address(p) + off, page_address(page) + *offset, len);
+	sk->sk_splice_off += len;
+	*offset = off;
 
 	return p;
 }
@@ -1356,7 +1376,7 @@ static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
 		return 1;
 
 	if (linear) {
-		page = linear_to_page(page, len, offset);
+		page = linear_to_page(page, len, &offset, skb);
 		if (!page)
 			return 1;
 	} else
diff --git a/net/core/sock.c b/net/core/sock.c
index f3a0d08..6b258a9 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1732,6 +1732,8 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 
 	sk->sk_sndmsg_page	=	NULL;
 	sk->sk_sndmsg_off	=	0;
+	sk->sk_splice_page	=	NULL;
+	sk->sk_splice_off	=	0;
 
 	sk->sk_peercred.pid 	=	0;
 	sk->sk_peercred.uid	=	-1;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 19d7b42..cf3d367 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1848,6 +1848,14 @@ void tcp_v4_destroy_sock(struct sock *sk)
 		sk->sk_sndmsg_page = NULL;
 	}
 
+	/*
+	 * If splice cached page exists, toss it.
+	 */
+	if (sk->sk_splice_page) {
+		__free_page(sk->sk_splice_page);
+		sk->sk_splice_page = NULL;
+	}
+
 	percpu_counter_dec(&tcp_sockets_allocated);
 }
 
