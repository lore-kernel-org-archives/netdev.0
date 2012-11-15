From: =?ISO-8859-1?Q?Roger_Pau_Monn=E9?= <roger.pau@citrix.com>
Subject: Re: [Xen-devel] [PATCH 3/4] Xen/netfront: Implement persistent grant
 in netfront.
Date: Thu, 15 Nov 2012 11:52:55 +0100
Message-ID: <50A4C987.3020308@citrix.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com> <1352963114-628-1-git-send-email-annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Annie Li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:14213 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964838Ab2KOKw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 05:52:58 -0500
In-Reply-To: <1352963114-628-1-git-send-email-annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/11/12 08:05, Annie Li wrote:
> Tx/rx page pool are maintained. New grant is mapped and put into
> pool, unmap only happens when releasing/removing device.
> 
> Signed-off-by: Annie Li <annie.li@oracle.com>
> ---
>  drivers/net/xen-netfront.c |  372 +++++++++++++++++++++++++++++++++++++-------
>  1 files changed, 315 insertions(+), 57 deletions(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 0ebbb19..17b81c0 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -79,6 +79,13 @@ struct netfront_stats {
>         struct u64_stats_sync   syncp;
>  };
> 
> +struct gnt_list {
> +       grant_ref_t             gref;
> +       struct                  page *gnt_pages;
> +       void                    *gnt_target;
> +       struct                  gnt_list *tail;
> +};

This could also be shared with blkfront.

> +
>  struct netfront_info {
>         struct list_head list;
>         struct net_device *netdev;
> @@ -109,6 +116,10 @@ struct netfront_info {
>         grant_ref_t grant_tx_ref[NET_TX_RING_SIZE];
>         unsigned tx_skb_freelist;
> 
> +       struct gnt_list *tx_grant[NET_TX_RING_SIZE];
> +       struct gnt_list *tx_gnt_list;
> +       unsigned int tx_gnt_cnt;

I don't understand this, why do you need both an array and a list? I'm
not familiar with net code, so I don't know if this is some kind of
special netfront thing?

Anyway if you have to use a list I would recommend using one of the list
constructions that's already in the kernel, it simplifies the code and
makes it more easy to understand than creating your own list structure.

> +
>         spinlock_t   rx_lock ____cacheline_aligned_in_smp;
>         struct xen_netif_rx_front_ring rx;
>         int rx_ring_ref;
> @@ -126,6 +137,10 @@ struct netfront_info {
>         grant_ref_t gref_rx_head;
>         grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
> 
> +       struct gnt_list *rx_grant[NET_RX_RING_SIZE];
> +       struct gnt_list *rx_gnt_list;
> +       unsigned int rx_gnt_cnt;

Same comment above here.

> +
>         unsigned long rx_pfn_array[NET_RX_RING_SIZE];
>         struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
>         struct mmu_update rx_mmu[NET_RX_RING_SIZE];
> @@ -134,6 +149,7 @@ struct netfront_info {
>         struct netfront_stats __percpu *stats;
> 
>         unsigned long rx_gso_checksum_fixup;
> +       u8 persistent_gnt:1;
>  };
> 
>  struct netfront_rx_info {
> @@ -194,6 +210,16 @@ static grant_ref_t xennet_get_rx_ref(struct netfront_info *np,
>         return ref;
>  }
> 
> +static struct gnt_list *xennet_get_rx_grant(struct netfront_info *np,
> +                                           RING_IDX ri)
> +{
> +       int i = xennet_rxidx(ri);
> +       struct gnt_list *gntlist = np->rx_grant[i];
> +       np->rx_grant[i] = NULL;

Ok, I think I get why do you need both an array and a list, is that
because netfront doesn't have some kind of shadow ring to keep track of
issued requests?

So each issued request has an associated gnt_list with the list of used
grants? If so it would be good to add a comment about it.

> +       return gntlist;
> +}
> +
>  #ifdef CONFIG_SYSFS
>  static int xennet_sysfs_addif(struct net_device *netdev);
>  static void xennet_sysfs_delif(struct net_device *netdev);
> @@ -231,6 +257,68 @@ static void xennet_maybe_wake_tx(struct net_device *dev)
>                 netif_wake_queue(dev);
>  }
> 
> +static grant_ref_t xennet_alloc_rx_ref(struct net_device *dev,
> +                                      unsigned long mfn, void *vaddr,
> +                                      unsigned int id,
> +                                      grant_ref_t ref)
> +{
> +       struct netfront_info *np = netdev_priv(dev);
> +       grant_ref_t gnt_ref;
> +       struct gnt_list *gnt_list_entry;
> +
> +       if (np->persistent_gnt && np->rx_gnt_cnt) {
> +               gnt_list_entry = np->rx_gnt_list;
> +               np->rx_gnt_list = np->rx_gnt_list->tail;
> +               np->rx_gnt_cnt--;
> +
> +               gnt_list_entry->gnt_target = vaddr;
> +               gnt_ref = gnt_list_entry->gref;
> +               np->rx_grant[id] = gnt_list_entry;
> +       } else {
> +               struct page *page;
> +
> +               BUG_ON(!np->persistent_gnt && np->rx_gnt_cnt);
> +               if (!ref)
> +                       gnt_ref =
> +                               gnttab_claim_grant_reference(&np->gref_rx_head);
> +               else
> +                       gnt_ref = ref;
> +               BUG_ON((signed short)gnt_ref < 0);
> +
> +               if (np->persistent_gnt) {

So you are only using persistent grants if the backend also supports
them. Have you benchmarked the performance of a persistent frontend with
a non-persistent backend. In the block case, usign a persistent frontend
with a non-persistent backend let to an overall performance improvement,
so blkfront uses persistent grants even if blkback doesn't support them.
Take a look at the following graph:

http://xenbits.xen.org/people/royger/persistent_grants/nonpers_read.png

> +                       page = alloc_page(GFP_KERNEL);
> +                       if (!page) {
> +                               if (!ref)
> +                                       gnttab_release_grant_reference(
> +                                                       &np->gref_rx_head, ref);
> +                               return -ENOMEM;
> +                       }
> +                       mfn = pfn_to_mfn(page_to_pfn(page));
> +
> +                       gnt_list_entry = kmalloc(sizeof(struct gnt_list),
> +                                                GFP_KERNEL);
> +                       if (!gnt_list_entry) {
> +                               __free_page(page);
> +                               if (!ref)
> +                                       gnttab_release_grant_reference(
> +                                                       &np->gref_rx_head, ref);
> +                               return -ENOMEM;
> +                       }
> +                       gnt_list_entry->gref = gnt_ref;
> +                       gnt_list_entry->gnt_pages = page;
> +                       gnt_list_entry->gnt_target = vaddr;
> +
> +                       np->rx_grant[id] = gnt_list_entry;
> +               }
> +
> +               gnttab_grant_foreign_access_ref(gnt_ref, np->xbdev->otherend_id,
> +                                               mfn, 0);
> +       }
> +       np->grant_rx_ref[id] = gnt_ref;
> +
> +       return gnt_ref;
> +}
> +
>  static void xennet_alloc_rx_buffers(struct net_device *dev)
>  {
>         unsigned short id;
> @@ -240,8 +328,6 @@ static void xennet_alloc_rx_buffers(struct net_device *dev)
>         int i, batch_target, notify;
>         RING_IDX req_prod = np->rx.req_prod_pvt;
>         grant_ref_t ref;
> -       unsigned long pfn;
> -       void *vaddr;
>         struct xen_netif_rx_request *req;
> 
>         if (unlikely(!netif_carrier_ok(dev)))
> @@ -306,19 +392,16 @@ no_skb:
>                 BUG_ON(np->rx_skbs[id]);
>                 np->rx_skbs[id] = skb;
> 
> -               ref = gnttab_claim_grant_reference(&np->gref_rx_head);
> -               BUG_ON((signed short)ref < 0);
> -               np->grant_rx_ref[id] = ref;
> +               page = skb_frag_page(&skb_shinfo(skb)->frags[0]);
> 
> -               pfn = page_to_pfn(skb_frag_page(&skb_shinfo(skb)->frags[0]));
> -               vaddr = page_address(skb_frag_page(&skb_shinfo(skb)->frags[0]));
> +               ref = xennet_alloc_rx_ref(dev, pfn_to_mfn(page_to_pfn(page)),
> +                                         page_address(page), id, 0);
> +               if ((signed short)ref < 0) {
> +                       __skb_queue_tail(&np->rx_batch, skb);
> +                       break;
> +               }
> 
>                 req = RING_GET_REQUEST(&np->rx, req_prod + i);
> -               gnttab_grant_foreign_access_ref(ref,
> -                                               np->xbdev->otherend_id,
> -                                               pfn_to_mfn(pfn),
> -                                               0);
> -
>                 req->id = id;
>                 req->gref = ref;
>         }
> @@ -375,17 +458,30 @@ static void xennet_tx_buf_gc(struct net_device *dev)
> 
>                         id  = txrsp->id;
>                         skb = np->tx_skbs[id].skb;
> -                       if (unlikely(gnttab_query_foreign_access(
> -                               np->grant_tx_ref[id]) != 0)) {
> -                               printk(KERN_ALERT "xennet_tx_buf_gc: warning "
> -                                      "-- grant still in use by backend "
> -                                      "domain.\n");
> -                               BUG();
> +
> +                       if (np->persistent_gnt) {
> +                               struct gnt_list *gnt_list_entry;
> +
> +                               gnt_list_entry = np->tx_grant[id];
> +                               BUG_ON(!gnt_list_entry);
> +
> +                               gnt_list_entry->tail = np->tx_gnt_list;
> +                               np->tx_gnt_list = gnt_list_entry;
> +                               np->tx_gnt_cnt++;
> +                       } else {
> +                               if (unlikely(gnttab_query_foreign_access(
> +                                       np->grant_tx_ref[id]) != 0)) {
> +                                       printk(KERN_ALERT "xennet_tx_buf_gc: warning "
> +                                              "-- grant still in use by backend "
> +                                              "domain.\n");
> +                                       BUG();
> +                               }
> +
> +                               gnttab_end_foreign_access_ref(
> +                                       np->grant_tx_ref[id], GNTMAP_readonly);

If I've read the code correctly, you are giving this frame both
read/write permissions to the other end on xennet_alloc_tx_ref, but then
you are only removing the read permissions? (see comment below on the
xennet_alloc_tx_ref function).

> +                               gnttab_release_grant_reference(
> +                                     &np->gref_tx_head, np->grant_tx_ref[id]);
>                         }
> -                       gnttab_end_foreign_access_ref(
> -                               np->grant_tx_ref[id], GNTMAP_readonly);
> -                       gnttab_release_grant_reference(
> -                               &np->gref_tx_head, np->grant_tx_ref[id]);
>                         np->grant_tx_ref[id] = GRANT_INVALID_REF;
>                         add_id_to_freelist(&np->tx_skb_freelist, np->tx_skbs, id);
>                         dev_kfree_skb_irq(skb);
> @@ -409,6 +505,59 @@ static void xennet_tx_buf_gc(struct net_device *dev)
>         xennet_maybe_wake_tx(dev);
>  }
> 
> +static grant_ref_t xennet_alloc_tx_ref(struct net_device *dev,
> +                                      unsigned long mfn,
> +                                      unsigned int id)
> +{
> +       struct netfront_info *np = netdev_priv(dev);
> +       grant_ref_t ref;
> +       struct page *granted_page;
> +
> +       if (np->persistent_gnt && np->tx_gnt_cnt) {
> +               struct gnt_list *gnt_list_entry;
> +
> +               gnt_list_entry = np->tx_gnt_list;
> +               np->tx_gnt_list = np->tx_gnt_list->tail;
> +               np->tx_gnt_cnt--;
> +
> +               ref = gnt_list_entry->gref;
> +               np->tx_grant[id] = gnt_list_entry;
> +       } else {
> +               struct gnt_list *gnt_list_entry;
> +
> +               BUG_ON(!np->persistent_gnt && np->tx_gnt_cnt);
> +               ref = gnttab_claim_grant_reference(&np->gref_tx_head);
> +               BUG_ON((signed short)ref < 0);
> +
> +               if (np->persistent_gnt) {
> +                       granted_page = alloc_page(GFP_KERNEL);
> +                       if (!granted_page) {
> +                               gnttab_release_grant_reference(
> +                                                       &np->gref_tx_head, ref);
> +                               return -ENOMEM;
> +                       }
> +
> +                       mfn = pfn_to_mfn(page_to_pfn(granted_page));
> +                       gnt_list_entry = kmalloc(sizeof(struct gnt_list),
> +                                                GFP_KERNEL);
> +                       if (!gnt_list_entry) {
> +                               __free_page(granted_page);
> +                               gnttab_release_grant_reference(
> +                                                       &np->gref_tx_head, ref);
> +                               return -ENOMEM;
> +                       }
> +
> +                       gnt_list_entry->gref = ref;
> +                       gnt_list_entry->gnt_pages = granted_page;
> +                       np->tx_grant[id] = gnt_list_entry;
> +               }
> +               gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
> +                                               mfn, 0);

If you are not always using persistent grants I guess you need to give
read only permissions to this frame (GNTMAP_readonly). Also, for keeping
things in logical order, isn't it best that this function comes before
xennet_tx_buf_gc?

> +       }
> +
> +       return ref;
> +}
> +
> @@ -1132,8 +1357,10 @@ static void xennet_release_rx_bufs(struct netfront_info *np)
>                 }
> 
>                 skb = np->rx_skbs[id];
> -               mfn = gnttab_end_foreign_transfer_ref(ref);
> -               gnttab_release_grant_reference(&np->gref_rx_head, ref);
> +               if (!np->persistent_gnt) {
> +                       mfn = gnttab_end_foreign_transfer_ref(ref);
> +                       gnttab_release_grant_reference(&np->gref_rx_head, ref);
> +               }
>                 np->grant_rx_ref[id] = GRANT_INVALID_REF;
> 
>                 if (0 == mfn) {
> @@ -1607,6 +1834,13 @@ again:
>                 goto abort_transaction;
>         }
> 
> +       err = xenbus_printf(xbt, dev->nodename, "feature-persistent-grants",
> +                           "%u", info->persistent_gnt);

As in netback, I think "feature-persistent" should be used.

> +       if (err) {
> +               message = "writing feature-persistent-grants";
> +               xenbus_dev_fatal(dev, err, "%s", message);
> +       }
> +
>         err = xenbus_transaction_end(xbt, 0);
>         if (err) {
>                 if (err == -EAGAIN)
> @@ -1634,6 +1868,7 @@ static int xennet_connect(struct net_device *dev)
>         grant_ref_t ref;
>         struct xen_netif_rx_request *req;
>         unsigned int feature_rx_copy;
> +       int ret, val;
> 
>         err = xenbus_scanf(XBT_NIL, np->xbdev->otherend,
>                            "feature-rx-copy", "%u", &feature_rx_copy);
> @@ -1646,6 +1881,13 @@ static int xennet_connect(struct net_device *dev)
>                 return -ENODEV;
>         }
> 
> +       err = xenbus_scanf(XBT_NIL, np->xbdev->otherend,
> +                          "feature-persistent-grants", "%u", &val);
> +       if (err != 1)
> +               val = 0;
> +
> +       np->persistent_gnt = !!val;
> +
>         err = talk_to_netback(np->xbdev, np);
>         if (err)
>                 return err;
> @@ -1657,9 +1899,24 @@ static int xennet_connect(struct net_device *dev)
>         spin_lock_bh(&np->rx_lock);
>         spin_lock_irq(&np->tx_lock);
> 
> +       np->tx_gnt_cnt = 0;
> +       np->rx_gnt_cnt = 0;
> +
>         /* Step 1: Discard all pending TX packet fragments. */
>         xennet_release_tx_bufs(np);
> 
> +       if (np->persistent_gnt) {
> +               struct gnt_list *gnt_list_entry;
> +
> +               while (np->rx_gnt_list) {
> +                       gnt_list_entry = np->rx_gnt_list;
> +                       np->rx_gnt_list = np->rx_gnt_list->tail;
> +                       gnttab_end_foreign_access(gnt_list_entry->gref, 0, 0UL);
> +                       __free_page(gnt_list_entry->gnt_pages);
> +                       kfree(gnt_list_entry);
> +               }
> +       }
> +
>         /* Step 2: Rebuild the RX buffer freelist and the RX ring itself. */
>         for (requeue_idx = 0, i = 0; i < NET_RX_RING_SIZE; i++) {
>                 skb_frag_t *frag;
> @@ -1673,10 +1930,11 @@ static int xennet_connect(struct net_device *dev)
> 
>                 frag = &skb_shinfo(skb)->frags[0];
>                 page = skb_frag_page(frag);
> -               gnttab_grant_foreign_access_ref(
> -                       ref, np->xbdev->otherend_id,
> -                       pfn_to_mfn(page_to_pfn(page)),
> -                       0);
> +               ret = xennet_alloc_rx_ref(dev, pfn_to_mfn(page_to_pfn(page)),
> +                                         page_address(page), requeue_idx, ref);
> +               if ((signed short)ret < 0)
> +                       break;
> +
>                 req->gref = ref;
>                 req->id   = requeue_idx;
> 
> --
> 1.7.3.4
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
> 
