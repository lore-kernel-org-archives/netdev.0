From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: net: rps: support 802.1Q
Date: Fri, 19 Aug 2011 12:54:13 +0100
Message-ID: <1313754853.2814.8.camel@deadeye>
References: <1313730353-25379-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:1683 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096Ab1HSLyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 07:54:17 -0400
In-Reply-To: <1313730353-25379-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-08-19 at 13:05 +0800, Changli Gao wrote:
> For the 802.1Q packets, if the NIC doesn't support hw-accel-vlan-rx, RPS
> won't inspect the internal 4 tuples to generate skb->rxhash, so this kind
> of traffic can't get any benefit from RPS.
> 
> This patch adds the support for 802.1Q to RPS.
[...]
> @@ -2565,6 +2566,13 @@ again:
>  		addr2 = (__force u32) ip6->daddr.s6_addr32[3];
>  		nhoff += 40;
>  		break;
> +	case __constant_htons(ETH_P_8021Q):
> +		if (!pskb_may_pull(skb, sizeof(*vlan) + nhoff))
> +			goto done;
> +		vlan = (const struct vlan_hdr *) (skb->data + nhoff);
> +		proto = vlan->h_vlan_encapsulated_proto;
> +		nhoff += sizeof(*vlan);
> +		goto again;
>  	default:
>  		goto done;
>  	}

Should this really be reading an unlimited number of tags?  What if an
attacker starts sending packets full of VLAN tags?  Since this runs
before netfilter, there would be no way to prevent those packets burning
our CPU time.  And if there are legitimately multiple VLAN tags, they
presumably won't all have the 802.1q Ethertype.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

