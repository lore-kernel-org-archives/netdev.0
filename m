From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/4) remove hashbin from irlan
Date: Mon, 18 Aug 2003 11:39:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818113936.205b5632.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
   "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The locking in hashbin_delete is a problem since unregister_netdevice
can't be called with locks held in 2.6.0-test3.

Replace it with simpler list macros.
Insertion/deletion protected with RTNL semaphore, and read
uses RCU.

Don't have client hardware to test, but load/unload works on SMP.

diff -Nru a/include/net/irda/irlan_common.h b/include/net/irda/irlan_common.h
--- a/include/net/irda/irlan_common.h	Mon Aug 18 11:09:06 2003
+++ b/include/net/irda/irlan_common.h	Mon Aug 18 11:09:06 2003
@@ -33,7 +33,6 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 
-#include <net/irda/irqueue.h>
 #include <net/irda/irttp.h>
 
 #define IRLAN_MTU        1518
@@ -161,9 +160,8 @@
  *  IrLAN control block
  */
 struct irlan_cb {
-	irda_queue_t q; /* Must be first */
-
 	int    magic;
+	struct list_head  dev_list;
 	struct net_device dev;        /* Ethernet device structure*/
 	struct net_device_stats stats;
 
@@ -204,6 +202,7 @@
 
 int irlan_run_ctrl_tx_queue(struct irlan_cb *self);
 
+struct irlan_cb *irlan_get_any(void);
 void irlan_get_provider_info(struct irlan_cb *self);
 void irlan_get_unicast_addr(struct irlan_cb *self);
 void irlan_get_media_char(struct irlan_cb *self);
@@ -221,8 +220,6 @@
 
 int irlan_extract_param(__u8 *buf, char *name, char *value, __u16 *len);
 void print_ret_code(__u8 code);
-
-extern hashbin_t *irlan;
 
 #endif
 
diff -Nru a/net/irda/irlan/irlan_client.c b/net/irda/irlan/irlan_client.c
--- a/net/irda/irlan/irlan_client.c	Mon Aug 18 11:09:06 2003
+++ b/net/irda/irlan/irlan_client.c	Mon Aug 18 11:09:06 2003
@@ -154,7 +154,6 @@
 	
 	IRDA_DEBUG(1, "%s()\n", __FUNCTION__ );
 
-	ASSERT(irlan != NULL, return;);
 	ASSERT(discovery != NULL, return;);
 
 	/*
@@ -170,7 +169,8 @@
 	daddr = discovery->daddr;
 
 	/* Find instance */
-	self = (struct irlan_cb *) hashbin_get_first(irlan);
+	rcu_read_lock();
+	self = irlan_get_any();
 	if (self) {
 		ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -179,6 +179,7 @@
 		
 		irlan_client_wakeup(self, saddr, daddr);
 	}
+	rcu_read_unlock();
 }
 	
 /*
diff -Nru a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
--- a/net/irda/irlan/irlan_common.c	Mon Aug 18 11:09:06 2003
+++ b/net/irda/irlan/irlan_common.c	Mon Aug 18 11:09:06 2003
@@ -33,6 +33,7 @@
 #include <linux/proc_fs.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/rtnetlink.h>
 
 #include <asm/system.h>
 #include <asm/bitops.h>
@@ -63,7 +64,8 @@
 /*
  *  Master structure
  */
-hashbin_t *irlan = NULL;
+static LIST_HEAD(irlans);
+
 static void *ckey;
 static void *skey;
 
@@ -124,12 +126,6 @@
 	__u16 hints;
 
 	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
-	/* Allocate master structure */
-	irlan = hashbin_new(HB_LOCK);	/* protect from /proc */
-	if (irlan == NULL) {
-		printk(KERN_WARNING "IrLAN: Can't allocate hashbin!\n");
-		return -ENOMEM;
-	}
 #ifdef CONFIG_PROC_FS
 	create_proc_info_entry("irlan", 0, proc_irda, irlan_proc_read);
 #endif /* CONFIG_PROC_FS */
