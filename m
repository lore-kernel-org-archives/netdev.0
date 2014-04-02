From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next v2] vxlan: fix handling of the inner 8021Q tagged
 frame
Date: Wed, 02 Apr 2014 17:30:55 +0900
Message-ID: <533BCABF.80303@lab.ntt.co.jp>
References: <87d2h1i0pj.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Atzm Watanabe <atzm@stratosphere.co.jp>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:33286 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757976AbaDBIbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 04:31:04 -0400
In-Reply-To: <87d2h1i0pj.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2014/04/01 23:27), Atzm Watanabe wrote:
> Currently the implementation can forward the 8021Q tagged frame,
> but the FDB cannot learn the VID.
> So there is a possibility of forwarding the frame to wrong VTEP,
> when same LLADDR exists on different VLANs.
> 
> This patch supports only single tagged frame, so the outermost
> tag will be used when handling the 8021AD Q-in-Q frame.
> 
> v2: Fix probably unsafe operation on the struct vxlan_key.
>     The outermost tag will be used when handling the 8021AD
>     Q-in-Q frame.  Based on Stephen Hemminger's comments.
> 
> Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>
...
> @@ -1215,8 +1257,18 @@ static void vxlan_rcv(struct vxlan_sock *vs,
>  #endif
>  	}
>  
> +	ether_addr_copy(key.eth_addr, eth_hdr(skb)->h_source);
> +	switch (ntohs(eth_hdr(skb)->h_proto)) {
> +	case ETH_P_8021Q:
> +	case ETH_P_8021AD:
> +		key.vlan_id = ntohs(vlan_eth_hdr(skb)->h_vlan_TCI) & VLAN_VID_MASK;
> +		break;

It seems that we can't segregate skbs tagged by same vlan id but
different vlan protocols.

> +	default:
> +		key.vlan_id = 0;
> +	}
> +
>  	if ((vxlan->flags & VXLAN_F_LEARN) &&
> -	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source))
> +	    vxlan_snoop(skb->dev, &saddr, &key))
>  		goto drop;
>  
>  	skb_reset_network_header(skb);
...
> @@ -1983,23 +2056,28 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
>  #endif
>  	}
>  
> -	f = vxlan_find_mac(vxlan, eth->h_dest);
> +	ether_addr_copy(key.eth_addr, eth->h_dest);
> +	key.vlan_id = vlan_tx_tag_present(skb) ? vlan_tx_tag_get_id(skb) : 0;

Can't we assume that skbs always have HW accelarated vlan tags?


Thanks,
Toshiaki Makita
