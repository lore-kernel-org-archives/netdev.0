From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net/mlx4_en: Advertise HIGH DMA support only
 if dma mask is 64 bit
Date: Mon, 12 Aug 2013 18:32:40 +0200
Message-ID: <1376325160.14079.59.camel@deadeye.wl.decadent.org.uk>
References: <1376296230-12276-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	Alexander Guller <alexg@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33902 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756189Ab3HLQcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 12:32:47 -0400
In-Reply-To: <1376296230-12276-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-08-12 at 11:30 +0300, Amir Vadai wrote:
> Need to check that the pci device DMA mask was set to 64 bit support
> (done by mlx4_core) before advertising HIGH DMA support in higher drivers.
> Otherwise, may run into an issue that skb/frag/data is in high memory
> and can't dma map it, thus packets are dropped.

NETIF_F_HIGHDMA means that the driver can transmit skbs with page
fragments in high memory, i.e. it doesn't require them to have an
existing virtual mapping for the kernel.  If I'm not mistaken, this
should be cleared only for drivers that don't use DMA or kmap functions.

On a 64-bit machine there is no highmem and without NETIF_F_HIGHDMA you
can still be given pages at any physical address.

On a 32-bit machine highmem usually starts at 1GB and I doubt you have
any chips that are that limited in DMA range. :-)

I really doubt this is the fix you're looking for.

Ben.

> Signed-off-by: Alexander Guller <alexg@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index fa37b7a..9568b77 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2317,9 +2317,13 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
>  	dev->vlan_features = dev->hw_features;
>  
>  	dev->hw_features |= NETIF_F_RXCSUM | NETIF_F_RXHASH;
> -	dev->features = dev->hw_features | NETIF_F_HIGHDMA |
> +	dev->features = dev->hw_features |
>  			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX |
>  			NETIF_F_HW_VLAN_CTAG_FILTER;
> +
> +	if (mdev->dev->pdev->dma_mask == DMA_BIT_MASK(64))
> +		dev->features |= NETIF_F_HIGHDMA;
> +
>  	dev->hw_features |= NETIF_F_LOOPBACK;
>  
>  	if (mdev->dev->caps.steering_mode ==

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
