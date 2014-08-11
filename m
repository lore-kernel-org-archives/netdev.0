From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net v2 2/3] xen-netback: don't stop dealloc
 kthread too early
Date: Mon, 11 Aug 2014 15:31:07 +0100
Message-ID: <20140811143107.GH3249@zion.uk.xensource.com>
References: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com>
 <1407515833-2550-3-git-send-email-wei.liu2@citrix.com>
 <53E8B2A4.9070008@citrix.com>
 <20140811134847.GF3249@zion.uk.xensource.com>
 <53E8CBF5.1030600@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, Ian Campbell <ian.campbell@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:50945 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442AbaHKObd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 10:31:33 -0400
Content-Disposition: inline
In-Reply-To: <53E8CBF5.1030600@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2014 at 02:58:13PM +0100, David Vrabel wrote:
> On 11/08/14 14:48, Wei Liu wrote:
> > On Mon, Aug 11, 2014 at 01:10:12PM +0100, David Vrabel wrote:
> >> On 08/08/14 17:37, Wei Liu wrote:
> > [...]
> >>>  	if (tx_evtchn == rx_evtchn) {
> >>>  		/* feature-split-event-channels == 0 */
> >>> @@ -687,6 +700,9 @@ void xenvif_disconnect(struct xenvif *vif)
> >>>  			queue->task = NULL;
> >>>  		}
> >>>  
> >>> +		wait_event(queue->inflight_wq,
> >>> +			   atomic_read(&queue->inflight_packets) == 0);
> >>
> >> Just make the dealloc task not stop unless it has deallocated all
> >> outstanding requests.  There's no need for another wait queue here.
> >>
> > 
> > Are you suggesting something like
> > 
> >   while (atomic_read(&queue->inflight_packets) !=0)
> >   	schedule_timeout(SOME_TIMEOUT);
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
>                || !kthread_should_stop()) {
>             [...]
> 
> etc.
> 
> Although, the main loop is a bit confused, so I suggest adding:
> 
> static bool xenvif_dealloc_thread_should_stop(struct xenvif_queue *q)
> {
>     /* Dealloc thread must remain running if there are any inflight
>      * packets so it can properly dealloc them when they complete.
>      */
>     return atomic_read(&queue->inflight_packets) == 0
>         && kthread_should_stop();
> }
> 
> And cleaning it up a bit (the while() could be a for(;;)).
> 

Unfortunately this approach is bogus. If xenbus thread is not blocked it
can free up various resources while dealloc thread is running -- queue
can be gone under dealloc thread's feet.

Wei.

> David
