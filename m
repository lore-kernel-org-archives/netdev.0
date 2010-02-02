From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Handle vlan packets in
 skb_gso_segment()
Date: Tue, 02 Feb 2010 07:45:34 -0800 (PST)
Message-ID: <20100202.074534.109997141.davem@davemloft.net>
References: <1264454194.28852.130.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39077
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751790Ab0BBPpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 10:45:22 -0500
In-Reply-To: <1264454194.28852.130.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 25 Jan 2010 13:16:34 -0800

> Handle VLAN packets in skb_gso_segment(). Currently, when large
> VLAN packets are sent via virtio_net on guest and tun on host, 
> skb_gso_segment() fails with EPROTONOSUPPORT.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
 ...
> @@ -1672,6 +1672,12 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb, int features)
>  
> 	skb_reset_mac_header(skb);
> 	skb->mac_len = skb->network_header - skb->mac_header;
> +	if (ntohs(type) == ETH_P_8021Q) {
> +		skb->protocol = vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
> +		type = skb->protocol;
> +		skb->mac_len += VLAN_HLEN;
> +		skb_set_network_header(skb, skb->mac_len);
> +	}
> 	__skb_pull(skb, skb->mac_len);
>  

You can't do this.

Now, VLAN packets that are GSO handled will show up differently to
sniffers than those which do not get GSO handling.

You really can't pop the MAC header and modify the skb->protocol
here.
