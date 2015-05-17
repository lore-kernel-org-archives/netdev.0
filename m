From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v4 for-next 04/12] IB/ipoib: Return IPoIB devices matching connection parameters
Date: Sun, 17 May 2015 08:51:00 +0300
Message-ID: <1431841868-28063-5-git-send-email-haggaie@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:34479 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751819AbbEQFwL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2015 01:52:11 -0400
In-Reply-To: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guy Shapiro <guysh@mellanox.com>

Implement the get_net_device_by_port_pkey_ip callback that returns network
device to ib_core according to connection parameters. Check the ipoib
device and iterate over all child devices to look for a match.

For each ipoib device we iterate through all upper devices when searching
for a matching IP, in order to support bonding.

Signed-off-by: Guy Shapiro <guysh@mellanox.com>
Signed-off-by: Haggai Eran <haggaie@mellanox.com>
Signed-off-by: Yotam Kenneth <yotamke@mellanox.com>
Signed-off-by: Shachar Raindel <raindel@mellanox.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 139 +++++++++++++++++++++++++++++-
 1 file changed, 138 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 3421e42870c3..75def39a4271 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -48,6 +48,9 @@
 
 #include <linux/jhash.h>
 #include <net/arp.h>
+#include <net/addrconf.h>
+#include <linux/inetdevice.h>
+#include <rdma/ib_cache.h>
 
 #define DRV_VERSION "1.0.0"
 
@@ -91,11 +94,15 @@ struct ib_sa_client ipoib_sa_client;
 static void ipoib_add_one(struct ib_device *device);
 static void ipoib_remove_one(struct ib_device *device);
 static void ipoib_neigh_reclaim(struct rcu_head *rp);
+static struct net_device *ipoib_get_net_device_by_port_pkey_ip(
+		struct ib_device *dev, u8 port, u16 pkey,
+		struct sockaddr *addr);
 
 static struct ib_client ipoib_client = {
 	.name   = "ipoib",
 	.add    = ipoib_add_one,
-	.remove = ipoib_remove_one
+	.remove = ipoib_remove_one,
+	.get_net_device_by_port_pkey_ip = ipoib_get_net_device_by_port_pkey_ip,
 };
 
 int ipoib_open(struct net_device *dev)
@@ -222,6 +229,136 @@ static int ipoib_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+/* Called with an RCU read lock taken */
+static bool ipoib_is_dev_match_addr(struct sockaddr *addr,
+				    struct net_device *dev)
+{
+	struct net *net = dev_net(dev);
+	struct in_device *in_dev;
+	struct sockaddr_in *addr_in = (struct sockaddr_in *)addr;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct sockaddr_in6 *addr_in6 = (struct sockaddr_in6 *)addr;
+#endif
+	__be32 ret_addr;
+
+	switch (addr->sa_family) {
+	case AF_INET:
+		in_dev = in_dev_get(dev);
+		if (!in_dev)
+			return false;
+
+		ret_addr = inet_confirm_addr(net, in_dev, 0,
+					     addr_in->sin_addr.s_addr,
+					     RT_SCOPE_HOST);
+		in_dev_put(in_dev);
+		if (ret_addr)
+			return true;
+
+		break;
+#if IS_ENABLED(CONFIG_IPV6)
+	case AF_INET6:
+		if (ipv6_chk_addr(net, &addr_in6->sin6_addr, dev, 1))
+			return true;
+
+		break;
+#endif
+	}
+	return false;
+}
+
+/**
+ * Find a net_device matching the given address, which is an upper device of
+ * the given net_device.
+ * @addr: IP address to look for.
+ * @dev: base IPoIB net_device
+ *
+ * If found, returns the net_device with a reference held. Otherwise return
+ * NULL.
+ */
+static struct net_device *ipoib_get_net_dev_match_addr(struct sockaddr *addr,
+						       struct net_device *dev)
+{
+	struct net_device *upper,
+			  *result = NULL;
+	struct list_head *iter;
+
+	rcu_read_lock();
+	if (ipoib_is_dev_match_addr(addr, dev)) {
+		dev_hold(dev);
+		result = dev;
+		goto out;
+	}
+
+	netdev_for_each_all_upper_dev_rcu(dev, upper, iter) {
+		if (ipoib_is_dev_match_addr(addr, upper)) {
+			dev_hold(upper);
+			result = upper;
+			break;
+		}
+	}
+out:
+	rcu_read_unlock();
+	return result;
+}
+
+/* returns an IPoIB netdev on top a given ipoib device matching a pkey_index
+ * and address, if one exists. */
+static struct net_device *ipoib_match_pkey_addr(struct ipoib_dev_priv *priv,
+						u16 pkey_index,
+						struct sockaddr *addr)
+{
+	struct ipoib_dev_priv *child_priv;
+	struct net_device *net_dev = NULL;
+
+	if (priv->pkey_index == pkey_index) {
+		net_dev = ipoib_get_net_dev_match_addr(addr, priv->dev);
+		if (net_dev)
+			return net_dev;
+	}
+
+	/* Check child interfaces */
+	down_read(&priv->vlan_rwsem);
+	list_for_each_entry(child_priv, &priv->child_intfs, list) {
+		net_dev = ipoib_match_pkey_addr(child_priv, pkey_index, addr);
+		if (net_dev)
+			break;
+	}
+	up_read(&priv->vlan_rwsem);
+
+	return net_dev;
+}
+
+static struct net_device *ipoib_get_net_device_by_port_pkey_ip(
+		struct ib_device *dev, u8 port, u16 pkey, struct sockaddr *addr)
+{
+	struct ipoib_dev_priv *priv;
+	struct list_head *dev_list;
+	struct net_device *net_dev;
+	u16 pkey_index;
+	int ret;
+
+	ret = ib_find_cached_pkey(dev, port, pkey, &pkey_index);
+	if (ret)
+		return NULL;
+
+	if (!rdma_protocol_ib(dev, port))
+		return NULL;
+
+	dev_list = ib_get_client_data(dev, &ipoib_client);
+	if (!dev_list)
+		return NULL;
+
+	list_for_each_entry(priv, dev_list, list) {
+		if (priv->port != port)
+			continue;
+
+		net_dev = ipoib_match_pkey_addr(priv, pkey_index, addr);
+		if (net_dev)
+			return net_dev;
+	}
+	return NULL;
+}
+
 int ipoib_set_mode(struct net_device *dev, const char *buf)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
-- 
1.7.11.2
