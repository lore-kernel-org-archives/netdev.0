From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH V6 net-next 1/5] xen-netback: Factor queue-specific data
 into queue struct.
Date: Mon, 17 Mar 2014 12:19:20 +0000
Message-ID: <1395058760.7428.18.camel@kazak.uk.xensource.com>
References: <1393847269-6981-1-git-send-email-andrew.bennieston@citrix.com>
		 <1393847269-6981-2-git-send-email-andrew.bennieston@citrix.com>
	 <1394812505.6442.128.camel@kazak.uk.xensource.com>
	 <5326E23F.8050304@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>
To: Andrew Bennieston <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:8344 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932767AbaCQMTX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:19:23 -0400
In-Reply-To: <5326E23F.8050304@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-17 at 11:53 +0000, Andrew Bennieston wrote:
> On 14/03/14 15:55, Ian Campbell wrote:
> > On Mon, 2014-03-03 at 11:47 +0000, Andrew J. Bennieston wrote:
> >> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> >>
> >> In preparation for multi-queue support in xen-netback, move the
> >> queue-specific data from struct xenvif into struct xenvif_queue, a=
nd
> >> update the rest of the code to use this.
> >>
> >> Also[...]
> >>
> >> Finally,[...]
> >
> > This is already quite a big patch, and I don't think the commit log
> > covers everything it changes/refactors, does it?
> >
> > It's always a good idea to break these things apart but in particul=
ar
> > separating the mechanical stuff (s/vif/queue/g) from the non-mechan=
ical
> > stuff, since the mechanical stuff is essentially trivial to review =
and
> > getting it out the way makes the non-mechanical stuff much easier t=
o
> > check (or even spot).
> >
>=20
> The vast majority of changes in this patch are s/vif/queue/g. The res=
t
> are related changes, such as inserting loops over queues, and moving
> queue-specific initialisation away from the vif-wide initialisation, =
so
> that it can be done once per queue.
>=20
> I consider these things to be logically related and definitely within
> the purview of this single patch. Without doing this, it is difficult=
 to
> get a patch that results in something that even compiles, without
> putting in a bunch of placeholder code that will be removed in the ve=
ry
> next patch.

Well, I'd have introduced a single xenvif_queue instance without tellin=
g
the core network stuff we were doing multiqueue yet which would allow
all the function arguments etc to be changed mechanically without doing
a lot of the other work at the same time, like refactoring the carrier
handling or even adding the loops. But what's done is done now.

>=20
> When I split this feature into multiple patches, I took care to group
> as little as possible into this first patch (and the same for netfron=
t).
> It is still a large patch, but by my count most of this is a simple
> replacement of vif with queue...
>=20
> A first-order approximation, searching for line pairs where the first
> has 'vif' and the second has 'queue', yields:
>=20
> =E2=9E=9C  xen-netback git:(saturn) git show HEAD~4 | grep -A 1 vif |=
 grep queue=20
> | wc -l
> 380
>=20
> i.e. 760 (=3D380*2) lines out of the 2240 (~ 40%) are trivial replace=
ments
> of vif with queue, and this is not counting multi-line replacements, =
of
> which there are many. What remains is mostly adding loops over these
> queues. This could, in principle, be done in a second patch, but the
> impact of this is small.

Actually, the readability/reviewability impact is quite high IMHO.

