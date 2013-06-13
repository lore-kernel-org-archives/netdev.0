From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH net] tulip: Properly check dma mapping result
Date: Thu, 13 Jun 2013 15:26:14 -0700
Message-ID: <CAP6odjhmVEBghTUQ=N_fxs8rr5USkaDq-AG3=New6AkOVv_HAA@mail.gmail.com>
References: <1371151888-12138-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>,
	Grant Grundler <grundler@parisc-linux.org>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:55341 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757878Ab3FMW0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 18:26:16 -0400
Received: by mail-oa0-f47.google.com with SMTP id m1so9874577oag.34
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 15:26:15 -0700 (PDT)
In-Reply-To: <1371151888-12138-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 13, 2013 at 12:31 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
> Tulip throws an error when dma debugging is enabled, as it doesn't properly
> check dma mapping results with dma_mapping_error() durring tx ring refills.
>
> Easy fix, just add it in, and drop the frame if the mapping is bad
>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Grant Grundler <grundler@parisc-linux.org>

LGTM. thanks!

Reviewed-by: Grant Grundler <grundler@parisc-linux.org>

FYA: the original DMA mapping interface that was introduce in 2.4 did
not return errors. It would panic the system. The reasoning at the
time was (I'm paraphrasing): "Driver writers won't check the erorr or
handle it correctly so don't make it more complicated.

cheers,
grant

> CC: "David S. Miller" <davem@davemloft.net>
> ---
>  drivers/net/ethernet/dec/tulip/interrupt.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/drivers/net/ethernet/dec/tulip/interrupt.c b/drivers/net/ethernet/dec/tulip/interrupt.c
> index 28a5e42..92306b3 100644
> --- a/drivers/net/ethernet/dec/tulip/interrupt.c
> +++ b/drivers/net/ethernet/dec/tulip/interrupt.c
> @@ -76,6 +76,12 @@ int tulip_refill_rx(struct net_device *dev)
>
>                         mapping = pci_map_single(tp->pdev, skb->data, PKT_BUF_SZ,
>                                                  PCI_DMA_FROMDEVICE);
> +                       if (dma_mapping_error(&tp->pdev->dev, mapping)) {
> +                               dev_kfree_skb(skb);
> +                               tp->rx_buffers[entry].skb = NULL;
> +                               break;
> +                       }
> +
>                         tp->rx_buffers[entry].mapping = mapping;
>
>                         tp->rx_ring[entry].buffer1 = cpu_to_le32(mapping);
> --
> 1.8.1.4
>
