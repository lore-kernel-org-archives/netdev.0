From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net-next v3 2/2] enic: use netdev_dma_alloc
Date: Tue, 10 Mar 2015 13:14:40 -0700
Message-ID: <54FF50B0.3080900@redhat.com>
References: <1426009384-11544-1-git-send-email-_govind@gmx.com> <1426009384-11544-3-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ssujith@cisco.com, benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52769 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368AbbCJUOr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 16:14:47 -0400
In-Reply-To: <1426009384-11544-3-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/10/2015 10:43 AM, Govindarajulu Varadarajan wrote:
> This patches uses dma cache skb allocator fot rx buffers.
>
> netdev_dma_head is initialized per rq. All calls to netdev_dma_alloc_skb() and
> netdev_dma_frag_unmap() happens in napi_poll and they are serialized.
>
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

This isn't going to work. The problem is the way you are using your 
fragments you can end up with a memory corruption as the frame headers 
that were updated by the stack may be reverted for any frames received 
before the last frame was unmapped.  I ran into that issue when I was 
doing page reuse with build_skb on the Intel drivers and I suspect you 
will see the same issue.

The way to work around it is to receive the data in to the fragments, 
and then pull the headers out and store them in a separate skb via 
something similar to copy-break.  You can then track the fragments in frags.

> ---
>   drivers/net/ethernet/cisco/enic/enic_main.c | 31 +++++++++--------------------
>   drivers/net/ethernet/cisco/enic/vnic_rq.c   |  3 +++
>   drivers/net/ethernet/cisco/enic/vnic_rq.h   |  3 +++
>   3 files changed, 15 insertions(+), 22 deletions(-)
>
> diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
> index 204bd182..3be5bc12 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_main.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_main.c
> @@ -952,13 +952,9 @@ nla_put_failure:
>   
>   static void enic_free_rq_buf(struct vnic_rq *rq, struct vnic_rq_buf *buf)
>   {
> -	struct enic *enic = vnic_dev_priv(rq->vdev);
> -
>   	if (!buf->os_buf)
>   		return;
> -
> -	pci_unmap_single(enic->pdev, buf->dma_addr,
> -		buf->len, PCI_DMA_FROMDEVICE);
> +	netdev_dma_frag_unmap(&rq->nc_head, buf->nc);
>   	dev_kfree_skb_any(buf->os_buf);
>   	buf->os_buf = NULL;
>   }
> @@ -979,17 +975,10 @@ static int enic_rq_alloc_buf(struct vnic_rq *rq)
>   
>   		return 0;
>   	}
> -	skb = netdev_alloc_skb_ip_align(netdev, len);
> +	skb = netdev_dma_alloc_skb(&rq->nc_head, &buf->nc, &dma_addr, len);
>   	if (!skb)
>   		return -ENOMEM;
>   
> -	dma_addr = pci_map_single(enic->pdev, skb->data, len,
> -				  PCI_DMA_FROMDEVICE);
> -	if (unlikely(enic_dma_map_check(enic, dma_addr))) {
> -		dev_kfree_skb(skb);
> -		return -ENOMEM;
> -	}
> -
>   	enic_queue_rq_desc(rq, skb, os_buf_index,
>   		dma_addr, len);
>   

I'm curious why you are still using skbs as your data type for receiving 
frames before they come in.  Why not just store a pointer to your dma 
buffer and hold off on allocating the sk_buff until you have actually 
received the frame in the buffer?  It would save you something like 256B 
per frame if you just hold off on the allocation until the skb is really 
needed.

