From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] pktgen: allow faster module unload
Date: Sun, 21 Nov 2010 18:07:31 +0100
Message-ID: <1290359251.2756.134.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39899 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754525Ab0KURHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Nov 2010 12:07:43 -0500
Received: by wwa36 with SMTP id 36so6481131wwa.1
        for <netdev@vger.kernel.org>; Sun, 21 Nov 2010 09:07:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unloading pktgen module needs ~6 seconds on a 64 cpus machine, to stop
64 kthreads.

Add a pktgen_exiting variable to let kernel threads die faster, so that
kthread_stop() doesnt have to wait too long for them. This variable is
not tested in fast path.

Note : Before exiting from pktgen_thread_worker(), we must make sure
kthread_stop() is waiting for this thread to be stopped, like its done
in kernel/softirq.c

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/pktgen.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 52fc1e0..f6f3d5d 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -395,6 +395,8 @@ struct pktgen_hdr {
 	__be32 tv_usec;
 };
 
+bool pktgen_exiting __read_mostly;
+
 struct pktgen_thread {
 	spinlock_t if_lock;		/* for list of devices */
 	struct list_head if_list;	/* All device here */
@@ -3451,11 +3453,6 @@ static void pktgen_rem_thread(struct pktgen_thread *t)
 
 	remove_proc_entry(t->tsk->comm, pg_proc_dir);
 
-	mutex_lock(&pktgen_thread_lock);
-
-	list_del(&t->th_list);
-
-	mutex_unlock(&pktgen_thread_lock);
 }
 
 static void pktgen_resched(struct pktgen_dev *pkt_dev)
@@ -3602,6 +3599,8 @@ static int pktgen_thread_worker(void *arg)
 		pkt_dev = next_to_run(t);
 
 		if (unlikely(!pkt_dev && t->control == 0)) {
+			if (pktgen_exiting)
+				break;
 			wait_event_interruptible_timeout(t->queue,
 							 t->control != 0,
 							 HZ/10);
@@ -3654,6 +3653,13 @@ static int pktgen_thread_worker(void *arg)
 	pr_debug("%s removing thread\n", t->tsk->comm);
 	pktgen_rem_thread(t);
 
+	/* Wait for kthread_stop() or risk corruption */
+	while (!kthread_should_stop()) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule();
+	}
+	__set_current_state(TASK_RUNNING);
+
 	return 0;
 }
 
@@ -3928,6 +3934,7 @@ static void __exit pg_cleanup(void)
 	struct list_head *q, *n;
 
 	/* Stop all interfaces & threads */
+	pktgen_exiting = true;
 
 	list_for_each_safe(q, n, &pktgen_threads) {
 		t = list_entry(q, struct pktgen_thread, th_list);


