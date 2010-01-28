From: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Subject: Re: CBQ broken in 2.6
Date: Thu, 28 Jan 2010 19:48:55 +0000
Message-ID: <1264708135.22027.13.camel@magrat.sigsegv.cx>
References: <20100128125317.GA8931@ff.dom.local>
	 <1264685696.4038.14.camel@mare-infinitum.sigsegv.cx>
	 <20100128184519.GA3109@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab2.miniserver.com ([89.200.136.192]:56838 "EHLO
	www.sigsegv.cx" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753320Ab0A1TtA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2010 14:49:00 -0500
In-Reply-To: <20100128184519.GA3109@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jarek,

[snip]


> > Alternatively, it may be a bug with the stats themselves which once
> > again I do not see in the actual sch_cbq.c file.
> 
> For now I could only find some explanation in this place:
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=net/sched/sch_cbq.c;h=3846d65bc03ec7a7de7e6ca674dc6c2b255dc570;hb=HEAD
> 
> 820 static __inline__ struct sk_buff *
> 821 cbq_dequeue_prio(struct Qdisc *sch, int prio)
> 822 {
> ...
> 863                         if (borrow != cl) {
> 864 #ifndef CBQ_XSTATS_BORROWS_BYTES
> 865                                 borrow->xstats.borrows++;
> 866                                 cl->xstats.borrows++;
> 867 #else
> 868                                 borrow->xstats.borrows += qdisc_pkt_len(skb);
> 869                                 cl->xstats.borrows += qdisc_pkt_len(skb);
> 870 #endif
> 
> So, xstats.borrows is updated for lender as well, which might look
> wrong/right/funny (depending on your political principles ;-).

OK. I will look at it. The traffic is actually in a subclass (1:18) so
this may explain it. It definitely does not fit my "political
principles". Borrow should mean how many times the class has borrowed
and overactions should mean the whole lot of overs - delay, borrow,
drop, etc. At least that were the semantics on BSD and other
implementations I dealt with before Linux. 

My problem as well is that my C has always sucked bricks and I use it
once a year when I run into a problem like that. So it takes me a while
to trace it and figure it out.

> 
> It could be your case if the class above has an unbounded child class.
> Otherwise, it needs more searching. Btw, I'm not the CBQ expert to
> verify (without learning the specs) these borrowing relations. (As a
> matter of fact, within a few years I didn't find here many traces of
> such (active) experts, so my recommendation would be HTB or HFSC
> unless you really know what you're doing ;-)

Well, I know CBQ reasonably well from a "network engineer" perspective.
I used to run it production in an ISP 1998 and after that in an SMB
2002-2007. I have also been running it in lab and on my home network for
10+ years. Mostly on BSD though. There was even a point where I
maintained a fork of the patches before they went into the main tree.
The sole reason I ditched BSD was that they plugged it into the pf
framework and it became too big of a hassle to port/maintain the
configs.

I know what I am doing and HTB is not what I want. It is a good algo for
expressing classic commerical relationships (CIR/PIR). It is worse than
CBQ for "sharing" where all of the apps that share are your own and the
scheduler/estimator is good.

Thanks for all the help. 

> 
> Regards,
> Jarek P.
> 
-- 
   Understanding is a three-edged sword:
            your side, their side, and the truth. --Kosh Naranek

A. R. Ivanov
E-mail:  anton.ivanov@kot-begemot.co.uk
WWW:     http://www.kot-begemot.co.uk/


