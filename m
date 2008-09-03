From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH RESEND] ipv6: return with appropriate error code when
 sending RH0 using setsockopt()
Date: Wed, 03 Sep 2008 14:36:46 -0400
Message-ID: <48BED93E.2000204@hp.com>
References: <48BE4DA2.20800@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:25894 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679AbYICSgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 14:36:49 -0400
In-Reply-To: <48BE4DA2.20800@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shan Wei wrote:
>  I'm sorry to resend the patch, for that no one replied it from Jun 27.
> 
>  The kernel had removed the RH0(Type 0 Routing Header), but we can still
>  send IPv6 packet with RH0 using sendmsg() or setsockopt().
> 
>  Compare with sendmsg() that returns EINVAL, but setsockopt() return EPERM.
>  The patch fix it.
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---
>  net/ipv6/ipv6_sockglue.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index 4e5eac3..7a58597 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -353,9 +353,10 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
>  			goto e_inval;
>  
>  		/* hop-by-hop / destination options are privileged option */
> -		retv = -EPERM;
> -		if (optname != IPV6_RTHDR && !capable(CAP_NET_RAW))
> +		if (optname != IPV6_RTHDR && !capable(CAP_NET_RAW)) {
> +			retv = -EPERM;
>  			break;
> +		}

I'm not sure you need this since it doesn't actually change anything,
setting the error before the check just seems like the style in this
function.  It will get set to -EINVAL below...

> @@ -365,6 +366,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
>  			break;
>  		}
>  
> +		retv = -EINVAL;
>  		/* routing header option needs extra check */
>  		if (optname == IPV6_RTHDR && opt && opt->srcrt) {
>  			struct ipv6_rt_hdr *rthdr = opt->srcrt;

This seems correct as trying to set an unsupported routing header type
is invalid, or trying to set a Type 2 that itself is invalid is bad.
The Unix I checked does this.

There's actually another bug here and in the sendmsg() path in that you
can set the hdrlen and segments_left fields to be invalid (according to
RFC3775), as long as the math works out (segments * 2 == length).
Segments_left should always be 1 and hdrlen 2 for a Type2 routing
header.  The packet should be dropped at the destination, but we
probably shouldn't send it.  I can send a patch for that later.

-Brian
