From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: [PATCH 8/26 v3] rdma/cm: Restrict AF_IB loopback to binding to IB
 devices only
Date: Mon, 24 Sep 2012 23:55:31 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F0D8@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma@vger.kernel.org)"
	<linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26227 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751669Ab2IXXzc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 19:55:32 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a user specifies AF_IB as the source address for a loopback
connection, limit the resolution to IB devices only.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
resending with netdev copied

 drivers/infiniband/core/cma.c |   28 ++++++++++++++++++++--------
 1 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 0e661b4..b305963 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1971,26 +1971,38 @@ static void cma_set_loopback(struct sockaddr *addr)
 
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
