From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] restore netdev_priv optimization
Date: Fri, 17 Aug 2007 15:40:22 -0700
Message-ID: <20070817154022.0f3afba4@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53693 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759443AbXHQWkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 18:40:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Compile tested only!!!

Fix optimization of netdev_priv() lost by the  addition of multiqueue.
Move the variable size subqueues to after the constant size priv area.

When putting back the old netdev_priv() code, I tried to make it
clearer by using roundup() and ALIGN() macros.

--- a/include/linux/netdevice.h	2007-08-17 12:08:51.000000000 -0400
+++ b/include/linux/netdevice.h	2007-08-17 12:48:03.000000000 -0400
@@ -575,16 +575,15 @@ struct net_device
 
 	/* The TX queue control structures */
 	unsigned int			egress_subqueue_count;
-	struct net_device_subqueue	egress_subqueue[1];
+	struct net_device_subqueue	*egress_subqueue;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
 #define	NETDEV_ALIGN		32
-#define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
 
 static inline void *netdev_priv(const struct net_device *dev)
 {
-	return dev->priv;
+	return (void *)dev + ALIGN(sizeof(struct net_device), NETDEV_ALIGN);
 }
 
 #define SET_MODULE_OWNER(dev) do { } while (0)
--- a/net/core/dev.c	2007-08-17 09:02:57.000000000 -0400
+++ b/net/core/dev.c	2007-08-17 12:48:30.000000000 -0400
@@ -3706,7 +3706,22 @@ EXPORT_SYMBOL(dev_get_stats);
  *	@queue_count:	the number of subqueues to allocate
  *
  *	Allocates a struct net_device with private data area for driver use
- *	and performs basic initialization.  Also allocates subquue structs
+ *	and performs basic initialization.
+ *
+ *      Layout:
+ *              allocation->+------------+
+ *                          | (pad)      | dev->padded
+ *                   dev -->+------------+ -- (32 byte boundary)
+ *                          | net_device |
+ *      netdev_priv(dev) -->+------------+ -- (32 byte boundary)
+ *                          | device     |
+ *                          | private    |
+ *			    |            |
+ * dev->egress_subqueue  -->+------------+ -- (32 byte boundary)
+ *                          | Tx queue(s)|
+ *                          +------------+
+ *
+ * Also allocates subqueue structs
  *	for each queue on the device at the end of the netdevice.
  */
 struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
@@ -3719,10 +3734,9 @@ struct net_device *alloc_netdev_mq(int s
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
 	/* ensure 32-byte alignment of both the device and private area */
-	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST +
-		     (sizeof(struct net_device_subqueue) * (queue_count - 1))) &
-		     ~NETDEV_ALIGN_CONST;
-	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
+	alloc_size = roundup(sizeof(*dev), NETDEV_ALIGN);
+	alloc_size += roundup(sizeof_priv, NETDEV_ALIGN);
+	alloc_size += sizeof(struct net_device_subqueue) * queue_count;
 
 	p = kzalloc(alloc_size, GFP_KERNEL);
 	if (!p) {
@@ -3730,19 +3744,20 @@ struct net_device *alloc_netdev_mq(int s
 		return NULL;
 	}
 
-	dev = (struct net_device *)
-		(((long)p + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
+	/* Pad so that network device is on cache line boundary	 */
+	dev = (struct net_device *) ALIGN((unsigned long) p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
 
-	if (sizeof_priv) {
-		dev->priv = ((char *)dev +
-			     ((sizeof(struct net_device) +
-			       (sizeof(struct net_device_subqueue) *
-				(queue_count - 1)) + NETDEV_ALIGN_CONST)
-			      & ~NETDEV_ALIGN_CONST));
-	}
+	if (sizeof_priv)
+		dev->priv = netdev_priv(dev);
 
+	/* Put subqueue(s) which are variable size after fix sized priv area */
 	dev->egress_subqueue_count = queue_count;
+	dev->egress_subqueue = ALIGN((unsigned long)(netdev_priv(dev) + sizeof_priv),
+				     NETDEV_ALIGN);
+
+	pr_debug("alloc_netdev_mq: p=%p dev=%p priv=%p q=%p\n",
+	       p, dev, dev->priv, dev->egress_subqueue);
 
 	setup(dev);
 	strcpy(dev->name, name);
