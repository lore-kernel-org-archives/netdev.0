From: Andrea Merello <andrea.merello-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH resend] rtl818x_pci: Fix a memory leak in rtl8180_init_rx_ring
Date: Sat, 30 Jan 2016 18:15:40 +0100
Message-ID: <CAN8YU5OiiCn1LfSZ8+9eX9ZLRC-Tda7wm=Yp2RDyrtLzFN5quw@mail.gmail.com>
References: <1452949632-16329-1-git-send-email-baijiaju1990@163.com>
Reply-To: andrea.merello-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1452949632-16329-1-git-send-email-baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks for pointing this out!

At a first look I'd propose to merge the two identical
pci_fee_consistent() in a single one, and place it in an error exit
path at the end of function.

BTW, looking at the code, it seems there is another leak here that
your patch does not address: we still leaks allocated (and dma-mapped)
skbs.

Indeed we probably need to rework error handling in this piece of code..

Andrea

On Sat, Jan 16, 2016 at 2:07 PM, Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org> wrote:
> When dev_alloc_skb or pci_dma_mapping_error in rtl8180_init_rx_ring fails,
> the memory allocated by pci_zalloc_consistent is not freed.
>
> This patch fixes the bug by adding pci_free_consistent
> in error handling code.
>
> Signed-off-by: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
> ---
>  drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c |    4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c b/drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c
> index a43a16f..28479b1 100644
> --- a/drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c
> +++ b/drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c
> @@ -1018,6 +1018,8 @@ static int rtl8180_init_rx_ring(struct ieee80211_hw *dev)
>                 dma_addr_t *mapping;
>                 entry = priv->rx_ring + priv->rx_ring_sz*i;
>                 if (!skb) {
> +                       pci_free_consistent(priv->pdev, priv->rx_ring_sz * 32,
> +                                       priv->rx_ring, priv->rx_ring_dma);
>                         wiphy_err(dev->wiphy, "Cannot allocate RX skb\n");
>                         return -ENOMEM;
>                 }
> @@ -1028,6 +1030,8 @@ static int rtl8180_init_rx_ring(struct ieee80211_hw *dev)
>
>                 if (pci_dma_mapping_error(priv->pdev, *mapping)) {
>                         kfree_skb(skb);
> +                       pci_free_consistent(priv->pdev, priv->rx_ring_sz * 32,
> +                                       priv->rx_ring, priv->rx_ring_dma);
>                         wiphy_err(dev->wiphy, "Cannot map DMA for RX skb\n");
>                         return -ENOMEM;
>                 }
> --
> 1.7.9.5
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
