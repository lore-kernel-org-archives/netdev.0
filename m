From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net v2 2/3] xen-netback: don't stop dealloc
 kthread too early
Date: Mon, 11 Aug 2014 14:58:13 +0100
Message-ID: <53E8CBF5.1030600@citrix.com>
References: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com> <1407515833-2550-3-git-send-email-wei.liu2@citrix.com> <53E8B2A4.9070008@citrix.com> <20140811134847.GF3249@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:63500 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753544AbaHKN6o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2014 09:58:44 -0400
In-Reply-To: <20140811134847.GF3249@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/14 14:48, Wei Liu wrote:
> On Mon, Aug 11, 2014 at 01:10:12PM +0100, David Vrabel wrote:
>> On 08/08/14 17:37, Wei Liu wrote:
> [...]
>>>  	if (tx_evtchn == rx_evtchn) {
>>>  		/* feature-split-event-channels == 0 */
>>> @@ -687,6 +700,9 @@ void xenvif_disconnect(struct xenvif *vif)
>>>  			queue->task = NULL;
>>>  		}
>>>  
>>> +		wait_event(queue->inflight_wq,
>>> +			   atomic_read(&queue->inflight_packets) == 0);
>>
>> Just make the dealloc task not stop unless it has deallocated all
>> outstanding requests.  There's no need for another wait queue here.
>>
> 
> Are you suggesting something like
> 
>   while (atomic_read(&queue->inflight_packets) !=0)
>   	schedule_timeout(SOME_TIMEOUT);

No. That would be awful!

Add the test to the kthread itself:

int xenvif_dealloc_kthread(void *data)
{
	struct xenvif_queue *queue = data;

	while (atomic_read(&queue->inflight_packets) > 0
               || !kthread_should_stop()) {
            [...]

etc.

Although, the main loop is a bit confused, so I suggest adding:

static bool xenvif_dealloc_thread_should_stop(struct xenvif_queue *q)
{
    /* Dealloc thread must remain running if there are any inflight
     * packets so it can properly dealloc them when they complete.
     */
    return atomic_read(&queue->inflight_packets) == 0
        && kthread_should_stop();
}

And cleaning it up a bit (the while() could be a for(;;)).

David
