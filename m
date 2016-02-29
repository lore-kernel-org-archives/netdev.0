From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] mld, igmp: Fix reserved tailroom calculation
Date: Mon, 29 Feb 2016 15:57:46 +0100
Message-ID: <56D45C6A.5040606@iogearbox.net>
References: <1456603028-12589-2-git-send-email-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Benjamin Poirier <bpoirier@suse.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53388 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754675AbcB2O5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 09:57:49 -0500
In-Reply-To: <1456603028-12589-2-git-send-email-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Benjamin,

[ -Cc my old RH address ]

On 02/27/2016 08:57 PM, Benjamin Poirier wrote:
> The current reserved_tailroom calculation fails to take hlen and tlen into
> account.
>
> skb:
> [__hlen__|__data____________|__tlen___|__extra__]
> ^                                               ^
> head                                            skb_end_offset
>
> In this representation, hlen + data + tlen is the size passed to alloc_skb.
> "extra" is the extra space made available in __alloc_skb because of
> rounding up by kmalloc. We can reorder the representation like so:
>
> [__hlen__|__data____________|__extra__|__tlen___]
> ^                                               ^
> head                                            skb_end_offset
>
> The maximum space available for ip headers and payload without
> fragmentation is min(mtu, data + extra). Therefore,
> reserved_tailroom
> = data + extra + tlen - min(mtu, data + extra)
> = skb_end_offset - hlen - min(mtu, skb_end_offset - hlen - tlen)
> = skb_tailroom - min(mtu, skb_tailroom - tlen) ; after skb_reserve(hlen)
>
> Compare the second line to the current expression:
> reserved_tailroom = skb_end_offset - min(mtu, skb_end_offset)
> and we can see that hlen and tlen are not taken into account.
>
> Depending on hlen, tlen, mtu and the number of multicast address records,
> the current code may output skbs that have less tailroom than
> dev->needed_tailroom or it may output more skbs than needed because not all
> space available is used.
>
> Fixes: 4c672e4b ("ipv6: mld: fix add_grhead skb_over_panic for devs with large MTUs")
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
> ---
>   net/ipv4/igmp.c  | 4 ++--
>   net/ipv6/mcast.c | 4 ++--
>   2 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index 05e4cba..b5d28a4 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
[...]

[ cutting the IPv4 part off as diff is the same ]

> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 5ee56d0..c157edc 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -1574,9 +1574,9 @@ static struct sk_buff *mld_newpack(struct inet6_dev *idev, unsigned int mtu)
>   		return NULL;
>
>   	skb->priority = TC_PRIO_CONTROL;
> -	skb->reserved_tailroom = skb_end_offset(skb) -
> -				 min(mtu, skb_end_offset(skb));
>   	skb_reserve(skb, hlen);
> +	skb->reserved_tailroom = skb_tailroom(skb) -
> +		min_t(int, mtu, skb_tailroom(skb) - tlen);

Are you sure this is correct? Wouldn't that mean (assuming we allocated
enough space), that I could now fill a larger than MTU frame?

>   	if (__ipv6_get_lladdr(idev, &addr_buf, IFA_F_TENTATIVE)) {
>   		/* <draft-ietf-magma-mld-source-05.txt>:

Thanks,
Daniel
