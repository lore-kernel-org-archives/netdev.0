From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/11) Irda dongle module owner support
Date: Thu, 2 Oct 2003 15:20:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002152026.4bfd2c67.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

IRDA dongle interface needed to be converted to have an owner field
to avoid races on module unload.

Eliminated the use of hashbin locking because the dongle control
code needed to do it's own locking to avoid races.   This also closed
the race between find and insert. 

The find/insert hashbin race may be a general problem with all the IRDA
hashbin stuff. IMHO the hashbin stuff should be replaced, it is full
of dead incomplete code and done better by the list macros.

diff -Nru a/include/net/irda/irda_device.h b/include/net/irda/irda_device.h
--- a/include/net/irda/irda_device.h	Thu Oct  2 14:51:18 2003
+++ b/include/net/irda/irda_device.h	Thu Oct  2 14:51:18 2003
@@ -128,6 +128,7 @@
 	void (*close)(dongle_t *dongle);
 	int  (*reset)(struct irda_task *task);
 	int  (*change_speed)(struct irda_task *task);
+	struct module *owner;
 };
 
 /* 
diff -Nru a/net/irda/irda_device.c b/net/irda/irda_device.c
--- a/net/irda/irda_device.c	Thu Oct  2 14:51:18 2003
+++ b/net/irda/irda_device.c	Thu Oct  2 14:51:18 2003
@@ -58,6 +58,7 @@
 static void __irda_task_delete(struct irda_task *task);
 
 static hashbin_t *dongles = NULL;
+static spinlock_t dongle_lock = SPIN_LOCK_UNLOCKED;
 static hashbin_t *tasks = NULL;
 
 const char *infrared_mode[] = {
@@ -85,7 +86,7 @@
 
 int __init irda_device_init( void)
 {
-	dongles = hashbin_new(HB_LOCK);
+	dongles = hashbin_new(HB_NOLOCK);
 	if (dongles == NULL) {
 		printk(KERN_WARNING "IrDA: Can't allocate dongles hashbin!\n");
 		return -ENOMEM;
@@ -424,25 +425,35 @@
 dongle_t *irda_device_dongle_init(struct net_device *dev, int type)
 {
 	struct dongle_reg *reg;
-	dongle_t *dongle;
+	dongle_t *dongle = NULL;
 
 	ASSERT(dev != NULL, return NULL;);
+	ASSERT(!in_interrupt(), return NULL;);
+
+	spin_lock(&dongle_lock);
+	reg = hashbin_find(dongles, type, NULL);
 
 #ifdef CONFIG_KMOD
-	ASSERT(!in_interrupt(), return NULL;);
 	/* Try to load the module needed */
-	request_module("irda-dongle-%d", type);
+	if (!reg && capable(CAP_SYS_MODULE)) {
+		spin_unlock(&dongle_lock);
+	
+		request_module("irda-dongle-%d", type);
+		
+		spin_lock(&dongle_lock);
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
 
@@ -450,6 +461,8 @@
 	dongle->issue = reg;
 	dongle->dev = dev;
 
+ out:
+	spin_unlock(&dongle_lock);
 	return dongle;
 }
 
@@ -461,7 +474,7 @@
 	ASSERT(dongle != NULL, return -1;);
 
 	dongle->issue->close(dongle);
-
+	module_put(dongle->issue->owner);
 	kfree(dongle);
 
 	return 0;
@@ -472,14 +485,16 @@
  */
 int irda_device_register_dongle(struct dongle_reg *new)
 {
+	spin_lock(&dongle_lock);
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
+	spin_unlock(&dongle_lock);
 
         return 0;
 }
@@ -494,11 +509,11 @@
 {
 	struct dongle *node;
 
+	spin_lock(&dongle_lock);
 	node = hashbin_remove(dongles, dongle->type, NULL);
-	if (!node) {
+	if (!node) 
 		ERROR("%s: dongle not found!\n", __FUNCTION__);
-		return;
-	}
+	spin_unlock(&dongle_lock);
 }
 
 /*
