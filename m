From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH,RFC] skb->network_header and __vlan_put_tag()
Date: Tue, 17 Jun 2008 14:18:12 +0200
Message-ID: <4857AB84.2090409@trash.net>
References: <20080616221525.GG27971@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62419 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755100AbYFQMSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 08:18:20 -0400
In-Reply-To: <20080616221525.GG27971@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> __vlan_put_tag() is not only substracting 4 from the skb's
> ->mac_header pointer (which kind of makes sense[*]), but it is
> substracting 4 from the ->network_header pointer as well.
> 
> Conceptually, sure, VLAN is another layer of encapsulation between
> ethernet and IP, but doesn't it make more sense to just consider the
> VLAN tag part of the MAC header?  What good does it do to point
> ->network_header to the _middle_ of the VLAN tag when a VLAN tag is
> inserted?
> 
> I'm adding VLAN support to mv643xx_eth (which does not support HW
> insertion of a VLAN tag, but it does support HW checksumming when
> a VLAN tag is present, you just have to tell the HW how many bytes
> there are between the start of the packet and the IP header), and
> I'm ending up with code like this:
> 
> 	if (skb->protocol == htons(ETH_P_8021Q))
> 		ip_header = ip_hdr(skb) + 4;
> 	else
> 		ip_header = ip_hdr(skb);
> 
> whereas it'd be nicer if you could just have the same code for the
> VLAN and non-VLAN case:
> 
> 	ip_header = ip_hdr(skb);
> 
> 
> [*] But skb->mac_header seems to be mostly NULL when this function
>     is called, causing it to end up being 0xfffffffc by the time the
>     packet is given to the device's ->hard_start_xmit().

I agree that your patch makes sense, it seems some drivers
(niu, gianfar) even assume this. Regarding the invalid
mac_header pointer, that looks like a bug and it should
probably call skb_reset_mac_header() instead of manually
changing the potentially invalid ->mac_header.

> Index: linux-2.6.26-rc5/include/linux/if_vlan.h
> ===================================================================
> --- linux-2.6.26-rc5.orig/include/linux/if_vlan.h
> +++ linux-2.6.26-rc5/include/linux/if_vlan.h
> @@ -280,7 +280,6 @@ static inline struct sk_buff *__vlan_put
>  
>  	skb->protocol = htons(ETH_P_8021Q);
>  	skb->mac_header -= VLAN_HLEN;
> -	skb->network_header -= VLAN_HLEN;
>  
>  	return skb;
>  }

There is another spot where VLAN headers are built with an also
incorrect looking network_header adjustment in vlan_dev_hard_header()
that should also be changed for consisteny.

Could you try if changing both these spots and adding the
skb_reset_mac_header() works for you and still displays
the packets properly in tcpdump?
