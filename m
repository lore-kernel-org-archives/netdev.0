From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 2/5] vxlan: make COLLECT_METADATA mode bridge
 friendly
Date: Sun, 22 Jan 2017 12:40:47 +0100
Message-ID: <f4c86e0a-472b-700c-98fe-f5da2eea35e6@cumulusnetworks.com>
References: <1484977616-1541-1-git-send-email-roopa@cumulusnetworks.com>
 <1484977616-1541-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37224 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdAVLku (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 06:40:50 -0500
Received: by mail-wm0-f42.google.com with SMTP id c206so112251036wme.0
        for <netdev@vger.kernel.org>; Sun, 22 Jan 2017 03:40:49 -0800 (PST)
In-Reply-To: <1484977616-1541-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/01/17 06:46, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch series makes vxlan COLLECT_METADATA mode bridge
> and layer2 network friendly. Vxlan COLLECT_METADATA mode today
> solves the per-vni netdev scalability problem in l3 networks.
> When vxlan collect metadata device participates in bridging
> vlan to vn-segments, It can only get the vlan mapped vni in
> the xmit tunnel dst metadata. It will need the vxlan driver to
> continue learn, hold forwarding state and remote destination
> information similar to how it already does for non COLLECT_METADATA
> vxlan netdevices today.
> 
> Changes introduced by this patch:
>     - allow learning and forwarding database state to vxlan netdev in
>       COLLECT_METADATA mode. Current behaviour is not changed
>       by default. tunnel info flag IP_TUNNEL_INFO_BRIDGE is used
>       to support the new bridge friendly mode.
>     - A single fdb table hashed by (mac, vni) to allow fdb entries with
>       multiple vnis in the same fdb table
>     - rx path already has the vni
>     - tx path expects a vni in the packet with dst_metadata
>     - prior to this series, fdb remote_dsts carried remote vni and
>       the vxlan device carrying the fdb table represented the
>       source vni. With the vxlan device now representing multiple vnis,
>       this patch adds a src vni attribute to the fdb entry. The remote
>       vni already uses NDA_VNI attribute. This patch introduces
>       NDA_SRC_VNI netlink attribute to represent the src vni in a multi
>       vni fdb table.
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
[snip]
> @@ -2173,23 +2221,29 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
>  	bool did_rsc = false;
>  	struct vxlan_rdst *rdst, *fdst = NULL;
>  	struct vxlan_fdb *f;
> +	__be32 vni = 0;
>  
>  	info = skb_tunnel_info(skb);
>  
>  	skb_reset_mac_header(skb);
>  
>  	if (vxlan->flags & VXLAN_F_COLLECT_METADATA) {
> -		if (info && info->mode & IP_TUNNEL_INFO_TX)
> -			vxlan_xmit_one(skb, dev, NULL, false);
> -		else
> -			kfree_skb(skb);
> -		return NETDEV_TX_OK;
> +		if (info && info->mode & IP_TUNNEL_INFO_BRIDGE &&
> +		    info->mode & IP_TUNNEL_INFO_TX) {

nit: parentheses around the IP_TUNNEL_INFO_TX check

> +			vni = tunnel_id_to_key32(info->key.tun_id);
> +		} else {
> +			if (info && info->mode & IP_TUNNEL_INFO_TX)

nit: parentheses around the IP_TUNNEL_INFO_TX check

> +				vxlan_xmit_one(skb, dev, vni, NULL, false);
> +			else
> +				kfree_skb(skb);
> +			return NETDEV_TX_OK;
> +		}
>  	}
>  
>  	if (vxlan->flags & VXLAN_F_PROXY) {
>  		eth = eth_hdr(skb);
>  		if (ntohs(eth->h_proto) == ETH_P_ARP)
> -			return arp_reduce(dev, skb);
> +			return arp_reduce(dev, skb, vni);
>  #if IS_ENABLED(CONFIG_IPV6)
>  		else if (ntohs(eth->h_proto) == ETH_P_IPV6 &&
>  			 pskb_may_pull(skb, sizeof(struct ipv6hdr)
> @@ -2200,13 +2254,13 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
>  				msg = (struct nd_msg *)skb_transport_header(skb);
>  				if (msg->icmph.icmp6_code == 0 &&
>  				    msg->icmph.icmp6_type == NDISC_NEIGHBOUR_SOLICITATION)
> -					return neigh_reduce(dev, skb);
> +					return neigh_reduce(dev, skb, vni);
>  		}
>  #endif
>  	}
>  
>  	eth = eth_hdr(skb);
> -	f = vxlan_find_mac(vxlan, eth->h_dest);
> +	f = vxlan_find_mac(vxlan, eth->h_dest, vni);
>  	did_rsc = false;
>  
>  	if (f && (f->flags & NTF_ROUTER) && (vxlan->flags & VXLAN_F_RSC) &&
> @@ -2214,11 +2268,11 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
>  	     ntohs(eth->h_proto) == ETH_P_IPV6)) {
>  		did_rsc = route_shortcircuit(dev, skb);
>  		if (did_rsc)
> -			f = vxlan_find_mac(vxlan, eth->h_dest);
> +			f = vxlan_find_mac(vxlan, eth->h_dest, vni);
>  	}
>  
>  	if (f == NULL) {
> -		f = vxlan_find_mac(vxlan, all_zeros_mac);
> +		f = vxlan_find_mac(vxlan, all_zeros_mac, vni);
>  		if (f == NULL) {
>  			if ((vxlan->flags & VXLAN_F_L2MISS) &&
>  			    !is_multicast_ether_addr(eth->h_dest))
> @@ -2239,11 +2293,11 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
>  		}
>  		skb1 = skb_clone(skb, GFP_ATOMIC);
>  		if (skb1)
> -			vxlan_xmit_one(skb1, dev, rdst, did_rsc);
> +			vxlan_xmit_one(skb1, dev, vni, rdst, did_rsc);
>  	}
>  
>  	if (fdst)
> -		vxlan_xmit_one(skb, dev, fdst, did_rsc);
> +		vxlan_xmit_one(skb, dev, vni, fdst, did_rsc);
>  	else
>  		kfree_skb(skb);
>  	return NETDEV_TX_OK;
> @@ -2307,12 +2361,12 @@ static int vxlan_init(struct net_device *dev)
>  	return 0;
>  }
>  
> -static void vxlan_fdb_delete_default(struct vxlan_dev *vxlan)
> +static void vxlan_fdb_delete_default(struct vxlan_dev *vxlan, __be32 vni)
>  {
>  	struct vxlan_fdb *f;
>  
>  	spin_lock_bh(&vxlan->hash_lock);
> -	f = __vxlan_find_mac(vxlan, all_zeros_mac);
> +	f = __vxlan_find_mac(vxlan, all_zeros_mac, vni);
>  	if (f)
>  		vxlan_fdb_destroy(vxlan, f);
>  	spin_unlock_bh(&vxlan->hash_lock);
> @@ -2322,7 +2376,7 @@ static void vxlan_uninit(struct net_device *dev)
>  {
>  	struct vxlan_dev *vxlan = netdev_priv(dev);
>  
> -	vxlan_fdb_delete_default(vxlan);
> +	vxlan_fdb_delete_default(vxlan, vxlan->cfg.vni);
>  
>  	free_percpu(dev->tstats);
>  }
> @@ -2536,6 +2590,8 @@ static void vxlan_setup(struct net_device *dev)
>  	dev->vlan_features = dev->features;
>  	dev->hw_features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
>  	dev->hw_features |= NETIF_F_GSO_SOFTWARE;
> +	dev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX;
> +	dev->features |= dev->hw_features;
>  	netif_keep_dst(dev);
>  	dev->priv_flags |= IFF_NO_QUEUE;
>  
> @@ -2921,6 +2977,7 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
>  				       NLM_F_EXCL|NLM_F_CREATE,
>  				       vxlan->cfg.dst_port,
>  				       vxlan->default_dst.remote_vni,
> +				       vxlan->default_dst.remote_vni,
>  				       vxlan->default_dst.remote_ifindex,
>  				       NTF_SELF);
>  		if (err)
> @@ -2929,7 +2986,7 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
>  
>  	err = register_netdevice(dev);
>  	if (err) {
> -		vxlan_fdb_delete_default(vxlan);
> +		vxlan_fdb_delete_default(vxlan, vxlan->cfg.vni);
>  		return err;
>  	}
>  
> @@ -3023,19 +3080,19 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
>  		conf.flags |= VXLAN_F_UDP_ZERO_CSUM_TX;
>  
>  	if (data[IFLA_VXLAN_UDP_ZERO_CSUM6_TX] &&
> -	    nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]))
> +	    !nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]))
>  		conf.flags |= VXLAN_F_UDP_ZERO_CSUM6_TX;
>  
>  	if (data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX] &&
> -	    nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
> +	    !nla_get_u8(data[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
>  		conf.flags |= VXLAN_F_UDP_ZERO_CSUM6_RX;
>  
>  	if (data[IFLA_VXLAN_REMCSUM_TX] &&
> -	    nla_get_u8(data[IFLA_VXLAN_REMCSUM_TX]))
> +	    !nla_get_u8(data[IFLA_VXLAN_REMCSUM_TX]))
>  		conf.flags |= VXLAN_F_REMCSUM_TX;
>  
>  	if (data[IFLA_VXLAN_REMCSUM_RX] &&
> -	    nla_get_u8(data[IFLA_VXLAN_REMCSUM_RX]))
> +	    !nla_get_u8(data[IFLA_VXLAN_REMCSUM_RX]))
>  		conf.flags |= VXLAN_F_REMCSUM_RX;

Aren't these going to break user-space ? 

>  
>  	if (data[IFLA_VXLAN_GBP])
> diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
> index bd99a8d..f3d16db 100644
> --- a/include/uapi/linux/neighbour.h
> +++ b/include/uapi/linux/neighbour.h
> @@ -26,6 +26,7 @@ enum {
>  	NDA_IFINDEX,
>  	NDA_MASTER,
>  	NDA_LINK_NETNSID,
> +	NDA_SRC_VNI,
>  	__NDA_MAX
>  };
>  
> 
