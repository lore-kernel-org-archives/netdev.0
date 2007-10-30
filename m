From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net: avoid race between netpoll and network fast path
Date: Mon, 29 Oct 2007 21:26:11 -0700 (PDT)
Message-ID: <20071029.212611.152845077.davem@davemloft.net>
References: <47158540.7000709@oracle.com>
	<20071016.210613.71104656.davem@davemloft.net>
	<4715A1B6.5020300@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, netdev@vger.kernel.org
To: tina.yang@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49765
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751351AbXJ3E0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 00:26:16 -0400
In-Reply-To: <4715A1B6.5020300@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tina Yang <tina.yang@oracle.com>
Date: Tue, 16 Oct 2007 22:46:30 -0700

> 	The precise race is
> 	1) net_rx_action get the dev from poll_list
> 	2) at the same time, netpoll poll_napi() get a hold of the poll lock
> 	   and calls ->poll(), remove dev from the poll list
> 	3) after it finishes, net_rx_action get the poll lock, and calls
> 	   ->poll() the second time, and panic when trying to remove (again)
> 	   the dev from the poll list.

This is trivial to fix.

I'll check the following into 2.6.14 and backport it to
the -stable trees.

[NET]: Fix race between poll_napi() and net_rx_action()

netpoll_poll_lock() synchronizes the ->poll() invocation
code paths, but once we have the lock we have to make
sure that NAPI_STATE_SCHED is still set.  Otherwise we
get:

	cpu 0			cpu 1

	net_rx_action()		poll_napi()
	netpoll_poll_lock()	... spin on ->poll_lock
	->poll()
	  netif_rx_complete
	netpoll_poll_unlock()	acquire ->poll_lock()
				->poll()
				 netif_rx_complete()
				 CRASH

Based upon a bug report from Tina Yang.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index 853c8b5..02e7d83 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2172,7 +2172,15 @@ static void net_rx_action(struct softirq_action *h)
 
 		weight = n->weight;
 
-		work = n->poll(n, weight);
+		/* This NAPI_STATE_SCHED test is for avoiding a race
+		 * with netpoll's poll_napi().  Only the entity which
+		 * obtains the lock and sees NAPI_STATE_SCHED set will
+		 * actually make the ->poll() call.  Therefore we avoid
+		 * accidently calling ->poll() when NAPI is not scheduled.
+		 */
+		work = 0;
+		if (test_bit(NAPI_STATE_SCHED, &n->state))
+			work = n->poll(n, weight);
 
 		WARN_ON_ONCE(work > weight);
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index bf8d18f..c499b5c 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -116,6 +116,29 @@ static __sum16 checksum_udp(struct sk_buff *skb, struct udphdr *uh,
  * network adapter, forcing superfluous retries and possibly timeouts.
  * Thus, we set our budget to greater than 1.
  */
+static int poll_one_napi(struct netpoll_info *npinfo,
+			 struct napi_struct *napi, int budget)
+{
+	int work;
+
+	/* net_rx_action's ->poll() invocations and our's are
+	 * synchronized by this test which is only made while
+	 * holding the napi->poll_lock.
+	 */
+	if (!test_bit(NAPI_STATE_SCHED, &napi->state))
+		return budget;
+
+	npinfo->rx_flags |= NETPOLL_RX_DROP;
+	atomic_inc(&trapped);
+
+	work = napi->poll(napi, budget);
+
+	atomic_dec(&trapped);
+	npinfo->rx_flags &= ~NETPOLL_RX_DROP;
+
+	return budget - work;
+}
+
 static void poll_napi(struct netpoll *np)
 {
 	struct netpoll_info *npinfo = np->dev->npinfo;
@@ -123,17 +146,13 @@ static void poll_napi(struct netpoll *np)
 	int budget = 16;
 
 	list_for_each_entry(napi, &np->dev->napi_list, dev_list) {
-		if (test_bit(NAPI_STATE_SCHED, &napi->state) &&
-		    napi->poll_owner != smp_processor_id() &&
+		if (napi->poll_owner != smp_processor_id() &&
 		    spin_trylock(&napi->poll_lock)) {
-			npinfo->rx_flags |= NETPOLL_RX_DROP;
-			atomic_inc(&trapped);
-
-			napi->poll(napi, budget);
-
-			atomic_dec(&trapped);
-			npinfo->rx_flags &= ~NETPOLL_RX_DROP;
+			budget = poll_one_napi(npinfo, napi, budget);
 			spin_unlock(&napi->poll_lock);
+
+			if (!budget)
+				break;
 		}
 	}
 }

