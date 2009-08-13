From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Speed-up pfifo_fast lookup using a bitmap
Date: Thu, 13 Aug 2009 10:08:27 +0000
Message-ID: <20090813100826.GA6042@ff.dom.local>
References: <20090813072818.7541.77365.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, kaber@trash.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f228.google.com ([209.85.220.228]:34538 "EHLO
	mail-fx0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434AbZHMKId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 06:08:33 -0400
Received: by fxm28 with SMTP id 28so490897fxm.17
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2009 03:08:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090813072818.7541.77365.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 13, 2009 at 12:58:18PM +0530, Krishna Kumar wrote:
> Maintain a per-qdisc bitmap indicating availability of skbs for
> each band. This helps in faster lookup for a skb when there are
> no high priority skbs. Also, it helps in (rare) cases where there
> are no skbs on the list where an immediate lookup helps rather
> than iterating through the three bands.
> 
> Another option I considered was to create a private qdisc pointer
> and avoid touching Qdisc structure:
> 	struct pfifo_fast_priv {
> 		unsigned long bitmap;
> 		struct sk_buff_head q[PFIFO_FAST_BANDS];
> 	};
> but the test numbers came a little less, since it takes a few more
> memory references on enqueue/dequeue.

If it's exactly "a little less" I'd consider keeping it private yet...

> 
> By keeping the bitmap in Qdisc, it is possible to implement the
> lookup for other schedulers, maybe sch_prio which goes through 16
> bands?
> 
> The BW numbers are average across 5 iterations for multiple
> netperf sessions (1-12 on x86_64, and 1-32 on P6) tested with
> Chelsio 10 gbps cards over a 2 hour run:
> 
> -------------------------------------------------------------------------
>      |         x86_64 (Mb/s)          |               P6 (Mb/s)
> --------------------------------------|----------------------------------
> Size |  ORG BW          NEW BW        |    ORG BW          NEW BW       
> -----|--------------------------------|----------------------------------
> 16K  |  157700          158237        |    153876          156696
> 64K  |  155916          157882        |    154176          155987
> 128K |  155122          155628        |    154983          155904
> 256K |  154808          158913        |    153898          155164
> -------------------------------------------------------------------------

Btw, I wonder how much gain of your previous (_CAN_BYPASS) patch is
saved after this change...

> 
> Thanks,
> 
> - KK
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
> 
>  include/net/sch_generic.h |    1 
>  net/sched/sch_generic.c   |   46 +++++++++++++++++++++++-------------
>  2 files changed, 31 insertions(+), 16 deletions(-)
> 
> diff -ruNp org/include/net/sch_generic.h new/include/net/sch_generic.h
> --- org/include/net/sch_generic.h	2009-08-07 12:05:43.000000000 +0530
> +++ new/include/net/sch_generic.h	2009-08-07 19:35:16.000000000 +0530
> @@ -72,6 +72,7 @@ struct Qdisc
>  	 * For performance sake on SMP, we put highly modified fields at the end
>  	 */
>  	unsigned long		state;
> +	unsigned long		bitmap;
>  	struct sk_buff_head	q;
>  	struct gnet_stats_basic bstats;
>  	struct gnet_stats_queue	qstats;
> diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
> --- org/net/sched/sch_generic.c	2009-08-07 12:05:43.000000000 +0530
> +++ new/net/sched/sch_generic.c	2009-08-13 11:57:54.000000000 +0530
> @@ -406,18 +406,29 @@ static const u8 prio2band[TC_PRIO_MAX+1]
>  
>  #define PFIFO_FAST_BANDS 3
>  
> -static inline struct sk_buff_head *prio2list(struct sk_buff *skb,
> -					     struct Qdisc *qdisc)
> +/*
> + * Convert a bitmap to the first band number where an skb is queue'd, where:

 - * Convert a bitmap to the first band number where an skb is queue'd, where:
 + * Convert a bitmap to the first band number where an skb is queued, where:

> + * 	bitmap=0 means there are no skbs for any bands
> + * 	bitmap=1 means there is a skb on band 0

 - * 	bitmap=1 means there is a skb on band 0
 + * 	bitmap=1 means there is an skb on band 0

> + *	bitmap=7 means there are skbs on all 3 bands, etc.
> + */
> +static const int bitmap2band[] =
> +	{-1, 0, 1, 0, 2, 0, 1, 0};

Why wrapped?

...
 ... pfifo_fast_reset(...)
 {
	...
+	qdisc->bitmap = 0; ?
 }

Thanks,
Jarek P.
