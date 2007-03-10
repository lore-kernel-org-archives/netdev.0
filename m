From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/2] NET: Multiple queue network device support
Date: Sat, 10 Mar 2007 12:37:24 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC329026EA188@orsmsx414.amr.corp.intel.com>
References: <20070310023432.GJ521@postel.suug.ch>
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
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6199 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932224AbXCJUh2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2007 15:37:28 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20070310023432.GJ521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Thomas Graf [mailto:tgraf@suug.ch] 
> Sent: Friday, March 09, 2007 6:35 PM
> To: Waskiewicz Jr, Peter P
> Cc: Kok, Auke-jan H; David Miller; Garzik, Jeff; 
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; 
> Brandeburg, Jesse; Kok, Auke; Ronciak, John
> Subject: Re: [PATCH 1/2] NET: Multiple queue network device support
> 
> * Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> 
> 2007-03-09 15:27
> > That's the entire point of this extra locking.  enqueue() 
> is going to 
> > put an skb into a band somewhere that maps to some queue, 
> and there is 
> > no way to guarantee the skb I retrieve from dequeue() is headed for 
> > the same queue.  Therefore, I need to unlock the queue 
> after I finish 
> > enqueuing, since having that lock makes little sense to dequeue().
> > dequeue() will then grab *a* lock on a queue; it may be the 
> same one 
> > we had during enqueue(), but it may not be.  And the 
> placement of the 
> > unlock of that queue is exactly where it happens in non-multiqueue, 
> > which is right before the hard_start_xmit().
> 
> The lock is already unlocked after dequeue, from your prio_dequeue():
> 
>        if (netif_is_multiqueue(sch->dev)) {
>                queue = q->band2queue[prio];
>                if 
> (spin_trylock(&sch->dev->egress_subqueue[queue].queue_lock)) {
>                        qdisc = q->queues[prio];
>                        skb = qdisc->dequeue(qdisc);
>                        if (skb) {
>                                sch->q.qlen--;
>                                skb->priority = prio;
>                                
> spin_unlock(&sch->dev->egress_subqueue[queue].queue_lock);
>                                return skb;
>                        }
>                        
> spin_unlock(&sch->dev->egress_subqueue[queue].queue_lock);
>        }

Ok, now I see what's wrong.  Taking Dave M.'s recommendation to store
the queue mapping in the skb will let me unlock the queue when dequeue()
returns.  I'll fix this locking issue; thanks for the feedback and
persistent drilling into my thick head.

-PJ Waskiewicz
peter.p.waskiewicz.jr@intel.com
