From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/2] NET: Multiple queue network device support
Date: Mon, 12 Mar 2007 13:21:16 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329027335CC@orsmsx414.amr.corp.intel.com>
References: <20070312085802.GA1664@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"David Miller" <davem@davemloft.net>,
	"Garzik, Jeff" <jgarzik@pobox.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Jarek Poplawski" <jarkao2@o2.pl>, "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:19848 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752859AbXCLUVU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 16:21:20 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070312085802.GA1664@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> From: Jarek Poplawski [mailto:jarkao2@o2.pl] 
> Sent: Monday, March 12, 2007 1:58 AM
> To: Thomas Graf
> Cc: Kok, Auke-jan H; David Miller; Garzik, Jeff; 
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; 
> Waskiewicz Jr, Peter P; Brandeburg, Jesse; Kok, Auke; Ronciak, John
> Subject: Re: [PATCH 1/2] NET: Multiple queue network device support
> 
> On 09-03-2007 14:40, Thomas Graf wrote:
> > * Kok, Auke <auke-jan.h.kok@intel.com> 2007-02-08 16:09
> >> diff --git a/net/core/dev.c b/net/core/dev.c index 
> 455d589..42b635c 
> >> 100644
> >> --- a/net/core/dev.c
> >> +++ b/net/core/dev.c
> >> @@ -1477,6 +1477,49 @@ gso:
> >>  	skb->tc_verd = SET_TC_AT(skb->tc_verd,AT_EGRESS);
> >>  #endif
> >>  	if (q->enqueue) {
> >> +#ifdef CONFIG_NET_MULTI_QUEUE_DEVICE
> >> +		int queue_index;
> >> +		/* If we're a multi-queue device, get a queue 
> index to lock */
> >> +		if (netif_is_multiqueue(dev))
> >> +		{
> >> +			/* Get the queue index and lock it. */
> >> +			if (likely(q->ops->map_queue)) {
> >> +				queue_index = q->ops->map_queue(skb, q);
> >> +				
> spin_lock(&dev->egress_subqueue[queue_index].queue_lock);
> >> +				rc = q->enqueue(skb, q);
> 
> I'm not sure Dave Miller thought about this place, when he 
> proposed to save the mapping, but I think this could be not 
> enough. This place is racy: ->map_queue() is called 2 times 
> and with some filters (and
> policies/actions) results could differ. And of course the 
> subqueue lock doesn't prevent any filter from a config change 
> in the meantime.
> 
> After second reading of this patch I have doubts it's the 
> proper way to solve the problem: there are many subqueues but 
> we need a top queue (prio here) to mange them, anyway. So, 
> why not to build this functionality directly into the queue? 
> There is no difference for a device if skbs are going from 
> the subqueue or a class, it is only interested in the mapping 
> result and a possibility to stop and start a subqueue and to 
> query its status. All this could be done by adding the 
> callbacks directly to any classful scheduler or, if not 
> enough, to write some specialized qdisc based on prio. The 
> possibility to lock only a subqueue instead of a queue could 
> be analized independently - current proposal doesn't solve 
> this anyway.
> 
> Regards,
> Jarek P.
> 

Thanks again for the feedback.  Given some discussions I had last week
in the office and the general feedback here, I'm going to remove the new
per-queue locking and leave the start/stop functions for each queue and
combine entry points for hard_start_xmit().  I'll get this out asap for
review once it's been tested here.  If we see issues in the future with
lock contention on the queues, we can revisit the per-queue locking.

Cheers,
-PJ Waskiewicz
