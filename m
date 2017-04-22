From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] net: natsemi: ns83820: add checks for dma mapping
 error
Date: Sat, 22 Apr 2017 21:20:20 +0200
Message-ID: <20170422192020.GA10084@electric-eye.fr.zoreil.com>
References: <20170417.151743.1779341653983811894.davem@davemloft.net>
 <1492866365-5422-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1492866365-5422-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Khoroshilov <khoroshilov@ispras.ru> :
[...]
> diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
> index 729095db3e08..dfc64e1e31f9 100644
> --- a/drivers/net/ethernet/natsemi/ns83820.c
> +++ b/drivers/net/ethernet/natsemi/ns83820.c
[...]
> @@ -1183,6 +1193,32 @@ static netdev_tx_t ns83820_hard_start_xmit(struct sk_buff *skb,
>  		netif_start_queue(ndev);
>  
>  	return NETDEV_TX_OK;
> +
> +dma_error:
> +	do {
> +		free_idx = (free_idx + NR_TX_DESC - 1) % NR_TX_DESC;
> +		desc = dev->tx_descs + (free_idx * DESC_SIZE);
> +		cmdsts = le32_to_cpu(desc[DESC_CMDSTS]);
> +		len = cmdsts & CMDSTS_LEN_MASK;
> +		buf = desc_addr_get(desc + DESC_BUFPTR);
> +		if (desc == first_desc)
> +			pci_unmap_single(dev->pci_dev,
> +					buf,
> +					len,
> +					PCI_DMA_TODEVICE);
> +		else
> +			pci_unmap_page(dev->pci_dev,
> +					buf,
> +					len,
> +					PCI_DMA_TODEVICE);

(use tabs + spaces to indent: code should line up right after the parenthesis)

(premature line breaks imho)

(nevermind, both can be avoided :o) )

> +		desc[DESC_CMDSTS] = cpu_to_le32(0);
> +		mb();
> +	} while (desc != first_desc);
> +
> +dma_error_first:
> +	dev_kfree_skb_any(skb);
> +	ndev->stats.tx_errors++;
                    ^^^^^^^^^ -> should be tx_dropped
> +	return NETDEV_TX_OK;
>  }

You only need a single test in the error loop if you mimic the map loop.
Something like:

diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index 729095d..5e2dbc9 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -1160,9 +1160,11 @@ static netdev_tx_t ns83820_hard_start_xmit(struct sk_buff *skb,
 
 		buf = skb_frag_dma_map(&dev->pci_dev->dev, frag, 0,
 				       skb_frag_size(frag), DMA_TO_DEVICE);
+		if (dma_mapping_error(&dev->pci_dev->dev, buf))
+			goto err_unmap_frags;
 		dprintk("frag: buf=%08Lx  page=%08lx offset=%08lx\n",
 			(long long)buf, (long) page_to_pfn(frag->page),
 			frag->page_offset);
 		len = skb_frag_size(frag);
 		frag++;
 		nr_frags--;
@@ -1181,8 +1184,27 @@ static netdev_tx_t ns83820_hard_start_xmit(struct sk_buff *skb,
 	/* Check again: we may have raced with a tx done irq */
 	if (stopped && (dev->tx_done_idx != tx_done_idx) && start_tx_okay(dev))
 		netif_start_queue(ndev);
-
+out:
 	return NETDEV_TX_OK;
+
+err_unmap_frags:
+	while (1) {
+		buf = desc_addr_get(desc + DESC_BUFPTR);
+		if (!--nr_frags)
+			break;
+
+		pci_unmap_page(dev->pci_dev, buf, len, PCI_DMA_TODEVICE);
+
+		free_idx = (free_idx - 1) % NR_TX_DESC;
+		desc = dev->tx_descs + (free_idx * DESC_SIZE);
+		len = le32_to_cpu(desc + DESC_CMDSTS) & CMDSTS_LEN_MASK;
+	}
+	pci_unmap_single(dev->pci_dev, buf, len, PCI_DMA_TODEVICE);
+
+err_free_skb:
+	dev_kfree_skb_any(skb);
+	ndev->stats.tx_dropped++;
+	goto out;
 }
 
 static void ns83820_update_stats(struct ns83820 *dev)


Thinking more about it, the driver seems rather unsafe if a failing
start_xmit closely follows a succeeding one. The driver should imho
map frags first *then* plug the remaining hole in the descriptor ring.
Until it does, the implicit assumption about descriptor ownership that
the error unroll loop relies on may be wrong.

-- 
Ueimor
