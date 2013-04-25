From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH 0/3] URGENT for 3.9: net: fec: revert NAPI introduction
Date: Thu, 25 Apr 2013 14:31:25 +0200
Message-ID: <1366893085.4139.6.camel@weser.hi.pengutronix.de>
References: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
	 <CAOMZO5D5+bZ9NvF7HvVsne1ktZDDYPqZgomHkSaydrn2UEvBcQ@mail.gmail.com>
	 <CAHrpEqQyG68v4VMDNEwcobhHqkuP_ORH9KA3OZD=2xAoJCMNOQ@mail.gmail.com>
	 <1366620998.4141.28.camel@weser.hi.pengutronix.de>
	 <CAHrpEqQzpLCVqyuMgD=W6ObK1Za-AcmDV7Ejxzw9xKFH57J99A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Fabio Estevam <festevam@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39742 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370Ab3DYMcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 08:32:33 -0400
In-Reply-To: <CAHrpEqQzpLCVqyuMgD=W6ObK1Za-AcmDV7Ejxzw9xKFH57J99A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, den 22.04.2013, 17:17 +0800 schrieb Frank Li:
> 2013/4/22 Lucas Stach <l.stach@pengutronix.de>:
> > Hi all,
> >
> > Am Samstag, den 20.04.2013, 20:35 +0800 schrieb Frank Li:
> >> 2013/4/20 Fabio Estevam <festevam@gmail.com>
> >> >
> >> > Lucas,
> >> >
> >> > On Fri, Apr 19, 2013 at 11:36 AM, Lucas Stach <l.stach@pengutronix.de> wrote:
> >> > > Those patches introduce instability to the point of kernel OOPSes with
> >> > > NULL-ptr dereferences.
> >> > >
> >> > > The patches drop locks from the code without justifying why this would
> >> > > be safe at all. In fact it isn't safe as now the controller restart can
> >> > > happily free the RX and TX ring buffers while the NAPI poll function is
> >> > > still accessing them. So with a heavily loaded but slightly instable
> >>
> >> I think a possible solution is disable NAPI in restart function.
> >> So only one thread can reset BD queue.
> >>
> >> BD queue is nolock design.
> >>
> > It doesn't matter at all that the hardware BD queue is designed to be
> > operated lockless, you still have to synchronize the driver functions to
> > each other and explicit locks are a far better way to achieve this than
> > some implicit tunneling through a single thread or other such things.
> 
> Not hardware BD queue.
> I redesign software BD queue as lockless queue.
> 
> After put actual queue process work to NAPI,  interrupt handle will
> not interrupt xmit and NAPI function again.
> 
> There are just one entry xmit to push new data to bd queue.
> One entry fec_enet_tx to pull old data from bd queue.
> 
>                        HARD_TX_LOCK(dev, txq, cpu);
> 
>                         if (!netif_xmit_stopped(txq)) {
>                                 __this_cpu_inc(xmit_recursion);
>                                 rc = dev_hard_start_xmit(skb, dev, txq);
>                                 __this_cpu_dec(xmit_recursion);
>                                 if (dev_xmit_complete(rc)) {
>                                         HARD_TX_UNLOCK(dev, txq);
>                                         goto out;
>                                 }
>                         }
>                         HARD_TX_UNLOCK(dev, txq);
> 
> Restart function will only called at suspend/resume, init, and speed change.
> So risk should not in heave loading.
> 
> The other reason of remove lock is that fix deadlock detected by kernel.

While I agree that lockless queues and NAPI disable while doing FEC
restart is the way to go for further development, I tried to implement
that yesterday and it needs some bigger changes to the driver to split
things up properly, otherwise we need a lot of ad-hoc hackery to check
if NAPI is enabled, which seems really error prone. 

think such a change in the driver is not acceptable in the current state
of the cycle. I for one will not submit this change, as I'm not sure at
all that it won't regress in other situations.

Regards,
Lucas
-- 
Pengutronix e.K.                           | Lucas Stach                 |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-5076 |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
