From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [rfc] more atm cleanup
Date: Mon, 23 Jun 2003 23:50:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306240353.h5O3r1sG025541@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

here's a couple of changes, in short, protect/setup br2684 and pppoatm
ioctl's with a mutex, get rid of sleep in vcc and just use sock->sleep,
replace wake_up() with sk_state_change and sk_data_ready (sk_write_space
needs some thinking so we have one wake_up not converted).  vcc->callback()
also goes away in favor of sk_state_change().

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1363  -> 1.1364 
#	    net/atm/br2684.c	1.3     -> 1.4    
#	    net/atm/common.h	1.14    -> 1.15   
#	    net/atm/common.c	1.39    -> 1.40   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/21	chas@relax.cmf.nrl.navy.mil	1.1364
# common.h, common.c, br2684.c:
#   cleanup br2684_ioctl_hook
# --------------------------------------------
#
diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	Mon Jun 23 09:45:37 2003
+++ b/net/atm/br2684.c	Mon Jun 23 09:45:37 2003
@@ -16,9 +16,12 @@
 #include <linux/ip.h>
 #include <asm/uaccess.h>
 #include <net/arp.h>
+#include <linux/atm.h>
+#include <linux/atmdev.h>
 
 #include <linux/atmbr2684.h>
 
+#include "common.h"
 #include "ipcommon.h"
 
 /*
@@ -768,8 +771,6 @@
 
 extern struct proc_dir_entry *atm_proc_root;	/* from proc.c */
 
-extern int (*br2684_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
-
 /* the following avoids some spurious warnings from the compiler */
 #define UNUSED __attribute__((unused))
 
@@ -779,14 +780,14 @@
 	if ((p = create_proc_entry("br2684", 0, atm_proc_root)) == NULL)
 		return -ENOMEM;
 	p->proc_fops = &br2684_proc_operations;
-	br2684_ioctl_hook = br2684_ioctl;
+	br2684_ioctl_set(br2684_ioctl);
 	return 0;
 }
 
 static void __exit UNUSED br2684_exit(void)
 {
 	struct br2684_dev *brdev;
-	br2684_ioctl_hook = NULL;
+	br2684_ioctl_set(NULL);
 	remove_proc_entry("br2684", atm_proc_root);
 	while (!list_empty(&br2684_devs)) {
 		brdev = list_entry_brdev(br2684_devs.next);
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jun 23 09:45:37 2003
+++ b/net/atm/common.c	Mon Jun 23 09:45:37 2003
@@ -145,9 +145,18 @@
 #endif
 
 #if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
-int (*br2684_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
+static DECLARE_MUTEX(br2684_ioctl_mutex);
+
+static int (*br2684_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
+
+void br2684_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long))
+{
+	down(&br2684_ioctl_mutex);
+	br2684_ioctl_hook = hook;
+	up(&br2684_ioctl_mutex);
+}
 #ifdef CONFIG_ATM_BR2684_MODULE
-EXPORT_SYMBOL(br2684_ioctl_hook);
+EXPORT_SYMBOL(br2684_ioctl_set);
 #endif
 #endif
 
@@ -886,11 +895,12 @@
 		goto done;
 #endif
 #if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
-	if (br2684_ioctl_hook) {
+	down(&br2684_ioctl_mutex);
+	if (br2684_ioctl_hook)
 		error = br2684_ioctl_hook(vcc, cmd, arg);
-		if (error != -ENOIOCTLCMD)
-			goto done;
-	}
+	up(&br2684_ioctl_mutex);
+	if (error != -ENOIOCTLCMD)
+		goto done;
 #endif
 
 	error = atm_dev_ioctl(cmd, arg);
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Mon Jun 23 09:45:37 2003
+++ b/net/atm/common.h	Mon Jun 23 09:45:37 2003
@@ -27,6 +27,7 @@
 void atm_shutdown_dev(struct atm_dev *dev);
 
 void pppoatm_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long));
+void br2684_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long));
 
 int atmpvc_init(void);
 void atmpvc_exit(void);

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1362  -> 1.1363 
#	   net/atm/pppoatm.c	1.7     -> 1.8    
#	    net/atm/common.h	1.13    -> 1.14   
#	    net/atm/common.c	1.38    -> 1.39   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/21	chas@relax.cmf.nrl.navy.mil	1.1363
# pppoatm.c, common.h, common.c:
#   cleanup pppoatm_ioctl_hook
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jun 23 09:45:58 2003
+++ b/net/atm/common.c	Mon Jun 23 09:45:58 2003
@@ -129,8 +129,19 @@
 #endif
 
 #if defined(CONFIG_PPPOATM) || defined(CONFIG_PPPOATM_MODULE)
