From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next 14/15] i40e: ignore skb->xmit_more when deciding to set
 RS bit
Date: Mon, 9 Oct 2017 09:28:15 -0700
Message-ID: <CAKgT0UfZEU++hZkpp1NixYxj=2STfXX-5opz2BoEhG1SfUA5pQ@mail.gmail.com>
References: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
 <20171006175727.868-15-jeffrey.t.kirsher@intel.com> <063D6719AE5E284EB5DD2968C1650D6DD008D373@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Jacob Keller <jacob.e.keller@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:52118 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755279AbdJIQ2S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 12:28:18 -0400
Received: by mail-qt0-f177.google.com with SMTP id q4so44164485qtq.8
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 09:28:18 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD008D373@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 9, 2017 at 2:07 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Jeff Kirsher
>> Sent: 06 October 2017 18:57
>> From: Jacob Keller <jacob.e.keller@intel.com>
>>
>> Since commit 6a7fded776a7 ("i40e: Fix RS bit update in Tx path and
>> disable force WB workaround") we've tried to "optimize" setting the
>> RS bit based around skb->xmit_more. This same logic was refactored
>> in commit 1dc8b538795f ("i40e: Reorder logic for coalescing RS bits"),
>> but ultimately was not functionally changed.
>
> I've tried to understand the above, but without definitions of WB
> and RS and the '4-ness' of something it is quite difficult.
>
> I THINK this is all about telling the hardware there is a packet
> in the ring to transmit?
>
> I don't understand the 4-ness. Linux requires that the hardware
> be notified of a single packet transmit, and that the 'transmit
> complete' also be notified in 'a timely manner' for a single packet.

So to clarify some of this. The RS is short for Report Status. It
tells the hardware that when it has completed the descriptor it should
trigger a write back, aka WB.

The 4-ness is because each descriptor is 16 bytes, so if we write back
once every 4 descriptors that is one 64B cache line which is much
better for most platforms performance wise.

> skb->xmit_more ought to be usable to optimise both of these
> (assuming it isn't a lie).

Actually it leads to issues if we hold off for too long. If we are
busy dequeueing a long list, and the Tx queue has gone empty then we
are stalling Tx without need to do so. We need to be regularly
notifying the device that it has buffers available to transmit which
is what xmit_more is good for. However in addition the hardware needs
to notify us regularly that there are buffers ready to clean which it
isn't necessarily so useful for, especially if  are filling the entire
ring and only providing one notification to the driver that there are
buffers ready since we can defer the Tx interrupt for too long.

What Jake is trying to fix here is to prevent us from generating what
looks like a square wave in terms of throughput. Essentially the
current behavior that is being seen is that all the buffers in the
ring either belong to software, or belong to hardware. It is best for
us to have this split half and half so that the hardware has buffers
to transmit and software has buffers to clean and enqueue new buffers
onto.

> The driver would need to ensure a ring full of messages isn't
> generated without either wakeup - but that might be 128 frames.

That is what is happening here. Basically we are guaranteeing
writebacks are occurring on a regular basis instead of in large
bursts.

> FWIW on the systems I have PCIe writes are relatively cheap
> (reads are slow). So different counts would be appropriate
> for delaying doorbell writes and requesting completion interrupts.
>
>         David

The doorbell writes are still being delayed the same amount with this
patch. The only thing that was split out was the device write backs
are now occurring on a more regular basis instead of being held off
until a much larger set is handled.

- Alex
