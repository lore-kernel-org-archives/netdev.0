From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [kvm-devel] [PATCH resent] virtio_net: Fix stalled inbound trafficon early packets
Date: Tue, 11 Dec 2007 14:19:52 +0100
Message-ID: <200712111419.52880.borntraeger@de.ibm.com>
References: <200712111242.28843.borntraeger@de.ibm.com> <475E8716.2010500@qumranet.com> <475E892D.9060400@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	kvm-devel <kvm-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: dor.laor@qumranet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:54628 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbXLKNT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 08:19:58 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id lBBDJtLf237674
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 13:19:56 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBBDJtB23006542
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 14:19:55 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBBDJsAU019646
	for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 14:19:55 +0100
In-Reply-To: <475E892D.9060400@qumranet.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2nd try. I somehow enable html on the last post

Dor Laor wrote:
> Christian Borntraeger wrote:
>>
>> Hello Rusty,
>>
>> while implementing and testing virtio on s390 I found a problem in
>> virtio_net: The current virtio_net driver has a startup race, which
>> prevents any incoming traffic:
>>
>> If try_fill_recv submits buffers to the host system data might be
>> filled in and an interrupt is sent, before napi_enable finishes.
>> In that case the interrupt will kick skb_recv_done which will then
>> call netif_rx_schedule. netif_rx_schedule checks, if NAPI_STATE_SCHED
>> is set - which is not as we did not run napi_enable. No poll routine
>> is scheduled. Furthermore, skb_recv_done returns false, we disables
>> interrupts for this device.
>>
>> One solution is the enable napi before inbound buffer are available.
>>
> But then you might get recv interrupt without a buffer.

If I look at the current implementation (lguest) no interrupt is sent if
there is not buffer available, no?
On the other hand, if the host does send an interrupt when no buffer is
available, this is also no problem. Looking at virtnet_poll, it seems it
can cope with an empty ring. 

> The way other physical NICs doing it is by dis/en/abling interrupt 
> using registers (look at e1000).
> I suggest we can export add_status and use the original code but
> before enabling napi add a call to add_status(dev, 
> VIRTIO_CONFIG_DEV_OPEN).
> The host won't trigger an irq until it sees the above.

That would also work. We already have VRING_AVAIL_F_NO_INTERRUPT in
virtio_ring.c - maybe we can use that. Its hidden in callback and
restart handling, what about adding an explicit startup?
>
> BTW: Rusty is on vacation and that's probably the reason he didn't 
> respond.
> Regards,
> Dor.

Ok, didnt know that. At the moment I can live with my private patch
while we work on a final solution. Meanwhile I will try to debug virtio
on SMP guests - I still see some strange races on our test system. (But
block and net is now working on s390 and can cope with medium load. )

Christian


