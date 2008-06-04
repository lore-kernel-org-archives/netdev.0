From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: PATCH: fix bridged 802.3ad bonding
Date: Wed, 4 Jun 2008 10:24:25 +0200
Message-ID: <20080604082425.GA3272@midget.suse.cz>
References: <20080603132106.GA3256@midget.suse.cz> <20080603094604.6a7dfe7d@extreme> <20080603193227.GA4050@midget.suse.cz> <20080603131326.1f70915e@extreme> <18105.1212528128@death> <20080603215519.298c0cd3@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, Jiri Bohac <jbohac@suse.cz>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:47402 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753030AbYFDIY1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 04:24:27 -0400
Content-Disposition: inline
In-Reply-To: <20080603215519.298c0cd3@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 09:55:19PM -0700, Stephen Hemminger wrote:
> I prefer the following because it process all link-local frames through
> the normal input path. This means the frames will:
> 	* be filterable by netfilter

Well, the LACP frames are not filtered by netfilter when there is
bonding on its own (not part of a bridge), so I don't see why
this should change when the bond is made part of a bridge.

Maybe it is a good idea to run the LACP frames through netfilter,
but I think this should be done consistently in the bonding code,
whether or not bridging is set up, and probably on the individual
slave interfaces. It does not make sense to filter bonding's LACP
frames in ebtables, IMHO.

> 	* not forwarded across bridge (this is important).

I thought this was the case with my second patch as well (?)

 
> --- a/net/bridge/br_input.c	2008-06-03 21:44:54.000000000 -0700
> +++ b/net/bridge/br_input.c	2008-06-03 21:52:20.000000000 -0700
> @@ -135,15 +135,12 @@ struct sk_buff *br_handle_frame(struct n
>  		/* Pause frames shouldn't be passed up by driver anyway */
>  		if (skb->protocol == htons(ETH_P_PAUSE))
>  			goto drop;
> -
> -		/* Process STP BPDU's through normal netif_receive_skb() path */
> -		if (p->br->stp_enabled != BR_NO_STP) {
> -			if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
> -				    NULL, br_handle_local_finish))
> -				return NULL;
> -			else
> -				return skb;
> -		}
> +
> +		if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
> +			    NULL, br_handle_local_finish))
> +			return NULL;	/* frame consumed by filter */
> +		else
> +			return skb;	/* continue processing */
>  	}
>  
>  	switch (p->state) {

where did the "if (p->br->stp_enabled != BR_NO_STP)" condition
go? Is it not needed? I thought it was there to prevent the STP
BPDUs from being handled when STP is turned off.

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

