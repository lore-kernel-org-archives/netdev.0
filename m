From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/4) dlci locking and registration changes
Date: Mon, 8 Sep 2003 14:12:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030908141246.5782437a.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change the locking for the dlci device list and registration.
- use RTNL instead of a private lock (needed for net notifier in next patch).
- reorder the checks in the dlci_add to avoid complicated unwinds
- use dev->destructor to free
- hold RTNL around deassoc to protect callback from races


diff -Nru a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
--- a/drivers/net/wan/dlci.c	Mon Sep  8 14:02:46 2003
+++ b/drivers/net/wan/dlci.c	Mon Sep  8 14:02:46 2003
@@ -58,7 +58,6 @@
 static const char version[] = "DLCI driver v0.35, 4 Jan 1997, mike.mclagan@linux.org";
 
 static LIST_HEAD(dlci_devs);
-static spinlock_t dlci_dev_lock = SPIN_LOCK_UNLOCKED;
 
 static void dlci_setup(struct net_device *);
 
@@ -360,34 +359,38 @@
 	struct net_device	*master, *slave;
 	struct dlci_local	*dlp;
 	struct frad_local	*flp;
-	int			err;
+	int			err = -EINVAL;
 
 
 	/* validate slave device */
 	slave = dev_get_by_name(dlci->devname);
 	if (!slave)
-		return(-ENODEV);
+		return -ENODEV;
 
-	if (slave->type != ARPHRD_FRAD) {
-		dev_put(slave);
-		return(-EINVAL);
-	}
+	if (slave->type != ARPHRD_FRAD || slave->priv == NULL)
+		goto err1;
 
 	/* create device name */
 	master = alloc_netdev( sizeof(struct dlci_local), "dlci%d",
 			      dlci_setup);
 	if (!master) {
-		dev_put(slave);
-		return(-ENOMEM);
+		err = -ENOMEM;
+		goto err1;
 	}
 
-	err = register_netdev(master);
-	if (err < 0) {
-		dev_put(slave);
-		kfree(master);
-		return(err);
+	/* make sure same slave not already registered */
+	rtnl_lock();
+	list_for_each_entry(dlp, &dlci_devs, list) {
+		if (dlp->slave == slave) {
+			err = -EBUSY;
+			goto err2;
+		}
 	}
 
+	err = dev_alloc_name(master, master->name);
+	if (err < 0)
+		goto err2;
+
 	*(short *)(master->dev_addr) = dlci->dlci;
 
 	dlp = (struct dlci_local *) master->priv;
@@ -395,22 +398,27 @@
 	dlp->master = master;
 
 	flp = slave->priv;
-	err = flp ? (*flp->assoc)(slave, master) : -EINVAL;
+	err = (*flp->assoc)(slave, master);
 	if (err < 0)
-	{
-		unregister_netdev(master);
-		dev_put(slave);
-		free_netdev(master);
-		return(err);
-	}
+		goto err2;
+
+	err = register_netdevice(master);
+	if (err < 0) 
+		goto err2;
 
 	strcpy(dlci->devname, master->name);
 
-	spin_lock_bh(&dlci_dev_lock);
 	list_add(&dlp->list, &dlci_devs);
-	spin_unlock_bh(&dlci_dev_lock);
+	rtnl_unlock();
 
 	return(0);
+
+ err2:
+	rtnl_unlock();
+	kfree(master);
+ err1:
+	dev_put(slave);
+	return(err);
 }
 
 static int dlci_del(struct dlci_add *dlci)
@@ -433,21 +441,18 @@
 	slave = dlp->slave;
 	flp = slave->priv;
 
+	rtnl_lock();
 	err = (*flp->deassoc)(slave, master);
-	if (err) 
-		return(err);
-
+	if (!err) {
+		list_del(&dlp->list);
 
-	spin_lock_bh(&dlci_dev_lock);
-	list_del(&dlp->list);
-	spin_unlock_bh(&dlci_dev_lock);
+		unregister_netdevice(master);
 
-	unregister_netdev(master);
-
-	dev_put(slave);
-	free_netdev(master);
+		dev_put(slave);
+	}
+	rtnl_unlock();
 
-	return(0);
+	return(err);
 }
 
 static int dlci_ioctl(unsigned int cmd, void *arg)
@@ -494,6 +499,7 @@
 	dev->hard_header	= dlci_header;
 	dev->get_stats		= dlci_get_stats;
 	dev->change_mtu		= dlci_change_mtu;
+	dev->destructor		= free_netdev;
 
 	dlp->receive		= dlci_receive;
 
@@ -518,12 +524,12 @@
 	
 	dlci_ioctl_set(NULL);
 
+	rtnl_lock();
 	list_for_each_entry_safe(dlp, nxt, &dlci_devs, list) {
-		unregister_netdev(dlp->master);
+		unregister_netdevice(dlp->master);
 		dev_put(dlp->slave);
-		free_netdev(dlp->master);
 	}
-
+	rtnl_unlock();
 }
 
 module_init(init_dlci);
