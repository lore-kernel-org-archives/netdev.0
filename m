From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] cipso: subtraction on unsigned hdr_delta
Date: Wed, 4 Mar 2009 12:25:01 -0500
Message-ID: <200903041225.01858.paul.moore@hp.com>
References: <49ADADEA.8090306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:17877 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753421AbZCDRZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 12:25:08 -0500
In-Reply-To: <49ADADEA.8090306@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 03 March 2009 05:23:38 pm Roel Kluin wrote:
> hdr_delta is unsigned, so take care not to subtract below 0.
>
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
> index 7bc9929..b1d862b 100644
> --- a/net/ipv4/cipso_ipv4.c
> +++ b/net/ipv4/cipso_ipv4.c
> @@ -1999,7 +1999,11 @@ void cipso_v4_sock_delattr(struct sock *sk)
>  				iter++;
>  		hdr_delta = opt->optlen;
>  		opt->optlen = (optlen_new + 3) & ~3;
> -		hdr_delta -= opt->optlen;
> +
> +		if (hdr_delta > opt->optlen)
> +			hdr_delta -= opt->optlen;
> +		else
> +			hdr_delta = 0;
>  	} else {
>  		/* only the cipso option was present on the socket so we can
>  		 * remove the entire option struct */

This patch isn't needed since I can't think of any sane reason why the 
hdr_delta subtraction would ever cause an error.  Similarly, I don't think 
David's concerns over the icsk_ext_hdr_len adjustment necessarily apply here 
either.  Let me try and explain, feel free to point out faults in my logic ...

This function, cipso_v4_sock_delattr(), is only used _to_ remove the CIPSO IP 
option from a socket, never to add it.  In the code snippet above we see the 
following three lines:

	hdr_delta = opt->optlen;
	opt->optlen = (optlen_new + 3) & ~3;
	hdr_delta -= opt->optlen;

The first line sets hdr_delta equal to length of the original IP option list 
(length includes the CIPSO option).  The second line calculates the new length 
of the IP option list (without the CIPSO option), complete with padding.  The 
third line subtracts the new option length from hdr_delta which is currently 
equal to original option length.  The only way that hdr_delta could ever be in 
danger of going negative would be if the removal of the CIPSO IP option caused 
the total IP option length to somehow increase; I just can't think how that 
would be possible.

-- 
paul moore
linux @ hp