-int (*pppoatm_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
-EXPORT_SYMBOL(pppoatm_ioctl_hook);
+static DECLARE_MUTEX(pppoatm_ioctl_mutex);
+
+static int (*pppoatm_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
+
+void pppoatm_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long))
+{
+	down(&pppoatm_ioctl_mutex);
+	pppoatm_ioctl_hook = hook;
+	up(&pppoatm_ioctl_mutex);
+}
+#ifdef CONFIG_PPPOATM_MODULE
+EXPORT_SYMBOL(pppoatm_ioctl_set);
+#endif
 #endif
 
 #if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
@@ -865,12 +876,14 @@
 		default:
 			break;
 	}
+	error = -ENOIOCTLCMD;
 #if defined(CONFIG_PPPOATM) || defined(CONFIG_PPPOATM_MODULE)
-	if (pppoatm_ioctl_hook) {
+	down(&pppoatm_ioctl_mutex);
+	if (pppoatm_ioctl_hook)
 		error = pppoatm_ioctl_hook(vcc, cmd, arg);
-		if (error != -ENOIOCTLCMD)
-			goto done;
-	}
+	up(&pppoatm_ioctl_mutex);
+	if (error != -ENOIOCTLCMD)
+		goto done;
 #endif
 #if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
 	if (br2684_ioctl_hook) {
diff -Nru a/net/atm/common.h b/net/atm/common.h
--- a/net/atm/common.h	Mon Jun 23 09:45:58 2003
+++ b/net/atm/common.h	Mon Jun 23 09:45:58 2003
@@ -26,6 +26,8 @@
 
 void atm_shutdown_dev(struct atm_dev *dev);
 
+void pppoatm_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long));
+
 int atmpvc_init(void);
 void atmpvc_exit(void);
 int atmsvc_init(void);
diff -Nru a/net/atm/pppoatm.c b/net/atm/pppoatm.c
--- a/net/atm/pppoatm.c	Mon Jun 23 09:45:58 2003
+++ b/net/atm/pppoatm.c	Mon Jun 23 09:45:58 2003
@@ -44,6 +44,8 @@
 #include <linux/ppp_channel.h>
 #include <linux/atmppp.h>
 
+#include "common.h"
+
 #if 0
 #define DPRINTK(format, args...) \
 	printk(KERN_DEBUG "pppoatm: " format, ##args)
@@ -344,17 +346,15 @@
 /* the following avoids some spurious warnings from the compiler */
 #define UNUSED __attribute__((unused))
 
-extern int (*pppoatm_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
-
 static int __init UNUSED pppoatm_init(void)
 {
-	pppoatm_ioctl_hook = pppoatm_ioctl;
+	pppoatm_ioctl_set(pppoatm_ioctl);
 	return 0;
 }
 
 static void __exit UNUSED pppoatm_exit(void)
 {
-	pppoatm_ioctl_hook = NULL;
+	pppoatm_ioctl_set(NULL);
 }
 
 module_init(pppoatm_init);


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1365  -> 1.1366 
#	       net/atm/lec.c	1.31    -> 1.32   
#	 net/atm/signaling.c	1.18    -> 1.19   
#	       net/atm/mpc.c	1.22    -> 1.23   
#	       net/atm/raw.c	1.5     -> 1.6    
#	      net/atm/clip.c	1.19    -> 1.20   
#	    net/atm/common.c	1.40    -> 1.41   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/23	chas@relax.cmf.nrl.navy.mil	1.1366
# use sk_data_ready and sk_change_state instead of wake_up
# --------------------------------------------
#
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Mon Jun 23 10:57:48 2003
+++ b/net/atm/clip.c	Mon Jun 23 10:57:48 2003
@@ -67,7 +67,7 @@
 	ctrl->ip = ip;
 	atm_force_charge(atmarpd,skb->truesize);
 	skb_queue_tail(&atmarpd->sk->sk_receive_queue, skb);
-	wake_up(atmarpd->sk->sk_sleep);
+	atmarpd->sk->sk_data_ready(atmarpd->sk, skb->len);
 	return 0;
 }
 
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jun 23 10:57:48 2003
+++ b/net/atm/common.c	Mon Jun 23 10:57:48 2003
@@ -328,7 +328,7 @@
 	set_bit(ATM_VF_CLOSE, &vcc->flags);
 	vcc->reply = reply;
 	vcc->sk->sk_err = -reply;
-	wake_up(vcc->sk->sk_sleep);
+	vcc->sk->sk_state_change(vcc->sk);
 }
 
 
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Mon Jun 23 10:57:48 2003
+++ b/net/atm/lec.c	Mon Jun 23 10:57:48 2003
@@ -134,7 +134,7 @@
                 priv = (struct lec_priv *)dev->priv;
                 atm_force_charge(priv->lecd, skb2->truesize);
                 skb_queue_tail(&priv->lecd->sk->sk_receive_queue, skb2);
