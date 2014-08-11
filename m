From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH net v2 2/3] xen-netback: don't stop dealloc
 kthread too early
Date: Mon, 11 Aug 2014 15:13:41 +0100
Message-ID: <53E8CF95.5050209@citrix.com>
References: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com> <1407515833-2550-3-git-send-email-wei.liu2@citrix.com> <53E8B2A4.9070008@citrix.com> <20140811134847.GF3249@zion.uk.xensource.com> <53E8CBF5.1030600@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	Ian Campbell <ian.campbell@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:11843 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753491AbaHKONz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2014 10:13:55 -0400
In-Reply-To: <53E8CBF5.1030600@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/14 14:58, David Vrabel wrote:
> On 11/08/14 14:48, Wei Liu wrote:
>> On Mon, Aug 11, 2014 at 01:10:12PM +0100, David Vrabel wrote:
>>> On 08/08/14 17:37, Wei Liu wrote:
>> [...]
>>>>   	if (tx_evtchn == rx_evtchn) {
>>>>   		/* feature-split-event-channels == 0 */
>>>> @@ -687,6 +700,9 @@ void xenvif_disconnect(struct xenvif *vif)
>>>>   			queue->task = NULL;
>>>>   		}
>>>>   
>>>> +		wait_event(queue->inflight_wq,
>>>> +			   atomic_read(&queue->inflight_packets) == 0);
>>>
>>> Just make the dealloc task not stop unless it has deallocated all
>>> outstanding requests.  There's no need for another wait queue here.
>>>
>>
>> Are you suggesting something like
>>
>>    while (atomic_read(&queue->inflight_packets) !=0)
>>    	schedule_timeout(SOME_TIMEOUT);
> 
> No. That would be awful!
> 
> Add the test to the kthread itself:
> 
> int xenvif_dealloc_kthread(void *data)
> {
> 	struct xenvif_queue *queue = data;
> 
> 	while (atomic_read(&queue->inflight_packets) > 0
>                 || !kthread_should_stop()) {
>              [...]
> 
> etc.
> 
> Although, the main loop is a bit confused, so I suggest adding:
> 
> static bool xenvif_dealloc_thread_should_stop(struct xenvif_queue *q)
> {
>      /* Dealloc thread must remain running if there are any inflight
>       * packets so it can properly dealloc them when they complete.
>       */
>      return atomic_read(&queue->inflight_packets) == 0
>          && kthread_should_stop();
> }
> 
> And cleaning it up a bit (the while() could be a for(;;)).

I would recommend this:
---
@@ -2066,7 +2066,7 @@ int xenvif_dealloc_kthread(void *data)
 		wait_event_interruptible(queue->dealloc_wq,
 					 tx_dealloc_work_todo(queue) ||
 					 kthread_should_stop());
-		if (kthread_should_stop())
+		if (kthread_should_stop() && !atomic_read(&queue->inflight_packets))
 			break;
 
 		xenvif_tx_dealloc_action(queue);
---
If kthread_stop called, this will keep the main loop running until all callbacks are called.
Then it proceeds to the exit branch, otherwise doesn't disrupt normal operation.
