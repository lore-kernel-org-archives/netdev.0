From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [ioctl][3/8] use new code for pppoatm and br2684 (from levon@movementarian.org)
Date: Thu, 25 Sep 2003 12:10:04 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309251610.h8PGA3kT006938@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1449  -> 1.1450 
#	    net/atm/br2684.c	1.11    -> 1.12   
#	     net/atm/ioctl.c	1.2     -> 1.3    
#	   net/atm/pppoatm.c	1.14    -> 1.15   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/23	chas@relax.cmf.nrl.navy.mil	1.1450
# [ATM]: [ioctl][3/8] use new code for pppoatm and br2684 (from levon@movementarian.org)
# --------------------------------------------
#
diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
--- a/net/atm/br2684.c	Thu Sep 25 09:24:19 2003
+++ b/net/atm/br2684.c	Thu Sep 25 09:24:19 2003
@@ -634,9 +634,11 @@
  * This handles ioctls actually performed on our vcc - we must return
  * -ENOIOCTLCMD for any unrecognized ioctl
  */
-static int br2684_ioctl(struct atm_vcc *atmvcc, unsigned int cmd,
+static int br2684_ioctl(struct socket *sock, unsigned int cmd,
 	unsigned long arg)
 {
+	struct atm_vcc *atmvcc = ATM_SD(sock);
+
 	int err;
 	switch(cmd) {
 	case ATM_SETBACKEND:
@@ -667,6 +669,12 @@
 	return -ENOIOCTLCMD;
 }
 
+static struct atm_ioctl br2684_ioctl_ops = {
+	.owner	= THIS_MODULE,
+	.ioctl	= br2684_ioctl,
+};
+
+
 #ifdef CONFIG_PROC_FS
 static void *br2684_seq_start(struct seq_file *seq, loff_t *pos)
 {
@@ -774,7 +782,7 @@
 		return -ENOMEM;
 	p->proc_fops = &br2684_proc_ops;
 #endif
-	br2684_ioctl_set(br2684_ioctl);
+	register_atm_ioctl(&br2684_ioctl_ops);
 	return 0;
 }
 
@@ -783,7 +791,7 @@
 	struct net_device *net_dev;
 	struct br2684_dev *brdev;
 	struct br2684_vcc *brvcc;
-	br2684_ioctl_set(NULL);
+	deregister_atm_ioctl(&br2684_ioctl_ops);
 
 #ifdef CONFIG_PROC_FS
 	remove_proc_entry("br2684", atm_proc_root);
diff -Nru a/net/atm/ioctl.c b/net/atm/ioctl.c
--- a/net/atm/ioctl.c	Thu Sep 25 09:24:19 2003
+++ b/net/atm/ioctl.c	Thu Sep 25 09:24:19 2003
@@ -122,38 +122,6 @@
 #endif
 #endif
 
-#if defined(CONFIG_PPPOATM) || defined(CONFIG_PPPOATM_MODULE)
-static DECLARE_MUTEX(pppoatm_ioctl_mutex);
-
-static int (*pppoatm_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
-
-void pppoatm_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long))
-{
-	down(&pppoatm_ioctl_mutex);
-	pppoatm_ioctl_hook = hook;
-	up(&pppoatm_ioctl_mutex);
-}
-#ifdef CONFIG_PPPOATM_MODULE
-EXPORT_SYMBOL(pppoatm_ioctl_set);
-#endif
-#endif
-
-#if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
-static DECLARE_MUTEX(br2684_ioctl_mutex);
-
-static int (*br2684_ioctl_hook)(struct atm_vcc *, unsigned int, unsigned long);
-
-void br2684_ioctl_set(int (*hook)(struct atm_vcc *, unsigned int, unsigned long))
-{
-	down(&br2684_ioctl_mutex);
-	br2684_ioctl_hook = hook;
-	up(&br2684_ioctl_mutex);
-}
-#ifdef CONFIG_ATM_BR2684_MODULE
-EXPORT_SYMBOL(br2684_ioctl_set);
-#endif
-#endif
-
 static DECLARE_MUTEX(ioctl_mutex);
 static LIST_HEAD(ioctl_list);
 
@@ -433,23 +401,6 @@
 
 	if (error != -ENOIOCTLCMD)
 		goto done;
-
-#if defined(CONFIG_PPPOATM) || defined(CONFIG_PPPOATM_MODULE)
-	down(&pppoatm_ioctl_mutex);
-	if (pppoatm_ioctl_hook)
-		error = pppoatm_ioctl_hook(vcc, cmd, arg);
-	up(&pppoatm_ioctl_mutex);
-	if (error != -ENOIOCTLCMD)
-		goto done;
-#endif
-#if defined(CONFIG_ATM_BR2684) || defined(CONFIG_ATM_BR2684_MODULE)
-	down(&br2684_ioctl_mutex);
-	if (br2684_ioctl_hook)
-		error = br2684_ioctl_hook(vcc, cmd, arg);
-	up(&br2684_ioctl_mutex);
-	if (error != -ENOIOCTLCMD)
-		goto done;
-#endif
 
 	error = atm_dev_ioctl(cmd, arg);
 
diff -Nru a/net/atm/pppoatm.c b/net/atm/pppoatm.c
--- a/net/atm/pppoatm.c	Thu Sep 25 09:24:19 2003
+++ b/net/atm/pppoatm.c	Thu Sep 25 09:24:19 2003
@@ -315,9 +315,11 @@
  * This handles ioctls actually performed on our vcc - we must return
  * -ENOIOCTLCMD for any unrecognized ioctl
  */
-static int pppoatm_ioctl(struct atm_vcc *atmvcc, unsigned int cmd,
+static int pppoatm_ioctl(struct socket *sock, unsigned int cmd,
 	unsigned long arg)
 {
+	struct atm_vcc *atmvcc = ATM_SD(sock);
+
 	if (cmd != ATM_SETBACKEND && atmvcc->push != pppoatm_push)
 		return -ENOIOCTLCMD;
 	switch (cmd) {
@@ -341,15 +343,20 @@
 	return -ENOIOCTLCMD;
 }
 
+struct atm_ioctl pppoatm_ioctl_ops = {
+	.owner	= THIS_MODULE,
+	.ioctl	= pppoatm_ioctl,
+};
+
 static int __init pppoatm_init(void)
 {
-	pppoatm_ioctl_set(pppoatm_ioctl);
+	register_atm_ioctl(&pppoatm_ioctl_ops);
 	return 0;
 }
 
 static void __exit pppoatm_exit(void)
 {
-	pppoatm_ioctl_set(NULL);
+	deregister_atm_ioctl(&pppoatm_ioctl_ops);
 }
 
 module_init(pppoatm_init);
