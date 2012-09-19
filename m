From: Jamie Gloudon <jamie.gloudon@gmail.com>
Subject: Re: [PATCH net-next] net: more accurate network taps in transmit path
Date: Wed, 19 Sep 2012 11:58:30 -0400
Message-ID: <20120919155830.GA1456@darkstar>
References: <20120918193208.GA19030@darkstar>
 <1347998905.2685.29.camel@bwh-desktop.uk.solarflarecom.com>
 <20120918211423.GA19115@darkstar>
 <1348034050.26523.325.camel@edumazet-glaptop>
 <1348037089.26523.397.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:45348 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755446Ab2ISP6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 11:58:39 -0400
Received: by qcro28 with SMTP id o28so927200qcr.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 08:58:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1348037089.26523.397.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just to report. This patch fixed the invalid tcp tx checksum issue via tap for me. Thanks!

On Wed, Sep 19, 2012 at 08:44:49AM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> dev_queue_xmit_nit() should be called right before ndo_start_xmit()
> calls or we might give wrong packet contents to taps users :
> 
> Packet checksum can be changed, or packet can be linearized or
> segmented, and segments partially sent for the later case.
> 
> Also a memory allocation can fail and packet never really hit the
> driver entry point.
> 
> Reported-by: Jamie Gloudon <jamie.gloudon@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/core/dev.c |    9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index dcc673d..52cd1d7 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2213,9 +2213,6 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
>  			skb_dst_drop(skb);
>  
> -		if (!list_empty(&ptype_all))
> -			dev_queue_xmit_nit(skb, dev);
> -
>  		features = netif_skb_features(skb);
>  
>  		if (vlan_tx_tag_present(skb) &&
> @@ -2250,6 +2247,9 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  			}
>  		}
>  
> +		if (!list_empty(&ptype_all))
> +			dev_queue_xmit_nit(skb, dev);
> +
>  		skb_len = skb->len;
>  		rc = ops->ndo_start_xmit(skb, dev);
>  		trace_net_dev_xmit(skb, rc, dev, skb_len);
> @@ -2272,6 +2272,9 @@ gso:
>  		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
>  			skb_dst_drop(nskb);
>  
> +		if (!list_empty(&ptype_all))
> +			dev_queue_xmit_nit(nskb, dev);
> +
>  		skb_len = nskb->len;
>  		rc = ops->ndo_start_xmit(nskb, dev);
>  		trace_net_dev_xmit(nskb, rc, dev, skb_len);
> 
> 
