From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: Introduce dev_get_by_index_rcu()
Date: Tue, 20 Oct 2009 07:03:44 +0200
Message-ID: <4ADD44B0.8030204@gmail.com>
References: <4ADD3794.8030906@gmail.com>	<20091019.212018.79580287.davem@davemloft.net>	<4ADD3B5A.1080905@gmail.com> <20091019.212855.179405364.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52883 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274AbZJTFDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 01:03:41 -0400
In-Reply-To: <20091019.212855.179405364.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 20 Oct 2009 06:23:54 +0200
>=20
>> I wonder if the whole thing could use RCU somehow, since some
>> workloads hit this dev_base_lock rwlock pretty hard...
>=20
> True, but for now we'll put your fix in :-)

[PATCH net-next-2.6] net: Introduce dev_get_by_index_rcu()

Some workloads hit dev_base_lock rwlock pretty hard.
We can use RCU lookups to avoid touching this rwlock.

netdevices are already freed after a RCU grace period, so this patch
adds no penalty at device dismantle time.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    1
 net/core/dev.c            |   40 ++++++++++++++++++++++++++++++------
 2 files changed, 35 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8380009..4eda680 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1127,6 +1127,7 @@ extern void		netdev_resync_ops(struct net_device =
*dev);
 extern int call_netdevice_notifiers(unsigned long val, struct net_devi=
ce *dev);
 extern struct net_device	*dev_get_by_index(struct net *net, int ifinde=
x);
 extern struct net_device	*__dev_get_by_index(struct net *net, int ifin=
dex);
+extern struct net_device	*dev_get_by_index_rcu(struct net *net, int if=
index);
 extern int		dev_restart(struct net_device *dev);
 #ifdef CONFIG_NETPOLL_TRAP
 extern int		netpoll_trap(void);
diff --git a/net/core/dev.c b/net/core/dev.c
index 28b0b9e..cb011b7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -217,12 +217,15 @@ static int list_netdevice(struct net_device *dev)
 	write_lock_bh(&dev_base_lock);
 	list_add_tail(&dev->dev_list, &net->dev_base_head);
 	hlist_add_head(&dev->name_hlist, dev_name_hash(net, dev->name));
-	hlist_add_head(&dev->index_hlist, dev_index_hash(net, dev->ifindex));
+	hlist_add_head_rcu(&dev->index_hlist,
+			   dev_index_hash(net, dev->ifindex));
 	write_unlock_bh(&dev_base_lock);
 	return 0;
 }
=20
-/* Device list removal */
+/* Device list removal
+ * caller must respect a RCU grace period before freeing/reusing dev
+ */
 static void unlist_netdevice(struct net_device *dev)
 {
 	ASSERT_RTNL();
@@ -231,7 +234,7 @@ static void unlist_netdevice(struct net_device *dev=
)
 	write_lock_bh(&dev_base_lock);
 	list_del(&dev->dev_list);
 	hlist_del(&dev->name_hlist);
-	hlist_del(&dev->index_hlist);
+	hlist_del_rcu(&dev->index_hlist);
 	write_unlock_bh(&dev_base_lock);
 }
=20
@@ -649,6 +652,31 @@ struct net_device *__dev_get_by_index(struct net *=
net, int ifindex)
 }
 EXPORT_SYMBOL(__dev_get_by_index);
=20
+/**
+ *	dev_get_by_index_rcu - find a device by its ifindex
+ *	@net: the applicable net namespace
+ *	@ifindex: index of device
+ *
+ *	Search for an interface by index. Returns %NULL if the device
+ *	is not found or a pointer to the device. The device has not
+ *	had its reference counter increased so the caller must be careful
+ *	about locking. The caller must hold RCU lock.
+ */
+
+struct net_device *dev_get_by_index_rcu(struct net *net, int ifindex)
+{
+	struct hlist_node *p;
+	struct net_device *dev;
+	struct hlist_head *head =3D dev_index_hash(net, ifindex);
+
+	hlist_for_each_entry_rcu(dev, p, head, index_hlist)
+		if (dev->ifindex =3D=3D ifindex)
+			return dev;
+
+	return NULL;
+}
+EXPORT_SYMBOL(dev_get_by_index_rcu);
+
=20
 /**
  *	dev_get_by_index - find a device by its ifindex
@@ -665,11 +693,11 @@ struct net_device *dev_get_by_index(struct net *n=
et, int ifindex)
 {
 	struct net_device *dev;
=20
-	read_lock(&dev_base_lock);
-	dev =3D __dev_get_by_index(net, ifindex);
+	rcu_read_lock();
+	dev =3D dev_get_by_index_rcu(net, ifindex);
 	if (dev)
 		dev_hold(dev);
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 	return dev;
 }
 EXPORT_SYMBOL(dev_get_by_index);
