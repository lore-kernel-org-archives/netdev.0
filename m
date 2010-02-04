From: Jasper Spaans <spaans@fox-it.com>
Subject: Re: [RFC] bonding: better transmit hash
Date: Thu, 4 Feb 2010 09:26:16 +0000
Message-ID: <4B6A92B8.8070806@fox-it.com>
References: <20100203111337.1085b772@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.fox-it.com ([82.94.91.210]:37621 "EHLO mail2.fox-it.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754136Ab0BDJre convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 04:47:34 -0500
In-Reply-To: <20100203111337.1085b772@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/10 19:13, Stephen Hemminger wrote:
> This is a prototype of improved bonding link hashing. It adds a couple
> of things:
>    * support IPV6 addresses for L3/L4
>    * support other protocols beside TCP/UDP
>    * use all of mac address (not just last byte)
>    * use jhash for better mixing
>    * use skb header field access to handle vlan's etc properly
>
> It no longer is a pure xor, does that matter?
>   
The goal is to distribute packets when load is high - so a bit of
efficiency would be nice. Looking at jhash, it seems to use ~60
operations per round of hashing instead of just 1 xor.
Besides, it seems jhash (the generic function) hashes your data in
chunks of 12 bytes, and finishes of with another round hashing. You
might want to use the specialized jhash_3words function in those cases,
which only does one round.
> --- a/drivers/net/bonding/bond_main.c	2010-02-03 10:42:50.998328499 -0800
> +++ b/drivers/net/bonding/bond_main.c	2010-02-03 11:08:35.034851960 -0800
> @@ -3587,17 +3587,28 @@ void bond_unregister_arp(struct bonding 
>   * Hash for the output device based upon layer 2 and layer 3 data. If
>   * the packet is not IP mimic bond_xmit_hash_policy_l2()
>   */
> -static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
> +static int bond_xmit_hash_policy_l23(const struct sk_buff *skb, int count)
>  {
> -	struct ethhdr *data = (struct ethhdr *)skb->data;
> -	struct iphdr *iph = ip_hdr(skb);
> +	u32 h;
>  
> -	if (skb->protocol == htons(ETH_P_IP)) {
> -		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
> -			(data->h_dest[5] ^ data->h_source[5])) % count;
> +	switch (skb->protocol) {
> +	case htons(ETH_P_IP):
> +	{
> +		const struct iphdr *iph = ip_hdr(skb);
> +		h = iph->daddr ^ iph->saddr ^ iph->protocol;
> +		break;
> +	}
> +	case htons(ETH_P_IPV6):
> +	{
> +		const struct ipv6hdr *iph = ipv6_hdr(skb);
> +		h = iph->saddr.s6_addr32[3] ^ iph->daddr.s6_addr32[3];
> +		break;
> +	}
> +	default:
> +		h = skb->protocol;
>  	}
>  
> -	return (data->h_dest[5] ^ data->h_source[5]) % count;
> +	return jhash(eth_hdr(skb), 2*ETH_ALEN, h) % count;
>  }
>   
This breaks stuff - in the layer 3 case, you're suddenly putting layer 2
data into the hash, and in the layer 2 case, you're putting the protocol
into the hash. Especially the first case has the potential to break our
setup, in which related traffic might end up at different interfaces.

>  /*
> @@ -3605,35 +3616,55 @@ static int bond_xmit_hash_policy_l23(str
>   * the packet is a frag or not TCP or UDP, just use layer 3 data.  If it is
>   * altogether not IP, mimic bond_xmit_hash_policy_l2()
>   */
> -static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
> +static int bond_xmit_hash_policy_l34(const struct sk_buff *skb, int count)
>  {
> -	struct ethhdr *data = (struct ethhdr *)skb->data;
> -	struct iphdr *iph = ip_hdr(skb);
> -	__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
> -	int layer4_xor = 0;
> +	u32 h;
> +
> +	switch (skb->protocol) {
> +	case htons(ETH_P_IP):
> +	{
> +		const struct iphdr *iph = ip_hdr(skb);
> +		h = iph->saddr ^ iph->daddr;
>  
> -	if (skb->protocol == htons(ETH_P_IP)) {
> -		if (!(iph->frag_off & htons(IP_MF|IP_OFFSET)) &&
> +		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
>  		    (iph->protocol == IPPROTO_TCP ||
> -		     iph->protocol == IPPROTO_UDP)) {
> -			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
> -		}
> -		return (layer4_xor ^
> -			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
> +		     iph->protocol == IPPROTO_UDP ||
> +		     iph->protocol == IPPROTO_UDPLITE ||
> +		     iph->protocol == IPPROTO_SCTP ||
> +		     iph->protocol == IPPROTO_DCCP ||
> +		     iph->protocol == IPPROTO_ESP))
> +			h ^= *(((u32*)iph) + iph->ihl);
>  
> +		break;
> +	}
> +	case htons(ETH_P_IPV6):
> +	{
> +		const struct ipv6hdr *iph = ipv6_hdr(skb);
> +		h = iph->daddr.s6_addr32[3] ^
> +		        iph->saddr.s6_addr32[3] ^ iph->nexthdr;
> +		if (iph->nexthdr == IPPROTO_TCP ||
> +		    iph->nexthdr == IPPROTO_UDP ||
> +		    iph->nexthdr == IPPROTO_UDPLITE ||
> +		    iph->nexthdr == IPPROTO_SCTP ||
> +		    iph->nexthdr == IPPROTO_DCCP ||
> +		    iph->nexthdr == IPPROTO_ESP)
> +			h ^= *(u32*)&iph[1];
> +		break;
> +	}
> +	default:
> +		h = ntohs(skb->protocol);
>  	}
>  
> -	return (data->h_dest[5] ^ data->h_source[5]) % count;
> +	return jhash(eth_hdr(skb), 2*ETH_ALEN, h) % count;
>  }
>   
I like the support for ipv6 and more protocols - but again, why the
skb->protocol as initializer? Also, why mix in iph->nexthdr into h in
the ipv6 case?

>  
>  /*
>   * Hash for the output device based upon layer 2 data
>   */
> -static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
> +static int bond_xmit_hash_policy_l2(const struct sk_buff *skb, int count)
>  {
> -	struct ethhdr *data = (struct ethhdr *)skb->data;
> -
> -	return (data->h_dest[5] ^ data->h_source[5]) % count;
> +	return jhash(eth_hdr(skb), 2*ETH_ALEN,
> +		     ntohs(skb->protocol)) % count;
>  } 
>   
This one also needlessly incorporates the protocol into the hash.

On a meta-level, do you have any measurements showing biased output for
real traffic? My experience is that the normal xor code just works fine,
except for one specific setup in which the traffic itself is rather
biased (tons of ipsec between just two hosts + less normal traffic
between the rest of the network). In that case, it will also be
difficult to distribute this load even using the above changes.

Jasper

-- 
Ir. Jasper Spaans
Fox-IT Experts in IT Security!
T: +31 (0) 15 284 79 99
KvK Haaglanden 27301624


