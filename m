From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 1/7] ebtables: Allow filtering of hardware
 accelerated vlan frames.
Date: Mon, 18 Oct 2010 20:58:12 +0100
Message-ID: <1287431892.2252.575.camel@achroite.uk.solarflarecom.com>
References: <1287000177-7126-1-git-send-email-jesse@nicira.com>
	 <1287000177-7126-2-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:46130 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755806Ab0JRT6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 15:58:15 -0400
In-Reply-To: <1287000177-7126-2-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-10-13 at 13:02 -0700, Jesse Gross wrote:
> An upcoming commit will allow packets with hardware vlan acceleration
> information to be passed though more parts of the network stack, including
> packets trunked through the bridge.  This adds support for matching and
> filtering those packets through ebtables.
> 
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> ---
>  net/bridge/br_netfilter.c       |   16 +++++++++-------
>  net/bridge/netfilter/ebt_vlan.c |   38 +++++++++++++++++++++++---------------
>  net/bridge/netfilter/ebtables.c |   15 +++++++++++----
>  3 files changed, 43 insertions(+), 26 deletions(-)
> 
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index 7f9ce96..d6a4fec 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -64,22 +64,24 @@ static int brnf_filter_pppoe_tagged __read_mostly = 0;
>  
>  static inline __be16 vlan_proto(const struct sk_buff *skb)
>  {
> -	return vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
> +	if (skb->protocol == htons(ETH_P_8021Q))
> +		return vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
> +	else if (vlan_tx_tag_present(skb))
> +		return skb->protocol;

If there are two levels of VLAN-encapsulation, this will return either
the inner or outer tag depending on whether VLAN acceleration is being
used.  It should behave consistently.

> +	else
> +		return 0;
>  }
>  
>  #define IS_VLAN_IP(skb) \
> -	(skb->protocol == htons(ETH_P_8021Q) && \
> -	 vlan_proto(skb) == htons(ETH_P_IP) && 	\
> +	(vlan_proto(skb) == htons(ETH_P_IP) && 	\
>  	 brnf_filter_vlan_tagged)
>  
>  #define IS_VLAN_IPV6(skb) \
> -	(skb->protocol == htons(ETH_P_8021Q) && \
> -	 vlan_proto(skb) == htons(ETH_P_IPV6) &&\
> +	(vlan_proto(skb) == htons(ETH_P_IPV6) &&\
>  	 brnf_filter_vlan_tagged)
>  
>  #define IS_VLAN_ARP(skb) \
> -	(skb->protocol == htons(ETH_P_8021Q) &&	\
> -	 vlan_proto(skb) == htons(ETH_P_ARP) &&	\
> +	(vlan_proto(skb) == htons(ETH_P_ARP) &&	\
>  	 brnf_filter_vlan_tagged)
>  
>  static inline __be16 pppoe_proto(const struct sk_buff *skb)
> diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
> index 87b53b3..a39d92d 100644
> --- a/net/bridge/netfilter/ebt_vlan.c
> +++ b/net/bridge/netfilter/ebt_vlan.c
> @@ -39,8 +39,6 @@ static bool
>  ebt_vlan_mt(const struct sk_buff *skb, struct xt_action_param *par)
>  {
>  	const struct ebt_vlan_info *info = par->matchinfo;
> -	const struct vlan_hdr *fp;
> -	struct vlan_hdr _frame;
>  
>  	unsigned short TCI;	/* Whole TCI, given from parsed frame */
>  	unsigned short id;	/* VLAN ID, given from frame TCI */
> @@ -48,21 +46,31 @@ ebt_vlan_mt(const struct sk_buff *skb, struct xt_action_param *par)
>  	/* VLAN encapsulated Type/Length field, given from orig frame */
>  	__be16 encap;
>  
> -	fp = skb_header_pointer(skb, 0, sizeof(_frame), &_frame);
> -	if (fp == NULL)
> -		return false;
> -
> -	/* Tag Control Information (TCI) consists of the following elements:
> -	 * - User_priority. The user_priority field is three bits in length,
> -	 * interpreted as a binary number.
> -	 * - Canonical Format Indicator (CFI). The Canonical Format Indicator
> -	 * (CFI) is a single bit flag value. Currently ignored.
> -	 * - VLAN Identifier (VID). The VID is encoded as
> -	 * an unsigned binary number. */
> -	TCI = ntohs(fp->h_vlan_TCI);
> +	if (skb->protocol == htons(ETH_P_8021Q)) {
> +		const struct vlan_hdr *fp;
> +		struct vlan_hdr _frame;
> +
> +		fp = skb_header_pointer(skb, 0, sizeof(_frame), &_frame);
> +		if (fp == NULL)
> +			return false;
> +
> +		/* Tag Control Information (TCI) consists of the following elements:
> +		 * - User_priority. The user_priority field is three bits in length,
> +		 * interpreted as a binary number.
> +		 * - Canonical Format Indicator (CFI). The Canonical Format Indicator
> +		 * (CFI) is a single bit flag value. Currently ignored.
> +		 * - VLAN Identifier (VID). The VID is encoded as
> +		 * an unsigned binary number. */
> +		TCI = ntohs(fp->h_vlan_TCI);
> +
> +		encap = fp->h_vlan_encapsulated_proto;
> +	} else {
> +		TCI = vlan_tx_tag_get(skb);
> +		encap = skb->protocol;
> +	}
> +
[...]

This has the same problem.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

