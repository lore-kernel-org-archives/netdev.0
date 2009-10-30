From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: Introduce dev_get_by_name_rcu()
Date: Fri, 30 Oct 2009 18:11:27 +0100
Message-ID: <4AEB1E3F.3010002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46911 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932108AbZJ3RL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 13:11:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some workloads hit dev_base_lock rwlock pretty hard.
We can use RCU lookups to avoid touching this rwlock
(and avoid touching netdevice refcount)

netdevices are already freed after a RCU grace period, so this patch
adds no penalty at device dismantle time.

However, it adds a synchronize_rcu() call in dev_change_name()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    1 
 net/core/dev.c            |   49 +++++++++++++++++++++++++++++-------
 2 files changed, 41 insertions(+), 9 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 193b637..86773e1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1115,6 +1115,7 @@ extern void		__dev_remove_pack(struct packet_type *pt);
 extern struct net_device	*dev_get_by_flags(struct net *net, unsigned short flags,
 						  unsigned short mask);
 extern struct net_device	*dev_get_by_name(struct net *net, const char *name);
+extern struct net_device	*dev_get_by_name_rcu(struct net *net, const char *name);
 extern struct net_device	*__dev_get_by_name(struct net *net, const char *name);
 extern int		dev_alloc_name(struct net_device *dev, const char *name);
 extern int		dev_open(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 94f42a1..f54d8b8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -213,7 +213,7 @@ static int list_netdevice(struct net_device *dev)
 
 	write_lock_bh(&dev_base_lock);
 	list_add_tail(&dev->dev_list, &net->dev_base_head);
-	hlist_add_head(&dev->name_hlist, dev_name_hash(net, dev->name));
+	hlist_add_head_rcu(&dev->name_hlist, dev_name_hash(net, dev->name));
 	hlist_add_head_rcu(&dev->index_hlist,
 			   dev_index_hash(net, dev->ifindex));
 	write_unlock_bh(&dev_base_lock);
@@ -230,7 +230,7 @@ static void unlist_netdevice(struct net_device *dev)
 	/* Unlink dev from the device chain */
 	write_lock_bh(&dev_base_lock);
 	list_del(&dev->dev_list);
-	hlist_del(&dev->name_hlist);
+	hlist_del_rcu(&dev->name_hlist);
 	hlist_del_rcu(&dev->index_hlist);
 	write_unlock_bh(&dev_base_lock);
 }
@@ -599,6 +599,32 @@ struct net_device *__dev_get_by_name(struct net *net, const char *name)
 EXPORT_SYMBOL(__dev_get_by_name);
 
 /**
+ *	dev_get_by_name_rcu	- find a device by its name
+ *	@net: the applicable net namespace
+ *	@name: name to find
+ *
+ *	Find an interface by name.
+ *	If the name is found a pointer to the device is returned.
+ * 	If the name is not found then %NULL is returned.
+ *	The reference counters are not incremented so the caller must be
+ *	careful with locks. The caller must hold RCU lock.
+ */
+
+struct net_device *dev_get_by_name_rcu(struct net *net, const char *name)
+{
+	struct hlist_node *p;
+	struct net_device *dev;
+	struct hlist_head *head = dev_name_hash(net, name);
+
+	hlist_for_each_entry_rcu(dev, p, head, name_hlist)
+		if (!strncmp(dev->name, name, IFNAMSIZ))
+			return dev;
+
+	return NULL;
+}
+EXPORT_SYMBOL(dev_get_by_name_rcu);
+
+/**
  *	dev_get_by_name		- find a device by its name
  *	@net: the applicable net namespace
  *	@name: name to find
@@ -614,11 +640,11 @@ struct net_device *dev_get_by_name(struct net *net, const char *name)
 {
 	struct net_device *dev;
 
-	read_lock(&dev_base_lock);
-	dev = __dev_get_by_name(net, name);
+	rcu_read_lock();
+	dev = dev_get_by_name_rcu(net, name);
 	if (dev)
 		dev_hold(dev);
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 	return dev;
 }
 EXPORT_SYMBOL(dev_get_by_name);
@@ -960,7 +986,12 @@ rollback:
 
 	write_lock_bh(&dev_base_lock);
 	hlist_del(&dev->name_hlist);
-	hlist_add_head(&dev->name_hlist, dev_name_hash(net, dev->name));
+	write_unlock_bh(&dev_base_lock);
+
+	synchronize_rcu();
+
+	write_lock_bh(&dev_base_lock);
+	hlist_add_head_rcu(&dev->name_hlist, dev_name_hash(net, dev->name));
 	write_unlock_bh(&dev_base_lock);
 
 	ret = call_netdevice_notifiers(NETDEV_CHANGENAME, dev);
@@ -1062,9 +1093,9 @@ void dev_load(struct net *net, const char *name)
 {
 	struct net_device *dev;
 
-	read_lock(&dev_base_lock);
-	dev = __dev_get_by_name(net, name);
-	read_unlock(&dev_base_lock);
+	rcu_read_lock();
+	dev = dev_get_by_name_rcu(net, name);
+	rcu_read_unlock();
 
 	if (!dev && capable(CAP_NET_ADMIN))
 		request_module("%s", name);

