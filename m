From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM]: [ioctl][1/8] move vcc_ioctl() to ioctl.c (from levon@movementarian.org)
Date: Fri, 26 Sep 2003 09:48:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309261348.h8QDm2kT022888@ginger.cmf.nrl.navy.mil>
References: <davem@redhat.com>
Cc: Mitchell Blank Jr <mitch@sfgoth.com>, levon@movementarian.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: Message from "David S. Miller" <davem@redhat.com>
   of "Thu, 25 Sep 2003 20:55:30 PDT." <20030925205530.2a166ccc.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030925205530.2a166ccc.davem@redhat.com>,"David S. Miller" writes:
>What I'm going to do is just merge in all of what Chas posted
>today, you can send me new patches to update this to John's
>latest code.

that seems very reasonable.  i believe the following attached patch
will provide the initial backend interface that mitch's patchset
depends on (its really just name changes).  mitch, perhaps you could
just submit this as patch 0/N when you are ready to submit your
atm_backend changes.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1458  -> 1.1459 
#	    net/atm/br2684.c	1.12    -> 1.13   
#	       net/atm/lec.c	1.41    -> 1.42   
#	     net/atm/ioctl.c	1.7     -> 1.8    
#	drivers/atm/atmtcp.c	1.20    -> 1.21   
#	   net/atm/pppoatm.c	1.15    -> 1.16   
#	       net/atm/mpc.c	1.29    -> 1.30   
#	include/linux/atmdev.h	1.32    -> 1.33   
#	      net/atm/clip.c	1.29    -> 1.30   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/26	chas@relax.cmf.nrl.navy.mil	1.1459
# [ATM]: initial backend support (from levon@movementarian.org)
# --------------------------------------------
#
diff -Nru a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
--- a/drivers/atm/atmtcp.c	Fri Sep 26 09:43:45 2003
+++ b/drivers/atm/atmtcp.c	Fri Sep 26 09:43:45 2003
@@ -460,21 +460,21 @@
 	return err;
 }
 
-static struct atm_ioctl atmtcp_ioctl_ops = {
+static struct atm_backend atmtcp_ops = {
 	.owner 	= THIS_MODULE,
 	.ioctl	= atmtcp_ioctl,
 };
 
 static __init int atmtcp_init(void)
 {
-	register_atm_ioctl(&atmtcp_ioctl_ops);
+	register_atm_backend(&atmtcp_ops);
 	return 0;
 }
 
 
 static void __exit atmtcp_exit(void)
 {
-	deregister_atm_ioctl(&atmtcp_ioctl_ops);
+	deregister_atm_backend(&atmtcp_ops);
 }
 
 MODULE_LICENSE("GPL");
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Fri Sep 26 09:43:45 2003
+++ b/include/linux/atmdev.h	Fri Sep 26 09:43:45 2003
@@ -448,7 +448,7 @@
 
 void vcc_release_async(struct atm_vcc *vcc, int reply);
 
-struct atm_ioctl {
+struct atm_backend {
 	struct module *owner;
 	/* A module reference is kept if appropriate over this call.
 	 * Return -ENOIOCTLCMD if you don't handle it. */
@@ -457,18 +457,14 @@
 };
 
 /**
- * register_atm_ioctl - register handler for ioctl operations
- *
- * Special (non-device) handlers of ioctl's should
- * register here. If you're a normal device, you should
- * set .ioctl in your atmdev_ops instead.
+ * register_atm_backend - register an ATM backend
  */
-void register_atm_ioctl(struct atm_ioctl *);
+void register_atm_backend(struct atm_backend *);
 
 /**
- * deregister_atm_ioctl - remove the ioctl handler
+ * deregister_atm_backend - remove a backend
  */
-void deregister_atm_ioctl(struct atm_ioctl *);
+void deregister_atm_backend(struct atm_backend *);
 
 #endif /* __KERNEL__ */
 
diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	Fri Sep 26 09:43:45 2003
+++ b/net/atm/br2684.c	Fri Sep 26 09:43:45 2003
@@ -669,7 +669,7 @@
 	return -ENOIOCTLCMD;
 }
 
-static struct atm_ioctl br2684_ioctl_ops = {
+static struct atm_backend br2684_ops = {
 	.owner	= THIS_MODULE,
 	.ioctl	= br2684_ioctl,
 };
@@ -782,7 +782,7 @@
 		return -ENOMEM;
 	p->proc_fops = &br2684_proc_ops;
 #endif
-	register_atm_ioctl(&br2684_ioctl_ops);
+	register_atm_backend(&br2684_ops);
 	return 0;
 }
 
@@ -791,7 +791,7 @@
 	struct net_device *net_dev;
 	struct br2684_dev *brdev;
 	struct br2684_vcc *brvcc;
-	deregister_atm_ioctl(&br2684_ioctl_ops);
+	deregister_atm_backend(&br2684_ops);
 
 #ifdef CONFIG_PROC_FS
 	remove_proc_entry("br2684", atm_proc_root);
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Fri Sep 26 09:43:45 2003
+++ b/net/atm/clip.c	Fri Sep 26 09:43:45 2003
@@ -804,7 +804,7 @@
 	return err;
 }
 
