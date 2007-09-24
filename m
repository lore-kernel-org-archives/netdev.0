From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/4] [NET_SCHED] explict hold dev tx lock
Date: Mon, 24 Sep 2007 16:47:06 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903A5151B@orsmsx414.amr.corp.intel.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com> <20070916.161748.48388692.davem@davemloft.net> <1189988958.4230.55.camel@localhost>  <1190569987.4256.52.camel@localhost> <1190570205.4256.56.camel@localhost> <D5C1322C3E673F459512FB59E0DDC32903A51122@orsmsx414.amr.corp.intel.com> <1190674298.4264.24.camel@localhost> <D5C1322C3E673F459512FB59E0DDC32903A51462@orsmsx414.amr.corp.intel.com> <1190677099.4264.37.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <krkumar2@in.ibm.com>,
	<johnpol@2ka.mipt.ru>, <herbert@gondor.apana.org.au>,
	<kaber@trash.net>, <shemminger@linux-foundation.org>,
	<jagana@us.ibm.com>, <Robert.Olsson@data.slu.se>,
	<rick.jones2@hp.com>, <xma@us.ibm.com>, <gaagaan@gmail.com>,
	<netdev@vger.kernel.org>, <rdreier@cisco.com>,
	<mcarlson@broadcom.com>, <jeff@garzik.org>, <mchan@broadcom.com>,
	<general@lists.openfabrics.org>, <kumarkr@linux.ibm.com>,
	<tgraf@suug.ch>, <randy.dunlap@oracle.com>, <sri@us.ibm.com>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28638 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758509AbXIXXrD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 19:47:03 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1190677099.4264.37.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Mon, 2007-24-09 at 15:57 -0700, Waskiewicz Jr, Peter P wrote:
> 
> > I've looked at that as a candidate to use.  The lock for 
> enqueue would 
> > be needed when actually placing the skb into the 
> appropriate software 
> > queue for the qdisc, so it'd be quick.
> 
> The enqueue is easy to comprehend. The single device queue 
> lock should suffice. The dequeue is interesting:

We should make sure we're symmetric with the locking on enqueue to
dequeue.  If we use the single device queue lock on enqueue, then
dequeue will also need to check that lock in addition to the individual
queue lock.  The details of this are more trivial than the actual
dequeue to make it efficient though.

> Maybe you can point me to some doc or describe to me the 
> dequeue aspect; are you planning to have an array of txlocks 
> per, one per ring?
> How is the policy to define the qdisc queues locked/mapped to 
> tx rings? 

The dequeue locking would be pushed into the qdisc itself.  This is how
I had it originally, and it did make the code more complex, but it was
successful at breaking the heavily-contended queue_lock apart.  I have a
subqueue structure right now in netdev, which only has queue_state (for
netif_{start|stop}_subqueue).  This state is checked in sch_prio right
now in the dequeue for both prio and rr.  My approach is to add a
queue_lock in that struct, so each queue allocated by the driver would
have a lock per queue.  Then in dequeue, that lock would be taken when
the skb is about to be dequeued.

The skb->queue_mapping field also maps directly to the queue index
itself, so it can be unlocked easily outside of the context of the
dequeue function.  The policy would be to use a spin_trylock() in
dequeue, so that dequeue can still do work if enqueue or another dequeue
is busy.  And the allocation of qdisc queues to device queues is assumed
to be one-to-one (that's how the qdisc behaves now).

I really just need to put my nose to the grindstone and get the patches
together and to the list...stay tuned.

Thanks,
-PJ Waskiewicz
