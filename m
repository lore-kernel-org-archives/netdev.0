From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v3 for-next 02/13] IB/addr: Pass network namespace as a parameter
Date: Sun, 10 May 2015 13:26:33 +0300
Message-ID: <1431253604-9214-3-git-send-email-haggaie@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:49332 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752493AbbEJK1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 06:27:19 -0400
In-Reply-To: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guy Shapiro <guysh@mellanox.com>

Add network namespace support to the ib_addr module. For that, all the
address resolution and matching should be done using the appropriate
namespace instead of init_net.

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
 drivers/infiniband/core/addr.c | 18 ++++++++++--------
 drivers/infiniband/core/cma.c  |  1 +
 include/rdma/ib_addr.h         | 16 +++++++++++++++-
 3 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index f80da50d84a5..5998dd11256d 100644
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
@@ -138,7 +138,7 @@ int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr,
 
 	switch (addr->sa_family) {
 	case AF_INET:
-		dev = ip_dev_find(&init_net,
+		dev = ip_dev_find(dev_addr->net,
 			((struct sockaddr_in *) addr)->sin_addr.s_addr);
 
 		if (!dev)
@@ -149,12 +149,11 @@ int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr,
 			*vlan_id = rdma_vlan_dev_vlan_id(dev);
 		dev_put(dev);
 		break;
-
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
@@ -236,7 +235,7 @@ static int addr4_resolve(struct sockaddr_in *src_in,
 	fl4.daddr = dst_ip;
 	fl4.saddr = src_ip;
 	fl4.flowi4_oif = addr->bound_dev_if;
-	rt = ip_route_output_key(&init_net, &fl4);
+	rt = ip_route_output_key(addr->net, &fl4);
 	if (IS_ERR(rt)) {
 		ret = PTR_ERR(rt);
 		goto out;
@@ -278,12 +277,13 @@ static int addr6_resolve(struct sockaddr_in6 *src_in,
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
@@ -481,6 +481,7 @@ int rdma_addr_find_dmac_by_grh(union ib_gid *sgid, union ib_gid *dgid, u8 *dmac,
 		return ret;
 
 	memset(&dev_addr, 0, sizeof(dev_addr));
+	dev_addr.net = &init_net;
 
 	ctx.addr = &dev_addr;
 	init_completion(&ctx.comp);
@@ -517,6 +518,7 @@ int rdma_addr_find_smac_by_sgid(union ib_gid *sgid, u8 *smac, u16 *vlan_id)
 	if (ret)
 		return ret;
 	memset(&dev_addr, 0, sizeof(dev_addr));
+	dev_addr.net = &init_net;
 	ret = rdma_translate_ip(&gid_addr._sockaddr, &dev_addr, vlan_id);
 	if (ret)
 		return ret;
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 5dcc61833557..c06d181d69c4 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -524,6 +524,7 @@ struct rdma_cm_id *rdma_create_id(rdma_cm_event_handler event_handler,
 	INIT_LIST_HEAD(&id_priv->listen_list);
 	INIT_LIST_HEAD(&id_priv->mc_list);
 	get_random_bytes(&id_priv->seq_num, sizeof id_priv->seq_num);
+	id_priv->id.route.addr.dev_addr.net = &init_net;
 
 	return &id_priv->id;
 }
diff --git a/include/rdma/ib_addr.h b/include/rdma/ib_addr.h
index ce55906b54a0..7d7831de2040 100644
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
-- 
1.7.11.2
