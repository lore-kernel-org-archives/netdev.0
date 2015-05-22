From: Joao Martins <Joao.Martins@neclab.eu>
Subject: Re: [RFC PATCH 03/13] xen-netback: implement TX persistent grants
Date: Fri, 22 May 2015 10:24:39 +0000
Message-ID: <30CF0FF9-3B1D-48AF-AFB4-73E20C404357@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-4-git-send-email-joao.martins@neclab.eu>
 <20150519152342.GB26335@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:60435 "EHLO mailer1.neclab.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756038AbbEVKZQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 06:25:16 -0400
In-Reply-To: <20150519152342.GB26335@zion.uk.xensource.com>
Content-Language: en-US
Content-ID: <E17434BED329FB4C9F1BBCBB522A2DE9@office.hd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 19 May 2015, at 17:23, Wei Liu <wei.liu2@citrix.com> wrote:
> On Tue, May 12, 2015 at 07:18:27PM +0200, Joao Martins wrote:
>> Introduces persistent grants for TX path which follows similar code =
path
>> as the grant mapping.
>>=20
>> It starts by checking if there's a persistent grant available for he=
ader
>> and frags grefs and if so setting it in tx_pgrants. If no persistent=
 grant
>> is found in the tree for the header it will resort to grant copy (bu=
t
>> preparing the map ops and add them laster). For the frags it will us=
e the
>                                     ^
>                                     later
>=20
>> tree page pool, and in case of no pages it fallbacks to grant map/un=
map
>> using mmap_pages. When skb destructor callback gets called we releas=
e the
>> slot and persistent grant within the callback to avoid waking up the
>> dealloc thread. As long as there are no unmaps to done the dealloc t=
hread
>> will remain inactive.
>>=20
>=20
> This scheme looks complicated. Can we just only use one
> scheme at a time? What's the rationale for using this combined scheme=
?
> Maybe you're thinking about using a max_grants < ring_size to save
> memory?

Yes, my purpose was to allow a max_grants < ring_size to save amount of
memory mapped. I did a bulk transfer test with iperf and the max amount=
 of
grants in tree was <160 TX gnts, without affecting the max performance;
tough using pktgen fills the tree completely.
The second reason is to handle the case for a (malicious?) frontend pro=
viding
more grefs than the max allowed in which I would fallback to grant map/=
unmap.

>=20
> Only skim the patch. I will do detailed reviews after we're sure this=
 is
