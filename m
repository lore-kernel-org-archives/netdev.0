From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sch_htb: ix the deficit overflows
Date: Mon, 30 Nov 2009 11:10:20 +0000
Message-ID: <20091130111020.GA7114@ff.dom.local>
References: <4B0F8A5D.1040806@gmail.com> <20091128000401.GA3713@ami.dom.local> <412e6f7f0911292026w704a70b8yc3af2c2473e05d34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Martin Devera <martin.devera@cdi.cz>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:32970 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926AbZK3LKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 06:10:20 -0500
Received: by bwz27 with SMTP id 27so2383819bwz.21
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 03:10:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <412e6f7f0911292026w704a70b8yc3af2c2473e05d34@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2009 at 12:26:33PM +0800, Changli Gao wrote:
> On Sat, Nov 28, 2009 at 8:04 AM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > Changli Gao wrote, On 11/27/2009 09:14 AM:
> >
> >
> > This case of the quantum smaller than the packet size should be treated
> > as a broken config, so I don't think it's worth to do such a deep change
> > with additional delays and cpu cycles for all to fix it. A warning or
> > lower limit should be enough (if necessary at all).
> >
> 
> I don't think this change is deep. HTB has it own lower limit for
> quantum 1000, but the MTU is various, and maybe larger than that.

Users can control this with "r2q" and "quantum", and there is a hint
on quantum size in the user's guide.

> And
> if we use IMQ to shape traffic, the skb will be defragmented by
> conntrack, and its size will be larger than MTU.

IMQ is a very nice thing, but it's considered broken as well, so it
can't be the reason for changing HTB.

> 
> The previous patch indeed introduces some additional CPU cycles.
> Review  the new patch bellow please:

And this patch is very similar, except ->peek()/dequeue(). Additional
lookups are done instead of dequeuing the first found class, which
might be quite long in some cases.

> 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 2e38d1a..d55382b 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -815,6 +815,17 @@ next:
>                         goto next;
>                 }
> 
> +               if (unlikely(cl->un.leaf.deficit[level] < 0)) {
> +                       cl->un.leaf.deficit[level] += cl->quantum;
> +                       htb_next_rb_node((level ? cl->parent->un.inner.ptr :
> +                                         q->ptr[0]) + prio);
> +                       cl = htb_lookup_leaf(q->row[level] + prio, prio,
> +                                            q->ptr[level] + prio,
> +                                            q->last_ptr_id[level] + prio);
> +                       start = cl;
> +                       goto next;
> +               }
> +
>                 skb = cl->un.leaf.q->dequeue(cl->un.leaf.q);
>                 if (likely(skb != NULL))
>                         break;
> 
> If you think it is acceptable, I'll resubmit it for inclusion.

It's not acceptable to me mainly because the real change done by this
patch is different than you describe: preventing an overflow might be
simple. You change the way DRR is implemented here, and even if it's
right, it should be written explicitly and proved with tests results.

Anyway, I think you should rather care for the author's acceptance,
because the way it's done doesn't look like accidental and has been
heavily tested btw. (I added Martin to CC.)

Regards,
Jarek P.

PS: Btw, this newer version of the patch is broken with spaces.
