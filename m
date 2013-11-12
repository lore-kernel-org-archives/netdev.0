From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v3 5/10] bonding: create bond_first_slave_rcu()
Date: Tue, 12 Nov 2013 14:55:12 +0800
Message-ID: <5281D0D0.9040704@huawei.com>
References: <5280CF59.5090202@huawei.com> <20131111125917.GX19702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:48102 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407Ab3KLHB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 02:01:59 -0500
In-Reply-To: <20131111125917.GX19702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/11 20:59, Veaceslav Falico wrote:
> On Mon, Nov 11, 2013 at 08:36:41PM +0800, Ding Tianhong wrote:
>> The bond_first_slave_rcu() will be used to instead of bond_first_slave()
>> in rcu_read_lock().
>>
>> So move the struct netdev_adjacent to the netdevice.h and make the
>> bond_first_slave_rcu() could use the struct.
> 
> The whole point in netdev_adjacent functions was to hide it from the users
> who wanted to use it directly. See
> 
> http://www.spinics.net/lists/netdev/msg248026.html
> 
> for reference. Please try to avoid that.
> 
Hi, Veaceslav
following the point, I rebuild the bond_first_slave_rcu(),
if you have no comments, I will move it in the patch set.

Regards
Ding

+/* Caller must have rcu_read_lock */
+#define bond_first_slave_rcu(bond) \
+       netdev_lower_get_first_private_rcu(bond->dev)
+
 #define bond_is_first_slave(bond, pos) (pos == bond_first_slave(bond))
 #define bond_is_last_slave(bond, pos) (pos == bond_last_slave(bond))

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 15fa01c..abfcfad 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2869,6 +2869,7 @@ void *netdev_lower_get_next_private_rcu(struct net_device *dev,
             priv = netdev_lower_get_next_private_rcu(dev, &(iter)))

 void *netdev_adjacent_get_private(struct list_head *adj_list);
+void *netdev_lower_get_first_private_rcu(struct net_device *dev);
 struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
 struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
 int netdev_upper_dev_link(struct net_device *dev, struct net_device *upper_dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 8ffc52e..39bc202 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4570,6 +4570,27 @@ void *netdev_lower_get_next_private_rcu(struct net_device *dev,
 EXPORT_SYMBOL(netdev_lower_get_next_private_rcu);

 /**
+ * netdev_lower_get_first_private_rcu - Get the first ->private from the
+ *                                    lower neighbour list, RCU
+ *                                    variant
+ * @dev: device
+ *
+ * Gets the first netdev_adjacent->private from the dev's lower neighbour
+ * list. The caller must hold RCU read lock.
+ */
+void *netdev_lower_get_first_private_rcu(struct net_device *dev)
+{
+       struct netdev_adjacent *lower;
+
+       lower = list_first_or_null_rcu(&dev->adj_list.lower,
+                       struct netdev_adjacent, list);
+       if (lower)
+               return lower->private;
+       return NULL;
+}
+EXPORT_SYMBOL(netdev_lower_get_first_private_rcu);
