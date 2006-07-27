From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Thu, 27 Jul 2006 12:17:51 +1000
Message-ID: <1153966671.6904.71.camel@localhost.localdomain>
References: <20060718081625.GA13830@2ka.mipt.ru>
	 <20060718230121.GA31474@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.tip.net.au ([203.10.76.45]:6619 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1751024AbWG0CRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 22:17:54 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060718230121.GA31474@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-07-19 at 03:01 +0400, Alexey Kuznetsov wrote:
> Hello!
> 
> Can I ask couple of questions? Just as a person who looked at VJ's
> slides once and was confused. And startled, when found that it is not
> considered as another joke of genuis. :-)

Hi Alexey!

> About locks:
> 
> > 	  is completely lockless (there is one irq lock when skb 
> > is queued/dequeued into netchannels queue in hard/soft irq, 
> 
> Equivalent of socket spinlock.

I don't think they are equivalent.  In channels, this can be split into
two locks, queue lock and an dequeue lock, which operate independently.
The socket spinlock cannot.  Moreover, in the case where there is a
guarantee about IRQs being bound to a single CPU (as Dave's ideas on
MSI), the queue lock is no longer required.  In the case where there is
a single reader of the socket (or, as VJ did, the other end is in
userspace), no dequeue lock is required.

> VJ slides describe a totally different scheme, where softirq part is omitted
> completely, protocol processing is moved to user space as whole.
> It is an amazing toy. But I see nothing, which could promote its status
> to practical. Exokernels used to do this thing for ages, and all the
> performance gains are compensated by overcomplicated classification
> engine, which has to remain in kernel and essentially to do the same
> work which routing/firewalling/socket hash tables do.

My feeling is that modern cards will do partial demux for us; whether we
use netchannels or not, we should use that to accelerate lookup.  Making
card aim MSI at same CPU for same flow is a start (and as Dave said,
much less code).  As the next step, having the card give us a cookie
too, would allow us to explicitly skip first level of lookup.  This
should allow us to identify which flows are simple enough to be directly
accelerated (whether by channels or something else): no bonding, raw
sockets, non-trivial netfilter rules, connection tracking changes, etc.

Thoughts?
Rusty.
-- 
Help! Save Australia from the worst of the DMCA: http://linux.org.au/law

