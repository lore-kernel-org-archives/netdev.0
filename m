From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH 1/4] xen/netback: implements persistent grant
 with one page pool.
Date: Fri, 16 Nov 2012 10:49:51 +0800
Message-ID: <50A5A9CF.8030008@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com> <1352963066-570-1-git-send-email-annie.li@oracle.com> <50A4BC7D.6060707@citrix.com>
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
Received: from userp1040.oracle.com ([156.151.31.81]:38970 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169Ab2KPCuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 21:50:02 -0500
In-Reply-To: <50A4BC7D.6060707@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-11-15 17:57, Roger Pau Monn=E9 wrote:
> On 15/11/12 08:04, Annie Li wrote:
>> This patch implements persistent grant in netback driver. Tx and rx
>> share the same page pool, this pool will be split into two parts
>> in next patch.
>>
>> Signed-off-by: Annie Li<annie.li@oracle.com>
>> ---
>>   drivers/net/xen-netback/common.h    |   18 +++-
>>   drivers/net/xen-netback/interface.c |   22 ++++
>>   drivers/net/xen-netback/netback.c   |  212 +++++++++++++++++++++++=
++++++++----
>>   drivers/net/xen-netback/xenbus.c    |   14 ++-
>>   4 files changed, 239 insertions(+), 27 deletions(-)
>>
>> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netb=
ack/common.h
>> index 94b79c3..a85cac6 100644
>> --- a/drivers/net/xen-netback/common.h
>> +++ b/drivers/net/xen-netback/common.h
>> @@ -45,8 +45,19 @@
>>   #include<xen/grant_table.h>
>>   #include<xen/xenbus.h>
>>
>> +#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE=
_SIZE)
>> +#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE=
_SIZE)
>> +#define MAXIMUM_OUTSTANDING_BLOCK_REQS \
>> +                       (XEN_NETIF_TX_RING_SIZE + XEN_NETIF_RX_RING_=
SIZE)
>> +
>>   struct xen_netbk;
>>
>> +struct persistent_entry {
>> +       grant_ref_t forgranted;
>> +       struct page *fpage;
>> +       struct gnttab_map_grant_ref map;
>> +};
> This should be common with the blkback implementation, I think we sho=
uld
> move some structures/functions from blkback to a common place. When I
> implementated some functions in blkback I though they could be reused=
 by
> other backends that wanted to use persistent grants, so I keep them f=
ree
> of blkback specific structures.

Good idea, thanks.

>
>>   struct xenvif {
>>          /* Unique identifier for this interface. */
>>          domid_t          domid;
>> @@ -75,6 +86,7 @@ struct xenvif {
>>
>>          /* Internal feature information. */
>>          u8 can_queue:1;     /* can queue packets for receiver? */
>> +       u8 persistent_grant:1;
>>
>>          /*
>>           * Allow xenvif_start_xmit() to peek ahead in the rx reques=
t
>> @@ -98,6 +110,9 @@ struct xenvif {
>>          struct net_device *dev;
>>
>>          wait_queue_head_t waiting_to_free;
>> +
>> +       struct persistent_entry *persistent_gnt[MAXIMUM_OUTSTANDING_=
BLOCK_REQS];
>> +       unsigned int persistent_gntcnt;
> This should be a red-black tree, which has the property of a search t=
ime
> <=3D O(log n), using an array is more expensive in terms of memory an=
d has
> a worse search time O(n), this is specially interesting for netback,
> which can have twice as much persistent grants as blkback (because tw=
o
> rings are used).

Right, thanks.

>
> Take a look at the following functions from blkback; foreach_grant,
> add_persistent_gnt and get_persistent_gnt. They are generic functions=
 to
> deal with persistent grants.

Ok, thanks.
Or moving those functions into a separate common file?

>
>>   };
>>
>>   static inline struct xenbus_device *xenvif_to_xenbus_device(struct=
 xenvif *vif)
>> @@ -105,9 +120,6 @@ static inline struct xenbus_device *xenvif_to_xe=
nbus_device(struct xenvif *vif)
>>          return to_xenbus_device(vif->dev->dev.parent);
>>   }
>>
>> -#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE=
_SIZE)
>> -#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE=
_SIZE)
>> -
>>   struct xenvif *xenvif_alloc(struct device *parent,
>>                              domid_t domid,
>>                              unsigned int handle);
>> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-n=
etback/interface.c
>> index b7d41f8..226d159 100644
>> --- a/drivers/net/xen-netback/interface.c
>> +++ b/drivers/net/xen-netback/interface.c
>> @@ -300,6 +300,8 @@ struct xenvif *xenvif_alloc(struct device *paren=
t, domid_t domid,
>>                  return ERR_PTR(err);
>>          }
>>
>> +       vif->persistent_gntcnt =3D 0;
>> +
>>          netdev_dbg(dev, "Successfully created xenvif\n");
>>          return vif;
>>   }
>> @@ -343,6 +345,23 @@ err:
>>          return err;
>>   }
>>
>> +void xenvif_free_grants(struct persistent_entry **pers_entry,
>> +                       unsigned int count)
>> +{
>> +       int i, ret;
>> +       struct gnttab_unmap_grant_ref unmap;
>> +
>> +       for (i =3D 0; i<  count; i++) {
>> +               gnttab_set_unmap_op(&unmap,
>> +                       (unsigned long)page_to_pfn(pers_entry[i]->fp=
age),
>> +                       GNTMAP_host_map,
>> +                       pers_entry[i]->map.handle);
>> +               ret =3D gnttab_unmap_refs(&unmap,&pers_entry[i]->fpa=
ge,
>> +                                       1, false);
> This is not correct, you should call gnttab_set_unmap_op on a batch o=
f
> grants (up to BLKIF_MAX_SEGMENTS_PER_REQUEST), and then call
> gnttab_unmap_refs on all of them. Here is a simple example (take a lo=
ok
> at blkback.c function xen_blkif_schedule to see an example with a
> red-black tree, I think this part of the code should also be made com=
mon):
>
> for (i =3D 0, segs_to_unmap =3D 0; i<  count; i++) {
> 	gnttab_set_unmap_op(&unmap[segs_to_unmap],
> 		(unsigned long)page_to_pfn(pers_entry[i]->fpage),
> 		GNTMAP_host_map,
> 		pers_entry[i]->map.handle);
> 	pages[segs_to_unmap] =3D
> 		(unsigned long)page_to_pfn(pers_entry[i]->fpage);
> 	if (++segs_to_unmap =3D=3D BLKIF_MAX_SEGMENTS_PER_REQUEST ||
> 		(i + 1) =3D=3D count) {
> 		ret =3D gnttab_unmap_refs(unmap, NULL, pages,
> 			segs_to_unmap);
> 		BUG_ON(ret);
> 		segs_to_unmap =3D=3D 0;
> 	}
> }

Got it, thanks.

>
>> +               BUG_ON(ret);
>> +       }
>> +}
>> +
>>   void xenvif_disconnect(struct xenvif *vif)
>>   {
>>          struct net_device *dev =3D vif->dev;
>> @@ -366,6 +385,9 @@ void xenvif_disconnect(struct xenvif *vif)
>>          unregister_netdev(vif->dev);
>>
>>          xen_netbk_unmap_frontend_rings(vif);
>> +       if (vif->persistent_grant)
>> +               xenvif_free_grants(vif->persistent_gnt,
>> +                                  vif->persistent_gntcnt);
>>
>>          free_netdev(vif->dev);
>>   }
>> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-net=
back/netback.c
>> index 2596401..a26d3fc 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -80,6 +80,8 @@ union page_ext {
>>          void *mapping;
>>   };
>>
>> +struct xenvif;
>> +
>>   struct xen_netbk {
>>          wait_queue_head_t wq;
>>          struct task_struct *task;
>> @@ -102,6 +104,7 @@ struct xen_netbk {
>>
>>          struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
>>          struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS];
>> +       struct xenvif *gnttab_tx_vif[MAX_PENDING_REQS];
>>
>>          u16 pending_ring[MAX_PENDING_REQS];
>>
>> @@ -111,12 +114,139 @@ struct xen_netbk {
>>           * straddles two buffers in the frontend.
>>           */
>>          struct gnttab_copy grant_copy_op[2*XEN_NETIF_RX_RING_SIZE];
>> +       struct xenvif *gnttab_rx_vif[2*XEN_NETIF_RX_RING_SIZE];
>>          struct netbk_rx_meta meta[2*XEN_NETIF_RX_RING_SIZE];
>>   };
>>
>>   static struct xen_netbk *xen_netbk;
>>   static int xen_netbk_group_nr;
>>
>> +static struct persistent_entry*
>> +get_per_gnt(struct persistent_entry **pers_entry,
>> +           unsigned int count, grant_ref_t gref)
>> +{
>> +       int i;
>> +
>> +       for (i =3D 0; i<  count; i++)
>> +               if (gref =3D=3D pers_entry[i]->forgranted)
>> +                       return pers_entry[i];
>> +
>> +       return NULL;
>> +}
> This should be replaced with common code shared with all persistent
> backends implementations.

Ok, thanks.

>
>> +
>> +static void*
>> +map_new_gnt(struct persistent_entry **pers_entry, unsigned int coun=
t,
>> +           grant_ref_t ref, domid_t domid)
>> +{
>> +       struct gnttab_map_grant_ref *map;
>> +       struct page *page;
>> +       unsigned long vaddr;
>> +       unsigned long pfn;
>> +       uint32_t flags;
>> +       int ret =3D 0;
>> +
>> +       pers_entry[count] =3D (struct persistent_entry *)
>> +                           kmalloc(sizeof(struct persistent_entry),
>> +                                   GFP_KERNEL);
>> +       if (!pers_entry[count])
>> +               return ERR_PTR(-ENOMEM);
>> +
>> +       map =3D&pers_entry[count]->map;
>> +       page =3D alloc_page(GFP_KERNEL);
>> +       if (!page) {
>> +               kfree(pers_entry[count]);
>> +               pers_entry[count] =3D NULL;
>> +               return ERR_PTR(-ENOMEM);
>> +       }
>> +
>> +       pers_entry[count]->fpage =3D page;
>> +       pfn =3D page_to_pfn(page);
>> +       vaddr =3D (unsigned long)pfn_to_kaddr(pfn);
>> +       flags =3D GNTMAP_host_map;
>> +
>> +       gnttab_set_map_op(map, vaddr, flags, ref, domid);
>> +       ret =3D gnttab_map_refs(map, NULL,&page, 1);
>> +       BUG_ON(ret);
> This is highly inefficient, one of the points of using gnttab_set_map=
_op
> is that you can queue a bunch of grants, and then map them at the sam=
e
> time using gnttab_map_refs, but here you are using it to map a single
> grant at a time. You should instead see how much grants you need to m=
ap
> to complete the request and map them all at the same time.

Yes, it is inefficient here. But this is limited by current netback=20
implementation. Current netback is not per-VIF based(not like blkback=20
does). After combining persistent grant and non persistent grant=20
together, every vif request in the queue may/may not support persistent=
=20
grant. I have to judge whether every vif in the queue supports=20
persistent grant or not. If it support, memcpy is used, if not,=20
grantcopy is used.
After making netback per-VIF works, this issue can be fixed.

>
>> +
>> +       pers_entry[count]->forgranted =3D ref;
>> +
>> +       return page_address(page);
>> +}
>> +
>> +static void*
>> +get_ref_page(struct persistent_entry **pers_entry, unsigned int *co=
unt,
>> +            grant_ref_t ref, domid_t domid, unsigned int total)
>> +{
>> +       struct persistent_entry *per_gnt;
>> +       void *vaddr;
>> +
>> +       per_gnt =3D get_per_gnt(pers_entry, *count, ref);
>> +
>> +       if (per_gnt !=3D NULL)
>> +               return page_address(per_gnt->fpage);
>> +       else {
>> +               BUG_ON(*count>=3D total);
>> +               vaddr =3D map_new_gnt(pers_entry, *count, ref, domid=
);
>> +               if (IS_ERR_OR_NULL(vaddr))
>> +                       return vaddr;
>> +               *count +=3D 1;
>> +               return vaddr;
>> +       }
>> +}
>> +
>> +static int
>> +grant_memory_copy_op(unsigned int cmd, void *vuop, unsigned int cou=
nt,
>> +                    struct xen_netbk *netbk, bool tx_pool)
>> +{
>> +       int i;
>> +       struct xenvif *vif;
>> +       struct gnttab_copy *uop =3D vuop;
>> +       unsigned int *gnt_count;
>> +       unsigned int gnt_total;
>> +       struct persistent_entry **pers_entry;
>> +       int ret =3D 0;
>> +
>> +       BUG_ON(cmd !=3D GNTTABOP_copy);
>> +       for (i =3D 0; i<  count; i++) {
>> +               if (tx_pool)
>> +                       vif =3D netbk->gnttab_tx_vif[i];
>> +               else
>> +                       vif =3D netbk->gnttab_rx_vif[i];
>> +
>> +               pers_entry =3D vif->persistent_gnt;
>> +               gnt_count =3D&vif->persistent_gntcnt;
>> +               gnt_total =3D MAXIMUM_OUTSTANDING_BLOCK_REQS;
>> +
>> +               if (vif->persistent_grant) {
>> +                       void *saddr, *daddr;
>> +
>> +                       saddr =3D uop[i].source.domid =3D=3D DOMID_S=
ELF ?
>> +                               (void *) uop[i].source.u.gmfn :
>> +                               get_ref_page(pers_entry, gnt_count,
>> +                                            uop[i].source.u.ref,
>> +                                            uop[i].source.domid,
>> +                                            gnt_total);
>> +                       if (IS_ERR_OR_NULL(saddr))
>> +                               return -ENOMEM;
>> +
>> +                       daddr =3D uop[i].dest.domid =3D=3D DOMID_SEL=
=46 ?
>> +                               (void *) uop[i].dest.u.gmfn :
>> +                               get_ref_page(pers_entry, gnt_count,
>> +                                            uop[i].dest.u.ref,
>> +                                            uop[i].dest.domid,
>> +                                            gnt_total);
>> +                       if (IS_ERR_OR_NULL(daddr))
>> +                               return -ENOMEM;
>> +
>> +                       memcpy(daddr+uop[i].dest.offset,
>> +                              saddr+uop[i].source.offset, uop[i].le=
n);
>> +               } else
>> +                       ret =3D HYPERVISOR_grant_table_op(cmd,&uop[i=
], 1);
>> +       }
>> +
>> +       return ret;
>> +}
>> +
>>   void xen_netbk_add_xenvif(struct xenvif *vif)
>>   {
>>          int i;
>> @@ -387,13 +517,15 @@ static struct netbk_rx_meta *get_next_rx_buffe=
r(struct xenvif *vif,
>>    * Set up the grant operations for this fragment. If it's a flippi=
ng
>>    * interface, we also set up the unmap request from here.
>>    */
>> -static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff =
*skb,
>> -                               struct netrx_pending_operations *npo=
,
>> -                               struct page *page, unsigned long siz=
e,
>> -                               unsigned long offset, int *head)
>> +static int netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *=
skb,
>> +                              struct netrx_pending_operations *npo,
>> +                              struct page *page, unsigned long size=
,
>> +                              unsigned long offset, int *head,
>> +                              struct xenvif **grxvif)
>>   {
>>          struct gnttab_copy *copy_gop;
>>          struct netbk_rx_meta *meta;
>> +       int count =3D 0;
>>          /*
>>           * These variables are used iff get_page_ext returns true,
>>           * in which case they are guaranteed to be initialized.
>> @@ -425,6 +557,10 @@ static void netbk_gop_frag_copy(struct xenvif *=
vif, struct sk_buff *skb,
>>                          bytes =3D MAX_BUFFER_OFFSET - npo->copy_off=
;
>>
>>                  copy_gop =3D npo->copy + npo->copy_prod++;
>> +               *grxvif =3D vif;
>> +               grxvif++;
>> +               count++;
>> +
>>                  copy_gop->flags =3D GNTCOPY_dest_gref;
>>                  if (foreign) {
>>                          struct xen_netbk *netbk =3D&xen_netbk[group=
];
>> @@ -438,7 +574,10 @@ static void netbk_gop_frag_copy(struct xenvif *=
vif, struct sk_buff *skb,
>>                  } else {
>>                          void *vaddr =3D page_address(page);
>>                          copy_gop->source.domid =3D DOMID_SELF;
>> -                       copy_gop->source.u.gmfn =3D virt_to_mfn(vadd=
r);
>> +                       if (!vif->persistent_grant)
>> +                               copy_gop->source.u.gmfn =3D virt_to_=
mfn(vaddr);
>> +                       else
>> +                               copy_gop->source.u.gmfn =3D (unsigne=
d long)vaddr;
>>                  }
>>                  copy_gop->source.offset =3D offset;
>>                  copy_gop->dest.domid =3D vif->domid;
>> @@ -460,6 +599,7 @@ static void netbk_gop_frag_copy(struct xenvif *v=
if, struct sk_buff *skb,
>>                  *head =3D 0; /* There must be something in this buf=
fer now. */
>>
>>          }
>> +       return count;
>>   }
>>
>>   /*
>> @@ -474,8 +614,10 @@ static void netbk_gop_frag_copy(struct xenvif *=
vif, struct sk_buff *skb,
>>    * zero GSO descriptors (for non-GSO packets) or one descriptor (f=
or
>>    * frontend-side LRO).
>>    */
>> -static int netbk_gop_skb(struct sk_buff *skb,
>> -                        struct netrx_pending_operations *npo)
>> +static int netbk_gop_skb(struct xen_netbk *netbk,
>> +                        struct sk_buff *skb,
>> +                        struct netrx_pending_operations *npo,
>> +                        struct xenvif **grxvif)
>>   {
>>          struct xenvif *vif =3D netdev_priv(skb->dev);
>>          int nr_frags =3D skb_shinfo(skb)->nr_frags;
>> @@ -518,17 +660,19 @@ static int netbk_gop_skb(struct sk_buff *skb,
>>                  if (data + len>  skb_tail_pointer(skb))
>>                          len =3D skb_tail_pointer(skb) - data;
>>
>> -               netbk_gop_frag_copy(vif, skb, npo,
>> -                                   virt_to_page(data), len, offset,=
&head);
>> +               grxvif +=3D netbk_gop_frag_copy(vif, skb, npo,
>> +                                             virt_to_page(data), le=
n,
>> +                                             offset,&head, grxvif);
>> +
>>                  data +=3D len;
>>          }
>>
>>          for (i =3D 0; i<  nr_frags; i++) {
>> -               netbk_gop_frag_copy(vif, skb, npo,
>> -                                   skb_frag_page(&skb_shinfo(skb)->=
frags[i]),
>> -                                   skb_frag_size(&skb_shinfo(skb)->=
frags[i]),
>> -                                   skb_shinfo(skb)->frags[i].page_o=
ffset,
>> -&head);
>> +               grxvif +=3D netbk_gop_frag_copy(vif, skb, npo,
>> +                               skb_frag_page(&skb_shinfo(skb)->frag=
s[i]),
>> +                               skb_frag_size(&skb_shinfo(skb)->frag=
s[i]),
>> +                               skb_shinfo(skb)->frags[i].page_offse=
t,
>> +&head, grxvif);
>>          }
>>
>>          return npo->meta_prod - old_meta_prod;
>> @@ -593,6 +737,8 @@ struct skb_cb_overlay {
>>   static void xen_netbk_rx_action(struct xen_netbk *netbk)
>>   {
>>          struct xenvif *vif =3D NULL, *tmp;
>> +       struct xenvif **grxvif =3D netbk->gnttab_rx_vif;
>> +       int old_copy_prod =3D 0;
>>          s8 status;
>>          u16 irq, flags;
>>          struct xen_netif_rx_response *resp;
>> @@ -619,7 +765,9 @@ static void xen_netbk_rx_action(struct xen_netbk=
 *netbk)
>>                  nr_frags =3D skb_shinfo(skb)->nr_frags;
>>
>>                  sco =3D (struct skb_cb_overlay *)skb->cb;
>> -               sco->meta_slots_used =3D netbk_gop_skb(skb,&npo);
>> +               sco->meta_slots_used =3D netbk_gop_skb(netbk, skb,&n=
po, grxvif);
>> +               grxvif +=3D npo.copy_prod - old_copy_prod;
>> +               old_copy_prod =3D npo.copy_prod;
>>
>>                  count +=3D nr_frags + 1;
>>
>> @@ -636,8 +784,10 @@ static void xen_netbk_rx_action(struct xen_netb=
k *netbk)
>>                  return;
>>
>>          BUG_ON(npo.copy_prod>  ARRAY_SIZE(netbk->grant_copy_op));
>> -       ret =3D HYPERVISOR_grant_table_op(GNTTABOP_copy,&netbk->gran=
t_copy_op,
>> -                                       npo.copy_prod);
>> +       ret =3D grant_memory_copy_op(GNTTABOP_copy,
>> +&netbk->grant_copy_op,
>> +                                  npo.copy_prod, netbk,
>> +                                  false);
>>          BUG_ON(ret !=3D 0);
>>
>>          while ((skb =3D __skb_dequeue(&rxq)) !=3D NULL) {
>> @@ -918,7 +1068,8 @@ static struct gnttab_copy *xen_netbk_get_reques=
ts(struct xen_netbk *netbk,
>>                                                    struct xenvif *vi=
f,
>>                                                    struct sk_buff *s=
kb,
>>                                                    struct xen_netif_=
tx_request *txp,
>> -                                                 struct gnttab_copy=
 *gop)
>> +                                                 struct gnttab_copy=
 *gop,
>> +                                                 struct xenvif **gt=
xvif)
>>   {
>>          struct skb_shared_info *shinfo =3D skb_shinfo(skb);
>>          skb_frag_t *frags =3D shinfo->frags;
>> @@ -944,7 +1095,11 @@ static struct gnttab_copy *xen_netbk_get_reque=
sts(struct xen_netbk *netbk,
>>                  gop->source.domid =3D vif->domid;
>>                  gop->source.offset =3D txp->offset;
>>
>> -               gop->dest.u.gmfn =3D virt_to_mfn(page_address(page))=
;
>> +               if (!vif->persistent_grant)
>> +                       gop->dest.u.gmfn =3D virt_to_mfn(page_addres=
s(page));
>> +               else
>> +                       gop->dest.u.gmfn =3D (unsigned long)page_add=
ress(page);
>> +
>>                  gop->dest.domid =3D DOMID_SELF;
>>                  gop->dest.offset =3D txp->offset;
>>
>> @@ -952,6 +1107,9 @@ static struct gnttab_copy *xen_netbk_get_reques=
ts(struct xen_netbk *netbk,
>>                  gop->flags =3D GNTCOPY_source_gref;
>>
>>                  gop++;
>> +               *gtxvif =3D vif;
>> +               gtxvif++;
>> +
>>
>>                  memcpy(&pending_tx_info[pending_idx].req, txp, size=
of(*txp));
>>                  xenvif_get(vif);
>> @@ -1218,6 +1376,7 @@ static bool tx_credit_exceeded(struct xenvif *=
vif, unsigned size)
>>   static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
>>   {
>>          struct gnttab_copy *gop =3D netbk->tx_copy_ops, *request_go=
p;
>> +       struct xenvif **gtxvif =3D netbk->gnttab_tx_vif;
>>          struct sk_buff *skb;
>>          int ret;
>>
>> @@ -1338,7 +1497,11 @@ static unsigned xen_netbk_tx_build_gops(struc=
t xen_netbk *netbk)
>>                  gop->source.domid =3D vif->domid;
>>                  gop->source.offset =3D txreq.offset;
>>
>> -               gop->dest.u.gmfn =3D virt_to_mfn(page_address(page))=
;
>> +               if (!vif->persistent_grant)
>> +                       gop->dest.u.gmfn =3D virt_to_mfn(page_addres=
s(page));
>> +               else
>> +                       gop->dest.u.gmfn =3D (unsigned long)page_add=
ress(page);
>> +
>>                  gop->dest.domid =3D DOMID_SELF;
>>                  gop->dest.offset =3D txreq.offset;
>>
>> @@ -1346,6 +1509,7 @@ static unsigned xen_netbk_tx_build_gops(struct=
 xen_netbk *netbk)
>>                  gop->flags =3D GNTCOPY_source_gref;
>>
>>                  gop++;
>> +               *gtxvif++ =3D vif;
>>
>>                  memcpy(&netbk->pending_tx_info[pending_idx].req,
>>                         &txreq, sizeof(txreq));
>> @@ -1369,12 +1533,13 @@ static unsigned xen_netbk_tx_build_gops(stru=
ct xen_netbk *netbk)
>>                  netbk->pending_cons++;
>>
>>                  request_gop =3D xen_netbk_get_requests(netbk, vif,
>> -                                                    skb, txfrags, g=
op);
>> +                                                    skb, txfrags, g=
op, gtxvif);
>>                  if (request_gop =3D=3D NULL) {
>>                          kfree_skb(skb);
>>                          netbk_tx_err(vif,&txreq, idx);
>>                          continue;
>>                  }
>> +               gtxvif +=3D request_gop - gop;
>>                  gop =3D request_gop;
>>
>>                  vif->tx.req_cons =3D idx;
>> @@ -1467,8 +1632,9 @@ static void xen_netbk_tx_action(struct xen_net=
bk *netbk)
>>
>>          if (nr_gops =3D=3D 0)
>>                  return;
>> -       ret =3D HYPERVISOR_grant_table_op(GNTTABOP_copy,
>> -                                       netbk->tx_copy_ops, nr_gops)=
;
>> +       ret =3D grant_memory_copy_op(GNTTABOP_copy,
>> +                                  netbk->tx_copy_ops, nr_gops,
>> +                                  netbk, true);
>>          BUG_ON(ret);
>>
>>          xen_netbk_tx_submit(netbk);
>> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netb=
ack/xenbus.c
>> index 410018c..938e908 100644
>> --- a/drivers/net/xen-netback/xenbus.c
>> +++ b/drivers/net/xen-netback/xenbus.c
>> @@ -114,6 +114,13 @@ static int netback_probe(struct xenbus_device *=
dev,
>>                          goto abort_transaction;
>>                  }
>>
>> +               err =3D xenbus_printf(xbt, dev->nodename,
>> +                                   "feature-persistent-grants", "%u=
", 1);
>> +               if (err) {
>> +                       message =3D "writing feature-persistent-gran=
ts";
>> +                       goto abort_transaction;
>> +               }
>> +
>>                  err =3D xenbus_transaction_end(xbt, 0);
>>          } while (err =3D=3D -EAGAIN);
>>
>> @@ -453,7 +460,12 @@ static int connect_rings(struct backend_info *b=
e)
>>                  val =3D 0;
>>          vif->csum =3D !val;
>>
>> -       /* Map the shared frame, irq etc. */
>> +       if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-persistent=
-grants",
>> +                        "%u",&val)<  0)
> In block devices "feature-persistent" is used, so I think that for
> clearness it should be announced the same way in net.
Is it  "feature-persistent" ? I checked your RFC patch, the key is=20
"feature-persistent-grants".

Thanks
Annie
>
>> +               val =3D 0;
>> +       vif->persistent_grant =3D !!val;
>> +
>> +/* Map the shared frame, irq etc. */
>>          err =3D xenvif_connect(vif, tx_ring_ref, rx_ring_ref, evtch=
n);
>>          if (err) {
>>                  xenbus_dev_fatal(dev, err,
>> --
>> 1.7.3.4
>>
>>
>> _______________________________________________
>> Xen-devel mailing list
>> Xen-devel@lists.xen.org
>> http://lists.xen.org/xen-devel
>>
