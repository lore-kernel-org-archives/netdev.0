From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix resetting network_header in
 neigh_resolve_output and neigh_connected_output
Date: Fri, 01 Jul 2016 15:57:39 -0400 (EDT)
Message-ID: <20160701.155739.68430210554301895.davem@davemloft.net>
References: <1557d0eb9b5.10e107ce3332041.1418466288700186568@abahmed.com>
	<20160627.101032.719251971537230839.davem@davemloft.net>
	<15592436817.c86fc05b10946.6198596471268005484@abahmed.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ab@abahmed.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <15592436817.c86fc05b10946.6198596471268005484@abahmed.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Abdelrhman Ahmed <ab@abahmed.com>
Date: Mon, 27 Jun 2016 16:28:59 +0200

> @@ -1293,15 +1293,19 @@ int neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb)
>  	int rc = 0;
>  
>  	if (!neigh_event_send(neigh, skb)) {
> -		int err;
> +		int err, offset;
>  		struct net_device *dev = neigh->dev;
> +		unsigned char *data;
>  		unsigned int seq;
>  
>  		if (dev->header_ops->cache && !neigh->hh.hh_len)
>  			neigh_hh_init(neigh);
>  
> +		data = skb->data;
> +
>  		do {
> -			__skb_pull(skb, skb_network_offset(skb));
> +			offset = data - skb->data;
> +			__skb_pull(skb, offset);

This is definitely not right, using skb->data for this.  It may work
for the cases you have tested but it is not generally correct.

You must use the skb network header.

You are just trying to avoid doing the pull more than once if we loop
right?  Then simply use a boolean to track that.
