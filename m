From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Wed, 21 Jul 2010 10:05:29 +0200
Message-ID: <1279699529.3707.5.camel@jlt3.sipsolutions.net>
References: <1279631789.2498.71.camel@edumazet-laptop>
	 <1279639232.2498.82.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:57535 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762740Ab0GUIFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 04:05:33 -0400
In-Reply-To: <1279639232.2498.82.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-07-20 at 17:20 +0200, Eric Dumazet wrote:

> [PATCH net-next-2.6 v2] netlink: netlink_recvmsg() fix
> 
> commit 1dacc76d0014 
> (net/compat/wext: send different messages to compat tasks)
> introduced a race condition on netlink, in case MSG_PEEK is used.
> 
> An skb given by skb_recv_datagram() might be shared, we must copy it
> before any modification, or risk fatal corruption.

Makes sense to me, seeing that if you MSG_PEEK it just increases
skb->users. But nothing could touch the other skb at the same time?
Although I guess with netlink multicast we have a similar situation.

johannes

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/netlink/af_netlink.c |   13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 7aeaa83..1537fa5 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1405,7 +1405,7 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
>  	struct netlink_sock *nlk = nlk_sk(sk);
>  	int noblock = flags&MSG_DONTWAIT;
>  	size_t copied;
> -	struct sk_buff *skb, *frag __maybe_unused = NULL;
> +	struct sk_buff *skb;
>  	int err;
>  
>  	if (flags&MSG_OOB)
> @@ -1440,7 +1440,12 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
>  			kfree_skb(skb);
>  			skb = compskb;
>  		} else {
> -			frag = skb_shinfo(skb)->frag_list;
> +			skb = skb_unshare(skb, GFP_KERNEL);
> +			if (!skb) {
> +				err = -ENOMEM;
> +				goto out;
> +			}
> +			kfree_skb(skb_shinfo(skb)->frag_list);
>  			skb_shinfo(skb)->frag_list = NULL;
>  		}
>  	}
> @@ -1477,10 +1482,6 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
>  	if (flags & MSG_TRUNC)
>  		copied = skb->len;
>  
> -#ifdef CONFIG_COMPAT_NETLINK_MESSAGES
> -	skb_shinfo(skb)->frag_list = frag;
> -#endif
> -
>  	skb_free_datagram(sk, skb);
>  
>  	if (nlk->cb && atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf / 2)
> 
> 
> 


