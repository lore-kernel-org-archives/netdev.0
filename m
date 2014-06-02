From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next v3] macvlan: fix the problem when mac address
 changes for passthru mode
Date: Mon, 02 Jun 2014 10:53:03 -0400
Message-ID: <538C8FCF.9010909@redhat.com>
References: <53882611.1080302@huawei.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Ding Tianhong <dingtianhong@huawei.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6856 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755133AbaFBOxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2014 10:53:13 -0400
In-Reply-To: <53882611.1080302@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2014 02:32 AM, Ding Tianhong wrote:
> The macvlan dev should always have the same mac address like lowerdev
> when in the passthru mode, change the mac address alone will break the
> work mechanism, so when the lowerdev or macvlan mac address changes,
> we should propagate the changes to another dev.
> 
> v1->v2: Allow macvlan dev to change mac address for passthru mode and propagate to
> 	lowerdev.
> 
> v2->v3: Don't set the mac address to the lower dev's unicast address for
> 	passthru mode when mac address changes.
> 

Looks good.

The only thing I'd add is a check to see if we are setting the same
mac address just to avoid all the possibly useless notifier work.

-vlad

> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/net/macvlan.c | 50 ++++++++++++++++++++++++++++++++++++++------------
>  1 file changed, 38 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index a665e90..d2dbcfc 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -494,35 +494,49 @@ hash_del:
>  	return 0;
>  }
>  
> -static int macvlan_set_mac_address(struct net_device *dev, void *p)
> +static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
>  {
>  	struct macvlan_dev *vlan = netdev_priv(dev);
>  	struct net_device *lowerdev = vlan->lowerdev;
> -	struct sockaddr *addr = p;
>  	int err;
>  
> -	if (!is_valid_ether_addr(addr->sa_data))
> -		return -EADDRNOTAVAIL;
> -
>  	if (!(dev->flags & IFF_UP)) {
>  		/* Just copy in the new address */
> -		memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
> +		ether_addr_copy(dev->dev_addr, addr);
>  	} else {
>  		/* Rehash and update the device filters */
> -		if (macvlan_addr_busy(vlan->port, addr->sa_data))
> +		if (macvlan_addr_busy(vlan->port, addr))
>  			return -EBUSY;
>  
> -		err = dev_uc_add(lowerdev, addr->sa_data);
> -		if (err)
> -			return err;
> +		if (!vlan->port->passthru) {
> +			err = dev_uc_add(lowerdev, addr);
> +			if (err)
> +				return err;
>  
> -		dev_uc_del(lowerdev, dev->dev_addr);
> +			dev_uc_del(lowerdev, dev->dev_addr);
> +		}
>  
> -		macvlan_hash_change_addr(vlan, addr->sa_data);
> +		macvlan_hash_change_addr(vlan, addr);
>  	}
>  	return 0;
>  }
>  
> +static int macvlan_set_mac_address(struct net_device *dev, void *p)
> +{
> +	struct macvlan_dev *vlan = netdev_priv(dev);
> +	struct sockaddr *addr = p;
> +
> +	if (!is_valid_ether_addr(addr->sa_data))
> +		return -EADDRNOTAVAIL;
> +
> +	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
> +		dev_set_mac_address(vlan->lowerdev, addr);
> +		return 0;
> +	}
> +
> +	return macvlan_sync_address(dev, addr->sa_data);
> +}
> +
>  static void macvlan_change_rx_flags(struct net_device *dev, int change)
>  {
>  	struct macvlan_dev *vlan = netdev_priv(dev);
> @@ -1106,6 +1120,18 @@ static int macvlan_device_event(struct notifier_block *unused,
>  			dev_set_mtu(vlan->dev, dev->mtu);
>  		}
>  		break;
> +	case NETDEV_CHANGEADDR:
> +		if (!port->passthru)
> +			return NOTIFY_DONE;
> +
> +		vlan = list_first_entry_or_null(&port->vlans,
> +						struct macvlan_dev,
> +						list);
> +
> +		if (macvlan_sync_address(vlan->dev, dev->dev_addr))
> +			return NOTIFY_BAD;
> +
> +		break;
>  	case NETDEV_UNREGISTER:
>  		/* twiddle thumbs on netns device moves */
>  		if (dev->reg_state != NETREG_UNREGISTERING)
> 