-                wake_up(priv->lecd->sk->sk_sleep);
+                priv->lecd->sk->sk_data_ready(priv->lecd->sk, skb2->len);
         }
 
         return;
@@ -513,7 +513,7 @@
                         memcpy(skb2->data, mesg, sizeof(struct atmlec_msg));
                         atm_force_charge(priv->lecd, skb2->truesize);
                         skb_queue_tail(&priv->lecd->sk->sk_receive_queue, skb2);
-                        wake_up(priv->lecd->sk->sk_sleep);
+                        priv->lecd->sk->sk_data_ready(priv->lecd->sk, skb2->len);
                 }
                 if (f != NULL) br_fdb_put_hook(f);
 #endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
@@ -598,13 +598,13 @@
 
         atm_force_charge(priv->lecd, skb->truesize);
 	skb_queue_tail(&priv->lecd->sk->sk_receive_queue, skb);
-        wake_up(priv->lecd->sk->sk_sleep);
+        priv->lecd->sk->sk_data_ready(priv->lecd->sk, skb->len);
 
         if (data != NULL) {
                 DPRINTK("lec: about to send %d bytes of data\n", data->len);
                 atm_force_charge(priv->lecd, data->truesize);
                 skb_queue_tail(&priv->lecd->sk->sk_receive_queue, data);
-                wake_up(priv->lecd->sk->sk_sleep);
+                priv->lecd->sk->sk_data_ready(priv->lecd->sk, skb->len);
         }
 
         return 0;
@@ -686,7 +686,7 @@
         if (memcmp(skb->data, lec_ctrl_magic, 4) ==0) { /* Control frame, to daemon*/
                 DPRINTK("%s: To daemon\n",dev->name);
                 skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-                wake_up(vcc->sk->sk_sleep);
+                vcc->sk->sk_data_ready(vcc->sk, skb->len);
         } else { /* Data frame, queue to protocol handlers */
                 unsigned char *dst;
 
diff -Nru a/net/atm/mpc.c b/net/atm/mpc.c
--- a/net/atm/mpc.c	Mon Jun 23 10:57:48 2003
+++ b/net/atm/mpc.c	Mon Jun 23 10:57:48 2003
@@ -669,7 +669,7 @@
 		dprintk("mpoa: (%s) mpc_push: control packet arrived\n", dev->name);
 		/* Pass control packets to daemon */
 		skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-		wake_up(vcc->sk->sk_sleep);
+		vcc->sk->sk_data_ready(vcc->sk, skb->len);
 		return;
 	}
 
@@ -947,7 +947,7 @@
 	memcpy(skb->data, mesg, sizeof(struct k_message));
 	atm_force_charge(mpc->mpoad_vcc, skb->truesize);
 	skb_queue_tail(&mpc->mpoad_vcc->sk->sk_receive_queue, skb);
-	wake_up(mpc->mpoad_vcc->sk->sk_sleep);
+	mpc->mpoad_vcc->sk->sk_data_ready(mpc->mpoad_vcc->sk, skb->len);
 
 	return 0;
 }
@@ -1226,7 +1226,7 @@
 
 	atm_force_charge(vcc, skb->truesize);
 	skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-	wake_up(vcc->sk->sk_sleep);
+	vcc->sk->sk_data_ready(vcc->sk, skb->len);
 	dprintk("mpoa: purge_egress_shortcut: exiting:\n");
 
 	return;
