From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC PATCH 1/2] r8169: check dma mapping failures
Date: Tue, 12 Oct 2010 00:08:27 +0200
Message-ID: <20101011220827.GA11340@electric-eye.fr.zoreil.com>
References: <1286548203-10831-1-git-send-email-sgruszka@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Denis Kirjanov <kirjanov@gmail.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 88-139-115-126.adslgp.cegetel.net ([88.139.115.126]:46925 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756914Ab0JKWbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 18:31:15 -0400
Content-Disposition: inline
In-Reply-To: <1286548203-10831-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanislaw Gruszka <sgruszka@redhat.com> :
[...]
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index bc669a4..b3b28b1 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -4018,20 +4018,24 @@ static struct sk_buff *rtl8169_alloc_rx_skb(struct pci_dev *pdev,

You can replace the pci_dev parameter with pdev->dev

>  
>  	skb = __netdev_alloc_skb(dev, rx_buf_sz + pad, gfp);
>  	if (!skb)
> -		goto err_out;
> +		goto err0;

err_out_0 (with a big please)

>  	skb_reserve(skb, align ? ((pad - 1) & (unsigned long)skb->data) : pad);
>  
>  	mapping = dma_map_single(&pdev->dev, skb->data, rx_buf_sz,
>  				 PCI_DMA_FROMDEVICE);
> +	if (dma_mapping_error(&pdev->dev, mapping))
> +		goto err1;

err_free_skb_1

>  	rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
> -out:
> +
>  	return skb;
>  
> -err_out:
> +err1:
> +	dev_kfree_skb(skb);
> +err0:
>  	rtl8169_make_unusable_by_asic(desc);
> -	goto out;
> +	return NULL;

I'd keep the 'goto out' and NULL the skb after the dev_kfree_skb but
it's up to you.

>  }
>  
>  static void rtl8169_rx_clear(struct rtl8169_private *tp)
> @@ -4115,11 +4119,11 @@ static void rtl8169_unmap_tx_skb(struct pci_dev *pdev, struct ring_info *tx_skb,
>  	tx_skb->len = 0;
>  }
>  
> -static void rtl8169_tx_clear(struct rtl8169_private *tp)
> +static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start, u32 end)
>  {
> -	unsigned int i;
> +	u32 i;
>  
> -	for (i = tp->dirty_tx; i < tp->dirty_tx + NUM_TX_DESC; i++) {
> +	for (i = start; i < end; i++) {

Feel free to fix the (existing) wraparound bug.

>  		unsigned int entry = i % NUM_TX_DESC;
>  		struct ring_info *tx_skb = tp->tx_skb + entry;
>  		unsigned int len = tx_skb->len;
> @@ -4136,6 +4140,11 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
>  			tp->dev->stats.tx_dropped++;
>  		}
>  	}
> +}
> +
> +static inline void rtl8169_tx_clear(struct rtl8169_private *tp)

Though used several times, it's hardly time critical : drop the inline.

> +{
> +	rtl8169_tx_clear_range(tp, tp->dirty_tx, tp->dirty_tx + NUM_TX_DESC);
>  	tp->cur_tx = tp->dirty_tx = 0;
>  }
>  
> @@ -4254,6 +4263,8 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,

Please add a local &tp->pci_dev->dev variable.

>  		addr = ((void *) page_address(frag->page)) + frag->page_offset;
>  		mapping = dma_map_single(&tp->pci_dev->dev, addr, len,
>  					 PCI_DMA_TODEVICE);
> +		if (dma_mapping_error(&tp->pci_dev->dev, mapping))
> +			return -cur_frag;

I ponder adding an 'unlikely', goto some cleaning statement and return a
signification deprieved "I failed" value. The caller does it anyway but
I am not sure if it really is its business.

>  
>  		/* anti gcc 2.95.3 bugware (sic) */
>  		status = opts1 | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
> @@ -4314,7 +4325,10 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
>  	opts1 = DescOwn | rtl8169_tso_csum(skb, dev);
>  
>  	frags = rtl8169_xmit_frags(tp, skb, opts1);
> -	if (frags) {
> +	if (frags < 0) {

'unsigned int frags' problem.

[...]
> @@ -4355,6 +4371,10 @@ err_stop:
>  	netif_stop_queue(dev);
>  	dev->stats.tx_dropped++;
>  	return NETDEV_TX_BUSY;
> +
> +err_dma:
> +	rtl8169_tx_clear_range(tp, entry, entry + frags + 1);
> +	return NETDEV_TX_OK;

Third return statement, second NETDEV_TX_OK, no tx_dropped increase. May be
a bit heavy handed.

Otherwise it's cool.

-- 
Ueimor
