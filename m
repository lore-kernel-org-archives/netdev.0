From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] netlink, mmap: transform mmap skb into full skb on
 taps
Date: Fri, 11 Sep 2015 22:35:08 +0200
Message-ID: <55F33AFC.1080206@iogearbox.net>
References: <d8546f5fdd1e84659e0f184275b36fcd565fe59c.1441887916.git.daniel@iogearbox.net>	<20150910.221132.1962916984876023271.davem@davemloft.net>	<55F2AC29.3030209@iogearbox.net> <20150911.124205.1992250802389107845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chamaken@gmail.com, fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42877 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661AbbIKUfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 16:35:20 -0400
In-Reply-To: <20150911.124205.1992250802389107845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/11/2015 09:42 PM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Fri, 11 Sep 2015 12:25:45 +0200
>
>> Already calling into skb_clone() is an issue itself, as the data
>> area is user space buffer, and skb_clone() as well as skb_copy()
>> access skb_shinfo() area. :/ So in that regard netlink mmap skbs are
>> even further restrictive on what we can do than netlink large skbs.
>
> Indeed, this is fatal.
>
> So we'd still need something special like your
> netlink_to_full_skb_clone to elide trying to touch the skb_shinfo
> area.
>
> I thought briefly about somehow cobbling up extra space in the ring
> entries so we could have a real skb_shinfo() there, but that's illegal
> too as the user could scribble all over it randomly while we interpret
> the contents.  We don't own that memory.  So this doesn't work.

Yes, agreed.

> We could rename the clone_preserves_destructor and have it also mean
> that the SKB lacks frags and skb_shinfo() should not be inspected.
>
> Something like this:
[...]
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 2738d35..898c53d 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
[...]
> @@ -2220,7 +2221,8 @@ static inline void skb_orphan(struct sk_buff *skb)
>    */
>   static inline int skb_orphan_frags(struct sk_buff *skb, gfp_t gfp_mask)
>   {
> -	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY)))
> +	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) ||
> +		   skb->private_buffers))

(These two would need to be swapped.)

>   		return 0;
>   	return skb_copy_ubufs(skb, gfp_mask);
>   }
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index dad4dd3..54f9d6e 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -825,7 +825,10 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
>   	n->hdr_len = skb->nohdr ? skb_headroom(skb) : skb->hdr_len;
>   	n->cloned = 1;
>   	n->nohdr = 0;
> -	n->destructor = NULL;
> +	if (!skb->private_buffers)
> +		n->destructor = NULL;
> +	else
> +		C(destructor);
>   	C(tail);
>   	C(end);
>   	C(head);

We would also have to conditionally skip the __skb_clone()'s ...

   atomic_inc(&(skb_shinfo(skb)->dataref));

Thus, the issue here is that while netlink_alloc_large_skb() and
netlink_ring_setup_skb() would set both skb->private_buffers = 1,
the large skb case would actually need to inspect dataref count
(which it also can legally do) to properly release the vmalloc'ed
area again, while the other case must not even touch it. So if I
see this correctly, it looks like it's unfortunately not possible
to combine the two cases in a single flag. :/

If there's a good case to burn this flag outside of netlink for e.g.
vmalloc backend memory on skbs, it could be solved like that, while
the mmap case be declared netlink's problem. ;) I currently don't
have a better idea than to copy these guys, hmmm.

[...]
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 7f86d3b..523adac 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -854,6 +855,14 @@ static void netlink_ring_set_copied(struct sock *sk, struct sk_buff *skb)
>   #define netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group, scm)	0
>   #endif /* CONFIG_NETLINK_MMAP */
>
> +static bool skb_can_release_head(struct sk_buff *skb)
> +{
> +	if (!skb->cloned ||
> +	    !atomic_dec_return(&(skb_shinfo(skb)->dataref)))
> +		return true;
> +	return false;
> +}
> +
>   static void netlink_skb_destructor(struct sk_buff *skb)
>   {
>   #ifdef CONFIG_NETLINK_MMAP
> @@ -866,31 +875,35 @@ static void netlink_skb_destructor(struct sk_buff *skb)
[...]
