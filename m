From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v2] ss: Enclose IPv6 address in brackets
Date: Mon, 31 Jul 2017 22:27:42 +0200
Message-ID: <20170731202742.GX16375@orbyte.nwl.cc>
References: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
 <182a039f-5e8f-3c37-a32b-ae4562c57c1c@der-flo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Florian Lehner <dev@der-flo.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48855 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751106AbdGaU1n (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 16:27:43 -0400
Content-Disposition: inline
In-Reply-To: <182a039f-5e8f-3c37-a32b-ae4562c57c1c@der-flo.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 09:50:04PM +0200, Florian Lehner wrote:
> This updated patch adds support for RFC2732 IPv6 address format with
> brackets for the tool ss. Resolved hostnames will not be enclosed in
> brackets, therefore the global variable resolve_hosts is initialized and
> checked.
> 
> Signed-off-by: Lehner Florian <dev@der-flo.net>
> ---
>  misc/ss.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index 12763c9..ac94537 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -88,7 +88,7 @@ static int security_get_initial_context(char *name,
> char **context)
>  }
>  #endif
> 
> -int resolve_hosts;
> +int resolve_hosts = 0;

Global variables are guaranteed to be initialized to zero. According to
the web this is by C89.

>  int resolve_services = 1;
>  int preferred_family = AF_UNSPEC;
>  int show_options;
> @@ -1059,7 +1059,11 @@ static void inet_addr_print(const inet_prefix *a,
> int port, unsigned int ifindex
>  			ap = format_host(AF_INET, 4, a->data);
>  		}
>  	} else {
> -		ap = format_host(a->family, 16, a->data);
> +		if (a->family == AF_INET6 && !resolve_hosts) {
> +			sprintf(buf, "[%s]", format_host(a->family, 16, a->data));
> +		} else {
> +			ap = format_host(a->family, 16, a->data);
> +		}
>  		est_len = strlen(ap);
>  		if (est_len <= addr_width)
>  			est_len = addr_width;

This won't work if name resolution was requested but failed. In that
case an IPv6 address is returned but not enclosed in brackets.

Cheers, Phil
