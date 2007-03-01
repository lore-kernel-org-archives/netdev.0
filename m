From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] bridge: avoid ptype_all packet handling
Date: Wed, 28 Feb 2007 17:28:09 -0800
Message-ID: <45E62C29.7010203@candelatech.com>
References: <20070228171846.679d8733@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bridge@linux-foundation.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:42056 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932863AbXCAB2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 20:28:13 -0500
In-Reply-To: <20070228171846.679d8733@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> I was measuring bridging/routing performance and noticed this.
> 
> The current code runs the "all packet" type handlers before calling the
> bridge hook.  If an application (like some DHCP clients) is using AF_PACKET,
> this means that each received packet gets run through the Berkeley Packet Filter
> code in sk_run_filter (slow).
> 
> By moving the bridging hook to run first, the packets flowing through
> the bridge get filtered out there. This results in a 14%
> improvement in performance, but it does mean that some snooping applications
> would miss packets if being used on a bridge.  The correct way to see all
> packets on a bridge is to set the bridge pseudo-device to promiscuous
> mode.

Seems it would be better to fix these clients to be more selective as to
where they bind.

This breaks the case where you want to see packets on a particular interface,
not just the entire bridge, right?

Thanks,
Ben

> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> ---
>  net/core/dev.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index cf71614..dc2cda6 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1792,6 +1792,10 @@ int netif_receive_skb(struct sk_buff *skb)
>  
>  	rcu_read_lock();
>  
> +	if (handle_bridge(&skb, &pt_prev, &ret, orig_dev))
> +		goto out;
> +
> +
>  #ifdef CONFIG_NET_CLS_ACT
>  	if (skb->tc_verd & TC_NCLS) {
>  		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
> @@ -1826,9 +1830,6 @@ int netif_receive_skb(struct sk_buff *skb)
>  ncls:
>  #endif
>  
> -	if (handle_bridge(&skb, &pt_prev, &ret, orig_dev))
> -		goto out;
> -
>  	type = skb->protocol;
>  	list_for_each_entry_rcu(ptype, &ptype_base[ntohs(type)&15], list) {
>  		if (ptype->type == type &&


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

