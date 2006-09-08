From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: TG3 data corruption (TSO ?)
Date: Sat, 09 Sep 2006 07:46:02 +1000
Message-ID: <1157751962.31071.102.camel@localhost.localdomain>
References: <1551EAE59135BE47B544934E30FC4FC093FB19@NT-IRVA-0751.brcm.ad.broadcom.com>
	 <9EAEC3B2-260E-444E-BCA1-3C9806340F65@kernel.crashing.org>
	 <1157745256.5344.8.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Segher Boessenkool <segher@kernel.crashing.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:11145 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1751215AbWIHVqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2006 17:46:21 -0400
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1157745256.5344.8.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-09-08 at 12:54 -0700, Michael Chan wrote:
> On Fri, 2006-09-08 at 21:29 +0200, Segher Boessenkool wrote:
> 
> > I've got a patch that seems so solve the problem, it needs more testing
> > though (maybe Ben can do this :-) ).  The problem is that there should
> > be quite a few wmb()'s in the code that are just not there; adding some
> > to tg3_set_txd() seems to fix the immediate problem but more is needed
> > (and I don't see why those should be needed, unless tg3_set_txd() is
> > updating a life ring entry in place or something like that).
> > 
> > More testing is needed, but the problem is definitely the lack of memory
> > ordering.
> > 
> Oh, we know about this.  The powerpc writel() used to have memory
> barriers in 2.4 kernels but not any more in 2.6 kernels.  Red Hat's
> version of tg3 has extra wmb()'s to fix this problem.  David doesn't
> think that the upstream version of tg3 should have these wmb()'s, and
> the problem should instead be fixed in powerpc's writel().

The PowerPC writel has a full sync _after_ the write, mostly to prevent
it from leaking out of a spinlock, and for ordering it vs. other
writel's or readl's. It doesn't provide any ordering guarantee vs
cacheable storage (and was never intended to do so afaik). Such ordering
shall
be provided explicitely. It's possible that 2.4 used a big hammer
approach but we've since been actively fixing drivers for that. It's to
be noted that PowerPC might not be the only architecture affected as I
don't think that in general, you have ordering guarantees between
cacheable and non-cacheable stores unless you use explicit barriers.

Thus I disagree with "fixing" the powerpc writel(). The barries shall
definitely go into tg3.

Cheers,
Ben.




