From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net] vxlan: do not use fdb in metadata mode
Date: Thu, 18 Feb 2016 15:32:40 +0900
Message-ID: <20160218063238.GB22357@vergenet.net>
References: <6003cfff14ce8e36bfbe4929fce56d06e4ebec58.1455657466.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35306 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424013AbcBRGcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 01:32:55 -0500
Received: by mail-pa0-f44.google.com with SMTP id ho8so25917230pac.2
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 22:32:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <6003cfff14ce8e36bfbe4929fce56d06e4ebec58.1455657466.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Tue, Feb 16, 2016 at 10:18:26PM +0100, Jiri Benc wrote:
> In metadata mode, the vxlan interface is not supposed to use the fdb control
> plane but an external one (openvswitch or static routes). With the current
> code, packets may leak into the fdb handling code which usually causes them
> to be dropped anyway but may have strange side effects.
> 
> Just drop the packets directly when in metadata mode if the destination data
> are not correctly provided on egress.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

The logic here looks correct to me but I am curious to know
what circumstances would lead to the kfree_skb() case.

> ---
>  drivers/net/vxlan.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index db96f3a16f6c..e6944b29588e 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2171,9 +2171,11 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
>  #endif
>  	}
>  
> -	if (vxlan->flags & VXLAN_F_COLLECT_METADATA &&
> -	    info && info->mode & IP_TUNNEL_INFO_TX) {
> -		vxlan_xmit_one(skb, dev, NULL, false);
> +	if (vxlan->flags & VXLAN_F_COLLECT_METADATA) {
> +		if (info && info->mode & IP_TUNNEL_INFO_TX)
> +			vxlan_xmit_one(skb, dev, NULL, false);
> +		else
> +			kfree_skb(skb);
>  		return NETDEV_TX_OK;
>  	}
>  
> -- 
> 1.8.3.1
> 
