From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ss: Fix allocation of cong control alg name
Date: Fri, 29 May 2015 15:53:48 +0300
Message-ID: <20150529125348.GA17571@angus-think.wlc.globallogic.com>
References: <1432895400-12266-1-git-send-email-vadim4j@gmail.com>
 <1432897445.7456.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:36650 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755253AbbE2Myt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 08:54:49 -0400
Received: by lagv1 with SMTP id v1so54972117lag.3
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 05:54:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1432897445.7456.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2015 at 04:04:05AM -0700, Eric Dumazet wrote:
> On Fri, 2015-05-29 at 13:30 +0300, Vadim Kochan wrote:
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > Use strdup instead of malloc, and get rid of bad strcpy.
> > 
> > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> > ---
> >  misc/ss.c | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > diff --git a/misc/ss.c b/misc/ss.c
> > index 347e3a1..a719466 100644
> > --- a/misc/ss.c
> > +++ b/misc/ss.c
> > @@ -1908,8 +1908,7 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
> >  
> >  		if (tb[INET_DIAG_CONG]) {
> >  			const char *cong_attr = rta_getattr_str(tb[INET_DIAG_CONG]);
> > -			s.cong_alg = malloc(strlen(cong_attr + 1));
> > -			strcpy(s.cong_alg, cong_attr);
> > +			s.cong_alg = strdup(cong_attr);
> >  		}
> >  
> >  		if (TCPI_HAS_OPT(info, TCPI_OPT_WSCALE)) {
> 
> I doubt TCP_CA_NAME_MAX will ever change in the kernel : 16 bytes.
> 
> Its typically "cubic" and less than 8 bytes.
> 
> Using 8 bytes to point to a malloc(8) is a waste.
> 
> Please remove the memory allocation, or store the pointer, since
> tcp_show_info() does the malloc()/free() before return.
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index 347e3a1..9fe229f 100644
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
> @@ -1906,11 +1906,10 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
>  			s.has_fastopen_opt = TCPI_HAS_OPT(info, TCPI_OPT_SYN_DATA);
>  		}
>  
> -		if (tb[INET_DIAG_CONG]) {
> -			const char *cong_attr = rta_getattr_str(tb[INET_DIAG_CONG]);
> -			s.cong_alg = malloc(strlen(cong_attr + 1));
> -			strcpy(s.cong_alg, cong_attr);
> -		}
> +		if (tb[INET_DIAG_CONG])
> +			strncpy(s.cong_alg,
> +				rta_getattr_str(tb[INET_DIAG_CONG]),
> +				sizeof(s.cong_alg) - 1);
>  
>  		if (TCPI_HAS_OPT(info, TCPI_OPT_WSCALE)) {
>  			s.has_wscale_opt  = true;
> @@ -1984,8 +1983,6 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
>  		tcp_stats_print(&s);
>  		if (s.dctcp)
>  			free(s.dctcp);
> -		if (s.cong_alg)
> -			free(s.cong_alg);
>  	}
>  }
>  
> 
> 

Thanks!

Should I put you in "From" tag or in "Signed-off-by" ?
Or your diff might be used from this email thread ?
