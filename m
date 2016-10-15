From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: pktgen: remove rcu locking in pktgen_change_name()
Date: Sat, 15 Oct 2016 17:50:49 +0200
Message-ID: <1476546649.5650.51.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Sperbeck <jsperbeck@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34897 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932236AbcJOPuy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 11:50:54 -0400
Received: by mail-pa0-f68.google.com with SMTP id qn10so7346331pac.2
        for <netdev@vger.kernel.org>; Sat, 15 Oct 2016 08:50:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After Jesper commit back in linux-3.18, we trigger a lockdep
splat in proc_create_data() while allocating memory from
pktgen_change_name().

This patch converts t->if_lock to a mutex, since it is now only
used from control path, and adds proper locking to pktgen_change_name()

1) pktgen_thread_lock to protect the outer loop (iterating threads)
2) t->if_lock to protect the inner loop (iterating devices)

Note that before Jesper patch, pktgen_change_name() was lacking proper
protection, but lockdep was not able to detect the problem.

Fixes: 8788370a1d4b ("pktgen: RCU-ify "if_list" to remove lock in next_to_run()")
Reported-by: John Sperbeck <jsperbeck@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/core/pktgen.c |   17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 5219a9e2127a..306b8f0e03c1 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -216,8 +216,8 @@
 #define M_QUEUE_XMIT		2	/* Inject packet into qdisc */
 
 /* If lock -- protects updating of if_list */
-#define   if_lock(t)           spin_lock(&(t->if_lock));
-#define   if_unlock(t)           spin_unlock(&(t->if_lock));
+#define   if_lock(t)           mutex_lock(&(t->if_lock));
+#define   if_unlock(t)           mutex_unlock(&(t->if_lock));
 
 /* Used to help with determining the pkts on receive */
 #define PKTGEN_MAGIC 0xbe9be955
@@ -423,7 +423,7 @@ struct pktgen_net {
 };
 
 struct pktgen_thread {
-	spinlock_t if_lock;		/* for list of devices */
+	struct mutex if_lock;		/* for list of devices */
 	struct list_head if_list;	/* All device here */
 	struct list_head th_list;
 	struct task_struct *tsk;
@@ -2010,11 +2010,13 @@ static void pktgen_change_name(const struct pktgen_net *pn, struct net_device *d
 {
 	struct pktgen_thread *t;
 
+	mutex_lock(&pktgen_thread_lock);
+
 	list_for_each_entry(t, &pn->pktgen_threads, th_list) {
 		struct pktgen_dev *pkt_dev;
 
-		rcu_read_lock();
-		list_for_each_entry_rcu(pkt_dev, &t->if_list, list) {
+		if_lock(t);
+		list_for_each_entry(pkt_dev, &t->if_list, list) {
 			if (pkt_dev->odev != dev)
 				continue;
 
@@ -2029,8 +2031,9 @@ static void pktgen_change_name(const struct pktgen_net *pn, struct net_device *d
 				       dev->name);
 			break;
 		}
-		rcu_read_unlock();
+		if_unlock(t);
 	}
+	mutex_unlock(&pktgen_thread_lock);
 }
 
 static int pktgen_device_event(struct notifier_block *unused,
@@ -3762,7 +3765,7 @@ static int __net_init pktgen_create_thread(int cpu, struct pktgen_net *pn)
 		return -ENOMEM;
 	}
 
-	spin_lock_init(&t->if_lock);
+	mutex_init(&t->if_lock);
 	t->cpu = cpu;
 
 	INIT_LIST_HEAD(&t->if_list);
