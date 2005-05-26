From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: [PATCH] [BRIDGE]
Date: Thu, 26 May 2005 09:36:59 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0505260934310.7768@webhosting.rdsbv.ro>
References: <Pine.LNX.4.62.0505241024580.19687@webhosting.rdsbv.ro>
 <20050525091427.35621a21@dxpl.pdx.osdl.net> <20050525144633.3a6f253e@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050525144633.3a6f253e@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 May 2005, Stephen Hemminger wrote:

> Here is the revised version, it deals with checksum mixtures better and
> ignores stuff until bridge is up.

This patch missing the case when we have HW_CSUM (for example) on the 
bridge device, and a new device that has no HW_CSUM is added.
The fix is to call br_features_recompute(br) also in br_add_if().

Thanks.

> Index: bridge/net/bridge/br_private.h
> ===================================================================
> --- bridge.orig/net/bridge/br_private.h
> +++ bridge/net/bridge/br_private.h
> @@ -174,6 +174,7 @@ extern int br_add_if(struct net_bridge *
> extern int br_del_if(struct net_bridge *br,
> 	      struct net_device *dev);
> extern int br_min_mtu(const struct net_bridge *br);
> +extern void br_features_recompute(struct net_bridge *br);
>
> /* br_input.c */
> extern int br_handle_frame_finish(struct sk_buff *skb);
> Index: bridge/net/bridge/br_notify.c
> ===================================================================
> --- bridge.orig/net/bridge/br_notify.c
> +++ bridge/net/bridge/br_notify.c
> @@ -65,6 +65,15 @@ static int br_device_event(struct notifi
> 		}
> 		break;
>
> +	case NETDEV_FEAT_CHANGE:
> +		if (br->dev->flags & IFF_UP)
> +			br_features_recompute(br);
> +
> +		/* could do recursive feature change notification
> +		 * but who would care??
> +		 */
> +		break;
> +
> 	case NETDEV_DOWN:
> 		if (br->dev->flags & IFF_UP)
> 			br_stp_disable_port(p);
> Index: bridge/net/bridge/br_device.c
> ===================================================================
> --- bridge.orig/net/bridge/br_device.c
> +++ bridge/net/bridge/br_device.c
> @@ -21,10 +21,7 @@
>
> static struct net_device_stats *br_dev_get_stats(struct net_device *dev)
> {
> -	struct net_bridge *br;
> -
> -	br = dev->priv;
> -
> +	struct net_bridge *br = netdev_priv(dev);
> 	return &br->statistics;
> }
>
> @@ -54,9 +51,11 @@ int br_dev_xmit(struct sk_buff *skb, str
>
> static int br_dev_open(struct net_device *dev)
> {
> -	netif_start_queue(dev);
> +	struct net_bridge *br = netdev_priv(dev);
>
> -	br_stp_enable_bridge(dev->priv);
> +	br_features_recompute(br);
> +	netif_start_queue(dev);
> +	br_stp_enable_bridge(br);
>
> 	return 0;
> }
> @@ -67,7 +66,7 @@ static void br_dev_set_multicast_list(st
>
> static int br_dev_stop(struct net_device *dev)
> {
> -	br_stp_disable_bridge(dev->priv);
> +	br_stp_disable_bridge(netdev_priv(dev));
>
> 	netif_stop_queue(dev);
>
> @@ -76,7 +75,7 @@ static int br_dev_stop(struct net_device
>
> static int br_change_mtu(struct net_device *dev, int new_mtu)
> {
> -	if ((new_mtu < 68) || new_mtu > br_min_mtu(dev->priv))
> +	if (new_mtu < 68 || new_mtu > br_min_mtu(netdev_priv(dev)))
> 		return -EINVAL;
>
> 	dev->mtu = new_mtu;
> Index: bridge/net/bridge/br_if.c
> ===================================================================
> --- bridge.orig/net/bridge/br_if.c
> +++ bridge/net/bridge/br_if.c
> @@ -314,6 +314,28 @@ int br_min_mtu(const struct net_bridge *
> 	return mtu;
> }
>
> +/*
> + * Recomputes features using slave's features
> + */
> +void br_features_recompute(struct net_bridge *br)
> +{
> +	struct net_bridge_port *p;
> +	unsigned long features, checksum;
> +
> +	features = NETIF_F_SG | NETIF_F_FRAGLIST
> +		| NETIF_F_HIGHDMA | NETIF_F_TSO;
> +	checksum = NETIF_F_IP_CSUM;	/* least commmon subset */
> +
> +	list_for_each_entry(p, &br->port_list, list) {
> +		if (!(p->dev->features
> +		      & (NETIF_F_IP_CSUM|NETIF_F_NO_CSUM|NETIF_F_HW_CSUM)))
> +			checksum = 0;
> +		features &= p->dev->features;
> +	}
> +
> +	br->dev->features = features | checksum | NETIF_F_LLTX;
> +}
> +
> /* called with RTNL */
> int br_add_if(struct net_bridge *br, struct net_device *dev)
> {
> @@ -368,6 +390,7 @@ int br_del_if(struct net_bridge *br, str
>
> 	spin_lock_bh(&br->lock);
> 	br_stp_recalculate_bridge_id(br);
> +	br_features_recompute(br);
> 	spin_unlock_bh(&br->lock);
>
> 	return 0;
>

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
