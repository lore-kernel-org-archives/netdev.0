From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 01/11] IB/core: Find the network device matching connection parameters
Date: Mon, 15 Jun 2015 11:47:06 +0300
Message-ID: <1434358036-15526-2-git-send-email-haggaie@mellanox.com>
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

From: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

In the case of IPoIB, and maybe in other cases, the network device is
managed by an upper-layer protocol (ULP). In order to expose this
network device to other users of the IB device, let ULPs implement
a callback that returns network device according to connection parameters.

The IB device and port, together with the P_Key and the GID should
be enough to uniquely identify the ULP net device. However, in current
kernels there can be multiple IPoIB interfaces created with the same GID.
Furthermore, such configuration may be desireable to support ipvlan-like
configurations for RDMA CM with IPoIB.  To resolve the device in these
cases the code will also take the IP address as an additional input.

Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/device.c | 29 +++++++++++++++++++++++++++++
 include/rdma/ib_verbs.h          | 35 +++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+)

diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index f08d438205ed..300609e8f841 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -38,6 +38,7 @@
 #include <linux/slab.h>
 #include <linux/init.h>
 #include <linux/mutex.h>
+#include <linux/netdevice.h>
 #include <rdma/rdma_netlink.h>
 
 #include "core_priv.h"
@@ -746,6 +747,34 @@ int ib_find_pkey(struct ib_device *device,
 }
 EXPORT_SYMBOL(ib_find_pkey);
 
+struct net_device *ib_get_net_dev_by_params(struct ib_device *dev,
+					    u8 port,
+					    u16 pkey,
+					    const union ib_gid *gid,
+					    const struct sockaddr *addr)
+{
+	struct net_device *net_dev = NULL;
+	struct ib_client *client;
+
+	if (!rdma_protocol_ib(dev, port))
+		return NULL;
+
+	down_read(&lists_rwsem);
+
+	list_for_each_entry(client, &client_list, list)
+		if (client->get_net_dev_by_params) {
+			net_dev = client->get_net_dev_by_params(dev, port, pkey,
+								gid, addr);
+			if (net_dev)
+				break;
+		}
+
+	up_read(&lists_rwsem);
+
+	return net_dev;
+}
+EXPORT_SYMBOL(ib_get_net_dev_by_params);
+
 static int __init ib_core_init(void)
 {
 	int ret;
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 986fddb08579..03899eebf53c 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -48,6 +48,7 @@
 #include <linux/rwsem.h>
 #include <linux/scatterlist.h>
 #include <linux/workqueue.h>
+#include <linux/socket.h>
 #include <uapi/linux/if_ether.h>
 
 #include <linux/atomic.h>
@@ -1762,6 +1763,26 @@ struct ib_client {
 	void (*add)   (struct ib_device *);
 	void (*remove)(struct ib_device *);
 
+	/* Returns the net_dev belonging to this ib_client and matching the
+	 * given parameters.
+	 * @dev:	An RDMA device that the net_dev use for communication.
+	 * @port:	A physical port number on the RDMA device.
+	 * @pkey:	P_Key that the net_dev uses if applicable.
+	 * @gid:	A GID that the net_dev uses to communicate.
+	 * @addr:	An IP address the net_dev is configured with.
+	 *
+	 * An ib_client that implements a net_dev on top of RDMA devices
+	 * (such as IP over IB) should implement this callback, allowing the
+	 * rdma_cm module to find the right net_dev for a given request.
+	 *
+	 * The caller is responsible for calling dev_put on the returned
+	 * netdev. */
+	struct net_device *(*get_net_dev_by_params)(
+			struct ib_device *dev,
+			u8 port,
+			u16 pkey,
+			const union ib_gid *gid,
+			const struct sockaddr *addr);
 	struct list_head list;
 };
 
@@ -3026,4 +3047,18 @@ static inline int ib_check_mr_access(int flags)
 int ib_check_mr_status(struct ib_mr *mr, u32 check_mask,
 		       struct ib_mr_status *mr_status);
 
+/**
+ * ib_get_net_dev_by_params() - Return the appropriate net_dev
+ * for a received CM request
+ * @dev:	An RDMA device on which the request has been received.
+ * @port:	Port number on the RDMA device.
+ * @pkey:	The Pkey the request came on.
+ * @gid:	A GID that the net_dev uses to communicate.
+ * @addr:	Contains the IP address that the request specified as its
+ *		destination.
+ */
+struct net_device *ib_get_net_dev_by_params(struct ib_device *dev, u8 port,
+					    u16 pkey, const union ib_gid *gid,
+					    const struct sockaddr *addr);
+
 #endif /* IB_VERBS_H */
-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
