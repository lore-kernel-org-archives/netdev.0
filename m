From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [RFC 21/23] net/xen-netback: Make it running on 64KB
 page granularity
Date: Fri, 15 May 2015 16:31:43 +0100
Message-ID: <20150515153143.GA8521@zion.uk.xensource.com>
References: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
 <1431622863-28575-22-git-send-email-julien.grall@citrix.com>
 <20150515023534.GE19352@zion.uk.xensource.com> <5555E81E.8070803@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <netdev@vger.kernel.org>,
	<tim@xen.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5555E81E.8070803@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 15, 2015 at 01:35:42PM +0100, Julien Grall wrote:
> Hi Wei,
> 
> Thanks you for the review.
> 
> On 15/05/15 03:35, Wei Liu wrote:
> > On Thu, May 14, 2015 at 06:01:01PM +0100, Julien Grall wrote:
> >> The PV network protocol is using 4KB page granularity. The goal of this
> >> patch is to allow a Linux using 64KB page granularity working as a
> >> network backend on a non-modified Xen.
> >>
> >> It's only necessary to adapt the ring size and break skb data in small
> >> chunk of 4KB. The rest of the code is relying on the grant table code.
> >>
> >> Although only simple workload is working (dhcp request, ping). If I try
> >> to use wget in the guest, it will stall until a tcpdump is started on
> >> the vif interface in DOM0. I wasn't able to find why.
> >>
> > 
> > I think in wget workload you're more likely to break down 64K pages to
> > 4K pages. Some of your calculation of mfn, offset might be wrong.
> 
> If so, why tcpdump on the vif interface would make wget suddenly
> working? Does it make netback use a different path?

No, but if might make core network component behave differently, this is
only my suspicion.

Do you see malformed packets with tcpdump?

> 
> >> I have not modified XEN_NETBK_RX_SLOTS_MAX because I wasn't sure what
> >> it's used for (I have limited knowledge on the network driver).
> >>
> > 
> > This is the maximum slots a guest packet can use. AIUI the protocol
> > still works on 4K granularity (you break 64K page to a bunch of 4K
> > pages), you don't need to change this.
> 
> 1 slot = 1 grant right? If so, XEN_NETBK_RX_SLOTS_MAX is based on the
> number of Linux page. So we would have to get the number for Xen page.
> 

Yes, 1 slot = 1 grant. I see what you're up to now. Yes, you need to
change this constant to match underlying HV page.

> Although, I gave a try to multiple by XEN_PFN_PER_PAGE (4KB/64KB = 16)
> but it get stuck in the loop.
> 

I don't follow. What is the new #define? Which loop does it get stuck?

