From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH V3 15/16] netfront: multi page ring
 support.
Date: Tue, 31 Jan 2012 10:58:51 +0000
Message-ID: <1328007531.5553.65.camel@leeds.uk.xensource.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
	 <1327934734-8908-16-git-send-email-wei.liu2@citrix.com>
	 <20120130213926.GB16261@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"Ian Campbell" <Ian.Campbell@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:39661 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299Ab2AaK6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 05:58:55 -0500
In-Reply-To: <20120130213926.GB16261@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-01-30 at 21:39 +0000, Konrad Rzeszutek Wilk wrote:
> On Mon, Jan 30, 2012 at 02:45:33PM +0000, Wei Liu wrote:
> > Use DMA API to allocate ring pages, because we need to get machine
> > contiginous memory.
> 
> >
> > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> > ---
> >  drivers/net/xen-netfront.c |  258 ++++++++++++++++++++++++++++++++------------
> >  1 files changed, 187 insertions(+), 71 deletions(-)
> >
> > diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> > index 01f589d..32ec212 100644
> > --- a/drivers/net/xen-netfront.c
> > +++ b/drivers/net/xen-netfront.c
> > @@ -66,9 +66,18 @@ struct netfront_cb {
> >
> >  #define GRANT_INVALID_REF    0
> >
> > -#define NET_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
> > -#define NET_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
> > -#define TX_MAX_TARGET min_t(int, NET_TX_RING_SIZE, 256)
> > +#define XENNET_MAX_RING_PAGE_ORDER 2
> > +#define XENNET_MAX_RING_PAGES      (1U << XENNET_MAX_RING_PAGE_ORDER)
> > +
> > +#define NET_TX_RING_SIZE(_nr_pages)                                  \
> > +     __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE * (_nr_pages))
> > +#define NET_RX_RING_SIZE(_nr_pages)                                  \
> > +     __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE * (_nr_pages))
> > +
> > +#define XENNET_MAX_TX_RING_SIZE NET_TX_RING_SIZE(XENNET_MAX_RING_PAGES)
> > +#define XENNET_MAX_RX_RING_SIZE NET_RX_RING_SIZE(XENNET_MAX_RING_PAGES)
> > +
> > +#define TX_MAX_TARGET XENNET_MAX_TX_RING_SIZE
> >
> >  struct netfront_stats {
> >       u64                     rx_packets;
> > @@ -84,12 +93,20 @@ struct netfront_info {
> >
> >       struct napi_struct napi;
> >
> > +     /* Statistics */
> > +     struct netfront_stats __percpu *stats;
> > +
> > +     unsigned long rx_gso_checksum_fixup;
> > +
> >       unsigned int evtchn;
> >       struct xenbus_device *xbdev;
> >
> >       spinlock_t   tx_lock;
> >       struct xen_netif_tx_front_ring tx;
> > -     int tx_ring_ref;
> > +     dma_addr_t tx_ring_dma_handle;
> > +     int tx_ring_ref[XENNET_MAX_RING_PAGES];
> > +     int tx_ring_page_order;
> > +     int tx_ring_pages;
> >
> >       /*
> >        * {tx,rx}_skbs store outstanding skbuffs. Free tx_skb entries
> > @@ -103,36 +120,34 @@ struct netfront_info {
> >       union skb_entry {
> >               struct sk_buff *skb;
> >               unsigned long link;
> > -     } tx_skbs[NET_TX_RING_SIZE];
> > +     } tx_skbs[XENNET_MAX_TX_RING_SIZE];
> >       grant_ref_t gref_tx_head;
> > -     grant_ref_t grant_tx_ref[NET_TX_RING_SIZE];
> > +     grant_ref_t grant_tx_ref[XENNET_MAX_TX_RING_SIZE];
> >       unsigned tx_skb_freelist;
> >
> >       spinlock_t   rx_lock ____cacheline_aligned_in_smp;
> >       struct xen_netif_rx_front_ring rx;
> > -     int rx_ring_ref;
> > +     dma_addr_t rx_ring_dma_handle;
> > +     int rx_ring_ref[XENNET_MAX_RING_PAGES];
> > +     int rx_ring_page_order;
> > +     int rx_ring_pages;
> >
> >       /* Receive-ring batched refills. */
> >  #define RX_MIN_TARGET 8
> >  #define RX_DFL_MIN_TARGET 64
> > -#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
> > +#define RX_MAX_TARGET XENNET_MAX_RX_RING_SIZE
> >       unsigned rx_min_target, rx_max_target, rx_target;
> >       struct sk_buff_head rx_batch;
> >
> >       struct timer_list rx_refill_timer;
> >
> > -     struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
> > +     struct sk_buff *rx_skbs[XENNET_MAX_RX_RING_SIZE];
> >       grant_ref_t gref_rx_head;
> > -     grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
> > -
> > -     unsigned long rx_pfn_array[NET_RX_RING_SIZE];
> > -     struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
> > -     struct mmu_update rx_mmu[NET_RX_RING_SIZE];
> > -
> > -     /* Statistics */
> > -     struct netfront_stats __percpu *stats;
> > +     grant_ref_t grant_rx_ref[XENNET_MAX_RX_RING_SIZE];
> >
> > -     unsigned long rx_gso_checksum_fixup;
> > +     unsigned long rx_pfn_array[XENNET_MAX_RX_RING_SIZE];
> > +     struct multicall_entry rx_mcl[XENNET_MAX_RX_RING_SIZE+1];
> > +     struct mmu_update rx_mmu[XENNET_MAX_RX_RING_SIZE];
> >  };
> >
> >  struct netfront_rx_info {
> > @@ -170,15 +185,15 @@ static unsigned short get_id_from_freelist(unsigned *head,
> >       return id;
> >  }
> >
> > -static int xennet_rxidx(RING_IDX idx)
> > +static int xennet_rxidx(RING_IDX idx, struct netfront_info *info)
> >  {
> > -     return idx & (NET_RX_RING_SIZE - 1);
> > +     return idx & (NET_RX_RING_SIZE(info->rx_ring_pages) - 1);
> >  }
> >
> >  static struct sk_buff *xennet_get_rx_skb(struct netfront_info *np,
> >                                        RING_IDX ri)
> >  {
> > -     int i = xennet_rxidx(ri);
> > +     int i = xennet_rxidx(ri, np);
> >       struct sk_buff *skb = np->rx_skbs[i];
> >       np->rx_skbs[i] = NULL;
> >       return skb;
> > @@ -187,7 +202,7 @@ static struct sk_buff *xennet_get_rx_skb(struct netfront_info *np,
> >  static grant_ref_t xennet_get_rx_ref(struct netfront_info *np,
> >                                           RING_IDX ri)
> >  {
> > -     int i = xennet_rxidx(ri);
> > +     int i = xennet_rxidx(ri, np);
> >       grant_ref_t ref = np->grant_rx_ref[i];
> >       np->grant_rx_ref[i] = GRANT_INVALID_REF;
> >       return ref;
> > @@ -300,7 +315,7 @@ no_skb:
> >
> >               skb->dev = dev;
> >
> > -             id = xennet_rxidx(req_prod + i);
> > +             id = xennet_rxidx(req_prod + i, np);
> >
> >               BUG_ON(np->rx_skbs[id]);
> >               np->rx_skbs[id] = skb;
> > @@ -596,7 +611,7 @@ static int xennet_close(struct net_device *dev)
> >  static void xennet_move_rx_slot(struct netfront_info *np, struct sk_buff *skb,
> >                               grant_ref_t ref)
> >  {
> > -     int new = xennet_rxidx(np->rx.req_prod_pvt);
> > +     int new = xennet_rxidx(np->rx.req_prod_pvt, np);
> >
> >       BUG_ON(np->rx_skbs[new]);
> >       np->rx_skbs[new] = skb;
> > @@ -1089,7 +1104,7 @@ static void xennet_release_tx_bufs(struct netfront_info *np)
> >       struct sk_buff *skb;
> >       int i;
> >
> > -     for (i = 0; i < NET_TX_RING_SIZE; i++) {
> > +     for (i = 0; i < NET_TX_RING_SIZE(np->tx_ring_pages); i++) {
> >               /* Skip over entries which are actually freelist references */
> >               if (skb_entry_is_link(&np->tx_skbs[i]))
> >                       continue;
> > @@ -1123,7 +1138,7 @@ static void xennet_release_rx_bufs(struct netfront_info *np)
> >
> >       spin_lock_bh(&np->rx_lock);
> >
> > -     for (id = 0; id < NET_RX_RING_SIZE; id++) {
> > +     for (id = 0; id < NET_RX_RING_SIZE(np->rx_ring_pages); id++) {
> >               ref = np->grant_rx_ref[id];
> >               if (ref == GRANT_INVALID_REF) {
> >                       unused++;
> > @@ -1305,13 +1320,13 @@ static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev
> >
> >       /* Initialise tx_skbs as a free chain containing every entry. */
> >       np->tx_skb_freelist = 0;
> > -     for (i = 0; i < NET_TX_RING_SIZE; i++) {
> > +     for (i = 0; i < XENNET_MAX_TX_RING_SIZE; i++) {
> >               skb_entry_set_link(&np->tx_skbs[i], i+1);
> >               np->grant_tx_ref[i] = GRANT_INVALID_REF;
> >       }
> >
> >       /* Clear out rx_skbs */
> > -     for (i = 0; i < NET_RX_RING_SIZE; i++) {
> > +     for (i = 0; i < XENNET_MAX_RX_RING_SIZE; i++) {
> >               np->rx_skbs[i] = NULL;
> >               np->grant_rx_ref[i] = GRANT_INVALID_REF;
> >       }
> > @@ -1409,15 +1424,11 @@ static int __devinit netfront_probe(struct xenbus_device *dev,
> >       return err;
> >  }
> >
> > -static void xennet_end_access(int ref, void *page)
> > -{
> > -     /* This frees the page as a side-effect */
> > -     if (ref != GRANT_INVALID_REF)
> > -             gnttab_end_foreign_access(ref, 0, (unsigned long)page);
> > -}
> > -
> >  static void xennet_disconnect_backend(struct netfront_info *info)
> >  {
> > +     int i;
> > +     struct xenbus_device *dev = info->xbdev;
> > +
> >       /* Stop old i/f to prevent errors whilst we rebuild the state. */
> >       spin_lock_bh(&info->rx_lock);
> >       spin_lock_irq(&info->tx_lock);
> > @@ -1429,12 +1440,24 @@ static void xennet_disconnect_backend(struct netfront_info *info)
> >               unbind_from_irqhandler(info->netdev->irq, info->netdev);
> >       info->evtchn = info->netdev->irq = 0;
> >
> > -     /* End access and free the pages */
> > -     xennet_end_access(info->tx_ring_ref, info->tx.sring);
> > -     xennet_end_access(info->rx_ring_ref, info->rx.sring);
> > +     for (i = 0; i < info->tx_ring_pages; i++) {
> > +             int ref = info->tx_ring_ref[i];
> > +             gnttab_end_foreign_access_ref(ref, 0);
> > +             info->tx_ring_ref[i] = GRANT_INVALID_REF;
> > +     }
> > +     dma_free_coherent(NULL, PAGE_SIZE * info->tx_ring_pages,
> > +                       (void *)info->tx.sring,
> > +                       info->tx_ring_dma_handle);
> > +
> > +     for (i = 0; i < info->rx_ring_pages; i++) {
> > +             int ref = info->rx_ring_ref[i];
> > +             gnttab_end_foreign_access_ref(ref, 0);
> > +             info->rx_ring_ref[i] = GRANT_INVALID_REF;
> > +     }
> > +     dma_free_coherent(NULL, PAGE_SIZE * info->rx_ring_pages,
> > +                       (void *)info->rx.sring,
> > +                       info->rx_ring_dma_handle);
> >
> > -     info->tx_ring_ref = GRANT_INVALID_REF;
> > -     info->rx_ring_ref = GRANT_INVALID_REF;
> >       info->tx.sring = NULL;
> >       info->rx.sring = NULL;
> >  }
> > @@ -1483,9 +1506,13 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
> >       struct xen_netif_rx_sring *rxs;
> >       int err;
> >       struct net_device *netdev = info->netdev;
> > +     unsigned int max_tx_ring_page_order, max_rx_ring_page_order;
> > +     int i, j;
> >
> > -     info->tx_ring_ref = GRANT_INVALID_REF;
> > -     info->rx_ring_ref = GRANT_INVALID_REF;
> > +     for (i = 0; i < XENNET_MAX_RING_PAGES; i++) {
> > +             info->tx_ring_ref[i] = GRANT_INVALID_REF;
> > +             info->rx_ring_ref[i] = GRANT_INVALID_REF;
> > +     }
> >       info->rx.sring = NULL;
> >       info->tx.sring = NULL;
> >       netdev->irq = 0;
> > @@ -1496,50 +1523,105 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
> >               goto fail;
> >       }
> >
> > -     txs = (struct xen_netif_tx_sring *)get_zeroed_page(GFP_NOIO | __GFP_HIGH);
> > +     err = xenbus_scanf(XBT_NIL, info->xbdev->otherend,
> > +                        "max-tx-ring-page-order", "%u",
> > +                        &max_tx_ring_page_order);
> > +     if (err < 0) {
> > +             info->tx_ring_page_order = 0;
> > +             dev_info(&dev->dev, "single tx ring\n");
> > +     } else {
> > +             info->tx_ring_page_order = max_tx_ring_page_order;
> > +             dev_info(&dev->dev, "multi page tx ring, order = %d\n",
> > +                      max_tx_ring_page_order);
> > +     }
> > +     info->tx_ring_pages = (1U << info->tx_ring_page_order);
> > +
> > +     txs = (struct xen_netif_tx_sring *)
> > +             dma_alloc_coherent(NULL, PAGE_SIZE * info->tx_ring_pages,
> > +                                &info->tx_ring_dma_handle,
> > +                                __GFP_ZERO | GFP_NOIO | __GFP_HIGH);
> 
> Hm, so I see you are using 'NULL' which is a big nono (the API docs say that).
> But the other reason why it is a no-no, is b/c this way the generic DMA engine has no
> clue whether you are OK getting pages under 4GB or above it (so 64-bit support).
> 
> If you don't supply a 'dev' it will assume 4GB. But when you are run this as a
> pure PV guest that won't matter the slighest b/I there are no DMA code in action
> (well, there is dma_alloc_coherent - which looking at the code would NULL it seems).
> 
> Anyhow, if you get to have more than 4GB in the guest or do PCI passthrough and use
> 'iommu=soft'- at which point the Xen SWIOTLB will kick and you will end up 'swizzling'
> the pages to be under 4GB. That can be fixed if you declerae a 'fake' device where you set
> the coherent_dma_mask to DMA_BIT_MASK(64).
> 

This seems to be a reasonable solution. I could not set netfront's DMA
mask, that's why I used NULL device. And, how do I create a 'fake'
device?

> But if you boot the guest under HVM, then it will use the generic SWIOTLB code, which
> won't guaranteeing the pages to be "machine" contingous but will be "guest machine"
> contingous. Is that sufficient for this?
> 

For HVM, this is sufficient.

> How did you test this? Did you supply iommu=soft  to your guest or booted it
> with more than 4GB?
> 

I haven't tested guest with more than 4GB RAM.


Wei.
