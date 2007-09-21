From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/2] David Miller's rbtree patches for 2.6.22.6
Date: Fri, 21 Sep 2007 16:48:41 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0709211329240.9514@kivilampi-30.cs.helsinki.fi>
References: <46F1CF35.3030606@gmail.com> <46F1D00B.6030108@gmail.com>
 <46F1D063.6030005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Tom Quetchenbach <virtualphtn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33462 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807AbXIUNso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 09:48:44 -0400
In-Reply-To: <46F1D063.6030005@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007, Tom Quetchenbach wrote:

> Patch 2: fixes to fack_counts and enhancement of SACK fast path

...Usually these are not combined in patches but a separate patch per 
change.

> diff -ur linux-2.6.22.6-rbtree-davem-fixed/include/net/tcp.h linux-2.6.22.6-rbtree-tomq/include/net/tcp.h
> --- linux-2.6.22.6-rbtree-davem-fixed/include/net/tcp.h	2007-09-19 17:36:07.000000000 -0700
> +++ linux-2.6.22.6-rbtree-tomq/include/net/tcp.h	2007-09-19 12:22:06.000000000 -0700
> @@ -1213,6 +1213,11 @@

...Btw, please always use -p to diff as well as it helps review :-).

>  	sk->sk_send_head = tcp_write_queue_next(sk, skb);
>  	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
>  		sk->sk_send_head = NULL;
> +	else
> +		/* update fack_count of send_head. Since we've sent skb already,
> + 		 * its packet count must be set by now. */
> +		TCP_SKB_CB(sk->sk_send_head)->fack_count =
> +			TCP_SKB_CB(skb)->fack_count + tcp_skb_pcount(skb);
>
>  	/* Don't override Nagle indefinately with F-RTO */
>  	if (tp->frto_counter == 2)
>  		tp->frto_counter = 3;
> @@ -1310,19 +1315,22 @@
>  /* An insert into the middle of the write queue causes the fack
>   * counts in subsequent packets to become invalid, fix them up.
>   */
> -static inline void tcp_reset_fack_counts(struct sock *sk, struct sk_buff *first)
> +static inline void tcp_reset_fack_counts(struct sock *sk, struct sk_buff *skb)
>  {
> -	struct sk_buff *prev = first->prev;
> +	struct sk_buff *prev = skb->prev;
>  	unsigned int fc = 0;
>  
>  	if (prev != (struct sk_buff *) &sk->sk_write_queue)
>  		fc = TCP_SKB_CB(prev)->fack_count + tcp_skb_pcount(prev);
>  
> -	while (first != (struct sk_buff *)&sk->sk_write_queue) {
> -		TCP_SKB_CB(first)->fack_count = fc;
> +	while (skb != (struct sk_buff *)&sk->sk_write_queue) {
> +		if (TCP_SKB_CB(skb)->fack_count == fc || !tcp_skb_pcount(skb))

What is this !tcp_skb_pcount(skb) for???? I think what we really want here 
is this: 	|| (skb == tcp_send_head(sk))

> +			break;
>
> -		fc += tcp_skb_pcount(first);
> -		first = first->next;
> +		TCP_SKB_CB(skb)->fack_count = fc;
> +
> +		fc += tcp_skb_pcount(skb);
> +		skb = skb->next;
>  	}
>  }
>  
> diff -ur linux-2.6.22.6-rbtree-davem-fixed/net/ipv4/tcp_input.c linux-2.6.22.6-rbtree-tomq/net/ipv4/tcp_input.c
> --- linux-2.6.22.6-rbtree-davem-fixed/net/ipv4/tcp_input.c	2007-09-13 18:23:16.000000000 -0700
> +++ linux-2.6.22.6-rbtree-tomq/net/ipv4/tcp_input.c	2007-09-19 12:27:42.000000000 -0700
> @@ -956,6 +956,7 @@
>  	int fack_count_base;
>  	int i;
>  	int first_sack_index;
> +	u32 prev_end_seq = 0;
>  
>  	if (!tp->sacked_out)
>  		tp->fackets_out = 0;
> @@ -1000,6 +1001,7 @@
>  		if (i == 0) {
>  			if (tp->recv_sack_cache[i].start_seq != start_seq)
>  				flag = 0;
> +			prev_end_seq = ntohl(tp->recv_sack_cache[i].end_seq);
>  		} else {
>  			if ((tp->recv_sack_cache[i].start_seq != start_seq) ||
>  			    (tp->recv_sack_cache[i].end_seq != end_seq))
> @@ -1016,9 +1018,16 @@
>  
>  	first_sack_index = 0;
>  	if (flag)
> +		/* all that has changed is end of first SACK block. So all we
> + 		 * need to do is tag those skbs that were'nt tagged last time. */

IMHO, a bit verbose comment. Besides, we already tell above that what SACK 
fastpath is all about...

>  		num_sacks = 1;
>  	else {
>  		int j;
> +		
> +		/* more than just end of first SACK block has changed; invalidate
> +		 * prev_end_seq */
> +
> +		prev_end_seq = 0;

Don't tell what's obvious from code as well.

>  		/* order SACK blocks to allow in order walk of the retrans queue */
>  		for (i = num_sacks-1; i > 0; i--) {
> @@ -1051,6 +1060,8 @@
>  		int fack_count;
>  		int dup_sack = (found_dup_sack && (i == first_sack_index));
>  
> +		if (prev_end_seq) start_seq = prev_end_seq;
> +

...We never add statements on the same line after if statements (see 
Documentation/CodingStyle)



-- 
 i.
