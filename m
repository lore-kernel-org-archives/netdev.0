From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] mpls: Add missing RCU-bh read side critical section
 locking in output path
Date: Tue, 28 Jun 2016 11:14:04 +0300
Message-ID: <20160628081404.GT10080@wantstofly.org>
References: <20160620180527.GU20238@wantstofly.org>
 <20160623.120055.541092448348137374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
	roopa@cumulusnetworks.com, rshearma@brocade.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hmm.wantstofly.org ([138.201.34.84]:48578 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbcF1IOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 04:14:07 -0400
Content-Disposition: inline
In-Reply-To: <20160623.120055.541092448348137374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2016 at 12:00:55PM -0400, David Miller wrote:

> > From: David Barroso <dbarroso@fastly.com>
> > 
> > When locally originated IP traffic hits a route that says to push
> > MPLS labels, we'll get a call chain dst_output() -> lwtunnel_output()
> > -> mpls_output() -> neigh_xmit() -> ___neigh_lookup_noref() where the
> > last function in this chain accesses a RCU-bh protected struct
> > neigh_table pointer without us ever having declared an RCU-bh read
> > side critical section.
> > 
> > As in case of locally originated IP traffic we'll be running in process
> > context, with softirqs enabled, we can be preempted by a softirq at any
> > time, and RCU-bh considers the completion of a softirq as signaling
> > the end of any pending read-side critical sections, so if we do get a
> > softirq here, we can end up with an unexpected RCU grace period and
> > all the nastiness that that comes with.
> > 
> > This patch makes neigh_xmit() take rcu_read_{,un}lock_bh() around the
> > code that expects to be treated as an RCU-bh read side critical section.
> > 
> > Signed-off-by: David Barroso <dbarroso@fastly.com>
> > Signed-off-by: Lennert Buytenhek <lbuytenhek@fastly.com>
> 
> Whilst the case that was used to discover this problem was MPLS, that
> is not the subsystem where the bug exists and is being fixed.
> 
> Therefore please fix your Subject line.
> 
> Thanks.

I'd say that the bug _is_ in the MPLS code, but that we're just fixing
it in a helper function that lives elsewhere (and which is only used by
MPLS), but yeah, the subject line and the patch body don't match up. :(
I've resubmitted the patch with the commit message below, I hope that
that'll do.

Thanks!


===

[PATCH] neigh: Explicitly declare RCU-bh read side critical section in neigh_xmit()

From: David Barroso <dbarroso@fastly.com>

neigh_xmit() expects to be called inside an RCU-bh read side critical
section, and while one of its two current callers gets this right, the
other one doesn't.

More specifically, neigh_xmit() has two callers, mpls_forward() and
mpls_output(), and while both callers call neigh_xmit() under
rcu_read_lock(), this provides sufficient protection for neigh_xmit()
only in the case of mpls_forward(), as that is always called from
softirq context and therefore doesn't need explicit BH protection,
while mpls_output() can be called from process context with softirqs
enabled.

When mpls_output() is called from process context, with softirqs
enabled, we can be preempted by a softirq at any time, and RCU-bh
considers the completion of a softirq as signaling the end of any
pending read-side critical sections, so if we do get a softirq
while we are in the part of neigh_xmit() that expects to be run inside
an RCU-bh read side critical section, we can end up with an unexpected
RCU grace period running right in the middle of that critical section,
making things go boom.

This patch fixes this impedance mismatch in the callee, by making
neigh_xmit() always take rcu_read_{,un}lock_bh() around the code that
expects to be treated as an RCU-bh read side critical section, as this
seems a safer option than fixing it in the callers.

Fixes: 4fd3d7d9e868f ("neigh: Add helper function neigh_xmit")
Signed-off-by: David Barroso <dbarroso@fastly.com>
Signed-off-by: Lennert Buytenhek <lbuytenhek@fastly.com>
Acked-by: David Ahern <dsa@cumulusnetworks.com>
Acked-by: Robert Shearman <rshearma@brocade.com>
