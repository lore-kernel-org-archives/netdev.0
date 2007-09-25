From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] RE: [PATCH 1/4] [NET_SCHED] explict hold dev tx lock
Date: Tue, 25 Sep 2007 09:08:54 -0400
Message-ID: <1190725734.4264.97.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
	<1190570205.4256.56.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903A51122@orsmsx414.amr.corp.intel.com>
	<1190674298.4264.24.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903A51462@orsmsx414.amr.corp.intel.com>
	<1190677099.4264.37.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903A5151B@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, kumarkr@linux.ibm.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com, mcarlson@broadcom.com,
	kaber@trash.net, randy.dunlap@oracle.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903A5151B@orsmsx414.amr.corp.intel.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-24-09 at 16:47 -0700, Waskiewicz Jr, Peter P wrote:

> We should make sure we're symmetric with the locking on enqueue to
> dequeue.  If we use the single device queue lock on enqueue, then
> dequeue will also need to check that lock in addition to the individual
> queue lock.  The details of this are more trivial than the actual
> dequeue to make it efficient though.

It would be interesting to observe the performance implications.

> The dequeue locking would be pushed into the qdisc itself.  This is how
> I had it originally, and it did make the code more complex, but it was
> successful at breaking the heavily-contended queue_lock apart.  I have a
> subqueue structure right now in netdev, which only has queue_state (for
> netif_{start|stop}_subqueue).  This state is checked in sch_prio right
> now in the dequeue for both prio and rr.  My approach is to add a
> queue_lock in that struct, so each queue allocated by the driver would
> have a lock per queue.  Then in dequeue, that lock would be taken when
> the skb is about to be dequeued.

more locks implies degraded performance. If only one processor can enter
that region, presumably after acquiring the outer lock , why this
secondary lock per queue?

> The skb->queue_mapping field also maps directly to the queue index
> itself, so it can be unlocked easily outside of the context of the
> dequeue function.  The policy would be to use a spin_trylock() in
> dequeue, so that dequeue can still do work if enqueue or another dequeue
> is busy.  

So there could be a parallel cpu dequeueing at the same time?
Wouldnt this have implications depending on what the scheduling
algorithm used? If for example i was doing priority queueing i would
want to make sure the highest priority is being dequeued first AND by
all means goes out first to the driver; i dont want a parallell cpu
dequeing a lower prio packet at the same time.

> And the allocation of qdisc queues to device queues is assumed
> to be one-to-one (that's how the qdisc behaves now).

Ok, that brings back the discussion we had; my thinking was something
like dev->hard_prep_xmit() would select the ring and i think you
staticly already map the ring to a qdisc queue. So i dont think 
dev->hard_prep_xmit() is useful to you.
In any case, there is nothing the batching patches do that interfere or
prevent you from going the path you intend to. instead of dequeueing one
packet, you dequeue several and instead of sending to the driver one
packet, you send several. And using the xmit_win, you should never ever
have to requeue.

cheers,
jamal
