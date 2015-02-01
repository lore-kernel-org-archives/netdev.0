From: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 04/10] IB/ipoib: Return IPoIB devices as possible matches to get_net_device_by_port_pkey_ip
Date: Sun,  1 Feb 2015 13:28:47 +0200
Message-ID: <1422790133-28725-5-git-send-email-raindel@mellanox.com>
References: <1422790133-28725-1-git-send-email-raindel@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422790133-28725-1-git-send-email-raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Implement callback that returns network device to ib_core according to
connection parameters. Check the ipoib device and iterate over all child
devices to look for a match.

For each ipoib device we iterate through all upper devices when searching for
a matching IP, in order to support bonding.

Signed-off-by: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

---
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 122 +++++++++++++++++++++++++++++-
 1 file changed, 121 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 6bad17d4d588..88fb78dd68c9 100644
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
@@ -222,6 +229,119 @@ static int ipoib_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+static bool ipoib_is_dev_match_addr(struct sockaddr *addr,
+				    struct net_device *dev)
+{
+	struct net *net = dev_net(dev);
+
+	if (addr->sa_family == AF_INET) {
+		struct in_device *in_dev = in_dev_get(dev);
+		struct sockaddr_in *addr_in = (struct sockaddr_in *)addr;
+		__be32 ret_addr;
+
+		if (!in_dev)
+			return false;
+
+		ret_addr = inet_confirm_addr(net, in_dev, 0,
+					     addr_in->sin_addr.s_addr,
+					     RT_SCOPE_HOST);
+		in_dev_put(in_dev);
+		if (ret_addr)
+			return true;
+	}
+#if IS_ENABLED(CONFIG_IPV6)
+	else if (addr->sa_family == AF_INET6) {
+		struct sockaddr_in6 *addr_in6 = (struct sockaddr_in6 *)addr;
+
+		if (ipv6_chk_addr(net, &addr_in6->sin6_addr, dev, 1))
+			return true;
+	}
+#endif
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
+	if (ipoib_is_dev_match_addr(addr, dev)) {
+		dev_hold(dev);
+		return dev;
+	}
+
+	rcu_read_lock();
+	netdev_for_each_all_upper_dev_rcu(dev, upper, iter) {
+		if (ipoib_is_dev_match_addr(addr, upper)) {
+			dev_hold(upper);
+			result = upper;
+			break;
+		}
+	}
+	rcu_read_unlock();
+	return result;
+}
+
+static struct net_device *ipoib_get_net_device_by_port_pkey_ip(
+		struct ib_device *dev, u8 port, u16 pkey, struct sockaddr *addr)
+{
+	struct ipoib_dev_priv *priv;
+	struct list_head *dev_list;
+	u16 pkey_index;
+
+	ib_find_cached_pkey(dev, port, pkey, &pkey_index);
+	if (pkey_index == (u16)-1)
+		return NULL;
+
+	if (rdma_node_get_transport(dev->node_type) != RDMA_TRANSPORT_IB)
+		return NULL;
+
+	dev_list = ib_get_client_data(dev, &ipoib_client);
+	if (!dev_list)
+		return NULL;
+
+	list_for_each_entry(priv, dev_list, list) {
+		struct net_device *net_dev = NULL;
+		struct ipoib_dev_priv *child_priv;
+
+		if (priv->port != port)
+			continue;
+
+		if (priv->pkey_index == pkey_index) {
+			net_dev = ipoib_get_net_dev_match_addr(addr, priv->dev);
+			if (net_dev)
+				return net_dev;
+		}
+
+		down_read(&priv->vlan_rwsem);
+		list_for_each_entry(child_priv,
+				    &priv->child_intfs, list) {
+			if (child_priv->pkey_index != pkey_index)
+				continue;
+
+			net_dev = ipoib_get_net_dev_match_addr(
+					addr, child_priv->dev);
+			if (net_dev)
+				break;
+		}
+		up_read(&priv->vlan_rwsem);
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
