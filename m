From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/4] USBNET: ax88179_178a: enable tso if host supports
 sg dma
Date: Wed, 31 Jul 2013 20:51:06 -0700
Message-ID: <1375329066.10515.125.camel@edumazet-glaptop>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	 <1375267909-30373-5-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375267909-30373-5-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-07-31 at 18:51 +0800, Ming Lei wrote:
> This patch enables 'can_dma_sg' flag for ax88179_178a device
> if the attached host controller supports building packet from
> discontinuous buffers(DMA SG is possible), so both frame header
> and skb data buffers can be passed to usb stack via urb->sg,
> then skb data copy can be saved.
> 
> With the patch, CPU utilization decreased much in iperf test at
> client mode.
> 
> Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  drivers/net/usb/ax88179_178a.c |   30 ++++++++++++++++++++++++++++++
>  1 file changed, 30 insertions(+)
> 
> diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
> index 5a468f3..c75bded 100644
> --- a/drivers/net/usb/ax88179_178a.c
> +++ b/drivers/net/usb/ax88179_178a.c
> @@ -1031,12 +1031,20 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
>  	dev->mii.phy_id = 0x03;
>  	dev->mii.supports_gmii = 1;
>  
> +	if (dev->udev->bus->no_sg_limit)
> +		dev->can_dma_sg = 1;
> +
>  	dev->net->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>  			      NETIF_F_RXCSUM;
>  
>  	dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>  				 NETIF_F_RXCSUM;
>  
> +	if (dev->can_dma_sg) {
> +		dev->net->features |= NETIF_F_SG | NETIF_F_TSO;
> +		dev->net->hw_features |= NETIF_F_SG | NETIF_F_TSO;
> +	}
> +
>  	/* Enable checksum offload */
>  	*tmp = AX_RXCOE_IP | AX_RXCOE_TCP | AX_RXCOE_UDP |
>  	       AX_RXCOE_TCPV6 | AX_RXCOE_UDPV6;
> @@ -1170,12 +1178,30 @@ ax88179_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
>  	int mss = skb_shinfo(skb)->gso_size;
>  	int headroom;
>  	int tailroom;
> +	struct skb_data *entry = (struct skb_data *)skb->cb;
>  
>  	tx_hdr1 = skb->len;
>  	tx_hdr2 = mss;
>  	if (((skb->len + 8) % frame_size) == 0)
>  		tx_hdr2 |= 0x80008000;	/* Enable padding */
>  
> +	if (dev->can_dma_sg) {



> +		if (!(entry->header = kmalloc(8, GFP_ATOMIC)))
> +			goto no_sg;
> +
> +		entry->length = 8;
> +		cpu_to_le32s(&tx_hdr1);
> +		cpu_to_le32s(&tx_hdr2);

You could do these cpu_to_le32s() calls before the if (dev->can_dma_sg)
and remove them before the skb_copy_to_linear_data() calls.

> +		memcpy(entry->header, &tx_hdr1, 4);
> +		memcpy(entry->header + 4, &tx_hdr2, 4);
> +
> +		return skb;
> +	} else {
> +no_sg:
> +		entry->header = NULL;
> +		entry->length = 0;
> +	}
> +
>  	headroom = skb_headroom(skb);
>  	tailroom = skb_tailroom(skb);
>  
> @@ -1323,6 +1349,10 @@ static int ax88179_reset(struct usbnet *dev)
>  
>  	dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>  				 NETIF_F_RXCSUM;
> +	if (dev->can_dma_sg) {
> +		dev->net->features |= NETIF_F_SG | NETIF_F_TSO;
> +		dev->net->hw_features |= NETIF_F_SG | NETIF_F_TSO;
> +	}

Are you sure this part is needed ?

Also it looks like that you are going through this sg allocation/setup
even for linear skb ?

For linear skb, with 8+ bytes of headroom, I guess this adds significant
overhead (2 kmalloc() + sg setup)



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
