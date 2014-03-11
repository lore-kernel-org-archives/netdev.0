From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC PATCH 2/2] netpoll: Don't poll for received packets
Date: Tue, 11 Mar 2014 01:45:11 -0700
Message-ID: <87wqg1dsyw.fsf_-_@xmission.com>
References: <871ty9qvaf.fsf_-_@xmission.com> <87vbvlpgnk.fsf_-_@xmission.com>
	<1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311.004217.1616529960369263682.davem@davemloft.net>
	<1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
	<87a9cxf7mp.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47076 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725AbaCKIpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 04:45:17 -0400
In-Reply-To: <87a9cxf7mp.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 11 Mar 2014 01:43:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When calling drivers napi poll function pass it a budget of 0, to
request that no rx packets be processed, and warn if any rx packets
are actually processed.

Additionally remove the drop_mon tracepoint as nothing interesting
should be happening in netpoll, and running an arbitrary tracepoint
in irq context is probably a bad idea.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/netpoll.c |   28 +++++++++-------------------
 1 files changed, 9 insertions(+), 19 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index e883eff6799e..f95ca7f9d246 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -114,48 +114,38 @@ static void queue_process(struct work_struct *work)
  * trylock here and interrupts are already disabled in the softirq
  * case. Further, we test the poll_owner to avoid recursion on UP
  * systems where the lock doesn't exist.
- *
- * In cases where there is bi-directional communications, reading only
- * one message at a time can lead to packets being dropped by the
- * network adapter, forcing superfluous retries and possibly timeouts.
- * Thus, we set our budget to greater than 1.
  */
-static int poll_one_napi(struct netpoll_info *npinfo,
-			 struct napi_struct *napi, int budget)
+static void poll_one_napi(struct netpoll_info *npinfo,
+			  struct napi_struct *napi)
 {
 	int work;
-
 	/* net_rx_action's ->poll() invocations and our's are
 	 * synchronized by this test which is only made while
 	 * holding the napi->poll_lock.
 	 */
 	if (!test_bit(NAPI_STATE_SCHED, &napi->state))
-		return budget;
+		return;
 
 	set_bit(NAPI_STATE_NPSVC, &napi->state);
 
-	work = napi->poll(napi, budget);
-	trace_napi_poll(napi);
+	/* Use a budget of 0 to request the drivers not process
+	 * their receive queue.  Warn when they do anyway.
+	 */
+	work = napi->poll(napi, 0);
+	WARN_ON_ONCE(work != 0);
 
 	clear_bit(NAPI_STATE_NPSVC, &napi->state);
-
-	return budget - work;
 }
 
 static void poll_napi(struct net_device *dev)
 {
 	struct napi_struct *napi;
-	int budget = 16;
 
 	list_for_each_entry(napi, &dev->napi_list, dev_list) {
 		if (napi->poll_owner != smp_processor_id() &&
 		    spin_trylock(&napi->poll_lock)) {
-			budget = poll_one_napi(rcu_dereference_bh(dev->npinfo),
-					       napi, budget);
+			poll_one_napi(rcu_dereference_bh(dev->npinfo), napi);
 			spin_unlock(&napi->poll_lock);
-
-			if (!budget)
-				break;
 		}
 	}
 }
-- 
1.7.5.4
