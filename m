From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM] a few patches from John Levon
Date: Thu, 04 Sep 2003 15:17:55 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309041917.h84JHrSa020864@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com, levon@movementarian.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030904022700.GA67203@compsoc.man.ac.uk>,John Levon writes:
>Kconfig in 2.6 seems to let ATM be compiled as a module, but the
>proto_ops and net_proto_family ops won't be refcounted. I haven't
>tested, but it looks to me like this would allow a rmmod on live code.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1420  -> 1.1421 
#	       net/atm/pvc.c	1.20    -> 1.21   
#	       net/atm/svc.c	1.24    -> 1.25   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/04	chas@relax.cmf.nrl.navy.mil	1.1421
# [ATM]: pvc/svc missing .owner for proto_ops/family (from levon@movementarian.org)
# --------------------------------------------
#
diff -Nru a/net/atm/pvc.c b/net/atm/pvc.c
--- a/net/atm/pvc.c	Thu Sep  4 15:03:08 2003
+++ b/net/atm/pvc.c	Thu Sep  4 15:03:08 2003
@@ -104,6 +104,7 @@
 
 static struct proto_ops pvc_proto_ops = {
 	.family =	PF_ATMPVC,
+	.owner =	THIS_MODULE,
 
 	.release =	vcc_release,
 	.bind =		pvc_bind,
@@ -134,6 +135,7 @@
 static struct net_proto_family pvc_family_ops = {
 	.family = PF_ATMPVC,
 	.create = pvc_create,
+	.owner = THIS_MODULE,
 };
 
 
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Thu Sep  4 15:03:08 2003
+++ b/net/atm/svc.c	Thu Sep  4 15:03:08 2003
@@ -513,6 +513,7 @@
 
 static struct proto_ops svc_proto_ops = {
 	.family =	PF_ATMSVC,
+	.owner =	THIS_MODULE,
 
 	.release =	svc_release,
 	.bind =		svc_bind,
@@ -549,6 +550,7 @@
 static struct net_proto_family svc_family_ops = {
 	.family = PF_ATMSVC,
 	.create = svc_create,
+	.owner = THIS_MODULE,
 };
 
 
In message <20030904073612.GA79992@compsoc.man.ac.uk>,John Levon writes:
>Here's an updated patch.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1421  -> 1.1422 
#	    net/atm/common.c	1.49    -> 1.50   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/04	chas@relax.cmf.nrl.navy.mil	1.1422
# [ATM]: fix atm_dev module refcount bug (from levon@movementarian.org)
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Thu Sep  4 14:58:58 2003
+++ b/net/atm/common.c	Thu Sep  4 14:58:58 2003
@@ -422,26 +422,31 @@
 	}
 	if (!error) error = adjust_tp(&vcc->qos.txtp,vcc->qos.aal);
 	if (!error) error = adjust_tp(&vcc->qos.rxtp,vcc->qos.aal);
-	if (error) {
-		vcc_remove_socket(vcc->sk);
-		return error;
-	}
+	if (error)
+		goto fail;
 	DPRINTK("VCC %d.%d, AAL %d\n",vpi,vci,vcc->qos.aal);
 	DPRINTK("  TX: %d, PCR %d..%d, SDU %d\n",vcc->qos.txtp.traffic_class,
 	    vcc->qos.txtp.min_pcr,vcc->qos.txtp.max_pcr,vcc->qos.txtp.max_sdu);
 	DPRINTK("  RX: %d, PCR %d..%d, SDU %d\n",vcc->qos.rxtp.traffic_class,
 	    vcc->qos.rxtp.min_pcr,vcc->qos.rxtp.max_pcr,vcc->qos.rxtp.max_sdu);
-	if (!try_module_get(dev->ops->owner))
-		return -ENODEV;
+	if (!try_module_get(dev->ops->owner)) {
+		error = -ENODEV;
+		goto fail;
+	}
+
 	if (dev->ops->open) {
-		error = dev->ops->open(vcc,vpi,vci);
-		if (error) {
-			module_put(dev->ops->owner);
-			vcc_remove_socket(vcc->sk);
-			return error;
-		}
+		if ((error = dev->ops->open(vcc,vpi,vci)))
+			goto put_module_fail;
 	}
 	return 0;
+
+put_module_fail:
+	module_put(dev->ops->owner);
+fail:
+	vcc_remove_socket(vcc->sk);
+	/* ensure we get dev module ref count correct */
+	vcc->dev = NULL;
+	return error;
 }
 
 


