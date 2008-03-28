From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 09:22:34 +0800
Message-ID: <20080328012234.GA20465@gondor.apana.org.au>
References: <47EC3182.7080005@sun.com> <20080327.170235.53674739.davem@davemloft.net> <47EC399E.90804@sun.com> <20080327.173418.18777696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matheos.Worku@Sun.COM, jesse.brandeburg@intel.com,
	jarkao2@gmail.com, netdev@vger.kernel.org, hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45042 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753456AbYC1BWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 21:22:47 -0400
Content-Disposition: inline
In-Reply-To: <20080327.173418.18777696.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2008 at 05:34:18PM -0700, David Miller wrote:
>
> The first cpu will get into __qdisc_run(), but the other
> ones will just q->enqueue() and exit since the first cpu
> has indicated it is processing the qdisc.

Indeed.  Since I created the problem it's only fair that I get
to fix it too :)

[NET]: Add preemption point in qdisc_run

The qdisc_run loop is currently unbounded and runs entirely
in a softirq.  This is bad as it may create an unbounded softirq
run.

This patch fixes this by calling need_resched and breaking out
if necessary.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 10b5c08..80d53dd 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -187,6 +187,10 @@ void __qdisc_run(struct net_device *dev)
 	do {
 		if (!qdisc_restart(dev))
 			break;
+		if (need_resched()) {
+			netif_schedule(dev);
+			break;
+		}
 	} while (!netif_queue_stopped(dev));
 
 	clear_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
