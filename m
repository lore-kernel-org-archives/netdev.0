From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] net: Initialize entire flowi struct
Date: Wed, 31 Aug 2011 23:51:32 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108312321400.1826@ja.ssi.bg>
References: <1314806703-5275-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:33105 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754673Ab1HaUpd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 16:45:33 -0400
In-Reply-To: <1314806703-5275-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 31 Aug 2011, David Ward wrote:

> The entire flowi struct needs to be initialized by afinfo->decode_session,
> because flow_hash_code operates over the entire struct and may otherwise
> return different hash values for what is intended to be the same key.

	Such change will cause problems for callers that
use flowi4 in stack. Examples:

ip_route_me_harder
icmp_route_lookup

	Not sure if adding size as parameter to flow_hash_code
is better approach. May be flow_cache_lookup needs to
determine size from family that can be used for flow_hash_code,
flow_key_compare and the memcpy(&fle->key, key, sizeof(*key))
after fle = kmem_cache_alloc(flow_cachep, GFP_ATOMIC). The
question is how to get size by family.

> Signed-off-by: David Ward <david.ward@ll.mit.edu>
> ---
>  net/ipv4/xfrm4_policy.c |    2 +-
>  net/ipv6/xfrm6_policy.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
> index fc5368a..afce24d 100644
> --- a/net/ipv4/xfrm4_policy.c
> +++ b/net/ipv4/xfrm4_policy.c
> @@ -114,7 +114,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
>  	u8 *xprth = skb_network_header(skb) + iph->ihl * 4;
>  	struct flowi4 *fl4 = &fl->u.ip4;
>  
> -	memset(fl4, 0, sizeof(struct flowi4));
> +	memset(fl, 0, sizeof(struct flowi));
>  	fl4->flowi4_mark = skb->mark;
>  
>  	if (!ip_is_fragment(iph)) {
> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
> index d879f7e..9088d38 100644
> --- a/net/ipv6/xfrm6_policy.c
> +++ b/net/ipv6/xfrm6_policy.c
> @@ -129,7 +129,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
>  	const unsigned char *nh = skb_network_header(skb);
>  	u8 nexthdr = nh[IP6CB(skb)->nhoff];
>  
> -	memset(fl6, 0, sizeof(struct flowi6));
> +	memset(fl, 0, sizeof(struct flowi));
>  	fl6->flowi6_mark = skb->mark;
>  
>  	ipv6_addr_copy(&fl6->daddr, reverse ? &hdr->saddr : &hdr->daddr);
> -- 
> 1.7.4.1

Regards

--
Julian Anastasov <ja@ssi.bg>
