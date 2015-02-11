From: Shachar Raindel <raindel@mellanox.com>
Subject: [PATCH v1 01/10] IB/addr: Pass network namespace as a parameter
Date: Wed, 11 Feb 2015 17:06:35 +0200
Message-ID: <1423667204-8807-2-git-send-email-raindel@mellanox.com>
References: <1423667204-8807-1-git-send-email-raindel@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.com, guysh@mellanox.com, haggaie@mellanox.com,
	yotamke@mellanox.com, raindel@mellanox.com
To: roland@kernel.org, sean.hefty@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:53598 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753641AbbBKPKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2015 10:10:37 -0500
In-Reply-To: <1423667204-8807-1-git-send-email-raindel@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guy Shapiro <guysh@mellanox.com>

Add network namespace support to the ib_addr module. For that, all the address
resolution and matching should be done using the appropriate namespace instead
of init_net.

This is achieved by:

1. Adding an explicit network namespace argument to exported function that
   require a namespace.
2. Saving the namespace in the rdma_addr_client structure.
3. Using it when calling networking functions.

In order to preserve the behavior of calling modules, &init_net is
passed as the parameter in calls from other modules. This is modified as
namespace support is added on more levels.

Signed-off-by: Haggai Eran <haggaie@mellanox.com>
Signed-off-by: Yotam Kenneth <yotamke@mellanox.com>
Signed-off-by: Shachar Raindel <raindel@mellanox.com>
Signed-off-by: Guy Shapiro <guysh@mellanox.com>

