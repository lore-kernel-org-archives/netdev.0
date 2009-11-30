From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [RFC PATCH 07/10] bnx2: remove skb_dma_map/unmap calls from
 driver
Date: Mon, 30 Nov 2009 02:26:49 -0800
Message-ID: <C27F8246C663564A84BB7AB34397724218065B9850@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20091125012048.32704.84356.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Alexander Duyck'" <alexander.h.duyck@intel.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"sathyap@serverengines.com" <sathyap@serverengines.com>,
	"subbus@serverengines.com" <subb
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4747 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633AbZK3K0w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 05:26:52 -0500
In-Reply-To: <20091125012048.32704.84356.stgit@gitlad.jf.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Duyck wrote:

> Due to the fact that skb_dma_map/unmap do not work correctly when a HW
> IOMMU is enabled it has been recommended to go about removing
> the calls
> from the network device drivers.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Thanks Alexander.  Sorry for the late response, I just got back
from vacation.  It looks ok except in bnx2_free_tx_skbs():

> @@ -5295,18 +5303,30 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
>               for (j = 0; j < TX_DESC_CNT; ) {
>                       struct sw_tx_bd *tx_buf = &txr->tx_buf_ring[j];
>                       struct sk_buff *skb = tx_buf->skb;
> +                     int k, last;
>
>                       if (skb == NULL) {
>                               j++;
>                               continue;
>                       }
>
> -                     skb_dma_unmap(&bp->pdev->dev, skb,
> DMA_TO_DEVICE);
> +                     pci_unmap_single(bp->pdev,
> +                                      pci_unmap_addr(tx_buf,
> mapping),
> +                                      skb_headlen(skb),
> +                                      PCI_DMA_TODEVICE);
>
>                       tx_buf->skb = NULL;
>
> -                     j += skb_shinfo(skb)->nr_frags + 1;
> +                     last = skb_shinfo(skb)->nr_frags;
> +                     for (k = 0; k < last; k++) {
> +                             tx_buf = &txr->tx_buf_ring[j + k + 1];

j + k + 1 can go beyond the ring when the ring wraps around.
I'll send an updated patch tomorrow.

> +                             pci_unmap_page(bp->pdev,
> +                                     pci_unmap_addr(tx_buf, mapping),
> +                                     skb_shinfo(skb)->frags[j].size,
> +                                     PCI_DMA_TODEVICE);
> +                     }
>                       dev_kfree_skb(skb);
> +                     j += k + 1;
>               }
>       }
>  }

