From: Jiri Benc <jbenc@suse.cz>
Subject: [RFC PATCH 1/6] invisible network devices
Date: Mon, 29 Jan 2007 18:48:06 +0100 (CET)
Message-ID: <20070129184707.885764375.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41726 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752053AbXA2Rr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 12:47:56 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The d80211 stack needs a network interface (called 'wmaster') used for
communication with the hardware (it has 802.11 qdisc attached which perform
MAC level QoS). This interface is not intended for users and it confuses
them.

As a short time solution, this patch allows net_device to be registered as
"invisible". This means it is not in the dev name hash list, its ifindex is
-1 and protocols are not notified about its registration/unregistration.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 include/linux/netdevice.h |    2 
 net/core/dev.c            |  223 ++++++++++++++++++++++++++++++----------------
 2 files changed, 151 insertions(+), 74 deletions(-)

--- dscape.orig/include/linux/netdevice.h
+++ dscape/include/linux/netdevice.h
@@ -975,6 +975,8 @@ extern struct net_device *alloc_netdev(i
 				       void (*setup)(struct net_device *));
 extern int		register_netdev(struct net_device *dev);
 extern void		unregister_netdev(struct net_device *dev);
+extern int		register_invisible_netdevice(struct net_device *dev);
+extern void		unregister_invisible_netdevice(struct net_device *dev);
 /* Functions used for multicast support */
 extern void		dev_mc_upload(struct net_device *dev);
 extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all);
--- dscape.orig/net/core/dev.c
+++ dscape/net/core/dev.c
@@ -2891,37 +2891,10 @@ static inline void net_set_todo(struct n
 	spin_unlock(&net_todo_list_lock);
 }
 
-/**
- *	register_netdevice	- register a network device
- *	@dev: device to register
- *
- *	Take a completed network device structure and add it to the kernel
- *	interfaces. A %NETDEV_REGISTER message is sent to the netdev notifier
- *	chain. 0 is returned on success. A negative errno code is returned
- *	on a failure to set up the device, or if the name is a duplicate.
- *
- *	Callers must hold the rtnl semaphore. You may want
- *	register_netdev() instead of this.
- *
- *	BUGS:
- *	The locking appears insufficient to guarantee two parallel registers
- *	will not get the same name.
- */
-
-int register_netdevice(struct net_device *dev)
+static int init_netdevice(struct net_device *dev)
 {
-	struct hlist_head *head;
-	struct hlist_node *p;
 	int ret;
 
-	BUG_ON(dev_boot_phase);
-	ASSERT_RTNL();
-
-	might_sleep();
-
-	/* When net_device's are persistent, this will be fatal. */
-	BUG_ON(dev->reg_state != NETREG_UNINITIALIZED);
-
 	spin_lock_init(&dev->queue_lock);
 	spin_lock_init(&dev->_xmit_lock);
 	dev->xmit_lock_owner = -1;
@@ -2929,7 +2902,7 @@ int register_netdevice(struct net_device
 	spin_lock_init(&dev->ingress_lock);
 #endif
 
-	dev->iflink = -1;
+	dev->iflink = dev->ifindex = -1;
 
 	/* Init, if this function is available */
 	if (dev->init) {
@@ -2940,27 +2913,13 @@ int register_netdevice(struct net_device
 			goto out;
 		}
 	}
- 
-	if (!dev_valid_name(dev->name)) {
-		ret = -EINVAL;
-		goto out;
-	}
-
-	dev->ifindex = dev_new_index();
-	if (dev->iflink == -1)
-		dev->iflink = dev->ifindex;
-
-	/* Check for existence of name */
-	head = dev_name_hash(dev->name);
-	hlist_for_each(p, head) {
-		struct net_device *d
-			= hlist_entry(p, struct net_device, name_hlist);
-		if (!strncmp(d->name, dev->name, IFNAMSIZ)) {
-			ret = -EEXIST;
- 			goto out;
-		}
- 	}
+	ret = 0;
+out:
+	return ret;
+}
 
+static void setup_netdevice(struct net_device *dev)
+{
 	/* Fix illegal SG+CSUM combinations. */
 	if ((dev->features & NETIF_F_SG) &&
 	    !(dev->features & NETIF_F_ALL_CSUM)) {
@@ -2999,17 +2958,75 @@ int register_netdevice(struct net_device
 	if (!dev->rebuild_header)
 		dev->rebuild_header = default_rebuild_header;
 
-	ret = netdev_register_sysfs(dev);
-	if (ret)
-		goto out;
-	dev->reg_state = NETREG_REGISTERED;
-
 	/*
 	 *	Default initial state at registry is that the
 	 *	device is present.
 	 */
 
 	set_bit(__LINK_STATE_PRESENT, &dev->state);
+}
+
+/**
+ *	register_netdevice	- register a network device
+ *	@dev: device to register
+ *
+ *	Take a completed network device structure and add it to the kernel
+ *	interfaces. A %NETDEV_REGISTER message is sent to the netdev notifier
+ *	chain. 0 is returned on success. A negative errno code is returned
+ *	on a failure to set up the device, or if the name is a duplicate.
+ *
+ *	Callers must hold the rtnl semaphore. You may want
+ *	register_netdev() instead of this.
+ *
+ *	BUGS:
+ *	The locking appears insufficient to guarantee two parallel registers
+ *	will not get the same name.
+ */
+
+int register_netdevice(struct net_device *dev)
+{
+	struct hlist_head *head;
+	struct hlist_node *p;
+	int ret;
+
+	BUG_ON(dev_boot_phase);
+	ASSERT_RTNL();
+
+	might_sleep();
+
+	/* When net_device's are persistent, this will be fatal. */
+	BUG_ON(dev->reg_state != NETREG_UNINITIALIZED);
+
+	ret = init_netdevice(dev);
+	if (ret)
+		goto out;
+
+	if (!dev_valid_name(dev->name)) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	dev->ifindex = dev_new_index();
+	if (dev->iflink == -1)
+		dev->iflink = dev->ifindex;
+
+	/* Check for existence of name */
+	head = dev_name_hash(dev->name);
+	hlist_for_each(p, head) {
+		struct net_device *d
+			= hlist_entry(p, struct net_device, name_hlist);
+		if (!strncmp(d->name, dev->name, IFNAMSIZ)) {
+			ret = -EEXIST;
+ 			goto out;
+		}
+ 	}
+
+	ret = netdev_register_sysfs(dev);
+	if (ret)
+		goto out;
+
+	setup_netdevice(dev);
+	dev->reg_state = NETREG_REGISTERED;
 
 	dev->next = NULL;
 	dev_init_scheduler(dev);
@@ -3030,6 +3047,31 @@ out:
 	return ret;
 }
 
+int register_invisible_netdevice(struct net_device *dev)
+{
+	int ret;
+
+	BUG_ON(dev_boot_phase);
+	might_sleep();
+	BUG_ON(dev->reg_state != NETREG_UNINITIALIZED);
+
+	ret = init_netdevice(dev);
+	if (ret)
+		goto out;
+
+	setup_netdevice(dev);
+	dev->reg_state = NETREG_REGISTERED;
+
+	dev->next = NULL;
+	dev_init_scheduler(dev);
+	dev_hold(dev);
+
+	ret = 0;
+out:
+	return ret;
+}
+EXPORT_SYMBOL(register_invisible_netdevice);
+
 /**
  *	register_netdev	- register a network device
  *	@dev: device to register
@@ -3118,6 +3160,23 @@ static void netdev_wait_allrefs(struct n
 	}
 }
 
+static void destruct_netdevice(struct net_device *dev)
+{
+	netdev_wait_allrefs(dev);
+
+	/* paranoia */
+	BUG_ON(atomic_read(&dev->refcnt));
+	BUG_TRAP(!dev->ip_ptr);
+	BUG_TRAP(!dev->ip6_ptr);
+	BUG_TRAP(!dev->dn_ptr);
+
+	/* It must be the very last action,
+	 * after this 'dev' may point to freed up memory.
+	 */
+	if (dev->destructor)
+		dev->destructor(dev);
+}
+
 /* The sequence is:
  *
  *	rtnl_lock();
@@ -3175,19 +3234,7 @@ void netdev_run_todo(void)
 		netdev_unregister_sysfs(dev);
 		dev->reg_state = NETREG_UNREGISTERED;
 
-		netdev_wait_allrefs(dev);
-
-		/* paranoia */
-		BUG_ON(atomic_read(&dev->refcnt));
-		BUG_TRAP(!dev->ip_ptr);
-		BUG_TRAP(!dev->ip6_ptr);
-		BUG_TRAP(!dev->dn_ptr);
-
-		/* It must be the very last action,
-		 * after this 'dev' may point to freed up memory.
-		 */
-		if (dev->destructor)
-			dev->destructor(dev);
+		destruct_netdevice(dev);
 	}
 
 out:
@@ -3269,6 +3316,17 @@ void synchronize_net(void) 
 	synchronize_rcu();
 }
 
