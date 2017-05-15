From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] ipv6: sr: fix user space compilation error with old
 glibc
Date: Mon, 15 May 2017 12:05:07 +0200
Message-ID: <59197D53.8030104@iogearbox.net>
References: <20170515091828.19349-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53309 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759124AbdEOKFK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 06:05:10 -0400
In-Reply-To: <20170515091828.19349-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2017 11:18 AM, David Lebrun wrote:
> When seg6.h is included in a user space program that also includes
> netinet/in.h, it results in multiple definitions of structures such as
> struct in6_addr. Recent glibc versions have a workaround that consists in
> defining __USE_KERNEL_IPV6_DEFS to prevent duplicates. However, such a
> program will fail to compile with older glibc versions.
>
> This patch ensures that including seg6.h will work in any case.
>
> Fixes: ea3ebc73b46fbdb049dafd47543bb22efaa09c8e ("uapi: fix linux/seg6.h and linux/seg6_iptunnel.h userspace compilation errors")
> Reported-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
> ---
>   include/uapi/linux/seg6.h | 9 +++++++++
>   1 file changed, 9 insertions(+)
>
> diff --git a/include/uapi/linux/seg6.h b/include/uapi/linux/seg6.h
> index 7278511..52b8f46 100644
> --- a/include/uapi/linux/seg6.h
> +++ b/include/uapi/linux/seg6.h
> @@ -15,7 +15,16 @@
>   #define _UAPI_LINUX_SEG6_H
>
>   #include <linux/types.h>
> +
> +#ifdef __KERNEL__
>   #include <linux/in6.h>		/* For struct in6_addr. */
> +#else
> +#ifdef __USE_KERNEL_IPV6_DEFS
> +#include <linux/in6.h>
> +#else
> +#include <netinet/in.h>
> +#endif
> +#endif
>
>   /*
>    * SRH
>

When this gets pulled into iproute2's include/linux/seg6.h due to
header rebase, we still have the same effect.

__USE_KERNEL_IPV6_DEFS gets defined by ip/iproute_lwtunnel.c, and
when we then include above header, we end up including linux/in6.h
just like before, same compile error in iproute2.

Or, is there still another fix for iproute2 coming after this has
landed?

Thanks,
Daniel

ip
     CC       iproute_lwtunnel.o
In file included from ../include/linux/seg6.h:23:0,
                  from iproute_lwtunnel.c:26:
../include/linux/in6.h:131:26: error: expected identifier before numeric constant
  #define IPPROTO_HOPOPTS  0 /* IPv6 hop-by-hop options */
                           ^
In file included from /usr/include/resolv.h:57:0,
                  from ../include/utils.h:6,
                  from iproute_lwtunnel.c:32:
/usr/include/netinet/in.h:196:8: error: redefinition of ‘struct in6_addr’
  struct in6_addr
         ^
In file included from ../include/linux/seg6.h:23:0,
                  from iproute_lwtunnel.c:26:
../include/linux/in6.h:32:8: note: originally defined here
  struct in6_addr {
         ^
In file included from /usr/include/resolv.h:57:0,
                  from ../include/utils.h:6,
                  from iproute_lwtunnel.c:32:
/usr/include/netinet/in.h:237:8: error: redefinition of ‘struct sockaddr_in6’
  struct sockaddr_in6
         ^
In file included from ../include/linux/seg6.h:23:0,
                  from iproute_lwtunnel.c:26:
../include/linux/in6.h:49:8: note: originally defined here
  struct sockaddr_in6 {
         ^
In file included from /usr/include/resolv.h:57:0,
                  from ../include/utils.h:6,
                  from iproute_lwtunnel.c:32:
/usr/include/netinet/in.h:273:8: error: redefinition of ‘struct ipv6_mreq’
  struct ipv6_mreq
         ^
In file included from ../include/linux/seg6.h:23:0,
                  from iproute_lwtunnel.c:26:
../include/linux/in6.h:59:8: note: originally defined here
  struct ipv6_mreq {
         ^
iproute_lwtunnel.c: In function ‘parse_encap_seg6’:
iproute_lwtunnel.c:375:3: warning: passing argument 3 of ‘inet_get_addr’ from incompatible pointer type [enabled by default]
    inet_get_addr(s, NULL, &srh->segments[i]);
    ^
In file included from iproute_lwtunnel.c:32:0:
../include/utils.h:241:5: note: expected ‘struct in6_addr *’ but argument is of type ‘struct in6_addr *’
  int inet_get_addr(const char *src, __u32 *dst, struct in6_addr *dst6);
      ^
make[1]: *** [iproute_lwtunnel.o] Error 1
make: *** [all] Error 2
