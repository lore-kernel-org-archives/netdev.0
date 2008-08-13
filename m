From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NMI lockup, 2.6.26 release
Date: Wed, 13 Aug 2008 07:43:26 +0000
Message-ID: <20080813074326.GB5367@ff.dom.local>
References: <200807222142.23710.denys@visp.net.lb> <200808121431.40852.denys@visp.net.lb> <20080812124034.GA7666@ff.dom.local> <200808131028.11153.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.184]:37689 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155AbYHMHnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 03:43:33 -0400
Received: by fk-out-0910.google.com with SMTP id 18so2622999fkq.5
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 00:43:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808131028.11153.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 10:28:11AM +0300, Denys Fedoryshchenko wrote:
> Just as proposal, maybe we can catch situation when "things going wrong" and 
> panic? So we can forward some info to hrtimers guys?
> If it is hrtimers bug...

Yes, it would be the best, but I don't know how much I can "use" you
and your clients for debugging this. So, of course, if it's possible
you could simply edit this patch and try with increased values like
(100 * HZ) or (1000 * HZ), or even something like:

+	if (q->next_watchdog < q->now || next_event <=
+	     q->next_watchdog - 10) {

Alas hrtimers guys didn't look like very interested, so the main
concern should be doing this optimal in net at least.

Jarek P.

> 
> On Tuesday 12 August 2008, Jarek Poplawski wrote:
> > On Tue, Aug 12, 2008 at 02:31:40PM +0300, Denys Fedoryshchenko wrote:
> > ...
> >
> > > With second patch it works fine, 9 days uptime now
> >
> > Great! I didn't expect it would be so easy with this strange problem.
> > So, it looks like hrtimers could break probably after some
> > overscheduling. The only problem with this is to find some reasonable
> > limit which is both safe and doesn't harm resolution too much for
> > others.
> >
> > IMHO this second patch with 1 jiffie watchdog resolution looks
> > reasonable and should be acceptable, but it would be nice to check if
> > we can go lower. Here is "the same" patch with only change in
> > resolution (1/10 of jiffie). If there are any problems with testing
> > this please let me know. (It should be applied after reverting
> > patch #2.)
> >
> > Thanks,
> > Jarek P.
> >
> > (testing patch #3)
> > ---
> >
> >  net/sched/sch_htb.c |    8 +++++++-
> >  1 files changed, 7 insertions(+), 1 deletions(-)
> >
> > diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> > index 30c999c..ff9e965 100644
> > --- a/net/sched/sch_htb.c
> > +++ b/net/sched/sch_htb.c
> > @@ -162,6 +162,7 @@ struct htb_sched {
> >
> >  	int rate2quantum;	/* quant = rate / rate2quantum */
> >  	psched_time_t now;	/* cached dequeue time */
> > +	psched_time_t next_watchdog;
> >  	struct qdisc_watchdog watchdog;
> >
> >  	/* non shaped skbs; let them go directly thru */
> > @@ -920,7 +921,11 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
> >  		}
> >  	}
> >  	sch->qstats.overlimits++;
> > -	qdisc_watchdog_schedule(&q->watchdog, next_event);
> > +	if (q->next_watchdog < q->now || next_event <=
> > +	     q->next_watchdog - PSCHED_TICKS_PER_SEC / (10 * HZ)) {
> > +		qdisc_watchdog_schedule(&q->watchdog, next_event);
> > +		q->next_watchdog = next_event;
> > +	}
> >  fin:
> >  	return skb;
> >  }
> > @@ -973,6 +978,7 @@ static void htb_reset(struct Qdisc *sch)
> >  		}
> >  	}
> >  	qdisc_watchdog_cancel(&q->watchdog);
> > +	q->next_watchdog = 0;
> >  	__skb_queue_purge(&q->direct_queue);
> >  	sch->q.qlen = 0;
> >  	memset(q->row, 0, sizeof(q->row));
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
