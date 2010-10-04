From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] sysctl: fix min/max handling in
 __do_proc_doulongvec_minmax()
Date: Mon, 4 Oct 2010 03:59:13 -0500
Message-ID: <20101004085913.GR14068@sgi.com>
References: <1286025469.2582.1806.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Robin Holt <holt@sgi.com>, Willy Tarreau <w@1wt.eu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:44307 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753630Ab0JDI7S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 04:59:18 -0400
Content-Disposition: inline
In-Reply-To: <1286025469.2582.1806.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 02, 2010 at 03:17:49PM +0200, Eric Dumazet wrote:
> When proc_doulongvec_minmax() is used with an array of longs,
> and no min/max check requested (.extra1 or .extra2 being NULL), we
> dereference a NULL pointer for the second element of the array.
> 
> Noticed while doing some changes in network stack for the "16TB problem"
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  kernel/sysctl.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index f88552c..4fba86d 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -2500,7 +2500,8 @@ static int __do_proc_doulongvec_minmax(void *data, struct ctl_table *table, int
>  				break;
>  			if (neg)
>  				continue;
> -			if ((min && val < *min) || (max && val > *max))
> +			if ((table->extra1 && val < *min) ||
> +			    (table->extra2 && val > *max))

How about changing:
        for (; left && vleft--; i++, min++, max++, first=0) {
into:
        for (; left && vleft--; i++, min = min ? min + 1 : NULL, max = max ? max + 1: NULL, first=0) {

That would make min and max correct and reduce the chances somebody in
the future overlooks the fact they are currently filled with garbage.

Robin
