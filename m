From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 7/9] net: Remove martian_destination label
Date: Wed, 23 Sep 2015 10:27:48 -0700
Message-ID: <1443029268.29850.118.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
	 <1443021322-48621-8-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34011 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755783AbbIWR1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 13:27:50 -0400
Received: by padhy16 with SMTP id hy16so46154207pad.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 10:27:50 -0700 (PDT)
In-Reply-To: <1443021322-48621-8-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-23 at 08:15 -0700, David Ahern wrote:
> Move call to ip_handle_martian_dest to various jump sites. The
> function only increments a counter and possibly does additional
> logging if CONFIG_IP_ROUTE_VERBOSE is enabled.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/ipv4/route.c | 24 +++++++++++++-----------
>  1 file changed, 13 insertions(+), 11 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 0fdcb0539795..c23bb0965966 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1790,15 +1790,19 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>  	if (ipv4_is_lbcast(daddr) || (saddr == 0 && daddr == 0))
>  		goto brd_input;
>  
> -	if (ipv4_is_zeronet(daddr))
> -		goto martian_destination;
> +	if (ipv4_is_zeronet(daddr)) {
> +		ip_handle_martian_dest(dev, in_dev, daddr, saddr);
> +		goto out;
> +	}
>  

As requested, here is an example of code for which compiler might
compile in a non efficient way, ie inserting code at the wrong place,
increasing icache pressure.

Removing a goto is removing an implicit unlikely.
