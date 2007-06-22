From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 21 Jun 2007 17:01:58 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290314719B@orsmsx414.amr.corp.intel.com>
References: <467B0E12.6030200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10955 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751581AbXFVACA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 20:02:00 -0400
Content-class: urn:content-classes:message
In-Reply-To: <467B0E12.6030200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The dependencies seem to be very confused. SCHED_PRIO does 
> not depend on anything new, SCH_RR also doesn't depend on 
> anything. SCH_PRIO_MQ and SCH_RR_MQ (which is missing) depend 
> on SCH_PRIO/SCH_RR. A single NET_SCH_MULTIQUEUE option seems 
> better than adding one per scheduler though.

I agree with a NET_SCH_MULTIQUEUE option.  However, SCH_RR does depend
on SCH_PRIO being built since it's the same code, doesn't it?  Maybe I'm
not understanding something about the build process.  I'll clean this
up.

> 
> > --- a/net/sched/sch_prio.c
> > +++ b/net/sched/sch_prio.c
> > @@ -9,6 +9,8 @@
> >   * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
> >   * Fixes:       19990609: J Hadi Salim <hadi@nortelnetworks.com>:
> >   *              Init --  EINVAL when opt undefined
> > + * Additions:	Peter P. Waskiewicz Jr. 
> <peter.p.waskiewicz.jr@intel.com>
> > + *		Added round-robin scheduling for selection at load-time
> >   
> 
> git keeps changelogs, please don't add it here.

Roger.

> >  	struct tcf_proto *filter_list;
> >  	u8  prio2band[TC_PRIO_MAX+1];
> >  	struct Qdisc *queues[TCQ_PRIO_BANDS];
> > +	u16 band2queue[TC_PRIO_MAX + 1];
> >   
> 
> Why is this still here? Its a 1:1 mapping.

I'll fix this.

> > @@ -211,6 +265,22 @@ static int prio_tune(struct Qdisc 
> *sch, struct rtattr *opt)
> >  			return -EINVAL;
> >  	}
> >  
> > +	/* If we're prio multiqueue or are using round-robin, make
> > +	 * sure the number of incoming bands matches the number of
> > +	 * queues on the device we're associating with.
> > +	 */
> > +#ifdef CONFIG_NET_SCH_RR
> > +	if (strcmp("rr", sch->ops->id) == 0)
> > +		if (qopt->bands != sch->dev->egress_subqueue_count)
> > +			return -EINVAL;
> > +#endif
> > +
> > +#ifdef CONFIG_NET_SCH_PRIO_MQ
> > +	if (strcmp("prio", sch->ops->id) == 0)
> > +		if (qopt->bands != sch->dev->egress_subqueue_count)
> > +			return -EINVAL;
> > +#endif
> >   
> 
> For the tenth time now, the user should enable this at 
> runtime. You can't just break things dependant on config options.

I had this in sch_prio and tc before, and was told to remove it because
of ABI issues.  I can put it back in, but I'm not sure what those
previous ABI issues were.  Was it backwards compatibility that you
referred to before that was broken?

As always, the feedback is very much appreciated.  I'll get these fixes
in as soon as possible.

-PJ
