From: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>
Subject: Re: [PATCH v2 5/8] net: pxa168_eth: get and set the mac address on
 the Ethernet controller
Date: Tue, 9 Sep 2014 12:29:58 -0400
Message-ID: <20140909162958.GS30828@titan.lakedaemon.net>
References: <1410273848-24663-1-git-send-email-antoine.tenart@free-electrons.com>
 <1410273848-24663-6-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, zmxu-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1410273848-24663-6-git-send-email-antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 09, 2014 at 04:44:05PM +0200, Antoine Tenart wrote:
> When changing the MAC address, in addition to updating the dev_addr in
> the net_device structure, this patch also update the MAC address
> registers (high and low) of the Ethernet controller with the new MAC.
> The address stored in these registers is used for IEEE 802.3x Ethernet
> flow control, which is already enabled.
> 
> This patch also tries reading the MAC address stored in these registers
> when probing the driver, to use the MAC address set by the bootloader
> and avoid using a random one.

Hmm, the wording here seems odd.  I think the preference should be:

 1) bootloader-supplied addr via DT
 2) addr read from device
 3) randomly generated one.

> 
> Signed-off-by: Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> ---
>  drivers/net/ethernet/marvell/pxa168_eth.c | 36 +++++++++++++++++++++++++++++--
>  1 file changed, 34 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
> index 10422f2df6cc..0ecbb3903b71 100644
> --- a/drivers/net/ethernet/marvell/pxa168_eth.c
> +++ b/drivers/net/ethernet/marvell/pxa168_eth.c
> @@ -60,6 +60,8 @@
>  #define PORT_COMMAND		0x0410
>  #define PORT_STATUS		0x0418
>  #define HTPR			0x0428
> +#define MAC_ADDR_LOW		0x0430
> +#define MAC_ADDR_HIGH		0x0438
>  #define SDMA_CONFIG		0x0440
>  #define SDMA_CMD		0x0448
>  #define INT_CAUSE		0x0450
> @@ -604,16 +606,42 @@ static void pxa168_eth_set_rx_mode(struct net_device *dev)
>  		update_hash_table_mac_address(pep, NULL, ha->addr);
>  }
>  
> +static void pxa168_eth_get_mac_address(struct net_device *dev,
> +				       unsigned char *addr)
> +{
> +	struct pxa168_eth_private *pep = netdev_priv(dev);
> +	unsigned int mac_h = rdl(pep, MAC_ADDR_HIGH);
> +	unsigned int mac_l = rdl(pep, MAC_ADDR_LOW);
> +
> +	addr[0] = (mac_h >> 24) & 0xff;
> +	addr[1] = (mac_h >> 16) & 0xff;
> +	addr[2] = (mac_h >> 8) & 0xff;
> +	addr[3] = mac_h & 0xff;
> +	addr[4] = (mac_l >> 8) & 0xff;
> +	addr[5] = mac_l & 0xff;
> +}
> +
>  static int pxa168_eth_set_mac_address(struct net_device *dev, void *addr)
>  {
>  	struct sockaddr *sa = addr;
>  	struct pxa168_eth_private *pep = netdev_priv(dev);
>  	unsigned char oldMac[ETH_ALEN];
> +	u32 mac_h, mac_l;
>  
>  	if (!is_valid_ether_addr(sa->sa_data))
>  		return -EADDRNOTAVAIL;
>  	memcpy(oldMac, dev->dev_addr, ETH_ALEN);
>  	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
> +
> +	mac_h = sa->sa_data[0] << 24;
> +	mac_h |= sa->sa_data[1] << 16;
> +	mac_h |= sa->sa_data[2] << 8;
> +	mac_h |= sa->sa_data[3];
> +	mac_l = sa->sa_data[4] << 8;
> +	mac_l |= sa->sa_data[5];
> +	wrl(pep, MAC_ADDR_HIGH, mac_h);
> +	wrl(pep, MAC_ADDR_LOW, mac_l);
> +
>  	netif_addr_lock_bh(dev);
>  	update_hash_table_mac_address(pep, oldMac, dev->dev_addr);
>  	netif_addr_unlock_bh(dev);
> @@ -1494,8 +1522,12 @@ static int pxa168_eth_probe(struct platform_device *pdev)
>  
>  	INIT_WORK(&pep->tx_timeout_task, pxa168_eth_tx_timeout_task);
>  
> -	dev_info(&pdev->dev, "Using random mac address\n");
> -	eth_hw_addr_random(dev);
> +	/* try reading the mac address, if set by the bootloader */
> +	pxa168_eth_get_mac_address(dev, dev->dev_addr);
> +	if (!is_valid_ether_addr(dev->dev_addr)) {
> +		dev_info(&pdev->dev, "Using random mac address\n");
> +		eth_hw_addr_random(dev);
> +	}

I would do the above iff there was no valid addr supplied by the DT.

thx,

Jason.
>  
>  	pep->rx_ring_size = NUM_RX_DESCS;
>  	pep->tx_ring_size = NUM_TX_DESCS;
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
