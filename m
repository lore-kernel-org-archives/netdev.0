From: Andrew Bennieston <andrew.bennieston@citrix.com>
Subject: Re: [PATCH V6 net-next 1/5] xen-netback: Factor queue-specific data
 into queue struct.
Date: Mon, 17 Mar 2014 11:53:35 +0000
Message-ID: <5326E23F.8050304@citrix.com>
References: <1393847269-6981-1-git-send-email-andrew.bennieston@citrix.com>	 <1393847269-6981-2-git-send-email-andrew.bennieston@citrix.com> <1394812505.6442.128.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:30197 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932672AbaCQLxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 07:53:51 -0400
In-Reply-To: <1394812505.6442.128.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/03/14 15:55, Ian Campbell wrote:
> On Mon, 2014-03-03 at 11:47 +0000, Andrew J. Bennieston wrote:
>> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
>>
>> In preparation for multi-queue support in xen-netback, move the
>> queue-specific data from struct xenvif into struct xenvif_queue, and
>> update the rest of the code to use this.
>>
>> Also[...]
>>
>> Finally,[...]
>
> This is already quite a big patch, and I don't think the commit log
> covers everything it changes/refactors, does it?
>
> It's always a good idea to break these things apart but in particular
> separating the mechanical stuff (s/vif/queue/g) from the non-mechanic=
al
> stuff, since the mechanical stuff is essentially trivial to review an=
d
> getting it out the way makes the non-mechanical stuff much easier to
> check (or even spot).
>

The vast majority of changes in this patch are s/vif/queue/g. The rest
are related changes, such as inserting loops over queues, and moving
queue-specific initialisation away from the vif-wide initialisation, so
that it can be done once per queue.

I consider these things to be logically related and definitely within
the purview of this single patch. Without doing this, it is difficult t=
o
get a patch that results in something that even compiles, without
putting in a bunch of placeholder code that will be removed in the very
next patch.

When I split this feature into multiple patches, I took care to group
as little as possible into this first patch (and the same for netfront)=
=2E
It is still a large patch, but by my count most of this is a simple
replacement of vif with queue...

A first-order approximation, searching for line pairs where the first
has 'vif' and the second has 'queue', yields:

=E2=9E=9C  xen-netback git:(saturn) git show HEAD~4 | grep -A 1 vif | g=
rep queue=20
| wc -l
380

i.e. 760 (=3D380*2) lines out of the 2240 (~ 40%) are trivial replaceme=
nts
of vif with queue, and this is not counting multi-line replacements, of
which there are many. What remains is mostly adding loops over these
queues. This could, in principle, be done in a second patch, but the
impact of this is small.