>=20
> >
> >>
> >> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
> >> Reviewed-by: Paul Durrant <paul.durrant@citrix.com>
> >> ---
> >>   drivers/net/xen-netback/common.h    |   85 ++++--
> >>   drivers/net/xen-netback/interface.c |  329 ++++++++++++++-------=
-
> >>   drivers/net/xen-netback/netback.c   |  530 ++++++++++++++++++---=
--------------
> >>   drivers/net/xen-netback/xenbus.c    |   87 ++++--
> >>   4 files changed, 608 insertions(+), 423 deletions(-)
> >>
> >> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-ne=
tback/common.h
> >> index ae413a2..4176539 100644
> >> --- a/drivers/net/xen-netback/common.h
> >> +++ b/drivers/net/xen-netback/common.h
> >> @@ -108,17 +108,39 @@ struct xenvif_rx_meta {
> >>    */
> >>   #define MAX_GRANT_COPY_OPS (MAX_SKB_FRAGS * XEN_NETIF_RX_RING_SI=
ZE)
> >>
> >> -struct xenvif {
> >> -	/* Unique identifier for this interface. */
> >> -	domid_t          domid;
> >> -	unsigned int     handle;
> >> +/* Queue name is interface name with "-qNNN" appended */
> >> +#define QUEUE_NAME_SIZE (IFNAMSIZ + 6)
> >
> > One more than necessary? Or does IFNAMSIZ not include the NULL? (I =
can't
> > figure out if it does or not!)
>=20
> interface.c contains the line:
> snprintf(name, IFNAMSIZ - 1, "vif%u.%u", domid, handle);
>=20
> This suggests that IFNAMSIZ counts the trailing NULL, so I can reduce
> this count by 1 on that basis.

Thanks.

> >> [...]
> >> -	/* This array is allocated seperately as it is large */
> >> -	struct gnttab_copy *grant_copy_op;
> >> +	struct gnttab_copy grant_copy_op[MAX_GRANT_COPY_OPS];
> >
> > Is this deliberate? It seems like a retrograde step reverting parts=
 of
> > ac3d5ac27735 "xen-netback: fix guest-receive-side array sizes" from=
 Paul
> > (at least you are nuking a speeling erorr)
>=20
> Yes, this was deliberate. These arrays were moved out to avoid proble=
ms
> with kmalloc for the struct net_device (which contains the struct xen=
vif
> in its netdev_priv space). Since the queues are now allocated via
> vzalloc, there is no need to do separate allocations (with the
> requirement to also separately free on every error/teardown path) so =
I
> moved these back into the main queue structure.

Please do this as a separate change then, either pre or post as
appropriate.

> > How does this series interact with Zoltan's foreign mapping one? Ba=
dly I
> > should imagine, are you going to rebase?
>=20
> I'm working on the rebase right now.
>=20
> >
> >> +	/* First, check if there is only one queue to optimise the
> >> +	 * single-queue or old frontend scenario.
> >> +	 */
> >> +	if (vif->num_queues =3D=3D 1) {
> >> +		queue_index =3D 0;
> >> +	} else {
> >> +		/* Use skb_get_hash to obtain an L4 hash if available */
> >> +		hash =3D skb_get_hash(skb);
> >> +		queue_index =3D (u16) (((u64)hash * vif->num_queues) >> 32);
> >
> > No modulo num_queues here?
> >
> > Is the multiply and shift from some best practice somewhere? Or els=
e
> > what is it doing?
>=20
> It seems to be what a bunch of other net drivers do in this scenario.=
 I
> guess the reasoning is it'll be faster than a mod num_queues.

Hard to believe that's the reason for the num_queues =3D=3D 2^x case at
least (which must be most common I'd expect).

> >
> >> +	/* Obtain the queue to be used to transmit this packet */
> >> +	index =3D skb_get_queue_mapping(skb);
> >> +	if (index >=3D vif->num_queues)
> >> +		index =3D 0; /* Fall back to queue 0 if out of range */
> >
> > Is this actually allowed to happen?
> >
> > Even if yes, not modulo num_queue so spread it around a bit?
>=20
> This probably isn't allowed to happen. I figured it didn't hurt to be=
 a
> little defensive with the code here, and falling back to queue 0 is a
> fairly safe thing to do.

If it shouldn't happen then is a ratelimited warning appropriate?

>=20
> >>   static void xenvif_up(struct xenvif *vif)
> >>   {
> >> -	napi_enable(&vif->napi);
> >> -	enable_irq(vif->tx_irq);
> >> -	if (vif->tx_irq !=3D vif->rx_irq)
> >> -		enable_irq(vif->rx_irq);
> >> -	xenvif_check_rx_xenvif(vif);
> >> +	struct xenvif_queue *queue =3D NULL;
> >> +	unsigned int queue_index;
> >> +
> >> +	for (queue_index =3D 0; queue_index < vif->num_queues; ++queue_i=
ndex) {
> >
> > This vif->num_queues -- is it the same as dev->num_tx_queues? Or ar=
eew
> > there differing concepts of queue around?
>=20
> It should be the same as dev->real_num_tx_queues, which may be less t=
han
> dev->num_tx_queues.

It'd be better to use the single variable in dev then I think, rather
than duplicate and risk them getting out of sync etc. I'm a bit
surprised there are no helpers in the core for this sort of thing (at
least not that I can find).

>=20
> >> +		queue =3D &vif->queues[queue_index];
> >> +		napi_enable(&queue->napi);
> >> +		enable_irq(queue->tx_irq);
> >> +		if (queue->tx_irq !=3D queue->rx_irq)
> >> +			enable_irq(queue->rx_irq);
> >> +		xenvif_check_rx_xenvif(queue);
> >> +	}
> >>   }
> >>
> >>   static void xenvif_down(struct xenvif *vif)
> >>   {
> >> -	napi_disable(&vif->napi);
> >> -	disable_irq(vif->tx_irq);
> >> -	if (vif->tx_irq !=3D vif->rx_irq)
> >> -		disable_irq(vif->rx_irq);
> >> -	del_timer_sync(&vif->credit_timeout);
> >> +	struct xenvif_queue *queue =3D NULL;
> >> +	unsigned int queue_index;
> >
> > Why unsigned?
> Why not? You can't have a negative number of queues. Zero indicates "=
I
> don't have any set up yet". I'm not expecting people to have 4 billio=
n
> or so queues, but equally I can't see a valid use for negative values
> here.

It's just unusual that's all.

> @@ -507,18 +529,24 @@ static void connect(struct backend_info *be)
> >>   	if (!err)
> >>   		be->have_hotplug_status_watch =3D 1;
> >>
> >> -	netif_wake_queue(be->vif->dev);
> >> +	netif_tx_wake_all_queues(be->vif->dev);
> >> +
> >> +	return;
> >> +
> >> +err:
> >> +	vfree(be->vif->queues);
> >> +	be->vif->queues =3D NULL;
> >> +	be->vif->num_queues =3D 0;
> >> +	return;
> >
> > Do you not need to unwind the setup already done on the previous qu=
eues
> > before the failure?
>=20
>=20
> Err... yes. I was sure that code existed at some point, but I can't f=
ind
> it now. Oops!

;-)

Ian.
