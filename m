From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/4] net: make dev_kfree_skb_irq not inline
Date: Thu, 14 Dec 2006 14:34:11 -0800
Message-ID: <20061214143411.39e9f77e@freekitty>
References: <20061214204814.631279000@osdl.org>
	<20061214204900.799953000@osdl.org>
	<20061214223009.GA16356@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:36809 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964938AbWLNWee (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 17:34:34 -0500
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20061214223009.GA16356@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Dec 2006 22:30:09 +0000
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Dec 14, 2006 at 12:48:15PM -0800, Stephen Hemminger wrote:
> > Move the dev_kfree_skb_irq function from netdevice.h to dev.c
> > for a couple of reasons. Primarily, I want to make softnet_data
> > local to dev.c; also this function is called 300+ places already.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> > 
> > --- linux-2.6.20-rc1.orig/include/linux/netdevice.h
> > +++ linux-2.6.20-rc1/include/linux/netdevice.h
> > @@ -676,20 +676,7 @@ static inline int netif_running(const st
> >  /* Use this variant when it is known for sure that it
> >   * is executing from interrupt context.
> >   */
> > -static inline void dev_kfree_skb_irq(struct sk_buff *skb)
> > -{
> > -	if (atomic_dec_and_test(&skb->users)) {
> > -		struct softnet_data *sd;
> > -		unsigned long flags;
> > -
> > -		local_irq_save(flags);
> > -		sd = &__get_cpu_var(softnet_data);
> > -		skb->next = sd->completion_queue;
> > -		sd->completion_queue = skb;
> > -		raise_softirq_irqoff(NET_TX_SOFTIRQ);
> > -		local_irq_restore(flags);
> > -	}
> > -}
> > +extern void dev_kfree_skb_irq(struct sk_buff *skb);
> 
> Maybe you should only move the slowpath out of line ala:
> 
> static inline void dev_kfree_skb_irq(struct sk_buff *skb)
> {
> 	if (atomic_dec_and_test(&skb->users)) 
> 		__dev_kfree_skb_irq(skb);
> }
> 

We could but for routing or other cases where buffer isn't cloned
it goes through the test.

-- 
Stephen Hemminger <shemminger@osdl.org>
