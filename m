From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] ss: Fix allocation of cong control alg name
Date: Fri, 29 May 2015 15:02:09 -0700
Message-ID: <20150529150209.07430666@urahara>
References: <1432922994-13735-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	daniel@iogearbox.net, jose.r.guzman.mosqueda@intel.com
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36475 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756904AbbE2WCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 18:02:07 -0400
Received: by pacux9 with SMTP id ux9so27566000pac.3
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 15:02:07 -0700 (PDT)
In-Reply-To: <1432922994-13735-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 May 2015 21:09:54 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Used 16 char array for cong alg name instead of malloc.
> 
> Fixes: 8250bc9ff4e5 ("ss: Unify inet sockets output")
> Reported-by: Jose R. Guzman Mosqueda <jose.r.guzman.mosqueda@intel.com>
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
> v2:
>    Used 16 byte array for cong alg name instead of malloc
>    	suggested by Eric Dumazet <eric.dumazet@gmail.com>
> 
>  misc/ss.c | 12 +++++-------
>  1 file changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index 347e3a1..0bab8a2 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -755,7 +755,7 @@ struct tcpstat
>  	int		    timer;
>  	int		    timeout;
>  	int		    probes;
> -	char		    *cong_alg;
> +	char		    cong_alg[16];
>  	double		    rto, ato, rtt, rttvar;
>  	int		    qack, cwnd, ssthresh, backoff;
>  	double		    send_bps;
> @@ -1664,7 +1664,7 @@ static void tcp_stats_print(struct tcpstat *s)
>  		printf(" ecnseen");
>  	if (s->has_fastopen_opt)
>  		printf(" fastopen");
> -	if (s->cong_alg)
> +	if (s->cong_alg[0])
>  		printf(" %s", s->cong_alg);
>  	if (s->has_wscale_opt)
>  		printf(" wscale:%d,%d", s->snd_wscale, s->rcv_wscale);
> @@ -1907,9 +1907,9 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
>  		}
>  
>  		if (tb[INET_DIAG_CONG]) {
> -			const char *cong_attr = rta_getattr_str(tb[INET_DIAG_CONG]);
> -			s.cong_alg = malloc(strlen(cong_attr + 1));
> -			strcpy(s.cong_alg, cong_attr);
> +			strncpy(s.cong_alg,
> +					rta_getattr_str(tb[INET_DIAG_CONG]),
> +					sizeof(s.cong_alg) - 1);
>  		}
>  
>  		if (TCPI_HAS_OPT(info, TCPI_OPT_WSCALE)) {
> @@ -1984,8 +1984,6 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
>  		tcp_stats_print(&s);
>  		if (s.dctcp)
>  			free(s.dctcp);
> -		if (s.cong_alg)
> -			free(s.cong_alg);
>  	}
>  }
>  

Why not use strdupa? I handles arbitrary size?
