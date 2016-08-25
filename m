From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] qdisc: fix a module refcount leak in
 qdisc_create_dflt()
Date: Thu, 25 Aug 2016 07:46:01 -0700
Message-ID: <1472136361.14381.132.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472056742.14381.93.camel@edumazet-glaptop3.roam.corp.google.com>
         <ef703076-2e2c-3373-53b1-99ba5df2c2d5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        stephen hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35097 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757831AbcHYPCF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 11:02:05 -0400
Received: by mail-pa0-f67.google.com with SMTP id cf3so3255498pad.2
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 08:00:48 -0700 (PDT)
In-Reply-To: <ef703076-2e2c-3373-53b1-99ba5df2c2d5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-25 at 21:26 +0800, Wei Yongjun wrote:
> On 08/25/2016 12:39 AM, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Should qdisc_alloc() fail, we must release the module refcount
> > we got right before.
> >
> > Fixes: 6da7c8fcbcbd ("qdisc: allow setting default queuing discipline")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > ---
> >  net/sched/sch_generic.c |    9 +++++----
> >  1 file changed, 5 insertions(+), 4 deletions(-)
> >
> > diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> > index e95b67cd5718..657c13362b19 100644
> > --- a/net/sched/sch_generic.c
> > +++ b/net/sched/sch_generic.c
> > @@ -643,18 +643,19 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
> >  	struct Qdisc *sch;
> >  
> >  	if (!try_module_get(ops->owner))
> > -		goto errout;
> > +		return NULL;
> >  
> >  	sch = qdisc_alloc(dev_queue, ops);
> > -	if (IS_ERR(sch))
> > -		goto errout;
> > +	if (IS_ERR(sch)) {
> > +		module_put(ops->owner);
> > +		return NULL;
> > +	}
> >  	sch->parent = parentid;
> >  
> >  	if (!ops->init || ops->init(sch, NULL) == 0)
> >  		return sch;
> >  
> >  	qdisc_destroy(sch);
> 
> ops->init() failed, missing module_put() here.

qdisc_destroy() is doing this for us, we do not want to have a double
module_put()
