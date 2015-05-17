From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v4 for-next 03/12] IB/core: Find the network namespace matching connection parameters
Date: Sun, 17 May 2015 08:50:59 +0300
Message-ID: <1431841868-28063-4-git-send-email-haggaie@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:34449 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751282AbbEQFvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2015 01:51:44 -0400
In-Reply-To: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Kenneth <yotamke@mellanox.com>

In the case of IPoIB, and maybe in other cases, the network device is
managed by an upper-layer protocol (ULP). In order to expose this
network device to other users of the IB device, let ULPs implement
a callback that returns network device according to connection parameters.

The IB device and port, together with the P_Key and the IP address should
be enough to uniquely identify the ULP net device.

This function is passed to ib_core as part of the ib_client
registration.

Using this functionality, add a way to get the network namespace
corresponding to a work completion. This is needed so that responses to CM
requests can be sent from the same network namespace as the request.

Signed-off-by: Haggai Eran <haggaie@mellanox.com>
Signed-off-by: Yotam Kenneth <yotamke@mellanox.com>
Signed-off-by: Shachar Raindel <raindel@mellanox.com>
Signed-off-by: Guy Shapiro <guysh@mellanox.com>
---
 drivers/infiniband/core/device.c | 52 ++++++++++++++++++++++++++++++++++++++++
 include/rdma/ib_verbs.h          | 33 +++++++++++++++++++++++++
 2 files changed, 85 insertions(+)

diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index 3a44723c6b9d..be184f9feab2 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -38,6 +38,7 @@
 #include <linux/slab.h>
 #include <linux/init.h>
 #include <linux/mutex.h>
+#include <linux/netdevice.h>
 #include <rdma/rdma_netlink.h>
 
 #include "core_priv.h"
@@ -748,6 +749,57 @@ int ib_find_pkey(struct ib_device *device,
 }
 EXPORT_SYMBOL(ib_find_pkey);
 
+static struct net_device *ib_get_net_dev_by_port_pkey_ip(struct ib_device *dev,
+							 u8 port,
+							 u16 pkey,
+							 struct sockaddr *addr)
+{
+	struct net_device *ret = NULL;
+	struct ib_client *client;
+
+	down_read(&lists_rwsem);
+
+	list_for_each_entry_rcu(client, &client_list, list)
+		if (client->get_net_device_by_port_pkey_ip) {
+			ret = client->get_net_device_by_port_pkey_ip(dev, port,
+								     pkey,
+								     addr);
+			if (ret)
+				break;
+		}
+
+	up_read(&lists_rwsem);
+
+	return ret;
+}
+
+struct net *ib_get_net_ns_by_port_pkey_ip(struct ib_device *dev,
+					  u8 port,
+					  u16 pkey,
+					  struct sockaddr *addr)
+{
+	struct net_device *ndev = NULL;
+	struct net *ns;
+
+	if (rdma_protocol_ib(dev, port))
+		ndev = ib_get_net_dev_by_port_pkey_ip(dev, port, pkey, addr);
+
+	if (!ndev)
+		goto not_found;
+
+	rcu_read_lock();
+	ns = maybe_get_net(dev_net(ndev));
+	dev_put(ndev);
+	rcu_read_unlock();
+	if (!ns)
+		goto not_found;
+	return ns;
+
+not_found:
+	return get_net(&init_net);
+}
+EXPORT_SYMBOL(ib_get_net_ns_by_port_pkey_ip);
+
 static int __init ib_core_init(void)
 {
 	int ret;
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 8d59479eea4d..76093a33ed46 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -48,6 +48,7 @@
 #include <linux/rwsem.h>
 #include <linux/scatterlist.h>
 #include <linux/workqueue.h>
+#include <linux/socket.h>
 #include <uapi/linux/if_ether.h>
 
 #include <linux/atomic.h>
@@ -1691,6 +1692,24 @@ struct ib_client {
 	void (*add)   (struct ib_device *);
 	void (*remove)(struct ib_device *);
 
+	/* Returns the net_dev belonging to this ib_client and matching the
+	 * given parameters.
+	 * @dev:	An RDMA device that the net_dev use for communication.
+	 * @port:	A physical port number on the RDMA device.
+	 * @pkey:	P_Key that the net_dev uses if applicable.
+	 * @addr:	An IP address the net_dev is configured with.
+	 *
+	 * An ib_client that implements a net_dev on top of RDMA devices
+	 * (such as IP over IB) should implement this callback, allowing the
+	 * rdma_cm module to find the right net_dev for a given request.
+	 *
+	 * The caller is responsible for calling dev_put on the returned
+	 * netdev. */
+	struct net_device *(*get_net_device_by_port_pkey_ip)(
+			struct ib_device *dev,
+			u8 port,
+			u16 pkey,
+			struct sockaddr *addr);
 	struct list_head list;
 };
 
@@ -2835,4 +2854,18 @@ static inline int ib_check_mr_access(int flags)
 int ib_check_mr_status(struct ib_mr *mr, u32 check_mask,
 		       struct ib_mr_status *mr_status);
 
+/**
+ * ib_get_net_ns_by_port_pkey_ip() - Return the appropriate net namespace
+ * for a received CM request
+ * @dev:	An RDMA device on which the request has been received.
+ * @port:	Port number on the RDMA device.
+ * @pkey:	The Pkey the request came on.
+ * @addr:	Contains the IP address that the request specified as its
+ *		destination.
+ */
+struct net *ib_get_net_ns_by_port_pkey_ip(struct ib_device *dev,
+					  u8 port,
+					  u16 pkey,
+					  struct sockaddr *addr);
+
 #endif /* IB_VERBS_H */
-- 
1.7.11.2
