From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 08 Oct 2007 16:48:50 -0400
Message-ID: <1191876530.4373.58.camel@localhost>
References: <1191868010.4335.33.camel@localhost>
	 <D5C1322C3E673F459512FB59E0DDC32903BC1234@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	mcarlson@broadcom.com, jeff@garzik.org, mchan@broadcom.com,
	general@lists.openfabrics.org, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:10092 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223AbXJHUs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 16:48:57 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1434599wxd
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2007 13:48:56 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903BC1234@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-08-10 at 12:46 -0700, Waskiewicz Jr, Peter P wrote:

> 	I still have concerns how this will work with Tx multiqueue.
> The way the batching code looks right now, you will probably send a
> batch of skb's from multiple bands from PRIO or RR to the driver.  For
> non-Tx multiqueue drivers, this is fine.  For Tx multiqueue drivers,
> this isn't fine, since the Tx ring is selected by the value of
> skb->queue_mapping (set by the qdisc on {prio|rr}_classify()).  If the
> whole batch comes in with different queue_mappings, this could prove to
> be an interesting issue.

true, that needs some resolution. Heres a hand-waving thought:
Assuming all packets of a specific map end up in the same qdiscn queue,
it seems feasible to ask the qdisc scheduler to give us enough packages
(ive seen people use that terms to refer to packets) for each hardware
ring's available space. With the patches i posted, i do that via
dev->xmit_win that assumes only one view of the driver; essentially a
single ring.  
If that is doable, then it is up to the driver to say
"i have space for 5 in ring[0], 10 in ring[1] 0 in ring[2]" based on
what scheduling scheme the driver implements - the dev->blist can stay
the same. Its a handwave, so there may be issues there and there could
be better ways to handle this.

Note: The other issue that needs resolving that i raised earlier was in
regards to multiqueue running on multiple cpus servicing different rings
concurently. 

> 	Now I see in the driver HOWTO you recently sent that the driver
> will be expected to loop over the list and call it's ->hard_start_xmit()
> for each skb.  

It's the core that does that, not the driver; the driver continues to
use ->hard_start_xmit() (albeit modified one). The idea is not to have
many new interfaces.

> I think that should be fine for multiqueue, I just wanted
> to see if you had any thoughts on how it should work, any performance
> issues you can see (I can't think of any).  Since the batching feature
> and Tx multiqueue are very new features, I'd like to make sure we can
> think of any possible issues with them coexisting before they are both
> mainline.

Isnt multiqueue mainline already?

> 	Looking ahead for multiqueue, I'm still working on the per-queue
> lock implementation for multiqueue, which I know will not work with
> batching as it's designed today.  

The point behind batching is to reduce the cost of the locks by
amortizing across the locks. Even better if one can, they should get rid
of locks. Remind me, why do you need the per-queuemap lock? And is it
needed from the enqueuing side too? Maybe lets start there to help me
understand things?

> I'm still not sure how to handle this,
> because it really would require the batch you send to have the same
> queue_mapping in each skb, so you're grabbing the correct queue_lock.

Sure, that is doable if the driver can set a per queue_mapping xmit_win
and the qdisc can be taught to say "give me packets for queue_mapping X"

> Or, we could have the core grab all the queue locks for each
> skb->queue_mapping represented in the batch.  That would block another
> batch though if it had any of those queues in it's next batch before the
> first one completed.  Thoughts?

I am not understanding the desire to have locks on a per-queuemap. I
think the single queuelock we have today should suffice. If the intent
is to have concurent cpus running to each hardware ring, then this is
what i questioned earlier whether it was the right thing to do(very top
of email where i mention it as "other issue"). 

cheers,
jamal