@@ -158,6 +154,8 @@
 
 void __exit irlan_cleanup(void) 
 {
+	struct irlan_cb *self, *next;
+
 	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
 
 	irlmp_unregister_client(ckey);
@@ -166,10 +164,13 @@
 #ifdef CONFIG_PROC_FS
 	remove_proc_entry("irlan", proc_irda);
 #endif /* CONFIG_PROC_FS */
-	/*
-	 *  Delete hashbin and close all irlan client instances in it
-	 */
-	hashbin_delete(irlan, (FREE_FUNC) __irlan_close);
+
+	/* Cleanup any leftover network devices */
+	rtnl_lock();
+	list_for_each_entry_safe(self, next, &irlans, dev_list) {
+		__irlan_close(self);
+	}
+	rtnl_unlock();
 }
 
 /*
@@ -210,7 +211,6 @@
 	struct irlan_cb *self;
 
 	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
-	ASSERT(irlan != NULL, return NULL;);
 
 	/* 
 	 *  Initialize the irlan structure. 
@@ -243,7 +243,7 @@
 	init_timer(&self->client.kick_timer);
 	init_waitqueue_head(&self->open_wait);	
 
-	hashbin_insert(irlan, (irda_queue_t *) self, daddr, NULL);
+	list_add_rcu(&self->dev_list, &irlans);
 	
 	skb_queue_head_init(&self->client.txq);
 	
@@ -258,8 +258,7 @@
  * Function __irlan_close (self)
  *
  *    This function closes and deallocates the IrLAN client instances. Be 
- *    aware that other functions which calles client_close() must call 
- *    hashbin_remove() first!!!
+ *    aware that other functions which calles client_close()
  */
 static void __irlan_close(struct irlan_cb *self)
 {
@@ -267,6 +266,7 @@
 
 	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
 	
+	ASSERT_RTNL();
 	ASSERT(self != NULL, return;);
 	ASSERT(self->magic == IRLAN_MAGIC, return;);
 
@@ -283,12 +283,23 @@
 	while ((skb = skb_dequeue(&self->client.txq)))
 		dev_kfree_skb(skb);
 
-	unregister_netdev(&self->dev);
+	unregister_netdevice(&self->dev);
 	
 	self->magic = 0;
 	kfree(self);
 }
 
+/* Find any instance of irlan, used for client discovery wakeup */
+struct irlan_cb *irlan_get_any(void)
+{
+	struct irlan_cb *self;
+
+	list_for_each_entry_rcu(self, &irlans, dev_list) {
+		return self;
+	}
+	return NULL;
+}
+
 /*
  * Function irlan_connect_indication (instance, sap, qos, max_sdu_size, skb)
  *
@@ -1086,18 +1097,16 @@
  */
 static int irlan_proc_read(char *buf, char **start, off_t offset, int len)
 {
- 	struct irlan_cb *self;
-	unsigned long flags;
-	ASSERT(irlan != NULL, return 0;);
+	struct irlan_cb *self;
      
 	len = 0;
 	
-	spin_lock_irqsave(&irlan->hb_spinlock, flags);
+	rcu_read_lock();
 
 	len += sprintf(buf+len, "IrLAN instances:\n");
 	
-	self = (struct irlan_cb *) hashbin_get_first(irlan);
-	while (self != NULL) {
+	list_for_each_entry_rcu(self, &irlans, dev_list) {
+
 		ASSERT(self->magic == IRLAN_MAGIC, break;);
 		
 		len += sprintf(buf+len, "ifname: %s,\n",
@@ -1126,10 +1135,8 @@
 			       netif_queue_stopped(&self->dev) ? "TRUE" : "FALSE");
 			
 		len += sprintf(buf+len, "\n");
-
-		self = (struct irlan_cb *) hashbin_get_next(irlan);
  	} 
-	spin_unlock_irqrestore(&irlan->hb_spinlock, flags);
+	rcu_read_unlock();
 
 	return len;
 }
