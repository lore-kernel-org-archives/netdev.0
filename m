From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Fri, 29 Oct 2004 01:40:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4181838B.6040002@tpack.net>
References: <41797696.9070905@candelatech.com>	<20041022214611.GA4948@electric-eye.fr.zoreil.com> <41798506.1030909@candelatech.com> <417D675F.3000909@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "Linux 802.1Q VLAN" <vlan@candelatech.com>,
        Francois Romieu <romieu@fr.zoreil.com>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <417D675F.3000909@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> 
> --- linux-2.6.9/net/8021q/vlan_dev.c	2004-10-18 14:55:07.000000000 -0700
> +++ linux-2.6.9.p4s/net/8021q/vlan_dev.c	2004-10-25 13:38:32.779294920 -0700
> @@ -1,4 +1,4 @@
> -/*
> +/* -*- linux-c -*-
>   * INET		802.1Q VLAN
>   *		Ethernet-type device handling.
>   *
> @@ -484,13 +484,26 @@
>  	       veth->h_vlan_proto, veth->h_vlan_TCI, veth->h_vlan_encapsulated_proto);
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
> +		if (rv == 0) {
> +			/* Was success, need to free the skb reference since we bumped up the
> +			 * user count above.
> +			 */
> +
> +			stats->tx_packets++; /* for statics only */
> +			stats->tx_bytes += skb->len;
> +
> +			kfree_skb(skb);
> +		}
> +		return rv;
> +	}
>  }
>  
>  int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)

Hi Ben,

I am not happy with this change to vlan_dev_hard_start_xmit().

I certainly appreciate the idea of avoiding flow-control "black-holes", but that would
take more than just this change. You have to consider (at least) these issues:

  o It is considered an error if a queue-less device returns anything but zero from its
    hard_start_xmit() function (see dev_queue_xmit()).

  o So, lets add a tx queue to it. Sure, that would be nice. Now we can even do shaping
    and other fancy stuff. But then how do we manage netif_queue_stopped? Especially
    restarting the queue could be tricky.

  o But couldn't we skip netif_stop_queue() and just return NETDEV_TX_BUSY when congested?
    No, that would make the qdisc system "busy-retry" untill it succeeds. BAD.

  o It is unsafe to pass a shared skb to dev_queue_xmit() unless you control all the
    references yourself. (It will likely be enqueued on a list.)

And specifically for this patch:

  o The skb could be freed (replaced) in __vlan_put_tag(), so you cannot tell the caller
    to hang on to it.

  o If rv is NET_XMIT_CN (and probably also rv < 0) you have to return 0, in order to
    make the caller forget about this skb.


Dave, I think this part of the patch should be reverted until someone comes up with a
general scheme for flow_control handling through virtual devices.


-Tommy
