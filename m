From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 1/2] David Miller's rbtree patches for 2.6.22.6
Date: Fri, 21 Sep 2007 16:37:42 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0709211622030.9514@kivilampi-30.cs.helsinki.fi>
References: <46F1CF35.3030606@gmail.com> <46F1D00B.6030108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Quetchenbach <virtualphtn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39528 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759791AbXIUNhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 09:37:43 -0400
In-Reply-To: <46F1D00B.6030108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007, Tom Quetchenbach wrote:

> Patch 1: David Miller's red-black tree code, tweaked for 2.6.22.6,
> with some bugfixes

It would help if you would leave the original changes as is (rb-tree and 
fack_count separated) and add your work on top of that...

> diff -ur linux-2.6.22.6/include/net/tcp.h linux-2.6.22.6-rbtree-davem-fixed/include/net/tcp.h
> --- linux-2.6.22.6/include/net/tcp.h	2007-08-30 23:21:01.000000000 -0700
> +++ linux-2.6.22.6-rbtree-davem-fixed/include/net/tcp.h	2007-09-19 17:36:07.000000000 -0700
> @@ -540,6 +540,7 @@
>  	__u32		seq;		/* Starting sequence number	*/
>  	__u32		end_seq;	/* SEQ + FIN + SYN + datalen	*/
>  	__u32		when;		/* used to compute rtt's	*/
> +	unsigned int	fack_count;	/* speed up SACK processing	*/
>  	__u8		flags;		/* TCP header flags.		*/
>  
>  	/* NOTE: These must match up to the flags byte in a
> @@ -1043,12 +1044,12 @@
>  }
>  
>  /*from STCP */
> -static inline void clear_all_retrans_hints(struct tcp_sock *tp){
> +static inline void clear_all_retrans_hints(struct tcp_sock *tp)
> +{

Unrelated change, please don't do that. Besides, it's already fixed in 
net-2.6.24.

>  	tp->lost_skb_hint = NULL;
>  	tp->scoreboard_skb_hint = NULL;
>  	tp->retransmit_skb_hint = NULL;
>  	tp->forward_skb_hint = NULL;
> -	tp->fastpath_skb_hint = NULL;
>  }
>  
>  /* MD5 Signature */
> @@ -1227,9 +1229,61 @@
>  	sk->sk_send_head = NULL;
>  }
>  
> +static inline struct sk_buff *tcp_write_queue_find(struct sock *sk, __u32 seq)
> +{
> +	struct rb_node *rb_node = tcp_sk(sk)->write_queue_rb.rb_node;
> +	struct sk_buff *skb = NULL;
> +
> +	while (rb_node) {
> +		struct sk_buff *tmp = rb_entry(rb_node,struct sk_buff,rb);
> +		if (TCP_SKB_CB(tmp)->end_seq > seq) {

This is old and buggy version of the rb-tree code. Get the latest rb-tree 
patch from tcp-2.6 tree.

> +			skb = tmp;
> +			if (TCP_SKB_CB(tmp)->seq <= seq)

...fixed in tcp-2.6.

> +				break;
> +			rb_node = rb_node->rb_left;
> +		} else
> +			rb_node = rb_node->rb_right;
> +
> +	}
> +	return skb;
> +}
> +
> +static inline void tcp_rb_insert(struct sk_buff *skb, struct rb_root *root)
> +{
> +	struct rb_node **rb_link, *rb_parent;
> +	__u32 seq = TCP_SKB_CB(skb)->seq;
> +
> +	rb_link = &root->rb_node;
> +	rb_parent = NULL;
> +	while (*rb_link != NULL) {
> +		struct sk_buff *tmp = rb_entry(*rb_link,struct sk_buff,rb);
> +		rb_parent = *rb_link;
> +		if (TCP_SKB_CB(tmp)->end_seq > seq) {
> +			BUG_ON(TCP_SKB_CB(tmp)->seq <= seq);

...these are broken as well.

>
> +			rb_link = &rb_parent->rb_left;
> +		} else {
> +			rb_link = &rb_parent->rb_right;
> +		}
> +	}
> +	rb_link_node(&skb->rb, rb_parent, rb_link);
> +	rb_insert_color(&skb->rb, root);
> +}
> +
> +static inline void tcp_rb_unlink(struct sk_buff *skb, struct rb_root *root)
> +{
> +	rb_erase(&skb->rb, root);
> +}
> +
>  static inline void __tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb)
>  {
> +	struct sk_buff *tail = tcp_write_queue_tail(sk);
> +	unsigned int fc = 0;
> +
> +	if (tail)
> +		fc = TCP_SKB_CB(tail)->fack_count + tcp_skb_pcount(tail);
> +	TCP_SKB_CB(skb)->fack_count = fc;
>  	__skb_queue_tail(&sk->sk_write_queue, skb);
> +	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
>  }
>  
>  static inline void tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb)
> diff -ur linux-2.6.22.6/net/ipv4/tcp_input.c linux-2.6.22.6-rbtree-davem-fixed/net/ipv4/tcp_input.c
> --- linux-2.6.22.6/net/ipv4/tcp_input.c	2007-08-30 23:21:01.000000000 -0700
> +++ linux-2.6.22.6-rbtree-davem-fixed/net/ipv4/tcp_input.c	2007-09-13 18:23:16.000000000 -0700
> @@ -947,14 +947,13 @@
>  	unsigned char *ptr = (skb_transport_header(ack_skb) +
>  			      TCP_SKB_CB(ack_skb)->sacked);
>  	struct tcp_sack_block_wire *sp = (struct tcp_sack_block_wire *)(ptr+2);
> -	struct sk_buff *cached_skb;
>  	int num_sacks = (ptr[1] - TCPOLEN_SACK_BASE)>>3;
>  	int reord = tp->packets_out;
>  	int prior_fackets;
>  	u32 lost_retrans = 0;
>  	int flag = 0;
>  	int found_dup_sack = 0;
> -	int cached_fack_count;
> +	int fack_count_base;
>  	int i;
>  	int first_sack_index;
>  
> @@ -1020,7 +1019,6 @@
>  		num_sacks = 1;
>  	else {
>  		int j;
> -		tp->fastpath_skb_hint = NULL;
>  
>  		/* order SACK blocks to allow in order walk of the retrans queue */
>  		for (i = num_sacks-1; i > 0; i--) {
> @@ -1045,14 +1043,7 @@
>  	/* clear flag as used for different purpose in following code */
>  	flag = 0;
>  
> -	/* Use SACK fastpath hint if valid */
> -	cached_skb = tp->fastpath_skb_hint;
> -	cached_fack_count = tp->fastpath_cnt_hint;
> -	if (!cached_skb) {
> -		cached_skb = tcp_write_queue_head(sk);
> -		cached_fack_count = 0;
> -	}
> -
> +	fack_count_base = TCP_SKB_CB(tcp_write_queue_head(sk))->fack_count;
>  	for (i=0; i<num_sacks; i++, sp++) {
>  		struct sk_buff *skb;
>  		__u32 start_seq = ntohl(sp->start_seq);
> @@ -1060,8 +1051,10 @@
>  		int fack_count;
>  		int dup_sack = (found_dup_sack && (i == first_sack_index));
>  
> -		skb = cached_skb;
> -		fack_count = cached_fack_count;
> +		skb = tcp_write_queue_find(sk, start_seq);
> +		if (!skb)
> +			continue;

In net-2.6.24 we validate SACK blocks early. ...This is not a working 
solution anyway since tcp_write_queue_find(end_seq) might be valid don't 
you think (though with validator it should only happen when dup_sack is 
set)? For non-DSACK cases, a better alternative is like this:

if (WARN_ON(skb == NULL))
	continue;

> +		fack_count = TCP_SKB_CB(skb)->fack_count - fack_count_base;
>  
>  		/* Event "B" in the comment above. */
>  		if (after(end_seq, tp->high_seq))

-- 
 i.
