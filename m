From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] 8021q: fix a potential memory leak
Date: Wed, 18 Jun 2014 00:00:51 -0700
Message-ID: <1403074851.4559.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1403070362-29664-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:51514 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259AbaFRHAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 03:00:55 -0400
Received: by mail-we0-f181.google.com with SMTP id q59so345493wes.40
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 00:00:54 -0700 (PDT)
In-Reply-To: <1403070362-29664-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-06-18 at 13:46 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> skb_cow called in vlan_reorder_header does not free the skb when it failed,
> and vlan_reorder_header returns NULL to reset original skb when it is called
> in vlan_untag, lead to a memory leak.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/8021q/vlan_core.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index 9012b1c..75d4277 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -114,8 +114,11 @@ EXPORT_SYMBOL(vlan_dev_vlan_proto);
>  
>  static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
>  {
> -	if (skb_cow(skb, skb_headroom(skb)) < 0)
> +	if (skb_cow(skb, skb_headroom(skb)) < 0) {
> +		kfree_skb(skb);
>  		return NULL;
> +	}
> +
>  	memmove(skb->data - ETH_HLEN, skb->data - VLAN_ETH_HLEN, 2 * ETH_ALEN);
>  	skb->mac_header += VLAN_HLEN;
>  	return skb;

Good catch.

Acked-by: Eric Dumazet <edumazet@google.com>

Note that the 'goto err_free;' in caller is misleading as well, as skb
is NULL.

vlan_reorder_header() could return an error code instead of a skb...
