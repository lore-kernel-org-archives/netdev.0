From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 4/5] xps_flows: XPS for packets that don't
 have a socket
Date: Thu, 29 Sep 2016 08:15:42 -0700
Message-ID: <1475162142.28155.188.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160929035428.204355-1-tom@herbertland.com>
         <20160929035428.204355-5-tom@herbertland.com>
         <1475124851.28155.135.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALx6S36FsjSioksB+O7Lp7-7PcC8iMc9LWqWiFr8RzFJ=GkKGQ@mail.gmail.com>
         <1475155080.28155.159.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALx6S344d16SVhO+FhXpyL09k4vSuv45F-bff-nMeqS4H=p+tw@mail.gmail.com>
         <1475160695.28155.168.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Rick Jones <rick.jones2@hpe.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33108 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751710AbcI2PPp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 11:15:45 -0400
Received: by mail-pa0-f68.google.com with SMTP id oz2so3570631pac.0
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 08:15:44 -0700 (PDT)
In-Reply-To: <1475160695.28155.168.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-29 at 07:51 -0700, Eric Dumazet wrote:
> On Thu, 2016-09-29 at 10:08 -0400, Tom Herbert wrote:
> 
> > It addresses  the issue that Rick Jones pointed out was happening with
> > XPS. When packets are sent for a flow that has no socket and XPS is
> > enabled then each packet uses the XPS queue based on the running CPU.
> > Since the thread sending on a flow can be rescheduled on different
> > CPUs this is creating ooo packets. In this case the ooo is being
> > caused by interaction with XPS.
> > 
> 
> Nope, your patch does not address the problem properly.
> 
> I am not sure I want to spend more time explaining the issue.
> 
> Lets talk about this in Tokyo next week.
> 

Just as a reminder, sorry to bother you, stating some obvious facts for
both of us. We have public exchanges, so we also need to re-explain how
things work.

Queue selection on xmit happens before we hit the qdisc and its delays.

So when you access txq->dql.num_completed_ops and
txq->dql.num_enqueue_ops you can observe values that do not change for a
while.

Say a thread runs on a VM, and sends 2 packets P1, P2 on the same flow
(skb_get_hash() returns the same value for these 2 packets)

P1 is sent on behalf of CPU 1, we pickup queue txq1, and queue the
packet on its qdisc . Transmit does not happen because of some
constraints like rate limiting or scheduling constraints.

P2 is sent on behalf of CPU 2, we pickup queue txq2, notice that prior
packet chose txq1. We check txq1->dql and decide it is fine to use txq2,
since the dql params of txq1 were not changed yet.

( txq->dql.num_completed_ops == ent.queue_ptr )

Note that in RFS case, we have the guarantee that we observe 'live
queues' since they are the per cpu backlog.

So input_queue_head_incr() and input_queue_tail_incr_save() are
correctly doing the OOO prevention, because a queued packet immediately
changes the state.

So really your patch works if you have no qdisc, or a non congested
qdisc. (Think if P1 is dropped by a full pfifo or pfifo_fast : We really
want to avoid steering P2, P3, ..., PN on this full pfifo while maybe
other txq are idle). Strange attractors are back (check commit
9b462d02d6dd6 )

You could avoid (ab)using BQL with a different method, grabbing
skb->destructor for the packets that are socketless

The hash table would simply track the sum of skb->truesize to allow flow
migration. This would be self contained and not intrusive.
