From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/4) get rid of register_frad
Date: Mon, 8 Sep 2003 14:09:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030908140922.21f8faec.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The sdla and dlci drivers have a callback interface which only stores a name
in a table, but doesn't do anything useful. Looks like an interface which has
lost it's usefulness and can be safely removed.

Tested on 2.6.0-test5 by exercising the higher layer (dlci) without real hardware.

diff -Nru a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
--- a/drivers/net/wan/dlci.c	Mon Sep  8 14:01:46 2003
+++ b/drivers/net/wan/dlci.c	Mon Sep  8 14:01:46 2003
@@ -59,63 +59,9 @@
 
 static LIST_HEAD(dlci_devs);
 static spinlock_t dlci_dev_lock = SPIN_LOCK_UNLOCKED;
-static char *basename[16];
 
 static void dlci_setup(struct net_device *);
 
-/* allow FRAD's to register their name as a valid FRAD */
-int register_frad(const char *name)
-{
-	int i;
-
-	if (!name)
-		return(-EINVAL);
-
-	for (i=0;i<sizeof(basename) / sizeof(char *);i++)
-	{
-		if (!basename[i])
-			break;
-
-		/* take care of multiple registrations */
-		if (strcmp(basename[i], name) == 0)
-			return(0);
-	}
-
-	if (i == sizeof(basename) / sizeof(char *))
-		return(-EMLINK);
-
-	basename[i] = kmalloc(strlen(name) + 1, GFP_KERNEL);
-	if (!basename[i])
-		return(-ENOMEM);
-
-	strcpy(basename[i], name);
-
-	return(0);
-}
-
-EXPORT_SYMBOL(register_frad);
-
-int unregister_frad(const char *name)
-{
-	int i;
-
-	if (!name)
-		return(-EINVAL);
-
-	for (i=0;i<sizeof(basename) / sizeof(char *);i++)
-		if (basename[i] && (strcmp(basename[i], name) == 0))
-			break;
-
-	if (i == sizeof(basename) / sizeof(char *))
-		return(-EINVAL);
-
-	kfree(basename[i]);
-	basename[i] = NULL;
-
-	return(0);
-}
-EXPORT_SYMBOL(unregister_frad);
-
 /* 
  * these encapsulate the RFC 1490 requirements as well as 
  * deal with packet transmission and reception, working with
@@ -414,7 +360,7 @@
 	struct net_device	*master, *slave;
 	struct dlci_local	*dlp;
 	struct frad_local	*flp;
-	int			err, i;
+	int			err;
 
 
 	/* validate slave device */
@@ -427,18 +373,6 @@
 		return(-EINVAL);
 	}
 
-	/* check for registration */
-	for (i=0;i<sizeof(basename) / sizeof(char *); i++)
-		if ((basename[i]) && 
-			 (strncmp(dlci->devname, basename[i], strlen(basename[i])) == 0) && 
-			 (strlen(dlci->devname) > strlen(basename[i])))
-			break;
-
-	if (i == sizeof(basename) / sizeof(char *)) {
-		dev_put(slave);
-		return(-EINVAL);
-	}
-
 	/* create device name */
 	master = alloc_netdev( sizeof(struct dlci_local), "dlci%d",
 			      dlci_setup);
@@ -571,13 +505,9 @@
 
 int __init init_dlci(void)
 {
-	int i;
 	dlci_ioctl_set(dlci_ioctl);
 
 	printk("%s.\n", version);
-
-	for(i=0;i<sizeof(basename) / sizeof(char *);i++)
-		basename[i] = NULL;
 
 	return 0;
 }
diff -Nru a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
--- a/drivers/net/wan/sdla.c	Mon Sep  8 14:01:46 2003
+++ b/drivers/net/wan/sdla.c	Mon Sep  8 14:01:46 2003
@@ -60,8 +60,6 @@
 
 static const char* version = "SDLA driver v0.30, 12 Sep 1996, mike.mclagan@linux.org";
 
-static const char* devname = "sdla";
-
 static unsigned int valid_port[] __initdata = { 0x250, 0x270, 0x280, 0x300, 0x350, 0x360, 0x380, 0x390};
 
 static unsigned int valid_mem[]  __initdata = {
@@ -1664,12 +1662,6 @@
 	int err;
 
 	printk("%s.\n", version);
-	err = register_frad(devname);
-	if (err) {
-		printk(KERN_ERR "%s: frad registration failed %d\n",
-		       devname, err);
-		return err;
-	}
 
 	sdla = alloc_netdev(sizeof(struct frad_local), "sdla0", setup_sdla);
 	if (!sdla) 
@@ -1693,8 +1685,6 @@
 	flp = sdla->priv;
 	del_timer_sync(&flp->timer);
 	free_netdev(sdla);
-	
-	unregister_frad(devname);
 }
 
 MODULE_LICENSE("GPL");
diff -Nru a/include/linux/if_frad.h b/include/linux/if_frad.h
--- a/include/linux/if_frad.h	Mon Sep  8 14:01:46 2003
+++ b/include/linux/if_frad.h	Mon Sep  8 14:01:46 2003
@@ -191,9 +191,6 @@
    int               buffer;		/* current buffer for S508 firmware */
 };
 
-int register_frad(const char *name);
-int unregister_frad(const char *name);
-
 extern void dlci_ioctl_set(int (*hook)(unsigned int, void *));
 
 #endif /* __KERNEL__ */
