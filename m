From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Kernel header changes break glibc build
Date: Sun, 03 Dec 2006 12:25:31 +0000
Message-ID: <1165148731.12649.51.camel@pmac.infradead.org>
References: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org,
	Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:63669 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1759627AbWLCMZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 07:25:36 -0500
To: "Joseph S. Myers" <joseph@codesourcery.com>
In-Reply-To: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-10-06 at 17:20 +0000, Joseph S. Myers wrote:
> The kernel headers installed by Linux 2.6.19-rc1 "make
> headers_install" do not work for building glibc, because glibc expects
> <linux/rtnetlink.h> to provide various definitions, some of which have
> been moved to <linux/if_addr.h> and some of which have been removed
> altogether.
> 
> This kernel patch allows glibc to build again by making rtnetlink.h
> include if_addr.h and adding back the removed definitions required by
> glibc, but I don't know if it's the correct approach or if glibc
> should change the headers it includes and add its own macro
> definitions.
> 
> Signed-off-by: Joseph Myers <joseph@codesourcery.com>

Since it was Thomas Graf who made these changes and David Miller who
committed them, you'd do well to Cc both of those people.

Sorry for the delayed response on my part -- I've been away
concentrating on OLPC stuff, and just about everything else has fallen
by the wayside.

Thomas, this is in response to your changes in
http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=1823730fbc89fadde72a7bb3b7bdf03cc7b8835c;hp=47f68512d2685431f1781830dfcbab31bda87644
in which you create <linux/if_addr.h> and require that it's included
directly rather than being part of (or even included from)
<linux/rtnetlink.h>. Was there a good reason for changing that
user-visible header? Is there a reason not to include if_addr.h from
rtnetlink.h as Joseph's patch does?

I suspect that if the IF{L,}A_{PAYLOAD,RTA} macros aren't used in the
kernel then the best answer is for glibc to define those for itself.

> ---
> Index: include/linux/rtnetlink.h
> ===================================================================
> --- include/linux/rtnetlink.h
> +++ include/linux/rtnetlink.h
> @@ -2,6 +2,7 @@
>  #define __LINUX_RTNETLINK_H
>  
>  #include <linux/netlink.h>
> +#include <linux/if_addr.h>
>  #include <linux/if_link.h>
>  
>  /****
> Index: include/linux/if_link.h
> ===================================================================
> --- include/linux/if_link.h
> +++ include/linux/if_link.h
> @@ -82,6 +82,9 @@
>  
>  #define IFLA_MAX (__IFLA_MAX - 1)
>  
> +#define IFLA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
> +#define IFLA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
> +
>  /* ifi_flags.
>  
>     IFF_* flags.
> Index: include/linux/if_addr.h
> ===================================================================
> --- include/linux/if_addr.h
> +++ include/linux/if_addr.h
> @@ -52,4 +52,7 @@
>  	__u32	tstamp; /* updated timestamp, hundredths of seconds */
>  };
>  
> +#define IFA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifaddrmsg))))
> +#define IFA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifaddrmsg))
> +
>  #endif
> 
> 
> 
-- 
dwmw2

