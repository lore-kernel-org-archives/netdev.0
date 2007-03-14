From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/6] IrDA: IrLAP raw mode
Date: Wed, 14 Mar 2007 21:23:31 +0200
Message-ID: <20070314192331.GD3397@sortiz.org>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch allows us to bypass the IrDA stack down to the IrLAP level.
Sending and receiving frames is done through a character device.
This is useful for e.g. doing real IrDA sniffing, testing external IrDA
stacks and for Lirc (once I will add the framing disabling switch).

Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 include/net/irda/irlap.h     |    5 +
 include/net/irda/irlap_raw.h |   27 +++
 net/irda/Kconfig             |   10 ++
 net/irda/Makefile            |    1 +
 net/irda/irlap.c             |    5 +
 net/irda/irlap_event.c       |    5 +
 net/irda/irlap_frame.c       |    6 +
 net/irda/irlap_raw.c         |  358 ++++++++++++++++++++++++++++++++++++++++++
 net/irda/irsysctl.c          |   16 ++-
 9 files changed, 432 insertions(+), 1 deletions(-)
 create mode 100644 include/net/irda/irlap_raw.h
 create mode 100644 net/irda/irlap_raw.c

diff --git a/include/net/irda/irlap.h b/include/net/irda/irlap.h
index e77eb88..1b24cfc 100644
--- a/include/net/irda/irlap.h
+++ b/include/net/irda/irlap.h
@@ -36,6 +36,7 @@
 #include <net/irda/qos.h>		/* struct qos_info */
 #include <net/irda/discovery.h>		/* discovery_t */
 #include <net/irda/irlap_event.h>	/* IRLAP_STATE, ... */
+#include <net/irda/irlap_raw.h>	        /* IRLAP raw definitions */
 #include <net/irda/irmod.h>		/* struct notify_t */
 
 #define CONFIG_IRDA_DYNAMIC_WINDOW 1
@@ -208,6 +209,10 @@ struct irlap_cb {
 	int    xbofs_delay;   /* Nr of XBOF's used to MTT */
 	int    bofs_count;    /* Negotiated extra BOFs */
 	int    next_bofs;     /* Negotiated extra BOFs after next frame */
+#ifdef CONFIG_IRDA_RAW
+	int    raw_mode;
+	struct irlap_raw * irlap_raw;
+#endif
 };
 
 /* 
diff --git a/include/net/irda/irlap_raw.h b/include/net/irda/irlap_raw.h
new file mode 100644
index 0000000..37a29dd
--- /dev/null
+++ b/include/net/irda/irlap_raw.h
@@ -0,0 +1,27 @@
+/*
+ * Copyright (C) 2007 Samuel Ortiz (samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation, version 2.
+ *
+ */
+
+#ifndef _IRLAP_RAW_H
+#define _IRLAP_RAW_H
+
+#ifdef CONFIG_IRDA_RAW
+
+int irlap_raw_recv_frame(struct sk_buff *skb, struct net_device *dev);
+int irlap_raw_register_device(struct net_device * dev);
+int irlap_raw_unregister_device(struct net_device * dev);
+
+#else
+
+#define irlap_raw_recv_frame(skbuff, netdev)
+#define irlap_raw_register_device(netdev)
+#define irlap_raw_unregister_device(netdev)
+
+#endif
+
+#endif
diff --git a/net/irda/Kconfig b/net/irda/Kconfig
index 9efb17b..310a036 100644
--- a/net/irda/Kconfig
+++ b/net/irda/Kconfig
@@ -92,5 +92,15 @@ config IRDA_DEBUG
 
 	  If unsure, say Y (since it makes it easier to find the bugs).
 
+config IRDA_RAW
+	bool "IrLAP raw"
+	depends on IRDA
+	help
+	  Say Y if you want to bypass the IrDA stack, down to the IrLAP level.
+	  This option allows you to send and receive IrLAP frames from
+	  userspace, by writing and reading to a character device
+	  (/dev/irdaX_raw). Note that the IrDA stack will be mostly disabled.
+	  If unsure, say N.
+
 source "drivers/net/irda/Kconfig"
 
