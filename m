From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next 0/2] xen-netback: Changes around carrier handling
Date: Thu, 7 Aug 2014 16:51:17 +0100
Message-ID: <53E3A075.2090400@citrix.com>
References: <1407165658-20146-1-git-send-email-zoltan.kiss@citrix.com>	<20140805.160748.1185917042908283028.davem@davemloft.net>	<53E28017.9040908@citrix.com> <20140806.140146.1448631909293617629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <Ian.Campbell@citrix.com>,
	<david.vrabel@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Paul Durrant <Paul.Durrant@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140806.140146.1448631909293617629.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/08/14 22:01, David Miller wrote:
> From: Zoltan Kiss <zoltan.kiss@citrix.com>
> Date: Wed, 6 Aug 2014 20:20:55 +0100
>
>> The fundamental problem with netback that start_xmit place the
>> packet into an internal queue, and then the thread does the actual
>> transmission from that queue, but it doesn't know whether it will
>> succeed in a finite time period.
>
> A hardware device acts the same way when the link goes down or the
> transmitter hangs.  I do not see this situation, therefore, as
> fundamentally unique to xen-netback.
>
>> I just noticed a possible problem with start_xmit: if this slot
>> estimation fails, and the packet is likely to be stalled at least for
>> a while, it still place the skb into the internal queue and return
>> NETDEV_TX_OK. Shouldn't we return NETDEV_TX_BUSY and not placing the
>> packet into the internal queue? It will be requeued later, or dropped
>> by QDisc. I think it will be more natural. But it can decrease
>> performance if these "not enough slot" situations are very frequent
>> and short living, and by the time the RX thread wakes up
>> My long term idea is to move part of the thread's work into
>> start_xmit, so it can set up the grant operations and if there isn't
>> enough slot it can return the skb to QDisc with NETDEV_TX_BUSY for
>> requeueing. Then the thread can only do the batching of the grant copy
>> operations and releasing the skbs. And we can ditch a good part of the
>> code ...
>
> Yes, it would be a slight improvement if slot availability was
> detected at ->ndo_start_xmit() time.
>
> But best would be to properly stop the queue at the _end_ of
> ->ndo_start_xmit() like nearly all ethernet drivers do.
>
> And we can't do that in netback because..... your queues are too
> small.
>
> If your queues were large enough you could say "now that I've queued
> up SKB for transmit, do I still have enough slots available for a
> maxed out SKB?"  and stop the queue if the answer to that question is
> no.
>
> The queue state was not meant to be a "maybe I can queue a new packet"
> indication.  It's supposed to mean that you can absolutely take at
> least one more SKB of any size or configuration.
Ok, how about this:
* ndo_start_xmit tries to set up the grant copy operations, something 
which is done now in the thread
* no estimation madness, just go ahead and try to do it
* if the skb can fit, kick the thread
* if it fails (not enough slots to complete the TX), then:
   * call netif_tx_stop_queue on that queue (just like now)
   * set up timer rx_stalled (just like now)
   * save the state of the current skb (where the grant copy op setup is 
halted)
* if new slots coming in, continue to create the grant copy ops for the 
stalled skb, and if it succeeds, kick the thread plus call 
netif_tx_start_queue. (just like now)
* if the timer fires, drop the stalled skb, and set the carrier off, so 
QDisc won't bother to queue packets for a stalled interface
* the thread will only do the actual grant copy hypercall and releasing 
the skb
* in any case, ndo_start_xmit should return NETDEV_TX_OK, just like now


>
> Returning TX_BUSY from ->ndo_start_xmit() is fundamentally, therefore,
> more like an error condition rather than something that should occur
> under normal circumstances.  If your queue is up, you should be able
> to accept any one single packet.  That's the rule.
>
> Requeueing back into the qdisc is expensive and takes a lot of locks
> awkwardly.  You do not want the kernel taking this code path.
Ok, thanks for clearing that up, I thought it works differently.
