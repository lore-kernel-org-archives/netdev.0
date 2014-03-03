From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] vlan: use ether_addr_equal_64bits to instead
 of ether_addr_equal
Date: Sun, 02 Mar 2014 17:49:44 -0800
Message-ID: <1393811384.13719.47.camel@joe-AO722>
References: <5313D77F.3090508@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0143.hostedemail.com ([216.40.44.143]:40977 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751539AbaCCBts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 20:49:48 -0500
In-Reply-To: <5313D77F.3090508@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-03 at 09:14 +0800, Ding Tianhong wrote:
> Ether_addr_equal_64bits is more efficient than ether_addr_equal, and
> can be used when each argument is an array within a structure that
> contains at least two bytes of data beyond the array, so it is safe
> to use it for vlan.
[]
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
[]
> @@ -26,7 +26,7 @@ bool vlan_do_receive(struct sk_buff **skbp)
>  		/* Our lower layer thinks this is not local, let's make sure.
>  		 * This allows the VLAN to have a different MAC than the
>  		 * underlying device, and still route correctly. */
> -		if (ether_addr_equal(eth_hdr(skb)->h_dest, vlan_dev->dev_addr))
> +		if (ether_addr_equal_64bits(eth_hdr(skb)->h_dest, vlan_dev->dev_addr))
>  			skb->pkt_type = PACKET_HOST;
>  	}

Hi again Ding

If you do have performance numbers:

The lines above this ether_addr_equal_64 are:

	if (skb->pkt_type == PACKET_OTHERHOST) {
		/* Our lower layer thinks this is not local, let's make sure.
		 * This allows the VLAN to have a different MAC than the
		 * underlying device, and still route correctly. */
		if (ether_addr_equal(eth_hdr(skb)->h_dest, vlan_dev->dev_addr))
			skb->pkt_type = PACKET_HOST;
	}

Maybe it'd be faster overall to add an unlikely
to the == test

	if (unlikely(skb->pkt_type == PACKET_OTHERHOST)) {
