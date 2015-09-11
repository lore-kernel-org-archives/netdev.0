From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] netlink, mmap: transform mmap skb into full skb on
 taps
Date: Fri, 11 Sep 2015 12:25:45 +0200
Message-ID: <55F2AC29.3030209@iogearbox.net>
References: <d8546f5fdd1e84659e0f184275b36fcd565fe59c.1441887916.git.daniel@iogearbox.net> <20150910.221132.1962916984876023271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chamaken@gmail.com, fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49190 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286AbbIKKZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 06:25:49 -0400
In-Reply-To: <20150910.221132.1962916984876023271.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/11/2015 07:11 AM, David Miller wrote:
...
> Looking more deeply into this, I think we have the same exact problem
> with netlink skbs that use vmalloc memory at skb->head.

Yes, agreed, the test in the patch covered those as well via:

   if (netlink_skb_is_mmaped(skb) || is_vmalloc_addr(skb->head))

> We have a special hack, but only when netlink_skb_clone() is used,
> to preserve the destructor.  But these skbs can escape anywhere
> and be eventually cloned as we have seen with the mmap stuff.

Yes, it looks like they are currently only used from user space to
kernel space. I saw that 3a36515f7294 ("netlink: fix splat in skb_clone
with large messages") fixed a couple of these in upper layers with
regards to large skbs, so there's a chance that this can be overseen
rather easily as well in other places and then only come to light in
cases where we allocate more than NLMSG_GOODSIZE, so we don't actually
use the alloc_skb() path. :/ So I like your idea below!

> I'm wondering if we should do something more precise to fix this,
> and in a way that handles both the mmap and vmalloc cases.

Perhaps it might also be useful if the kernel would one day want to
use netlink_alloc_large_skb() for answers back to user space, or in
places where we use network skbs (haven't looked into it with regards
to this).

Some more comments below:

> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 2738d35..77b804c 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -584,8 +584,9 @@ struct sk_buff {
>   				fclone:2,
>   				peeked:1,
>   				head_frag:1,
> -				xmit_more:1;
> -	/* one bit hole */
> +				xmit_more:1,
> +				clone_preserves_destructor;

( Nit: maybe as clone_preserves_destructor:1 )

> +
>   	kmemcheck_bitfield_end(flags1);
>
>   	/* fields enclosed in headers_start/headers_end are copied
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index dad4dd3..4a7b8e3 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -825,7 +825,8 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
>   	n->hdr_len = skb->nohdr ? skb_headroom(skb) : skb->hdr_len;
>   	n->cloned = 1;
>   	n->nohdr = 0;
> -	n->destructor = NULL;
> +	if (!skb->clone_preserves_destructor)
> +		n->destructor = NULL;

I think we also need here:

	else
		C(destructor);

>   	C(tail);
>   	C(end);
>   	C(head);
[...]
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 7f86d3b..214f1a1 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -719,6 +719,7 @@ static void netlink_ring_setup_skb(struct sk_buff *skb, struct sock *sk,
>   	skb->end	= skb->tail + size;
>   	skb->len	= 0;
>
> +	skb->clone_preserves_destructor = 1;
>   	skb->destructor	= netlink_skb_destructor;
>   	NETLINK_CB(skb).flags |= NETLINK_SKB_MMAPED;
>   	NETLINK_CB(skb).sk = sk;
> @@ -854,6 +855,14 @@ static void netlink_ring_set_copied(struct sock *sk, struct sk_buff *skb)
>   #define netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group, scm)	0
>   #endif /* CONFIG_NETLINK_MMAP */

One more thing that came to my mind. For netlink mmap skbs, the
skb->clone_preserves_destructor is actually not enough.

Already calling into skb_clone() is an issue itself, as the data area is
user space buffer, and skb_clone() as well as skb_copy() access skb_shinfo()
area. :/ So in that regard netlink mmap skbs are even further restrictive
on what we can do than netlink large skbs.

Best,
Daniel
