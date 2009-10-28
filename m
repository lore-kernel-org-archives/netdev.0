From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/6] vlan: Optimize multiple unregistration
Date: Wed, 28 Oct 2009 21:05:57 +0100
Message-ID: <4AE8A425.1000600@trash.net>
References: <4AE728A9.2080209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64900 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329AbZJ1UGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 16:06:02 -0400
In-Reply-To: <4AE728A9.2080209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Use unregister_netdevice_many() to speedup master device unregister.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  include/linux/if_vlan.h |    1 
>  net/8021q/vlan.c        |   49 +++++++++++++++++++++++++-------------
>  net/core/dev.c          |    1 
>  3 files changed, 35 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index 8898cbe..71a4870 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -85,6 +85,7 @@ struct vlan_group {
>  					    * the vlan is attached to.
>  					    */
>  	unsigned int		nr_vlans;
> +	int			killall;
>  	struct hlist_node	hlist;	/* linked list */
>  	struct net_device **vlan_devices_arrays[VLAN_GROUP_ARRAY_SPLIT_PARTS];
>  	struct rcu_head		rcu;
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index 6b5c9dd..511afe7 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -159,11 +159,12 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
>  	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
>  		ops->ndo_vlan_rx_kill_vid(real_dev, vlan_id);
>  
> -	vlan_group_set_device(grp, vlan_id, NULL);
>  	grp->nr_vlans--;
>  
> -	synchronize_net();
> -
> +	if (!grp->killall) {
> +		vlan_group_set_device(grp, vlan_id, NULL);
> +		synchronize_net();
> +	}
>  	unregister_netdevice_queue(dev, head);
>  
>  	/* If the group is now empty, kill off the group. */
> @@ -183,6 +184,34 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
>  	dev_put(real_dev);
>  }
>  
> +void unregister_vlan_dev_alls(struct vlan_group *grp)

This could be static.

> +{
> +	LIST_HEAD(list);
> +	int i;
> +	struct net_device *vlandev;
> +	struct vlan_group save;
> +
> +	memcpy(&save, grp, sizeof(save));
> +	memset(&grp->vlan_devices_arrays, 0, sizeof(grp->vlan_devices_arrays));

This shouldn't be necessary since the lower device is already in the
process of being unregistered. If it was necessary, it could cause
crashes since the individual pointers are not set to zero atomically.
Or maybe I'm misunderstanding the purpose entirely :)

> +	grp->killall = 1;
> +
> +	synchronize_net();
> +
> +	/* Delete all VLANs for this dev. */
> +	for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
> +		vlandev = vlan_group_get_device(&save, i);
> +		if (!vlandev)
> +			continue;
> +
> +		unregister_vlan_dev(vlandev, &list);
> +		if (grp->nr_vlans == 0)
> +			break;
> +	}
> +	unregister_netdevice_many(&list);
> +	for (i = 0; i < VLAN_GROUP_ARRAY_SPLIT_PARTS; i++)
> +		kfree(save.vlan_devices_arrays[i]);
> +}
> +
>  static void vlan_transfer_operstate(const struct net_device *dev,
>  				    struct net_device *vlandev)
>  {
> @@ -524,19 +553,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
>  		break;
>  
>  	case NETDEV_UNREGISTER:
> -		/* Delete all VLANs for this dev. */
> -		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
> -			vlandev = vlan_group_get_device(grp, i);
> -			if (!vlandev)
> -				continue;
> -
> -			/* unregistration of last vlan destroys group, abort
> -			 * afterwards */
> -			if (grp->nr_vlans == 1)
> -				i = VLAN_GROUP_ARRAY_LEN;
> -
> -			unregister_vlan_dev(vlandev, NULL);
> -		}
> +		unregister_vlan_dev_alls(grp);
>  		break;
>  	}
>  

