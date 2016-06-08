From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next 3/4] sched: remove qdisc_rehape_fail
Date: Wed, 8 Jun 2016 23:01:09 +0200
Message-ID: <20160608210109.GD29699@breakpoint.cc>
References: <1465400141-29088-1-git-send-email-fw@strlen.de>
 <1465400141-29088-4-git-send-email-fw@strlen.de>
 <1465407776.7945.24.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60602 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423322AbcFHVBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 17:01:14 -0400
Content-Disposition: inline
In-Reply-To: <1465407776.7945.24.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-06-08 at 17:35 +0200, Florian Westphal wrote:
> > After the removal of TCA_CBQ_POLICE in cbq scheduler qdisc->reshape_fail
> > is always NULL, i.e. qdisc_rehape_fail is now the same as qdisc_drop.
> > 
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> >  include/net/sch_generic.h | 19 -------------------
> >  net/sched/sch_fifo.c      |  4 ++--
> >  net/sched/sch_netem.c     |  4 ++--
> >  net/sched/sch_plug.c      |  2 +-
> >  net/sched/sch_tbf.c       |  4 ++--
> >  5 files changed, 7 insertions(+), 26 deletions(-)
> > 
> > diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> > index c069ac1..a9aec63 100644
> > --- a/include/net/sch_generic.h
> > +++ b/include/net/sch_generic.h
> > @@ -63,9 +63,6 @@ struct Qdisc {
> >  	struct list_head	list;
> >  	u32			handle;
> >  	u32			parent;
> > -	int			(*reshape_fail)(struct sk_buff *skb,
> > -					struct Qdisc *q);
> > -
> >  	void			*u32_node;
> >  
> 
> You removed 2 pointers from Qdisc, so now next_sched & gso_skb are in a
> different cache line than ->state
> 
> Some performance penalty is expected, unless you move a read_mostly
> field there to compensate.

Would you mind an annotation rather than covering the hole?

--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -71,11 +71,11 @@ struct Qdisc {
        struct gnet_stats_basic_cpu __percpu *cpu_bstats;
        struct gnet_stats_queue __percpu *cpu_qstats;
 
-       struct Qdisc            *next_sched;
-       struct sk_buff          *gso_skb;
        /*
         * For performance sake on SMP, we put highly modified fields at the end
         */
+       struct Qdisc            *next_sched ____cacheline_aligned_in_smp;
+       struct sk_buff          *gso_skb;


... it creates 16 byte hole after cpu_qstats and keeps the rest as-is
 (i.e. next_sched is at beginning of 2nd cacheline, as before the removal).

I could also cover the hole by moving rcu_head there but it seems fragile
and doesn't reduce total struct size anyway (we get larger hole at end).

If you have no objection I'd resubmit the series as-is but with this patch.

Let me know, thanks Eric!
