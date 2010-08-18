From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 8/8] net_sched: sch_sfq: use proto_ports_offset() to
 support AH message
Date: Wed, 18 Aug 2010 07:05:31 -0400
Message-ID: <1282129531.23601.20.camel@bigi>
References: <1282108055-3702-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:53173 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738Ab0HRLFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 07:05:36 -0400
Received: by qwh6 with SMTP id 6so364405qwh.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 04:05:35 -0700 (PDT)
In-Reply-To: <1282108055-3702-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-08-18 at 13:07 +0800, Changli Gao wrote:

>  		const struct iphdr *iph;
> +		int poff;
>  
>  		if (!pskb_network_may_pull(skb, sizeof(*iph)))
>  			goto err;
>  		iph = ip_hdr(skb);
>  		h = (__force u32)iph->daddr;
>  		h2 = (__force u32)iph->saddr ^ iph->protocol;
> -		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
> -		    (iph->protocol == IPPROTO_TCP ||
> -		     iph->protocol == IPPROTO_UDP ||
> -		     iph->protocol == IPPROTO_UDPLITE ||
> -		     iph->protocol == IPPROTO_SCTP ||
> -		     iph->protocol == IPPROTO_DCCP ||
> -		     iph->protocol == IPPROTO_ESP) &&
> -		     pskb_network_may_pull(skb, iph->ihl * 4 + 4))
> -			h2 ^= *(((u32*)iph) + iph->ihl);
> +		if (iph->frag_off & htons(IP_MF|IP_OFFSET))
> +			break;
> +		poff = proto_ports_offset(iph->protocol);
> +		if (poff >= 0 &&
> +		    pskb_network_may_pull(skb, iph->ihl * 4 + 4 + poff)) {
> +			iph = ip_hdr(skb);
> +			h2 ^= *(u32*)((void *)iph + iph->ihl * 4 + poff);
> +		}
>  		break;

Same comment with this one as earlier patch? Or it may be too early
here ;->

cheers,
jamal

>  	case htons(ETH_P_IPV6):
>  	{
>  		struct ipv6hdr *iph;
> +		int poff;
>  
>  		if (!pskb_network_may_pull(skb, sizeof(*iph)))
>  			goto err;
>  		iph = ipv6_hdr(skb);
>  		h = (__force u32)iph->daddr.s6_addr32[3];
>  		h2 = (__force u32)iph->saddr.s6_addr32[3] ^ iph->nexthdr;
> -		if ((iph->nexthdr == IPPROTO_TCP ||
> -		     iph->nexthdr == IPPROTO_UDP ||
> -		     iph->nexthdr == IPPROTO_UDPLITE ||
> -		     iph->nexthdr == IPPROTO_SCTP ||
> -		     iph->nexthdr == IPPROTO_DCCP ||
> -		     iph->nexthdr == IPPROTO_ESP) &&
> -		    pskb_network_may_pull(skb, sizeof(*iph) + 4))
> -			h2 ^= *(u32*)&iph[1];
> +		poff = proto_ports_offset(iph->nexthdr);
> +		if (poff >= 0 &&
> +		    pskb_network_may_pull(skb, sizeof(*iph) + 4 + poff)) {
> +			iph = ipv6_hdr(skb);
> +			h2 ^= *(u32*)((void *)iph + sizeof(*iph) + poff);
> +		}
>  		break;
>  	}
>  	default:

