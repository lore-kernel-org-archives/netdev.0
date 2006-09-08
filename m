From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: TG3 data corruption (TSO ?)
Date: Fri, 08 Sep 2006 15:40:20 -0700
Message-ID: <1157755220.9584.21.camel@rh4>
References: <1551EAE59135BE47B544934E30FC4FC093FB19@NT-IRVA-0751.brcm.ad.broadcom.com>
 <1157751689.31071.97.camel@localhost.localdomain>
 <1157753242.9584.4.camel@rh4>
 <1157754326.31071.115.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Segher Boessenkool" <segher@kernel.crashing.org>,
	"Linux Kernel list" <linux-kernel@vger.kernel.org>,
	"Paul Mackerras" <paulus@samba.org>,
	"Anton Blanchard" <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:33035 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751225AbWIHWmS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 18:42:18 -0400
To: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>
In-Reply-To: <1157754326.31071.115.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-09-09 at 08:25 +1000, Benjamin Herrenschmidt wrote:
> Ok. I'm trying to figure out what's the best way with fixing that. I can
> see the flamewar coming on wether stores to memory vs. writel shall be
> ordered or not :)
> 
> I'm very reluctant to add another sync instruction to our writel though.
> It needs one already after the stores to prevent leaking out of
> spinlocks (and thus possible mmio vs. mmio order issues on SMP with
> stores from different CPUs being re-ordered). Fixing the above would
> require one before the store as well. We already pay a pretty high price
> for that sync, having 2 would be a real shame.
> 
> (Unfortunately, there is no cheap barrier available for ordering
> cacheable vs. non cacheable storage on PowerPC, they are completely
> separate domains).
> 
> One option I was discussing with others would be to drop that sync after
> the store, and instead start requiring drivers to use mmiowb() (as
> defined by the ia64 folks) to provide ordering of writel's vs. locks.
> But that probably means breaking and then having to fix a while bunch of
> drivers in the tree who haven't been updated to use it...
> 
> I'd rather not have to do that, or even if I go that way, not have to
> add that sync at all before the store and thus get back the few percent
> of perfs lost due to those sync's on some heavy IO benchmarks.
> 
Another way to fix this without requiring drivers to add all kinds of
barriers in the driver code is to add a writel_sync() variant.  So on
powerpc, writel_sync() will have a sync before and after the write.  On
most other architectures, writel_sync() is the same as writel() if the
ordering is guaranteed.  We'll then convert tg3 and other drivers to use
writel_sync() in places where they're needed.

