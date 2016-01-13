From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH RT] net: move xmit_recursion to per-task variable on -RT
Date: Wed, 13 Jan 2016 16:23:52 +0100
Message-ID: <20160113152352.GH29964@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de,
	Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org
To: linux-rt-users@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A softirq on -RT can be preempted. That means one task is in
__dev_queue_xmit(), gets preempted and another task may enter
__dev_queue_xmit() aw well. netperf together with a bridge device
will then trigger the `recursion alert` because each task increments
the xmit_recursion variable which is per-CPU.
A virtual device like br0 is required to trigger this warning.

This patch moves the counter to per task instead per-CPU so it counts
the recursion properly on -RT.

Cc: stable-rt@vger.kernel.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/netdevice.h |  9 +++++++++
 include/linux/sched.h     |  3 +++
 net/core/dev.c            | 41 ++++++++++++++++++++++++++++++++++++++---
 3 files changed, 50 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f14e39cb897c..4a8d3429dc12 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2249,11 +2249,20 @@ void netdev_freemem(struct net_device *dev);
 void synchronize_net(void);
 int init_dummy_netdev(struct net_device *dev);
 
+#ifdef CONFIG_PREEMPT_RT_FULL
+static inline int dev_recursion_level(void)
+{
+	return atomic_read(&current->xmit_recursion);
+}
+
+#else
+
 DECLARE_PER_CPU(int, xmit_recursion);
 static inline int dev_recursion_level(void)
 {
 	return this_cpu_read(xmit_recursion);
 }
+#endif
 
 struct net_device *dev_get_by_index(struct net *net, int ifindex);
 struct net_device *__dev_get_by_index(struct net *net, int ifindex);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 04eb2f8bc274..5d36818107b0 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1855,6 +1855,9 @@ struct task_struct {
 	pte_t kmap_pte[KM_TYPE_NR];
 # endif
 #endif
+#ifdef CONFIG_PREEMPT_RT_FULL
+	atomic_t xmit_recursion;
+#endif
 #ifdef CONFIG_DEBUG_ATOMIC_SLEEP
 	unsigned long	task_state_change;
 #endif
diff --git a/net/core/dev.c b/net/core/dev.c
index ae4a67e7e654..1f6a7e9a22c4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2946,9 +2946,44 @@ static void skb_update_prio(struct sk_buff *skb)
 #define skb_update_prio(skb)
 #endif
 
+#ifdef CONFIG_PREEMPT_RT_FULL
+
+static inline int xmit_rec_read(void)
+{
+       return atomic_read(&current->xmit_recursion);
+}
+
+static inline void xmit_rec_inc(void)
+{
+       atomic_inc(&current->xmit_recursion);
+}
+
+static inline void xmit_rec_dec(void)
+{
+       atomic_dec(&current->xmit_recursion);
+}
+
+#else
+
 DEFINE_PER_CPU(int, xmit_recursion);
 EXPORT_SYMBOL(xmit_recursion);
 
+static inline int xmit_rec_read(void)
+{
+	return __this_cpu_read(xmit_recursion);
+}
+
+static inline void xmit_rec_inc(void)
+{
+	__this_cpu_inc(xmit_recursion);
+}
+
+static inline int xmit_rec_dec(void)
+{
+	__this_cpu_dec(xmit_recursion);
+}
+#endif
+
 #define RECURSION_LIMIT 10
 
 /**
@@ -3141,7 +3176,7 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 
 		if (txq->xmit_lock_owner != cpu) {
 
-			if (__this_cpu_read(xmit_recursion) > RECURSION_LIMIT)
+			if (xmit_rec_read() > RECURSION_LIMIT)
 				goto recursion_alert;
 
 			skb = validate_xmit_skb(skb, dev);
@@ -3151,9 +3186,9 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 			HARD_TX_LOCK(dev, txq, cpu);
 
 			if (!netif_xmit_stopped(txq)) {
-				__this_cpu_inc(xmit_recursion);
+				xmit_rec_inc();
 				skb = dev_hard_start_xmit(skb, dev, txq, &rc);
-				__this_cpu_dec(xmit_recursion);
+				xmit_rec_dec();
 				if (dev_xmit_complete(rc)) {
 					HARD_TX_UNLOCK(dev, txq);
 					goto out;
-- 
2.7.0.rc3