-static struct atm_ioctl clip_ioctl_ops = {
+static struct atm_backend clip_ops = {
 	.owner 	= THIS_MODULE,
 	.ioctl	= clip_ioctl,
 };
@@ -1035,7 +1035,7 @@
 	skb_queue_head_init(&clip_tbl.proxy_queue);
 
 	clip_tbl_hook = &clip_tbl;
-	register_atm_ioctl(&clip_ioctl_ops);
+	register_atm_backend(&clip_ops);
 
 	return 0;
 }
@@ -1046,7 +1046,7 @@
 
 	remove_proc_entry("arp", atm_proc_root);
 
-	deregister_atm_ioctl(&clip_ioctl_ops);
+	deregister_atm_backend(&clip_ops);
 
 	neigh_ifdown(&clip_tbl, NULL);
 	dev = clip_devs;
diff -Nru a/net/atm/ioctl.c b/net/atm/ioctl.c
--- a/net/atm/ioctl.c	Fri Sep 26 09:43:45 2003
+++ b/net/atm/ioctl.c	Fri Sep 26 09:43:45 2003
@@ -23,26 +23,26 @@
 #include "signaling.h"		/* for WAITING and sigd_attach */
 
 
-static DECLARE_MUTEX(ioctl_mutex);
-static LIST_HEAD(ioctl_list);
+static DECLARE_MUTEX(backend_mutex);
+static LIST_HEAD(backend_list);
 
 
-void register_atm_ioctl(struct atm_ioctl *ioctl)
+void register_atm_backend(struct atm_backend *backend)
 {
-	down(&ioctl_mutex);
-	list_add_tail(&ioctl->list, &ioctl_list);
-	up(&ioctl_mutex);
+	down(&backend_mutex);
+	list_add_tail(&backend->list, &backend_list);
+	up(&backend_mutex);
 }
 
-void deregister_atm_ioctl(struct atm_ioctl *ioctl)
+void deregister_atm_backend(struct atm_backend *backend)
 {
-	down(&ioctl_mutex);
-	list_del(&ioctl->list);
-	up(&ioctl_mutex);
+	down(&backend_mutex);
+	list_del(&backend->list);
+	up(&backend_mutex);
 }
 
-EXPORT_SYMBOL(register_atm_ioctl);
-EXPORT_SYMBOL(deregister_atm_ioctl);
+EXPORT_SYMBOL(register_atm_backend);
+EXPORT_SYMBOL(deregister_atm_backend);
 
 int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
@@ -120,9 +120,9 @@
 
 	error = -ENOIOCTLCMD;
 