> the right way to go.
>=20
>> Results show an improvement of 46% (1.82 vs 1.24 Mpps, 64 pkt size)
>> measured with pktgen and up to over 48% (21.6 vs 14.5 Gbit/s) measur=
ed
>> with iperf (TCP) with 4 parallel flows 1 queue vif, DomU to Dom0.
>> Tests ran on a Intel Xeon E5-1650 v2 with HT disabled.
>> [=85]
>> int xenvif_init_queue(struct xenvif_queue *queue)
>> {
>> 	int err, i;
>> @@ -496,9 +524,23 @@ int xenvif_init_queue(struct xenvif_queue *queu=
e)
>> 			  .ctx =3D NULL,
>> 			  .desc =3D i };
>> 		queue->grant_tx_handle[i] =3D NETBACK_INVALID_HANDLE;
>> +		queue->tx_pgrants[i] =3D NULL;
>> +	}
>> +
>> +	if (queue->vif->persistent_grants) {
>> +		err =3D init_persistent_gnt_tree(&queue->tx_gnts_tree,
>> +					       queue->tx_gnts_pages,
>> +					       XEN_NETIF_TX_RING_SIZE);
>> +		if (err)
>> +			goto err_disable;
>> 	}
>>=20
>> 	return 0;
>> +
>> +err_disable:
>> +	netdev_err(queue->vif->dev, "Could not reserve tree pages.");
>> +	queue->vif->persistent_grants =3D 0;
>=20
> You can just move the above two lines under `if (err)'.
>=20
> Also see below.
In the next patch this is also common cleanup path. I did it this way t=
o=20
avoid moving this hunk around.


>> +	return 0;
>> }
>>=20
>> void xenvif_carrier_on(struct xenvif *vif)
>> @@ -654,6 +696,10 @@ void xenvif_disconnect(struct xenvif *vif)
>> 		}
>>=20
>> 		xenvif_unmap_frontend_rings(queue);
>> +
>> +		if (queue->vif->persistent_grants)
>> +			deinit_persistent_gnt_tree(&queue->tx_gnts_tree,
>> +						   queue->tx_gnts_pages);
>=20
> If the init function fails on queue N (N>0) you now leak resources.
Correct. I should return -ENOMEM (on init) and not 0.


>> 	}
>> }
>>=20
>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-net=
back/netback.c
>> index 332e489..529d7c3 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -269,6 +269,11 @@ static inline unsigned long idx_to_kaddr(struct=
 xenvif_queue *queue,
>> 	return (unsigned long)pfn_to_kaddr(idx_to_pfn(queue, idx));
>> }
>>=20
>> +static inline void *page_to_kaddr(struct page *page)
>> +{
>> +	return pfn_to_kaddr(page_to_pfn(page));
>> +}
>> +
>> #define callback_param(vif, pending_idx) \
>> 	(vif->pending_tx_info[pending_idx].callback_struct)
>>=20
>> @@ -299,6 +304,29 @@ static inline pending_ring_idx_t pending_index(=
unsigned i)
>> 	return i & (MAX_PENDING_REQS-1);
>> }
>>=20
>> +/*  Creates a new persistent grant and add it to the tree.
>> + */
>> +static struct persistent_gnt *xenvif_pgrant_new(struct persistent_g=
nt_tree *tree,
>> +						struct gnttab_map_grant_ref *gop)
>> +{
>> +	struct persistent_gnt *persistent_gnt;
>> +
>> +	persistent_gnt =3D kmalloc(sizeof(*persistent_gnt), GFP_KERNEL);
>=20
> xenvif_pgrant_new can be called in NAPI which runs in softirq context
> which doesn't allow you to sleep.

Silly mistake, I will fix this. The whole point of the tree page pool w=
as that we
aren't allowed to sleep both here and in ndo_start_xmit (in patch #6).

>> [=85]
>>=20
>> +/* Checks if there's a persistent grant available for gref and
>> + * if so, set it also in the tx_pgrants array that keeps the ones
>> + * in use.
>> + */
>> +static bool xenvif_tx_pgrant_available(struct xenvif_queue *queue,
>> +				       grant_ref_t ref, u16 pending_idx,
>> +				       bool *can_map)
>> +{
>> +	struct persistent_gnt_tree *tree =3D &queue->tx_gnts_tree;
>> +	struct persistent_gnt *persistent_gnt;
>> +	bool busy;
>> +
>> +	if (!queue->vif->persistent_grants)
>> +		return false;
>> +
>> +	persistent_gnt =3D get_persistent_gnt(tree, ref);
>> +
>> +	/* If gref is already in use we fallback, since it would
>> +	 * otherwise mean re-adding the same gref to the tree
>> +	 */
>> +	busy =3D IS_ERR(persistent_gnt);
>> +	if (unlikely(busy))
>> +		persistent_gnt =3D NULL;
>> +
>=20
> Under what circumstance can we retrieve a already in use persistent
> grant? You seem to suggest this is a bug in RX case.

A guest could share try to share the same mapped page in multiple frags=
,
in which case I fallback to map/unmap. I think this is a limitation in
the way we manage the persistent gnts where we can only have a single
reference of a persistent grant inflight.

>> [=85]
>> 			MAX_PENDING_REQS);
>> 		index =3D pending_index(queue->dealloc_prod);
>> @@ -1691,7 +1939,10 @@ void xenvif_zerocopy_callback(struct ubuf_inf=
o *ubuf, bool zerocopy_success)
>> 		smp_wmb();
>> 		queue->dealloc_prod++;
>> 	} while (ubuf);
>> -	wake_up(&queue->dealloc_wq);
>> +	/* Wake up only when there are grants to unmap */
>> +	if (dealloc_prod_save !=3D queue->dealloc_prod)
>> +		wake_up(&queue->dealloc_wq);
>> +
>> 	spin_unlock_irqrestore(&queue->callback_lock, flags);
>>=20
>> 	if (likely(zerocopy_success))
>> @@ -1779,10 +2030,13 @@ int xenvif_tx_action(struct xenvif_queue *qu=
eue, int budget)
>>=20
>> 	xenvif_tx_build_gops(queue, budget, &nr_cops, &nr_mops);
>>=20
>> -	if (nr_cops =3D=3D 0)
>> +	if (!queue->vif->persistent_grants &&
>> +	    nr_cops =3D=3D 0)
>=20
> You can just move nr_cops to previous line.
>=20
> Wei.
