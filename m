From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 1/2] iplink_geneve: add ttl configuration at link creation
Date: Mon, 15 Jun 2015 14:38:46 -0400
Message-ID: <20150615183845.GF16684@tuxdriver.com>
References: <1432320406-28121-1-git-send-email-linville@tuxdriver.com>
 <1434393436-4487-1-git-send-email-linville@tuxdriver.com>
 <1434393436-4487-2-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52699 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755211AbbFOSpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 14:45:10 -0400
Content-Disposition: inline
In-Reply-To: <1434393436-4487-2-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2015 at 02:37:15PM -0400, John W. Linville wrote:
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
>  include/linux/if_link.h |  1 +

This includes the include/linux/if_link.h bits, that will need to be
dropped after iproute2 does the 4.1 update for that file.

>  ip/iplink_geneve.c      | 23 ++++++++++++++++++++++-
>  man/man8/ip-link.8.in   |  7 +++++++
>  3 files changed, 30 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index 7720ad34c6b3..2b5268531bef 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -393,6 +393,7 @@ enum {
>  	IFLA_GENEVE_UNSPEC,
>  	IFLA_GENEVE_ID,
>  	IFLA_GENEVE_REMOTE,
> +	IFLA_GENEVE_TTL,
>  	__IFLA_GENEVE_MAX
>  };
>  #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
> diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
> index 74703e1ee156..dff08a62d9a9 100644
> --- a/ip/iplink_geneve.c
> +++ b/ip/iplink_geneve.c
> @@ -17,9 +17,11 @@
>  static void print_explain(FILE *f)
>  {
>  	fprintf(f, "Usage: ... geneve id VNI remote ADDR\n");
> +	fprintf(f, "                 [ ttl TTL ]\n");
>  	fprintf(f, "\n");
>  	fprintf(f, "Where: VNI  := 0-16777215\n");
>  	fprintf(f, "       ADDR := IP_ADDRESS\n");
> +	fprintf(f, "       TTL  := { 1..255 | inherit }\n");
>  }
>  
>  static void explain(void)
> @@ -34,7 +36,7 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
>  	int vni_set = 0;
>  	__u32 daddr = 0;
>  	struct in6_addr daddr6 = IN6ADDR_ANY_INIT;
> -
> +	__u8 ttl = 0;
>  
>  	while (argc > 0) {
>  		if (!matches(*argv, "id") ||
> @@ -52,6 +54,18 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
>  			}
>  			if (IN_MULTICAST(ntohl(daddr)))
>  				invarg("invalid remote address", *argv);
> +		} else if (!matches(*argv, "ttl") ||
> +			   !matches(*argv, "hoplimit")) {
> +			unsigned uval;
> +
> +			NEXT_ARG();
> +			if (strcmp(*argv, "inherit") != 0) {
> +				if (get_unsigned(&uval, *argv, 0))
> +					invarg("invalid TTL", *argv);
> +				if (uval > 255)
> +					invarg("TTL must be <= 255", *argv);
> +				ttl = uval;
> +			}
>  		} else if (matches(*argv, "help") == 0) {
>  			explain();
>  			return -1;
> @@ -80,6 +94,7 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
>  	addattr32(n, 1024, IFLA_GENEVE_ID, vni);
>  	if (daddr)
>  		addattr_l(n, 1024, IFLA_GENEVE_REMOTE, &daddr, 4);
> +	addattr8(n, 1024, IFLA_GENEVE_TTL, ttl);
>  
>  	return 0;
>  }
> @@ -105,6 +120,12 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
>  			fprintf(f, "remote %s ",
>  				format_host(AF_INET, 4, &addr, s1, sizeof(s1)));
>  	}
> +
> +	if (tb[IFLA_GENEVE_TTL]) {
> +		__u8 ttl = rta_getattr_u8(tb[IFLA_GENEVE_TTL]);
> +		if (ttl)
> +			fprintf(f, "ttl %d ", ttl);
> +	}
>  }
>  
>  static void geneve_print_help(struct link_util *lu, int argc, char **argv,
> diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
> index 8cac246d7296..51d0c624a023 100644
> --- a/man/man8/ip-link.8.in
> +++ b/man/man8/ip-link.8.in
> @@ -606,6 +606,9 @@ the following additional arguments are supported:
>  
>  .BI "ip link add " DEVICE
>  .BI type " geneve " id " ID " remote " IPADDR"
> +.R " [ "
> +.BI ttl " TTL "
> +.R " ]"
>  
>  .in +8
>  .sp
> @@ -616,6 +619,10 @@ the following additional arguments are supported:
>  .BI remote " IPADDR"
>  - specifies the unicast destination IP address to use in outgoing packets.
>  
> +.sp
> +.BI ttl " TTL"
> +- specifies the TTL value to use in outgoing packets.
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
