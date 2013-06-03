From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv2 net-next] netlink: allow large data transfers from
 user-space
Date: Mon, 3 Jun 2013 19:01:37 +0200
Message-ID: <20130603170136.GA23920@macbook.localnet>
References: <1370277599-27072-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41639 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758127Ab3FCRBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 13:01:45 -0400
Content-Disposition: inline
In-Reply-To: <1370277599-27072-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 03, 2013 at 06:39:59PM +0200, Pablo Neira Ayuso wrote:
> I can hit ENOBUFS in the sendmsg() path with a large batch that is
> composed of many netlink messages. Here that limit is 8 MBytes of
> skbuff data area as kmalloc does not manage to get more than that.
> 
> While discussing atomic rule-set for nftables with Patrick McHardy,
> we decided to put all rule-set updates that need to be applied
> atomically in one single batch to simplify the existing approach.
> However, as explained above, the existing netlink code limits us
> to a maximum of ~20000 rules that fit in one single batch without
> hitting ENOBUFS. iptables does not have such limitation as it is
> using vmalloc.
> 
> This patch adds netlink_alloc_large_skb() which is only used in
> the netlink_sendmsg() path. It uses alloc_skb if the memory
> requested is <= one memory page, that should be the common case
> for most subsystems, else vmalloc for higher memory allocations.

I know I suggested to do this - just wondering right now, how will we
indiciate to userspace that a change has been applied atomically when
sending notifications? Not sure whether it matters unless userspace
will be able to get a dump while we're in the middle of updating
the ruleset. I guess that won't be possible, right?

> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
> v1: initial version
> v2: Use NLMSG_GOODSIZE instead of PAGE_SIZE, suggested by Eric Dumazet.
> 
>  net/netlink/af_netlink.c |   37 +++++++++++++++++++++++++++++++++++--
>  1 file changed, 35 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 12ac6b4..7c71d07 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -750,6 +750,10 @@ static void netlink_skb_destructor(struct sk_buff *skb)
>  		skb->data = NULL;
>  	}
>  #endif
> +	if (is_vmalloc_addr(skb->head)) {
> +		vfree(skb->head);
> +		skb->data = NULL;
> +	}
>  	if (skb->sk != NULL)
>  		sock_rfree(skb);
>  }
> @@ -1420,6 +1424,35 @@ struct sock *netlink_getsockbyfilp(struct file *filp)
>  	return sock;
>  }
>  
> +static struct sk_buff *netlink_alloc_large_skb(unsigned int size)
> +{
> +	struct sk_buff *skb;
> +	void *data;
> +
> +	if (size <= NLMSG_GOODSIZE)
> +		return alloc_skb(size, GFP_KERNEL);
> +
> +	skb = alloc_skb_head(GFP_KERNEL);
> +	if (skb == NULL)
> +		return NULL;
> +
> +	data = vmalloc(size);
> +	if (data == NULL)
> +		goto err;
> +
> +	skb->head	= data;
> +	skb->data	= data;
> +	skb_reset_tail_pointer(skb);
> +	skb->end	= skb->tail + size;
> +	skb->len	= 0;
> +	skb->destructor = netlink_skb_destructor;
> +
> +	return skb;
> +err:
> +	kfree_skb(skb);
> +	return NULL;
> +}
> +
>  /*
>   * Attach a skb to a netlink socket.
>   * The caller must hold a reference to the destination socket. On error, the
> @@ -1510,7 +1543,7 @@ static struct sk_buff *netlink_trim(struct sk_buff *skb, gfp_t allocation)
>  		return skb;
>  
>  	delta = skb->end - skb->tail;
> -	if (delta * 2 < skb->truesize)
> +	if (is_vmalloc_addr(skb->head) || delta * 2 < skb->truesize)
>  		return skb;
>  
>  	if (skb_shared(skb)) {
> @@ -2096,7 +2129,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
>  	if (len > sk->sk_sndbuf - 32)
>  		goto out;
>  	err = -ENOBUFS;
> -	skb = alloc_skb(len, GFP_KERNEL);
> +	skb = netlink_alloc_large_skb(len);
>  	if (skb == NULL)
>  		goto out;
>  
> -- 
> 1.7.10.4
