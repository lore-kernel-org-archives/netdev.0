From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] Experiment with dev and module ref counts
Date: Tue, 6 May 2003 16:51:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030506165148.7d40b1f3.shemminger@osdl.org>
References: <20030505130050.4b9868bb.shemminger@osdl.org>
	<20030506075808.388332C07F@lists.samba.org>
	<20030506153555.4e82bc4b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rusty@rustcorp.com.au, davem@redhat.com, kuznet@ms2.inr.ac.ru,
   acme@conectiva.com.br
In-Reply-To: <20030506153555.4e82bc4b.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch ties network device refcounts and module ref counts 
together.  It works for IPV4 and the dev->destructor problem is fixed,
at least for the Ethernet bridge device. Unregister and shutdown
work correctly, and modules can be removed when expected.

BUT: lots of dev_hold usage would need more auditing.
No idea what the performance impact is yet.

diff -urNp -X dontdiff linux-2.5/include/linux/netdevice.h linux-2.5-dev/include/linux/netdevice.h
--- linux-2.5/include/linux/netdevice.h	2003-04-14 13:32:21.000000000 -0700
+++ linux-2.5-dev/include/linux/netdevice.h	2003-05-06 15:11:25.000000000 -0700
@@ -29,6 +29,7 @@
 #include <linux/if_ether.h>
 #include <linux/if_packet.h>
 #include <linux/kobject.h>
+#include <linux/module.h>
 
 #include <asm/atomic.h>
 #include <asm/cache.h>
@@ -629,12 +630,32 @@ extern int netdev_finish_unregister(stru
 
 static inline void dev_put(struct net_device *dev)
 {
+	module_put(dev->owner);
 	if (atomic_dec_and_test(&dev->refcnt))
 		netdev_finish_unregister(dev);
 }
 
-#define __dev_put(dev) atomic_dec(&(dev)->refcnt)
-#define dev_hold(dev) atomic_inc(&(dev)->refcnt)
+static inline void __dev_put(struct net_device *dev)
+{
+	module_put(dev->owner);
+	atomic_dec(&dev->refcnt);
+}
+
+static inline void dev_hold(struct net_device *dev)
+{
+	__module_get(dev->owner);
+	atomic_inc(&dev->refcnt);
+}
+
+static inline int dev_try_hold(struct net_device *dev)
+{
+	int ret = 0;
+	if (try_module_get(dev->owner)){
+		atomic_inc(&dev->refcnt);
+		ret = 1;
+	}
+	return ret;
+}
 
 /* Carrier loss detection, dial on demand. The functions netif_carrier_on
  * and _off may be called from IRQ context, but it is caller
diff -urNp -X dontdiff linux-2.5/kernel/module.c linux-2.5-dev/kernel/module.c
--- linux-2.5/kernel/module.c	2003-04-30 11:19:23.000000000 -0700
+++ linux-2.5-dev/kernel/module.c	2003-05-06 13:13:20.000000000 -0700
@@ -214,6 +214,8 @@ static void module_unload_init(struct mo
 	INIT_LIST_HEAD(&mod->modules_which_use_me);
 	for (i = 0; i < NR_CPUS; i++)
 		atomic_set(&mod->ref[i].count, 0);
+	/* Hold reference count during initialization. */
+	atomic_set(&mod->ref[smp_processor_id()].count, 1);
 	/* Backwards compatibility macros put refcount during init. */
 	mod->waiter = current;
 }
@@ -500,16 +502,6 @@ sys_delete_module(const char __user *nam
 		goto out;
 	}
 
