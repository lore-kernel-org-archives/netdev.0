From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: percpu net_device refcount
Date: Thu, 07 Oct 2010 19:12:35 +0200
Message-ID: <1286471555.2912.291.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40132 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173Ab0JGRMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 13:12:40 -0400
Received: by fxm4 with SMTP id 4so60727fxm.19
        for <netdev@vger.kernel.org>; Thu, 07 Oct 2010 10:12:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We tried very hard to remove all possible dev_hold()/dev_put() pairs in
network stack, using RCU conversions.

There is still an unavoidable device refcount change for every dst we
create/destroy, and this can slow down some workloads (routers or some
app servers)

We can switch to a percpu refcount implementation, now dynamic per_cpu
infrastructure is mature. On a 64 cpus machine, this consumes 256 bytes
per device.

On x86, dev_hold(dev) code :

before
	lock	incl 0x280(%ebx)
after:
	movl	0x260(%ebx),%eax
	incl	fs:(%eax)

Stress bench :

(Sending 160.000.000 UDP frames,
IP route cache disabled, dual E5540 @2.53GHz,
32bit kernel, FIB_TRIE)

Before:

real	1m1.662s
user	0m14.373s
sys	12m55.960s

After:

real	0m51.179s
user	0m15.329s
sys	10m15.942s

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    6 ++--
 net/core/dev.c            |   47 ++++++++++++++++++++++++++++++------
 2 files changed, 43 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6abcef6..fa1d88d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1020,7 +1020,7 @@ struct net_device {
 	struct timer_list	watchdog_timer;
 
 	/* Number of references to this device */
-	atomic_t		refcnt ____cacheline_aligned_in_smp;
+	int __percpu		*pcpu_refcnt;
 
 	/* delayed register/unregister */
 	struct list_head	todo_list;
@@ -1792,7 +1792,7 @@ extern void netdev_run_todo(void);
  */
 static inline void dev_put(struct net_device *dev)
 {
-	atomic_dec(&dev->refcnt);
+	irqsafe_cpu_dec(*dev->pcpu_refcnt);
 }
 
 /**
@@ -1803,7 +1803,7 @@ static inline void dev_put(struct net_device *dev)
  */
 static inline void dev_hold(struct net_device *dev)
 {
-	atomic_inc(&dev->refcnt);
+	irqsafe_cpu_inc(*dev->pcpu_refcnt);
 }
 
 /* Carrier loss detection, dial on demand. The functions netif_carrier_on
diff --git a/net/core/dev.c b/net/core/dev.c
index 7d14955..2186e1e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5195,9 +5195,6 @@ int init_dummy_netdev(struct net_device *dev)
 	 */
 	dev->reg_state = NETREG_DUMMY;
 
-	/* initialize the ref count */
-	atomic_set(&dev->refcnt, 1);
-
 	/* NAPI wants this */
 	INIT_LIST_HEAD(&dev->napi_list);
 
@@ -5205,6 +5202,19 @@ int init_dummy_netdev(struct net_device *dev)
 	set_bit(__LINK_STATE_PRESENT, &dev->state);
 	set_bit(__LINK_STATE_START, &dev->state);
 
+#if 0
+	/* We dont allocate pcpu_refcnt for dummy devices,
+	 * because users of this 'device' dont need to change
+	 * its refcount
+	 */
+	dev->pcpu_refcnt = alloc_percpu(int);
+	if (!dev->pcpu_refcnt)
+		return -ENOMEM;
+
+	/* initialize the ref count */
+	dev_hold(dev);
+#endif
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(init_dummy_netdev);
@@ -5246,6 +5256,15 @@ out:
 }
 EXPORT_SYMBOL(register_netdev);
 
+static int netdev_refcnt_read(const struct net_device *dev)
+{
+	int i, refcnt = 0;
+
+	for_each_possible_cpu(i)
+		refcnt += *per_cpu_ptr(dev->pcpu_refcnt, i);
+	return refcnt;
+}
+
 /*
  * netdev_wait_allrefs - wait until all references are gone.
  *
@@ -5260,11 +5279,14 @@ EXPORT_SYMBOL(register_netdev);
 static void netdev_wait_allrefs(struct net_device *dev)
 {
 	unsigned long rebroadcast_time, warning_time;
+	int refcnt;
 
 	linkwatch_forget_dev(dev);
 
 	rebroadcast_time = warning_time = jiffies;
-	while (atomic_read(&dev->refcnt) != 0) {
+	refcnt = netdev_refcnt_read(dev);
+
+	while (refcnt != 0) {
 		if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
 			rtnl_lock();
 
@@ -5291,11 +5313,13 @@ static void netdev_wait_allrefs(struct net_device *dev)
 
 		msleep(250);
 
+		refcnt = netdev_refcnt_read(dev);
+
 		if (time_after(jiffies, warning_time + 10 * HZ)) {
 			printk(KERN_EMERG "unregister_netdevice: "
 			       "waiting for %s to become free. Usage "
 			       "count = %d\n",
-			       dev->name, atomic_read(&dev->refcnt));
+			       dev->name, refcnt);
 			warning_time = jiffies;
 		}
 	}
@@ -5353,7 +5377,7 @@ void netdev_run_todo(void)
 		netdev_wait_allrefs(dev);
 
 		/* paranoia */
-		BUG_ON(atomic_read(&dev->refcnt));
+		BUG_ON(netdev_refcnt_read(dev));
 		WARN_ON(rcu_dereference_raw(dev->ip_ptr));
 		WARN_ON(dev->ip6_ptr);
 		WARN_ON(dev->dn_ptr);
@@ -5523,9 +5547,13 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	dev = PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
 
-	if (dev_addr_init(dev))
+	dev->pcpu_refcnt = alloc_percpu(int);
+	if (!dev->pcpu_refcnt)
 		goto free_tx;
 
+	if (dev_addr_init(dev))
+		goto free_pcpu;
+
 	dev_mc_init(dev);
 	dev_uc_init(dev);
 
@@ -5556,6 +5584,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 free_tx:
 	kfree(tx);
+free_pcpu:
+	free_percpu(dev->pcpu_refcnt);
 free_p:
 	kfree(p);
 	return NULL;
@@ -5589,6 +5619,9 @@ void free_netdev(struct net_device *dev)
 	list_for_each_entry_safe(p, n, &dev->napi_list, dev_list)
 		netif_napi_del(p);
 
+	free_percpu(dev->pcpu_refcnt);
+	dev->pcpu_refcnt = NULL;
+
 	/*  Compatibility with error handling in drivers */
 	if (dev->reg_state == NETREG_UNINITIALIZED) {
 		kfree((char *)dev - dev->padded);


