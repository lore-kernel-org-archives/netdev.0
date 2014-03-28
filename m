From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH][net-next] gianfar: Simplify MQ polling to avoid soft
 lockup
Date: Fri, 28 Mar 2014 11:46:40 +0200
Message-ID: <53354500.3070404@freescale.com>
References: <1381759509-26882-1-git-send-email-claudiu.manoil@freescale.com> <1381761267.3392.49.camel@edumazet-glaptop.roam.corp.google.com> <525C0993.70503@freescale.com> <20140327125303.GA22117@breakpoint.cc> <5335307B.2060503@freescale.com> <20140328083447.GA4362@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe001.messaging.microsoft.com ([213.199.154.204]:52937
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751046AbaC1Jqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 05:46:50 -0400
In-Reply-To: <20140328083447.GA4362@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/28/2014 10:34 AM, Sebastian Andrzej Siewior wrote:
> On 2014-03-28 10:19:07 [+0200], Claudiu Manoil wrote:
>>> My problem is that when gfar_start_xmit() is preemted after the
>>> tx_queue->tx_skbuff[tx_queue->skb_curtx] is set but before the DMA is started
>>> then the NAPI-poll never completes because it sees a packet which never
>>> completes because the DMA engine did no start yet and won't.
>>
>> False, that code section from start_xmit() cannot be preempted, because
>> it has spin_lock_irqsave()/restore() around it (unless you modified
>> your code).  Will check though if on SMP, for some reason,
>> clean_tx_ring() enters with 0 skbs to clean.
>
> I said on -RT. On mainline it can't be preempted as I said. If for
> some reason you can't get your packet out (on a slow link as you in your
> case) it will return with 0 cleanups.
> This has been broken since c233cf4 ("gianfar: Fix tx napi polling")
> since you drop the return value.
>
>> [...]
>>
>>> To fix properly with something that works on -RT and mainline I suggest
>>> to revert this patch and add the following:
>>
>> This patch cannot be reverted. (why would you?)
> Because it does not fix a thing it simply duck tapes the issue that a TX
> transfer does not cleanup a thing and you assume that it did something.
> You have budget a reserved for RX cleanup which you do not use up if possible.
> You simple do one loop and leave.

Your proposed fix doesn't fix the root cause either, it's just a 
workaround that came late.  Do you suggest consuming Rx budget for
Tx processing as a better workaround?
Note that the NAPI processing code has been changed in the meanwhile:
http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git
to address other issues (see aeb12c5ef7cb08d879af22fc0a56cab9e70689ea,
and 71ff9e3df7e1c5d3293af6b595309124e8c97412).
