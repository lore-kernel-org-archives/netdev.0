From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH 4/5] netdev: implement infrastructure for threadable napi irq
Date: Wed, 15 Jun 2016 15:42:05 +0200
Message-ID: <f5e431e8336f80d0e6f6b4c40c81a373db6d6052.1465996447.git.pabeni@redhat.com>
References: <cover.1465996447.git.pabeni@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1465996447.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit adds the infrastructure needed for threadable
rx interrupt. A reference to the irq thread is used to
mark the threaded irq mode.
In threaded mode the poll loop is invoked directly from
__napi_schedule().
napi drivers which want to support threadable irq interrupts
must provide an irq mode change handler which actually set
napi->thread and register it after requesting the irq.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/netdevice.h |  4 ++++
 net/core/dev.c            | 59 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 63 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d101e4d..5da53be 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -322,6 +322,9 @@ struct napi_struct {
 	struct list_head	dev_list;
 	struct hlist_node	napi_hash_node;
 	unsigned int		napi_id;
+#ifdef CONFIG_IRQ_FORCED_THREADING
+	struct task_struct	*thread;
+#endif
 };
 
 enum {
@@ -330,6 +333,7 @@ enum {
 	NAPI_STATE_NPSVC,	/* Netpoll - don't dequeue from poll_list */
 	NAPI_STATE_HASHED,	/* In NAPI hash (busy polling possible) */
 	NAPI_STATE_NO_BUSY_POLL,/* Do not add in napi_hash, no busy polling */
+	NAPI_STATE_SCHED_THREAD, /* The poll thread is scheduled */
 };
 
 enum gro_result {
diff --git a/net/core/dev.c b/net/core/dev.c
index b148357..40ea1e7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -93,6 +93,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/notifier.h>
+#include <linux/kthread.h>
 #include <linux/skbuff.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -3453,10 +3454,68 @@ int netdev_tstamp_prequeue __read_mostly = 1;
 int netdev_budget __read_mostly = 300;
 int weight_p __read_mostly = 64;            /* old backlog weight */
 
+#if CONFIG_IRQ_FORCED_THREADING
+static int napi_poll(struct napi_struct *n, struct list_head *repoll);
+
+static void napi_threaded_poll(struct napi_struct *napi)
+{
+	unsigned long time_limit = jiffies + 2;
+	struct list_head dummy_repoll;
+	int budget = netdev_budget;
+	bool again = true;
+
+	if (test_and_set_bit(NAPI_STATE_SCHED_THREAD, &napi->state))
+		return;
+
+	local_irq_enable();
+	INIT_LIST_HEAD(&dummy_repoll);
+
+	while (again) {
+		/* ensure that the poll list is not empty */
+		if (list_empty(&dummy_repoll))
+			list_add(&napi->poll_list, &dummy_repoll);
+
+		budget -= napi_poll(napi, &dummy_repoll);
+
+		if (napi_disable_pending(napi))
+			again = false;
+		else if (!test_bit(NAPI_STATE_SCHED, &napi->state))
+			again = false;
+		else if (kthread_should_stop())
+			again = false;
+
+		if (!again || unlikely(budget <= 0 ||
+				       time_after_eq(jiffies, time_limit))) {
+			/* no need to reschedule if we are going to stop */
+			if (again)
+				cond_resched_softirq();
+			time_limit = jiffies + 2;
+			budget = netdev_budget;
+			rcu_bh_qs();
+			__kfree_skb_flush();
+		}
+	}
+
+	clear_bit(NAPI_STATE_SCHED_THREAD, &napi->state);
+	local_irq_disable();
+}
+
+static inline bool napi_is_threaded(struct napi_struct *napi)
+{
+	return current == napi->thread;
+}
+#else
+#define napi_is_threaded(napi) 0
+#endif
+
 /* Called with irq disabled */
 static inline void ____napi_schedule(struct softnet_data *sd,
 				     struct napi_struct *napi)
 {
+	if (napi_is_threaded(napi)) {
+		napi_threaded_poll(napi);
+		return;
+	}
 	list_add_tail(&napi->poll_list, &sd->poll_list);
 	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
 }
-- 
1.8.3.1
