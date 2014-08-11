From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net v2 2/3] xen-netback: don't stop dealloc
 kthread too early
Date: Mon, 11 Aug 2014 16:23:28 +0100
Message-ID: <53E8DFF0.8040702@citrix.com>
References: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com>	<1407515833-2550-3-git-send-email-wei.liu2@citrix.com>	<53E8B2A4.9070008@citrix.com>	<20140811134847.GF3249@zion.uk.xensource.com>	<53E8CBF5.1030600@citrix.com> <53E8CF95.5050209@citrix.com> <20140811144440.GJ3249@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xen.org>
To: Wei Liu <wei.liu2@citrix.com>, Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:57009 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753968AbaHKPXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2014 11:23:30 -0400
In-Reply-To: <20140811144440.GJ3249@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/14 15:44, Wei Liu wrote:
> On Mon, Aug 11, 2014 at 03:13:41PM +0100, Zoltan Kiss wrote:
> [...]
>>> And cleaning it up a bit (the while() could be a for(;;)).
>>
>> I would recommend this:
>> ---
>> @@ -2066,7 +2066,7 @@ int xenvif_dealloc_kthread(void *data)
>>  		wait_event_interruptible(queue->dealloc_wq,
>>  					 tx_dealloc_work_todo(queue) ||
>>  					 kthread_should_stop());
>> -		if (kthread_should_stop())
>> +		if (kthread_should_stop() && !atomic_read(&queue->inflight_packets))
>>  			break;
>>  
>>  		xenvif_tx_dealloc_action(queue);
>> ---
>> If kthread_stop called, this will keep the main loop running until all callbacks are called.
>> Then it proceeds to the exit branch, otherwise doesn't disrupt normal operation.
> 
> This snippet lacks change to while().
> 
> I would generally go for a shorter solution if the code is
> self-explanatory.
> 
> @@ -2078,21 +2066,19 @@ int xenvif_dealloc_kthread(void *data)
>  {
>         struct xenvif_queue *queue = data;
>  
> -       while (!kthread_should_stop()) {
> +       for (;;) {
>                 wait_event_interruptible(queue->dealloc_wq,
>                                          tx_dealloc_work_todo(queue) ||
>                                          kthread_should_stop());

This will never sleep if the thread is being stopped when there are
packets in flight.

> -               if (kthread_should_stop())
> +               if (kthread_should_stop() &&
> +                   !atomic_read(&queue->inflight_packets) &&
> +                   !tx_dealloc_work_todo(queue))
>                         break;

Moving the final dealloc into the loop adds a cond_resched() call.  This
is harmless but not really necessary when the thread is about to stop.

>  
>                 xenvif_tx_dealloc_action(queue);
>                 cond_resched();
>         }
>  
> -       /* Unmap anything remaining*/
> -       if (tx_dealloc_work_todo(queue))
> -               xenvif_tx_dealloc_action(queue);
> -
>         return 0;
>  }

David