diff -Nru a/net/atm/raw.c b/net/atm/raw.c
--- a/net/atm/raw.c	Mon Jun 23 10:57:48 2003
+++ b/net/atm/raw.c	Mon Jun 23 10:57:48 2003
@@ -29,7 +29,7 @@
 {
 	if (skb) {
 		skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-		wake_up(vcc->sk->sk_sleep);
+		vcc->sk->sk_data_ready(vcc->sk, skb->len);
 	}
 }
 
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	Mon Jun 23 10:57:48 2003
+++ b/net/atm/signaling.c	Mon Jun 23 10:57:48 2003
@@ -63,7 +63,7 @@
 #endif
 	atm_force_charge(sigd,skb->truesize);
 	skb_queue_tail(&sigd->sk->sk_receive_queue,skb);
-	wake_up(sigd->sk->sk_sleep);
+	sigd->sk->sk_data_ready(sigd->sk, skb->len);
 }
 
 
@@ -206,7 +206,7 @@
 		set_bit(ATM_VF_RELEASED,&vcc->flags);
 		vcc->reply = -EUNATCH;
 		vcc->sk->sk_err = EUNATCH;
-		wake_up(vcc->sk->sk_sleep);
+		vcc->sk->sk_state_change(vcc->sk);
 	}
 }
 

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1360  -> 1.1361 
#	       net/atm/svc.c	1.19    -> 1.20   
#	 net/atm/signaling.c	1.15    -> 1.16   
#	include/linux/atmdev.h	1.19    -> 1.20   
#	    net/atm/common.c	1.36    -> 1.37   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/20	chas@relax.cmf.nrl.navy.mil	1.1361
# use sk_state_change() and eliminate vcc->callback()
# --------------------------------------------
#
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Mon Jun 23 09:54:19 2003
+++ b/include/linux/atmdev.h	Mon Jun 23 09:54:19 2003
@@ -297,7 +297,6 @@
 	short		itf;		/* interface number */
 	struct sockaddr_atmsvc local;
 	struct sockaddr_atmsvc remote;
-	void (*callback)(struct atm_vcc *vcc);
 	int		reply;		/* also used by ATMTCP */
 	/* Multipoint part ------------------------------------------------- */
 	struct atm_vcc	*session;	/* session VCC descriptor */
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jun 23 09:54:19 2003
+++ b/net/atm/common.c	Mon Jun 23 09:54:19 2003
@@ -215,6 +215,14 @@
 
 	kfree(sk->sk_protinfo);
 }
+
+static void vcc_def_wakeup(struct sock *sk)
+{
+	read_lock(&sk->sk_callback_lock);
+	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+		wake_up(sk->sk_sleep);
+	read_unlock(&sk->sk_callback_lock);
+}
  
 int vcc_create(struct socket *sock, int protocol, int family)
 {
@@ -228,6 +236,7 @@
 	if (!sk)
 		return -ENOMEM;
 	sock_init_data(NULL, sk);
+	sk->sk_state_change = vcc_def_wakeup;
 
 	vcc = atm_sk(sk) = kmalloc(sizeof(*vcc), GFP_KERNEL);
 	if (!vcc) {
@@ -238,7 +247,6 @@
 	memset(vcc, 0, sizeof(*vcc));
 	vcc->sk = sk;
 	vcc->dev = NULL;
-	vcc->callback = NULL;
 	memset(&vcc->local,0,sizeof(struct sockaddr_atmsvc));
 	memset(&vcc->remote,0,sizeof(struct sockaddr_atmsvc));
 	vcc->qos.txtp.max_sdu = 1 << 16; /* for meta VCs */
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	Mon Jun 23 09:54:19 2003
+++ b/net/atm/signaling.c	Mon Jun 23 09:54:19 2003
@@ -137,11 +137,8 @@
 			}
 			vcc->sk->sk_ack_backlog++;
 			skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-			if (vcc->callback) {
-				DPRINTK("waking vcc->sleep 0x%p\n",
-				    &vcc->sleep);
-				vcc->callback(vcc);
-			}
+			DPRINTK("waking vcc->sleep 0x%p\n", &vcc->sleep);
+			vcc->sk->sk_state_change(vcc->sk);
 as_indicate_complete:
 			release_sock(vcc->sk);
 			return 0;
@@ -159,7 +156,7 @@
 			    (int) msg->type);
 			return -EINVAL;
 	}
-	if (vcc->callback) vcc->callback(vcc);
+	vcc->sk->sk_state_change(vcc->sk);
 	dev_kfree_skb(skb);
 	return 0;
 }
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Mon Jun 23 09:54:19 2003
+++ b/net/atm/svc.c	Mon Jun 23 09:54:19 2003
@@ -43,14 +43,6 @@
  */
 
 
