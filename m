From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH][net-next] gianfar: Simplify MQ polling to avoid soft
 lockup
Date: Fri, 28 Mar 2014 10:19:07 +0200
Message-ID: <5335307B.2060503@freescale.com>
References: <1381759509-26882-1-git-send-email-claudiu.manoil@freescale.com> <1381761267.3392.49.camel@edumazet-glaptop.roam.corp.google.com> <525C0993.70503@freescale.com> <20140327125303.GA22117@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:4090
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751099AbaC1ITX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 04:19:23 -0400
In-Reply-To: <20140327125303.GA22117@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/27/2014 2:53 PM, Sebastian Andrzej Siewior wrote:
> On 2013-10-14 18:11:15 [+0300], Claudiu Manoil wrote:
>>>> BUG: soft lockup - CPU#0 stuck for 23s! [iperf:2847]
>>>> NIP [c0255b6c] find_next_bit+0xb8/0xc4
>>>> LR [c0367ae8] gfar_poll+0xc8/0x1d8
>>> It seems there is a race condition, and this patch only makes it happen
>>> less often ?
>>>
>>> return faster means what exactly ?
>>>
>>
>> Hi Eric,
>> Because of the outer while loop, gfar_poll may not return due
>> to continuous tx work. The later implementation of gfar_poll
>> allows only one iteration of the Tx queues before returning
>> control to net_rx_action(), that's what I meant with "returns faster".
>
> We talk here about 23secs of cleanup. RX is limited by NAPI and TX is
> limited because it can't be refilled on your UP system.
> Does your box recover from this condition without this patch? Mine does
> not. But I run -RT and stumbled uppon something different.
>
> What I observe is that the TX queue is not empty but does not make any
> progress. That means tx_queue->tx_skbuff[tx_queue->skb_dirtytx] is true
> and gfar_clean_tx_ring() cleans up zero packages because it is not yet
> complete.
>
> My problem is that when gfar_start_xmit() is preemted after the
> tx_queue->tx_skbuff[tx_queue->skb_curtx] is set but before the DMA is started
> then the NAPI-poll never completes because it sees a packet which never
> completes because the DMA engine did no start yet and won't.

False, that code section from start_xmit() cannot be preempted, because
it has spin_lock_irqsave()/restore() around it (unless you modified
your code).  Will check though if on SMP, for some reason,
clean_tx_ring() enters with 0 skbs to clean.

[...]

> To fix properly with something that works on -RT and mainline I suggest
> to revert this patch and add the following:

This patch cannot be reverted. (why would you?)
This patch fixes the issue from description.  I'm seeing no issues with
P1010 now (on any kind of traffic), and the openwrt/tp-link guys also
confirmed (on the powerpc list) that this patch addresses the issue on
their end.
If you encounter problems with the latest driver code, please submit a
proper issue description indicating the code base you're using and so
on.  Also make sure that the problem you're seeing wasn't already fixed
by one of the latest gianfar fixes from net-next:
http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git
