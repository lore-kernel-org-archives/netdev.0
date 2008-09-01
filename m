From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [UPDATED] [NET-NEXT PATCH 1/2] pkt_sched: Add multiqueue
	scheduler support
Date: Mon, 01 Sep 2008 15:49:14 -0700
Message-ID: <1220309354.14337.34.camel@ahduyck-laptop>
References: <20080901210516.GA5931@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, jeff@garzik.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:46043 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbYIAWt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 18:49:29 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1468687waf.23
        for <netdev@vger.kernel.org>; Mon, 01 Sep 2008 15:49:28 -0700 (PDT)
In-Reply-To: <20080901210516.GA5931@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-09-01 at 23:05 +0200, Jarek Poplawski wrote:

> Mostly looks OK to me, but a few (late) doubts below:

Most of your suggestions I agree with, with the following exceptions.
> ...
> > +static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
> > +{
> > +	struct multiq_sched_data *q = qdisc_priv(sch);
> > +	struct tc_multiq_qopt *qopt;
> > +	struct Qdisc **queues;
> > +	int i;
> > +
> > +	if (sch->parent != TC_H_ROOT)
> > +		return -EINVAL;
> 
> Is it necessary?
> 
I think so.  Basically I want to have this qdisc as the root for all
other qdiscs because the hardware queue decision needs to be made as
soon as possible in order to avoid any head of line blocking issues.
This way you don't end up with multiple qdiscs fighting over hardware
queues.

> > +static int multiq_dump(struct Qdisc *sch, struct sk_buff *skb)
> > +{
> > +	struct multiq_sched_data *q = qdisc_priv(sch);
> > +	unsigned char *b = skb_tail_pointer(skb);
> > +	struct nlattr *nest;
> > +	struct tc_multiq_qopt opt;
> > +
> > +	opt.bands = q->bands;
> > +
> > +	nest = nla_nest_compat_start(skb, TCA_OPTIONS, sizeof(opt), &opt);
> 
> http://marc.info/?l=linux-netdev&m=121993231608269&w=2

I can dump the whole nested_compat setup and replace it all with an
nla_put, because it is inefficient to waste the space on an empty nested
attribute that isn't needed.  I think this was just a holdover from
prio/rr anyway.

> 
> > +	if (nest == NULL)
> > +		goto nla_put_failure;
> > +	nla_nest_compat_end(skb, nest);
> ...
> 
> Jarek P.

Thanks,

Alex