>
>>
>> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
>> Reviewed-by: Paul Durrant <paul.durrant@citrix.com>
>> ---
>>   drivers/net/xen-netback/common.h    |   85 ++++--
>>   drivers/net/xen-netback/interface.c |  329 ++++++++++++++--------
>>   drivers/net/xen-netback/netback.c   |  530 ++++++++++++++++++-----=
------------
>>   drivers/net/xen-netback/xenbus.c    |   87 ++++--
>>   4 files changed, 608 insertions(+), 423 deletions(-)
>>
>> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netb=
ack/common.h
>> index ae413a2..4176539 100644
>> --- a/drivers/net/xen-netback/common.h
>> +++ b/drivers/net/xen-netback/common.h
>> @@ -108,17 +108,39 @@ struct xenvif_rx_meta {
>>    */
>>   #define MAX_GRANT_COPY_OPS (MAX_SKB_FRAGS * XEN_NETIF_RX_RING_SIZE=
)
>>
>> -struct xenvif {
>> -	/* Unique identifier for this interface. */
>> -	domid_t          domid;
>> -	unsigned int     handle;
>> +/* Queue name is interface name with "-qNNN" appended */
>> +#define QUEUE_NAME_SIZE (IFNAMSIZ + 6)
>
> One more than necessary? Or does IFNAMSIZ not include the NULL? (I ca=
n't
> figure out if it does or not!)

interface.c contains the line:
snprintf(name, IFNAMSIZ - 1, "vif%u.%u", domid, handle);

This suggests that IFNAMSIZ counts the trailing NULL, so I can reduce
this count by 1 on that basis.

>
>> [...]
>> -	/* This array is allocated seperately as it is large */
>> -	struct gnttab_copy *grant_copy_op;
>> +	struct gnttab_copy grant_copy_op[MAX_GRANT_COPY_OPS];
>
> Is this deliberate? It seems like a retrograde step reverting parts o=
f
> ac3d5ac27735 "xen-netback: fix guest-receive-side array sizes" from P=
aul
> (at least you are nuking a speeling erorr)

Yes, this was deliberate. These arrays were moved out to avoid problems
with kmalloc for the struct net_device (which contains the struct xenvi=
f
in its netdev_priv space). Since the queues are now allocated via
vzalloc, there is no need to do separate allocations (with the
requirement to also separately free on every error/teardown path) so I
moved these back into the main queue structure.

>
> How does this series interact with Zoltan's foreign mapping one? Badl=
y I
> should imagine, are you going to rebase?

I'm working on the rebase right now.

>
>> +	/* First, check if there is only one queue to optimise the
>> +	 * single-queue or old frontend scenario.
>> +	 */
>> +	if (vif->num_queues =3D=3D 1) {
>> +		queue_index =3D 0;
>> +	} else {
>> +		/* Use skb_get_hash to obtain an L4 hash if available */
>> +		hash =3D skb_get_hash(skb);
>> +		queue_index =3D (u16) (((u64)hash * vif->num_queues) >> 32);
>
> No modulo num_queues here?
>
> Is the multiply and shift from some best practice somewhere? Or else
> what is it doing?

It seems to be what a bunch of other net drivers do in this scenario. I
guess the reasoning is it'll be faster than a mod num_queues.

>
>
>> +	/* Obtain the queue to be used to transmit this packet */
>> +	index =3D skb_get_queue_mapping(skb);
>> +	if (index >=3D vif->num_queues)
>> +		index =3D 0; /* Fall back to queue 0 if out of range */
>
> Is this actually allowed to happen?
>
> Even if yes, not modulo num_queue so spread it around a bit?

This probably isn't allowed to happen. I figured it didn't hurt to be a
little defensive with the code here, and falling back to queue 0 is a
fairly safe thing to do.

>>   static void xenvif_up(struct xenvif *vif)
>>   {
>> -	napi_enable(&vif->napi);
>> -	enable_irq(vif->tx_irq);
>> -	if (vif->tx_irq !=3D vif->rx_irq)
>> -		enable_irq(vif->rx_irq);
>> -	xenvif_check_rx_xenvif(vif);
>> +	struct xenvif_queue *queue =3D NULL;
>> +	unsigned int queue_index;
>> +
>> +	for (queue_index =3D 0; queue_index < vif->num_queues; ++queue_ind=
ex) {
>
> This vif->num_queues -- is it the same as dev->num_tx_queues? Or aree=
w
> there differing concepts of queue around?

It should be the same as dev->real_num_tx_queues, which may be less tha=
n
dev->num_tx_queues.

>> +		queue =3D &vif->queues[queue_index];
>> +		napi_enable(&queue->napi);
>> +		enable_irq(queue->tx_irq);
>> +		if (queue->tx_irq !=3D queue->rx_irq)
>> +			enable_irq(queue->rx_irq);
>> +		xenvif_check_rx_xenvif(queue);
>> +	}
>>   }
>>
>>   static void xenvif_down(struct xenvif *vif)
>>   {
>> -	napi_disable(&vif->napi);
>> -	disable_irq(vif->tx_irq);
>> -	if (vif->tx_irq !=3D vif->rx_irq)
>> -		disable_irq(vif->rx_irq);
>> -	del_timer_sync(&vif->credit_timeout);
>> +	struct xenvif_queue *queue =3D NULL;
>> +	unsigned int queue_index;
>
> Why unsigned?
Why not? You can't have a negative number of queues. Zero indicates "I
don't have any set up yet". I'm not expecting people to have 4 billion
or so queues, but equally I can't see a valid use for negative values
here.

>
>> @@ -496,9 +497,30 @@ static void connect(struct backend_info *be)
>>   		return;
>>   	}
>>
>> -	xen_net_read_rate(dev, &be->vif->credit_bytes,
>> -			  &be->vif->credit_usec);
>> -	be->vif->remaining_credit =3D be->vif->credit_bytes;
>> +	xen_net_read_rate(dev, &credit_bytes, &credit_usec);
>> +	read_xenbus_vif_flags(be);
>> +
>> +	be->vif->num_queues =3D 1;
>> +	be->vif->queues =3D vzalloc(be->vif->num_queues *
>> +			sizeof(struct xenvif_queue));
>> +
>> +	for (queue_index =3D 0; queue_index < be->vif->num_queues; ++queue=
_index) {
>> +		queue =3D &be->vif->queues[queue_index];
>> +		queue->vif =3D be->vif;
>> +		queue->id =3D queue_index;
>> +		snprintf(queue->name, sizeof(queue->name), "%s-q%u",
>> +				be->vif->dev->name, queue->id);
>> +
>> +		xenvif_init_queue(queue);
>> +
>> +		queue->remaining_credit =3D credit_bytes;
>> +
>> +		err =3D connect_rings(be, queue);
>> +		if (err)
>> +			goto err;
>> +	}
>> +
>> +	xenvif_carrier_on(be->vif);
>>
>>   	unregister_hotplug_status_watch(be);
>>   	err =3D xenbus_watch_pathfmt(dev, &be->hotplug_status_watch,
>> @@ -507,18 +529,24 @@ static void connect(struct backend_info *be)
>>   	if (!err)
>>   		be->have_hotplug_status_watch =3D 1;
>>
>> -	netif_wake_queue(be->vif->dev);
>> +	netif_tx_wake_all_queues(be->vif->dev);
>> +
>> +	return;
>> +
>> +err:
>> +	vfree(be->vif->queues);
>> +	be->vif->queues =3D NULL;
>> +	be->vif->num_queues =3D 0;
>> +	return;
>
> Do you not need to unwind the setup already done on the previous queu=
es
> before the failure?


Err... yes. I was sure that code existed at some point, but I can't fin=
d
it now. Oops!


-Andrew
>
>>   }
>>
>>
>> -static int connect_rings(struct backend_info *be)
>> +static int connect_rings(struct backend_info *be, struct xenvif_que=
ue *queue)
>>   {
>> -	struct xenvif *vif =3D be->vif;
>>   	struct xenbus_device *dev =3D be->dev;
>>   	unsigned long tx_ring_ref, rx_ring_ref;
>> -	unsigned int tx_evtchn, rx_evtchn, rx_copy;
>> +	unsigned int tx_evtchn, rx_evtchn;
>>   	int err;
>> -	int val;
>>
>>   	err =3D xenbus_gather(XBT_NIL, dev->otherend,
>>   			    "tx-ring-ref", "%lu", &tx_ring_ref,
>> @@ -546,6 +574,27 @@ static int connect_rings(struct backend_info *b=
e)
>>   		rx_evtchn =3D tx_evtchn;
>>   	}
>>
>> +	/* Map the shared frame, irq etc. */
>> +	err =3D xenvif_connect(queue, tx_ring_ref, rx_ring_ref,
>> +			     tx_evtchn, rx_evtchn);
>> +	if (err) {
>> +		xenbus_dev_fatal(dev, err,
>> +				 "mapping shared-frames %lu/%lu port tx %u rx %u",
>> +				 tx_ring_ref, rx_ring_ref,
>> +				 tx_evtchn, rx_evtchn);
>> +		return err;
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>
>
