From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] restore netdev_priv optimization (planb)
Date: Fri, 17 Aug 2007 17:49:09 -0700
Message-ID: <20070817174909.5e890ad6@freepuppy.rosehill.hemminger.net>
References: <20070817154022.0f3afba4@freepuppy.rosehill.hemminger.net>
	<20070817.160409.88475506.davem@davemloft.net>
	<20070817161928.6b6302fd@freepuppy.rosehill.hemminger.net>
	<20070817.165625.23014105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48178 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753414AbXHRAtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 20:49:15 -0400
In-Reply-To: <20070817.165625.23014105.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix optimization of netdev_priv() lost by the addition of multiqueue.

Only configurations that define MULITQUEUE need the extra overhead in
netdevice structure and the loss of the netdev_priv optimization.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/include/linux/netdevice.h	2007-08-17 16:45:39.000000000 -0700
+++ b/include/linux/netdevice.h	2007-08-17 17:31:51.000000000 -0700
@@ -574,17 +574,22 @@ struct net_device
 	const struct rtnl_link_ops *rtnl_link_ops;
 
 	/* The TX queue control structures */
-	unsigned int			egress_subqueue_count;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	unsigned short			egress_subqueue_count;
 	struct net_device_subqueue	egress_subqueue[1];
+#endif
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
 #define	NETDEV_ALIGN		32
-#define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
 
 static inline void *netdev_priv(const struct net_device *dev)
 {
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	return dev->priv;
+#else
+	return (void *)dev + ALIGN(sizeof(struct net_device), NETDEV_ALIGN);
+#endif
 }
 
 #define SET_MODULE_OWNER(dev) do { } while (0)
--- a/net/core/dev.c	2007-08-17 16:45:39.000000000 -0700
+++ b/net/core/dev.c	2007-08-17 17:44:02.000000000 -0700
@@ -3706,7 +3706,7 @@ EXPORT_SYMBOL(dev_get_stats);
  *	@queue_count:	the number of subqueues to allocate
  *
  *	Allocates a struct net_device with private data area for driver use
- *	and performs basic initialization.  Also allocates subquue structs
+ *	and performs basic initialization.  Also allocates subqueue structs
  *	for each queue on the device at the end of the netdevice.
  */
 struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
@@ -3714,15 +3714,20 @@ struct net_device *alloc_netdev_mq(int s
 {
 	void *p;
 	struct net_device *dev;
-	int alloc_size;
+	size_t dev_size, alloc_size;
 
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
+#ifndef CONFIG_NETDEVICES_MULTIQUEUE
+	BUG_ON(queue_count > 1);
+#endif
+
 	/* ensure 32-byte alignment of both the device and private area */
-	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST +
-		     (sizeof(struct net_device_subqueue) * (queue_count - 1))) &
-		     ~NETDEV_ALIGN_CONST;
-	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
+	dev_size = sizeof(*dev)
+		+ (queue_count - 1) * sizeof(struct net_device_subqueue);
+
+	alloc_size = roundup(dev_size, NETDEV_ALIGN);
+	alloc_size += sizeof_priv + NETDEV_ALIGN - 1;
 
 	p = kzalloc(alloc_size, GFP_KERNEL);
 	if (!p) {
@@ -3730,19 +3735,17 @@ struct net_device *alloc_netdev_mq(int s
 		return NULL;
 	}
 
-	dev = (struct net_device *)
-		(((long)p + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
+	dev = (struct net_device *) ALIGN((unsigned long) p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
 
-	if (sizeof_priv) {
-		dev->priv = ((char *)dev +
-			     ((sizeof(struct net_device) +
-			       (sizeof(struct net_device_subqueue) *
-				(queue_count - 1)) + NETDEV_ALIGN_CONST)
-			      & ~NETDEV_ALIGN_CONST));
-	}
-
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	dev->egress_subqueue_count = queue_count;
+	if (sizeof_priv)
+		dev->priv = ALIGN((unsigned long)dev + dev_size, NETDEV_ALIGN);
+#else
+	if (sizeof_priv)
+		dev->priv = netdev_priv(dev);
+#endif
 
 	setup(dev);
 	strcpy(dev->name, name);

