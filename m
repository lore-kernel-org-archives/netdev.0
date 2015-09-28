From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2] netpoll: Drop budget parameter from NAPI
 polling call hierarchy
Date: Mon, 28 Sep 2015 09:16:17 -0700
Message-ID: <20150928161426.1098.72362.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34115 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933922AbbI1QQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 12:16:19 -0400
Received: by padhy16 with SMTP id hy16so178383197pad.1
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 09:16:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For some reason we were carrying the budget value around between the
various calls to napi->poll.  If for example one of the drivers called had
a bug in which it returned a non-zero value for work this could result in
the budget value becoming negative.

Rather than carry around a value of budget that is 0 or less we can instead
just loop through and pass 0 to each napi->poll call.  If any driver
returns a value for work done that is non-zero then we can report that
driver and continue rather than allowing a bad actor to make the budget
value negative and pass that negative value to napi->poll.

Note, the only actual change here is that instead of letting budget become
negative we are keeping it at 0 regardless of the value returned for work
since it should not be possible for the polling routine to do any actual
work with a budget of 0.  So if the polling routine returns a non-0 value
we are just reporting it and continuing with a budget of 0 rather than
letting that work value be subtracted from the budget of 0.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---

v2: Rebased patch to incorporate latest changes to poll_one_napi.

 net/core/netpoll.c |   23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 8bdada242a7d..94acfc89ad97 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -140,7 +140,7 @@ static void queue_process(struct work_struct *work)
  * case. Further, we test the poll_owner to avoid recursion on UP
  * systems where the lock doesn't exist.
  */
-static int poll_one_napi(struct napi_struct *napi, int budget)
+static void poll_one_napi(struct napi_struct *napi)
 {
 	int work = 0;
 
@@ -149,33 +149,33 @@ static int poll_one_napi(struct napi_struct *napi, int budget)
 	 * holding the napi->poll_lock.
 	 */
 	if (!test_bit(NAPI_STATE_SCHED, &napi->state))
-		return budget;
+		return;
 
 	/* If we set this bit but see that it has already been set,
 	 * that indicates that napi has been disabled and we need
 	 * to abort this operation
 	 */
 	if (test_and_set_bit(NAPI_STATE_NPSVC, &napi->state))
-		goto out;
+		return;
 
-	work = napi->poll(napi, budget);
-	WARN_ONCE(work > budget, "%pF exceeded budget in poll\n", napi->poll);
+	/* We explicilty pass the polling call a budget of 0 to
+	 * indicate that we are clearing the Tx path only.
+	 */
+	work = napi->poll(napi, 0);
+	WARN_ONCE(work, "%pF exceeded budget in poll\n", napi->poll);
 	trace_napi_poll(napi);
 
 	clear_bit(NAPI_STATE_NPSVC, &napi->state);
-
-out:
-	return budget - work;
 }
 
-static void poll_napi(struct net_device *dev, int budget)
+static void poll_napi(struct net_device *dev)
 {
 	struct napi_struct *napi;
 
 	list_for_each_entry(napi, &dev->napi_list, dev_list) {
 		if (napi->poll_owner != smp_processor_id() &&
 		    spin_trylock(&napi->poll_lock)) {
-			budget = poll_one_napi(napi, budget);
+			poll_one_napi(napi);
 			spin_unlock(&napi->poll_lock);
 		}
 	}
@@ -185,7 +185,6 @@ static void netpoll_poll_dev(struct net_device *dev)
 {
 	const struct net_device_ops *ops;
 	struct netpoll_info *ni = rcu_dereference_bh(dev->npinfo);
-	int budget = 0;
 
 	/* Don't do any rx activity if the dev_lock mutex is held
 	 * the dev_open/close paths use this to block netpoll activity
@@ -208,7 +207,7 @@ static void netpoll_poll_dev(struct net_device *dev)
 	/* Process pending work on NIC */
 	ops->ndo_poll_controller(dev);
 
-	poll_napi(dev, budget);
+	poll_napi(dev);
 
 	up(&ni->dev_lock);
 
