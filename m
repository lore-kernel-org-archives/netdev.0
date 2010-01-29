From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] NAPI as kobject proposal
Date: Fri, 29 Jan 2010 10:18:39 -0800
Message-ID: <20100129101839.36944ba5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48149 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751185Ab0A2SS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 13:18:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NAPI interface structure in current kernels is managed by the driver.
As part of receive packet steering there is a requirement to add an
additional parameter to this for the CPU map. And this map needs to
have an API to set it.

The right way to do this in the kernel model is to make NAPI into
a kobject and associate it back with the network device (parent).
This isn't wildly difficult but does change some of the API for
network device drivers because:
  1. They need to handle another possible error on setup
  2. NAPI object needs to be dynamically allocated
     separately (not as part of netdev_priv)
  3. Driver should pass index that can be uses as part of
     name (easier than scanning)

Eventually, there will be:
  /sys/class/net/eth0/napi0/
                            weight
                            cpumap


So here is a starting point patch that shows how the API might look like.


---
 include/linux/netdevice.h |   20 ++++++++++++++------
 net/core/dev.c            |   28 ++++++++++++++++++++++++++--
 2 files changed, 40 insertions(+), 8 deletions(-)

--- a/include/linux/netdevice.h	2010-01-29 10:00:55.820739116 -0800
+++ b/include/linux/netdevice.h	2010-01-29 10:15:33.098863437 -0800
@@ -378,6 +378,8 @@ struct napi_struct {
 	struct list_head	dev_list;
 	struct sk_buff		*gro_list;
 	struct sk_buff		*skb;
+
+	struct kobject		kobj;
 };
 
 enum {
@@ -1037,25 +1039,31 @@ static inline void *netdev_priv(const st
 #define SET_NETDEV_DEVTYPE(net, devtype)	((net)->dev.type = (devtype))
 
 /**
- *	netif_napi_add - initialize a napi context
+ *	netif_napi_init - initialize a napi context
  *	@dev:  network device
  *	@napi: napi context
+ *	@index: queue number
  *	@poll: polling function
  *	@weight: default weight
  *
- * netif_napi_add() must be used to initialize a napi context prior to calling
+ * netif_napi_init() must be used to create a napi context prior to calling
  * *any* of the other napi related functions.
+ *
+ * in case of error, the context is not left in napi_list so it can
+ * be cleaned up by free_netdev, but is not valid for use.
  */
-void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
-		    int (*poll)(struct napi_struct *, int), int weight);
+extern int netif_napi_init(struct net_device *dev, struct napi_struct *napi,
+			   unsigned index,
+			   int (*poll)(struct napi_struct *, int), int weight);
 
 /**
- *  netif_napi_del - remove a napi context
+ *  netif_napi_del - free a napi context
  *  @napi: napi context
  *
  *  netif_napi_del() removes a napi context from the network device napi list
+ *                   and frees it.
  */
-void netif_napi_del(struct napi_struct *napi);
+extern void netif_napi_del(struct napi_struct *napi);
 
 struct napi_gro_cb {
 	/* Virtual address of skb_shinfo(skb)->frags[0].page + offset. */
--- a/net/core/dev.c	2010-01-29 10:00:55.810739850 -0800
+++ b/net/core/dev.c	2010-01-29 10:14:53.388864572 -0800
@@ -2926,9 +2926,24 @@ void napi_complete(struct napi_struct *n
 }
 EXPORT_SYMBOL(napi_complete);
 
-void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
+static void release_napi(struct kobject *kobj)
+{
+	struct napi_struct *napi
+		= container_of(kobj, struct napi_struct, kobj);
+	kfree(napi);
+}
+
+static struct kobj_type napi_ktype = {
+	/* insert future sysfs hooks ... */
+	.release = release_napi,
+};
+
+int netif_napi_init(struct net_device *dev, struct napi_struct *napi,
+		    unsigned index,
 		    int (*poll)(struct napi_struct *, int), int weight)
 {
+	int err;
+
 	INIT_LIST_HEAD(&napi->poll_list);
 	napi->gro_count = 0;
 	napi->gro_list = NULL;
@@ -2941,9 +2956,16 @@ void netif_napi_add(struct net_device *d
 	spin_lock_init(&napi->poll_lock);
 	napi->poll_owner = -1;
 #endif
+
+	err = kobject_init_and_add(&napi->kobj, &napi_ktype,
+				   &dev->dev.kobj, "napi%d", index);
+	if (err)
+		return err;
+
 	set_bit(NAPI_STATE_SCHED, &napi->state);
+	return 0;
 }
-EXPORT_SYMBOL(netif_napi_add);
+EXPORT_SYMBOL(netif_napi_init);
 
 void netif_napi_del(struct napi_struct *napi)
 {
@@ -2960,6 +2982,8 @@ void netif_napi_del(struct napi_struct *
 
 	napi->gro_list = NULL;
 	napi->gro_count = 0;
+
+	kobject_put(&napi->kobj);
 }
 EXPORT_SYMBOL(netif_napi_del);
 




