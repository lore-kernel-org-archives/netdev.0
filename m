From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH net-next] net/mlx4_en: don't set CHECKSUM_COMPLETE on SCTP
 packets
Date: Sun, 18 Jun 2017 14:10:03 +0300
Message-ID: <bc64924a-a9cd-737e-b63d-27011445d230@mellanox.com>
References: <eed45546c689875c5e57a7716fc1f06089f6b7d3.1497621301.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tariq Toukan <tariqt@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>
To: Davide Caratti <dcaratti@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0046.outbound.protection.outlook.com ([104.47.0.46]:64064
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751895AbdFRLKL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Jun 2017 07:10:11 -0400
In-Reply-To: <eed45546c689875c5e57a7716fc1f06089f6b7d3.1497621301.git.dcaratti@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 16/06/2017 5:01 PM, Davide Caratti wrote:
> if the NIC fails to validate the checksum on TCP/UDP, and validation of IP
> checksum is successful, the driver subtracts the pseudo-header checksum
> from the value obtained by the hardware and sets CHECKSUM_COMPLETE. Don't
> do that if protocol is IPPROTO_SCTP, otherwise CRC32c validation fails.
> 
> Reported-by: Shuang Li <shuali@redhat.com>
> Fixes: f8c6455bb04b ("net/mlx4_en: Extend checksum offloading by CHECKSUM COMPLETE")
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_rx.c | 33 +++++++++++++++++++-----------
>   1 file changed, 21 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 77abd18..d9293e4 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -572,16 +572,21 @@ static inline __wsum get_fixed_vlan_csum(__wsum hw_checksum,
>    * header, the HW adds it. To address that, we are subtracting the pseudo
>    * header checksum from the checksum value provided by the HW.
>    */
> -static void get_fixed_ipv4_csum(__wsum hw_checksum, struct sk_buff *skb,
> -				struct iphdr *iph)
> +static int get_fixed_ipv4_csum(__wsum hw_checksum, struct sk_buff *skb,
> +			       struct iphdr *iph)
>   {
>   	__u16 length_for_csum = 0;
>   	__wsum csum_pseudo_header = 0;
> +	__u8 ipproto = iph->protocol;
> +
> +	if (ipproto == IPPROTO_SCTP)

This is unlikely().

> +		return -1;
>   
>   	length_for_csum = (be16_to_cpu(iph->tot_len) - (iph->ihl << 2));
>   	csum_pseudo_header = csum_tcpudp_nofold(iph->saddr, iph->daddr,
> -						length_for_csum, iph->protocol, 0);
> +						length_for_csum, ipproto, 0);
>   	skb->csum = csum_sub(hw_checksum, csum_pseudo_header);
> +	return 0;
>   }
>   
>   #if IS_ENABLED(CONFIG_IPV6)
> @@ -592,17 +597,20 @@ static void get_fixed_ipv4_csum(__wsum hw_checksum, struct sk_buff *skb,
>   static int get_fixed_ipv6_csum(__wsum hw_checksum, struct sk_buff *skb,
>   			       struct ipv6hdr *ipv6h)
>   {
> +	__u8 nexthdr = ipv6h->nexthdr;
>   	__wsum csum_pseudo_hdr = 0;
>   
> -	if (unlikely(ipv6h->nexthdr == IPPROTO_FRAGMENT ||
> -		     ipv6h->nexthdr == IPPROTO_HOPOPTS))
> +	if (unlikely(nexthdr == IPPROTO_FRAGMENT ||
> +		     nexthdr == IPPROTO_HOPOPTS ||
> +		     nexthdr == IPPROTO_SCTP))
>   		return -1;
> -	hw_checksum = csum_add(hw_checksum, (__force __wsum)htons(ipv6h->nexthdr));
> +	hw_checksum = csum_add(hw_checksum, (__force __wsum)htons(nexthdr));
>   
>   	csum_pseudo_hdr = csum_partial(&ipv6h->saddr,
>   				       sizeof(ipv6h->saddr) + sizeof(ipv6h->daddr), 0);
>   	csum_pseudo_hdr = csum_add(csum_pseudo_hdr, (__force __wsum)ipv6h->payload_len);
> -	csum_pseudo_hdr = csum_add(csum_pseudo_hdr, (__force __wsum)ntohs(ipv6h->nexthdr));
> +	csum_pseudo_hdr = csum_add(csum_pseudo_hdr,
> +				   (__force __wsum)htons(nexthdr));
>   
>   	skb->csum = csum_sub(hw_checksum, csum_pseudo_hdr);
>   	skb->csum = csum_add(skb->csum, csum_partial(ipv6h, sizeof(struct ipv6hdr), 0));
> @@ -624,12 +632,13 @@ static int check_csum(struct mlx4_cqe *cqe, struct sk_buff *skb, void *va,
>   		hdr += sizeof(struct vlan_hdr);
>   	}
>   
> -	if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV4))
> -		get_fixed_ipv4_csum(hw_checksum, skb, hdr);
> +	if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV4)) &&
> +	    (unlikely(get_fixed_ipv4_csum(hw_checksum, skb, hdr))))
No! The lazy evaluation trick is wrong here.
This way you'll end up going almost always to the else (ipv6) for the 
wrong reason.

> +		return -1;
>   #if IS_ENABLED(CONFIG_IPV6)
> -	else if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV6))
> -		if (unlikely(get_fixed_ipv6_csum(hw_checksum, skb, hdr)))
> -			return -1;
> +	else if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPV6)) &&
> +		 (unlikely(get_fixed_ipv6_csum(hw_checksum, skb, hdr))))
> +		return -1;
Let's not change this, might cause future bugs, similarly to the one above.
>   #endif
>   	return 0;
>   }
> 

Regards,
Tariq
