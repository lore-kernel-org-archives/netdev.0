From: David Arcari <darcari@redhat.com>
Subject: Re: [PATCH v3 net 2/5] net:ethernet:aquantia: Fix packet type
 detection (TCP/UDP) for IPv6.
Date: Thu, 23 Mar 2017 08:13:06 -0400
Message-ID: <8cd2beb7-b97d-2de3-3f6c-9bc595efb272@redhat.com>
References: <cover.1490267633.git.pavel.belous@aquantia.com>
 <e291c95696469004331760a23230dd7793791a10.1490267633.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46168 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933030AbdCWMNM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 08:13:12 -0400
In-Reply-To: <e291c95696469004331760a23230dd7793791a10.1490267633.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/23/2017 07:19 AM, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> In order for the checksum offloads to work correctly we need to set the
> packet type bit (TCP/UDP) in the TX context buffer.
> 
> Fixes: 97bde5c4f909 ("net: ethernet: aquantia: Support for NIC-specific code")
> 
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 20 ++++++++++++++++----
>  1 file changed, 16 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> index ee78444..db2b51d 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> @@ -510,10 +510,22 @@ static unsigned int aq_nic_map_skb(struct aq_nic_s *self,
>  	if (skb->ip_summed == CHECKSUM_PARTIAL) {
>  		dx_buff->is_ip_cso = (htons(ETH_P_IP) == skb->protocol) ?
>  			1U : 0U;
> -		dx_buff->is_tcp_cso =
> -			(ip_hdr(skb)->protocol == IPPROTO_TCP) ? 1U : 0U;
> -		dx_buff->is_udp_cso =
> -			(ip_hdr(skb)->protocol == IPPROTO_UDP) ? 1U : 0U;
> +
> +		if (ip_hdr(skb)->version == 4) {
> +			dx_buff->is_tcp_cso =
> +				(ip_hdr(skb)->protocol == IPPROTO_TCP) ?
> +					1U : 0U;
> +			dx_buff->is_udp_cso =
> +				(ip_hdr(skb)->protocol == IPPROTO_UDP) ?
> +					1U : 0U;
> +		} else if (ip_hdr(skb)->version == 6) {
> +			dx_buff->is_tcp_cso =
> +				(ipv6_hdr(skb)->nexthdr == NEXTHDR_TCP) ?
> +					1U : 0U;
> +			dx_buff->is_udp_cso =
> +				(ipv6_hdr(skb)->nexthdr == NEXTHDR_UDP) ?
> +					1U : 0U;
> +		}
>  	}
>  
>  	for (; nr_frags--; ++frag_count) {
> 

Fixes tcp/ipv6

Tested-by: David Arcari <darcari@redhat.com>
