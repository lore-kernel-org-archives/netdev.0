From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv5 net-next] VXLAN: fix nonfunctional neigh_reduce
Date: Wed, 19 Mar 2014 16:20:53 -0400 (EDT)
Message-ID: <20140319.162053.1175830729987006835.davem@davemloft.net>
References: <201403182009.s2IK9Ias021320@lab1.dls>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, amwang@redhat.com, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665AbaCSUUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 16:20:55 -0400
In-Reply-To: <201403182009.s2IK9Ias021320@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <dlstevens@us.ibm.com>
Date: Tue, 18 Mar 2014 16:09:18 -0400

> +	if (dev == NULL)
> +		return NULL;
> +
> +
> +	len = LL_RESERVED_SPACE(dev) + sizeof(struct ipv6hdr) +
> +		sizeof(*na) + olen + dev->needed_tailroom;

No need to have two empty lines here, one is sufficient.

> +	olen = request->len - skb_transport_offset(request) - sizeof(*ns);

This overrides unconditionally, and in all cases, the assignment made
in the declaration of the 'olen' variable.  Therefore the variable
declaration should not have an initializer.  Please remove it.

 ...
> +	for (i = 0; i < olen-1; i += (ns->opt[i+1]<<3)) {
> +		if (ns->opt[i] == ND_OPT_SOURCE_LL_ADDR) {
> +			daddr = ns->opt + i + sizeof(struct nd_opt_hdr);
> +			break;
> +		}
> +	}

It's a real shame that we can't reuse ndisc_opt_addr_space(),
ndisc_parse_options(), etc. for this stuff.

> +	olen = 8; /* ND_OPT_TARGET_LL_ADDR */

I guess this is what the variable declaration assignment was
meant to be used for.

This is also ndisc_opt_addr_space(dev).

> +	na->opt[1] = 1; /* 8 bytes */

This is perhaps more clearly expressed as "opt >> 3".
> @@ -1357,8 +1446,7 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
>  	saddr = &iphdr->saddr;
>  	daddr = &iphdr->daddr;
>  
> -	if (ipv6_addr_loopback(daddr) ||
> -	    ipv6_addr_is_multicast(daddr))
> +	if (ipv6_addr_loopback(daddr))
>  		goto out;
>  
>  	msg = (struct nd_msg *)skb_transport_header(skb);

Note that the ipv6 stack input path checks to make sure that the
msg->target is not multicast.  Just something I noticed.
