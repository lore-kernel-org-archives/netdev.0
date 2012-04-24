From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: speedup skb_splice_bits()
Date: Tue, 24 Apr 2012 05:18:23 +0200
Message-ID: <1335237503.5205.113.camel@edumazet-glaptop>
References: <1335133576.2395.409.camel@edumazet-glaptop>
	 <20120423.230205.418261556142199877.davem@davemloft.net>
	 <20120423.230641.256329442020745539.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, axboe@kernel.dk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:45445 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756502Ab2DXDS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 23:18:28 -0400
Received: by wibhq7 with SMTP id hq7so188787wib.1
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 20:18:26 -0700 (PDT)
In-Reply-To: <20120423.230641.256329442020745539.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-23 at 23:06 -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 23 Apr 2012 23:02:05 -0400 (EDT)
> 
> > I'm going to cleanup spd_fill_page() to return a bool.
> 
> Done, thusly:
> 
> --------------------
> net: Use bool and remove inline in skb_splice_bits() code.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/core/skbuff.c |   58 ++++++++++++++++++++++++++---------------------------
>  1 file changed, 29 insertions(+), 29 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index dfb3040..aaf4abc 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -1547,9 +1547,9 @@ static void sock_spd_release(struct splice_pipe_desc *spd, unsigned int i)
>  	put_page(spd->pages[i]);
>  }
>  
> -static inline struct page *linear_to_page(struct page *page, unsigned int *len,
> -					  unsigned int *offset,
> -					  struct sk_buff *skb, struct sock *sk)
> +static struct page *linear_to_page(struct page *page, unsigned int *len,
> +				   unsigned int *offset,
> +				   struct sk_buff *skb, struct sock *sk)
>  {
>  	struct page *p = sk->sk_sndmsg_page;
>  	unsigned int off;
> @@ -1598,23 +1598,23 @@ static bool spd_can_coalesce(const struct splice_pipe_desc *spd,
>  /*
>   * Fill page/offset/length into spd, if it can hold more pages.
>   */
> -static inline int spd_fill_page(struct splice_pipe_desc *spd,
> -				struct pipe_inode_info *pipe, struct page *page,
> -				unsigned int *len, unsigned int offset,
> -				struct sk_buff *skb, int linear,
> -				struct sock *sk)
> +static bool spd_fill_page(struct splice_pipe_desc *spd,
> +			  struct pipe_inode_info *pipe, struct page *page,
> +			  unsigned int *len, unsigned int offset,
> +			  struct sk_buff *skb, int linear,

linear could be a bool too 

[PATCH] net: make spd_fill_page() linear argument a bool

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index aaf4abc..2342a72 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1601,7 +1601,7 @@ static bool spd_can_coalesce(const struct splice_pipe_desc *spd,
 static bool spd_fill_page(struct splice_pipe_desc *spd,
 			  struct pipe_inode_info *pipe, struct page *page,
 			  unsigned int *len, unsigned int offset,
-			  struct sk_buff *skb, int linear,
+			  struct sk_buff *skb, bool linear,
 			  struct sock *sk)
 {
 	if (unlikely(spd->nr_pages == MAX_SKB_FRAGS))
@@ -1642,7 +1642,7 @@ static inline void __segment_seek(struct page **page, unsigned int *poff,
 static bool __splice_segment(struct page *page, unsigned int poff,
 			     unsigned int plen, unsigned int *off,
 			     unsigned int *len, struct sk_buff *skb,
-			     struct splice_pipe_desc *spd, int linear,
+			     struct splice_pipe_desc *spd, bool linear,
 			     struct sock *sk,
 			     struct pipe_inode_info *pipe)
 {
@@ -1694,7 +1694,7 @@ static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
 	if (__splice_segment(virt_to_page(skb->data),
 			     (unsigned long) skb->data & (PAGE_SIZE - 1),
 			     skb_headlen(skb),
-			     offset, len, skb, spd, 1, sk, pipe))
+			     offset, len, skb, spd, true, sk, pipe))
 		return true;
 
 	/*
@@ -1705,7 +1705,7 @@ static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
 
 		if (__splice_segment(skb_frag_page(f),
 				     f->page_offset, skb_frag_size(f),
-				     offset, len, skb, spd, 0, sk, pipe))
+				     offset, len, skb, spd, false, sk, pipe))
 			return true;
 	}
 
