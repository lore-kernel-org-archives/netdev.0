From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: interrupt moving and NAPI scheduling
Date: Thu, 15 May 2014 17:26:28 +0100
Message-ID: <5374EAB4.2000701@citrix.com>
References: <1395756505-21573-1-git-send-email-david.vrabel@citrix.com> <533195B6.5090305@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:62669 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751874AbaEOQ0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 12:26:40 -0400
In-Reply-To: <533195B6.5090305@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Let me bump this question: how does the kernel make sure that if an 
interrupt is moved away from CPU X to Y (e.g. by irqbalance), the NAPI 
instance already scheduled on CPU Y won't race with the interrupt? I 
mean the following scenario:

1. instance calls napi_complete on CPU X
2. that removes the instance from the list
3. interrupt happens on CPU Y
4. "!test_and_set_bit(NAPI_STATE_SCHED, &n->state)" fails, as the bit is 
still set
5. instance not added to the list therefore
6. napi_complete on CPU X clear the bit

My assumption is that when the interrupt moved, the kernel makes sure 
the NAPI instance won't get scheduled on the old CPU, but I'm not sure 
about it

On 25/03/14 14:41, Zoltan Kiss wrote:
> My idea was that the current code can't race with interrupt running on a
> different CPU, because if the interrupt was moved since the last
> napi_schedule (which scheduled NAPI on the same CPU as the interrupt),
> the kernel would make sure that the NAPI instance is moved along with
> it. However I couldn't find any trace of this in the kernel so far, but
> the current code actually works for me, even when I used a bash script
> to aggressively move the interrupts around while running.
> I've added David and Eric to the mailing, maybe they can quickly shed
> some light on this: how does the kernel make sure that if the interrupt
> is moved away from a CPU (e.g. by irqbalance), the NAPI instance already
> scheduled there won't race with it?
>
> Zoli
>
> On 25/03/14 14:08, David Vrabel wrote:
>> When the NAPI budget was not all used, xenvif_poll() would call
>> napi_complete() /after/ enabling the interrupt.  This resulted in a
>> race between the napi_complete() and the napi_schedule() in the
>> interrupt handler.  The use of local_irq_save/restore() avoided by
>> race iff the handler is running on the same CPU but not if it was
>> running on a different CPU.
>>
>> Fix this properly by calling napi_complete() before reenabling
>> interrupts (in the xenvif_check_rx_xenvif() call).
>>
>> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
>> ---
>>   drivers/net/xen-netback/interface.c |   28 ++--------------------------
>>   1 files changed, 2 insertions(+), 26 deletions(-)
>>
>> diff --git a/drivers/net/xen-netback/interface.c
>> b/drivers/net/xen-netback/interface.c
>> index 7669d49..ee322d9 100644
>> --- a/drivers/net/xen-netback/interface.c
>> +++ b/drivers/net/xen-netback/interface.c
>> @@ -65,32 +65,8 @@ static int xenvif_poll(struct napi_struct *napi,
>> int budget)
>>       work_done = xenvif_tx_action(vif, budget);
>>
>>       if (work_done < budget) {
>> -        int more_to_do = 0;
>> -        unsigned long flags;
>> -
>> -        /* It is necessary to disable IRQ before calling
>> -         * RING_HAS_UNCONSUMED_REQUESTS. Otherwise we might
>> -         * lose event from the frontend.
>> -         *
>> -         * Consider:
>> -         *   RING_HAS_UNCONSUMED_REQUESTS
>> -         *   <frontend generates event to trigger napi_schedule>
>> -         *   __napi_complete
>> -         *
>> -         * This handler is still in scheduled state so the
>> -         * event has no effect at all. After __napi_complete
>> -         * this handler is descheduled and cannot get
>> -         * scheduled again. We lose event in this case and the ring
>> -         * will be completely stalled.
>> -         */
>> -
>> -        local_irq_save(flags);
>> -
>> -        RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
>> -        if (!more_to_do)
>> -            __napi_complete(napi);
>> -
>> -        local_irq_restore(flags);
>> +        napi_complete(napi);
>> +        xenvif_check_rx_xenvif(vif);
>>       }
>>
>>       return work_done;
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
