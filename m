From: Joao Martins <Joao.Martins@neclab.eu>
Subject: Re: [RFC PATCH 04/13] xen-netback: implement RX persistent grants
Date: Fri, 22 May 2015 10:25:10 +0000
Message-ID: <65A385A5-4D11-4032-BB1B-82180AF76477@neclab.eu>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-5-git-send-email-joao.martins@neclab.eu>
 <20150519153205.GC26335@zion.uk.xensource.com>
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
Received: from mailer1.neclab.eu ([195.37.70.40]:60443 "EHLO mailer1.neclab.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756587AbbEVKZa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 06:25:30 -0400
In-Reply-To: <20150519153205.GC26335@zion.uk.xensource.com>
Content-Language: en-US
Content-ID: <CC7B97421F4AA64FA666FC9EE0CA9FB4@office.hd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 19 May 2015, at 17:32, Wei Liu <wei.liu2@citrix.com> wrote:

> On Tue, May 12, 2015 at 07:18:28PM +0200, Joao Martins wrote:
>> It starts by doing a lookup in the tree for a gref. If no persistent
>> grant is found on the tree, it will do grant copy and prepare
>> the grant maps. Finally valides the grant map and adds it to the tre=
e.
>=20
> validates?
>=20
>> After mapped these grants can be pulled from the tree in the subsequ=
ent
>> requests. If it's out of pages in the tree pool, it will fallback to
>> grant copy.
>>=20
>=20
> Again, this looks complicated. Why use combined scheme? I will do
> detailed reviews after we're sure we need such scheme.
When we don't have the gref in tree we need to map it and then copying
afterwards into the newly mapped page (and this only happens once until
the grant is in tree). My options here were to either do this explicitl=
y,
after we add the persistent grant in which we would need to save to
dst/src address and len to copy. The other option is to reuse the grant
copy (since it's only once until the grant is in the tree) and use memc=
py
in followings requests. Additionally I allow the fallback to grant copy=
 in
case the guest provides providing more grefs > max_grants.

Note that this is also the case for TX as well, with regard to grant
copying the header. I was unsure about which one is the most correct wa=
y
of doing it, but ultimately the latter involved a smaller codepath, and
that's why I chose it. What do you think?


>> It adds four new fields in the netrx_pending_operations: copy_done
>> to track how many copies were made; map_prod and map_cons to track
>> how many maps are outstanding validation and finally copy_page for
>> the correspondent page (in tree) for copy_gref.
>>=20
>> Results are 1.04 Mpps measured with pktgen (pkt_size 64, burst 1)
>> with persistent grants versus 1.23 Mpps with grant copy (20%
>> regression). With persistent grants it adds up contention on
>> queue->wq as the kthread_guest_rx goes to sleep more often. If we
>> speed up the sender (burst 2,4 and 8) it goes up to 1.7 Mpps with
>> persistent grants. This issue is addressed in later a commit, by
>> copying the skb on xenvif_start_xmit() instead of going through
>> the RX kthread.
>>=20
>> Signed-off-by: Joao Martins <joao.martins@neclab.eu>
>> ---
>> drivers/net/xen-netback/common.h    |   7 ++
>> drivers/net/xen-netback/interface.c |  14 ++-
>> drivers/net/xen-netback/netback.c   | 190 ++++++++++++++++++++++++++=
++++------
>> 3 files changed, 178 insertions(+), 33 deletions(-)
>>=20
>> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netb=
ack/common.h
>> index e5ee220..23deb6a 100644
>> --- a/drivers/net/xen-netback/common.h
>> +++ b/drivers/net/xen-netback/common.h
>> @@ -235,6 +235,13 @@ struct xenvif_queue { /* Per-queue data for xen=
vif */
>>=20
>> 	struct gnttab_copy grant_copy_op[MAX_GRANT_COPY_OPS];
>>=20
>> +	/* To map the grefs to be added to the tree */
>> +	struct gnttab_map_grant_ref rx_map_ops[XEN_NETIF_RX_RING_SIZE];
>> +	struct page *rx_pages_to_map[XEN_NETIF_RX_RING_SIZE];
>> +	/* Only used if feature-persistent =3D 1 */
>=20
> This comment applies to rx_map_ops and rx_pages_to_map as well. Could
> you move it up?
Ok.

>> +	struct persistent_gnt_tree rx_gnts_tree;
>> +	struct page *rx_gnts_pages[XEN_NETIF_RX_RING_SIZE];
>> +
>> 	/* We create one meta structure per ring request we consume, so
>> 	 * the maximum number is the same as the ring size.
>> 	 */
>> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-n=
etback/interface.c
>=20
> [...]
>=20
>>=20
>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-net=
back/netback.c
>> index 529d7c3..738b6ee 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -413,14 +413,62 @@ static void xenvif_rx_queue_drop_expired(struc=
t xenvif_queue *queue)
>> }
>>=20
>> struct netrx_pending_operations {
>> +	unsigned map_prod, map_cons;
>> 	unsigned copy_prod, copy_cons;
>> 	unsigned meta_prod, meta_cons;
>> 	struct gnttab_copy *copy;
>> 	struct xenvif_rx_meta *meta;
>> 	int copy_off;
>> 	grant_ref_t copy_gref;
>> +	struct page *copy_page;
>> +	unsigned copy_done;
>> };
>>=20
>> +static void xenvif_create_rx_map_op(struct xenvif_queue *queue,
>> +				    struct gnttab_map_grant_ref *mop,
>> +				    grant_ref_t ref,
>> +				    struct page *page)
>=20
> Rename it to xenvif_rx_create_map_op to be consistent with
> xenvif_tx_create_map_op?
>=20
>> +{
>> +	queue->rx_pages_to_map[mop - queue->rx_map_ops] =3D page;
>> +	gnttab_set_map_op(mop,
>> +			  (unsigned long)page_to_kaddr(page),
>> +			  GNTMAP_host_map,
>> +			  ref, queue->vif->domid);
>> +}
>> +
>=20
> [...]
>=20
>> +
>> +		persistent_gnt =3D xenvif_pgrant_new(tree, gop_map);
>> +		if (unlikely(!persistent_gnt)) {
>> +			netdev_err(queue->vif->dev,
>> +				   "Couldn't add gref to the tree! ref: %d",
>> +				   gop_map->ref);
>> +			xenvif_page_unmap(queue, gop_map->handle, &page);
>> +			put_free_pages(tree, &page, 1);
>> +			kfree(persistent_gnt);
>> +			persistent_gnt =3D NULL;
>=20
> persistent_gnt is already NULL.
>=20
> So the kfree and =3D NULL is pointless.
Indeed, I will also retest this error path. This was a remnant of a ref=
actoring I did in
the RX/TX shared paths.

>> +			continue;
>> +		}
>> +
>> +		put_persistent_gnt(tree, persistent_gnt);
>> +	}
>> +}
>> +
>> +/*
>>  * This is a twin to xenvif_gop_skb.  Assume that xenvif_gop_skb was
>>  * used to set up the operations on the top of
>>  * netrx_pending_operations, which have since been done.  Check that
>>  * they didn't give any errors and advance over them.
>>  */
>> -static int xenvif_check_gop(struct xenvif *vif, int nr_meta_slots,
>> +static int xenvif_check_gop(struct xenvif_queue *queue, int nr_meta=
_slots,
>> 			    struct netrx_pending_operations *npo)
>> {
>> 	struct gnttab_copy     *copy_op;
>> 	int status =3D XEN_NETIF_RSP_OKAY;
>> 	int i;
>>=20
>> +	nr_meta_slots -=3D npo->copy_done;
>> +	if (npo->map_prod)
>=20
> Should be "if (npo->map_prod !=3D npo->map_cons)=94?
Correct. Using just npo->map_prod is buggy.
