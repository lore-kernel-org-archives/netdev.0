From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 8/9] net: add paged frag destructor support to
 kernel_sendpage.
Date: Thu, 10 May 2012 14:48:58 +0300
Message-ID: <20120510114858.GB9609@redhat.com>
References: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
 <1336056971-7839-8-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41794 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757952Ab2EJLs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 07:48:58 -0400
Content-Disposition: inline
In-Reply-To: <1336056971-7839-8-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 03, 2012 at 03:56:10PM +0100, Ian Campbell wrote:
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 2d590ca..bee7864 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -822,8 +822,11 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
>  	return mss_now;
>  }
>  
> -static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
> -			 size_t psize, int flags)
> +static ssize_t do_tcp_sendpages(struct sock *sk,
> +				struct page **pages,
> +				struct skb_frag_destructor *destroy,
> +				int poffset,
> +				size_t psize, int flags)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
>  	int mss_now, size_goal;
> @@ -870,7 +873,7 @@ new_segment:
>  			copy = size;
>  
>  		i = skb_shinfo(skb)->nr_frags;
> -		can_coalesce = skb_can_coalesce(skb, i, page, NULL, offset);
> +		can_coalesce = skb_can_coalesce(skb, i, page, destroy, offset);
>  		if (!can_coalesce && i >= MAX_SKB_FRAGS) {
>  			tcp_mark_push(tp, skb);
>  			goto new_segment;
> @@ -881,8 +884,9 @@ new_segment:
>  		if (can_coalesce) {
>  			skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
>  		} else {
> -			get_page(page);
>  			skb_fill_page_desc(skb, i, page, offset, copy);
> +			skb_frag_set_destructor(skb, i, destroy);
> +			skb_frag_ref(skb, i);
>  		}
>  
>  		skb->len += copy;
> @@ -937,18 +941,20 @@ out_err:
>  	return sk_stream_error(sk, flags, err);
>  }
>  
> -int tcp_sendpage(struct sock *sk, struct page *page, int offset,
> -		 size_t size, int flags)
> +int tcp_sendpage(struct sock *sk, struct page *page,
> +		 struct skb_frag_destructor *destroy,
> +		 int offset, size_t size, int flags)
>  {
>  	ssize_t res;
>  
>  	if (!(sk->sk_route_caps & NETIF_F_SG) ||
>  	    !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
> -		return sock_no_sendpage(sk->sk_socket, page, offset, size,
> -					flags);
> +		return sock_no_sendpage(sk->sk_socket, page, destroy,
> +					offset, size, flags);
>  
>  	lock_sock(sk);
> -	res = do_tcp_sendpages(sk, &page, offset, size, flags);
> +	res = do_tcp_sendpages(sk, &page, destroy,
> +			       offset, size, flags);
>  	release_sock(sk);
>  	return res;
>  }


Sorry about making more noise but I realized there's
something I don't understand here.

Is it true that all this does is stick the destructor in the frag list?

If so, could this deadlock (or delay application significantly) if tcp
has queued the skb on the write queue but is not transmitting it, while
the application is waiting for pages to complete?

-- 
MST
