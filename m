From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/11) Irda dongle module owner support (revised)
Date: Fri, 3 Oct 2003 10:21:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003102133.2e5a41a2.shemminger@osdl.org>
References: <20031002152026.4bfd2c67.shemminger@osdl.org>
	<20031002233335.GA7945@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, "David S. Miller" <davem@redhat.com>,
        irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20031002233335.GA7945@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Revised version of the dongle module owner patch, incorporating Jean's comments.
This replaces the original patch.  It provides an owner field an appropriate 
ref counting for IRDA dongles.

Changes since list version:
	s/dongle_lock/dongles->hb_spinlock/
	get lock on device_cleanup
	replace ASSERT() about in_interrupt with might_sleep().

In case your curious about locking, the callers are:
	module_init -> irda_device_init
	module_exit -> irda_device_cleanup
	irport_net_ioctl -> irda_device_dongle_init
	module_init -> XXX_dongle_init -> irda_device_register_dongle
	module_exit -> XXX_dongle_exit -> irda_device_unregister_dongle

In other words, no interrupt or BH access to the dongle list.
Obviously, hashing this list is overkill, but "when in Rome"...

--- linux-2.5/net/irda/irda_device.c	2003-10-01 13:40:11.000000000 -0700
+++ irda-2.5/net/irda/irda_device.c	2003-10-03 10:03:52.497879915 -0700
@@ -85,7 +85,7 @@ static void irda_task_timer_expired(void
 
 int __init irda_device_init( void)
 {
-	dongles = hashbin_new(HB_LOCK);
+	dongles = hashbin_new(HB_NOLOCK);
 	if (dongles == NULL) {
 		printk(KERN_WARNING "IrDA: Can't allocate dongles hashbin!\n");
 		return -ENOMEM;
@@ -109,7 +109,9 @@ void __exit irda_device_cleanup(void)
 	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
 
 	hashbin_delete(tasks, (FREE_FUNC) __irda_task_delete);
+	spin_lock(&dongles->hb_spinlock);
 	hashbin_delete(dongles, NULL);
+	spin_unlock(&dongles->hb_spinlock);
 }
 
 /*
@@ -424,25 +426,34 @@ int irda_device_txqueue_empty(struct net
 dongle_t *irda_device_dongle_init(struct net_device *dev, int type)
 {
 	struct dongle_reg *reg;
-	dongle_t *dongle;
+	dongle_t *dongle = NULL;
 
-	ASSERT(dev != NULL, return NULL;);
+	might_sleep();
+
+	spin_lock(&dongles->hb_spinlock);
+	reg = hashbin_find(dongles, type, NULL);
 
 #ifdef CONFIG_KMOD
-	ASSERT(!in_interrupt(), return NULL;);
 	/* Try to load the module needed */
-	request_module("irda-dongle-%d", type);
+	if (!reg && capable(CAP_SYS_MODULE)) {
+		spin_unlock(&dongles->hb_spinlock);
+	
+		request_module("irda-dongle-%d", type);
+		
+		spin_lock(&dongles->hb_spinlock);
+		reg = hashbin_find(dongles, type, NULL);
+	}
 #endif
 
-	if (!(reg = hashbin_lock_find(dongles, type, NULL))) {
-		ERROR("IrDA: Unable to find requested dongle\n");
-		return NULL;
+	if (!reg || !try_module_get(reg->owner) ) {
+		ERROR("IrDA: Unable to find requested dongle type %x\n", type);
+		goto out;
 	}
 
 	/* Allocate dongle info for this instance */
 	dongle = kmalloc(sizeof(dongle_t), GFP_KERNEL);
 	if (!dongle)
-		return NULL;
+		goto out;
 
 	memset(dongle, 0, sizeof(dongle_t));
 
@@ -450,6 +461,8 @@ dongle_t *irda_device_dongle_init(struct
 	dongle->issue = reg;
 	dongle->dev = dev;
 
+ out:
+	spin_unlock(&dongles->hb_spinlock);
 	return dongle;
 }
 
@@ -461,7 +474,7 @@ int irda_device_dongle_cleanup(dongle_t 
 	ASSERT(dongle != NULL, return -1;);
 
 	dongle->issue->close(dongle);
-
+	module_put(dongle->issue->owner);
 	kfree(dongle);
 
 	return 0;
@@ -472,14 +485,16 @@ int irda_device_dongle_cleanup(dongle_t 
  */
 int irda_device_register_dongle(struct dongle_reg *new)
 {
+	spin_lock(&dongles->hb_spinlock);
 	/* Check if this dongle has been registered before */
-	if (hashbin_lock_find(dongles, new->type, NULL)) {
-		MESSAGE("%s: Dongle already registered\n", __FUNCTION__);
-                return 0;
-        }
-
-	/* Insert IrDA dongle into hashbin */
-	hashbin_insert(dongles, (irda_queue_t *) new, new->type, NULL);
+	if (hashbin_find(dongles, new->type, NULL)) {
+		MESSAGE("%s: Dongle type %x already registered\n", 
+			__FUNCTION__, new->type);
+        } else {
+		/* Insert IrDA dongle into hashbin */
+		hashbin_insert(dongles, (irda_queue_t *) new, new->type, NULL);
+	}
+	spin_unlock(&dongles->hb_spinlock);
 
         return 0;
 }
@@ -494,11 +509,11 @@ void irda_device_unregister_dongle(struc
 {
 	struct dongle *node;
 
+	spin_lock(&dongles->hb_spinlock);
 	node = hashbin_remove(dongles, dongle->type, NULL);
-	if (!node) {
+	if (!node) 
 		ERROR("%s: dongle not found!\n", __FUNCTION__);
-		return;
-	}
+	spin_unlock(&dongles->hb_spinlock);
 }
 
 /*
