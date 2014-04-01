From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] vxlan: fix handling of the inner 8021Q
 tagged frame
Date: Tue, 01 Apr 2014 18:19:30 -0400 (EDT)
Message-ID: <20140401.181930.507358650238889815.davem@davemloft.net>
References: <87d2h1i0pj.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: atzm@stratosphere.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbaDAWTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 18:19:32 -0400
In-Reply-To: <87d2h1i0pj.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atzm Watanabe <atzm@stratosphere.co.jp>
Date: Tue, 01 Apr 2014 23:27:52 +0900

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
> +	default:
> +		key.vlan_id = 0;
> +	}
 ...
> @@ -1983,23 +2056,28 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
>  #endif
>  	}
>  
> -	f = vxlan_find_mac(vxlan, eth->h_dest);
> +	ether_addr_copy(key.eth_addr, eth->h_dest);
> +	key.vlan_id = vlan_tx_tag_present(skb) ? vlan_tx_tag_get_id(skb) : 0;
> +

Now the transmit and receive paths are more expensive, because instead
of just referring to packet header contents directly, we have to build
this key structure on the stack.

Please find a way to do this in a way which avoids this added cost.
