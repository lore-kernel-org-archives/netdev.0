From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/4] net: make dev_kfree_skb_irq not inline
Date: Thu, 14 Dec 2006 22:30:09 +0000
Message-ID: <20061214223009.GA16356@infradead.org>
References: <20061214204814.631279000@osdl.org> <20061214204900.799953000@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:42715 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964917AbWLNWaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 17:30:13 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061214204900.799953000@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 14, 2006 at 12:48:15PM -0800, Stephen Hemminger wrote:
> Move the dev_kfree_skb_irq function from netdevice.h to dev.c
> for a couple of reasons. Primarily, I want to make softnet_data
> local to dev.c; also this function is called 300+ places already.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> --- linux-2.6.20-rc1.orig/include/linux/netdevice.h
> +++ linux-2.6.20-rc1/include/linux/netdevice.h
> @@ -676,20 +676,7 @@ static inline int netif_running(const st
>  /* Use this variant when it is known for sure that it
>   * is executing from interrupt context.
>   */
> -static inline void dev_kfree_skb_irq(struct sk_buff *skb)
> -{
> -	if (atomic_dec_and_test(&skb->users)) {
> -		struct softnet_data *sd;
> -		unsigned long flags;
> -
> -		local_irq_save(flags);
> -		sd = &__get_cpu_var(softnet_data);
> -		skb->next = sd->completion_queue;
> -		sd->completion_queue = skb;
> -		raise_softirq_irqoff(NET_TX_SOFTIRQ);
> -		local_irq_restore(flags);
> -	}
> -}
> +extern void dev_kfree_skb_irq(struct sk_buff *skb);

Maybe you should only move the slowpath out of line ala:

static inline void dev_kfree_skb_irq(struct sk_buff *skb)
{
	if (atomic_dec_and_test(&skb->users)) 
		__dev_kfree_skb_irq(skb);
}