-	down(&ioctl_mutex);
-	list_for_each(pos, &ioctl_list) {
-		struct atm_ioctl * ic = list_entry(pos, struct atm_ioctl, list);
+	down(&backend_mutex);
+	list_for_each(pos, &backend_list) {
+		struct atm_backend * ic = list_entry(pos, struct atm_backend, list);
 		if (try_module_get(ic->owner)) {
 			error = ic->ioctl(sock, cmd, arg);
 			module_put(ic->owner);
@@ -130,7 +130,7 @@
 				break;
 		}
 	}
-	up(&ioctl_mutex);
+	up(&backend_mutex);
 
 	if (error != -ENOIOCTLCMD)
 		goto done;
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Fri Sep 26 09:43:45 2003
+++ b/net/atm/lec.c	Fri Sep 26 09:43:45 2003
@@ -1115,7 +1115,7 @@
 	return err;
 }
 
-static struct atm_ioctl lane_ioctl_ops = {
+static struct atm_backend lec_ops = {
 	.owner  = THIS_MODULE,
 	.ioctl  = lane_ioctl,
 };
@@ -1130,7 +1130,7 @@
 		p->proc_fops = &lec_seq_fops;
 #endif
 
-	register_atm_ioctl(&lane_ioctl_ops);
+	register_atm_backend(&lec_ops);
         printk("lec.c: " __DATE__ " " __TIME__ " initialized\n");
         return 0;
 }
@@ -1142,7 +1142,7 @@
 
 	remove_proc_entry("lec", atm_proc_root);
 
-	deregister_atm_ioctl(&lane_ioctl_ops);
+	deregister_atm_backend(&lec_ops);
 
         for (i = 0; i < MAX_LEC_ITF; i++) {
                 if (dev_lec[i] != NULL) {
diff -Nru a/net/atm/mpc.c b/net/atm/mpc.c
--- a/net/atm/mpc.c	Fri Sep 26 09:43:45 2003
+++ b/net/atm/mpc.c	Fri Sep 26 09:43:45 2003
@@ -1388,14 +1388,14 @@
 }
 
 
-static struct atm_ioctl atm_ioctl_ops = {
+static struct atm_backend mpoa_ops = {
 	.owner	= THIS_MODULE,
 	.ioctl	= atm_mpoa_ioctl,
 };
 
 static __init int atm_mpoa_init(void)
 {
-	register_atm_ioctl(&atm_ioctl_ops);
+	register_atm_backend(&mpoa_ops);
 
 #ifdef CONFIG_PROC_FS
 	if (mpc_proc_init() != 0)
@@ -1421,7 +1421,7 @@
 
 	del_timer(&mpc_timer);
 	unregister_netdevice_notifier(&mpoa_notifier);
-	deregister_atm_ioctl(&atm_ioctl_ops);
+	deregister_atm_backend(&mpoa_ops);
 
 	mpc = mpcs;
 	mpcs = NULL;
diff -Nru a/net/atm/pppoatm.c b/net/atm/pppoatm.c
--- a/net/atm/pppoatm.c	Fri Sep 26 09:43:45 2003
+++ b/net/atm/pppoatm.c	Fri Sep 26 09:43:45 2003
@@ -343,20 +343,20 @@
 	return -ENOIOCTLCMD;
 }
 
-struct atm_ioctl pppoatm_ioctl_ops = {
+static struct atm_backend pppoatm_backend_ops = {
 	.owner	= THIS_MODULE,
 	.ioctl	= pppoatm_ioctl,
 };
 
 static int __init pppoatm_init(void)
 {
-	register_atm_ioctl(&pppoatm_ioctl_ops);
+	register_atm_backend(&pppoatm_backend_ops);
 	return 0;
 }
 
 static void __exit pppoatm_exit(void)
 {
-	deregister_atm_ioctl(&pppoatm_ioctl_ops);
+	deregister_atm_backend(&pppoatm_backend_ops);
 }
 
 module_init(pppoatm_init);
