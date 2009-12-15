From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH 2/4] net: port mirroring: add port mirroring core
	code to kernel
Date: Tue, 15 Dec 2009 11:37:41 -0500
Message-ID: <20091215163741.GD18710@hmsreliant.think-freely.org>
References: <20091215162956.GB18710@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56876 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759719AbZLOQhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 11:37:46 -0500
Content-Disposition: inline
In-Reply-To: <20091215162956.GB18710@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add port mirroring module to kernel

This patch adds the code to support port mirroring to the kernel. Implementation
uses tracepoints to catch frames being received and sent on an interface, and
copies those frames to a destination interface.  configuration is preformed via
sysfs, by echoing a target net interface to the source net interfaces mirror_to
attribute

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/linux/portmirror.h |   50 ++++++
 net/core/mirror.c          |  344 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/net-sysfs.c       |   77 ++++++++++
 3 files changed, 471 insertions(+)

diff --git a/include/linux/portmirror.h b/include/linux/portmirror.h
new file mode 100644
index 0000000..454ca03
--- /dev/null
+++ b/include/linux/portmirror.h
@@ -0,0 +1,50 @@
+/*
+ * Generic Net Device Port Mirroring support 
+ *
+ * Authors:	Neil Horman <nhorman@tuxdriver.com>
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ */
+#ifndef _LINUX_PORTMIRROR_H
+#define _LINUX_PORTMIRROR_H
+
+#include <linux/netdevice.h>
+
+/*
+ * mirror_dev
+ * Params:
+ *   src_dev: the net_device struct to monitor for frames
+ *   dst_dev: the net_device struct to copy src_dev frames to
+ * Returns:
+ *  0 on success
+ *  -ERRNO on failure
+ */
+extern int mirror_dev(struct net_device *src_dev, struct net_device *dst_dev);
+
+/*
+ * unmirror_dev
+ * Params:
+ *   src_dev: the net_device struct to monitor for frames
+ *   dst_dev: the net_device struct to copy src_dev frames to
+ * Returns:
+ *  0 on success
+ *  -ERRNO on failure
+ */
+extern int unmirror_dev(struct net_device *src_dev, struct net_device *dst_dev);
+
+/*
+ * list_mirror_devs
+ * Params:
+ *   src_dev: the net_device you are monitoring frames from
+ *   rc: a pointer to the number of elements in the returned array,
+ * 	or -ERRNO
+ * Returns:
+ *   an array of string pointers whos length is deonted by rc
+ */
+extern char ** list_mirror_devs(struct net_device *src_dev, int *rc);
+
+#endif	/* _LINUX_PORTMIRROR_H */
diff --git a/net/core/mirror.c b/net/core/mirror.c
new file mode 100644
index 0000000..ced7a05
--- /dev/null
+++ b/net/core/mirror.c
@@ -0,0 +1,344 @@
+/*
+ * Generic port mirroring for Network interfaces 
+ *
+ * Copyright (C) 2009 Neil Horman <nhorman@tuxdriver.com>
+ */
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/string.h>
+#include <linux/if_arp.h>
+#include <linux/inetdevice.h>
+#include <linux/inet.h>
+#include <linux/interrupt.h>
+#include <linux/netpoll.h>
+#include <linux/sched.h>
+#include <linux/delay.h>
+#include <linux/types.h>
+#include <linux/workqueue.h>
+#include <linux/netlink.h>
+#include <linux/net_dropmon.h>
+#include <linux/percpu.h>
+#include <linux/timer.h>
+#include <linux/bitops.h>
+#include <linux/portmirror.h>
+#include <net/netevent.h>
+
+#include <trace/events/net.h>
+
+struct mirror_entry {
+	struct list_head list;
+	struct rcu_head rcu;
+	struct net_device *src_dev;
+	struct net_device *dst_dev;
+};
+
+
+static LIST_HEAD(mirror_list);
+static DEFINE_SPINLOCK(mirror_list_lock);
+
+/*
+ * Helper to free a mirror_entry after rcu
+ * passes a quiescent point
+ */
+static void free_mirror_ent(struct rcu_head *head)
+{
+	struct mirror_entry *n;
+	n = container_of(head, struct mirror_entry, rcu);
+	dev_put(n->src_dev);
+	dev_put(n->dst_dev);
+	kfree(n);
+}
+
+/*
+ * find_mirror_entry
+ * Params:
+ *   src: The source net_device we're looking for
+ *   dst: The destination net_device we're looking for
+ * Returns:
+ *   a struct mirror_entry * on success
+ *   NULL on failure (not found)
+ */
+static struct mirror_entry *find_mirror_entry(struct net_device *src,
+					      struct net_device *dst)
+{
+	struct mirror_entry *ent;
+
+	rcu_read_lock();
+
+	list_for_each_entry_rcu(ent, &mirror_list, list) {
+		if ((ent->src_dev == src) &&
+		    (ent->dst_dev == dst)) {
+			goto found;
+		}
+	}
+	ent = NULL;
+found:
+	rcu_read_unlock();
+	return ent;
+}
+
+
+/*
+ * find_mirror_next_src
+ * Params:
+ *   src: The source net_device we're looking for
+ *   ent: The last found list entry 
+ * Returns:
+ *   a struct mirror_entry * on success
+ *   NULL on failure (not found)
+ * Notes:
+ *   Must be called with rcu_read_lock held
+ */
+static struct mirror_entry *find_mirror_next_src(struct net_device *src,
+						 struct mirror_entry *ent)
+{
+	struct mirror_entry *pos;
+
+	if (unlikely(list_empty(&mirror_list)))
+		return NULL;
+
+	if (ent == NULL) {
+		pos = list_entry(mirror_list.next, struct mirror_entry, list);
+		goto check;
+	} else
+		pos = ent;
+
+	list_for_each_entry_continue_rcu(pos, &mirror_list, list) {
+check:
+		if (pos->src_dev == src)
+			goto found;
+	}
+	pos = NULL;
+found:
+	return pos;
+}
+
+/*
+ * common code for the tracepoint hooks
+ */
+static void mirror_skb(struct sk_buff *skb)
+{
+	struct sk_buff *copy;
+	int rc;
+	struct net_device *src_dev = skb->dev;
+	struct mirror_entry *ent = NULL;
+
+
+
+	
+	if (unlikely(src_dev == NULL)) {
+		if (net_ratelimit())
+			printk(KERN_ERR "No device found in mirror\n");
+		return;
+	}
+
+	/*
+	 * we need to grab the rcu read lock here and
+	 * find every entry in the mirror list that
+	 * lists this source device
+	 */ 
+	rcu_read_lock();
+	while((ent = find_mirror_next_src(src_dev, ent)) != NULL) {
+
+		/*
+		 * We don't want to mirror frames that are bound for
+		 * an interface we are mirroring to, thats an infinite
+		 * loop
+		 */ 
+		if (src_dev == ent->dst_dev)
+			continue;
+
+		/*
+		 * for each found entry, clone the skb
+		 */
+		copy = skb_clone(skb, GFP_ATOMIC);
+
+		/*
+		 * change the skb->dev to the destination device
+		 */
+		copy->dev = ent->dst_dev;		
+
+		rc = dev_queue_xmit(copy);
+	}
+	rcu_read_unlock();
+}
+
+/*
+ * Tracepoint hooks to forward frames to appropriate output devs
+ */
+static void net_tx_hook(struct sk_buff *skb, int rc)
+{
+	/*
+	 * Don't mirror the frame if the original send failed
+	 */
+	if (rc != NETDEV_TX_OK)
+		return;
+	mirror_skb(skb);
+}
+
+static void net_rx_hook(struct sk_buff *skb)
+{
+	mirror_skb(skb);
+}
+
+/*
+ * Helper functions to enable and disable the appropriate tracepoints
+ */
+static int enable_mirror_tracepoints(void)
+{
+	int rc = 0;
+
+	rc |= register_trace_net_dev_xmit(net_tx_hook);
+	rc |= register_trace_net_dev_receive(net_rx_hook);
+
+	if (rc)
+		rc = -EFAULT;
+
+	return rc;
+}
+
+static void disable_mirror_tracepoints(void)
+{
+
+	unregister_trace_net_dev_xmit(net_tx_hook);
+	unregister_trace_net_dev_receive(net_rx_hook);
+	tracepoint_synchronize_unregister();
+}
+
+/*
+ * mirror_dev
+ * Params:
+ *   src_dev: the net_device struct to monitor for frames
+ *   dst_dev: the net_device struct to copy src_dev frames to
+ * Returns:
+ *  0 on success
+ *  -ERRNO on failure
+ */
+int mirror_dev(struct net_device *src_dev, struct net_device *dst_dev)
+{
+	struct mirror_entry *newm;
+	int rc = -EEXIST; 
+
+
+
+	if (find_mirror_entry(src_dev, dst_dev))
+		goto out;
+
+	rc = -ENOMEM;
+	newm = kmalloc(sizeof(struct mirror_entry), GFP_KERNEL);
+	if (!newm)
+		goto out;
+
+	if (list_empty(&mirror_list))
+		rc = enable_mirror_tracepoints();
+	if (rc)
+		goto out_free;
+
+
+	newm->src_dev = src_dev;
+	newm->dst_dev = dst_dev;
+	dev_hold(src_dev);
+	dev_hold(dst_dev);
+	printk(KERN_CRIT "Adding src dev %p and dst dev %p\n",src_dev, dst_dev);
+	spin_lock(&mirror_list_lock);
+	list_add_rcu(&newm->list, &mirror_list);
+	spin_unlock(&mirror_list_lock);
+
+	rc = 0;	
+
+
+out:
+	return rc;
+
+out_free:
+	kfree(newm);
+	goto out;
+	
+}
+EXPORT_SYMBOL_GPL(mirror_dev);
+
+/*
+ * unmirror_dev
+ * Params:
+ *   src_dev: the net_device struct to monitor for frames
+ *   dst_dev: the net_device struct to copy src_dev frames to
+ * Returns:
+ *  0 on success
+ *  -ERRNO on failure
+ */
+int unmirror_dev(struct net_device *src_dev, struct net_device *dst_dev)
+{
+	struct mirror_entry *ent;
+	int rc = -ENOENT;
+
+	spin_lock(&mirror_list_lock);
+
+	ent = find_mirror_entry(src_dev, dst_dev);
+
+	if (!ent)
+		goto out_unlock;
+
+	rc = 0;
+
+	list_del_rcu(&ent->list);	
+	call_rcu(&ent->rcu, free_mirror_ent);
+
+	if (list_empty(&mirror_list))
+		disable_mirror_tracepoints();
+		
+out_unlock:
+	spin_unlock(&mirror_list_lock);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(unmirror_dev);
+
+/*
+ * list_mirror_devs
+ * Params:
+ *   src_dev: the net_device you are monitoring frames from
+ *   rc:  pointer to an integer for the return code
+ * Returns:
+ *	rc holds the number of elements in the array or -ERRNO
+ *	on failure
+ */
+char ** list_mirror_devs(struct net_device *src_dev, int *rc)
+{
+	struct mirror_entry *ent;
+	char **names = NULL;
+	int count = 0;
+	int i = 0;
+
+	*rc = -ENOENT;
+
+	rcu_read_lock();
+
+rescan:
+	list_for_each_entry_rcu(ent, &mirror_list, list) {
+		if (ent->src_dev == src_dev) { 
+			if (*rc == -ENOENT)
+				count++;
+			else
+				names[i++] = ent->dst_dev->name;
+		}
+	}
+
+	if (*rc == count)
+		goto out;
+	else if (count != 0) {
+		*rc = count;
+		names = kmalloc(sizeof(char *)*count, GFP_KERNEL);
+		if (names == NULL) {
+			*rc = -ENOMEM;
+			goto out;
+		}
+		goto rescan;
+	}
+
+out:
+	rcu_read_unlock();
+	return names;
+
+}
+EXPORT_SYMBOL_GPL(list_mirror_devs);
+
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index fbc1c74..c20415d 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -16,6 +16,7 @@
 #include <net/sock.h>
 #include <linux/rtnetlink.h>
 #include <linux/wireless.h>
+#include <linux/portmirror.h>
 #include <net/wext.h>
 
 #include "net-sysfs.h"
@@ -289,6 +290,78 @@ static ssize_t show_ifalias(struct device *dev,
 	return ret;
 }
 
+#ifdef CONFIG_NET_PORT_MIRRORING
+static ssize_t show_port_mirror(struct device *dev,
+			    struct device_attribute *attr, char *buf)
+{
+	int rc;
+	struct net_device  *src_dev = to_net_dev(dev);
+	char **names = NULL;
+	int i;
+	ssize_t ret = 0;
+	
+	names = list_mirror_devs(src_dev, &rc);
+	if (rc < 0)
+		return ret;
+
+	for(i=0 ; i<rc; i++) {
+		ret += sprintf(&buf[ret], "%s ", names[i]);
+	}
+	ret += sprintf(&buf[ret], "\n");
+	/*
+	 * need to free the names passed to us here
+	 */
+	kfree(names);
+	return ret;
+	
+}
+
+static ssize_t store_port_mirror(struct device *dev, struct device_attribute *attr,
+			    const char *buf, size_t len)
+{
+	int rc = -EINVAL;
+	struct net_device *dst_dev;
+	struct net_device *src_dev = to_net_dev(dev);
+	char removing = 0;
+
+	/*
+	 * Abort if theres not enough data
+	 */
+	if (len <= 1)
+		goto out;
+
+	/*
+	 * check to see if we're doing a removal
+	 * and get the appropriate destination device
+	 */
+	printk(KERN_CRIT "buf[0] is %c (0x%x)\n", buf[0], buf[0]);
+	if (buf[0] == '-') {
+		removing = 1;
+		printk(KERN_CRIT "REMOVING DEV %s\n", &buf[1]);
+		dst_dev = dev_get_by_name(dev_net(src_dev), &buf[1]);
+	} else
+		dst_dev = dev_get_by_name(dev_net(src_dev), buf);
+
+	rc = -ENOENT;
+	if (!dst_dev)
+		goto out;
+
+	/*
+	 * now we just need to insert or remove the mirror device
+	 */
+	if (removing)
+		rc = unmirror_dev(src_dev, dst_dev);
+	else
+		rc = mirror_dev(src_dev, dst_dev);
+
+	dev_put(dst_dev);
+
+	rc = (rc == 0) ? len : rc;
+out:
+	return rc;
+}
+#endif
+
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
 	__ATTR(dev_id, S_IRUGO, show_dev_id, NULL),
@@ -309,6 +382,10 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
+#ifdef CONFIG_NET_PORT_MIRRORING
+	__ATTR(mirror_to, S_IRUGO | S_IWUSR, show_port_mirror,
+	       store_port_mirror),
+#endif
 	{}
 };
 
