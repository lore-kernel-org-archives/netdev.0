From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCHv2] ipv4: Do not cache routing failures due to disabled
 forwarding.
Date: Thu, 18 Sep 2014 08:17:08 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1409180749570.4152@ja.home.ssi.bg>
References: <54143FB2.9000600@green-communications.fr> <1410776893-5284-1-git-send-email-nicolas.cavallari@green-communications.fr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51566 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751090AbaIRFSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 01:18:05 -0400
In-Reply-To: <1410776893-5284-1-git-send-email-nicolas.cavallari@green-communications.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 15 Sep 2014, Nicolas Cavallari wrote:

> If we cache them, the kernel will reuse them, independently of
> whether forwarding is enabled or not.  Which means that if forwarding is
> disabled on the input interface where the first routing request comes
> from, then that unreachable result will be cached and reused for
> other interfaces, even if forwarding is enabled on them.
> 
> This can be verified with two interfaces A and B and an output interface
> C, where B has forwarding enabled, but not A and trying
> ip route get $dst iif A from $src && ip route get $dst iif B from $src
> 
> Signed-off-by: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>

	Looks good to me,

Reviewed-by: Julian Anastasov <ja@ssi.bg>

	Still, I fail to see how the compiler optimizes
the jump, 'goto local_input' still jumps to res.fi check.
I tried even likely() after 'local_input:" checks for
res.fi and !itag but the 'if (res.fi) {' block is still
moved below and reached with jnz. I expected likely() to
prefer the res.fi != NULL path.

> ---
> v2: simplify patch using julian anastasov's suggestion.
> 
>  net/ipv4/route.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 234a43e..b09fda8 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1798,6 +1798,7 @@ local_input:
>  no_route:
>  	RT_CACHE_STAT_INC(in_no_route);
>  	res.type = RTN_UNREACHABLE;
> +	res.fi = NULL;
>  	goto local_input;
>  
>  	/*
> -- 
> 2.1.0

Regards

--
Julian Anastasov <ja@ssi.bg>
