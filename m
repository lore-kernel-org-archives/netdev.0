From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH,RFC] skb->network_header and __vlan_put_tag()
Date: Mon, 7 Jul 2008 14:05:41 +0200
Message-ID: <20080707120541.GB2026@xi.wantstofly.org>
References: <20080616221525.GG27971@xi.wantstofly.org> <4857AB84.2090409@trash.net> <486FBE5D.1020807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:36087 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753836AbYGGMFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 08:05:50 -0400
Content-Disposition: inline
In-Reply-To: <486FBE5D.1020807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 05, 2008 at 08:33:01PM +0200, Patrick McHardy wrote:

> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index 037929f..d0157d4 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -188,8 +188,7 @@ static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, unsigned short
>  	veth->h_vlan_TCI = htons(tag);
>  
>  	skb->protocol = htons(ETH_P_8021Q);
> -	skb->mac_header -= VLAN_HLEN;
> -	skb->network_header -= VLAN_HLEN;

This works -- I can now just calculate
'(void *)skb->data - (void *)ip_hdr(skb)' to find out how many bytes
there are in the virtual ethernet header (i.e. ethernet header plus
VLAN tag(s)) and program the TX descriptor accordingly.  (But in the
VLAN case, I only ever get packets that have already been checksummed
-- but that's another issue.)


> +	skb_reset_mac_header(skb);

I'm not sure whether there is much point to doing this.  With this
change, VLAN-tagged packets are given to ->hard_start_xmit() with
ethhdr pointing to skb->data instead of NULL, but non-VLAN-tagged
packets are still passed in with ethhdr being NULL.

I.e. this hacky code in ->hard_start_xmit():

	if (1) {
		void *ip = ip_hdr(skb);
		void *data = skb->data;

		printk(KERN_INFO "tx %p ", skb);
		printk("proto:%.4x ", ntohs(skb->protocol));
		printk("data:%p ", skb->data);
		printk("ethhdr:%p ", eth_hdr(skb));
		printk("iphdr:%p ", ip);
		printk("macbytes:%d\n", ip - data);
	}

Gives me for VLAN-tagged packets:

	tx c1d63520 proto:8100 data:c1d6240e ethhdr:c1d6240e iphdr:c1d62420 macbytes:18

and for non-VLAN-tagged packets:

	tx c1f90ee0 proto:0800 data:c0b1e8b6 ethhdr:00000000 iphdr:c0b1e8c4 macbytes:14
