From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 02/11] IB/ipoib: Return IPoIB devices matching connection parameters
Date: Mon, 15 Jun 2015 11:47:07 +0300
Message-ID: <1434358036-15526-3-git-send-email-haggaie@mellanox.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434358036-15526-1-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Implement the get_net_device_by_port_pkey_ip callback that returns network
device to ib_core according to connection parameters. Check the ipoib
device and iterate over all child devices to look for a match.

For each IPoIB device we iterate through all upper devices when searching
for a matching IP, in order to support bonding.

Signed-off-by: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 141 +++++++++++++++++++++++++++++-
 1 file changed, 140 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index da149c278cb8..15af32665a87 100644
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
+static struct net_device *ipoib_get_net_dev_by_params(
+		struct ib_device *dev, u8 port, u16 pkey,
+		const union ib_gid *gid, const struct sockaddr *addr);
 
 static struct ib_client ipoib_client = {
 	.name   = "ipoib",
 	.add    = ipoib_add_one,
-	.remove = ipoib_remove_one
+	.remove = ipoib_remove_one,
+	.get_net_dev_by_params = ipoib_get_net_dev_by_params,
 };
 
 int ipoib_open(struct net_device *dev)
@@ -222,6 +229,138 @@ static int ipoib_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+/* Called with an RCU read lock taken */
+static bool ipoib_is_dev_match_addr(const struct sockaddr *addr,
+				    struct net_device *dev)
+{
+	struct net *net = dev_net(dev);
+	struct in_device *in_dev;
+	struct sockaddr_in *addr_in = (struct sockaddr_in *)addr;
+	struct sockaddr_in6 *addr_in6 = (struct sockaddr_in6 *)addr;
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
+	case AF_INET6:
+		if (IS_ENABLED(CONFIG_IPV6) &&
+		    ipv6_chk_addr(net, &addr_in6->sin6_addr, dev, 1))
+			return true;
+
+		break;
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
+static struct net_device *ipoib_get_net_dev_match_addr(
+		const struct sockaddr *addr, struct net_device *dev)
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
+static struct net_device *ipoib_match_gid_pkey_addr(struct ipoib_dev_priv *priv,
+						    const union ib_gid *gid,
+						    u16 pkey_index,
+						    const struct sockaddr *addr)
+{
+	struct ipoib_dev_priv *child_priv;
+	struct net_device *net_dev = NULL;
+
+	if (priv->pkey_index == pkey_index &&
+	    (!gid || !memcmp(gid, &priv->local_gid, sizeof(*gid)))) {
+		net_dev = ipoib_get_net_dev_match_addr(addr, priv->dev);
+		if (net_dev)
+			return net_dev;
+	}
+
+	/* Check child interfaces */
+	down_read(&priv->vlan_rwsem);
+	list_for_each_entry(child_priv, &priv->child_intfs, list) {
+		net_dev = ipoib_match_gid_pkey_addr(child_priv, gid,
+						    pkey_index, addr);
+		if (net_dev)
+			break;
+	}
+	up_read(&priv->vlan_rwsem);
+
+	return net_dev;
+}
+
+static struct net_device *ipoib_get_net_dev_by_params(
+		struct ib_device *dev, u8 port, u16 pkey,
+		const union ib_gid *gid, const struct sockaddr *addr)
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
+		net_dev = ipoib_match_gid_pkey_addr(priv, gid, pkey_index,
+						    addr);
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
