From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] vxlan: use ether header as fallback hash
Date: Thu, 04 Oct 2012 06:57:53 +0200
Message-ID: <1349326673.16011.5.camel@edumazet-glaptop>
References: <20121001223232.566037595@vyatta.com>
	 <20121001223254.349753999@vyatta.com>
	 <CAEP_g=9Y3MmsABQJyi508FEgs4635tnaVqk4Ncwbpm41bLskhg@mail.gmail.com>
	 <20121003213906.09b57539@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@nicira.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:35966 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752977Ab2JDE56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 00:57:58 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so63982wey.19
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2012 21:57:56 -0700 (PDT)
In-Reply-To: <20121003213906.09b57539@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-03 at 21:39 -0700, Stephen Hemminger wrote:
> VXLAN bases source UDP port based on flow to help the
> receiver to be able to load balance based on outer header
> contents.
> 
> This patches changes the algorithm to better handle packets
> that can not be categorized by the rxhash() function.
> It adds a fallback to use jhash on the Ether header.
> 
> It also fixes a bug where the old code could assign 0 as a port
> value.
> 
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> RFC for now, compile tested only
> 
> --- a/drivers/net/vxlan.c	2012-10-03 21:25:43.747968165 -0700
> +++ b/drivers/net/vxlan.c	2012-10-03 21:36:10.213805422 -0700
> @@ -622,12 +622,30 @@ static inline u8 vxlan_ecn_encap(u8 tos,
>  	return INET_ECN_encapsulate(tos, inner);
>  }
>  

#include <linux/jhash.h>

> +/* Compute hash to use for source port
> + *   first choice to use L4 flow hash since it will spread
> + *     better and maybe available from hardware
> + *   secondary choice is to use jhash on the Ethernet header
> + * Always returns non-zero value
> + */
> +static u16 vxlan_flow_hash(struct sk_buff *skb)
> +{
> +	u16 hash = skb_get_rxhash(skb);

skb_get_rxhash(skb) returns an u32, that could have low order 16bits set
to 0.

So I would use u32 hash = skb_get_rxhash(skb);



> +
> +	if (!hash)
> +		hash = jhash(skb->data, 3, skb->protocol);
> +

then here, do :

	hash ^= hash >> 16;
	hash &= 0xffff;


> +	if (!hash)
> +		hash = 1;
> +
> +	return hash;
> +}
> +
