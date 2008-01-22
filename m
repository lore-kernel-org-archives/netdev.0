From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 2/4] dsmark: get rid of trivial function
Date: Mon, 21 Jan 2008 19:47:51 -0800
Message-ID: <20080121194751.31fd42a0@speedy>
References: <20080120130542.16720b45@deepthought>
	<20080120132550.056370c0@deepthought>
	<4793E460.5020804@trash.net>
	<20080121.022223.85874858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:40191 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764AbYAVDry (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 22:47:54 -0500
In-Reply-To: <20080121.022223.85874858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Jan 2008 02:22:23 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 21 Jan 2008 01:16:32 +0100
> 
> > Stephen Hemminger wrote:
> > > Replace loop in dsmark_valid_indices with equivalent bit math.
> > > 
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > > 
> > > --- a/net/sched/sch_dsmark.c	2008-01-20 13:07:58.000000000 -0800
> > > +++ b/net/sched/sch_dsmark.c	2008-01-20 13:22:54.000000000 -0800
> > > @@ -45,13 +45,8 @@ struct dsmark_qdisc_data {
> > >  
> > >  static inline int dsmark_valid_indices(u16 indices)
> > >  {
> > > -	while (indices != 1) {
> > > -		if (indices & 1)
> > > -			return 0;
> > > -		indices >>= 1;
> > > -	}
> > > -
> > > -	return 1;
> > > +	/* Must have only one bit set */
> > > +	return (indices & (indices - 1)) == 0;
> > 
> > hweight seems easier to understand, it took me a bit
> > to realize that the comment matches the code :)
> 
> Sounds good.  Here is what I ended up checking in.
> 
> [PKT_SCHED] dsmark: Use hweight32() instead of convoluted loop.
> 
> Based upon a patch by Stephen Hemminger and suggestions
> from Patrick McHardy.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
> index a9732ae..d96eaf0 100644
> --- a/net/sched/sch_dsmark.c
> +++ b/net/sched/sch_dsmark.c
> @@ -10,6 +10,7 @@
>  #include <linux/errno.h>
>  #include <linux/skbuff.h>
>  #include <linux/rtnetlink.h>
> +#include <linux/bitops.h>
>  #include <net/pkt_sched.h>
>  #include <net/dsfield.h>
>  #include <net/inet_ecn.h>
> @@ -43,17 +44,6 @@ struct dsmark_qdisc_data {
>  	int			set_tc_index;
>  };
>  
> -static inline int dsmark_valid_indices(u16 indices)
> -{
> -	while (indices != 1) {
> -		if (indices & 1)
> -			return 0;
> -		indices >>= 1;
> -	}
> -
> -	return 1;
> -}
> -
>  static inline int dsmark_valid_index(struct dsmark_qdisc_data *p, u16 index)
>  {
>  	return (index <= p->indices && index > 0);
> @@ -348,7 +338,8 @@ static int dsmark_init(struct Qdisc *sch, struct rtattr *opt)
>  		goto errout;
>  
>  	indices = RTA_GET_U16(tb[TCA_DSMARK_INDICES-1]);
> -	if (!indices || !dsmark_valid_indices(indices))
> +
> +	if (hweight32(indices) != 1)
>  		goto errout;

Come on Dave, that is a step backwards.
So you took a two instruction thing that any programmer who ever had one of those
technical trick interviews would surely understand, and made it call a function...
Seems like the thing you would consul others against.

Please use !is_power_of_2(indices) instead.
