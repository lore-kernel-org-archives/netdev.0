From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH net-next v3 1/1] net: fec: Enable imx6 enet checksum acceleration.
Date: Thu, 18 Apr 2013 13:49:23 +0100
Message-ID: <516FEBD3.8000803@mentor.com>
References: <Jim Baxter <jim_baxter@mentor.com>  <1366229278-7528-1-git-send-email-jim_baxter@mentor.com> <1366234670.3205.38.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, <netdev@vger.kernel.org>,
	Fabio Estevam <festevam@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:48534 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592Ab3DRMt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 08:49:29 -0400
In-Reply-To: <1366234670.3205.38.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/04/13 22:37, Eric Dumazet wrote:
> On Wed, 2013-04-17 at 21:07 +0100, Jim Baxter wrote:
>> Enables hardware generation of IP header and
>> protocol specific checksums for transmitted
>> packets.
>>
>> Enabled hardware discarding of received packets with
>> invalid IP header or protocol specific checksums.
>>
>> The feature is enabled by default but can be
>> enabled/disabled by ethtool.
>>
>> Signed-off-by: Fugang Duan <B38611@freescale.com>
>> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
>> ---
>>  
>> +static void
>> +fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
>> +{
>> +	int hdr_len = 0;
>> +
>> +	/* Only run for packets requiring a checksum. */
>> +	if (skb->ip_summed != CHECKSUM_PARTIAL)
>> +		return;
>> +	if (skb->len < (ETH_HLEN + sizeof(struct iphdr)))
>> +		return;
>> +
> 
> You could do the skb_cow_head() here.

I do not know the full length of the header at this point, so I think
that would be tricky.

> 
>> +	if (skb->protocol == htons(ETH_P_IP)) {
>> +		ip_hdr(skb)->check = 0;
>> +
>> +		switch (ip_hdr(skb)->protocol) {
>> +		case IPPROTO_UDP:
>> +			hdr_len = (ETH_HLEN +
>> +					(ip_hdr(skb)->ihl << 2) +
>> +					sizeof(struct udphdr));
>> +			if (skb->len < hdr_len)
>> +				return;
>> +			skb_cow_head(skb, hdr_len);
> 
> You should not ignore the return value...
I agree.
> 
>> +			skb_set_transport_header(skb,
>> +					ETH_HLEN + ip_hdrlen(skb));
>> +			udp_hdr(skb)->check = 0;
>> +			break;
>> +		case IPPROTO_TCP:
>> +			hdr_len = (ETH_HLEN +
>> +					(ip_hdr(skb)->ihl << 2) +
>> +					sizeof(struct tcphdr));
>> +			if (skb->len < hdr_len)
>> +				return;
>> +			skb_cow_head(skb, hdr_len);
> 
> same here
Do I need to call skb_cow_head here, I am not changing the size of the
header?
> 
>> +			if (tcp_hdr(skb))
>> +				tcp_hdr(skb)->check = 0;
>> +			break;
>> +		case IPPROTO_ICMP:
>> +			hdr_len = (ETH_HLEN +
>> +					(ip_hdr(skb)->ihl << 2) +
>> +					sizeof(struct icmphdr));
>> +			if (skb->len < hdr_len)
>> +				return;
>> +			skb_cow_head(skb, hdr_len);
> 
> same here
Again, do I need this here?
> 
>> +			if (icmp_hdr(skb))
>> +				icmp_hdr(skb)->checksum = 0;
>> +			break;
>> +		default:
>> +			break;
>> +		}
>> +	}
>> +}
>> +
> 
> 
> 