-void svc_callback(struct atm_vcc *vcc)
-{
-	wake_up(&vcc->sleep);
-}
-
-
-
-
 static int svc_shutdown(struct socket *sock,int how)
 {
 	return 0;
@@ -547,7 +539,6 @@
 	sock->ops = &svc_proto_ops;
 	error = vcc_create(sock, protocol, AF_ATMSVC);
 	if (error) return error;
-	ATM_SD(sock)->callback = svc_callback;
 	ATM_SD(sock)->local.sas_family = AF_ATMSVC;
 	ATM_SD(sock)->remote.sas_family = AF_ATMSVC;
 	return 0;


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1361  -> 1.1362 
#	       net/atm/lec.c	1.30    -> 1.31   
#	       net/atm/svc.c	1.20    -> 1.21   
#	drivers/atm/atmtcp.c	1.11    -> 1.12   
#	 net/atm/signaling.c	1.16    -> 1.17   
#	       net/atm/mpc.c	1.21    -> 1.22   
#	include/linux/atmdev.h	1.20    -> 1.21   
#	       net/atm/raw.c	1.4     -> 1.5    
#	      net/atm/clip.c	1.18    -> 1.19   
#	    net/atm/common.c	1.37    -> 1.38   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/23	chas@relax.cmf.nrl.navy.mil	1.1362
# eliminate vcc->sleep()
# --------------------------------------------
#
diff -Nru a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
--- a/drivers/atm/atmtcp.c	Mon Jun 23 10:58:07 2003
+++ b/drivers/atm/atmtcp.c	Mon Jun 23 10:58:07 2003
@@ -66,7 +66,7 @@
 	*(struct atm_vcc **) &new_msg->vcc = vcc;
 	old_test = test_bit(flag,&vcc->flags);
 	out_vcc->push(out_vcc,skb);
-	add_wait_queue(&vcc->sleep,&wait);
+	add_wait_queue(vcc->sk->sk_sleep, &wait);
 	while (test_bit(flag,&vcc->flags) == old_test) {
 		mb();
 		out_vcc = PRIV(vcc->dev) ? PRIV(vcc->dev)->vcc : NULL;
@@ -78,7 +78,7 @@
 		schedule();
 	}
 	current->state = TASK_RUNNING;
-	remove_wait_queue(&vcc->sleep,&wait);
+	remove_wait_queue(vcc->sk->sk_sleep, &wait);
 	return error;
 }
 
@@ -103,7 +103,7 @@
 		    msg->type);
 		return -EINVAL;
 	}
-	wake_up(&vcc->sleep);
+	wake_up(vcc->sk->sk_sleep);
 	return 0;
 }
 
@@ -257,7 +257,7 @@
 		walk = atm_sk(s);
 		if (walk->dev != atmtcp_dev)
 			continue;
-		wake_up(&walk->sleep);
+		wake_up(walk->sk->sk_sleep);
 	}
 	read_unlock(&vcc_sklist_lock);
 }
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Mon Jun 23 10:58:07 2003
+++ b/include/linux/atmdev.h	Mon Jun 23 10:58:07 2003
@@ -291,7 +291,6 @@
 	void		*dev_data;	/* per-device data */
 	void		*proto_data;	/* per-protocol data */
 	struct k_atm_aal_stats *stats;	/* pointer to AAL stats group */
-	wait_queue_head_t sleep;	/* if socket is busy */
 	struct sock	*sk;		/* socket backpointer */
 	/* SVC part --- may move later ------------------------------------- */
 	short		itf;		/* interface number */
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Mon Jun 23 10:58:07 2003
+++ b/net/atm/clip.c	Mon Jun 23 10:58:07 2003
@@ -67,7 +67,7 @@
 	ctrl->ip = ip;
 	atm_force_charge(atmarpd,skb->truesize);
 	skb_queue_tail(&atmarpd->sk->sk_receive_queue, skb);
-	wake_up(&atmarpd->sleep);
+	wake_up(atmarpd->sk->sk_sleep);
 	return 0;
 }
 
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Mon Jun 23 10:58:07 2003
+++ b/net/atm/common.c	Mon Jun 23 10:58:07 2003
@@ -235,7 +235,7 @@
 	sk = sk_alloc(family, GFP_KERNEL, 1, NULL);
 	if (!sk)
 		return -ENOMEM;