In message <20030904085844.GA87022@compsoc.man.ac.uk>,John Levon writes:
>This re-arranges things a bit to remove some clutter from the .c
>code as per preferred coding style. Against current Linus CVS.

[editor's note: i added the /* nothing */ in the empty inline stubs
to hopefully reduce any confusion.]


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1419  -> 1.1420 
#	      net/atm/proc.c	1.25    -> 1.26   
#	    net/atm/common.h	1.18    -> 1.19   
#	 net/atm/resources.h	1.10    -> 1.11   
#	 net/atm/resources.c	1.16    -> 1.17   
#	    net/atm/common.c	1.48    -> 1.49   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/04	chas@relax.cmf.nrl.navy.mil	1.1420
# [ATM]: reduce CONFIG_PROC_FS #ifdef clutter in .c code (from levon@movementarian.org) 
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Thu Sep  4 14:35:33 2003
+++ b/net/atm/common.c	Thu Sep  4 14:35:33 2003
@@ -1109,12 +1109,10 @@
 		printk(KERN_ERR "atmsvc_init() failed with %d\n", error);
 		goto failure;
 	}
-#ifdef CONFIG_PROC_FS
         if ((error = atm_proc_init()) < 0) {
 		printk(KERN_ERR "atm_proc_init() failed with %d\n",error);
 		goto failure;
 	}
-#endif
 	return 0;
 
 failure:
@@ -1125,9 +1123,7 @@
 
 static void __exit atm_exit(void)
 {
-#ifdef CONFIG_PROC_FS
 	atm_proc_exit();
-#endif
 	atmsvc_exit();
 	atmpvc_exit();
 }
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Thu Sep  4 14:35:33 2003
+++ b/net/atm/common.h	Thu Sep  4 14:35:33 2003
@@ -33,8 +33,21 @@
 void atmpvc_exit(void);
 int atmsvc_init(void);
 void atmsvc_exit(void);
+
+#ifdef CONFIG_PROC_FS
 int atm_proc_init(void);
 void atm_proc_exit(void);
+#else
+static inline int atm_proc_init(void)
+{
+	return 0;
+}
+
+static inline void atm_proc_exit(void)
+{
+	/* nothing */
+}
+#endif /* CONFIG_PROC_FS */
 
 /* SVC */
 
diff -Nru a/net/atm/proc.c b/net/atm/proc.c
--- a/net/atm/proc.c	Thu Sep  4 14:35:33 2003
+++ b/net/atm/proc.c	Thu Sep  4 14:35:33 2003
@@ -895,6 +895,10 @@
 	int digits,num;
 	int error;
 
+	/* No proc info */
+	if (!dev->ops->proc_read)
+		return 0;
+
 	error = -ENOMEM;
 	digits = 0;
 	for (num = dev->number; num; num /= 10) digits++;
@@ -920,6 +924,9 @@
 
 void atm_proc_dev_deregister(struct atm_dev *dev)
 {
+	if (!dev->ops->proc_read)
+		return;
+
 	remove_proc_entry(dev->proc_name, atm_proc_root);
 	kfree(dev->proc_name);
 }
diff -Nru a/net/atm/resources.c b/net/atm/resources.c
--- a/net/atm/resources.c	Thu Sep  4 14:35:33 2003
+++ b/net/atm/resources.c	Thu Sep  4 14:35:33 2003
@@ -110,20 +110,16 @@
 	list_add_tail(&dev->dev_list, &atm_devs);
 	spin_unlock(&atm_dev_lock);
 
