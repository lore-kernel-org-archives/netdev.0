From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] gre: add support for ERSPAN tunnel
Date: Wed, 9 Aug 2017 14:21:11 -0700
Message-ID: <20170809142111.79ce85ce@xeon-e3>
References: <1502310882-8802-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35548 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751890AbdHIVVT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 17:21:19 -0400
Received: by mail-pg0-f50.google.com with SMTP id v189so32880798pgd.2
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 14:21:19 -0700 (PDT)
In-Reply-To: <1502310882-8802-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  9 Aug 2017 13:34:42 -0700
William Tu <u9012063@gmail.com> wrote:

> The patch adds ERSPAN type II tunnel support.  The implementation
> is based on the draft at https://tools.ietf.org/html/draft-foschiano-erspan-01
> One of the purposes is for Linux box to be able to receive ERSPAN
> monitoring traffic sent from the Cisco switch, by creating a ERSPAN
> tunnel device.  In addition, the patch also adds ERSPAN TX, so traffic
> can also be encapsulated into ERSPAN and sent out.
> 
> The implementation reuses the key as ERSPAN session ID, and
> field 'erspan' as ERSPAN Index fields:
> ./ip link add dev ers11 type erspan seq key 100 erspan 123 \
> 		local 172.16.1.200 remote 172.16.1.100
> 
> Signed-off-by: William Tu <u9012063@gmail.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> ---
>  include/linux/if_tunnel.h |  1 +
>  ip/link_gre.c             | 26 +++++++++++++++++++++++++-
>  2 files changed, 26 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
> index 7375335a0773..21834cac4c0d 100644
> --- a/include/linux/if_tunnel.h
> +++ b/include/linux/if_tunnel.h
> @@ -134,6 +134,7 @@ enum {
>  	IFLA_GRE_COLLECT_METADATA,
>  	IFLA_GRE_IGNORE_DF,
>  	IFLA_GRE_FWMARK,
> +	IFLA_GRE_ERSPAN_INDEX,
>  	__IFLA_GRE_MAX,
>  };
>  
> diff --git a/ip/link_gre.c b/ip/link_gre.c
> index c2ec5f26902f..c28fac1eb5de 100644
> --- a/ip/link_gre.c
> +++ b/ip/link_gre.c
> @@ -26,7 +26,7 @@
>  static void print_usage(FILE *f)
>  {
>  	fprintf(f,
> -		"Usage: ... { gre | gretap } [ remote ADDR ]\n"
> +		"Usage: ... { gre | gretap | erspan } [ remote ADDR ]\n"
>  		"                            [ local ADDR ]\n"
>  		"                            [ [i|o]seq ]\n"
>  		"                            [ [i|o]key KEY ]\n"
> @@ -44,6 +44,7 @@ static void print_usage(FILE *f)
>  		"                            [ [no]encap-csum6 ]\n"
>  		"                            [ [no]encap-remcsum ]\n"
>  		"                            [ fwmark MARK ]\n"
> +		"                            [ erspan IDX ]\n"
>  		"\n"
>  		"Where: ADDR := { IP_ADDRESS | any }\n"
>  		"       TOS  := { NUMBER | inherit }\n"
> @@ -96,6 +97,7 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
>  	__u8 metadata = 0;
>  	__u8 ignore_df = 0;
>  	__u32 fwmark = 0;
> +	__u32 erspan_idx = 0;
>  
>  	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
>  		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
> @@ -172,6 +174,9 @@ get_failed:
>  
>  		if (greinfo[IFLA_GRE_FWMARK])
>  			fwmark = rta_getattr_u32(greinfo[IFLA_GRE_FWMARK]);
> +
> +		if (greinfo[IFLA_GRE_ERSPAN_INDEX])
> +			erspan_idx = rta_getattr_u32(greinfo[IFLA_GRE_ERSPAN_INDEX]);
>  	}
>  
>  	while (argc > 0) {
> @@ -328,6 +333,10 @@ get_failed:
>  			NEXT_ARG();
>  			if (get_u32(&fwmark, *argv, 0))
>  				invarg("invalid fwmark\n", *argv);
> +		} else if (strcmp(*argv, "erspan") == 0) {
> +			NEXT_ARG();
> +			if (get_u32(&erspan_idx, *argv, 0))
> +				invarg("invalid erspan index\n", *argv);
>  		} else
>  			usage();
>  		argc--; argv++;
> @@ -359,6 +368,7 @@ get_failed:
>  		addattr_l(n, 1024, IFLA_GRE_TTL, &ttl, 1);
>  		addattr_l(n, 1024, IFLA_GRE_TOS, &tos, 1);
>  		addattr32(n, 1024, IFLA_GRE_FWMARK, fwmark);
> +		addattr32(n, 1024, IFLA_GRE_ERSPAN_INDEX, htonl(erspan_idx));

If erspan_idx is zero, then you probably shouldn't send it to kernel.

Also you need to update manual pages.