-	sock_init_data(NULL, sk);
+	sock_init_data(sock, sk);
 	sk->sk_state_change = vcc_def_wakeup;
 
 	vcc = atm_sk(sk) = kmalloc(sizeof(*vcc), GFP_KERNEL);
@@ -257,8 +257,6 @@
 	vcc->push_oam = NULL;
 	vcc->vpi = vcc->vci = 0; /* no VCI/VPI yet */
 	vcc->atm_options = vcc->aal_options = 0;
-	init_waitqueue_head(&vcc->sleep);
-	sk->sk_sleep = &vcc->sleep;
 	sk->sk_destruct = vcc_sock_destruct;
 	sock->sk = sk;
 	return 0;
@@ -310,7 +308,7 @@
 	set_bit(ATM_VF_CLOSE, &vcc->flags);
 	vcc->reply = reply;
 	vcc->sk->sk_err = -reply;
-	wake_up(&vcc->sleep);
+	wake_up(vcc->sk->sk_sleep);
 }
 
 
@@ -557,7 +555,7 @@
 	}
 	/* verify_area is done by net/socket.c */
 	eff = (size+3) & ~3; /* align to word boundary */
-	prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 	error = 0;
 	while (!(skb = alloc_tx(vcc,eff))) {
 		if (m->msg_flags & MSG_DONTWAIT) {
@@ -578,9 +576,9 @@
 			error = -EPIPE;
 			break;
 		}
-		prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 	}
-	finish_wait(&vcc->sleep, &wait);
+	finish_wait(sk->sk_sleep, &wait);
 	if (error)
 		goto out;
 	skb->dev = NULL; /* for paths shared with net_device interfaces */
@@ -605,7 +603,7 @@
 	unsigned int mask;
 
 	vcc = ATM_SD(sock);
-	poll_wait(file,&vcc->sleep,wait);
+	poll_wait(file, vcc->sk->sk_sleep, wait);
 	mask = 0;
 	if (skb_peek(&vcc->sk->sk_receive_queue))
 		mask |= POLLIN | POLLRDNORM;
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Mon Jun 23 10:58:07 2003
+++ b/net/atm/lec.c	Mon Jun 23 10:58:07 2003
@@ -134,7 +134,7 @@
                 priv = (struct lec_priv *)dev->priv;
                 atm_force_charge(priv->lecd, skb2->truesize);
                 skb_queue_tail(&priv->lecd->sk->sk_receive_queue, skb2);
-                wake_up(&priv->lecd->sleep);
+                wake_up(priv->lecd->sk->sk_sleep);
         }
 
         return;
@@ -513,7 +513,7 @@
                         memcpy(skb2->data, mesg, sizeof(struct atmlec_msg));
                         atm_force_charge(priv->lecd, skb2->truesize);
                         skb_queue_tail(&priv->lecd->sk->sk_receive_queue, skb2);
-                        wake_up(&priv->lecd->sleep);
+                        wake_up(priv->lecd->sk->sk_sleep);
                 }
                 if (f != NULL) br_fdb_put_hook(f);
 #endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
@@ -598,13 +598,13 @@
 
         atm_force_charge(priv->lecd, skb->truesize);
 	skb_queue_tail(&priv->lecd->sk->sk_receive_queue, skb);
-        wake_up(&priv->lecd->sleep);
+        wake_up(priv->lecd->sk->sk_sleep);
 
         if (data != NULL) {
                 DPRINTK("lec: about to send %d bytes of data\n", data->len);
                 atm_force_charge(priv->lecd, data->truesize);
                 skb_queue_tail(&priv->lecd->sk->sk_receive_queue, data);
-                wake_up(&priv->lecd->sleep);
+                wake_up(priv->lecd->sk->sk_sleep);
         }
 
         return 0;
@@ -686,7 +686,7 @@
         if (memcmp(skb->data, lec_ctrl_magic, 4) ==0) { /* Control frame, to daemon*/
                 DPRINTK("%s: To daemon\n",dev->name);
                 skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-                wake_up(&vcc->sleep);
+                wake_up(vcc->sk->sk_sleep);
         } else { /* Data frame, queue to protocol handlers */
                 unsigned char *dst;
 
diff -Nru a/net/atm/mpc.c b/net/atm/mpc.c
--- a/net/atm/mpc.c	Mon Jun 23 10:58:07 2003
+++ b/net/atm/mpc.c	Mon Jun 23 10:58:07 2003
@@ -669,7 +669,7 @@
 		dprintk("mpoa: (%s) mpc_push: control packet arrived\n", dev->name);
 		/* Pass control packets to daemon */
 		skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-		wake_up(&vcc->sleep);
+		wake_up(vcc->sk->sk_sleep);
 		return;
 	}
 
