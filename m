From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH] ss: Enclose IPv6 address in brackets
Date: Mon, 31 Jul 2017 12:30:10 +0200
Message-ID: <20170731103010.GU16375@orbyte.nwl.cc>
References: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>
To: Florian Lehner <dev@der-flo.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35105 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750810AbdGaKaM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 06:30:12 -0400
Content-Disposition: inline
In-Reply-To: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 29, 2017 at 02:29:10PM +0200, Florian Lehner wrote:
> This patch adds support for RFC2732 IPv6 address format with brackets
> for the tool ss. So output for ss changes from
> 2a00:1450:400a:804::200e:443 to [2a00:1450:400a:804::200e]:443 for IPv6
> addresses with attached port number.
> 
> Signed-off-by: Lehner Florian <dev@der-flo.net>
> ---
>  misc/ss.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index 12763c9..db39c93 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -1059,7 +1059,11 @@ static void inet_addr_print(const inet_prefix *a,
> int port, unsigned int ifindex
>  			ap = format_host(AF_INET, 4, a->data);
>  		}
>  	} else {
> -		ap = format_host(a->family, 16, a->data);
> +		if (a->family == AF_INET6) {
> +			sprintf(buf, "[%s]", format_host(a->family, 16, a->data));
> +		} else {
> +			ap = format_host(a->family, 16, a->data);
> +		}
>  		est_len = strlen(ap);
>  		if (est_len <= addr_width)
>  			est_len = addr_width;

Note that this will enclosed resolved hostnames in brackets as well, not
sure if that's intended. Looks like fixing that is not exactly trivial:
Hostname resolution is buried in format_host() which resides in
lib/utils.c so is shared code with ip, tc, etc. Hence, adding the
brackets in rt_addr_n2a_r() is not an option, either. Adding a 'bool *'
param to format_host() and format_host_r() indicating that name
resolution has happened might help here.

Cheers, Phil
