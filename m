From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH RT] net: move xmit_recursion to per-task variable on -RT
Date: Thu, 14 Jan 2016 15:50:07 +0100
Message-ID: <20160114145007.GC17776@linutronix.de>
References: <20160113152352.GH29964@linutronix.de>
 <alpine.DEB.2.11.1601131830440.3575@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1601131830440.3575@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Thomas Gleixner | 2016-01-13 18:31:46 [+0100]:

>On Wed, 13 Jan 2016, Sebastian Andrzej Siewior wrote:
>> +#ifdef CONFIG_PREEMPT_RT_FULL
>> +static inline int dev_recursion_level(void)
>> +{
>> +	return atomic_read(&current->xmit_recursion);
>
>Why would you need an atomic here. current does hardly race against itself.

right.

--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2249,11 +2249,20 @@ void netdev_freemem(struct net_device *d
 void synchronize_net(void);
 int init_dummy_netdev(struct net_device *dev);
 
+#ifdef CONFIG_PREEMPT_RT_FULL
+static inline int dev_recursion_level(void)
+{
+	return current->xmit_recursion;
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
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1851,6 +1851,9 @@ struct task_struct {
 #ifdef CONFIG_DEBUG_ATOMIC_SLEEP
 	unsigned long	task_state_change;
 #endif
+#ifdef CONFIG_PREEMPT_RT_FULL
+	int xmit_recursion;
+#endif
 	int pagefault_disabled;
 /* CPU-specific state of this task */
 	struct thread_struct thread;
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2940,9 +2940,44 @@ static void skb_update_prio(struct sk_bu
 #define skb_update_prio(skb)
 #endif
 
+#ifdef CONFIG_PREEMPT_RT_FULL
+
+static inline int xmit_rec_read(void)
+{
+       return current->xmit_recursion;
+}
+
+static inline void xmit_rec_inc(void)
+{
+       current->xmit_recursion++;
+}
+
+static inline void xmit_rec_dec(void)
+{
+       current->xmit_recursion--;
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
@@ -3135,7 +3170,7 @@ static int __dev_queue_xmit(struct sk_bu
 
 		if (txq->xmit_lock_owner != cpu) {
 
-			if (__this_cpu_read(xmit_recursion) > RECURSION_LIMIT)
+			if (xmit_rec_read() > RECURSION_LIMIT)
 				goto recursion_alert;
 
 			skb = validate_xmit_skb(skb, dev);
@@ -3145,9 +3180,9 @@ static int __dev_queue_xmit(struct sk_bu
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

>Thanks,
>
>	tglx

Sebastian
