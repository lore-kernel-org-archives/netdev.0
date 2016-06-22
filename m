From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH RFC] sched: split classification and enqueue
Date: Wed, 22 Jun 2016 19:41:58 +0200
Message-ID: <20160622174158.GH10213@breakpoint.cc>
References: <1466589835-18521-1-git-send-email-fw@strlen.de>
 <CAADnVQJzcbjiB3FPMcuHOftreL3reu+AZyLWeX_et=3_X8_bcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	john fastabend <john.fastabend@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34295 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751396AbcFVRmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 13:42:08 -0400
Content-Disposition: inline
In-Reply-To: <CAADnVQJzcbjiB3FPMcuHOftreL3reu+AZyLWeX_et=3_X8_bcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> On Wed, Jun 22, 2016 at 3:03 AM, Florian Westphal <fw@strlen.de> wrote:
> > Currently classification and enqueue is done in a single step.
> >
> > core acquires the qdisc lock, then calls the ->enqueue() function
> > of the qdisc.
> >
> > Its the job of the qdisc and its attached classifiers to figure out what
> > to do next.
> >
> > Typically the enqueue function will call tc_classify() to lookup a
> > child class, then call ->enqueue of the child qdisc.
> >
> > This can repeat a number of times until a leaf qdisc is reached; this leaf
> > will do the real enqueue operation (pfifo for example).
> >
> > While this approach gives qdiscs and the classifier/action subsystem
> > a lot of control, it has one major drawback:  The root qdisc lock
> > is held for a prolonged period of time while we recurse through
> > the qdisc hierarchy from root to leaf.
> >
> > This (unfinished!) hack splits classification and enqueue into
> > two steps.
> >
> > Before enqueueing the packet and *before* acquiring the root qdisc lock,
> > the new qdisc ->classify() function is invoked.
> 
> I believe John is finalizing his lockless qdisc patches...
> would this split still be needed after qdiscs become lockless?

The RFC series i saw from John did not change the qdiscs to become
lockless; it did however allow adding qdiscs that can tell stack to
not grab the qdisc root lock
[ http://patchwork.ozlabs.org/patch/561780/ ]

Some of the patches in his old RFC series however add percpu counters
etc. which would be needed for this too.

So AFAIU the two approaches complement one another and are not
mutually exclusive.  For a lot of existing schedulers some kind of
central lock is required since qdisc manages single resource (but we
might be able to move some of that work out of locked section).
