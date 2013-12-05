From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: introduce dev_consume_skb_any()
Date: Thu, 5 Dec 2013 15:13:46 +0100
Message-ID: <20131205141346.GB14095@order.stressinduktion.org>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com> <1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com> <CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com> <20131203.165034.1085515763685633822.davem@davemloft.net> <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com> <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com> <1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com> <1386247508.30495.180.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33116 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998Ab3LEONr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 09:13:47 -0500
Content-Disposition: inline
In-Reply-To: <1386247508.30495.180.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 04:45:08AM -0800, Eric Dumazet wrote:
> -		local_irq_save(flags);
> -		sd = &__get_cpu_var(softnet_data);
> -		skb->next = sd->completion_queue;
> -		sd->completion_queue = skb;
> -		raise_softirq_irqoff(NET_TX_SOFTIRQ);
> -		local_irq_restore(flags);
> +	if (likely(atomic_read(&skb->users) == 1)) {
> +		smp_rmb();

Could you give me a hint why this barrier is needed? IMHO the volatile
access in atomic_read should get rid of the control dependency so I
don't see a need for this barrier. Without the volatile access a
compiler-barrier would still suffice, I guess?


> +		atomic_set(&skb->users, 0);
> +	} else if (likely(!atomic_dec_and_test(&skb->users))) {
> +		return;

Or does this memory barrier deal with the part below this return?

Thanks,

  Hannes
