From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: introduce dev_consume_skb_any()
Date: Thu, 05 Dec 2013 07:05:52 -0800
Message-ID: <1386255952.30495.192.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	 <1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	 <20131203.165034.1085515763685633822.davem@davemloft.net>
	 <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
	 <1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1386247508.30495.180.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131205141346.GB14095@order.stressinduktion.org>
	 <1386254734.30495.186.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:56194 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932203Ab3LEPFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 10:05:54 -0500
Received: by mail-pd0-f178.google.com with SMTP id y10so24582253pdj.23
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 07:05:53 -0800 (PST)
In-Reply-To: <1386254734.30495.186.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-05 at 06:45 -0800, Eric Dumazet wrote:
> On Thu, 2013-12-05 at 15:13 +0100, Hannes Frederic Sowa wrote:
> > On Thu, Dec 05, 2013 at 04:45:08AM -0800, Eric Dumazet wrote:
> > > -		local_irq_save(flags);
> > > -		sd = &__get_cpu_var(softnet_data);
> > > -		skb->next = sd->completion_queue;
> > > -		sd->completion_queue = skb;
> > > -		raise_softirq_irqoff(NET_TX_SOFTIRQ);
> > > -		local_irq_restore(flags);
> > > +	if (likely(atomic_read(&skb->users) == 1)) {
> > > +		smp_rmb();
> > 
> > Could you give me a hint why this barrier is needed? IMHO the volatile
> > access in atomic_read should get rid of the control dependency so I
> > don't see a need for this barrier. Without the volatile access a
> > compiler-barrier would still suffice, I guess?
> 
> Please take a look at kfree_skb() implementation.
> 
> If you think a comment is needed there, please feel free to add it.
> 

My understanding of this (old) barrier here is an implicit wmb in
skb_get()

This probably needs something like :

static inline struct sk_buff *skb_get(struct sk_buff *skb)
{
	smp_mb__before_atomic_inc(); /* check {consume|kfree}_skb() */
	atomic_inc(&skb->users);
}
