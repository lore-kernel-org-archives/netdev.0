From: Ingo Molnar <mingo@elte.hu>
Subject: Re: dynticks + iptables almost stops the boot process [was: Re: 2.6.20-rc6-mm3]
Date: Tue, 6 Feb 2007 17:48:26 +0100
Message-ID: <20070206164826.GA3491@elte.hu>
References: <20070129204528.eb8d695e.akpm@osdl.org> <20070131215241.GB2890@inferi.kami.home> <20070131232130.GC4137@inferi.kami.home> <1170358572.29240.292.camel@localhost.localdomain> <1170360101.29240.297.camel@localhost.localdomain> <20070201211137.GA2830@inferi.kami.home> <1170369202.29240.339.camel@localhost.localdomain> <20070202191802.GA4262@inferi.kami.home> <1170448034.29240.364.camel@localhost.localdomain> <20070202204344.GB4262@inferi.kami.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Mattia Dongili <malattia@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	mingo@redhat.com, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752198AbXBFQsf@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070202204344.GB4262@inferi.kami.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Mattia,

* Mattia Dongili <malattia@linux.it> wrote:

> > I have it halfways reproducible now and I'm working to find the root 
> > cause. Thanks for providing the info.
> 
> Great, I'm obviously available to test any patch :)

Could you try the patch below? The RCU serialization code (a rare call 
but can be common in some types of setups) has a nasty implicit 
dependency on the HZ tick - which until now was a hidden wart but became 
an explicit bug under dynticks. Maybe this is what is slowing down your 
box.

	Ingo

------------------------->
Subject: [patch] dynticks: make sure synchronize_rcu() completes
From: Ingo Molnar <mingo@elte.hu>

synchronize_rcu() has a nasty implicit dependency on the HZ tick: it 
relies on another CPU finishing all RCU work so that this CPU can finish 
its RCU work too - in IRQ context. But wait_for_completion() goes to 
sleep indefinitely on dynticks and there might be no other IRQs to this 
CPU for a long time.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 kernel/rcupdate.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

Index: linux/kernel/rcupdate.c
===================================================================
--- linux.orig/kernel/rcupdate.c
+++ linux/kernel/rcupdate.c
@@ -85,8 +85,13 @@ void synchronize_rcu(void)
 	/* Will wake me after RCU finished */
 	call_rcu(&rcu.head, wakeme_after_rcu);
 
-	/* Wait for it */
-	wait_for_completion(&rcu.completion);
+	/*
+	 * Wait for it. Note: on dynticks RCU completion needs to be
+	 * polled frequently, to make sure we finish work. If this CPU
+	 * goes idle then another CPU cannot finish this CPU's work.
+	 */
+	while (wait_for_completion_timeout(&rcu.completion, HZ/100 ? : 1) == 0)
+		/* nothing */;
 }
 
 static void rcu_barrier_callback(struct rcu_head *notused)
