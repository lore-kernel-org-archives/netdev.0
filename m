From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Mon, 8 Aug 2016 09:27:12 -0600
Message-ID: <39efdc37-88cc-34c4-ad64-2f13fd0bc4a2@cumulusnetworks.com>
References: <1470642127-574-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, ek@google.com, davem@davemloft.net,
	hideaki.yoshifuji@miraclelinux.com
To: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35149 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbcHHP1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 11:27:20 -0400
Received: by mail-pf0-f171.google.com with SMTP id x72so120301924pfd.2
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 08:27:19 -0700 (PDT)
In-Reply-To: <1470642127-574-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/8/16 1:42 AM, Lorenzo Colitti wrote:
> ping_v6_sendmsg never sets flowi6_oif, so it is not possible to
> ping an IPv6 address on a different interface. Instead, it sets
> flowi6_iif, which is incorrect but harmless. Also, it returns an
> error if a passed-in scope ID doesn't match sk_bound_dev_if.
> 
> Get rid of the error, stop setting flowi6_iif, and support
> various ways of setting oif in the same priority order used by
> udpv6_sendmsg.
> 
> Tested: https://android-review.googlesource.com/#/c/254470/
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---
>  net/ipv6/ping.c | 29 +++++++++++++++--------------
>  1 file changed, 15 insertions(+), 14 deletions(-)
> 
> diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
> index fed40d1..eabf1ea 100644
> --- a/net/ipv6/ping.c
> +++ b/net/ipv6/ping.c

-----8<-----

> @@ -106,16 +111,12 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
>  	fl6.flowi6_proto = IPPROTO_ICMPV6;
>  	fl6.saddr = np->saddr;
>  	fl6.daddr = *daddr;
> +	fl6.flowi6_oif = oif;
>  	fl6.flowi6_mark = sk->sk_mark;
>  	fl6.fl6_icmp_type = user_icmph.icmp6_type;
>  	fl6.fl6_icmp_code = user_icmph.icmp6_code;
>  	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
>  
> -	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
> -		fl6.flowi6_oif = np->mcast_oif;
> -	else if (!fl6.flowi6_oif)
> -		fl6.flowi6_oif = np->ucast_oif;
> -
>  	ipc6.tclass = np->tclass;
>  	fl6.flowlabel = ip6_make_flowinfo(ipc6.tclass, fl6.flowlabel);
>  
> 

That code removal is contrary to your patch description regarding flowi6_oif.
