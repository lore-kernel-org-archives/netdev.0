From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/9 v2] net: Refactor ip_route_input_slow
Date: Wed, 23 Sep 2015 10:33:07 -0700
Message-ID: <1443029587.29850.120.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
	 <1443022239.29850.113.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5602CE70.5010001@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34484 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755783AbbIWRdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 13:33:09 -0400
Received: by padhy16 with SMTP id hy16so46269137pad.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 10:33:08 -0700 (PDT)
In-Reply-To: <5602CE70.5010001@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-23 at 10:08 -0600, David Ahern wrote:
> On 9/23/15 9:30 AM, Eric Dumazet wrote:
> >
> > You also remove a lot of goto, but do not place likely() or unlikely()
> > clauses that would help compiler to emit the same optimal code.
> 
> I do not see where I have changed the likely/unlikely aspect of the 
> logic. Can you point to an example in the patches?
> 

Sure, I did for PATCH net-next 7/9

Copied here :

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 0fdcb0539795..c23bb0965966 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1790,15 +1790,19 @@ static int ip_route_input_slow(struct sk_buff
*skb, __be32 daddr, __be32 saddr,
>       if (ipv4_is_lbcast(daddr) || (saddr == 0 && daddr == 0))
>               goto brd_input;
>  
> -     if (ipv4_is_zeronet(daddr))
> -             goto martian_destination;
> +     if (ipv4_is_zeronet(daddr)) {
> +             ip_handle_martian_dest(dev, in_dev, daddr, saddr);
> +             goto out;
> +     }
>  

As requested, here is an example of code for which compiler might
compile in a non efficient way, ie inserting code at the wrong place,
increasing icache pressure.

Removing a goto is removing an implicit unlikely.