diff --git a/net/irda/Makefile b/net/irda/Makefile
index d1366c2..11d5ffb 100644
--- a/net/irda/Makefile
+++ b/net/irda/Makefile
@@ -13,3 +13,4 @@ irda-y := iriap.o iriap_event.o irlmp.o irlmp_event.o irlmp_frame.o \
 	  discovery.o parameters.o irmod.o
 irda-$(CONFIG_PROC_FS) += irproc.o
 irda-$(CONFIG_SYSCTL) += irsysctl.o
+irda-$(CONFIG_IRDA_RAW) += irlap_raw.o
diff --git a/net/irda/irlap.c b/net/irda/irlap.c
index d93ebd1..656c949 100644
--- a/net/irda/irlap.c
+++ b/net/irda/irlap.c
@@ -173,6 +173,8 @@ struct irlap_cb *irlap_open(struct net_device *dev, struct qos_info *qos,
 
 	irlmp_register_link(self, self->saddr, &self->notify);
 
+	irlap_raw_register_device(dev);
+
 	return self;
 }
 EXPORT_SYMBOL(irlap_open);
@@ -234,6 +236,9 @@ void irlap_close(struct irlap_cb *self)
 		IRDA_DEBUG(1, "%s(), Didn't find myself!\n", __FUNCTION__);
 		return;
 	}
+
+	irlap_raw_unregister_device(self->netdev);
+
 	__irlap_close(lap);
 }
 EXPORT_SYMBOL(irlap_close);
diff --git a/net/irda/irlap_event.c b/net/irda/irlap_event.c
index 7b6433f..94a1288 100644
--- a/net/irda/irlap_event.c
+++ b/net/irda/irlap_event.c
@@ -241,6 +241,11 @@ void irlap_do_event(struct irlap_cb *self, IRLAP_EVENT event,
 	if (!self || self->magic != LAP_MAGIC)
 		return;
 
+#ifdef CONFIG_IRDA_RAW
+       if (self->raw_mode)
+               return;
+#endif
+
 	IRDA_DEBUG(3, "%s(), event = %s, state = %s\n", __FUNCTION__,
 		   irlap_event[event], irlap_state[self->state]);
 
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index 0b04603..6906a72 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -1323,6 +1323,12 @@ int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
 		return -1;
 	}
 
+#ifdef CONFIG_IRDA_RAW
+       if (self->raw_mode) {
+               return irlap_raw_recv_frame(skb, dev);
+       }
+#endif
+
 	/* We are no longer an "old" protocol, so we need to handle
 	 * share and non linear skbs. This should never happen, so
 	 * we don't need to be clever about it. Jean II */
