From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v4 8/9] rdma/cm: Restrict AF_IB loopback to binding to IB devices only
Date: Tue, 22 Jan 2013 13:56:36 -0800
Message-ID: <1358891797-14625-9-git-send-email-sean.hefty@intel.com>
References: <1358891797-14625-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358891797-14625-1-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

If a user specifies AF_IB as the source address for a loopback
connection, limit the resolution to IB devices only.

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/cma.c |   28 ++++++++++++++++++++--------
 1 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 0ebf123..e7409b4 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1981,26 +1981,38 @@ static void cma_set_loopback(struct sockaddr *addr)
 
 static int cma_bind_loopback(struct rdma_id_private *id_priv)
 {
-	struct cma_device *cma_dev;
+	struct cma_device *cma_dev, *cur_dev;
 	struct ib_port_attr port_attr;
 	union ib_gid gid;
 	u16 pkey;
 	int ret;
 	u8 p;
 
+	cma_dev = NULL;
 	mutex_lock(&lock);
-	if (list_empty(&dev_list)) {
+	list_for_each_entry(cur_dev, &dev_list, list) {
+		if (cma_family(id_priv) == AF_IB &&
+		    rdma_node_get_transport(cur_dev->device->node_type) != RDMA_TRANSPORT_IB)
+			continue;
+
+		if (!cma_dev)
+			cma_dev = cur_dev;
+
+		for (p = 1; p <= cur_dev->device->phys_port_cnt; ++p) {
+			if (!ib_query_port(cur_dev->device, p, &port_attr) &&
+			    port_attr.state == IB_PORT_ACTIVE) {
+				cma_dev = cur_dev;
+				goto port_found;
+			}
+		}
+	}
+
+	if (!cma_dev) {
 		ret = -ENODEV;
 		goto out;
 	}
-	list_for_each_entry(cma_dev, &dev_list, list)
-		for (p = 1; p <= cma_dev->device->phys_port_cnt; ++p)
-			if (!ib_query_port(cma_dev->device, p, &port_attr) &&
-			    port_attr.state == IB_PORT_ACTIVE)
-				goto port_found;
 
 	p = 1;
-	cma_dev = list_entry(dev_list.next, struct cma_device, list);
 
 port_found:
 	ret = ib_get_cached_gid(cma_dev->device, p, 0, &gid);
-- 
1.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
