From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 2/2] iplink_geneve: add tos configuration at link creation
Date: Mon, 15 Jun 2015 14:39:00 -0400
Message-ID: <20150615183859.GG16684@tuxdriver.com>
References: <1432320406-28121-1-git-send-email-linville@tuxdriver.com>
 <1434393436-4487-1-git-send-email-linville@tuxdriver.com>
 <1434393436-4487-3-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52698 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754559AbbFOSpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 14:45:10 -0400
Content-Disposition: inline
In-Reply-To: <1434393436-4487-3-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2015 at 02:37:16PM -0400, John W. Linville wrote:
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
>  include/linux/if_link.h |  1 +

This includes the include/linux/if_link.h bits, that will need to be
dropped after iproute2 does the 4.1 update for that file.

>  ip/iplink_geneve.c      | 26 +++++++++++++++++++++++++-
>  man/man8/ip-link.8.in   |  6 ++++++
>  3 files changed, 32 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index 2b5268531bef..59b987407533 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -394,6 +394,7 @@ enum {
>  	IFLA_GENEVE_ID,
>  	IFLA_GENEVE_REMOTE,
>  	IFLA_GENEVE_TTL,
> +	IFLA_GENEVE_TOS,
>  	__IFLA_GENEVE_MAX
>  };
>  #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
> diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
> index dff08a62d9a9..331240a6a3d9 100644
> --- a/ip/iplink_geneve.c
> +++ b/ip/iplink_geneve.c
> @@ -11,16 +11,18 @@
>  
>  #include <stdio.h>
>  
> +#include "rt_names.h"
>  #include "utils.h"
>  #include "ip_common.h"
>  
>  static void print_explain(FILE *f)
>  {
>  	fprintf(f, "Usage: ... geneve id VNI remote ADDR\n");
> -	fprintf(f, "                 [ ttl TTL ]\n");
> +	fprintf(f, "                 [ ttl TTL ] [ tos TOS ]\n");
>  	fprintf(f, "\n");
>  	fprintf(f, "Where: VNI  := 0-16777215\n");
>  	fprintf(f, "       ADDR := IP_ADDRESS\n");
> +	fprintf(f, "       TOS  := { NUMBER | inherit }\n");
>  	fprintf(f, "       TTL  := { 1..255 | inherit }\n");
>  }
>  
> @@ -37,6 +39,7 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
>  	__u32 daddr = 0;
>  	struct in6_addr daddr6 = IN6ADDR_ANY_INIT;
>  	__u8 ttl = 0;
> +	__u8 tos = 0;
>  
>  	while (argc > 0) {
>  		if (!matches(*argv, "id") ||
> @@ -66,6 +69,17 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
>  					invarg("TTL must be <= 255", *argv);
>  				ttl = uval;
>  			}
> +		} else if (!matches(*argv, "tos") ||
> +			   !matches(*argv, "dsfield")) {
> +			__u32 uval;
> +
> +			NEXT_ARG();
> +			if (strcmp(*argv, "inherit") != 0) {
> +				if (rtnl_dsfield_a2n(&uval, *argv))
> +					invarg("bad TOS value", *argv);
> +				tos = uval;
> +			} else
> +				tos = 1;
>  		} else if (matches(*argv, "help") == 0) {
>  			explain();
>  			return -1;
> @@ -95,6 +109,7 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
>  	if (daddr)
>  		addattr_l(n, 1024, IFLA_GENEVE_REMOTE, &daddr, 4);
>  	addattr8(n, 1024, IFLA_GENEVE_TTL, ttl);
> +	addattr8(n, 1024, IFLA_GENEVE_TOS, tos);
>  
>  	return 0;
>  }
> @@ -103,6 +118,7 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
>  {
>  	__u32 vni;
>  	char s1[1024];
> +	__u8 tos;
>  
>  	if (!tb)
>  		return;
> @@ -126,6 +142,14 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
>  		if (ttl)
>  			fprintf(f, "ttl %d ", ttl);
>  	}
> +
> +	if (tb[IFLA_GENEVE_TOS] &&
> +	    (tos = rta_getattr_u8(tb[IFLA_GENEVE_TOS]))) {
> +		if (tos == 1)
> +			fprintf(f, "tos inherit ");
> +		else
> +			fprintf(f, "tos %#x ", tos);
> +	}
>  }
>  
>  static void geneve_print_help(struct link_util *lu, int argc, char **argv,
> diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
> index 51d0c624a023..372e6c6faf29 100644
> --- a/man/man8/ip-link.8.in
> +++ b/man/man8/ip-link.8.in
> @@ -608,6 +608,8 @@ the following additional arguments are supported:
>  .BI type " geneve " id " ID " remote " IPADDR"
>  .R " [ "
>  .BI ttl " TTL "
> +.R " ] [ "
> +.BI tos " TOS "
>  .R " ]"
>  
>  .in +8
> @@ -623,6 +625,10 @@ the following additional arguments are supported:
>  .BI ttl " TTL"
>  - specifies the TTL value to use in outgoing packets.
>  
> +.sp
> +.BI tos " TOS"
> +- specifies the TOS value to use in outgoing packets.
> +
>  .in -8
>  
>  .SS ip link delete - delete virtual link
> -- 
> 2.1.0
> 
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