> >> ---
> >>  drivers/net/xen-netback/common.h  |  7 ++++---
> >>  drivers/net/xen-netback/netback.c | 27 ++++++++++++++-------------
> >>  2 files changed, 18 insertions(+), 16 deletions(-)
> >>
> >> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> >> index 8a495b3..0eda6e9 100644
> >> --- a/drivers/net/xen-netback/common.h
> >> +++ b/drivers/net/xen-netback/common.h
> >> @@ -44,6 +44,7 @@
> >>  #include <xen/interface/grant_table.h>
> >>  #include <xen/grant_table.h>
> >>  #include <xen/xenbus.h>
> >> +#include <xen/page.h>
> >>  #include <linux/debugfs.h>
> >>  
> >>  typedef unsigned int pending_ring_idx_t;
> >> @@ -64,8 +65,8 @@ struct pending_tx_info {
> >>  	struct ubuf_info callback_struct;
> >>  };
> >>  
> >> -#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
> >> -#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
> >> +#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, XEN_PAGE_SIZE)
> >> +#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, XEN_PAGE_SIZE)
> >>  
> >>  struct xenvif_rx_meta {
> >>  	int id;
> >> @@ -80,7 +81,7 @@ struct xenvif_rx_meta {
> >>  /* Discriminate from any valid pending_idx value. */
> >>  #define INVALID_PENDING_IDX 0xFFFF
> >>  
> >> -#define MAX_BUFFER_OFFSET PAGE_SIZE
> >> +#define MAX_BUFFER_OFFSET XEN_PAGE_SIZE
> >>  
> >>  #define MAX_PENDING_REQS XEN_NETIF_TX_RING_SIZE
> >>  
> >> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> >> index 9ae1d43..ea5ce84 100644
> >> --- a/drivers/net/xen-netback/netback.c
> >> +++ b/drivers/net/xen-netback/netback.c
> >> @@ -274,7 +274,7 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
> >>  {
> >>  	struct gnttab_copy *copy_gop;
> >>  	struct xenvif_rx_meta *meta;
> >> -	unsigned long bytes;
> >> +	unsigned long bytes, off_grant;
> >>  	int gso_type = XEN_NETIF_GSO_TYPE_NONE;
> >>  
> >>  	/* Data must not cross a page boundary. */
> >> @@ -295,7 +295,8 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
> >>  		if (npo->copy_off == MAX_BUFFER_OFFSET)
> >>  			meta = get_next_rx_buffer(queue, npo);
> >>  
> >> -		bytes = PAGE_SIZE - offset;
> >> +		off_grant = offset & ~XEN_PAGE_MASK;
> >> +		bytes = XEN_PAGE_SIZE - off_grant;
> >>  		if (bytes > size)
> >>  			bytes = size;
> >>  
> >> @@ -314,9 +315,9 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
> >>  		} else {
> >>  			copy_gop->source.domid = DOMID_SELF;
> >>  			copy_gop->source.u.gmfn =
> >> -				virt_to_mfn(page_address(page));
> >> +				virt_to_mfn(page_address(page) + offset);
> >>  		}
> >> -		copy_gop->source.offset = offset;
> >> +		copy_gop->source.offset = off_grant;
> >>  
> >>  		copy_gop->dest.domid = queue->vif->domid;
> >>  		copy_gop->dest.offset = npo->copy_off;
> >> @@ -747,7 +748,7 @@ static int xenvif_count_requests(struct xenvif_queue *queue,
> >>  		first->size -= txp->size;
> >>  		slots++;
> >>  
> >> -		if (unlikely((txp->offset + txp->size) > PAGE_SIZE)) {
> >> +		if (unlikely((txp->offset + txp->size) > XEN_PAGE_SIZE)) {
> >>  			netdev_err(queue->vif->dev, "Cross page boundary, txp->offset: %x, size: %u\n",
> >>  				 txp->offset, txp->size);
> >>  			xenvif_fatal_tx_err(queue->vif);
> >> @@ -1241,11 +1242,11 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
> >>  		}
> >>  
> >>  		/* No crossing a page as the payload mustn't fragment. */
> >> -		if (unlikely((txreq.offset + txreq.size) > PAGE_SIZE)) {
> >> +		if (unlikely((txreq.offset + txreq.size) > XEN_PAGE_SIZE)) {
> >>  			netdev_err(queue->vif->dev,
> >>  				   "txreq.offset: %x, size: %u, end: %lu\n",
> >>  				   txreq.offset, txreq.size,
> >> -				   (txreq.offset&~PAGE_MASK) + txreq.size);
> >> +				   (txreq.offset&~XEN_PAGE_MASK) + txreq.size);
> >>  			xenvif_fatal_tx_err(queue->vif);
> >>  			break;
> >>  		}
> >> @@ -1287,7 +1288,7 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
> >>  			virt_to_mfn(skb->data);
> > 
> > You didn't change the calculation of MFN here. I think it returns the
> > MFN of the first 4K sub-page of that 64K page.  Do I miss anything?
> 
> There is no change required. On ARM virt_to_mfn is implemented with:
> 
> pfn_to_mfn(virt_to_phys(v) >> XEN_PAGE_SHIFT)
> 
> which will return a 4KB PFN (see patch #23).
> 

OK. I missed that patch.

> > 
> >>  		queue->tx_copy_ops[*copy_ops].dest.domid = DOMID_SELF;
> >>  		queue->tx_copy_ops[*copy_ops].dest.offset =
> >> -			offset_in_page(skb->data);
> >> +			offset_in_page(skb->data) & ~XEN_PAGE_MASK;
> >>  
> >>  		queue->tx_copy_ops[*copy_ops].len = data_len;
> >>  		queue->tx_copy_ops[*copy_ops].flags = GNTCOPY_source_gref;
> >> @@ -1366,8 +1367,8 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
> > 
> > This function is to coalesce frag_list to a new SKB. It's completely
> > fine to use the natural granularity of backend domain. The way you
> > modified it can lead to waste of memory, i.e. you only use first 4K of a
> > 64K page.
> 
> Thanks for explaining. I wasn't sure how the function works so I change
> it for safety. I will redo the change.
> 
> FWIW, I'm sure there is other place in netback where we waste memory
> with 64KB page granularity (such as grant table). I need to track them.
> 
> Let me know if you have some place in mind where the memory usage can be
> improved.
> 

I was about to say the mmap_pages array is an array of pages. But that
probably belongs to grant table driver.

Wei.

> >>  			return -ENOMEM;
> >>  		}
> >>  
> >> -		if (offset + PAGE_SIZE < skb->len)
> >> -			len = PAGE_SIZE;
> >> +		if (offset + XEN_PAGE_SIZE < skb->len)
> >> +			len = XEN_PAGE_SIZE;
> >>  		else
> >>  			len = skb->len - offset;
> >>  		if (skb_copy_bits(skb, offset, page_address(page), len))
> >> @@ -1396,7 +1397,7 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
> >>  	/* Fill the skb with the new (local) frags. */
> >>  	memcpy(skb_shinfo(skb)->frags, frags, i * sizeof(skb_frag_t));
> >>  	skb_shinfo(skb)->nr_frags = i;
> >> -	skb->truesize += i * PAGE_SIZE;
> >> +	skb->truesize += i * XEN_PAGE_SIZE;
> > 
> > The true size accounts for the actual memory occupied by this SKB. Since
> > the page is allocated with alloc_page, the granularity should be
> > PAGE_SIZE not XEN_PAGE_SIZE.
> 
> Ok. I will replace with PAGE_SIZE.
> 
> Regards,
> 
> -- 
> Julien Grall
