From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH 3/4] Xen/netfront: Implement persistent grant
 in netfront.
Date: Fri, 16 Nov 2012 13:22:07 +0800
Message-ID: <50A5CD7F.2010609@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com> <1352963114-628-1-git-send-email-annie.li@oracle.com> <50A4C987.3020308@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: =?ISO-8859-1?Q?Roger_Pau_Monn=E9?= <roger.pau@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30849 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767Ab2KPFWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 00:22:17 -0500
In-Reply-To: <50A4C987.3020308@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-11-15 18:52, Roger Pau Monn=E9 wrote:
> On 15/11/12 08:05, Annie Li wrote:
>> Tx/rx page pool are maintained. New grant is mapped and put into
>> pool, unmap only happens when releasing/removing device.
>>
>> Signed-off-by: Annie Li<annie.li@oracle.com>
>> ---
>>   drivers/net/xen-netfront.c |  372 ++++++++++++++++++++++++++++++++=
+++++-------
>>   1 files changed, 315 insertions(+), 57 deletions(-)
>>
>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>> index 0ebbb19..17b81c0 100644
>> --- a/drivers/net/xen-netfront.c
>> +++ b/drivers/net/xen-netfront.c
>> @@ -79,6 +79,13 @@ struct netfront_stats {
>>          struct u64_stats_sync   syncp;
>>   };
>>
>> +struct gnt_list {
>> +       grant_ref_t             gref;
>> +       struct                  page *gnt_pages;
>> +       void                    *gnt_target;
>> +       struct                  gnt_list *tail;
>> +};
> This could also be shared with blkfront.

Netfront does not have the shadow like blkfront, and it needs the=20
gnt_target to save skb address of rx path. So we can share this too?=20
blkfront would not use it actually.

