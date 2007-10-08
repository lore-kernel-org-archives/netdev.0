From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: [ofa-general] RE: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 8 Oct 2007 15:33:42 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com>
References: <1191868010.4335.33.camel@localhost>
	<D5C1322C3E673F459512FB59E0DDC32903BC1234@orsmsx414.amr.corp.intel.com>
	<1191876530.4373.58.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com, kaber@trash.net,
	randy.dunlap@oracle.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>
To: <hadi@cyberus.ca>
Return-path: <general-bounces@lists.openfabrics.org>
Content-class: urn:content-classes:message
In-Reply-To: <1191876530.4373.58.camel@localhost>
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

> true, that needs some resolution. Heres a hand-waving thought:
> Assuming all packets of a specific map end up in the same=20
> qdiscn queue, it seems feasible to ask the qdisc scheduler to=20
> give us enough packages (ive seen people use that terms to=20
> refer to packets) for each hardware ring's available space.=20
> With the patches i posted, i do that via
> dev->xmit_win that assumes only one view of the driver; essentially a
> single ring. =20
> If that is doable, then it is up to the driver to say "i have=20
> space for 5 in ring[0], 10 in ring[1] 0 in ring[2]" based on=20
> what scheduling scheme the driver implements - the dev->blist=20
> can stay the same. Its a handwave, so there may be issues=20
> there and there could be better ways to handle this.
>=20
> Note: The other issue that needs resolving that i raised=20
> earlier was in regards to multiqueue running on multiple cpus=20
> servicing different rings concurently.=20

I can see the qdisc being modified to send batches per queue_mapping.
This shouldn't be too difficult, and if we had the xmit_win per queue
(in the subqueue struct like Dave pointed out).

Addressing your note/issue with different rings being services
concurrently: I'd like to remove the QDISC_RUNNING bit from the global
device; with Tx multiqueue, this bit should be set on each queue (if at
all), allowing multiple Tx rings to be loaded simultaneously.  The
biggest issue today with the multiqueue implementation is the global
queue_lock.  I see it being a hot source of contention in my testing; my
setup is a 8-core machine (dual quad-core procs) with a 10GbE NIC, using
8 Tx and 8 Rx queues.  On transmit, when loading all 8 queues, the
enqueue/dequeue are hitting that lock quite a bit for the whole device.
I really think that the queue_lock should join the queue_state, so the
device no longer manages the top-level state (since we're operating
per-queue instead of per-device).

> It's the core that does that, not the driver; the driver=20
> continues to use ->hard_start_xmit() (albeit modified one).=20
> The idea is not to have many new interfaces.

I'll look closer at this, since I think I confused myself.

> Isnt multiqueue mainline already?

Well, it's in 2.6.23-rc*.  I imagine it won't see much action though
until 2.6.24, since people will be porting drivers during that time.
Plus having the native Rx multiqueue w/NAPI code in 2.6.24 makes sense
to have Tx multiqueue at that time.

> The point behind batching is to reduce the cost of the locks=20
> by amortizing across the locks. Even better if one can, they=20
> should get rid of locks. Remind me, why do you need the=20
> per-queuemap lock? And is it needed from the enqueuing side=20
> too? Maybe lets start there to help me understand things?

The multiqueue implementation today enforces the number of qdisc bands
(RR or PRIO) to be equal to the number of Tx rings your hardware/driver
is supporting.  Therefore, the queue_lock and queue_state in the kernel
directly relate to the qdisc band management.  If the queue stops from
the driver, then the qdisc won't try to dequeue from the band.  What I'm
working on is to move the lock there too, so I can lock the queue when I
enqueue (protect the band from multiple sources modifying the skb
chain), and lock it when I dequeue.  This is purely for concurrency of
adding/popping skb's from the qdisc queues.  Right now, we take the
whole global lock to add and remove skb's.  This is the next logical
step for separating the queue dependancy on each other.  Please let me
know if this doesn't make sense, or if you have any questions at all
about my reasoning.  I agree that this is where we should be on the same
page before moving onto anything else in this discussion.  :)

> Sure, that is doable if the driver can set a per=20
> queue_mapping xmit_win and the qdisc can be taught to say=20
> "give me packets for queue_mapping X"

Yes, I like this idea very much.  Do that, modify the qdisc to send in
chunks from a queue, and the problem should be solved.

I will try and find some additional cycles to get my patches completely
working, and send them.  It'd be easier I think to see what's going on
if I did that.  I'll also try to make them work with the ideas of
xmit_win per queue and batched queue qdisc sends.  Stay tuned...

Thanks Jamal,

-PJ Waskiewicz
<peter.p.waskiewicz.jr@intel.com>
