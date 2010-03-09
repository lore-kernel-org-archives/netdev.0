From: David Hollis <dhollis@davehollis.com>
Subject: Re: [PATCH] asix: fix setting mac address for AX88772
Date: Tue, 09 Mar 2010 18:25:33 -0500
Message-ID: <4B96D8ED.1010506@davehollis.com>
References: <20100309222438.10684.46211.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173011pub.verizon.net ([206.46.173.11]:57736 "EHLO
	vms173011pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585Ab0CIXZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 18:25:54 -0500
Received: from smtp.davehollis.com ([unknown] [173.65.165.104])
 by vms173011.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 7u2-7.02 32bit (built Apr 16 2009))
 with ESMTPA id <0KZ100BSDFQU987C@vms173011.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 09 Mar 2010 17:25:46 -0600 (CST)
In-reply-to: <20100309222438.10684.46211.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/09/2010 05:24 PM, Jussi Kivilinna wrote:
> Setting new MAC address only worked when device was set to promiscuous mode.
> Fix MAC address by writing new address to device using undocumented command
> AX_CMD_READ_NODE_ID+1. Patch is tested with AX88772 device.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Acked-by: David Hollis <dhollis@davehollis.com>

> ---
> 
>  drivers/net/usb/asix.c |   30 ++++++++++++++++++++++++++++--
>  1 files changed, 28 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
> index 20e3460..9e05639 100644
> --- a/drivers/net/usb/asix.c
> +++ b/drivers/net/usb/asix.c
> @@ -54,6 +54,7 @@ static const char driver_name [] = "asix";
>  #define AX_CMD_WRITE_IPG0		0x12
>  #define AX_CMD_WRITE_IPG1		0x13
>  #define AX_CMD_READ_NODE_ID		0x13
> +#define AX_CMD_WRITE_NODE_ID		0x14
>  #define AX_CMD_WRITE_IPG2		0x14
>  #define AX_CMD_WRITE_MULTI_FILTER	0x16
>  #define AX88172_CMD_READ_NODE_ID	0x17
> @@ -165,6 +166,7 @@ static const char driver_name [] = "asix";
>  /* This structure cannot exceed sizeof(unsigned long [5]) AKA 20 bytes */
>  struct asix_data {
>  	u8 multi_filter[AX_MCAST_FILTER_SIZE];
> +	u8 mac_addr[ETH_ALEN];
>  	u8 phymode;
>  	u8 ledmode;
>  	u8 eeprom_len;
> @@ -732,6 +734,30 @@ static int asix_ioctl (struct net_device *net, struct ifreq *rq, int cmd)
>  	return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
>  }
>  
> +static int asix_set_mac_address(struct net_device *net, void *p)
> +{
> +	struct usbnet *dev = netdev_priv(net);
> +	struct asix_data *data = (struct asix_data *)&dev->data;
> +	struct sockaddr *addr = p;
> +
> +	if (netif_running(net))
> +		return -EBUSY;
> +	if (!is_valid_ether_addr(addr->sa_data))
> +		return -EADDRNOTAVAIL;
> +
> +	memcpy(net->dev_addr, addr->sa_data, ETH_ALEN);
> +
> +	/* We use the 20 byte dev->data
> +	 * for our 6 byte mac buffer
> +	 * to avoid allocating memory that
> +	 * is tricky to free later */
> +	memcpy(data->mac_addr, addr->sa_data, ETH_ALEN);
> +	asix_write_cmd_async(dev, AX_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
> +							data->mac_addr);
> +
> +	return 0;
> +}
> +
>  /* We need to override some ethtool_ops so we require our
>     own structure so we don't interfere with other usbnet
>     devices that may be connected at the same time. */
> @@ -919,7 +945,7 @@ static const struct net_device_ops ax88772_netdev_ops = {
>  	.ndo_start_xmit		= usbnet_start_xmit,
>  	.ndo_tx_timeout		= usbnet_tx_timeout,
>  	.ndo_change_mtu		= usbnet_change_mtu,
> -	.ndo_set_mac_address 	= eth_mac_addr,
> +	.ndo_set_mac_address 	= asix_set_mac_address,
>  	.ndo_validate_addr	= eth_validate_addr,
>  	.ndo_do_ioctl		= asix_ioctl,
>  	.ndo_set_multicast_list = asix_set_multicast,
> @@ -1213,7 +1239,7 @@ static const struct net_device_ops ax88178_netdev_ops = {
>  	.ndo_stop		= usbnet_stop,
>  	.ndo_start_xmit		= usbnet_start_xmit,
>  	.ndo_tx_timeout		= usbnet_tx_timeout,
> -	.ndo_set_mac_address 	= eth_mac_addr,
> +	.ndo_set_mac_address 	= asix_set_mac_address,
>  	.ndo_validate_addr	= eth_validate_addr,
>  	.ndo_set_multicast_list = asix_set_multicast,
>  	.ndo_do_ioctl 		= asix_ioctl,
> 

