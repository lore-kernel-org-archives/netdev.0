From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH] e1000: add initial XDP support
Date: Sun, 28 Aug 2016 08:55:55 +0300
Message-ID: <CAJ3xEMh_oXucmESb3w9Mevnu7Pb+zHkozF=WqxoWMY3FijTnDg@mail.gmail.com>
References: <20160827071145.25345.84712.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Brenden Blanco <bblanco@plumgrid.com>,
        David Miller <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34114 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751367AbcH1Fz4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 01:55:56 -0400
Received: by mail-oi0-f68.google.com with SMTP id t127so9898773oie.1
        for <netdev@vger.kernel.org>; Sat, 27 Aug 2016 22:55:56 -0700 (PDT)
In-Reply-To: <20160827071145.25345.84712.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 27, 2016 at 10:11 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> From: Alexei Starovoitov <ast@fb.com>

> This patch adds initial support for XDP on e1000 driver. Note e1000
> driver does not support page recycling in general which could be
> added as a further improvement. However for XDP_DROP and XDP_XMIT
> the xdp code paths will recycle pages.

> @@ -4188,15 +4305,57 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
>                 prefetch(next_rxd);
>
>                 next_buffer = &rx_ring->buffer_info[i];
> -

nit, better to avoid random cleanups in a patch adding new (&& cool)
functionality

>                 cleaned = true;
>                 cleaned_count++;
> +               length = le16_to_cpu(rx_desc->length);
> +
> +               if (prog) {
> +                       struct page *p = buffer_info->rxbuf.page;
> +                       dma_addr_t dma = buffer_info->dma;
> +                       int act;
> +
> +                       if (unlikely(!(status & E1000_RXD_STAT_EOP))) {
> +                               /* attached bpf disallows larger than page
> +                                * packets, so this is hw error or corruption
> +                                */
> +                               pr_info_once("%s buggy !eop\n", netdev->name);
> +                               break;
> +                       }
> +                       if (unlikely(rx_ring->rx_skb_top)) {
> +                               pr_info_once("%s ring resizing bug\n",
> +                                            netdev->name);
> +                               break;
> +                       }
> +                       dma_sync_single_for_cpu(&pdev->dev, dma,
> +                                               length, DMA_FROM_DEVICE);
> +                       act = e1000_call_bpf(prog, page_address(p), length);
> +                       switch (act) {
> +                       case XDP_PASS:
> +                               break;
> +                       case XDP_TX:
> +                               dma_sync_single_for_device(&pdev->dev,
> +                                                          dma,
> +                                                          length,
> +                                                          DMA_TO_DEVICE);
> +                               e1000_xmit_raw_frame(buffer_info, length,
> +                                                    netdev, adapter);
> +                       /* Fallthrough to re-use mappedg page after xmit */

Did you want to say "mapped"? wasn't sure what's the role of "g" @ the end

> +                       case XDP_DROP:
> +                       default:
> +                               /* re-use mapped page. keep buffer_info->dma
> +                                * as-is, so that e1000_alloc_jumbo_rx_buffers
> +                                * only needs to put it back into rx ring
> +                                */

if we're on the XDP_TX pass, don't we need to actually see that frame
has been xmitted
before re using the page?

> +                               total_rx_bytes += length;
> +                               total_rx_packets++;
> +                               goto next_desc;
> +                       }
> +               }
> +
>                 dma_unmap_page(&pdev->dev, buffer_info->dma,
>                                adapter->rx_buffer_len, DMA_FROM_DEVICE);
>                 buffer_info->dma = 0;