>
>> +
>>   struct netfront_info {
>>          struct list_head list;
>>          struct net_device *netdev;
>> @@ -109,6 +116,10 @@ struct netfront_info {
>>          grant_ref_t grant_tx_ref[NET_TX_RING_SIZE];
>>          unsigned tx_skb_freelist;
>>
>> +       struct gnt_list *tx_grant[NET_TX_RING_SIZE];
>> +       struct gnt_list *tx_gnt_list;
>> +       unsigned int tx_gnt_cnt;
> I don't understand this, why do you need both an array and a list?

The array tx_grant is just like other tx_skbs, grant_tx_ref. It saves=20
grant entries corresponding every request in the ring. This is what=20
netfront different from blkfront, netfront does not have shadow ring,=20
and it only uses a ring size array to track every request in the ring.
The list is like a pool to save all available persistent grants.

> I'm
> not familiar with net code, so I don't know if this is some kind of
> special netfront thing?

Yes, this is different from blkfront. netfront uses ring size arrays to=
=20
track every request in the ring.

>
> Anyway if you have to use a list I would recommend using one of the l=
ist
> constructions that's already in the kernel, it simplifies the code an=
d
> makes it more easy to understand than creating your own list structur=
e.

Ok, thanks.

>
>> +
>>          spinlock_t   rx_lock ____cacheline_aligned_in_smp;
>>          struct xen_netif_rx_front_ring rx;
>>          int rx_ring_ref;
>> @@ -126,6 +137,10 @@ struct netfront_info {
>>          grant_ref_t gref_rx_head;
>>          grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
>>
>> +       struct gnt_list *rx_grant[NET_RX_RING_SIZE];
>> +       struct gnt_list *rx_gnt_list;
>> +       unsigned int rx_gnt_cnt;
> Same comment above here.

Same as above.

>
>> +
>>          unsigned long rx_pfn_array[NET_RX_RING_SIZE];
>>          struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
>>          struct mmu_update rx_mmu[NET_RX_RING_SIZE];
>> @@ -134,6 +149,7 @@ struct netfront_info {
>>          struct netfront_stats __percpu *stats;
>>
>>          unsigned long rx_gso_checksum_fixup;
>> +       u8 persistent_gnt:1;
>>   };
>>
>>   struct netfront_rx_info {
>> @@ -194,6 +210,16 @@ static grant_ref_t xennet_get_rx_ref(struct net=
front_info *np,
>>          return ref;
>>   }
>>
>> +static struct gnt_list *xennet_get_rx_grant(struct netfront_info *n=
p,
>> +                                           RING_IDX ri)
>> +{
>> +       int i =3D xennet_rxidx(ri);
>> +       struct gnt_list *gntlist =3D np->rx_grant[i];
>> +       np->rx_grant[i] =3D NULL;
> Ok, I think I get why do you need both an array and a list, is that
> because netfront doesn't have some kind of shadow ring to keep track =
of
> issued requests?

Yes.

>
> So each issued request has an associated gnt_list with the list of us=
ed
> grants?

gnt_list is kind of free grants. It is like a pool of free grants. If=20
free grants exist in this list, free grant will be gotten from this=20
list. If no, new grant will be allocated. In xennet_tx_buf_gc, free=20
grants will be put into the list again if response status is OK.

> If so it would be good to add a comment about it.
>
>> +       return gntlist;
>> +}
>> +
>>   #ifdef CONFIG_SYSFS
>>   static int xennet_sysfs_addif(struct net_device *netdev);
>>   static void xennet_sysfs_delif(struct net_device *netdev);
>> @@ -231,6 +257,68 @@ static void xennet_maybe_wake_tx(struct net_dev=
ice *dev)
>>                  netif_wake_queue(dev);
>>   }
>>
>> +static grant_ref_t xennet_alloc_rx_ref(struct net_device *dev,
>> +                                      unsigned long mfn, void *vadd=
r,
>> +                                      unsigned int id,
>> +                                      grant_ref_t ref)
>> +{
>> +       struct netfront_info *np =3D netdev_priv(dev);
>> +       grant_ref_t gnt_ref;
>> +       struct gnt_list *gnt_list_entry;
>> +
>> +       if (np->persistent_gnt&&  np->rx_gnt_cnt) {
>> +               gnt_list_entry =3D np->rx_gnt_list;
>> +               np->rx_gnt_list =3D np->rx_gnt_list->tail;
>> +               np->rx_gnt_cnt--;
>> +
>> +               gnt_list_entry->gnt_target =3D vaddr;
>> +               gnt_ref =3D gnt_list_entry->gref;
>> +               np->rx_grant[id] =3D gnt_list_entry;
>> +       } else {
>> +               struct page *page;
>> +
>> +               BUG_ON(!np->persistent_gnt&&  np->rx_gnt_cnt);
>> +               if (!ref)
>> +                       gnt_ref =3D
>> +                               gnttab_claim_grant_reference(&np->gr=
ef_rx_head);
>> +               else
>> +                       gnt_ref =3D ref;
>> +               BUG_ON((signed short)gnt_ref<  0);
>> +
>> +               if (np->persistent_gnt) {
> So you are only using persistent grants if the backend also supports
> them.

Current implementation is:
If netback supports persistent grant, the frontend will work with=20
persistent grant feature too.
If netback does not support persistent grant, the frontend will work=20
without persistent grant feature.

> Have you benchmarked the performance of a persistent frontend with
> a non-persistent backend.

I  remember I did some test before, not so sure. Will check it.

>   In the block case, usign a persistent frontend
> with a non-persistent backend let to an overall performance improveme=
nt,
> so blkfront uses persistent grants even if blkback doesn't support th=
em.
> Take a look at the following graph:
>
> http://xenbits.xen.org/people/royger/persistent_grants/nonpers_read.p=
ng

Good idea, that makes sense. I will change netfront too, thanks.

>
>> +                       page =3D alloc_page(GFP_KERNEL);
>> +                       if (!page) {
>> +                               if (!ref)
>> +                                       gnttab_release_grant_referen=
ce(
>> +&np->gref_rx_head, ref);
>> +                               return -ENOMEM;
>> +                       }
>> +                       mfn =3D pfn_to_mfn(page_to_pfn(page));
>> +
>> +                       gnt_list_entry =3D kmalloc(sizeof(struct gnt=
_list),
>> +                                                GFP_KERNEL);
>> +                       if (!gnt_list_entry) {
>> +                               __free_page(page);
>> +                               if (!ref)
>> +                                       gnttab_release_grant_referen=
ce(
>> +&np->gref_rx_head, ref);
>> +                               return -ENOMEM;
>> +                       }
>> +                       gnt_list_entry->gref =3D gnt_ref;
>> +                       gnt_list_entry->gnt_pages =3D page;
>> +                       gnt_list_entry->gnt_target =3D vaddr;
>> +
>> +                       np->rx_grant[id] =3D gnt_list_entry;
>> +               }
>> +
>> +               gnttab_grant_foreign_access_ref(gnt_ref, np->xbdev->=
otherend_id,
>> +                                               mfn, 0);
>> +       }
>> +       np->grant_rx_ref[id] =3D gnt_ref;
>> +
>> +       return gnt_ref;
>> +}
>> +
>>   static void xennet_alloc_rx_buffers(struct net_device *dev)
>>   {
>>          unsigned short id;
>> @@ -240,8 +328,6 @@ static void xennet_alloc_rx_buffers(struct net_d=
evice *dev)
>>          int i, batch_target, notify;
>>          RING_IDX req_prod =3D np->rx.req_prod_pvt;
>>          grant_ref_t ref;
>> -       unsigned long pfn;
>> -       void *vaddr;
>>          struct xen_netif_rx_request *req;
>>
>>          if (unlikely(!netif_carrier_ok(dev)))
>> @@ -306,19 +392,16 @@ no_skb:
>>                  BUG_ON(np->rx_skbs[id]);
>>                  np->rx_skbs[id] =3D skb;
>>
>> -               ref =3D gnttab_claim_grant_reference(&np->gref_rx_he=
ad);
>> -               BUG_ON((signed short)ref<  0);
>> -               np->grant_rx_ref[id] =3D ref;
>> +               page =3D skb_frag_page(&skb_shinfo(skb)->frags[0]);
>>
>> -               pfn =3D page_to_pfn(skb_frag_page(&skb_shinfo(skb)->=
frags[0]));
>> -               vaddr =3D page_address(skb_frag_page(&skb_shinfo(skb=
)->frags[0]));
>> +               ref =3D xennet_alloc_rx_ref(dev, pfn_to_mfn(page_to_=
pfn(page)),
>> +                                         page_address(page), id, 0)=
;
>> +               if ((signed short)ref<  0) {
>> +                       __skb_queue_tail(&np->rx_batch, skb);
>> +                       break;
>> +               }
>>
>>                  req =3D RING_GET_REQUEST(&np->rx, req_prod + i);
>> -               gnttab_grant_foreign_access_ref(ref,
>> -                                               np->xbdev->otherend_=
id,
>> -                                               pfn_to_mfn(pfn),
>> -                                               0);
>> -
>>                  req->id =3D id;
>>                  req->gref =3D ref;
>>          }
>> @@ -375,17 +458,30 @@ static void xennet_tx_buf_gc(struct net_device=
 *dev)
>>
>>                          id  =3D txrsp->id;
>>                          skb =3D np->tx_skbs[id].skb;
>> -                       if (unlikely(gnttab_query_foreign_access(
>> -                               np->grant_tx_ref[id]) !=3D 0)) {
>> -                               printk(KERN_ALERT "xennet_tx_buf_gc:=
 warning "
>> -                                      "-- grant still in use by bac=
kend "
>> -                                      "domain.\n");
>> -                               BUG();
>> +
>> +                       if (np->persistent_gnt) {
>> +                               struct gnt_list *gnt_list_entry;
>> +
>> +                               gnt_list_entry =3D np->tx_grant[id];
>> +                               BUG_ON(!gnt_list_entry);
>> +
>> +                               gnt_list_entry->tail =3D np->tx_gnt_=
list;
>> +                               np->tx_gnt_list =3D gnt_list_entry;
>> +                               np->tx_gnt_cnt++;
>> +                       } else {
>> +                               if (unlikely(gnttab_query_foreign_ac=
cess(
>> +                                       np->grant_tx_ref[id]) !=3D 0=
)) {
>> +                                       printk(KERN_ALERT "xennet_tx=
_buf_gc: warning "
>> +                                              "-- grant still in us=
e by backend "
>> +                                              "domain.\n");
>> +                                       BUG();
>> +                               }
>> +
>> +                               gnttab_end_foreign_access_ref(
>> +                                       np->grant_tx_ref[id], GNTMAP=
_readonly);
> If I've read the code correctly, you are giving this frame both
> read/write permissions to the other end on xennet_alloc_tx_ref, but t=
hen
> you are only removing the read permissions? (see comment below on the
> xennet_alloc_tx_ref function).

Yes, this is a bug.
=46or non persistent grant, it should remove the read permissions. For=20
persistent grant, it should remove both.
As mentioned above, it is better to enable persistent grant, I will=20
change code and not consider non persistent grant.
See comments below about why needing both permissions in=20
xennet_alloc_tx_ref.

>
>> +                               gnttab_release_grant_reference(
>> +&np->gref_tx_head, np->grant_tx_ref[id]);
>>                          }
>> -                       gnttab_end_foreign_access_ref(
>> -                               np->grant_tx_ref[id], GNTMAP_readonl=
y);
>> -                       gnttab_release_grant_reference(
>> -&np->gref_tx_head, np->grant_tx_ref[id]);
>>                          np->grant_tx_ref[id] =3D GRANT_INVALID_REF;
>>                          add_id_to_freelist(&np->tx_skb_freelist, np=
->tx_skbs, id);
>>                          dev_kfree_skb_irq(skb);
>> @@ -409,6 +505,59 @@ static void xennet_tx_buf_gc(struct net_device =
*dev)
>>          xennet_maybe_wake_tx(dev);
>>   }
>>
>> +static grant_ref_t xennet_alloc_tx_ref(struct net_device *dev,
>> +                                      unsigned long mfn,
>> +                                      unsigned int id)
>> +{
>> +       struct netfront_info *np =3D netdev_priv(dev);
>> +       grant_ref_t ref;
>> +       struct page *granted_page;
>> +
>> +       if (np->persistent_gnt&&  np->tx_gnt_cnt) {
>> +               struct gnt_list *gnt_list_entry;
>> +
>> +               gnt_list_entry =3D np->tx_gnt_list;
>> +               np->tx_gnt_list =3D np->tx_gnt_list->tail;
>> +               np->tx_gnt_cnt--;
>> +
>> +               ref =3D gnt_list_entry->gref;
>> +               np->tx_grant[id] =3D gnt_list_entry;
>> +       } else {
>> +               struct gnt_list *gnt_list_entry;
>> +
>> +               BUG_ON(!np->persistent_gnt&&  np->tx_gnt_cnt);
>> +               ref =3D gnttab_claim_grant_reference(&np->gref_tx_he=
ad);
>> +               BUG_ON((signed short)ref<  0);
>> +
>> +               if (np->persistent_gnt) {
>> +                       granted_page =3D alloc_page(GFP_KERNEL);
>> +                       if (!granted_page) {
>> +                               gnttab_release_grant_reference(
>> +&np->gref_tx_head, ref);
>> +                               return -ENOMEM;
>> +                       }
>> +
>> +                       mfn =3D pfn_to_mfn(page_to_pfn(granted_page)=
);
>> +                       gnt_list_entry =3D kmalloc(sizeof(struct gnt=
_list),
>> +                                                GFP_KERNEL);
>> +                       if (!gnt_list_entry) {
>> +                               __free_page(granted_page);
>> +                               gnttab_release_grant_reference(
>> +&np->gref_tx_head, ref);
>> +                               return -ENOMEM;
>> +                       }
>> +
>> +                       gnt_list_entry->gref =3D ref;
>> +                       gnt_list_entry->gnt_pages =3D granted_page;
>> +                       np->tx_grant[id] =3D gnt_list_entry;
>> +               }
>> +               gnttab_grant_foreign_access_ref(ref, np->xbdev->othe=
rend_id,
>> +                                               mfn, 0);
> If you are not always using persistent grants I guess you need to giv=
e
> read only permissions to this frame (GNTMAP_readonly).

We can not use GNTMAP_readonly here because tx path packet data will be=
=20
copied into these persistent grant pages. Mabbe it is better to use=20
GNTMAP_readonly for nonpersistent and 0 for persistent grant.
As mentioned above, it is better to enable persistent grant, I will=20
change code and not consider non persistent grant.

>   Also, for keeping
> things in logical order, isn't it best that this function comes befor=
e
> xennet_tx_buf_gc?

xennet_alloc_tx_ref is called by following function xennet_make_frags,=20
so I assume xennet_alloc_tx_ref is better to be close to=20
xennet_make_frags. Xennet_tx_buf_gc does not have any connection with=20
xennet_alloc_tx_ref, did I miss something?

>
>> +       }
>> +
>> +       return ref;
>> +}
>> +
>> @@ -1132,8 +1357,10 @@ static void xennet_release_rx_bufs(struct net=
front_info *np)
>>                  }
>>
>>                  skb =3D np->rx_skbs[id];
>> -               mfn =3D gnttab_end_foreign_transfer_ref(ref);
>> -               gnttab_release_grant_reference(&np->gref_rx_head, re=
f);
>> +               if (!np->persistent_gnt) {
>> +                       mfn =3D gnttab_end_foreign_transfer_ref(ref)=
;
>> +                       gnttab_release_grant_reference(&np->gref_rx_=
head, ref);
>> +               }
>>                  np->grant_rx_ref[id] =3D GRANT_INVALID_REF;
>>
>>                  if (0 =3D=3D mfn) {
>> @@ -1607,6 +1834,13 @@ again:
>>                  goto abort_transaction;
>>          }
>>
>> +       err =3D xenbus_printf(xbt, dev->nodename, "feature-persisten=
t-grants",
>> +                           "%u", info->persistent_gnt);
> As in netback, I think "feature-persistent" should be used.

Same in blkback, I assume it is  "feature-persistent-grants", right?
I referred your RFC patch, did you change it later? Or I missed somethi=
ng?

Thanks
Annie
>
>> +       if (err) {
>> +               message =3D "writing feature-persistent-grants";
>> +               xenbus_dev_fatal(dev, err, "%s", message);
>> +       }
>> +
>>          err =3D xenbus_transaction_end(xbt, 0);
>>          if (err) {
>>                  if (err =3D=3D -EAGAIN)
>> @@ -1634,6 +1868,7 @@ static int xennet_connect(struct net_device *d=
ev)
>>          grant_ref_t ref;
>>          struct xen_netif_rx_request *req;
>>          unsigned int feature_rx_copy;
>> +       int ret, val;
>>
>>          err =3D xenbus_scanf(XBT_NIL, np->xbdev->otherend,
>>                             "feature-rx-copy", "%u",&feature_rx_copy=
);
>> @@ -1646,6 +1881,13 @@ static int xennet_connect(struct net_device *=
dev)
>>                  return -ENODEV;
>>          }
>>
>> +       err =3D xenbus_scanf(XBT_NIL, np->xbdev->otherend,
>> +                          "feature-persistent-grants", "%u",&val);
>> +       if (err !=3D 1)
>> +               val =3D 0;
>> +
>> +       np->persistent_gnt =3D !!val;
>> +
>>          err =3D talk_to_netback(np->xbdev, np);
>>          if (err)
>>                  return err;
>> @@ -1657,9 +1899,24 @@ static int xennet_connect(struct net_device *=
dev)
>>          spin_lock_bh(&np->rx_lock);
>>          spin_lock_irq(&np->tx_lock);
>>
>> +       np->tx_gnt_cnt =3D 0;
>> +       np->rx_gnt_cnt =3D 0;
>> +
>>          /* Step 1: Discard all pending TX packet fragments. */
>>          xennet_release_tx_bufs(np);
>>
>> +       if (np->persistent_gnt) {
>> +               struct gnt_list *gnt_list_entry;
>> +
>> +               while (np->rx_gnt_list) {
>> +                       gnt_list_entry =3D np->rx_gnt_list;
>> +                       np->rx_gnt_list =3D np->rx_gnt_list->tail;
>> +                       gnttab_end_foreign_access(gnt_list_entry->gr=
ef, 0, 0UL);
>> +                       __free_page(gnt_list_entry->gnt_pages);
>> +                       kfree(gnt_list_entry);
>> +               }
>> +       }
>> +
>>          /* Step 2: Rebuild the RX buffer freelist and the RX ring i=
tself. */
>>          for (requeue_idx =3D 0, i =3D 0; i<  NET_RX_RING_SIZE; i++)=
 {
>>                  skb_frag_t *frag;
>> @@ -1673,10 +1930,11 @@ static int xennet_connect(struct net_device =
*dev)
>>
>>                  frag =3D&skb_shinfo(skb)->frags[0];
>>                  page =3D skb_frag_page(frag);
>> -               gnttab_grant_foreign_access_ref(
>> -                       ref, np->xbdev->otherend_id,
>> -                       pfn_to_mfn(page_to_pfn(page)),
>> -                       0);
>> +               ret =3D xennet_alloc_rx_ref(dev, pfn_to_mfn(page_to_=
pfn(page)),
>> +                                         page_address(page), requeu=
e_idx, ref);
>> +               if ((signed short)ret<  0)
>> +                       break;
>> +
>>                  req->gref =3D ref;
>>                  req->id   =3D requeue_idx;
>>
>> --
>> 1.7.3.4
>>
>>
>> _______________________________________________
>> Xen-devel mailing list
>> Xen-devel@lists.xen.org
>> http://lists.xen.org/xen-devel
>>
