From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v3 3/3] net: allow setting ecn via routing table
Date: Mon, 03 Nov 2014 08:11:00 -0800
Message-ID: <1415031060.14083.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415019720-17106-1-git-send-email-fw@strlen.de>
	 <1415019720-17106-4-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:43535 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753230AbaKCQLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 11:11:02 -0500
Received: by mail-ig0-f171.google.com with SMTP id hl2so4845928igb.16
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 08:11:01 -0800 (PST)
In-Reply-To: <1415019720-17106-4-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-03 at 14:02 +0100, Florian Westphal wrote:
> This patch allows to set ECN on a per-route basis in case the sysctl
> tcp_ecn is not set to 1. In other words, when ECN is set for specific
> routes, it provides a tcp_ecn=1 behaviour for that route while the rest
> of the stack acts according to the global settings.
> 
> One can use 'ip route change dev $dev $net features ecn' to toggle this.
> 
> Having a more fine-grained per-route setting can be beneficial for various
> reasons, for example, 1) within data centers, or 2) local ISPs may deploy
> ECN support for their own video/streaming services [1], etc.
> 
> There was a recent measurement study/paper [2] which scanned the Alexa's
> publicly available top million websites list from a vantage point in US,
> Europe and Asia:
> 
> Half of the Alexa list will now happily use ECN (tcp_ecn=2, most likely
> blamed to commit 255cac91c3 ("tcp: extend ECN sysctl to allow server-side
> only ECN") ;)); the break in connectivity on-path was found is about
> 1 in 10,000 cases. Timeouts rather than receiving back RSTs were much
> more common in the negotiation phase (and mostly seen in the Alexa
> middle band, ranks around 50k-150k): from 12-thousand hosts on which
> there _may_ be ECN-linked connection failures, only 79 failed with RST
> when _not_ failing with RST when ECN is not requested.
> 
> It's unclear though, how much equipment in the wild actually marks CE
> when buffers start to fill up.
> 
> We thought about a fallback to non-ECN for retransmitted SYNs as another
> global option (which could perhaps one day be made default), but as Eric
> points out, there's much more work needed to detect broken middleboxes.
> 
> Two examples Eric mentioned are buggy firewalls that accept only a single
> SYN per flow, and middleboxes that successfully let an ECN flow establish,
> but later mark CE for all packets (so cwnd converges to 1).
> 
>  [1] http://www.ietf.org/proceedings/89/slides/slides-89-tsvarea-1.pdf, p.15
>  [2] http://ecn.ethz.ch/
> 
> Joint work with Daniel Borkmann.
> 
> Reference: http://thread.gmane.org/gmane.linux.network/335797
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Changes since v2:
>   - alter new cookie_ecn_ok() ok function to also evaluate
>   RTAX_FEATURE_ECN if timestamp-ecn-bit is set and the ecn sysctl
>   is off.
>   - extra blank line in tcp_output.c to appease checkpatch.pl
> 
>  include/net/tcp.h     |  2 +-
>  net/ipv4/syncookies.c |  6 +++---
>  net/ipv4/tcp_input.c  | 25 +++++++++++++++----------
>  net/ipv4/tcp_output.c | 13 +++++++++++--
>  net/ipv6/syncookies.c |  2 +-
>  5 files changed, 31 insertions(+), 17 deletions(-)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 36c5084..f50f29faf 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -493,7 +493,7 @@ __u32 cookie_v4_init_sequence(struct sock *sk, const struct sk_buff *skb,
>  __u32 cookie_init_timestamp(struct request_sock *req);
>  bool cookie_timestamp_decode(struct tcp_options_received *opt);
>  bool cookie_ecn_ok(const struct tcp_options_received *opt,
> -		   const struct net *net);
> +		   const struct net *net, const struct dst_entry *dst);
>  
>  /* From net/ipv6/syncookies.c */
>  int __cookie_v6_check(const struct ipv6hdr *iph, const struct tcphdr *th,
> diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
> index 6de7725..45fe60c 100644
> --- a/net/ipv4/syncookies.c
> +++ b/net/ipv4/syncookies.c
> @@ -273,7 +273,7 @@ bool cookie_timestamp_decode(struct tcp_options_received *tcp_opt)
>  EXPORT_SYMBOL(cookie_timestamp_decode);
>  
>  bool cookie_ecn_ok(const struct tcp_options_received *tcp_opt,
> -		   const struct net *net)
> +		   const struct net *net, const struct dst_entry *dst)
>  {
>  	bool ecn_ok = tcp_opt->rcv_tsecr & TS_OPT_ECN;
>  
> @@ -283,7 +283,7 @@ bool cookie_ecn_ok(const struct tcp_options_received *tcp_opt,
>  	if (net->ipv4.sysctl_tcp_ecn)
>  		return true;
>  
> -	return false;
> +	return dst_feature(dst, RTAX_FEATURE_ECN);
>  }
>  EXPORT_SYMBOL(cookie_ecn_ok);
>  
> @@ -387,7 +387,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
>  				  dst_metric(&rt->dst, RTAX_INITRWND));
>  
>  	ireq->rcv_wscale  = rcv_wscale;
> -	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk));
> +	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk), &rt->dst);
>  
>  	ret = get_cookie_sock(sk, skb, req, &rt->dst);
>  	/* ip_queue_xmit() depends on our flow being setup
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 4e4617e..9db942a 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -5876,20 +5876,22 @@ static inline void pr_drop_req(struct request_sock *req, __u16 port, int family)
>   */
>  static void tcp_ecn_create_request(struct request_sock *req,
>  				   const struct sk_buff *skb,
> -				   const struct sock *listen_sk)
> +				   const struct sock *listen_sk,
> +				   struct dst_entry *dst)

Nit : This probably should be 'const struct dst_entry *dst'

Otherwise, patch looks fine, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