-#ifdef CONFIG_PROC_FS
-	if (ops->proc_read) {
-		if (atm_proc_dev_register(dev) < 0) {
-			printk(KERN_ERR "atm_dev_register: "
-			       "atm_proc_dev_register failed for dev %s\n",
-			       type);
-			spin_lock(&atm_dev_lock);
-			list_del(&dev->dev_list);
-			spin_unlock(&atm_dev_lock);
-			__free_atm_dev(dev);
-			return NULL;
-		}
+	if (atm_proc_dev_register(dev) < 0) {
+		printk(KERN_ERR "atm_dev_register: "
+		       "atm_proc_dev_register failed for dev %s\n",
+		       type);
+		spin_lock(&atm_dev_lock);
+		list_del(&dev->dev_list);
+		spin_unlock(&atm_dev_lock);
+		__free_atm_dev(dev);
+		return NULL;
 	}
-#endif
 
 	return dev;
 }
@@ -133,10 +129,8 @@
 {
 	unsigned long warning_time;
 
-#ifdef CONFIG_PROC_FS
-	if (dev->ops->proc_read)
-		atm_proc_dev_deregister(dev);
-#endif
+	atm_proc_dev_deregister(dev);
+
 	spin_lock(&atm_dev_lock);
 	list_del(&dev->dev_list);
 	spin_unlock(&atm_dev_lock);
diff -Nru a/net/atm/resources.h b/net/atm/resources.h
--- a/net/atm/resources.h	Thu Sep  4 14:35:33 2003
+++ b/net/atm/resources.h	Thu Sep  4 14:35:33 2003
@@ -29,6 +29,18 @@
 int atm_proc_dev_register(struct atm_dev *dev);
 void atm_proc_dev_deregister(struct atm_dev *dev);
 
-#endif
+#else
+
+static inline int atm_proc_dev_register(struct atm_dev *dev)
+{
+	return 0;
+}
+
+static inline void atm_proc_dev_deregister(struct atm_dev *dev)
+{
+	/* nothing */
+}
+
+#endif /* CONFIG_PROC_FS */
 
 #endif


In message <20030904092414.GF87022@compsoc.man.ac.uk>,John Levon writes:
>The problem UNUSED solves has been solved in the module_init/exit()
>macros for quite some time.


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1421  -> 1.1422 
#	    net/atm/common.c	1.49    -> 1.50   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/04	chas@relax.cmf.nrl.navy.mil	1.1422
# [ATM]: fix atm_dev module refcount bug (from levon@movementarian.org)
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Thu Sep  4 15:14:04 2003
+++ b/net/atm/common.c	Thu Sep  4 15:14:04 2003
@@ -422,26 +422,31 @@
 	}
 	if (!error) error = adjust_tp(&vcc->qos.txtp,vcc->qos.aal);
 	if (!error) error = adjust_tp(&vcc->qos.rxtp,vcc->qos.aal);
-	if (error) {
-		vcc_remove_socket(vcc->sk);
-		return error;
-	}
+	if (error)
+		goto fail;
 	DPRINTK("VCC %d.%d, AAL %d\n",vpi,vci,vcc->qos.aal);
 	DPRINTK("  TX: %d, PCR %d..%d, SDU %d\n",vcc->qos.txtp.traffic_class,
 	    vcc->qos.txtp.min_pcr,vcc->qos.txtp.max_pcr,vcc->qos.txtp.max_sdu);
 	DPRINTK("  RX: %d, PCR %d..%d, SDU %d\n",vcc->qos.rxtp.traffic_class,
 	    vcc->qos.rxtp.min_pcr,vcc->qos.rxtp.max_pcr,vcc->qos.rxtp.max_sdu);
-	if (!try_module_get(dev->ops->owner))
-		return -ENODEV;
+	if (!try_module_get(dev->ops->owner)) {
+		error = -ENODEV;
+		goto fail;
+	}
+
 	if (dev->ops->open) {
-		error = dev->ops->open(vcc,vpi,vci);
-		if (error) {
-			module_put(dev->ops->owner);
-			vcc_remove_socket(vcc->sk);
-			return error;
-		}
+		if ((error = dev->ops->open(vcc,vpi,vci)))
+			goto put_module_fail;
 	}
 	return 0;
+
+put_module_fail:
+	module_put(dev->ops->owner);
+fail:
+	vcc_remove_socket(vcc->sk);
+	/* ensure we get dev module ref count correct */
+	vcc->dev = NULL;
+	return error;
 }
 
 
