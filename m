From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 1/1] net: fec: Enable imx6 enet checksum
 acceleration.
Date: Wed, 17 Apr 2013 14:37:50 -0700
Message-ID: <1366234670.3205.38.camel@edumazet-glaptop>
References: <Jim Baxter <jim_baxter@mentor.com>
	 <1366229278-7528-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:62179 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965687Ab3DQVhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 17:37:54 -0400
Received: by mail-pd0-f175.google.com with SMTP id g10so1067527pdj.34
        for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 14:37:54 -0700 (PDT)
In-Reply-To: <1366229278-7528-1-git-send-email-jim_baxter@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-17 at 21:07 +0100, Jim Baxter wrote:
> Enables hardware generation of IP header and
> protocol specific checksums for transmitted
> packets.
> 
> Enabled hardware discarding of received packets with
> invalid IP header or protocol specific checksums.
> 
> The feature is enabled by default but can be
> enabled/disabled by ethtool.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
> ---
>  
> +static void
> +fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	int hdr_len = 0;
> +
> +	/* Only run for packets requiring a checksum. */
> +	if (skb->ip_summed != CHECKSUM_PARTIAL)
> +		return;
> +	if (skb->len < (ETH_HLEN + sizeof(struct iphdr)))
> +		return;
> +

You could do the skb_cow_head() here.

> +	if (skb->protocol == htons(ETH_P_IP)) {
> +		ip_hdr(skb)->check = 0;
> +
> +		switch (ip_hdr(skb)->protocol) {
> +		case IPPROTO_UDP:
> +			hdr_len = (ETH_HLEN +
> +					(ip_hdr(skb)->ihl << 2) +
> +					sizeof(struct udphdr));
> +			if (skb->len < hdr_len)
> +				return;
> +			skb_cow_head(skb, hdr_len);

You should not ignore the return value...

> +			skb_set_transport_header(skb,
> +					ETH_HLEN + ip_hdrlen(skb));
> +			udp_hdr(skb)->check = 0;
> +			break;
> +		case IPPROTO_TCP:
> +			hdr_len = (ETH_HLEN +
> +					(ip_hdr(skb)->ihl << 2) +
> +					sizeof(struct tcphdr));
> +			if (skb->len < hdr_len)
> +				return;
> +			skb_cow_head(skb, hdr_len);

same here

> +			if (tcp_hdr(skb))
> +				tcp_hdr(skb)->check = 0;
> +			break;
> +		case IPPROTO_ICMP:
> +			hdr_len = (ETH_HLEN +
> +					(ip_hdr(skb)->ihl << 2) +
> +					sizeof(struct icmphdr));
> +			if (skb->len < hdr_len)
> +				return;
> +			skb_cow_head(skb, hdr_len);

same here

> +			if (icmp_hdr(skb))
> +				icmp_hdr(skb)->checksum = 0;
> +			break;
> +		default:
> +			break;
> +		}
> +	}
> +}
> +
