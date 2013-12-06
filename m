From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] gro: small napi_get_frags() optim
Date: Thu, 05 Dec 2013 22:11:08 -0800
Message-ID: <1386310268.31845.13.camel@joe-AO722>
References: <1386308667.30495.230.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0099.hostedemail.com ([216.40.44.99]:46897 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751048Ab3LFGLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 01:11:22 -0500
Received: from smtprelay.hostedemail.com (ff-bigip1 [10.5.19.254])
	by smtpgrave05.hostedemail.com (Postfix) with ESMTP id 00094183FF2
	for <netdev@vger.kernel.org>; Fri,  6 Dec 2013 06:11:21 +0000 (UTC)
In-Reply-To: <1386308667.30495.230.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-05 at 21:44 -0800, Eric Dumazet wrote:
> Remove one useless conditional branch : 
> napi->skb is NULL, so nothing bad can happen.
[]
> diff --git a/net/core/dev.c b/net/core/dev.c
[]
> @@ -3981,8 +3981,7 @@ struct sk_buff *napi_get_frags(struct napi_struct *napi)
>  
>  	if (!skb) {
>  		skb = netdev_alloc_skb_ip_align(napi->dev, GRO_MAX_HEAD);
> -		if (skb)
> -			napi->skb = skb;
> +		napi->skb = skb;

Thanks, I agree this patch is appropriate as skb is unlikely
to be NULL in normal cases.

But just for thought: isn't the test expense essentially
free when skb is in a register vs the member set cost?

Also, netdev_alloc_skb_ip_align is static inline and it has
a test of
	if (NET_IP_ALIGN && skb)
just before the return so this "if (skb)" test could already
be elided by a good compiler but this change requires an
unconditional set.
