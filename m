From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Tue, 19 Feb 2008 22:49:08 +0900
Message-ID: <1203428949.3223.25.camel@shinybook.infradead.org>
References: <200801291316.m0TDGivY024953@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@computergmbh.de>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, varevoka@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:44345 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737AbYBSNtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 08:49:17 -0500
In-Reply-To: <200801291316.m0TDGivY024953@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-01-29 at 13:16 +0000, Linux Kernel Mailing List wrote:
> Commit:     643a2c15a407faf08101a20e1a3461160711899d
>
>     [NETFILTER]: Introduce nf_inet_address
>     
>     A few netfilter modules provide their own union of IPv4 and IPv6
>     address storage. Will unify that in this patch series.
>     
>     (1/4): Rename union nf_conntrack_address to union nf_inet_addr and
>     move it to x_tables.h.
>     
>     Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

 ...

> --- a/include/linux/netfilter.h
> +++ b/include/linux/netfilter.h
> @@ -48,6 +48,12 @@ enum nf_inet_hooks {
>  	NF_INET_NUMHOOKS
>  };
>  
> +union nf_inet_addr {
> +	u_int32_t	all[4];
> +	__be32		ip;
> +	__be32		ip6[4];
> +};
> +
>  #ifdef __KERNEL__
>  #ifdef CONFIG_NETFILTER

This breaks the busybox build:

CC      ipsvd/tcpudp.o
In file included from /usr/include/linux/netfilter_ipv4.h:8,
                 from ipsvd/tcpudp.c:33:
/usr/include/linux/netfilter.h:40: error: expected specifier-qualifier-list before 'u_int32_t'

What is this 'u_int32_t' nonsense anyway?

If a user-visible header is likely to be included by libc directly from
a 'standard' header, it may not require <stdint.h>. Therefore it should
use the system-specific types such as '__u32'.

If it isn't likely to be included by libc, which is the case for
netfilter, then it might as well just use the proper C types. Those who
are stuck on C89 or earlier might still prefer to use '__u32' even when
there's no need for it, but 'u_int32_t' is just silly. I suspect we
should eradicate it. I couldn't make busybox work with it --
__BIT_TYPES_DEFINED__ is defined in <sys/types.h> and prevents the
definitions of u_int32_t et al from appearing in <linux/types.h>. And if
I include <linux/types.h> first, other things break.

A later commit adds struct in_addr and struct in6_addr to this union
too, which breaks busybox even harder.

How is this supposed to be used in userspace? Or is it even supposed to
be exposed?

-- 
dwmw2

