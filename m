From: "Alexander Duyck" <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH] sched: only dequeue if packet can be queued to hardware queue.
Date: Thu, 18 Sep 2008 07:51:13 -0700
Message-ID: <5f2db9d90809180751h2b62f9f2m1462ca65b2a612bf@mail.gmail.com>
References: <20080918063036.27934.91273.stgit@localhost.localdomain>
	 <20080918.024655.22661052.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jarkao2@gmail.com, herbert@gondor.apana.org.au, kaber@trash.net
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:25144 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066AbYIROvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 10:51:14 -0400
Received: by yx-out-2324.google.com with SMTP id 8so1062035yxm.1
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2008 07:51:13 -0700 (PDT)
In-Reply-To: <20080918.024655.22661052.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2008 at 2:46 AM, David Miller <davem@davemloft.net> wrote:
> So what is the difference between qdisc->dequeue and qdisc->ops->dequeue?
> The same applies to ->enqueue.
>
> qdisc->{dequeue,enqueue} are given the value of ops->{dequeue,enqueue}
> at the time of qdisc creation.  I can only see two reasons for their
> existence:
>
> 1) We used to allow overriding ->enqueue and ->dequeue by certain
>   modules.  I see no such use like this in the current tree.
>
> 2) For performance it's kept as a copy in the qdisc.
>
> Either way, changing ->ops->dequeue into ->dequeue doesn't seem to be
> correct, unless you have some explanation.
>
> This is done in a few other places in your patch.

I redefined qdisc->dequeue to be set to smart_dequeue in sch_generic.c:
@@ -475,7 +491,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
       skb_queue_head_init(&sch->q);
       sch->ops = ops;
       sch->enqueue = ops->enqueue;
-       sch->dequeue = ops->dequeue;
+       sch->dequeue = ops->smart_dequeue;
       sch->dev_queue = dev_queue;
       dev_hold(qdisc_dev(sch));
       atomic_set(&sch->refcnt, 1);

Most of the changes from qdisc->dequeue to qdisc->ops->dequeue are to have the
standard dequeue call use nothing but standard dequeue calls in it's
path.  I needed
to maintain qdisc->ops->dequeue because there are several functions throughout
the qdisc code that require the ability to dequeue a packet regardless
of hw queue
state.

Thanks,

Alex