+static void uninit_netdevice(struct net_device *dev)
+{
+	/*
+	 *	Flush the multicast chain
+	 */
+	dev_mc_discard(dev);
+
+	if (dev->uninit)
+		dev->uninit(dev);
+}
+
 /**
  *	unregister_netdevice - remove device from the kernel
  *	@dev: device
@@ -3332,14 +3390,8 @@ int unregister_netdevice(struct net_devi
 	   this device. They should clean all the things.
 	*/
 	raw_notifier_call_chain(&netdev_chain, NETDEV_UNREGISTER, dev);
-	
-	/*
-	 *	Flush the multicast chain
-	 */
-	dev_mc_discard(dev);
 
-	if (dev->uninit)
-		dev->uninit(dev);
+	uninit_netdevice(dev);
 
 	/* Notifier chain MUST detach us from master device. */
 	BUG_TRAP(!dev->master);
@@ -3353,6 +3405,29 @@ int unregister_netdevice(struct net_devi
 	return 0;
 }
 
+void unregister_invisible_netdevice(struct net_device *dev)
+{
+	BUG_ON(dev_boot_phase);
+	BUG_ON(dev->reg_state != NETREG_REGISTERED);
+	might_sleep();
+
+	dev_close(dev);
+	dev->reg_state = NETREG_UNREGISTERING;
+	synchronize_net();
+	dev_shutdown(dev);
+
+	uninit_netdevice(dev);
+
+	BUG_TRAP(!dev->master);
+
+	synchronize_net();
+	dev_put(dev);
+
+	dev->reg_state = NETREG_UNREGISTERED;
+	destruct_netdevice(dev);
+}
+EXPORT_SYMBOL(unregister_invisible_netdevice);
+
 /**
  *	unregister_netdev - remove device from the kernel
  *	@dev: device

-- 
Jiri Benc
SUSE Labs
