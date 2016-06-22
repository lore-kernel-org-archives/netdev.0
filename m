From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH RFC] sched: split classification and enqueue
Date: Wed, 22 Jun 2016 19:23:44 +0200
Message-ID: <20160622172344.GG10213@breakpoint.cc>
References: <1466589835-18521-1-git-send-email-fw@strlen.de>
 <CAM_iQpXGX=jPO7q=W32o3X2_4ce5PbY2PuTMhkmhtGP6PXuH4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34258 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751082AbcFVRXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 13:23:49 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpXGX=jPO7q=W32o3X2_4ce5PbY2PuTMhkmhtGP6PXuH4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, Jun 22, 2016 at 3:03 AM, Florian Westphal <fw@strlen.de> wrote:
> >
> > This (unfinished!) hack splits classification and enqueue into
> > two steps.
> >
> > Before enqueueing the packet and *before* acquiring the root qdisc lock,
> > the new qdisc ->classify() function is invoked.
> >
> > This function -- much like enqueue in the current scheme -- looks up
> > a child class and/or determines the next qdisc where the packet needs
> > to be handled via the classifier action subsystem.
> > Then it invokes the new ->classify() hook of the child, which can repeat
> > until the leaf qdisc is reached.
> 
> Then how is the atomicity guaranteed? One of the important
> purposes of the qdisc lock is to guarantee the atomicity of any
> change of in the whole hierarchy, i.e., qdisc/class/filter/action.

Not in this PoC, but I think that this could be solved e.g. by adding a
sequence counter that gets sampled pre-classify, we'd then only have to
check post-aquiring the root lock if its unchanged.  If not, some
class/filter, etc changed and we can just drop skb (or re-do the
classification, but I dislike such loops).

Only config changes would increment the counter, so it should not be
a lot of overhead.
