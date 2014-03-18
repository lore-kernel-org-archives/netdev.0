From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCHv3 net-next] VXLAN: fix nonfunctional neigh_reduce
Date: Tue, 18 Mar 2014 13:44:07 -0400
Message-ID: <532885E7.9090602@hp.com>
References: <201403181620.s2IGKHcW028664@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:32071 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbaCRRoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 13:44:34 -0400
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com [15.217.128.51])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id C82E531EF
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 17:44:24 +0000 (UTC)
In-Reply-To: <201403181620.s2IGKHcW028664@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/18/2014 12:20 PM, David L Stevens wrote:
> 
> 	The VXLAN neigh_reduce() code is completely non-functional since
> check-in. Specific errors:
<snip>
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index eb59b14..f6ddde9 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1336,14 +1336,102 @@ out:
>  }
>  
>  #if IS_ENABLED(CONFIG_IPV6)
> +
> +static struct sk_buff *vxlan_na_create(struct sk_buff *request,
> +	struct neighbour *n, bool isrouter)
> +{
> +	struct net_device *dev = request->dev;
> +	struct sk_buff *reply = NULL;

Don't need this initialization as it's assigned below before using.

> +	struct nd_msg *ns, *na;
> +	struct ipv6hdr *pip6;
> +	u8 *daddr;
> +	int olen = 8; /* opt hdr + ETH_ALEN for target */
> +	int i, len;
> +
> +	if (dev == NULL)
> +		return NULL;
> +
> +	ns = (struct nd_msg *)skb_transport_header(request);

Nit: don't use this until below, can move initialization.

> +	len = LL_RESERVED_SPACE(dev) + sizeof(struct ipv6hdr) +
> +		sizeof(*na) + olen + dev->needed_tailroom;
> +	reply = alloc_skb(len, GFP_ATOMIC);
> +	if (reply == NULL)
> +		return NULL;
> +
> +	reply->protocol = htons(ETH_P_IPV6);
> +	reply->dev = dev;
> +	skb_reserve(reply, LL_RESERVED_SPACE(request->dev));
> +	skb_push(reply, sizeof(struct ethhdr));
> +	skb_set_mac_header(reply, 0);
> +
> +	daddr = eth_hdr(request)->h_source;
> +	olen = request->len - skb_transport_offset(request) - sizeof(*ns);
> +	for (i = 0; i < olen-1; i += (ns->opt[i+1]<<3)) {
> +		if (ns->opt[i] == ND_OPT_SOURCE_LL_ADDR) {
> +			daddr = ns->opt + i + sizeof(struct nd_opt_hdr);
> +			break;
> +		}
> +	}
> +
> +	/* Ethernet header */
> +	memcpy(eth_hdr(reply)->h_dest, daddr, ETH_ALEN);
> +	memcpy(eth_hdr(reply)->h_source, n->ha, ETH_ALEN);

Can use ether_addr_copy() here.

-Brian
