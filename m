From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH 2/3] net: UDP gro_receive accept csum=0
Date: Thu, 13 Feb 2014 10:06:36 +0200
Message-ID: <52FC7D0C.1020601@mellanox.com>
References: <alpine.DEB.2.02.1402110928070.7090@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jerry Chu <hkchu@google.com>, Eric Dumazet <edumazet@google.com>
To: Tom Herbert <therbert@google.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:36608 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751417AbaBMIGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 03:06:45 -0500
In-Reply-To: <alpine.DEB.2.02.1402110928070.7090@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/02/2014 19:43, Tom Herbert wrote:
> The code to validate checksum in UDP gro_receive explictly checks
> against driver having set CHECKSUM_COMPLETE. This does not perform
> GRO on UDP packets with a checksum of zero (no checksum needed).
> This patch adds the condition to allow UDP checksum to be zero.
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>   net/ipv4/udp_offload.c | 13 ++++++++-----
>   1 file changed, 8 insertions(+), 5 deletions(-)
>
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 25f5cee..4db7796 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -156,13 +156,9 @@ static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *s
>   	unsigned int hlen, off;
>   	int flush = 1;
>   
> -	if (NAPI_GRO_CB(skb)->udp_mark ||
> -	    (!skb->encapsulation && skb->ip_summed != CHECKSUM_COMPLETE))
> +	if (NAPI_GRO_CB(skb)->udp_mark)
>   		goto out;
>   
> -	/* mark that this skb passed once through the udp gro layer */
> -	NAPI_GRO_CB(skb)->udp_mark = 1;
> -
>   	off  = skb_gro_offset(skb);
>   	hlen = off + sizeof(*uh);
>   	uh   = skb_gro_header_fast(skb, off);
> @@ -172,6 +168,13 @@ static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *s
>   			goto out;
>   	}
>   
> +	if (!skb->encapsulation &&
> +	    skb->ip_summed != CHECKSUM_COMPLETE && uh->check != 0)
> +		goto out;
> +
> +	/* mark that this skb passed once through the udp gro layer */
> +	NAPI_GRO_CB(skb)->udp_mark = 1;
> +

Hi Tom,

Considering the patch just "as is" vs. the current code, its OK.

However, as skbs have only one indicator for the status of the checksum 
checks done by the receiving hardware, the basic assertion I thought we 
needed here is to reject skb if either it has the udp mark set or the 
encapsulation field is false, this is according to the conventions set 
by these two commits

0afb166 vxlan: Add capability of Rx checksum offload for inner packet
6a674e9 net: Add support for hardware-offloaded encapsulation

B/c after finalizing the GRO work and decapsulating, skb injected up 
into the TCP stack with ip_summed equals to CHECKSUM_NONE are rejected. 
If this assumption is wrong, maybe we can remove testing the ip_summed 
field here altogether?

Or.
