From: DDD <Dongdong.deng@windriver.com>
Subject: Re: [PATCH] netpoll: WARN_ONCE for start_xmit returns with
	interrupts enabled
Date: Thu, 20 Aug 2009 18:44:00 +0800
Message-ID: <1250765040.17891.91.camel@dengdd-desktop>
References: <1250678607.17891.26.camel@dengdd-desktop>
	 <1250678596.3937.182.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53561 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191AbZHTKbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 06:31:51 -0400
In-Reply-To: <1250678596.3937.182.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-19 at 05:43 -0500, Matt Mackall wrote: 
> On Wed, 2009-08-19 at 18:43 +0800, DDD wrote:
> > The NETPOLL API requires that interrupts remain disabled in
> > netpoll_send_skb().
> > 
> > Add a WARN_ONCE when ndo_start_xmit returns with interrupts enabled
> > in netpoll_send_skb().
> > 
> > Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>
> > ---
> >  net/core/netpoll.c |    6 ++++++
> >  1 files changed, 6 insertions(+), 0 deletions(-)
> > 
> > diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> > index df30feb..d38103f 100644
> > --- a/net/core/netpoll.c
> > +++ b/net/core/netpoll.c
> > @@ -319,6 +319,12 @@ static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
> >  
> >  			udelay(USEC_PER_POLL);
> >  		}
> > +
> > +		WARN_ONCE(!irqs_disabled(),
> > +			KERN_WARNING "netpoll_send_skb(): [net driver %s]"
> > +			"ndo_start_xmit() shouldn't return with interrupts"
> > +			"enabled!", dev->name);
> 
> Hmm, perhaps:
> 
> "netpoll_send_skb(): %s enabled interrupts in poll (%pF)\n",
> dev->name, ops->ndo_start_xmit
> 
> That'll give us a real function name and maybe even a module name.

Thanks, I will modify it as your suggestions.

When I test the WRAN_ONCE, I find that some net drivers still have this problem,
such as using local_irq_disable/local_irq_enable in ndo_start_xmit() or other cases.


I will do an new patch and hope it could fix this problem completely in all the net drivers that support NETPOLL.


I check the drivers that support NETPOLL one by one again(almost 100 drivers),
and following drivers's fix will be included by my patch:

1: ixp2000/ixpdev.c : 66 local_irq_disable

2: fec_mpc52xx.c : 319 spin_unlock_irq

3: macb.c:602 : 638 spin_unlock_irq

4: mlx4/en_netdev.c : 448 
mlx4_en_xmit() -> mlx4_en_xmit_poll() -> spin_trylock_irq

5: smc91x.c 
It seems that there is a lots work to let smc91x work well with netpoll.


Thanks,
Dongdong

> 
