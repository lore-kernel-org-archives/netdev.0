From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 19:29:28 +0800
Message-ID: <20080328112928.GA23547@gondor.apana.org.au>
References: <47EC399E.90804@sun.com> <20080327.173418.18777696.davem@davemloft.net> <20080328012234.GA20465@gondor.apana.org.au> <20080327.183844.74572930.davem@davemloft.net> <20080328102931.GA23039@gondor.apana.org.au> <20080328105629.GG1011@elte.hu> <20080328110621.GA23342@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Matheos.Worku@Sun.COM,
	jesse.brandeburg@intel.com, jarkao2@gmail.com,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44428 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753091AbYC1L3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 07:29:44 -0400
Content-Disposition: inline
In-Reply-To: <20080328110621.GA23342@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 07:06:21PM +0800, Herbert Xu wrote:
>
> Anyway, I've just realised that even if it does get updated, we still
> need a better bound to avoid starving other local softirq events so
> this is probably moot.

OK, since we don't really have any good ways of balancing softirq
events with each other, I've taken Dave's suggestion of checking
the jiffies as is done with NAPI.  I've kept the need_resched to
minimise the scheduling latency.

[NET]: Add preemption point in qdisc_run

The qdisc_run loop is currently unbounded and runs entirely
in a softirq.  This is bad as it may create an unbounded softirq
run.

This patch fixes this by calling need_resched and breaking out
if necessary.

It also adds a break out if the jiffies value changes since that
would indicate we've been transmitting for too long which starves
other softirqs.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 10b5c08..b741618 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -184,10 +184,22 @@ static inline int qdisc_restart(struct net_device *dev)
 
 void __qdisc_run(struct net_device *dev)
 {
-	do {
-		if (!qdisc_restart(dev))
+	unsigned long start_time = jiffies;
+
+	while (qdisc_restart(dev)) {
+		if (netif_queue_stopped(dev))
+			break;
+
+		/*
+		 * Postpone processing if
+		 * 1. another process needs the CPU;
+		 * 2. we've been doing it for too long.
+		 */
+		if (need_resched() || jiffies != start_time) {
+			netif_schedule(dev);
 			break;
-	} while (!netif_queue_stopped(dev));
+		}
+	}
 
 	clear_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
 }
