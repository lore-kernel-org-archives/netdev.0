From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v3 3/8] netfilter: Allow calling into nat helper
 without skb_dst.g
Date: Tue, 1 Dec 2015 21:51:19 +0100
Message-ID: <20151201205119.GA2563@salvia>
References: <1448496501-109561-1-git-send-email-jarno@ovn.org>
 <1448496501-109561-4-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	dev@openvswitch.org
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1448496501-109561-4-git-send-email-jarno@ovn.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 25, 2015 at 04:08:16PM -0800, Jarno Rajahalme wrote:
> NAT checksum recalculation code assumes existence of skb_dst, which
> becomes a problem for a later patch in the series ("openvswitch:
> Interface with NAT.").  Simplify this by removing the check on
> skb_dst, as the checksum will be dealt with later in the stack.
> 
> Suggested-by: Pravin Shelar <pshelar@nicira.com>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
>  net/ipv4/netfilter/nf_nat_l3proto_ipv4.c | 29 ++++++++---------------------
>  net/ipv6/netfilter/nf_nat_l3proto_ipv6.c | 29 ++++++++---------------------
>  2 files changed, 16 insertions(+), 42 deletions(-)
> 
> diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
> index 5075b7e..f8aad03 100644
> --- a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
> +++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
> @@ -127,28 +127,15 @@ static void nf_nat_ipv4_csum_recalc(struct sk_buff *skb,
>  				    u8 proto, void *data, __sum16 *check,
>  				    int datalen, int oldlen)
>  {
> -	const struct iphdr *iph = ip_hdr(skb);
> -	struct rtable *rt = skb_rtable(skb);
> -
>  	if (skb->ip_summed != CHECKSUM_PARTIAL) {
> -		if (!(rt->rt_flags & RTCF_LOCAL) &&
> -		    (!skb->dev || skb->dev->features & NETIF_F_V4_CSUM)) {
> -			skb->ip_summed = CHECKSUM_PARTIAL;
> -			skb->csum_start = skb_headroom(skb) +
> -					  skb_network_offset(skb) +
> -					  ip_hdrlen(skb);
> -			skb->csum_offset = (void *)check - data;
> -			*check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
> -						    datalen, proto, 0);
> -		} else {
> -			*check = 0;
> -			*check = csum_tcpudp_magic(iph->saddr, iph->daddr,
> -						   datalen, proto,
> -						   csum_partial(data, datalen,
> -								0));
> -			if (proto == IPPROTO_UDP && !*check)
> -				*check = CSUM_MANGLED_0;
> -		}
> +		const struct iphdr *iph = ip_hdr(skb);
> +
> +		skb->ip_summed = CHECKSUM_PARTIAL;
> +		skb->csum_start = skb_headroom(skb) + skb_network_offset(skb) +
> +			ip_hdrlen(skb);
> +		skb->csum_offset = (void *)check - data;
> +		*check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, datalen,
> +					    proto, 0);

Is this change going to work with traffic that is redirected to the
localhost?
