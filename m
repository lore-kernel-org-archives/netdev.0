From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] htb: fix sign extension bug
Date: Fri, 2 Aug 2013 08:24:04 -0700
Message-ID: <20130802082404.600bc55c@nehalam.linuxnetplumber.net>
References: <20130801211231.1b25c3be@nehalam.linuxnetplumber.net>
	<ktfdq8$882$1@ger.gmane.org>
	<20130801221936.24d4b31e@nehalam.linuxnetplumber.net>
	<20130801223207.2a9c69e9@nehalam.linuxnetplumber.net>
	<1375450580.3927.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:54911 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752742Ab3HBPYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 11:24:08 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so802427pbb.14
        for <netdev@vger.kernel.org>; Fri, 02 Aug 2013 08:24:08 -0700 (PDT)
In-Reply-To: <1375450580.3927.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 02 Aug 2013 06:36:20 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2013-08-01 at 22:32 -0700, Stephen Hemminger wrote:
> > When userspace passes a large priority value 
> > the assignment of the unsigned value hopt->prio
> > to  signed int cl->prio causes cl->prio to become negative and the
> > comparison is with TC_HTB_NUMPRIO is always false.
> > 
> > The result is that HTB crashes by referencing outside
> > the array when processing packets. With this patch the large value
> > wraps around like other values outside the normal range.
> > 
> > See: https://bugzilla.kernel.org/show_bug.cgi?id=60669
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> > 
> > --- a/net/sched/sch_htb.c	2013-06-20 09:22:46.489542435 -0700
> > +++ b/net/sched/sch_htb.c	2013-08-01 22:12:43.736307055 -0700
> > @@ -100,7 +100,7 @@ struct htb_class {
> >  	struct psched_ratecfg	ceil;
> >  	s64			buffer, cbuffer;/* token bucket depth/rate */
> >  	s64			mbuffer;	/* max wait time */
> > -	int			prio;		/* these two are used only by leaves... */
> > +	u32			prio;		/* these two are used only by leaves... */
> >  	int			quantum;	/* but stored for parent-to-leaf return */
> >  
> >  	struct tcf_proto	*filter_list;	/* class attached filters */
> > --
> 
> Thanks Stephen.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> It seems appropriate for net tree (and stable)
> 
> We probably should report an error from htb_change_class() ?

There are more signed/unsigned bugs lurking here, and opportunities to
shrink the structure. (for example prio could be u8). Overall this code
uses int where unsigned should be used.

Examples:
static inline void htb_add_class_to_row(struct htb_sched *q,
					struct htb_class *cl, int mask)
{
	q->row_mask[cl->level] |= mask;
	while (mask) {
		int prio = ffz(~mask);
		mask &= ~(1 << prio);
		htb_add_to_id_tree(&q->hlevel[cl->level].hprio[prio].row, cl, prio);
	}
}

Could be:
static void htb_add_class_to_row(struct htb_sched *q,
			  	 struct htb_class *cl, u8 mask)
{
	q->row_mask[cl->level] |= mask;
	while (mask) {
		u8 prio = ffz(~mask);
		mask &= ~(1 << prio);
		htb_add_to_id_tree(&q->hlevel[cl->level].hprio[prio].row, cl, prio);
	}
}

Looks like all use of int in HTB should be re-evaluated to see if a smaller unsigned
type could be used instead.
