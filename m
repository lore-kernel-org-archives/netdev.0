From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [RFC] add rtnl semaphore to linux-atm
Date: Wed, 01 Oct 2003 07:34:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310011134.h91BYPkT003172@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

i am thinking about doing the following to fix the race
during ATM_ITF_ANY operation.  rtnl is held across 
registration/unregistration.  this means that you can get
read-only access to the device list by holding rtnl
or a read_lock on atm_dev_lock similar to the scheme
used by netdevice (or so i think).

(the register_atmdevice/unregister just make it 
easier to see where one might call netdevice instead
in the future)


===== drivers/atm/atmtcp.c 1.20 vs edited =====
--- 1.20/drivers/atm/atmtcp.c	Tue Sep 23 19:22:15 2003
+++ edited/drivers/atm/atmtcp.c	Mon Sep 29 21:34:36 2003
@@ -378,7 +378,7 @@
 	struct atm_dev *dev;
 
 	dev = NULL;
-	if (itf != -1) dev = atm_dev_lookup(itf);
+	if (itf != -1) dev = atm_dev_get_by_index(itf);
 	if (dev) {
 		if (dev->ops != &atmtcp_v_dev_ops) {
 			atm_dev_put(dev);
@@ -415,7 +415,7 @@
 	struct atm_dev *dev;
 	struct atmtcp_dev_data *dev_data;
 
-	dev = atm_dev_lookup(itf);
+	dev = atm_dev_get_by_index(itf);
 	if (!dev) return -ENODEV;
 	if (dev->ops != &atmtcp_v_dev_ops) {
 		atm_dev_put(dev);
===== include/linux/atmdev.h 1.32 vs edited =====
--- 1.32/include/linux/atmdev.h	Tue Sep 23 18:19:10 2003
+++ edited/include/linux/atmdev.h	Mon Sep 29 21:59:18 2003
@@ -388,7 +388,7 @@
 
 struct atm_dev *atm_dev_register(const char *type,const struct atmdev_ops *ops,
     int number,unsigned long *flags); /* number == -1: pick first available */
-struct atm_dev *atm_dev_lookup(int number);
+struct atm_dev *atm_dev_get_by_index(int ifindex);
 void atm_dev_deregister(struct atm_dev *dev);
 void shutdown_atm_dev(struct atm_dev *dev);
 void vcc_insert_socket(struct sock *sk);
@@ -435,11 +435,12 @@
 {
 	atomic_dec(&dev->refcnt);
 
-	if ((atomic_read(&dev->refcnt) == 1) &&
+	if ((atomic_read(&dev->refcnt) == 0) &&
 	    test_bit(ATM_DF_CLOSE,&dev->flags))
 		shutdown_atm_dev(dev);
 }
 
+#define __atm_dev_put(dev) atomic_dec(&(dev)->refcnt)
 
 int atm_charge(struct atm_vcc *vcc,int truesize);
 struct sk_buff *atm_alloc_charge(struct atm_vcc *vcc,int pdu_size,
===== net/atm/common.c 1.54 vs edited =====
--- 1.54/net/atm/common.c	Tue Sep 23 13:38:28 2003
+++ edited/net/atm/common.c	Mon Sep 29 22:24:27 2003
@@ -426,7 +426,7 @@
 	    vcc->qos.rxtp.traffic_class == ATM_ANYCLASS)
 		return -EINVAL;
 	if (itf != ATM_ITF_ANY) {
-		dev = atm_dev_lookup(itf);
+		dev = atm_dev_get_by_index(itf);
 		if (!dev)
 			return -ENODEV;
 		error = __vcc_connect(vcc, dev, vpi, vci);
@@ -435,21 +435,19 @@
 			return error;
 		}
 	} else {
-		struct list_head *p, *next;
+		struct list_head *p;
 
 		dev = NULL;
-		spin_lock(&atm_dev_lock);
-		list_for_each_safe(p, next, &atm_devs) {
+		rtnl_lock();
+		list_for_each(p, &atm_devs) {
 			dev = list_entry(p, struct atm_dev, dev_list);
 			atm_dev_hold(dev);
-			spin_unlock(&atm_dev_lock);
 			if (!__vcc_connect(vcc, dev, vpi, vci))
 				break;
-			atm_dev_put(dev);
+			__atm_dev_put(dev);
 			dev = NULL;
-			spin_lock(&atm_dev_lock);
 		}
-		spin_unlock(&atm_dev_lock);
+		rtnl_unlock();
 		if (!dev)
 			return -ENODEV;
 	}
===== net/atm/resources.c 1.21 vs edited =====
--- 1.21/net/atm/resources.c	Thu Sep 11 06:41:52 2003
+++ edited/net/atm/resources.c	Tue Sep 30 07:10:43 2003
@@ -24,7 +24,7 @@
 
 
 LIST_HEAD(atm_devs);
-spinlock_t atm_dev_lock = SPIN_LOCK_UNLOCKED;
+static rwlock_t atm_dev_lock = RW_LOCK_UNLOCKED;
 
 static struct atm_dev *__alloc_atm_dev(const char *type)
 {
@@ -47,7 +47,7 @@
 	kfree(dev);
 }
 
-static struct atm_dev *__atm_dev_lookup(int number)
+static struct atm_dev *__atm_dev_get_by_index(int number)
 {
 	struct atm_dev *dev;
 	struct list_head *p;
@@ -55,27 +55,65 @@
 	list_for_each(p, &atm_devs) {
 		dev = list_entry(p, struct atm_dev, dev_list);
 		if ((dev->ops) && (dev->number == number)) {
-			atm_dev_hold(dev);
 			return dev;
 		}
 	}
 	return NULL;
 }
 
-struct atm_dev *atm_dev_lookup(int number)
+struct atm_dev *atm_dev_get_by_index(int number)
 {
 	struct atm_dev *dev;
 
-	spin_lock(&atm_dev_lock);
-	dev = __atm_dev_lookup(number);
-	spin_unlock(&atm_dev_lock);
+	read_lock(&atm_dev_lock);
+	dev = __atm_dev_get_by_index(number);
+	if (dev)
+		atm_dev_hold(dev);
+	read_unlock(&atm_dev_lock);
 	return dev;
 }
 
+static int register_atmdevice(struct atm_dev *dev)
+{
+	write_lock_irq(&atm_dev_lock);
+	list_add_tail(&dev->dev_list, &atm_devs);
+	atm_dev_hold(dev);
+	write_unlock_irq(&atm_dev_lock);
+
+	if (atm_proc_dev_register(dev) < 0) {
+		printk(KERN_ERR "atm_dev_register: "
+		       "atm_proc_dev_register failed for dev %s\n",
+		       dev->type);
+		write_lock_irq(&atm_dev_lock);
+		list_del(&dev->dev_list);
+		write_unlock_irq(&atm_dev_lock);
+		return -EIO;
+	}
+
+	return 0;
+}
+
+static int atm_dev_alloc_index(struct atm_dev *dev, int number)
+{
+	if (number != -1) {
+		if ((__atm_dev_get_by_index(number)))
+			return -EBUSY;
+	} else {
+		number = 0;
+		while ((__atm_dev_get_by_index(number))) {
+			number++;
+		}
+	}
+	dev->number = number;
+
+	return 0;
+}
+
 struct atm_dev *atm_dev_register(const char *type, const struct atmdev_ops *ops,
 				 int number, unsigned long *flags)
 {
-	struct atm_dev *dev, *inuse;
+	struct atm_dev *dev;
+	int err;
 
 	dev = __alloc_atm_dev(type);
 	if (!dev) {
@@ -83,60 +121,51 @@
 		    type);
 		return NULL;
 	}
-	spin_lock(&atm_dev_lock);
-	if (number != -1) {
-		if ((inuse = __atm_dev_lookup(number))) {
-			atm_dev_put(inuse);
-			spin_unlock(&atm_dev_lock);
-			__free_atm_dev(dev);
-			return NULL;
-		}
-		dev->number = number;
-	} else {
-		dev->number = 0;
-		while ((inuse = __atm_dev_lookup(dev->number))) {
-			atm_dev_put(inuse);
-			dev->number++;
-		}
-	}
 
 	dev->ops = ops;
 	if (flags)
 		dev->flags = *flags;
-	else
-		memset(&dev->flags, 0, sizeof(dev->flags));
-	memset(&dev->stats, 0, sizeof(dev->stats));
-	atomic_set(&dev->refcnt, 1);
-	list_add_tail(&dev->dev_list, &atm_devs);
-	spin_unlock(&atm_dev_lock);
 
-	if (atm_proc_dev_register(dev) < 0) {
-		printk(KERN_ERR "atm_dev_register: "
-		       "atm_proc_dev_register failed for dev %s\n",
-		       type);
-		spin_lock(&atm_dev_lock);
-		list_del(&dev->dev_list);
-		spin_unlock(&atm_dev_lock);
+	rtnl_lock();
+
+	err = atm_dev_alloc_index(dev, number);
+	if (err < 0)
+		goto out;
+
+	err = register_atmdevice(dev);
+
+out:
+	rtnl_unlock();
+
+	if (err < 0) {
 		__free_atm_dev(dev);
-		return NULL;
+		dev = NULL;
 	}
-
+		
 	return dev;
 }
 
+static void unregister_atmdevice(struct atm_dev *dev)
+{
+	atm_proc_dev_deregister(dev);
+
+	write_lock_irq(&atm_dev_lock);
+	list_del(&dev->dev_list);
+	write_unlock_irq(&atm_dev_lock);
+
+	atm_dev_put(dev);
+}
 
 void atm_dev_deregister(struct atm_dev *dev)
 {
 	unsigned long warning_time;
 
-	atm_proc_dev_deregister(dev);
-
-	spin_lock(&atm_dev_lock);
-	list_del(&dev->dev_list);
-	spin_unlock(&atm_dev_lock);
+	rtnl_lock();
+	unregister_atmdevice(dev);
+	rtnl_unlock();
 
         warning_time = jiffies;
-        while (atomic_read(&dev->refcnt) != 1) {
+        while (atomic_read(&dev->refcnt) != 0) {
                 current->state = TASK_INTERRUPTIBLE;
                 schedule_timeout(HZ / 4);
                 current->state = TASK_RUNNING;
@@ -153,7 +182,7 @@
 
 void shutdown_atm_dev(struct atm_dev *dev)
 {
-	if (atomic_read(&dev->refcnt) > 1) {
+	if (atomic_read(&dev->refcnt) > 0) {
 		set_bit(ATM_DF_CLOSE, &dev->flags);
 		return;
 	}
@@ -217,23 +246,23 @@
 			return -EFAULT;
 		if (get_user(len, &((struct atm_iobuf *) arg)->length))
 			return -EFAULT;
-		spin_lock(&atm_dev_lock);
+		read_lock(&atm_dev_lock);
 		list_for_each(p, &atm_devs)
 			size += sizeof(int);
 		if (size > len) {
-			spin_unlock(&atm_dev_lock);
+			read_unlock(&atm_dev_lock);
 			return -E2BIG;
 		}
 		tmp_buf = tmp_bufp = kmalloc(size, GFP_ATOMIC);
 		if (!tmp_buf) {
-			spin_unlock(&atm_dev_lock);
+			read_unlock(&atm_dev_lock);
 			return -ENOMEM;
 		}
 		list_for_each(p, &atm_devs) {
 			dev = list_entry(p, struct atm_dev, dev_list);
 			*tmp_bufp++ = dev->number;
 		}
-		spin_unlock(&atm_dev_lock);
+		read_unlock(&atm_dev_lock);
 	        error = (copy_to_user(buf, tmp_buf, size) ||
 				put_user(size, &((struct atm_iobuf *) arg)->length))
 					? -EFAULT : 0;
@@ -248,7 +277,7 @@
 	if (get_user(number, &((struct atmif_sioc *) arg)->number))
 		return -EFAULT;
 
-	if (!(dev = atm_dev_lookup(number)))
+	if (!(dev = atm_dev_get_by_index(number)))
 		return -ENODEV;
 	
 	switch (cmd) {
@@ -411,13 +440,13 @@
 
 void *atm_dev_seq_start(struct seq_file *seq, loff_t *pos)
 {
- 	spin_lock(&atm_dev_lock);
+ 	read_lock(&atm_dev_lock);
 	return *pos ? dev_get_idx(*pos) : (void *) 1;
 }
 
 void atm_dev_seq_stop(struct seq_file *seq, void *v)
 {
- 	spin_unlock(&atm_dev_lock);
+ 	read_unlock(&atm_dev_lock);
 }
  
 void *atm_dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
@@ -430,5 +459,5 @@
 
 EXPORT_SYMBOL(atm_dev_register);
 EXPORT_SYMBOL(atm_dev_deregister);
-EXPORT_SYMBOL(atm_dev_lookup);
+EXPORT_SYMBOL(atm_dev_get_by_index);
 EXPORT_SYMBOL(shutdown_atm_dev);
===== net/atm/resources.h 1.13 vs edited =====
--- 1.13/net/atm/resources.h	Mon Sep  8 13:27:12 2003
+++ edited/net/atm/resources.h	Mon Sep 29 22:03:48 2003
@@ -11,7 +11,6 @@
 
 
 extern struct list_head atm_devs;
-extern spinlock_t atm_dev_lock;
 
 
 int atm_dev_ioctl(unsigned int cmd, unsigned long arg);
