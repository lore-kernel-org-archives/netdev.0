From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: NAPI rescheduling and the delay caused by it
Date: Wed, 4 Dec 2013 21:23:23 +0000
Message-ID: <529F9D4B.1020208@citrix.com>
References: <529F7A87.5080303@citrix.com> <1386189718.30495.131.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	Malcolm Crossley <malcolm.crossley@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:18352 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753210Ab3LDVX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 16:23:27 -0500
In-Reply-To: <1386189718.30495.131.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/13 20:41, Eric Dumazet wrote:
> On Wed, 2013-12-04 at 18:55 +0000, Zoltan Kiss wrote:
>
>> So, my questions are:
>> - why is NAPI rescheduled on an another CPU?
>> - why does it cause a 3-4 milisec delay?
>
> NAPI can not be scheduled on another cpu.
>
> But at the time of napi_schedule() call, napi_struct can be already be
> scheduled by another cpu.
>
> ( NAPI_STATE_SCHED bit already set)
> So I would say something made the 'other' cpu non responsive fast enough
> to softirq events being ready for service.
>
> (Another wakeup happened 3-4 millisec later)
Oh, thanks! I forgot to mention, I have my grant mapping patches 
applied. The callback when the previous packet is sent to the another 
vif schedules the NAPI instance on that other CPU. But it's still not 
clear why it takes so long to serve that softirq!


> Really, I suspect your usage of netif_wake_queue() is simply wrong.
>
> Check why we have netif_rx() and netif_rx_ni() variants.
>
> And ask yourself if xenvif_notify_tx_completion() is correct, being
> called from process context.
So, at the moment we use netif_wake_queue to notify the stack that it 
can call xenvif_start_xmit, the thread is ready to accept new packets 
for transmission. It is called when we get an interrupt from the 
frontend (it marks it made room in the ring), and from 
xenvif_notify_tx_completion at the end of the thread. The latter checks 
if queueing were stopped in the meantime, and see if the guest made 
space after our recent transmission.
I see netif_rx_ni makes sure the softirq is executed, but I'm not sure I 
get how is it related to wake_queue. Can you explain a bit more?

Thanks,

Zoli
