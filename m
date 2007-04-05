From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: Bug in SCTP with SCTP_BINDX_REM_ADDR
Date: Thu, 05 Apr 2007 13:07:18 -0600
Message-ID: <461548E6.4030008@hp.com>
References: <4614FAE6.3070409@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sri@us.ibm.com
To: Paolo Galtieri <pgaltieri@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelrim03.cce.hp.com ([161.114.21.24]:43244 "EHLO
	ccerelrim03.cce.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767218AbXDETH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 15:07:28 -0400
In-Reply-To: <4614FAE6.3070409@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paolo

Paolo Galtieri wrote:
> What is happening is that the check for IPV6_ADDR_MAPPED that occurs
> during the add is missing when you do the remove and hence the IPv6
> address is never mapped to the IPv4 address causing the lookup to
> fail.  Below is the patch to add the necessary checks to do the
> mapping.  This patch is against 2.6.21-rc5
> 
> Does this make sense?  Any comments are appreciated.
>

Yes, it makes perfect sense; however, I think you can just use
af->addr_valid() instead of adding a special case below.

If that works, can you regenerate the patch and provide a
Signed-off-by line so I can incorporate that.

Thanks
-vlad

> Thank you,
> Paolo
> 
> I've attached the test program - compile as gcc -o bindx-test-ipv6 
> bindx-test-ipv6.c -lsctp
> ================================ >8 
> ==========================================
> --- net/sctp/socket.c.orig      2007-04-04 13:22:59.000000000 -0700
> +++ net/sctp/socket.c   2007-04-04 13:25:35.000000000 -0700
> @@ -627,6 +627,27 @@ int sctp_bindx_rem(struct sock *sk, stru
>                        retval = -EINVAL;
>                        goto err_bindx_rem;
>                }
> +               /*
> +                * It's possible that we mapped an IPV6 addr to an IPV4 
> addr
> +                * during the sctp_bindx_add() operation.  This will 
> happen if
> +                * the IPV6 address we assigned to an interface is a mapped
> +                * address, e.g. ::ffff:192.0.2.128.  If we have mapped 
> an IPV6
> +                * address to an IPV4 address during the add we need to 
> make
> +                * sure we do the same thing during the remove, 
> otherwise we
> +                * wont find a match on the address_list.
> +                */
> +
> +               if (af->sa_family == AF_INET6) {
> +                       struct in6_addr *in6;
> +                       int type;
> +
> +                       in6 = (struct in6_addr *)&sa_addr->v6.sin6_addr;
> +                       type = ipv6_addr_type(in6);
> +
> +                       if (type == IPV6_ADDR_MAPPED)
> +                               sctp_v6_map_v4(sa_addr);
> +               }
> +
>                if (sa_addr->v4.sin_port != htons(bp->port)) {
>                        retval = -EINVAL;
>                        goto err_bindx_rem;
> 
> 