-	/* Coming up?  Allow force on stuck modules. */
-	if (mod->state == MODULE_STATE_COMING) {
-		forced = try_force(flags);
-		if (!forced) {
-			/* This module can't be removed */
-			ret = -EBUSY;
-			goto out;
-		}
-	}
-
 	/* If it has an init func, it must have an exit func to unload */
 	if ((mod->init != init_module && mod->exit == cleanup_module)
 	    || mod->unsafe) {
@@ -1448,6 +1440,7 @@ sys_init_module(void __user *umod,
 			printk(KERN_ERR "%s: module is now stuck!\n",
 			       mod->name);
 		else {
+			module_put(mod);
 			down(&module_mutex);
 			free_module(mod);
 			up(&module_mutex);
@@ -1463,6 +1456,9 @@ sys_init_module(void __user *umod,
 	mod->init_size = 0;
 	up(&module_mutex);
 
+	/* Drop initial reference. */
+	module_put(mod);
+
 	return 0;
 }
 
diff -urNp -X dontdiff linux-2.5/net/core/dev.c linux-2.5-dev/net/core/dev.c
--- linux-2.5/net/core/dev.c	2003-05-05 09:41:03.000000000 -0700
+++ linux-2.5-dev/net/core/dev.c	2003-05-06 16:07:15.000000000 -0700
@@ -1,3 +1,4 @@
+#define NET_REFCNT_DEBUG	1
 /*
  * 	NET3	Protocol independent device support routines.
  *
@@ -440,8 +441,8 @@ struct net_device *dev_get_by_name(const
 
 	read_lock(&dev_base_lock);
 	dev = __dev_get_by_name(name);
-	if (dev)
-		dev_hold(dev);
+	if (dev && !dev_try_hold(dev))
+		dev = NULL;
 	read_unlock(&dev_base_lock);
 	return dev;
 }
@@ -513,8 +514,8 @@ struct net_device *dev_get_by_index(int 
 
 	read_lock(&dev_base_lock);
 	dev = __dev_get_by_index(ifindex);
-	if (dev)
-		dev_hold(dev);
+	if (dev && !dev_try_hold(dev))
+		dev = NULL;
 	read_unlock(&dev_base_lock);
 	return dev;
 }
@@ -563,8 +564,8 @@ struct net_device * dev_get_by_flags(uns
 
 	read_lock(&dev_base_lock);
 	dev = __dev_get_by_flags(if_flags, mask);
-	if (dev)
-		dev_hold(dev);
+	if (dev && !dev_try_hold(dev))
+	    dev = NULL;
 	read_unlock(&dev_base_lock);
 	return dev;
 }
@@ -1312,7 +1313,9 @@ int netif_rx(struct sk_buff *skb)
 				goto drop;
 
 enqueue:
-			dev_hold(skb->dev);
+			if (!dev_try_hold(skb->dev)) 
+				goto drop;
+
 			__skb_queue_tail(&queue->input_pkt_queue, skb);
 #ifndef OFFLINE_SAMPLE
 			get_sample_stats(this_cpu);
@@ -1990,9 +1993,8 @@ int netdev_set_master(struct net_device 
 	ASSERT_RTNL();
 
 	if (master) {
-		if (old)
+		if (old || !dev_try_hold(master))
 			return -EBUSY;
-		dev_hold(master);
 	}
 
 	br_write_lock_bh(BR_NETPROTO_LOCK);
@@ -2609,10 +2611,11 @@ int register_netdevice(struct net_device
 	set_bit(__LINK_STATE_PRESENT, &dev->state);
 
 	dev->next = NULL;
+	atomic_inc(&dev->refcnt);
 	dev_init_scheduler(dev);
 	write_lock_bh(&dev_base_lock);
 	*dp = dev;
-	dev_hold(dev);
+
 	dev->deadbeaf = 0;
 	write_unlock_bh(&dev_base_lock);
 
@@ -2809,7 +2812,9 @@ int unregister_netdevice(struct net_devi
 	}
 out:
 	kobject_unregister(&dev->kobj);
-	dev_put(dev);
+
+	atomic_dec(&dev->refcnt);
+
 	return 0;
 }
 
@@ -2900,7 +2905,11 @@ static int __init net_dev_init(void)
 #endif
 		dev->xmit_lock_owner = -1;
 		dev->iflink = -1;
-		dev_hold(dev);
+
+		if (!dev_try_hold(dev)) {
+			dev->deadbeaf = 1;
+			dp = &dev->next;
+		}
 
 		/*
 		 * Allocate name. If the init() fails
diff -urNp -X dontdiff linux-2.5/net/ipv4/devinet.c linux-2.5-dev/net/ipv4/devinet.c
--- linux-2.5/net/ipv4/devinet.c	2003-04-14 13:32:26.000000000 -0700
+++ linux-2.5-dev/net/ipv4/devinet.c	2003-05-06 15:16:03.000000000 -0700
@@ -559,6 +559,9 @@ int devinet_ioctl(unsigned int cmd, void
 	if ((dev = __dev_get_by_name(ifr.ifr_name)) == NULL)
 		goto done;
 
+	if (!dev_try_hold(dev))
+		goto done;
+
 	if (colon)
 		*colon = ':';
 
@@ -591,7 +594,7 @@ int devinet_ioctl(unsigned int cmd, void
 
 	ret = -EADDRNOTAVAIL;
 	if (!ifa && cmd != SIOCSIFADDR && cmd != SIOCSIFFLAGS)
-		goto done;
+		goto put;
 
 	switch(cmd) {
 	case SIOCGIFADDR:	/* Get interface address */
@@ -700,12 +703,15 @@ int devinet_ioctl(unsigned int cmd, void
 		}
 		break;
 	}
+put:
+	dev_put(dev);
 done:
 	rtnl_unlock();
 	dev_probe_unlock();
 out:
 	return ret;
 rarok:
+	dev_put(dev);
 	rtnl_unlock();
 	dev_probe_unlock();
 	ret = copy_to_user(arg, &ifr, sizeof(struct ifreq)) ? -EFAULT : 0;
diff -urNp -X dontdiff linux-2.5/net/ipv4/fib_frontend.c linux-2.5-dev/net/ipv4/fib_frontend.c
--- linux-2.5/net/ipv4/fib_frontend.c	2003-04-14 13:32:26.000000000 -0700
+++ linux-2.5-dev/net/ipv4/fib_frontend.c	2003-05-06 15:16:03.000000000 -0700
@@ -115,9 +115,9 @@ struct net_device * ip_dev_find(u32 addr
 	if (res.type != RTN_LOCAL)
 		goto out;
 	dev = FIB_RES_DEV(res);
-	if (dev)
-		atomic_inc(&dev->refcnt);
 
+	if (dev)
+		dev_hold(dev);
 out:
 	fib_res_put(&res);
 	return dev;
diff -urNp -X dontdiff linux-2.5/net/ipv4/fib_semantics.c linux-2.5-dev/net/ipv4/fib_semantics.c
--- linux-2.5/net/ipv4/fib_semantics.c	2003-04-29 09:57:41.000000000 -0700
+++ linux-2.5-dev/net/ipv4/fib_semantics.c	2003-05-06 15:10:40.000000000 -0700
@@ -406,7 +406,7 @@ static int fib_check_nh(const struct rtm
 			if (!(dev->flags&IFF_UP))
 				return -ENETDOWN;
 			nh->nh_dev = dev;
-			atomic_inc(&dev->refcnt);
+			dev_hold(dev);
 			nh->nh_scope = RT_SCOPE_LINK;
 			return 0;
 		}
@@ -429,7 +429,7 @@ static int fib_check_nh(const struct rtm
 		nh->nh_oif = FIB_RES_OIF(res);
 		if ((nh->nh_dev = FIB_RES_DEV(res)) == NULL)
 			goto out;
-		atomic_inc(&nh->nh_dev->refcnt);
+		dev_hold(nh->nh_dev);
 		err = -ENETDOWN;
 		if (!(nh->nh_dev->flags & IFF_UP))
 			goto out;
@@ -451,7 +451,7 @@ out:
 			return -ENETDOWN;
 		}
 		nh->nh_dev = in_dev->dev;
-		atomic_inc(&nh->nh_dev->refcnt);
+		dev_hold(nh->nh_dev);
 		nh->nh_scope = RT_SCOPE_HOST;
 		in_dev_put(in_dev);
 	}
