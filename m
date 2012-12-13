From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH] xfrm: avoid to send/receive the exceeding hard
 lifetime data
Date: Thu, 13 Dec 2012 11:14:22 +0100
Message-ID: <20121213101422.GF18940@secunet.com>
References: <1355387152-9963-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34119 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752802Ab2LMKOZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 05:14:25 -0500
Content-Disposition: inline
In-Reply-To: <1355387152-9963-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2012 at 04:25:52PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> If setkey sets both bh and bs as 1024, and the total send and receive package
> size is 1024, then if next package size is too large, this package should be
> discard.
> 
> Example, first package size is 1000, send success, then the second package
> is 500, 1000+500 is larger than 1024, so the second package should be discard.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com> 
> ---
>  net/xfrm/xfrm_input.c  |    6 +++---
>  net/xfrm/xfrm_output.c |    6 +++---
>  2 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
> index ab2bb42..d0de8f3 100644
> --- a/net/xfrm/xfrm_input.c
> +++ b/net/xfrm/xfrm_input.c
> @@ -178,6 +178,9 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
>  			goto drop_unlock;
>  		}
>  
> +		x->curlft.bytes += skb->len;
> +		x->curlft.packets++;
> +

This is a bit critical on input. We should only increment these values
if the integrity check on this packet was successfull. Otherwise someone
could spam us with invalid packets and trigger a state expiry.

If a synchronous crypto algorithm is used, we send at most one packet too
much. The maximal byte count was not yet reached and RFC 2401 says not
much on how to handle the packet that reaches the maximal byte count,
so this is probaply ok.

But if an asynchronous crypto algorithm is used, we can send a lot
of packets too much. So we should probaply add a second expiry check
after resume from asynchronous crypto. We do this already with the replay
check.
