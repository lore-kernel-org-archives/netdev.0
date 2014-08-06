From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next 0/2] xen-netback: Changes around carrier handling
Date: Wed, 6 Aug 2014 20:20:55 +0100
Message-ID: <53E28017.9040908@citrix.com>
References: <1407165658-20146-1-git-send-email-zoltan.kiss@citrix.com> <20140805.160748.1185917042908283028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <Ian.Campbell@citrix.com>,
	<david.vrabel@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:55615 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932246AbaHFTVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2014 15:21:20 -0400
In-Reply-To: <20140805.160748.1185917042908283028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/08/14 00:07, David Miller wrote:
> From: Zoltan Kiss <zoltan.kiss@citrix.com>
> Date: Mon, 4 Aug 2014 16:20:56 +0100
>
>> This series starts using carrier off as a way to purge packets when the guest is
>> not able (or willing) to receive them. It is a much faster way to get rid of
>> packets waiting for an overwhelmed guest.
>> The first patch changes current netback code where it relies currently on
>> netif_carrier_ok.
>> The second turns off the carrier if the guest times out on a queue, and only
>> turn it on again if that queue (or queues) resurrects.
>>
>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
>
> Applied, but I have some reservations:
>
> 1) This is starting to bleed what is normally qdisc type policy into the
>     driver.
Yeah. The fundamental problem with netback that start_xmit place the 
packet into an internal queue, and then the thread does the actual 
transmission from that queue, but it doesn't know whether it will 
succeed in a finite time period.
There is slot estimation in start_xmit to prevent QDisc pouring more 
packets into the internal queue when it seems it won't fit. When that 
happens, we stop QDisc and start a timer, and when the timer fires, 
before this patch we just ditched the internal queue and started QDisc 
again. If the frontend were dead, it lead to a quite long delay until 
packets destined to it were freed.
I just noticed a possible problem with start_xmit: if this slot 
estimation fails, and the packet is likely to be stalled at least for a 
while, it still place the skb into the internal queue and return 
NETDEV_TX_OK. Shouldn't we return NETDEV_TX_BUSY and not placing the 
packet into the internal queue? It will be requeued later, or dropped by 
QDisc. I think it will be more natural. But it can decrease performance 
if these "not enough slot" situations are very frequent and short 
living, and by the time the RX thread wakes up
My long term idea is to move part of the thread's work into start_xmit, 
so it can set up the grant operations and if there isn't enough slot it 
can return the skb to QDisc with NETDEV_TX_BUSY for requeueing. Then the 
thread can only do the batching of the grant copy operations and 
releasing the skbs. And we can ditch a good part of the code ...

>
> 2) There are other drivers that could run into this kind of situation and
>     have similar concerns, therefore we should make sure we have a consistent
>     approach that such entities use to handle this problem.
>
> Part of the problem is that netif_carrier_off() only partially mimicks
> the situation.  It expresses the "transmitter is down so packets
> aren't going onto the wire" part, which keeps the watchdog from
> spitting out log messages ever time it fires.  But it doesn't deal
> with packet freeing policy meanwhile, which I guess is the part that
> this patch series is largely trying to address.
>
> Thanks.
>
