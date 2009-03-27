From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: drop equalize support.
Date: Fri, 27 Mar 2009 11:29:47 -0700
Message-ID: <20090327112947.27a5ae7a@nehalam>
References: <20090314163735.GA9762@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36880 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751545AbZC0SaD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2009 14:30:03 -0400
In-Reply-To: <20090314163735.GA9762@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Mar 2009 17:37:35 +0100
Andreas Henriksson <andreas@fatal.se> wrote:

> Hello Stephen and netdev people!
> 
> Currently you can configure "equalize" and it looks all fine and dandy.
> The kernel has the interface defined, but apparently there's never actually
> been any implementation for it (only a never merged patch in the 2.4 era).
> 
> I'm suggesting to drop the code to give any potential users of this feature
> the benefit of receiving a proper error message. I see it unlikely that
> this will be implemented in the near future, but if it ever happens
> reviving the iproute2 side should be as easy as git revert this patch.
> 
> For more details see http://bugs.debian.org/149897
> 
> Regards, 
> Andreas Henriksson
> 
> 
> diff --git a/debian/rules b/debian/rules
> index 132455f..4d825ca 100755
> diff --git a/doc/ip-cref.tex b/doc/ip-cref.tex
> index bb4eb78..b333842 100644
> --- a/doc/ip-cref.tex
> +++ b/doc/ip-cref.tex
> @@ -1380,13 +1380,6 @@ database.
>  even if it does not match any interface prefix. One application of this
>  option may be found in~\cite{IP-TUNNELS}.
>  
> -\item \verb|equalize|
> -
> ---- allow packet by packet randomization on multipath routes.
> -Without this modifier, the route will be frozen to one selected
> -nexthop, so that load splitting will only occur on per-flow base.
> -\verb|equalize| only works if the kernel is patched.
> -
>  
>  \end{itemize}
>  
> diff --git a/ip/iproute.c b/ip/iproute.c
> index 6a2ea05..529159b 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -67,9 +67,9 @@ static void usage(void)
>  	fprintf(stderr, "NODE_SPEC := [ TYPE ] PREFIX [ tos TOS ]\n");
>  	fprintf(stderr, "             [ table TABLE_ID ] [ proto RTPROTO ]\n");
>  	fprintf(stderr, "             [ scope SCOPE ] [ metric METRIC ]\n");
> -	fprintf(stderr, "INFO_SPEC := NH OPTIONS FLAGS [ nexthop NH ]...\n");
> +	fprintf(stderr, "INFO_SPEC := NH OPTIONS [ nexthop NH ]...\n");
>  	fprintf(stderr, "NH := [ via ADDRESS ] [ dev STRING ] [ weight NUMBER ] NHFLAGS\n");
> -	fprintf(stderr, "OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ]\n");
> +	fprintf(stderr, "OPTIONS := [ mtu NUMBER ] [ advmss NUMBER ]\n");
>  	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ]\n");
>  	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
>  	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n");
> @@ -78,7 +78,6 @@ static void usage(void)
>  	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]\n");
>  	fprintf(stderr, "TABLE_ID := [ local | main | default | all | NUMBER ]\n");
>  	fprintf(stderr, "SCOPE := [ host | link | global | NUMBER ]\n");
> -	fprintf(stderr, "FLAGS := [ equalize ]\n");
>  	fprintf(stderr, "MP_ALGO := { rr | drr | random | wrandom }\n");
>  	fprintf(stderr, "NHFLAGS := [ onlink | pervasive ]\n");
>  	fprintf(stderr, "RTPROTO := [ kernel | boot | static | NUMBER ]\n");
> @@ -387,8 +386,6 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>  		fprintf(fp, "onlink ");
>  	if (r->rtm_flags & RTNH_F_PERVASIVE)
>  		fprintf(fp, "pervasive ");
> -	if (r->rtm_flags & RTM_F_EQUALIZE)
> -		fprintf(fp, "equalize ");
>  	if (r->rtm_flags & RTM_F_NOTIFY)
>  		fprintf(fp, "notify ");
>  
> @@ -428,9 +425,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>  		PRTFL(FAST, "fastroute");
>  		PRTFL(NOTIFY, "notify");
>  		PRTFL(TPROXY, "proxy");
> -#ifdef RTCF_EQUALIZE
> -		PRTFL(EQUALIZE, "equalize");
> -#endif
> +
>  		if (flags)
>  			fprintf(fp, "%s%x> ", first ? "<" : "", flags);
>  		if (tb[RTA_CACHEINFO]) {
> @@ -859,9 +854,6 @@ int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
>  			addattr32(&req.n, sizeof(req), RTA_FLOW, realm);
>  		} else if (strcmp(*argv, "onlink") == 0) {
>  			req.r.rtm_flags |= RTNH_F_ONLINK;
> -		} else if (matches(*argv, "equalize") == 0 ||
> -			   strcmp(*argv, "eql") == 0) {
> -			req.r.rtm_flags |= RTM_F_EQUALIZE;
>  		} else if (strcmp(*argv, "nexthop") == 0) {
>  			nhs_ok = 1;
>  			break;
> diff --git a/man/man8/ip.8 b/man/man8/ip.8
> index e948d03..e4a57ff 100644
> --- a/man/man8/ip.8
> +++ b/man/man8/ip.8
> @@ -163,7 +163,7 @@ replace " | " monitor " } "
>  .IR METRIC " ]"
>  
>  .ti -8
> -.IR INFO_SPEC " := " "NH OPTIONS FLAGS" " ["
> +.IR INFO_SPEC " := " "NH OPTIONS" " ["
>  .B  nexthop
>  .IR NH " ] ..."
>  
> @@ -177,7 +177,7 @@ replace " | " monitor " } "
>  .IR NUMBER " ] " NHFLAGS
>  
>  .ti -8
> -.IR OPTIONS " := " FLAGS " [ "
> +.IR OPTIONS " := [ "
>  .B  mtu
>  .IR NUMBER " ] [ "
>  .B  advmss
> @@ -213,10 +213,6 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
>  .IR NUMBER " ]"
>  
>  .ti -8
> -.IR FLAGS " := [ "
> -.BR equalize " ]"
> -
> -.ti -8
>  .IR NHFLAGS " := [ "
>  .BR onlink " | " pervasive " ]"
>  
> @@ -1582,14 +1578,6 @@ to assign (or not to assign) protocol tags.
>  pretend that the nexthop is directly attached to this link,
>  even if it does not match any interface prefix.
>  
> -.TP
> -.B equalize
> -allow packet by packet randomization on multipath routes.
> -Without this modifier, the route will be frozen to one selected
> -nexthop, so that load splitting will only occur on per-flow base.
> -.B equalize
> -only works if the kernel is patched.
> -
>  .SS ip route delete - delete route
>  
>  .B ip route del

applied, i think this was part of the aborted effort at more complex
multipath support. If it ever returns, we can re-enable it.
