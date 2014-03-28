From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [PATCH][net-next] gianfar: Simplify MQ polling to avoid soft
 lockup
Date: Fri, 28 Mar 2014 09:34:47 +0100
Message-ID: <20140328083447.GA4362@breakpoint.cc>
References: <1381759509-26882-1-git-send-email-claudiu.manoil@freescale.com>
 <1381761267.3392.49.camel@edumazet-glaptop.roam.corp.google.com>
 <525C0993.70503@freescale.com>
 <20140327125303.GA22117@breakpoint.cc>
 <5335307B.2060503@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43149 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751202AbaC1Ieu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 04:34:50 -0400
Content-Disposition: inline
In-Reply-To: <5335307B.2060503@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-03-28 10:19:07 [+0200], Claudiu Manoil wrote:
> >My problem is that when gfar_start_xmit() is preemted after the
> >tx_queue->tx_skbuff[tx_queue->skb_curtx] is set but before the DMA is started
> >then the NAPI-poll never completes because it sees a packet which never
> >completes because the DMA engine did no start yet and won't.
> 
> False, that code section from start_xmit() cannot be preempted, because
> it has spin_lock_irqsave()/restore() around it (unless you modified
> your code).  Will check though if on SMP, for some reason,
> clean_tx_ring() enters with 0 skbs to clean.

I said on -RT. On mainline it can't be preempted as I said. If for
some reason you can't get your packet out (on a slow link as you in your
case) it will return with 0 cleanups.
This has been broken since c233cf4 ("gianfar: Fix tx napi polling")
since you drop the return value.

> [...]
> 
> >To fix properly with something that works on -RT and mainline I suggest
> >to revert this patch and add the following:
> 
> This patch cannot be reverted. (why would you?)
Because it does not fix a thing it simply duck tapes the issue that a TX
transfer does not cleanup a thing and you assume that it did something.
You have budget a reserved for RX cleanup which you do not use up if possible.
You simple do one loop and leave.

> This patch fixes the issue from description.  I'm seeing no issues with
> P1010 now (on any kind of traffic), and the openwrt/tp-link guys also
> confirmed (on the powerpc list) that this patch addresses the issue on
> their end.
Simply because the stall is gone doesn't make it good. As you had no
idea why.

> If you encounter problems with the latest driver code, please submit a
> proper issue description indicating the code base you're using and so
> on.  Also make sure that the problem you're seeing wasn't already fixed
> by one of the latest gianfar fixes from net-next:
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git

I pointed out _why_ you saw the stall and the fix involved not to
endless loop on TX clean up on yet transmitted packages. The removal of
outer loop was not required. The issue is present since c233cf4 which
made it in v3.10 into the kernel. 

Sebastian
