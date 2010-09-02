From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Thu, 2 Sep 2010 10:26:25 -0700
Message-ID: <20100902172625.GD2349@linux.vnet.ibm.com>
References: <20100813143904.GA27261@gondor.apana.org.au>
 <20100813162912.GJ2511@linux.vnet.ibm.com>
 <20100813175157.GA29586@gondor.apana.org.au>
 <20100814.235033.02286546.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, linville@tuxdriver.com,
	netdev@vger.kernel.org, mingo@elte.hu,
	linux-kernel@vger.kernel.org, peterz@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:54648 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752853Ab0IBR01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Sep 2010 13:26:27 -0400
Content-Disposition: inline
In-Reply-To: <20100814.235033.02286546.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 14, 2010 at 11:50:33PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 13 Aug 2010 13:51:57 -0400
> 
> > On Fri, Aug 13, 2010 at 09:29:12AM -0700, Paul E. McKenney wrote:
> >> But all in all, mightn't it be easier to remove the checks from
> >> _local_bh_enable(), and then just use rcu_read_lock_bh()?  Have those
> >> checks really been that helpful in finding bugs?  ;-)
> > 
> > You are right.  It would be much simpler to simply have it not
> > warn.
> 
> For now I'm going to assume that this is how the issue will be
> addressed.

And here is the patch, at long last.  Adding Ingo and Peter Z to CC
in case there is some problem with this approach that I cannot see.

							Thanx, Paul

commit 095d050d5d04344d3cdd4ff8558ea8709e3c4beb
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Thu Sep 2 10:07:21 2010 -0700

    softirq: adjust error check
    
    The error check for _local_bh_enable_ip() warns on both in_irq() and
    irqs_disabled().  The check for in_irq() is necessary, because a hardirq
    might well have interrupted bh execution, in which case it is simply
    not possible for the hardirq to exclude the bh that got interrupted.
    
    However, it is perfectly reasonable to disable bh while hardirqs are
    disabled, and this in fact promotes common code.  This commit therefore
    removes the irqs_disabled() check.
    
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/kernel/softirq.c b/kernel/softirq.c
index 07b4f1b..3cff1bb 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -140,7 +140,7 @@ EXPORT_SYMBOL(_local_bh_enable);
 
 static inline void _local_bh_enable_ip(unsigned long ip)
 {
-	WARN_ON_ONCE(in_irq() || irqs_disabled());
+	WARN_ON_ONCE(in_irq());
 #ifdef CONFIG_TRACE_IRQFLAGS
 	local_irq_disable();
 #endif
