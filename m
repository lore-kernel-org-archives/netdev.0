From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/3] tcp: Slightly optimize tcp_sendmsg
Date: Thu, 10 Dec 2009 10:17:30 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912101016040.23376@melkinpaasi.cs.helsinki.fi>
References: <20091209082613.19055.58864.sendpatchset@localhost.localdomain> <20091209082624.19055.99645.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59240 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933274AbZLJIRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 03:17:24 -0500
In-Reply-To: <20091209082624.19055.99645.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Dec 2009, Krishna Kumar wrote:

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Slightly optimize tcp_sendmsg since NETIF_F_SG is used many
> times iteratively in the loop. The only other modification is
> to change:
> 			} else if (i == MAX_SKB_FRAGS ||
> 				   (!i &&
> 				   !(sk->sk_route_caps & NETIF_F_SG))) {
> 	to:
> 			} else if (i == MAX_SKB_FRAGS || !sg) {

I can see that you make this change from the patch itself but could you 
give a justification on why dropping the !i is possible? ...I couldn't
see what would allow that.

> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  net/ipv4/tcp.c |   17 +++++++++--------
>  1 file changed, 9 insertions(+), 8 deletions(-)
> 
> diff -ruNp org/net/ipv4/tcp.c new/net/ipv4/tcp.c
> --- org/net/ipv4/tcp.c	2009-12-09 10:01:35.000000000 +0530
> +++ new/net/ipv4/tcp.c	2009-12-09 10:26:42.000000000 +0530
> @@ -878,12 +878,12 @@ ssize_t tcp_sendpage(struct socket *sock
>  #define TCP_PAGE(sk)	(sk->sk_sndmsg_page)
>  #define TCP_OFF(sk)	(sk->sk_sndmsg_off)
>  
> -static inline int select_size(struct sock *sk)
> +static inline int select_size(struct sock *sk, int sg)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
>  	int tmp = tp->mss_cache;
>  
> -	if (sk->sk_route_caps & NETIF_F_SG) {
> +	if (sg) {
>  		if (sk_can_gso(sk))
>  			tmp = 0;
>  		else {
> @@ -907,7 +907,7 @@ int tcp_sendmsg(struct kiocb *iocb, stru
>  	struct sk_buff *skb;
>  	int iovlen, flags;
>  	int mss_now, size_goal;
> -	int err, copied;
> +	int sg, err, copied;
>  	long timeo;
>  
>  	lock_sock(sk);
> @@ -935,6 +935,8 @@ int tcp_sendmsg(struct kiocb *iocb, stru
>  	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
>  		goto out_err;
>  
> +	sg = sk->sk_route_caps & NETIF_F_SG;
> +
>  	while (--iovlen >= 0) {
>  		int seglen = iov->iov_len;
>  		unsigned char __user *from = iov->iov_base;
> @@ -960,8 +962,9 @@ new_segment:
>  				if (!sk_stream_memory_free(sk))
>  					goto wait_for_sndbuf;
>  
> -				skb = sk_stream_alloc_skb(sk, select_size(sk),
> -						sk->sk_allocation);
> +				skb = sk_stream_alloc_skb(sk,
> +							  select_size(sk, sg),
> +							  sk->sk_allocation);
>  				if (!skb)
>  					goto wait_for_memory;
>  
> @@ -998,9 +1001,7 @@ new_segment:
>  					/* We can extend the last page
>  					 * fragment. */
>  					merge = 1;
> -				} else if (i == MAX_SKB_FRAGS ||
> -					   (!i &&
> -					   !(sk->sk_route_caps & NETIF_F_SG))) {
> +				} else if (i == MAX_SKB_FRAGS || !sg) {
>  					/* Need to add new fragment and cannot
>  					 * do this because interface is non-SG,
>  					 * or because all the page slots are
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
 i.
