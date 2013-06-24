From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: gre: fix a possible skb leak
Date: Mon, 24 Jun 2013 16:38:07 +0200
Message-ID: <51C859CF.80009@redhat.com>
References: <1372080360.3301.61.camel@edumazet-glaptop> <20130624140359.GA28057@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22800 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750902Ab3FXOiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 10:38:14 -0400
In-Reply-To: <20130624140359.GA28057@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2013 04:03 PM, Veaceslav Falico wrote:
> On Mon, Jun 24, 2013 at 06:26:00AM -0700, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
...
> Maybe we can also use it here (build-tested only):

Yep, this clean-up looks good I think. But then -net needs to be merged into
-net-next first (also for the gre_offload patch).

> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 4850dc1..5776819 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2924,10 +2924,7 @@ perform_csum_check:
>       return segs;
>
>   err:
> -    while ((skb = segs)) {
> -        segs = skb->next;
> -        kfree_skb(skb);
> -    }
> +    kfree_skb_list(segs);
>       return ERR_PTR(err);
>   }
>   EXPORT_SYMBOL_GPL(skb_segment);
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 4bcabf3..27ba045 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -575,11 +575,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
>               return 0;
>           }
>
> -        while (frag) {
> -            skb = frag->next;
> -            kfree_skb(frag);
> -            frag = skb;
> -        }
> +        kfree_skb_list(frag);
>           IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
>           return err;
>
