From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/4) convert irlan to use alloc_netdev
Date: Mon, 18 Aug 2003 11:49:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818114930.4ca873cf.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
   "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch to 2.6.0-test3 converts irlan to use alloc_netdev.

Setup auto free via destructor.

diff -Nru a/include/net/irda/irlan_common.h b/include/net/irda/irlan_common.h
--- a/include/net/irda/irlan_common.h	Mon Aug 18 11:09:33 2003
+++ b/include/net/irda/irlan_common.h	Mon Aug 18 11:09:33 2003
@@ -162,7 +162,7 @@
 struct irlan_cb {
 	int    magic;
 	struct list_head  dev_list;
-	struct net_device dev;        /* Ethernet device structure*/
+	struct net_device *dev;        /* Ethernet device structure*/
 	struct net_device_stats stats;
 
 	__u32 saddr;               /* Source device address */
diff -Nru a/include/net/irda/irlan_eth.h b/include/net/irda/irlan_eth.h
--- a/include/net/irda/irlan_eth.h	Mon Aug 18 11:09:33 2003
+++ b/include/net/irda/irlan_eth.h	Mon Aug 18 11:09:33 2003
@@ -25,7 +25,7 @@
 #ifndef IRLAN_ETH_H
 #define IRLAN_ETH_H
 
-int  irlan_eth_init(struct net_device *dev);
+void  irlan_eth_setup(struct net_device *dev);
 int  irlan_eth_open(struct net_device *dev);
 int  irlan_eth_close(struct net_device *dev);
 int  irlan_eth_receive(void *instance, void *sap, struct sk_buff *skb);
diff -Nru a/net/irda/irlan/irlan_client.c b/net/irda/irlan/irlan_client.c
--- a/net/irda/irlan/irlan_client.c	Mon Aug 18 11:09:33 2003
+++ b/net/irda/irlan/irlan_client.c	Mon Aug 18 11:09:33 2003
@@ -512,7 +512,7 @@
 		      bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], 
 		      bytes[5]);
 		for (i = 0; i < 6; i++) 
-			self->dev.dev_addr[i] = bytes[i];
+			self->dev->dev_addr[i] = bytes[i];
 	}
 }
 
diff -Nru a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
--- a/net/irda/irlan/irlan_common.c	Mon Aug 18 11:09:33 2003
+++ b/net/irda/irlan/irlan_common.c	Mon Aug 18 11:09:33 2003
@@ -174,33 +174,6 @@
 }
 
 /*
- * Function irlan_register_netdev (self)
- *
- *    Registers the network device to be used. We should don't register until
- *    we have been binded to a particular provider or client.
- */
-int irlan_register_netdev(struct irlan_cb *self)
-{
-	int i=0;
-
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
-
-	/* Check if we should call the device eth<x> or irlan<x> */
-	if (!eth) {
-		/* Get the first free irlan<x> name */
-		do {
-			sprintf(self->dev.name, "%s%d", "irlan", i++);
-		} while (dev_get(self->dev.name));
-	}
-	
-	if (register_netdev(&self->dev) != 0) {
-		IRDA_DEBUG(2, "%s(), register_netdev() failed!\n", __FUNCTION__ );
-		return -1;
-	}
-	return 0;
-}
-
-/*
  * Function irlan_open (void)
  *
  *    Open new instance of a client/provider, we should only register the 
@@ -208,30 +181,25 @@
  */
 struct irlan_cb *irlan_open(__u32 saddr, __u32 daddr)
 {
+	struct net_device *dev;
 	struct irlan_cb *self;
 
 	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
 
-	/* 
-	 *  Initialize the irlan structure. 
-	 */
-	self = kmalloc(sizeof(struct irlan_cb), GFP_ATOMIC);
-	if (self == NULL)
+	/* Create network device with irlan */
+	dev = alloc_netdev(sizeof(*self), 
+			   eth ? "eth%d" : "irlan%d", 
+			   irlan_eth_setup);
+	if (!dev)
 		return NULL;
-	
-	memset(self, 0, sizeof(struct irlan_cb));
+
+	self = dev->priv;
+	self->dev = dev;
 
 	/*
 	 *  Initialize local device structure
 	 */
 	self->magic = IRLAN_MAGIC;
-
-	sprintf(self->dev.name, "%s", "unknown");
-
-	self->dev.priv = (void *) self;
-	self->dev.next = NULL;
-	self->dev.init = irlan_eth_init;
-	
 	self->saddr = saddr;
 	self->daddr = daddr;
 
@@ -242,15 +210,22 @@
 	init_timer(&self->watchdog_timer);
 	init_timer(&self->client.kick_timer);
 	init_waitqueue_head(&self->open_wait);	
-
-	list_add_rcu(&self->dev_list, &irlans);
 	
 	skb_queue_head_init(&self->client.txq);
 	
 	irlan_next_client_state(self, IRLAN_IDLE);
 	irlan_next_provider_state(self, IRLAN_IDLE);
 
-	irlan_register_netdev(self);
+	if (register_netdev(dev)) {
+		IRDA_DEBUG(2, "%s(), register_netdev() failed!\n", 
+			   __FUNCTION__ );
+		self = NULL;
+		kfree(dev);
+	} else {
+		rtnl_lock();
+		list_add_rcu(&self->dev_list, &irlans);
+		rtnl_unlock();
+	}
 
 	return self;
 }
