From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Fri, 22 Oct 2004 23:46:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022214611.GA4948@electric-eye.fr.zoreil.com>
References: <41797696.9070905@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "Linux 802.1Q VLAN" <vlan@candelatech.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <41797696.9070905@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Minor nits below.

[...]
> @@ -484,13 +484,32 @@
>  	       veth->h_vlan_proto, veth->h_vlan_TCI, 
>  	       veth->h_vlan_encapsulated_proto);
>  #endif
> 
> -	stats->tx_packets++; /* for statics only */
> -	stats->tx_bytes += skb->len;
> -
>  	skb->dev = VLAN_DEV_INFO(dev)->real_dev;
> -	dev_queue_xmit(skb);
> 
> -	return 0;
> +	{
> +		/* Please note, dev_queue_xmit consumes the pkt regardless of the
> +		 * error value.  So, will copy the skb first and free if successful.
> +		 */
> +		struct sk_buff* skb2 = skb_get(skb);
> +		int rv = dev_queue_xmit(skb2);
> +		if (rv != 0) {
> +			/* The skb memory should still be valid since we made a copy,
> +			 * so can return error code here.
> +			 */
> +			return rv;
> +		}
> +		else {
> +			/* Was success, need to free the skb reference since we bumped up the
> +			 * user count above.
> +			 */
> +
> +			stats->tx_packets++; /* for statics only */
> +			stats->tx_bytes += skb->len;
> +
> +			kfree_skb(skb);
> +			return 0;
> +		}
> +	}


Why not use a single return point, say:

		struct sk_buff *skb2 = skb_get(skb);
		int rv = dev_queue_xmit(skb2);

		if (!rv) {
			/* 
			 * Was success, need to free the skb reference since 
			 * we bumped up the user count above.
			 */

			stats->tx_packets++; /* for statics only */
			stats->tx_bytes += skb->len;

			kfree_skb(skb);
		}
		return rv;

vlan_dev_get_realdev_name() and vlan_dev_get_vid() can be tidy up 
a bit (factoring dev_put() or handling debug code differently for instance).

[...]
> --- linux-2.6.9/include/linux/if_vlan.h	2004-10-18 
> 14:53:43.000000000 -0700
> +++ linux-2.6.9.p4s/include/linux/if_vlan.h	2004-10-22 
> 12:14:24.000000000 -0700
> @@ -366,7 +366,9 @@
>  	GET_VLAN_INGRESS_PRIORITY_CMD,
>  	GET_VLAN_EGRESS_PRIORITY_CMD,
>  	SET_VLAN_NAME_TYPE_CMD,
> -	SET_VLAN_FLAG_CMD
> +	SET_VLAN_FLAG_CMD,
> +        GET_VLAN_REALDEV_NAME_CMD, /* If this works, you know it's a VLAN device, btw */
> +        GET_VLAN_VID_CMD /* Get the VID of this VLAN (specified by name) */
>  };

Whitespace attacks.


My 0.02 U+20AC

--
Ueimor
