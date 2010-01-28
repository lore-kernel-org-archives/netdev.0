From: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Subject: Re: CBQ broken in 2.6
Date: Thu, 28 Jan 2010 13:34:56 +0000
Message-ID: <1264685696.4038.14.camel@mare-infinitum.sigsegv.cx>
References: <20100128125317.GA8931@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab2.miniserver.com ([89.200.136.192]:60867 "EHLO
	www.sigsegv.cx" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752170Ab0A1NfA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2010 08:35:00 -0500
In-Reply-To: <20100128125317.GA8931@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jarek,

The class was created as bounded and never changed. I do a full reload
of the hierarchy including a root qdisc delete via a script instead of
trying to adjust it. 

It has 7 or so children and one sibling. It is parented to root.

I have recompiled sch_cbq.c with a number of printks in strategic
places. I have also added some debug output to tc. I have also rewritten
my test suite.

The results are as follows

Based on the printks cbq_set_lss and the cbq_change_class functions
correctly.

It indeed sets cl->borrow and cl->share to NULL as expected.

Based on results from the fixed test suite it also works as expected,
just with much lower precision than what I used to get from 2.6.9 and
2.6.18.

However, it still returns complete bonkers for stats. 

Example (same class, I just moved the hierarchy around a bit trying to
get a better fix on this so it is now 1:15).

class cbq 1:15 parent 1: leaf 76: rate 5600Kbit (bounded) prio 1
 Sent 10920592 bytes 14420 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
  borrowed 8311 overactions 0 avgidle 78 undertime 0

It is bounded, but according to stats it has borrowed and has no
overactions. 

If the stats are to be believed it is a bug somewhere which is eluding
me (and my test suite and printks are wrong somehow). 

Alternatively, it may be a bug with the stats themselves which once
again I do not see in the actual sch_cbq.c file.

Brgds,


On Thu, 2010-01-28 at 12:53 +0000, Jarek Poplawski wrote:
> On 27-01-2010 13:28, Anton Ivanov wrote:
> > Thanks it is indeed sch_cbq.c,
> > 
> > I have been going through the code in the meantime and found a place
> > where cl->tparent can be modified further down in the routine in
> > question. There is an invocation of cbq_set_lss() around the end of
> > cbq_change_class() which can do that.
> > 
> > I am rebuilding the kernel for my CBQ box with a few printks at the
> > moment to see if it modified there or not.
> > 
> > In any case here is the tell-tale symptom:
> > 
> > class cbq 1:16 parent 1: leaf 76: rate 5600Kbit (bounded,isolated) prio
> > 2
> >  Sent 162051 bytes 925 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >   borrowed 201 overactions 0 avgidle 78 undertime 0
> > 
> > That is a bounded class. Its borrowed should be always 0 no matter what.
> > That is basically a broken CBQ implementation.
> > 
> > An elementary network test suite shows the same result - it is being
> > allowed to borrow.
> > 
> > I am happy to send the whole config if necessary if someone wants to
> > look at it.
> 
> Was this class created as bounded or changed later? Did it have any
> child?
> 
> Jarek P.
> 
-- 
   Understanding is a three-edged sword:
            your side, their side, and the truth. --Kosh Naranek

A. R. Ivanov
E-mail:  anton.ivanov@kot-begemot.co.uk
WWW:     http://www.kot-begemot.co.uk/


