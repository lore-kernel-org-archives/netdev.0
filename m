From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Subject: Re: [PATCH] tcp-illinois: incorrect beta usage
Date: Wed, 28 Nov 2007 16:25:35 -0800
Message-ID: <aa7d2c6d0711281625m44bf3ca3me188a7041d3421da@mail.gmail.com>
References: <aa7d2c6d0711261023m3d2dd850o76a8f44aef022f39@mail.gmail.com>
	 <001001c83063$9adbc9d0$d5897e82@csp.uiuc.edu>
	 <20071128154725.29af2852@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Herbert Xu" <herbert@gondor.apana.org.au>, shaoliu@princeton.edu,
	"Douglas Leith" <doug.leith@nuim.ie>,
	"Robert Shorten" <robert.shorten@nuim.ie>, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.234]:3543 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112AbXK2AZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 19:25:37 -0500
Received: by nz-out-0506.google.com with SMTP id s18so1270186nze
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2007 16:25:36 -0800 (PST)
In-Reply-To: <20071128154725.29af2852@freepuppy.rosehill>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Stephen.

A related problem (largely due to the published algorithm itself) is
that Illinois is very aggressive when it over-estimates the maximum
RTT.

At high load (say 200Mbps and 200ms RTT), a backlog of packets builds
up just after a loss, causing the RTT estimate to become large.  This
makes Illinois think that *all* losses are due to corruption not
congestion, and so only back off by 1/8 instead of 1/2.

I can't think how to fix this except by better RTT estimation, or
changes to Illinois itself.  Currently, I ignore RTT measurements when
   sacked_out != 0    and have a heuristic "RTT aging" mechanism, but
that's pretty ugly.

Cheers,
Lachlan

On 28/11/2007, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> Lachlan Andrew observed that my TCP-Illinois implementation uses the
> beta value incorrectly:
>   The parameter  beta  in the paper specifies the amount to decrease
>   *by*:  that is, on loss,
>      W <-  W -  beta*W
>   but in   tcp_illinois_ssthresh() uses  beta  as the amount
>   to decrease  *to*: W <- beta*W
>
> This bug makes the Linux TCP-Illinois get less-aggressive on uncongested network,
> hurting performance. Note: since the base beta value is .5, it has no
> impact on a congested network.
>
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>
> --- a/net/ipv4/tcp_illinois.c   2007-08-18 07:50:15.000000000 -0700
> +++ b/net/ipv4/tcp_illinois.c   2007-11-28 15:39:04.000000000 -0800
> @@ -298,7 +298,7 @@ static u32 tcp_illinois_ssthresh(struct
>         struct illinois *ca = inet_csk_ca(sk);
>
>         /* Multiplicative decrease */
> -       return max((tp->snd_cwnd * ca->beta) >> BETA_SHIFT, 2U);
> +       return max(tp->snd_cwnd - ((tp->snd_cwnd * ca->beta) >> BETA_SHIFT), 2U);
>  }
>
>
>


-- 
Lachlan Andrew  Dept of Computer Science, Caltech
1200 E California Blvd, Mail Code 256-80, Pasadena CA 91125, USA
Ph: +1 (626) 395-8820    Fax: +1 (626) 568-3603
http://netlab.caltech.edu/~lachlan
