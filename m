From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet
 length for qdiscs
Date: Fri, 25 Jul 2008 03:57:12 -0700 (PDT)
Message-ID: <20080725.035712.33516738.davem@davemloft.net>
References: <20080719233506.12596.59935.stgit@fate.lan>
	<20080725105748.GB10399@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jussi.kivilinna@mbnet.fi, kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52513
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751500AbYGYK5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 06:57:13 -0400
In-Reply-To: <20080725105748.GB10399@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 25 Jul 2008 10:57:48 +0000

> On 20-07-2008 01:35, Jussi Kivilinna wrote:
> > Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> ...
> > diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
> > index 1afe3ee..f1d2f8e 100644
> > --- a/net/sched/sch_cbq.c
> > +++ b/net/sched/sch_cbq.c
> > @@ -370,7 +370,6 @@ static int
> >  cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> >  {
> >  	struct cbq_sched_data *q = qdisc_priv(sch);
> > -	int len = skb->len;
> >  	int uninitialized_var(ret);
> >  	struct cbq_class *cl = cbq_classify(skb, sch, &ret);
> >  
> > @@ -391,7 +390,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> >  	if (ret == NET_XMIT_SUCCESS) {
> >  		sch->q.qlen++;
> >  		sch->bstats.packets++;
> > -		sch->bstats.bytes+=len;
> > +		sch->bstats.bytes += qdisc_pkt_len(skb);
> 
> Alas I didn't manage to read this earlier, but this type of changes
> here and elsewhere in this patch looks wrong to me: we shouldn't
> use skb pointer after ->enqueue().

It should be OK here, we have the root qdisc locked, so nobody
can remove it from the queue and if we got NET_XMIT_SUCCESS that
thing must not have been freed.

And anyways, we can't know the qdisc_pkt_len() until the enqueue
fucntion has been called.

Even TCP depends upon that NET_XMIT_* return value having some real
meaning, remember the HTB bug we tracked down last week? :-)
