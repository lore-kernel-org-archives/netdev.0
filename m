From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC take2] pkt_sched: gen_estimator: Dont report fake rate
	estimators
Date: Fri, 2 Oct 2009 11:25:14 +0000
Message-ID: <20091002112514.GA14100@ff.dom.local>
References: <20091002070819.GA9694@ff.dom.local> <4AC5D78D.3030400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:9460 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbZJBLZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 07:25:17 -0400
Received: by fg-out-1718.google.com with SMTP id 22so2075342fge.1
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2009 04:25:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4AC5D78D.3030400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 02, 2009 at 12:35:57PM +0200, Eric Dumazet wrote:
> Here is second attempt to make this change, thanks Jarek !
> 
> This is indeed less intrusive !
> 
> [RFC] pkt_sched: gen_estimator: Dont report fake rate estimators
> 
> We currently send TCA_STATS_RATE_EST elements to netlink users, even if no estimator
> is running.
> 
> # tc -s -d qdisc
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 112833764978 bytes 1495081739 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> 
> User has no way to tell if the "rate 0bit 0pps" is a real estimation, or a fake
> one (because no estimator is active)
> 
> After this patch, tc command output is :
> $ tc -s -d qdisc
> qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 561075 bytes 1196 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> 
> We add a parameter to gnet_stats_copy_rate_est() function so that
> it can use gen_estimator_active(bstats, r), as suggested by Jarek.

So you prefer the additional parameter version, but since these
_active tests are not needed e.g. for HTB classes, which got it
active by default, so maybe bstats == NULL would let skip such a test?

...
> --- a/include/net/gen_stats.h
> +++ b/include/net/gen_stats.h
> @@ -30,6 +30,7 @@ extern int gnet_stats_start_copy_compat(struct sk_buff *skb, int type,
>  extern int gnet_stats_copy_basic(struct gnet_dump *d,
>  				 struct gnet_stats_basic_packed *b);
>  extern int gnet_stats_copy_rate_est(struct gnet_dump *d,
> +				    const struct gnet_stats_basic_packed *bstats,

It seems these *b/*bstats defs could look more consistent. Otherwise
it looks OK to me.

Thanks,
Jarek P.