@@ -258,7 +233,8 @@
  * Function __irlan_close (self)
  *
  *    This function closes and deallocates the IrLAN client instances. Be 
- *    aware that other functions which calles client_close()
+ *    aware that other functions which calls client_close() must
+ *    remove self from irlans list first.
  */
 static void __irlan_close(struct irlan_cb *self)
 {
@@ -283,10 +259,8 @@
 	while ((skb = skb_dequeue(&self->client.txq)))
 		dev_kfree_skb(skb);
 
-	unregister_netdevice(&self->dev);
-	
-	self->magic = 0;
-	kfree(self);
+	/* Unregister and free self via destructor */
+	unregister_netdevice(self->dev);
 }
 
 /* Find any instance of irlan, used for client discovery wakeup */
@@ -348,7 +322,7 @@
 		irlan_open_unicast_addr(self);
 	}
 	/* Ready to transfer Ethernet frames (at last) */
-	netif_start_queue(&self->dev); /* Clear reason */
+	netif_start_queue(self->dev); /* Clear reason */
 }
 
 void irlan_connect_confirm(void *instance, void *sap, struct qos_info *qos, 
@@ -382,7 +356,7 @@
  	irlan_set_multicast_filter(self, TRUE);
 
 	/* Ready to transfer Ethernet frames */
-	netif_start_queue(&self->dev);
+	netif_start_queue(self->dev);
 	self->disconnect_reason = 0; /* Clear reason */
 #ifdef CONFIG_IRLAN_SEND_GRATUITOUS_ARP
 	irlan_eth_send_gratuitous_arp(&self->dev);
@@ -1110,7 +1084,7 @@
 		ASSERT(self->magic == IRLAN_MAGIC, break;);
 		
 		len += sprintf(buf+len, "ifname: %s,\n",
-			       self->dev.name);
+			       self->dev->name);
 		len += sprintf(buf+len, "client state: %s, ",
 			       irlan_state[ self->client.state]);
 		len += sprintf(buf+len, "provider state: %s,\n",
@@ -1132,7 +1106,7 @@
 					  buf+len);
 			
 		len += sprintf(buf+len, "tx busy: %s\n", 
-			       netif_queue_stopped(&self->dev) ? "TRUE" : "FALSE");
+			       netif_queue_stopped(self->dev) ? "TRUE" : "FALSE");
 			
 		len += sprintf(buf+len, "\n");
  	} 
diff -Nru a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
--- a/net/irda/irlan/irlan_eth.c	Mon Aug 18 11:09:33 2003
+++ b/net/irda/irlan/irlan_eth.c	Mon Aug 18 11:09:33 2003
@@ -47,14 +47,12 @@
  *    The network device initialization function.
  *
  */
-int irlan_eth_init(struct net_device *dev)
+void irlan_eth_setup(struct net_device *dev)
 {
 	struct irlan_cb *self;
 
 	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
 
-	ASSERT(dev != NULL, return -1;);
-       
 	self = (struct irlan_cb *) dev->priv;
 
 	dev->open               = irlan_eth_open;
@@ -62,6 +60,8 @@
 	dev->hard_start_xmit    = irlan_eth_xmit; 
 	dev->get_stats	        = irlan_eth_get_stats;
 	dev->set_multicast_list = irlan_eth_set_multicast_list;
+	dev->destructor		= (void (*)(struct net_device *)) kfree;
+
 	SET_MODULE_OWNER(dev);
 
 	ether_setup(dev);
@@ -85,8 +85,6 @@
 		get_random_bytes(dev->dev_addr+4, 1);
 		get_random_bytes(dev->dev_addr+5, 1);
 	}
-
-	return 0;
 }
 
 /*
@@ -237,7 +235,7 @@
 	 * might have been previously set by the low level IrDA network
 	 * device driver 
 	 */
-	skb->dev = &self->dev;
+	skb->dev = self->dev;
 	skb->protocol=eth_type_trans(skb, skb->dev); /* Remove eth header */
 	
 	self->stats.rx_packets++;
@@ -264,7 +262,7 @@
 	ASSERT(self != NULL, return;);
 	ASSERT(self->magic == IRLAN_MAGIC, return;);
 	
-	dev = &self->dev;
+	dev = self->dev;
 
 	ASSERT(dev != NULL, return;);
 	

	