> @@ -1016,8 +1005,6 @@ static bool enic_rxcopybreak(struct net_device *netdev, struct sk_buff **skb,
>   	new_skb = netdev_alloc_skb_ip_align(netdev, len);
>   	if (!new_skb)
>   		return false;
> -	pci_dma_sync_single_for_cpu(enic->pdev, buf->dma_addr, len,
> -				    DMA_FROM_DEVICE);
>   	memcpy(new_skb->data, (*skb)->data, len);
>   	*skb = new_skb;
>   
> @@ -1065,8 +1052,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
>   				enic->rq_truncated_pkts++;
>   		}
>   
> -		pci_unmap_single(enic->pdev, buf->dma_addr, buf->len,
> -				 PCI_DMA_FROMDEVICE);
> +		netdev_dma_frag_unmap(&rq->nc_head, buf->nc);
>   		dev_kfree_skb_any(skb);
>   		buf->os_buf = NULL;
>   
> @@ -1078,10 +1064,11 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
>   		/* Good receive
>   		 */
>   
> +		pci_dma_sync_single_for_cpu(enic->pdev, buf->dma_addr,
> +					    bytes_written, DMA_FROM_DEVICE);
>   		if (!enic_rxcopybreak(netdev, &skb, buf, bytes_written)) {
>   			buf->os_buf = NULL;
> -			pci_unmap_single(enic->pdev, buf->dma_addr, buf->len,
> -					 PCI_DMA_FROMDEVICE);
> +			netdev_dma_frag_unmap(&rq->nc_head, buf->nc);
>   		}
>   		prefetch(skb->data - NET_IP_ALIGN);
>   

It looks like you already have copy-break code in your codepath.  It 
might be worth taking a look at what you would gain by deferring the skb 
allocation and using the copy-break code path to take care of small 
frames and headers for larger frames.

> @@ -1122,9 +1109,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
>   
>   		/* Buffer overflow
>   		 */
> -
> -		pci_unmap_single(enic->pdev, buf->dma_addr, buf->len,
> -				 PCI_DMA_FROMDEVICE);
> +		netdev_dma_frag_unmap(&rq->nc_head, buf->nc);
>   		dev_kfree_skb_any(skb);
>   		buf->os_buf = NULL;
>   	}
> @@ -1648,6 +1633,8 @@ static int enic_open(struct net_device *netdev)
>   	}
>   
>   	for (i = 0; i < enic->rq_count; i++) {
> +		netdev_dma_init(&enic->rq[i].nc_head, &enic->pdev->dev,
> +				GFP_ATOMIC);
>   		vnic_rq_fill(&enic->rq[i], enic_rq_alloc_buf);
>   		/* Need at least one buffer on ring to get going */
>   		if (vnic_rq_desc_used(&enic->rq[i]) == 0) {
> diff --git a/drivers/net/ethernet/cisco/enic/vnic_rq.c b/drivers/net/ethernet/cisco/enic/vnic_rq.c
> index 36a2ed6..afa1d71 100644
> --- a/drivers/net/ethernet/cisco/enic/vnic_rq.c
> +++ b/drivers/net/ethernet/cisco/enic/vnic_rq.c
> @@ -23,6 +23,7 @@
>   #include <linux/pci.h>
>   #include <linux/delay.h>
>   #include <linux/slab.h>
> +#include <linux/skbuff.h>
>   
>   #include "vnic_dev.h"
>   #include "vnic_rq.h"
> @@ -199,6 +200,8 @@ void vnic_rq_clean(struct vnic_rq *rq,
>   		rq->ring.desc_avail++;
>   	}
>   
> +	netdev_dma_destroy(&rq->nc_head);
> +
>   	/* Use current fetch_index as the ring starting point */
>   	fetch_index = ioread32(&rq->ctrl->fetch_index);
>   
> diff --git a/drivers/net/ethernet/cisco/enic/vnic_rq.h b/drivers/net/ethernet/cisco/enic/vnic_rq.h
> index 8111d52..d4ee963 100644
> --- a/drivers/net/ethernet/cisco/enic/vnic_rq.h
> +++ b/drivers/net/ethernet/cisco/enic/vnic_rq.h
> @@ -21,6 +21,7 @@
>   #define _VNIC_RQ_H_
>   
>   #include <linux/pci.h>
> +#include <linux/skbuff.h>
>   
>   #include "vnic_dev.h"
>   #include "vnic_cq.h"
> @@ -73,6 +74,7 @@ struct vnic_rq_buf {
>   	unsigned int index;
>   	void *desc;
>   	uint64_t wr_id;
> +	struct netdev_dma_node *nc;
>   };
>   
>   struct vnic_rq {
> @@ -100,6 +102,7 @@ struct vnic_rq {
>   	unsigned int bpoll_state;
>   	spinlock_t bpoll_lock;
>   #endif /* CONFIG_NET_RX_BUSY_POLL */
> +	struct netdev_dma_head nc_head;
>   };
>   
>   static inline unsigned int vnic_rq_desc_avail(struct vnic_rq *rq)
