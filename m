From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.8-rc3-mm1 1/1] via-velocity: more inetaddr_notifier fix
Date: Fri, 6 Aug 2004 00:01:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040806000137.B16153@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
        Ferenc Kubinszky <ferenc.kubinszky@wit.mht.bme.hu>,
        Kazutoshi Morioka <morioka@at.wakwak.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There is no guarantee that the event which gets passed is associated to
a via-velocity device, thus preventing to dereference dev->priv as if it
always was a struct velocity_info *.
The via-velocity devices are kept in a module private list for comparison.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/via-velocity.c~via-velocity-wol-strangeness drivers/net/via-velocity.c
--- linux-2.6.8-rc3/drivers/net/via-velocity.c~via-velocity-wol-strangeness	2004-08-05 23:47:54.000000000 +0200
+++ linux-2.6.8-rc3-romieu/drivers/net/via-velocity.c	2004-08-05 23:47:54.000000000 +0200
@@ -262,6 +262,7 @@ static u32 check_connection_type(struct 
 static int velocity_set_media_mode(struct velocity_info *vptr, u32 mii_status);
 
 #ifdef CONFIG_PM
+
 static int velocity_suspend(struct pci_dev *pdev, u32 state);
 static int velocity_resume(struct pci_dev *pdev);
 
@@ -270,9 +271,26 @@ static int velocity_netdev_event(struct 
 static struct notifier_block velocity_inetaddr_notifier = {
       .notifier_call	= velocity_netdev_event,
 };
-static int velocity_notifier_registered;
 
-#endif				/* CONFIG_PM */
+static spinlock_t velocity_dev_list_lock = SPIN_LOCK_UNLOCKED;
+static LIST_HEAD(velocity_dev_list);
+
+static void velocity_register_notifier(void)
+{
+	register_inetaddr_notifier(&velocity_inetaddr_notifier);
+}
+
+static void velocity_unregister_notifier(void)
+{
+	unregister_inetaddr_notifier(&velocity_inetaddr_notifier);
+}
+
+#else				/* CONFIG_PM */
+
+#define velocity_register_notifier()	do {} while (0)
+#define velocity_unregister_notifier()	do {} while (0)
+
+#endif				/* !CONFIG_PM */
 
 /*
  *	Internal board variants. At the moment we have only one
@@ -327,6 +345,14 @@ static void __devexit velocity_remove1(s
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct velocity_info *vptr = dev->priv;
 
+#ifdef CONFIG_PM
+	unsigned long flags;
+
+	spin_lock_irqsave(&velocity_dev_list_lock, flags);
+	if (!list_empty(&velocity_dev_list))
+		list_del(&vptr->list);
+	spin_unlock_irqrestore(&velocity_dev_list_lock, flags);
+#endif
 	unregister_netdev(dev);
 	iounmap(vptr->mac_regs);
 	pci_release_regions(pdev);
@@ -782,13 +808,16 @@ static int __devinit velocity_found1(str
 	/* and leave the chip powered down */
 	
 	pci_set_power_state(pdev, 3);
-out:
 #ifdef CONFIG_PM
-	if (ret == 0 && !velocity_notifier_registered) {
-		velocity_notifier_registered = 1;
-		register_inetaddr_notifier(&velocity_inetaddr_notifier);
+	{
+		unsigned long flags;
+
+		spin_lock_irqsave(&velocity_dev_list_lock, flags);
+		list_add(&vptr->list, &velocity_dev_list);
+		spin_unlock_irqrestore(&velocity_dev_list_lock, flags);
 	}
 #endif
+out:
 	return ret;
 
 err_iounmap:
@@ -843,6 +872,8 @@ static void __devinit velocity_init_info
 
 	spin_lock_init(&vptr->lock);
 	spin_lock_init(&vptr->xmit_lock);
+
+	INIT_LIST_HEAD(&vptr->list);
 }
 
 /**
@@ -2211,8 +2242,11 @@ static struct pci_driver velocity_driver
 static int __init velocity_init_module(void)
 {
 	int ret;
-	ret = pci_module_init(&velocity_driver);
 
+	velocity_register_notifier();
+	ret = pci_module_init(&velocity_driver);
+	if (ret < 0)
+		velocity_unregister_notifier();
 	return ret;
 }
 
@@ -2227,12 +2261,7 @@ static int __init velocity_init_module(v
  
 static void __exit velocity_cleanup_module(void)
 {
-#ifdef CONFIG_PM
-	if (velocity_notifier_registered) {
-		unregister_inetaddr_notifier(&velocity_inetaddr_notifier);
-		velocity_notifier_registered = 0;
-	}
-#endif
+	velocity_unregister_notifier();
 	pci_unregister_driver(&velocity_driver);
 }
 
@@ -3252,13 +3281,20 @@ static int velocity_resume(struct pci_de
 static int velocity_netdev_event(struct notifier_block *nb, unsigned long notification, void *ptr)
 {
 	struct in_ifaddr *ifa = (struct in_ifaddr *) ptr;
-	struct net_device *dev;
-	struct velocity_info *vptr;
 
 	if (ifa) {
-		dev = ifa->ifa_dev->dev;
-		vptr = dev->priv;
-		velocity_get_ip(vptr);
+		struct net_device *dev = ifa->ifa_dev->dev;
+		struct velocity_info *vptr;
+		unsigned long flags;
+
+		spin_lock_irqsave(&velocity_dev_list_lock, flags);
+		list_for_each_entry(vptr, &velocity_dev_list, list) {
+			if (vptr->dev == dev) {
+				velocity_get_ip(vptr);
+				break;
+			}
+		}
+		spin_unlock_irqrestore(&velocity_dev_list_lock, flags);
 	}
 	return NOTIFY_DONE;
 }
diff -puN drivers/net/via-velocity.h~via-velocity-wol-strangeness drivers/net/via-velocity.h
--- linux-2.6.8-rc3/drivers/net/via-velocity.h~via-velocity-wol-strangeness	2004-08-05 23:47:54.000000000 +0200
+++ linux-2.6.8-rc3-romieu/drivers/net/via-velocity.h	2004-08-05 23:47:54.000000000 +0200
@@ -1733,8 +1733,7 @@ struct velocity_opt {
 };
 
 struct velocity_info {
-	struct velocity_info *next;
-	struct velocity_info *prev;
+	struct list_head list;
 
 	struct pci_dev *pdev;
 	struct net_device *dev;

_
