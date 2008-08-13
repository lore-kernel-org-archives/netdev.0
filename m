From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH diagnostic] Prevent console flood when one CPU sees another
	AWOL via RCU
Date: Tue, 12 Aug 2008 17:25:03 -0700
Message-ID: <20080813002503.GA25397@linux.vnet.ibm.com>
References: <630464.55583.qm@web82105.mail.mud.yahoo.com> <20080810151520.GG8125@linux.vnet.ibm.com> <20080811013538.GA3958@linux.vnet.ibm.com> <20080811113817.GF6925@elte.hu> <20080811131727.GL8125@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Witbrodt <dawitbro@sbcglobal.net>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-kernel@vger.kernel.org, Yinghai Lu <yhlu.kernel@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:55361 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155AbYHMAZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 20:25:05 -0400
Content-Disposition: inline
In-Reply-To: <20080811131727.GL8125@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 06:17:28AM -0700, Paul E. McKenney wrote:
> On Mon, Aug 11, 2008 at 01:38:17PM +0200, Ingo Molnar wrote:
> > 
> > * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > 
> > > And here is the patch.  It is still a bit raw, so the results should 
> > > be viewed with some suspicion.  It adds a default-off kernel parameter 
> > > CONFIG_RCU_CPU_STALL which must be enabled.
> > > 
> > > Rather than exponential backoff, it backs off to once per 30 seconds. 
> > > My feeling upon thinking on it was that if you have stalled RCU grace 
> > > periods for that long, a few extra printk() messages are probably the 
> > > least of your worries...
> > 
> > while this wont debug problems were timer irqs are genuinely stuck for 
> > long periods of time, it should find problems with RCU completion logic 
> > itself in the presence of correct timer irqs - and the lack of any 
> > messages from this debug option should point the finger more firmly in 
> > the direction of stalled timer irqs.
> > 
> > So i find this debug feature rather useful and have applied it to 
> > tip/core/rcu (and cleaned it up a bit). I renamed the config option to 
> > CONFIG_DEBUG_RCU_STALL to make it more in line with usual debug option 
> > names. Lets see whether -tip testing finds any false positives.
> 
> Sounds good!
> 
> For whatever it is worth, this diagnostic can also locate latency issues
> in non-CONFIG_PREEMPT kernels, even when those problems are outside of
> preempt_disable() regions.  Latency tracer is of course a better tool
> for things -inside- of preempt_disable() regions.

One small change needed to keep from flooding the console when one
CPU notices that another is AWOL.  Unless I am missing something subtle.
Otherwise the cleanups look good!

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

 rcuclassic.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/rcuclassic.c b/kernel/rcuclassic.c
index 56b8712..dab2676 100644
--- a/kernel/rcuclassic.c
+++ b/kernel/rcuclassic.c
@@ -308,6 +308,7 @@ static void print_other_cpu_stall(struct rcu_ctrlblk *rcp)
 		spin_unlock(&rcp->lock);
 		return;
 	}
+	rcp->gp_check = get_seconds() + 30;
 	spin_unlock(&rcp->lock);
 
 	/* OK, time to rat on our buddy... */
