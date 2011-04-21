From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bonding: fix bridged bonds in 802.3ad mode
Date: Thu, 21 Apr 2011 20:08:19 +0100
Message-ID: <1303412899.3165.47.camel@bwh-desktop>
References: <20110421184748.GD23756@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Benjamin Poirier <benjamin.poirier@polymtl.ca>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:7859 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376Ab1DUTIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 15:08:23 -0400
In-Reply-To: <20110421184748.GD23756@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-21 at 20:47 +0200, Jiri Bohac wrote:
> 802.3ad bonding inside a bridge is broken again. Originally fixed by
> 43aa1920117801fe9ae3d1fad886b62511e09bee, the bug was re-introduced by
> 1e253c3b8a1aeed51eef6fc366812f219b97de65.
> 
> LACP frames must not have their skb->dev changed by the bridging hook.
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> 
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1514,6 +1514,11 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
>  		memcpy(eth_hdr(skb)->h_dest, bond->dev->dev_addr, ETH_ALEN);
>  	}
>  
> +	/* prevent bridging code from mangling and forwarding LACP frames */
> +	if (bond->params.mode == BOND_MODE_8023AD &&
> +	    skb->protocol == htons(ETH_P_SLOW))
> +		return RX_HANDLER_PASS;
> +
>  	return RX_HANDLER_ANOTHER;
>  }
>  

It seems to me that 1e253c3b8a1aeed51eef6fc366812f219b97de65 is bogus
and should be reverted, rather than worked around by other drivers.  We
shouldn't enable non-conformant forwarding behaviour by default just
because some people find it useful.  The administrator should have to
explicitly enable it.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