diff --git a/net/irda/irlap_raw.c b/net/irda/irlap_raw.c
new file mode 100644
index 0000000..5a4c409
--- /dev/null
+++ b/net/irda/irlap_raw.c
@@ -0,0 +1,358 @@
+/*
+ * net/irda/irlap_raw.c Raw IrLAP character device.
+ * Copyright (C) 2007 Samuel Ortiz (samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation, version 2.
+ *
+ * From /dev/irdaN_raw, you can read and write raw IrLAP frames.
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/list.h>
+#include <linux/fs.h>
+#include <linux/poll.h>
+#include <linux/netdevice.h>
+#include <linux/if.h>
+#include <linux/list.h>
+#include <linux/mutex.h>
+#include <linux/workqueue.h>
+#include <linux/miscdevice.h>
+#include <linux/wait.h>
+
+#include <net/irda/irda.h>
+#include <net/irda/irda_device.h>
+#include <net/irda/irlap.h>
+#include <net/irda/irlap_raw.h>
+
+/* We keep the last 10 IrLAP frames */
+unsigned int sysctl_raw_ring_length = 10;
+
+struct irlap_raw {
+	struct list_head    list;
+	char                name[IFNAMSIZ + 8];
+	struct miscdevice   misc_device;
+	struct irlap_cb     * irlap;
+	struct sk_buff_head skb_ring;
+	wait_queue_head_t   rx_wait;
+	unsigned int        refcount;
+	struct mutex        rx_mutex;
+	struct mutex        tx_mutex;
+	struct work_struct  skb_ring_work;
+};
+
+static LIST_HEAD(irlap_raw_list);
+static DEFINE_MUTEX(irlap_raw_mutex);
+
+static void irlap_raw_skb_ring_gc(struct work_struct *work)
+{
+	struct irlap_raw * raw =
+		container_of(work, struct irlap_raw, skb_ring_work);
+
+	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+
+	if (mutex_lock_interruptible(&raw->rx_mutex))
+		return;
+
+	while(skb_queue_len(&raw->skb_ring) > sysctl_raw_ring_length) {
+		struct sk_buff * old_skb;
+
+		IRDA_DEBUG(3, "%s(): We still have %d entries\n",
+			   __FUNCTION__, skb_queue_len(&raw->skb_ring));
+
+		old_skb = skb_dequeue_tail(&raw->skb_ring);
+		dev_kfree_skb(old_skb);
+	}
+
+	mutex_unlock(&raw->rx_mutex);
+}
+
+int irlap_raw_recv_frame(struct sk_buff *skb, struct net_device *dev)
+{
+	struct irlap_cb * irlap;
+	struct irlap_raw * raw;
+
+	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+
+	irlap = dev->atalk_ptr;
+	if (irlap == NULL)
+		return -ENODEV;
+
+	if (skb == NULL)
+		return -EINVAL;
+
+	raw = irlap->irlap_raw;
+	if (raw == NULL)
+		return -ENODEV;
+
+	skb_queue_head(&raw->skb_ring, skb);
+
+	wake_up_interruptible(&raw->rx_wait);
+
+	/*
+	 * We call the "garbage collector" in process
+	 * context, so that we can lock the skb removal
+	 * against read().
+	 */
+	if (skb_queue_len(&raw->skb_ring) > sysctl_raw_ring_length) {
+		IRDA_DEBUG(3, "%s(): We have %d entries, time to clean up\n",
+			   __FUNCTION__, skb_queue_len(&raw->skb_ring));
+		schedule_work(&raw->skb_ring_work);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(irlap_raw_recv_frame);
+
+
+ssize_t irlap_raw_read(struct file * file, char __user * buf,
+		       size_t count, loff_t * ppos)
+{
+	int ret = 0;
+	struct irlap_raw * raw;
+	struct sk_buff * frame;
+
+	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+
+	raw = file->private_data;
+
+	ret = mutex_lock_interruptible(&raw->rx_mutex);
+	if (ret)
+		return ret;
+
+	ret = wait_event_interruptible(raw->rx_wait,
+				       !skb_queue_empty(&raw->skb_ring));
+	if (ret < 0)
+		goto out;
+
+	if (skb_queue_empty(&raw->skb_ring)) {
+		ret = -EINTR;
+		IRDA_DEBUG(3, "%s(): Queue is empty\n", __FUNCTION__);
+		goto out;
+	}
+
+	frame = skb_dequeue_tail(&raw->skb_ring);
+
+	if (frame == NULL) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	if (copy_to_user(buf, frame->data, frame->len)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	ret = frame->len;
+	dev_kfree_skb(frame);
+
+ out:
+	mutex_unlock(&raw->rx_mutex);
+
+	IRDA_DEBUG(3, "%s(): Read %d bytes\n", __FUNCTION__, ret);
+	return ret;
+}
+
+extern void irlap_queue_xmit(struct irlap_cb *self, struct sk_buff *skb);
+ssize_t irlap_raw_write(struct file * file, const char __user * buf,
+			size_t count, loff_t * ppos)
+{
+	int ret;
+	struct irlap_raw * raw;
+	struct sk_buff *tx_skb;
+
+	IRDA_DEBUG(3, "%s(): Trying to write %d bytes\n", __FUNCTION__, count);
+
+	raw = file->private_data;
+
+	ret = mutex_lock_interruptible(&raw->tx_mutex);
+	if (ret)
+		return ret;
+
+	if (count == 0)
+		goto out;
+
+	tx_skb = alloc_skb(IRDA_SIR_MAX_FRAME, GFP_KERNEL);
+	if (tx_skb == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	if (copy_from_user(skb_put(tx_skb, count), buf, count)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	irlap_queue_xmit(raw->irlap, tx_skb);
+
+	ret = count;
+ out:
+	mutex_unlock(&raw->tx_mutex);
+
+	IRDA_DEBUG(3, "%s(): Wrote %d bytes\n", __FUNCTION__, ret);
+	return ret;
+}
+
+unsigned int irlap_raw_poll(struct file * file,
+			    struct poll_table_struct * table)
+{
+	int ret = 0;
+	struct irlap_raw * raw;
+
+	raw = file->private_data;
+
+        poll_wait(file, &raw->rx_wait, table);
+
+        if (!skb_queue_empty(&raw->skb_ring))
+                ret = POLLIN | POLLRDNORM;
+	else
+		ret = POLLOUT | POLLWRNORM;
+
+	return ret;
+}
+
+int irlap_raw_open(struct inode * inode, struct file * file)
+{
+	unsigned int minor = iminor(inode);
+	int ret = -ENODEV;
+	struct irlap_raw * raw, * tmp;
+
+	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+
+	mutex_lock_interruptible(&irlap_raw_mutex);
+	list_for_each_entry_safe(raw, tmp, &irlap_raw_list, list) {
+		if (raw->misc_device.minor == minor) {
+			IRDA_DEBUG(3, "%s(): Found raw (minor: %d)\n",
+				   __FUNCTION__, minor);
+			file->private_data = raw;
+			raw->irlap->raw_mode = 1;
+			raw->refcount++;
+			mutex_unlock(&irlap_raw_mutex);
+			return 0;
+		}
+	}
+
+	mutex_unlock(&irlap_raw_mutex);
+	return ret;
+}
+
+int irlap_raw_release(struct inode * inode, struct file * file)
+{
+	struct irlap_raw * raw;
+
+	if (file->private_data) {
+		mutex_lock_interruptible(&irlap_raw_mutex);
+
+		raw = file->private_data;
+		if (raw->refcount > 0)
+			raw->refcount--;
+
+		if (raw->refcount == 0) {
+			skb_queue_purge(&raw->skb_ring);
+			raw->irlap->raw_mode = 0;
+		}
+
+		file->private_data = NULL;
+
+		mutex_unlock(&irlap_raw_mutex);
+	}
+
+	return 0;
+}
+
+static const struct file_operations irlap_raw_fops = {
+	.owner		= THIS_MODULE,
+	.read		= irlap_raw_read,
+	.write          = irlap_raw_write,
+	.poll		= irlap_raw_poll,
+	.open		= irlap_raw_open,
+	.release	= irlap_raw_release,
+};
+
+
+int irlap_raw_register_device(struct net_device * dev)
+{
+	int ret = 0;
+	struct irlap_cb * irlap;
+	struct irlap_raw * raw;
+
+	if (dev == NULL)
+		return -ENODEV;
+
+	raw = kzalloc(sizeof(struct irlap_raw), GFP_KERNEL);
+	if (raw == NULL)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&raw->list);
+	INIT_WORK(&raw->skb_ring_work, irlap_raw_skb_ring_gc);
+	mutex_init(&raw->rx_mutex);
+	mutex_init(&raw->tx_mutex);
+	raw->refcount = 0;
+	skb_queue_head_init(&raw->skb_ring);
+
+	sprintf(raw->name, "%s_raw", dev->name);
+	raw->misc_device.minor = MISC_DYNAMIC_MINOR;
+	raw->misc_device.name = raw->name;
+	raw->misc_device.fops = &irlap_raw_fops;
+
+	list_add(&raw->list, &irlap_raw_list);
+
+	irlap = dev->atalk_ptr;
+	if (irlap == NULL) {
+		ret = -ENODEV;
+		goto out_err;
+	}
+
+        /* We'll enter raw mode whenever the device is open */
+	irlap->raw_mode = 0;
+	irlap->irlap_raw = raw;
+
+	init_waitqueue_head(&raw->rx_wait);
+
+	raw->irlap = irlap;
+
+	ret = misc_register(&raw->misc_device);
+	if (!ret) {
+		printk(KERN_INFO "Registered %s raw IrLAP device\n", raw->name);
+		return ret;
+	}
+
+ out_err:
+	irlap->irlap_raw = NULL;
+	kfree(raw);
+	return ret;
+
+}
+EXPORT_SYMBOL(irlap_raw_register_device);
+
+
+int irlap_raw_unregister_device(struct net_device * dev)
+{
+	struct irlap_cb * irlap;
+	struct irlap_raw * raw;
+
+	irlap = dev->atalk_ptr;
+	if (irlap == NULL)
+		return -ENODEV;
+
+	raw = irlap->irlap_raw;
+	mutex_lock_interruptible(&irlap_raw_mutex);
+	if (raw->refcount) {
+		mutex_unlock(&irlap_raw_mutex);
+		return -EBUSY;
+	}
+
+	printk(KERN_INFO "%s unregistered\n", raw->name);
+
+	list_del(&raw->list);
+	misc_deregister(&raw->misc_device);
+
+	mutex_unlock(&irlap_raw_mutex);
+
+	kfree(raw);
+
+	return 0;
+}
+EXPORT_SYMBOL(irlap_raw_unregister_device);
diff --git a/net/irda/irsysctl.c b/net/irda/irsysctl.c
index 2e968e7..a7e967d 100644
--- a/net/irda/irsysctl.c
+++ b/net/irda/irsysctl.c
@@ -35,7 +35,7 @@
 enum { DISCOVERY=1, DEVNAME, DEBUG, FAST_POLL, DISCOVERY_SLOTS,
        DISCOVERY_TIMEOUT, SLOT_TIMEOUT, MAX_BAUD_RATE, MIN_TX_TURN_TIME,
        MAX_TX_DATA_SIZE, MAX_TX_WINDOW, MAX_NOREPLY_TIME, WARN_NOREPLY_TIME,
-       LAP_KEEPALIVE_TIME };
+       LAP_KEEPALIVE_TIME, RAW_RING_LENGTH };
 
 extern int  sysctl_discovery;
 extern int  sysctl_discovery_slots;
@@ -50,6 +50,9 @@ extern int  sysctl_max_tx_window;
 extern int  sysctl_max_noreply_time;
 extern int  sysctl_warn_noreply_time;
 extern int  sysctl_lap_keepalive_time;
+#ifdef CONFIG_IRDA_RAW
+extern unsigned int  sysctl_raw_ring_length;
+#endif
 
 /* this is needed for the proc_dointvec_minmax - Jean II */
 static int max_discovery_slots = 16;		/* ??? */
@@ -237,6 +240,17 @@ static ctl_table irda_table[] = {
 		.extra1		= &min_lap_keepalive_time,
 		.extra2		= &max_lap_keepalive_time
 	},
+#ifdef CONFIG_IRDA_RAW
+	{
+		.ctl_name	= RAW_RING_LENGTH,
+		.procname	= "raw_ring_length",
+		.data		= &sysctl_raw_ring_length,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
+#endif
+
 	{ .ctl_name = 0 }
 };
 
-- 
1.5.0.2


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