---
 drivers/infiniband/core/addr.c           | 31 ++++++++++++----------
 drivers/infiniband/core/cma.c            |  4 ++-
 drivers/infiniband/core/verbs.c          | 14 +++++++---
 drivers/infiniband/hw/ocrdma/ocrdma_ah.c |  3 ++-
 include/rdma/ib_addr.h                   | 44 ++++++++++++++++++++++++++++----
 5 files changed, 72 insertions(+), 24 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index f80da50..95beaef 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -128,7 +128,7 @@ int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr,
 	int ret = -EADDRNOTAVAIL;
 
 	if (dev_addr->bound_dev_if) {
-		dev = dev_get_by_index(&init_net, dev_addr->bound_dev_if);
+		dev = dev_get_by_index(dev_addr->net, dev_addr->bound_dev_if);
 		if (!dev)
 			return -ENODEV;
 		ret = rdma_copy_addr(dev_addr, dev, NULL);
@@ -137,9 +137,10 @@ int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr,
 	}
 
 	switch (addr->sa_family) {
-	case AF_INET:
-		dev = ip_dev_find(&init_net,
-			((struct sockaddr_in *) addr)->sin_addr.s_addr);
+	case AF_INET: {
+		struct sockaddr_in *addr_in = (struct sockaddr_in *)addr;
+
+		dev = ip_dev_find(dev_addr->net, addr_in->sin_addr.s_addr);
 
 		if (!dev)
 			return ret;
@@ -149,12 +150,12 @@ int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr,
 			*vlan_id = rdma_vlan_dev_vlan_id(dev);
 		dev_put(dev);
 		break;
-
+	}
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
 		rcu_read_lock();
-		for_each_netdev_rcu(&init_net, dev) {
-			if (ipv6_chk_addr(&init_net,
+		for_each_netdev_rcu(dev_addr->net, dev) {
+			if (ipv6_chk_addr(dev_addr->net,
 					  &((struct sockaddr_in6 *) addr)->sin6_addr,
 					  dev, 1)) {
 				ret = rdma_copy_addr(dev_addr, dev, NULL);
@@ -236,7 +237,7 @@ static int addr4_resolve(struct sockaddr_in *src_in,
 	fl4.daddr = dst_ip;
 	fl4.saddr = src_ip;
 	fl4.flowi4_oif = addr->bound_dev_if;
-	rt = ip_route_output_key(&init_net, &fl4);
+	rt = ip_route_output_key(addr->net, &fl4);
 	if (IS_ERR(rt)) {
 		ret = PTR_ERR(rt);
 		goto out;
@@ -278,12 +279,13 @@ static int addr6_resolve(struct sockaddr_in6 *src_in,
 	fl6.saddr = src_in->sin6_addr;
 	fl6.flowi6_oif = addr->bound_dev_if;
 
-	dst = ip6_route_output(&init_net, NULL, &fl6);
+	dst = ip6_route_output(addr->net, NULL, &fl6);
 	if ((ret = dst->error))
 		goto put;
 
 	if (ipv6_addr_any(&fl6.saddr)) {
-		ret = ipv6_dev_get_saddr(&init_net, ip6_dst_idev(dst)->dev,
+		ret = ipv6_dev_get_saddr(addr->net,
+					 ip6_dst_idev(dst)->dev,
 					 &fl6.daddr, 0, &fl6.saddr);
 		if (ret)
 			goto put;
@@ -458,7 +460,7 @@ static void resolve_cb(int status, struct sockaddr *src_addr,
 }
 
 int rdma_addr_find_dmac_by_grh(union ib_gid *sgid, union ib_gid *dgid, u8 *dmac,
-			       u16 *vlan_id)
+			       u16 *vlan_id, struct net *net)
 {
 	int ret = 0;
 	struct rdma_dev_addr dev_addr;
@@ -481,6 +483,7 @@ int rdma_addr_find_dmac_by_grh(union ib_gid *sgid, union ib_gid *dgid, u8 *dmac,
 		return ret;
 
 	memset(&dev_addr, 0, sizeof(dev_addr));
+	dev_addr.net = net;
 
 	ctx.addr = &dev_addr;
 	init_completion(&ctx.comp);
@@ -492,7 +495,7 @@ int rdma_addr_find_dmac_by_grh(union ib_gid *sgid, union ib_gid *dgid, u8 *dmac,
 	wait_for_completion(&ctx.comp);
 
 	memcpy(dmac, dev_addr.dst_dev_addr, ETH_ALEN);
-	dev = dev_get_by_index(&init_net, dev_addr.bound_dev_if);
+	dev = dev_get_by_index(net, dev_addr.bound_dev_if);
 	if (!dev)
 		return -ENODEV;
 	if (vlan_id)
@@ -502,7 +505,8 @@ int rdma_addr_find_dmac_by_grh(union ib_gid *sgid, union ib_gid *dgid, u8 *dmac,
 }
 EXPORT_SYMBOL(rdma_addr_find_dmac_by_grh);
 
-int rdma_addr_find_smac_by_sgid(union ib_gid *sgid, u8 *smac, u16 *vlan_id)
+int rdma_addr_find_smac_by_sgid(union ib_gid *sgid, u8 *smac, u16 *vlan_id,
+				struct net *net)
 {
 	int ret = 0;
 	struct rdma_dev_addr dev_addr;
@@ -517,6 +521,7 @@ int rdma_addr_find_smac_by_sgid(union ib_gid *sgid, u8 *smac, u16 *vlan_id)
 	if (ret)
 		return ret;
 	memset(&dev_addr, 0, sizeof(dev_addr));
+	dev_addr.net = net;
 	ret = rdma_translate_ip(&gid_addr._sockaddr, &dev_addr, vlan_id);
 	if (ret)
 		return ret;
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 6e5e11c..aeb2417 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -512,6 +512,7 @@ struct rdma_cm_id *rdma_create_id(rdma_cm_event_handler event_handler,
 	INIT_LIST_HEAD(&id_priv->listen_list);
 	INIT_LIST_HEAD(&id_priv->mc_list);
 	get_random_bytes(&id_priv->seq_num, sizeof id_priv->seq_num);
+	id_priv->id.route.addr.dev_addr.net = &init_net;
 
 	return &id_priv->id;
 }
@@ -637,7 +638,8 @@ static int cma_modify_qp_rtr(struct rdma_id_private *id_priv,
 	    == RDMA_TRANSPORT_IB &&
 	    rdma_port_get_link_layer(id_priv->id.device, id_priv->id.port_num)
 	    == IB_LINK_LAYER_ETHERNET) {
-		ret = rdma_addr_find_smac_by_sgid(&sgid, qp_attr.smac, NULL);
+		ret = rdma_addr_find_smac_by_sgid(&sgid, qp_attr.smac, NULL,
+						  &init_net);
 
 		if (ret)
 			goto out;
diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index f93eb8d..ca5c4dd 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -212,7 +212,9 @@ int ib_init_ah_from_wc(struct ib_device *device, u8 port_num, struct ib_wc *wc,
 			ah_attr->vlan_id = wc->vlan_id;
 		} else {
 			ret = rdma_addr_find_dmac_by_grh(&grh->dgid, &grh->sgid,
-					ah_attr->dmac, &ah_attr->vlan_id);
+							 ah_attr->dmac,
+							 &ah_attr->vlan_id,
+							 &init_net);
 			if (ret)
 				return ret;
 		}
@@ -882,11 +884,15 @@ int ib_resolve_eth_l2_attrs(struct ib_qp *qp,
 			if (!(*qp_attr_mask & IB_QP_VID))
 				qp_attr->vlan_id = rdma_get_vlan_id(&sgid);
 		} else {
-			ret = rdma_addr_find_dmac_by_grh(&sgid, &qp_attr->ah_attr.grh.dgid,
-					qp_attr->ah_attr.dmac, &qp_attr->vlan_id);
+			ret = rdma_addr_find_dmac_by_grh(
+				&sgid,
+				&qp_attr->ah_attr.grh.dgid,
+				qp_attr->ah_attr.dmac, &qp_attr->vlan_id,
+				&init_net);
 			if (ret)
 				goto out;
-			ret = rdma_addr_find_smac_by_sgid(&sgid, qp_attr->smac, NULL);
+			ret = rdma_addr_find_smac_by_sgid(&sgid, qp_attr->smac,
+							  NULL, &init_net);
 			if (ret)
 				goto out;
 		}
diff --git a/drivers/infiniband/hw/ocrdma/ocrdma_ah.c b/drivers/infiniband/hw/ocrdma/ocrdma_ah.c
index f3cc8c9..debaac2 100644
--- a/drivers/infiniband/hw/ocrdma/ocrdma_ah.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_ah.c
@@ -119,7 +119,8 @@ struct ib_ah *ocrdma_create_ah(struct ib_pd *ibpd, struct ib_ah_attr *attr)
 
 	if (pd->uctx) {
 		status = rdma_addr_find_dmac_by_grh(&sgid, &attr->grh.dgid,
-                                        attr->dmac, &attr->vlan_id);
+						    attr->dmac, &attr->vlan_id,
+						    &init_net);
 		if (status) {
 			pr_err("%s(): Failed to resolve dmac from gid." 
 				"status = %d\n", __func__, status);
diff --git a/include/rdma/ib_addr.h b/include/rdma/ib_addr.h
index ce55906..40ccf8b 100644
--- a/include/rdma/ib_addr.h
+++ b/include/rdma/ib_addr.h
@@ -47,6 +47,7 @@
 #include <rdma/ib_verbs.h>
 #include <rdma/ib_pack.h>
 #include <net/ipv6.h>
+#include <net/net_namespace.h>
 
 struct rdma_addr_client {
 	atomic_t refcount;
@@ -64,6 +65,16 @@ void rdma_addr_register_client(struct rdma_addr_client *client);
  */
 void rdma_addr_unregister_client(struct rdma_addr_client *client);
 
+/**
+ * struct rdma_dev_addr - Contains resolved RDMA hardware addresses
+ * @src_dev_addr:	Source MAC address.
+ * @dst_dev_addr:	Destination MAC address.
+ * @broadcast:		Broadcast address of the device.
+ * @dev_type:		The interface hardware type of the device.
+ * @bound_dev_if:	An optional device interface index.
+ * @transport:		The transport type used.
+ * @net:		Network namespace containing the bound_dev_if net_dev.
+ */
 struct rdma_dev_addr {
 	unsigned char src_dev_addr[MAX_ADDR_LEN];
 	unsigned char dst_dev_addr[MAX_ADDR_LEN];
@@ -71,11 +82,14 @@ struct rdma_dev_addr {
 	unsigned short dev_type;
 	int bound_dev_if;
 	enum rdma_transport_type transport;
+	struct net *net;
 };
 
 /**
  * rdma_translate_ip - Translate a local IP address to an RDMA hardware
  *   address.
+ *
+ * The dev_addr->net field must be initialized.
  */
 int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr,
 		      u16 *vlan_id);
@@ -90,7 +104,7 @@ int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr,
  * @dst_addr: The destination address to resolve.
  * @addr: A reference to a data location that will receive the resolved
  *   addresses.  The data location must remain valid until the callback has
- *   been invoked.
+ *   been invoked. The net field of the addr struct must be valid.
  * @timeout_ms: Amount of time to wait for the address resolution to complete.
  * @callback: Call invoked once address resolution has completed, timed out,
  *   or been canceled.  A status of 0 indicates success.
@@ -110,9 +124,29 @@ int rdma_copy_addr(struct rdma_dev_addr *dev_addr, struct net_device *dev,
 
 int rdma_addr_size(struct sockaddr *addr);
 
-int rdma_addr_find_smac_by_sgid(union ib_gid *sgid, u8 *smac, u16 *vlan_id);
-int rdma_addr_find_dmac_by_grh(union ib_gid *sgid, union ib_gid *dgid, u8 *smac,
-			       u16 *vlan_id);
+/** rdma_addr_find_smac_by_sgid() - Find the src MAC and VLAN ID for a src GID
+ * @sgid:	Source GID to find the MAC and VLAN for.
+ * @smac:	A buffer to contain the resulting MAC address.
+ * @vlan_id:	Will contain the resulting VLAN ID.
+ * @net:	Network namespace to use for the address resolution.
+ *
+ * It is the caller's responsibility to keep the network namespace alive until
+ * the function returns.
+ */
+int rdma_addr_find_smac_by_sgid(union ib_gid *sgid, u8 *smac, u16 *vlan_id,
+				struct net *net);
+/** rdma_addr_find_dmac_by_grh() - Find the dst MAC and VLAN ID for a GID pair
+ * @sgid:	Source GID to use for the search.
+ * @dgid:	Destination GID to find the details for.
+ * @dmac:	Contains the resulting destination MAC address.
+ * @vlan_id:	Contains the resulting VLAN ID.
+ * @net:	Network namespace to use for the address resolution.
+ *
+ * It is the caller's responsibility to keep the network namespace alive until
+ * the function returns.
+ */
+int rdma_addr_find_dmac_by_grh(union ib_gid *sgid, union ib_gid *dgid, u8 *dmac,
+			       u16 *vlan_id, struct net *net);
 
 static inline u16 ib_addr_get_pkey(struct rdma_dev_addr *dev_addr)
 {
@@ -182,7 +216,7 @@ static inline void iboe_addr_get_sgid(struct rdma_dev_addr *dev_addr,
 	struct net_device *dev;
 	struct in_device *ip4;
 
-	dev = dev_get_by_index(&init_net, dev_addr->bound_dev_if);
+	dev = dev_get_by_index(dev_addr->net, dev_addr->bound_dev_if);
 	if (dev) {
 		ip4 = (struct in_device *)dev->ip_ptr;
 		if (ip4 && ip4->ifa_list && ip4->ifa_list->ifa_address)
-- 
1.7.11.2
