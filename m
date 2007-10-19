From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Fix possible dev_deactivate race condition
Date: Fri, 19 Oct 2007 13:36:24 +0800
Message-ID: <20071019053624.GA10560@gondor.apana.org.au>
References: <E1IiWnJ-0000ne-00@gondolin.me.apana.org.au> <1192745137.7367.40.camel@pasglop> <alpine.LFD.0.999.0710181549330.26902@woody.linux-foundation.org> <1192749449.7367.51.camel@pasglop> <alpine.LFD.0.999.0710181627091.26902@woody.linux-foundation.org> <20071019023219.GB8453@gondor.apana.org.au> <alpine.LFD.0.999.0710181941020.26902@woody.linux-foundation.org> <alpine.LFD.0.999.0710182007170.26902@woody.linux-foundation.org> <20071019042025.GA9617@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	akpm@linux-foundation.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linuxppc-dev@ozlabs.org, Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3430 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752268AbXJSFgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 01:36:49 -0400
Content-Disposition: inline
In-Reply-To: <20071019042025.GA9617@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2007 at 12:20:25PM +0800, Herbert Xu wrote:
>
> In fact this bug exists elsewhere too.  For example, the network
> stack does this in net/sched/sch_generic.c:
> 
>         /* Wait for outstanding qdisc_run calls. */
> 	while (test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
> 		yield();
> 
> This has the same problem as the current synchronize_irq code.

OK here is the fix for that case.

[NET]: Fix possible dev_deactivate race condition

The function dev_deactivate is supposed to only return when
all outstanding transmissions have completed.  Unfortunately
it is possible for store operations in the driver's transmit
function to only become visible after dev_deactivate returns.

This patch fixes this by taking the queue lock after we see
the end of the queue run.  This ensures that all effects of
any previous transmit calls are visible.

If however we detect that there is another queue run occuring,
then we'll warn about it because this should never happen as
we have pointed dev->qdisc to noop_qdisc within the same queue
lock earlier in the functino.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e01d576..b3b7420 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -556,6 +556,7 @@ void dev_deactivate(struct net_device *dev)
 {
 	struct Qdisc *qdisc;
 	struct sk_buff *skb;
+	int running;
 
 	spin_lock_bh(&dev->queue_lock);
 	qdisc = dev->qdisc;
@@ -571,12 +572,31 @@ void dev_deactivate(struct net_device *dev)
 
 	dev_watchdog_down(dev);
 
-	/* Wait for outstanding dev_queue_xmit calls. */
+	/* Wait for outstanding qdisc-less dev_queue_xmit calls. */
 	synchronize_rcu();
 
 	/* Wait for outstanding qdisc_run calls. */
-	while (test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
-		yield();
+	do {
+		while (test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
+			yield();
+
+		/*
+		 * Double-check inside queue lock to ensure that all effects
+		 * of the queue run are visible when we return.
+		 */
+		spin_lock_bh(&dev->queue_lock);
+		running = test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
+		spin_unlock_bh(&dev->queue_lock);
+
+		/*
+		 * The running flag should never be set at this point because
+		 * we've already set dev->qdisc to noop_qdisc *inside* the same
+		 * pair of spin locks.  That is, if any qdisc_run starts after
+		 * our initial test it should see the noop_qdisc and then
+		 * clear the RUNNING bit before dropping the queue lock.  So
+		 * if it is set here then we've found a bug.
+		 */
+	} while (WARN_ON_ONCE(running));
 }
 
 void dev_init_scheduler(struct net_device *dev)
