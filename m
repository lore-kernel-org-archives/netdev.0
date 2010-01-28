From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: CBQ broken in 2.6
Date: Thu, 28 Jan 2010 19:45:20 +0100
Message-ID: <20100128184519.GA3109@del.dom.local>
References: <20100128125317.GA8931@ff.dom.local>
 <1264685696.4038.14.camel@mare-infinitum.sigsegv.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f215.google.com ([209.85.220.215]:39102 "EHLO
	mail-fx0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274Ab0A1Sp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 13:45:26 -0500
Received: by fxm7 with SMTP id 7so1197432fxm.28
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 10:45:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1264685696.4038.14.camel@mare-infinitum.sigsegv.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2010 at 01:34:56PM +0000, Anton Ivanov wrote:
> Hi Jarek,
Hi Anton,

> 
> The class was created as bounded and never changed. I do a full reload
> of the hierarchy including a root qdisc delete via a script instead of
> trying to adjust it. 
> 
> It has 7 or so children and one sibling. It is parented to root.
> 
> I have recompiled sch_cbq.c with a number of printks in strategic
> places. I have also added some debug output to tc. I have also rewritten
> my test suite.
> 
> The results are as follows
> 
> Based on the printks cbq_set_lss and the cbq_change_class functions
> correctly.
> 
> It indeed sets cl->borrow and cl->share to NULL as expected.
> 
> Based on results from the fixed test suite it also works as expected,
> just with much lower precision than what I used to get from 2.6.9 and
> 2.6.18.
> 
> However, it still returns complete bonkers for stats. 
> 
> Example (same class, I just moved the hierarchy around a bit trying to
> get a better fix on this so it is now 1:15).
> 
> class cbq 1:15 parent 1: leaf 76: rate 5600Kbit (bounded) prio 1
>  Sent 10920592 bytes 14420 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
>   borrowed 8311 overactions 0 avgidle 78 undertime 0
> 
> It is bounded, but according to stats it has borrowed and has no
> overactions. 
> 
> If the stats are to be believed it is a bug somewhere which is eluding
> me (and my test suite and printks are wrong somehow). 
> 
> Alternatively, it may be a bug with the stats themselves which once
> again I do not see in the actual sch_cbq.c file.

For now I could only find some explanation in this place:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=net/sched/sch_cbq.c;h=3846d65bc03ec7a7de7e6ca674dc6c2b255dc570;hb=HEAD

820 static __inline__ struct sk_buff *
821 cbq_dequeue_prio(struct Qdisc *sch, int prio)
822 {
...
863                         if (borrow != cl) {
864 #ifndef CBQ_XSTATS_BORROWS_BYTES
865                                 borrow->xstats.borrows++;
866                                 cl->xstats.borrows++;
867 #else
868                                 borrow->xstats.borrows += qdisc_pkt_len(skb);
869                                 cl->xstats.borrows += qdisc_pkt_len(skb);
870 #endif

So, xstats.borrows is updated for lender as well, which might look
wrong/right/funny (depending on your political principles ;-).

It could be your case if the class above has an unbounded child class.
Otherwise, it needs more searching. Btw, I'm not the CBQ expert to
verify (without learning the specs) these borrowing relations. (As a
matter of fact, within a few years I didn't find here many traces of
such (active) experts, so my recommendation would be HTB or HFSC
unless you really know what you're doing ;-)

Regards,
Jarek P.