@@ -947,7 +947,7 @@
 	memcpy(skb->data, mesg, sizeof(struct k_message));
 	atm_force_charge(mpc->mpoad_vcc, skb->truesize);
 	skb_queue_tail(&mpc->mpoad_vcc->sk->sk_receive_queue, skb);
-	wake_up(&mpc->mpoad_vcc->sleep);
+	wake_up(mpc->mpoad_vcc->sk->sk_sleep);
 
 	return 0;
 }
@@ -1226,7 +1226,7 @@
 
 	atm_force_charge(vcc, skb->truesize);
 	skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-	wake_up(&vcc->sleep);
+	wake_up(vcc->sk->sk_sleep);
 	dprintk("mpoa: purge_egress_shortcut: exiting:\n");
 
 	return;
diff -Nru a/net/atm/raw.c b/net/atm/raw.c
--- a/net/atm/raw.c	Mon Jun 23 10:58:07 2003
+++ b/net/atm/raw.c	Mon Jun 23 10:58:07 2003
@@ -29,7 +29,7 @@
 {
 	if (skb) {
 		skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-		wake_up(&vcc->sleep);
+		wake_up(vcc->sk->sk_sleep);
 	}
 }
 
@@ -40,7 +40,7 @@
 		skb->truesize);
 	atomic_sub(skb->truesize, &vcc->sk->sk_wmem_alloc);
 	dev_kfree_skb_any(skb);
-	wake_up(&vcc->sleep);
+	wake_up(vcc->sk->sk_sleep);
 }
 
 
diff -Nru a/net/atm/signaling.c b/net/atm/signaling.c
--- a/net/atm/signaling.c	Mon Jun 23 10:58:07 2003
+++ b/net/atm/signaling.c	Mon Jun 23 10:58:07 2003
@@ -61,7 +61,7 @@
 #endif
 	atm_force_charge(sigd,skb->truesize);
 	skb_queue_tail(&sigd->sk->sk_receive_queue,skb);
-	wake_up(&sigd->sleep);
+	wake_up(sigd->sk->sk_sleep);
 }
 
 
@@ -137,7 +137,7 @@
 			}
 			vcc->sk->sk_ack_backlog++;
 			skb_queue_tail(&vcc->sk->sk_receive_queue, skb);
-			DPRINTK("waking vcc->sleep 0x%p\n", &vcc->sleep);
+			DPRINTK("waking vcc->sk->sk_sleep 0x%p\n", vcc->sk->sk_sleep);
 			vcc->sk->sk_state_change(vcc->sk);
 as_indicate_complete:
 			release_sock(vcc->sk);
@@ -204,7 +204,7 @@
 		set_bit(ATM_VF_RELEASED,&vcc->flags);
 		vcc->reply = -EUNATCH;
 		vcc->sk->sk_err = EUNATCH;
-		wake_up(&vcc->sleep);
+		wake_up(vcc->sk->sk_sleep);
 	}
 }
 
diff -Nru a/net/atm/svc.c b/net/atm/svc.c
--- a/net/atm/svc.c	Mon Jun 23 10:58:07 2003
+++ b/net/atm/svc.c	Mon Jun 23 10:58:07 2003
@@ -56,13 +56,13 @@
 
 	DPRINTK("svc_disconnect %p\n",vcc);
 	if (test_bit(ATM_VF_REGIS,&vcc->flags)) {
-		prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		sigd_enq(vcc,as_close,NULL,NULL,NULL);
 		while (!test_bit(ATM_VF_RELEASED,&vcc->flags) && sigd) {
 			schedule();
-			prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+			prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		}
-		finish_wait(&vcc->sleep, &wait);
+		finish_wait(vcc->sk->sk_sleep, &wait);
 	}
 	/* beware - socket is still in use by atmsigd until the last
 	   as_indicate has been answered */
@@ -138,13 +138,13 @@
 	}
 	vcc->local = *addr;
 	vcc->reply = WAITING;
