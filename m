From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/2] forcedeth: scatter gather and segmentation offload
 support
Date: Fri, 21 Oct 2005 17:23:14 -0400
Message-ID: <43595C42.4080201@pobox.com>
References: <432D7354.8000503@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <432D7354.8000503@colorfullife.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Manfred Spraul wrote:
> The attached patch adds scatter gather and segmentation offload support
> into forcedeth driver.
> 
> This patch has been tested by NVIDIA and reviewed by Manfred.
> 
> Notes:
> - Manfred mentioned that mapping of pages could take time and should not
> be under spinlock for performance reasons
> - During testing with netperf, I have noticed a connection running
> segmentation offload gets "unoffloaded" by the kernel due to possible
> retransmissions.
> 
> Thanks,
> Ayaz
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> Signed-off-By: Manfred Spraul <manfred@colorfullife.com>

Patch needs to be updated per [minor] comments below, and resent.


> ------------------------------------------------------------------------
> 
> --- orig-2.6/drivers/net/forcedeth.c	2005-09-06 11:54:41.000000000 -0700
> +++ 2.6/drivers/net/forcedeth.c	2005-09-06 13:52:50.000000000 -0700
> @@ -915,21 +920,44 @@
>  	return nv_alloc_rx(dev);
>  }
>  
> +static void nv_release_txskb(struct net_device *dev, unsigned int skbnr)
> +{
> +	struct fe_priv *np = get_nvpriv(dev);

Remove get_nvpriv() and call netdev_priv() directly.


> +	struct sk_buff *skb = np->tx_skbuff[skbnr];;
> +	unsigned int j, entry, fragments;
> +			
> +	dprintk(KERN_INFO "%s: nv_release_txskb for skbnr %d, skb %p\n",
> +		dev->name, skbnr, np->tx_skbuff[skbnr]);
> +	
> +	entry = skbnr;
> +	if ((fragments = skb_shinfo(skb)->nr_frags) != 0) {
> +		for (j = fragments; j >= 1; j--) {
> +			skb_frag_t *frag = &skb_shinfo(skb)->frags[j-1];
> +			pci_unmap_page(np->pci_dev, np->tx_dma[entry],
> +				       frag->size,
> +				       PCI_DMA_TODEVICE);
> +			entry = (entry - 1) % TX_RING;
> +		}
> +	}
> +	pci_unmap_single(np->pci_dev, np->tx_dma[entry],
> +			 skb->len - skb->data_len,
> +			 PCI_DMA_TODEVICE);
> +	dev_kfree_skb_irq(skb);
> +	np->tx_skbuff[skbnr] = NULL;
> +}
> +
>  static void nv_drain_tx(struct net_device *dev)
>  {
>  	struct fe_priv *np = get_nvpriv(dev);

ditto, etc.


> -	int i;
> +	unsigned int i;
> +	
>  	for (i = 0; i < TX_RING; i++) {
>  		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
>  			np->tx_ring.orig[i].FlagLen = 0;
>  		else
>  			np->tx_ring.ex[i].FlagLen = 0;
>  		if (np->tx_skbuff[i]) {
> -			pci_unmap_single(np->pci_dev, np->tx_dma[i],
> -						np->tx_skbuff[i]->len,
> -						PCI_DMA_TODEVICE);
> -			dev_kfree_skb(np->tx_skbuff[i]);
> -			np->tx_skbuff[i] = NULL;
> +			nv_release_txskb(dev, i);
>  			np->stats.tx_dropped++;
>  		}
>  	}
> @@ -968,28 +996,69 @@
>  static int nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct fe_priv *np = get_nvpriv(dev);
> -	int nr = np->next_tx % TX_RING;
> -	u32 tx_checksum = (skb->ip_summed == CHECKSUM_HW ? (NV_TX2_CHECKSUM_L3|NV_TX2_CHECKSUM_L4) : 0);
> +	u32 tx_flags_extra = (np->desc_ver == DESC_VER_1 ? NV_TX_LASTPACKET : NV_TX2_LASTPACKET);
> +	unsigned int fragments = skb_shinfo(skb)->nr_frags;
> +	unsigned int nr = (np->next_tx + fragments) % TX_RING;
> +	unsigned int i;
> +
> +	spin_lock_irq(&np->lock);
> +	wmb();

wmb() appears spurious AFAICS, with spinlock

> +	if ((np->next_tx - np->nic_tx + fragments) > TX_LIMIT_STOP) {

Why not references MAX_SKB_FRAGS like everyone else?


> +		spin_unlock_irq(&np->lock);
> +		netif_stop_queue(dev);
> +		return 1;

new code should properly use NETDEV_TX_xxx return code


> @@ -1020,7 +1087,8 @@
>  {
>  	struct fe_priv *np = get_nvpriv(dev);

use netdev_priv() directly

The rest looks OK.

	Jeff
