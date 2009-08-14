From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Speed-up pfifo_fast lookup using a bitmap
Date: Fri, 14 Aug 2009 11:01:27 +0000
Message-ID: <20090814110127.GA17563@ff.dom.local>
References: <20090814081907.18169.10600.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:38797 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753589AbZHNLBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 07:01:33 -0400
Received: by bwz22 with SMTP id 22so1074984bwz.18
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 04:01:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090814081907.18169.10600.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 14, 2009 at 01:49:07PM +0530, Krishna Kumar wrote:
> Jarek Poplawski <jarkao2@gmail.com> wrote on 08/13/2009 04:57:16 PM:
> 
> > > Sounds reasonable. To quantify that, I will test again for a longer
> > > run and report the difference.
> >
> > Yes, more numbers would be appreciated.
> 
> I did a longer 7-hour testing of original code, public bitmap (the
> code submitted earlier) and a private bitmap (patch below). Each
> result line is aggregate of 5 iterations of individual 1, 2, 4, 8,
> 32 netperf sessions, each running for 55 seconds:
> 
> -------------------------------------------------------
> IO Size     Org        Public          Private
> -------------------------------------------------------
> 4K          122571     126821          125913
> 16K         135715     135642          135530 
> 128K        131324     131862          131668
> 256K        130060     130107          130378
> -------------------------------------------------------
> Total:      519670     524433 (0.92%)  523491 (0.74%)
> -------------------------------------------------------
> 
> The difference between keeping the bitmap private and public is
> not much.

Alas, private or public, these values are lower on average than
before, so I'm not sure the complexity (especially in reading) added
by this patch is worth it. So, I can only say it looks formally OK,
except the changelog and maybe 2 cosmetical suggestions below.

> > > The tests are on the latest tree which contains CAN_BYPASS. So a
> > > single netperf process running this change will get no advantage
> > > since this enqueue/dequeue never happens unless the NIC is slow.
> > > But for multiple processes, it should help.
> > 
> > I mean: since the previous patch saved ~2% on omitting enqueue/dequeue,
> > and now enqueue/dequeue is ~2% faster, is it still worth to omit this?
> 
> I haven't tested the bitmap patch without the bypass code.
> Theoretically I assume that patch should help as we still save
> an enqueue/dequeue.
> 
> Thanks,
> 
> - KK
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
> 
>  net/sched/sch_generic.c |   70 ++++++++++++++++++++++++++------------
>  1 file changed, 48 insertions(+), 22 deletions(-)
> 
> diff -ruNp org/net/sched/sch_generic.c new2/net/sched/sch_generic.c
> --- org/net/sched/sch_generic.c	2009-08-07 12:05:43.000000000 +0530
> +++ new2/net/sched/sch_generic.c	2009-08-14 12:48:37.000000000 +0530
> @@ -406,18 +406,38 @@ static const u8 prio2band[TC_PRIO_MAX+1]
...
> +static inline struct sk_buff_head *band2list(struct pfifo_fast_priv *priv,
> +					     int band)
>  {
> -	struct sk_buff_head *list = qdisc_priv(qdisc);
> -	return list + prio2band[skb->priority & TC_PRIO_MAX];
> +	return &priv->q[0] + band;

	return priv->q + band;
seems more readable.

...
>  static struct Qdisc_ops pfifo_fast_ops __read_mostly = {
>  	.id		=	"pfifo_fast",
> -	.priv_size	=	PFIFO_FAST_BANDS * sizeof(struct sk_buff_head),
> +	.priv_size	=	sizeof (struct pfifo_fast_priv),

checkpatch warns here, and it seems consistent with Documentation/
CodingStyle.

Thanks,
Jarek P.