-	prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc,as_bind,NULL,NULL,&vcc->local);
 	while (vcc->reply == WAITING && sigd) {
 		schedule();
-		prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
-	finish_wait(&vcc->sleep, &wait);
+	finish_wait(sk->sk_sleep, &wait);
 	clear_bit(ATM_VF_REGIS,&vcc->flags); /* doesn't count */
 	if (!sigd) {
 		error = -EUNATCH;
@@ -219,10 +219,10 @@
 		}
 		vcc->remote = *addr;
 		vcc->reply = WAITING;
-		prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 		sigd_enq(vcc,as_connect,NULL,NULL,&vcc->remote);
 		if (flags & O_NONBLOCK) {
-			finish_wait(&vcc->sleep, &wait);
+			finish_wait(sk->sk_sleep, &wait);
 			sock->state = SS_CONNECTING;
 			error = -EINPROGRESS;
 			goto out;
@@ -231,7 +231,7 @@
 		while (vcc->reply == WAITING && sigd) {
 			schedule();
 			if (!signal_pending(current)) {
-				prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+				prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 				continue;
 			}
 			DPRINTK("*ABORT*\n");
@@ -249,13 +249,13 @@
 			 */
 			sigd_enq(vcc,as_close,NULL,NULL,NULL);
 			while (vcc->reply == WAITING && sigd) {
-				prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+				prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 				schedule();
 			}
 			if (!vcc->reply)
 				while (!test_bit(ATM_VF_RELEASED,&vcc->flags)
 				    && sigd) {
-					prepare_to_wait(&vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+					prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 					schedule();
 				}
 			clear_bit(ATM_VF_REGIS,&vcc->flags);
@@ -265,7 +265,7 @@
 			error = -EINTR;
 			break;
 		}
-		finish_wait(&vcc->sleep, &wait);
+		finish_wait(sk->sk_sleep, &wait);
 		if (error)
 			goto out;
 		if (!sigd) {
@@ -312,13 +312,13 @@
 		goto out;
 	}
 	vcc->reply = WAITING;
-	prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+	prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq(vcc,as_listen,NULL,NULL,&vcc->local);
 	while (vcc->reply == WAITING && sigd) {
 		schedule();
-		prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
-	finish_wait(&vcc->sleep, &wait);
+	finish_wait(sk->sk_sleep, &wait);
 	if (!sigd) {
 		error = -EUNATCH;
 		goto out;
@@ -354,7 +354,7 @@
 	while (1) {
 		DEFINE_WAIT(wait);
 
-		prepare_to_wait(&old_vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+		prepare_to_wait(old_vcc->sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 		while (!(skb = skb_dequeue(&old_vcc->sk->sk_receive_queue)) &&
 		       sigd) {
 			if (test_bit(ATM_VF_RELEASED,&old_vcc->flags)) break;
@@ -373,9 +373,9 @@
 				error = -ERESTARTSYS;
 				break;
 			}
-			prepare_to_wait(&old_vcc->sleep, &wait, TASK_INTERRUPTIBLE);
+			prepare_to_wait(old_vcc->sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 		}
-		finish_wait(&old_vcc->sleep, &wait);
+		finish_wait(old_vcc->sk->sk_sleep, &wait);
 		if (error)
 			goto out;
 		if (!skb) {
@@ -400,15 +400,15 @@
 		}
 		/* wait should be short, so we ignore the non-blocking flag */
 		new_vcc->reply = WAITING;
-		prepare_to_wait(&new_vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(new_vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		sigd_enq(new_vcc,as_accept,old_vcc,NULL,NULL);
 		while (new_vcc->reply == WAITING && sigd) {
 			release_sock(sk);
 			schedule();
 			lock_sock(sk);
-			prepare_to_wait(&new_vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+			prepare_to_wait(new_vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		}
-		finish_wait(&new_vcc->sleep, &wait);
+		finish_wait(new_vcc->sk->sk_sleep, &wait);
 		if (!sigd) {
 			error = -EUNATCH;
 			goto out;
@@ -444,14 +444,14 @@
 	DEFINE_WAIT(wait);
 
 	vcc->reply = WAITING;
-	prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+	prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	sigd_enq2(vcc,as_modify,NULL,NULL,&vcc->local,qos,0);
 	while (vcc->reply == WAITING && !test_bit(ATM_VF_RELEASED,&vcc->flags)
 	    && sigd) {
 		schedule();
-		prepare_to_wait(&vcc->sleep, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(vcc->sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 	}
-	finish_wait(&vcc->sleep, &wait);
+	finish_wait(vcc->sk->sk_sleep, &wait);
 	if (!sigd) return -EUNATCH;
 	return vcc->reply;
 }
