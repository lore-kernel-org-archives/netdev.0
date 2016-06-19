From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/2] net: simplify and make pkt_type_ok() available
 for other users
Date: Sun, 19 Jun 2016 20:06:05 +0200
Message-ID: <5766DF0D.7080001@iogearbox.net>
References: <1466262725-30289-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, fw@strlen.de
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58461 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbcFSSG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 14:06:57 -0400
In-Reply-To: <1466262725-30289-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,

On 06/18/2016 05:12 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>   include/linux/skbuff.h   | 11 +++++++++++
>   net/netfilter/nft_meta.c |  9 +--------
>   2 files changed, 12 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index dc0fca7..0b794de 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -37,6 +37,7 @@
>   #include <net/flow_dissector.h>
>   #include <linux/splice.h>
>   #include <linux/in6.h>
> +#include <linux/if_packet.h>
>   #include <net/flow.h>
>
>   /* The interface for checksum offload between the stack and networking drivers
> @@ -797,6 +798,7 @@ struct sk_buff {
>   	atomic_t		users;
>   };
>
> +

Why the extra newline here (the rest looks good)?

>   #ifdef __KERNEL__
>   /*
>    *	Handling routines are only of interest to the kernel
> @@ -881,6 +883,15 @@ static inline struct rtable *skb_rtable(const struct sk_buff *skb)
>   	return (struct rtable *)skb_dst(skb);
>   }
>
> +/* For mangling skb->pkt_type from user space side from applications
> + * such as nft, tc, etc, we only allow a conservative subset of
> + * possible pkt_types to be set.
> +*/
> +static inline bool skb_pkt_type_ok(u32 p)
> +{
> +	return p <= PACKET_OTHERHOST;

Just a small nit: I would probably rename 'p' into 'type'.

> +}
> +
>   void kfree_skb(struct sk_buff *skb);
>   void kfree_skb_list(struct sk_buff *segs);
>   void skb_tx_error(struct sk_buff *skb);
> diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
> index 16c50b0..03e5e33 100644
> --- a/net/netfilter/nft_meta.c
> +++ b/net/netfilter/nft_meta.c
> @@ -199,13 +199,6 @@ err:
>   }
>   EXPORT_SYMBOL_GPL(nft_meta_get_eval);
>
> -/* don't change or set _LOOPBACK, _USER, etc. */
> -static bool pkt_type_ok(u32 p)
> -{
> -	return p == PACKET_HOST || p == PACKET_BROADCAST ||
> -	       p == PACKET_MULTICAST || p == PACKET_OTHERHOST;
> -}
> -
>   void nft_meta_set_eval(const struct nft_expr *expr,
>   		       struct nft_regs *regs,
>   		       const struct nft_pktinfo *pkt)
> @@ -223,7 +216,7 @@ void nft_meta_set_eval(const struct nft_expr *expr,
>   		break;
>   	case NFT_META_PKTTYPE:
>   		if (skb->pkt_type != value &&
> -		    pkt_type_ok(value) && pkt_type_ok(skb->pkt_type))
> +		    skb_pkt_type_ok(value) && skb_pkt_type_ok(skb->pkt_type))
>   			skb->pkt_type = value;
>   		break;
>   	case NFT_META_NFTRACE:
>
