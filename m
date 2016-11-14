From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] ipv6: sr: fix IPv6 initialization failure
 without lwtunnels
Date: Mon, 14 Nov 2016 06:22:19 -0800
Message-ID: <5829C89B.7010405@cumulusnetworks.com>
References: <CAKD1Yr0fDFdDv9+S3i_rH6W6btEuvs9s-h33_N67iM4qrtDezQ@mail.gmail.com>        <1478780813-20005-1-git-send-email-david.lebrun@uclouvain.be>        <20161113.002055.1386089188095640295.davem@davemloft.net> <20161113.002348.81553025732356797.davem@davemloft.net> <5828C619.2020008@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        lorenzo@google.com
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34992 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932190AbcKNO2H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 09:28:07 -0500
Received: by mail-pg0-f45.google.com with SMTP id p66so54770305pga.2
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 06:28:06 -0800 (PST)
In-Reply-To: <5828C619.2020008@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/16, 11:59 AM, David Lebrun wrote:
> On 11/13/2016 06:23 AM, David Miller wrote:
>> This seems like such a huge mess, quite frankly.
>>
>> IPV6-SR has so many strange dependencies, a weird Kconfig option that is
>> simply controlling what a responsible sysadmin should be allow to do if
>> he chooses anyways.
>>
>> Every distribution is going to say "¯\_(ツ)_/¯" and just turn the thing
>> on in their builds.
> Indeed, the issue is that seg6_iptunnel.o was included in obj-y instead
> of ipv6-y, triggering the bug when CONFIG_IPV6=m. Fixed with the
> following modification to the patch (tested with allyesconfig and
> allmodconfig):
>
> diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
> index 8979d53..a233136 100644
> --- a/net/ipv6/Makefile
> +++ b/net/ipv6/Makefile
> @@ -53,6 +53,6 @@ obj-$(subst m,y,$(CONFIG_IPV6)) += inet6_hashtables.o
>
>  ifneq ($(CONFIG_IPV6),)
>  obj-$(CONFIG_NET_UDP_TUNNEL) += ip6_udp_tunnel.o
> -obj-$(CONFIG_LWTUNNEL) += seg6_iptunnel.o
> +ipv6-$(CONFIG_LWTUNNEL) += seg6_iptunnel.o
>  obj-y += mcast_snoop.o
>  endif


>
> I agree with you that the way to combine the dependencies is strange,
> even if they are very few. The part of the IPv6-SR patch that is enabled
> by default depends on two things: IPV6 and LWTUNNEL. The problem is that
> LWTUNNEL does not depend on IPV6 and is not necessarily enabled. To fix
> the bug reported by Lorenzo, I propose to select one the three following
> solutions:
>
> 1. Make LWTUNNEL always enabled (removing the option).
>    Pros: remove an option
>    Cons: add always-enabled code
>
> 2. Create an option IPV6_SEG6_LWTUNNEL, which would select LWTUNNEL and
> enable the compilation of seg6_iptunnel.o.
>    Pros: logically dissociate the part of IPv6-SR that depends on
> LWTUNNEL from the core patch and simplifies compilation
>    Cons: add an option

I prefer option b). most LWTUNNEL encaps are done this way.

seg6 and seg6_iptunnel is new segment routing code and can be under CONFIG_IPV6_SEG6 which depends on CONFIG_LWTUNNEL and CONFIG_IPV6. CONFIG_IPV6_SEG6_HMAC could then depend on CONFIG_IPV6_SEG6



>
> 3. Apply the proposed patch with the fix
>    Pros: do not modify options
>    Cons: weird conditional compilation
>
> What do you think ?
>
> David
>
