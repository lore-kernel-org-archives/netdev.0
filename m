From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: Cannot communicate with brX when its MAC
 address is changed
Date: Thu, 1 Dec 2011 09:21:06 -0800
Message-ID: <20111201092106.00473fed@nehalam.linuxnetplumber.net>
References: <4ED5E9D6.3070404@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39518 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754826Ab1LARVL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 12:21:11 -0500
In-Reply-To: <4ED5E9D6.3070404@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Nov 2011 17:31:18 +0900
Koki Sanagi <sanagi.koki@jp.fujitsu.com> wrote:

> When the MAC address of a bridge interface is changed, it cannot communicate
> with others. Because Whether or not a packet should be transferred to bridge
> interface depends on whether or not dst of a packet is in fdb and is_local=y.
> If we change MAC address of a bridge interface, it isn't in fdb.
> 
> This patch adds an condition that dst of a packet matches MAC address of
> a bridge interface to the conventional condition.
> 
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> ---
>  net/bridge/br_input.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 5a31731..4e5c862 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -94,7 +94,8 @@ int br_handle_frame_finish(struct sk_buff *skb)
>  			skb2 = skb;
>  
>  		br->dev->stats.multicast++;
> -	} else if ((dst = __br_fdb_get(br, dest)) && dst->is_local) {
> +	} else if ((dst = __br_fdb_get(br, dest) && dst->is_local) ||
> +		   !compare_ether_addr(p->br->dev->dev_addr, dest)) {
>  		skb2 = skb;
>  		/* Do not forward the packet since it's local. */
>  		skb = NULL;
> 

There is a problem with paren's in this version of the patch, don't apply it!

Looked into using fdb to handle this, but then there would be fdb entries
where the destination port entry was either NULL (or a dummy), and that
would require a bunch of auditing of all usages and could introduce new
bugs.

I am testing a patch that does same thing by moving compare_ether up
to where broadcast is tested.
