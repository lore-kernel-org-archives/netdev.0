From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] spinlock badness in last dongle changes.
Date: Mon, 6 Oct 2003 22:26:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031006222631.1934f8e1.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com, davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 2.6.0-test6 bk latest, rmmod of irda hangs on SMP...

A couple of locking problems happened when converted from using
hashbin lock outside of irqueue.  First, the lock was never initialized;
Second, the lock was being unlocked after the hashbin was free.

Since the hashbin of dongles should be empty (ie all dongle unregistered)
don't really need locking there, so just warn if we find anything...

diff -Nru a/net/irda/irda_device.c b/net/irda/irda_device.c
--- a/net/irda/irda_device.c	Mon Oct  6 22:25:01 2003
+++ b/net/irda/irda_device.c	Mon Oct  6 22:25:01 2003
@@ -90,6 +90,7 @@
 		printk(KERN_WARNING "IrDA: Can't allocate dongles hashbin!\n");
 		return -ENOMEM;
 	}
+	spin_lock_init(&dongles->hb_spinlock);
 
 	tasks = hashbin_new(HB_LOCK);
 	if (tasks == NULL) {
@@ -104,14 +105,20 @@
 	return 0;
 }
 
+static void __exit leftover_dongle(void *arg)
+{
+	struct dongle_reg *reg = arg;
+	printk(KERN_WARNING "IrDA: Dongle type %x not unregistered\n",
+	       reg->type);
+}
+
 void __exit irda_device_cleanup(void)
 {
 	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
 
 	hashbin_delete(tasks, (FREE_FUNC) __irda_task_delete);
-	spin_lock(&dongles->hb_spinlock);
-	hashbin_delete(dongles, NULL);
-	spin_unlock(&dongles->hb_spinlock);
+
+	hashbin_delete(dongles, leftover_dongle);
 }
 
 /*
