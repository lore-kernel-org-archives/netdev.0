From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: [PATCH 10/26 v3] rdma/cm: Add support for AF_IB to rdma_resolve_addr
Date: Mon, 24 Sep 2012 23:55:32 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F0EA@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma@vger.kernel.org)"
	<linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:24911 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752072Ab2IXXz7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 19:55:59 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the user to specify the remote address using AF_IB format.
When AF_IB is used, the remote address simply needs to be recorded,
and no resolution using ARP is done.  The local address may still
need to be matched with a local IB device.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
resending with netdev copied

 drivers/infiniband/core/cma.c |  106 +++++++++++++++++++++++++++++++++++++++--
 1 files changed, 100 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index fa4ac4f..9d37c2f 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -433,6 +433,61 @@ out:
 	return ret;
 }
 
+/*
+ * Select the source IB device and address to reach the destination IB address.
+ */
+static int cma_resolve_ib_dev(struct rdma_id_private *id_priv)
+{
+	struct cma_device *cma_dev, *cur_dev;
+	struct sockaddr_ib *addr;
+	union ib_gid gid, sgid, *dgid;
+	u16 pkey, index;
+	u8 port, p;
+	int i;
+
+	cma_dev = NULL;
+	addr = (struct sockaddr_ib *) &id_priv->id.route.addr.dst_addr;
+	dgid = (union ib_gid *) &addr->sib_addr;
+	pkey = ntohs(addr->sib_pkey);
+
+	list_for_each_entry(cur_dev, &dev_list, list) {
+		if (rdma_node_get_transport(cur_dev->device->node_type) != RDMA_TRANSPORT_IB)
+			continue;
+
+		for (p = 1; p <= cur_dev->device->phys_port_cnt; ++p) {
+			if (ib_find_cached_pkey(cur_dev->device, p, pkey, &index))
+				continue;
+
+			for (i = 0; !ib_get_cached_gid(cur_dev->device, p, i, &gid); i++) {
+				if (!memcmp(&gid, dgid, sizeof(gid))) {
+					cma_dev = cur_dev;
+					sgid = gid;
+					port = p;
+					goto found;
+				}
+
+				if (!cma_dev && (gid.global.subnet_prefix ==
+						 dgid->global.subnet_prefix)) {
+					cma_dev = cur_dev;
+					sgid = gid;
+					port = p;
+				}
+			}
+		}
+	}
+
+	if (!cma_dev)
+		return -ENODEV;
+
+found:
+	cma_attach_to_dev(id_priv, cma_dev);
+	id_priv->id.port_num = port;
+	addr = (struct sockaddr_ib *) &id_priv->id.route.addr.src_addr;
+	memcpy(&addr->sib_addr, &sgid, sizeof sgid);
+	cma_translate_ib(addr, &id_priv->id.route.addr.dev_addr);
+	return 0;
+}
+
 static void cma_deref_id(struct rdma_id_private *id_priv)
 {
 	if (atomic_dec_and_test(&id_priv->refcount))
@@ -2091,14 +2146,48 @@ err:
 	return ret;
 }
 
+static int cma_resolve_ib_addr(struct rdma_id_private *id_priv)
+{
+	struct cma_work *work;
+	int ret;
+
+	work = kzalloc(sizeof *work, GFP_KERNEL);
+	if (!work)
+		return -ENOMEM;
+
+	if (!id_priv->cma_dev) {
+		ret = cma_resolve_ib_dev(id_priv);
+		if (ret)
+			goto err;
+	}
+
+	rdma_addr_set_dgid(&id_priv->id.route.addr.dev_addr, (union ib_gid *)
+		&(((struct sockaddr_ib *) &id_priv->id.route.addr.dst_addr)->sib_addr));
+
+	work->id = id_priv;
+	INIT_WORK(&work->work, cma_work_handler);
+	work->old_state = RDMA_CM_ADDR_QUERY;
+	work->new_state = RDMA_CM_ADDR_RESOLVED;
+	work->event.event = RDMA_CM_EVENT_ADDR_RESOLVED;
+	queue_work(cma_wq, &work->work);
+	return 0;
+err:
+	kfree(work);
+	return ret;
+}
+
 static int cma_bind_addr(struct rdma_cm_id *id, struct sockaddr *src_addr,
 			 struct sockaddr *dst_addr)
 {
 	if (!src_addr || !src_addr->sa_family) {
 		src_addr = (struct sockaddr *) &id->route.addr.src_addr;
-		if ((src_addr->sa_family = dst_addr->sa_family) == AF_INET6) {
+		src_addr->sa_family = dst_addr->sa_family;
+		if (dst_addr->sa_family == AF_INET6) {
 			((struct sockaddr_in6 *) src_addr)->sin6_scope_id =
 				((struct sockaddr_in6 *) dst_addr)->sin6_scope_id;
+		} else if (dst_addr->sa_family == AF_IB) {
+			((struct sockaddr_ib *) src_addr)->sib_pkey =
+				((struct sockaddr_ib *) dst_addr)->sib_pkey;
 		}
 	}
 	return rdma_bind_addr(id, src_addr);
@@ -2125,12 +2214,17 @@ int rdma_resolve_addr(struct rdma_cm_id *id, struct sockaddr *src_addr,
 
 	atomic_inc(&id_priv->refcount);
 	memcpy(cma_dst_addr(id_priv), dst_addr, rdma_addr_size(dst_addr));
-	if (cma_any_addr(dst_addr))
+	if (cma_any_addr(dst_addr)) {
 		ret = cma_resolve_loopback(id_priv);
-	else
-		ret = rdma_resolve_ip(&addr_client, cma_src_addr(id_priv),
-				      dst_addr, &id->route.addr.dev_addr,
-				      timeout_ms, addr_handler, id_priv);
+	} else {
+		if (dst_addr->sa_family == AF_IB) {
+			ret = cma_resolve_ib_addr(id_priv);
+		} else {
+			ret = rdma_resolve_ip(&addr_client, cma_src_addr(id_priv),
+					      dst_addr, &id->route.addr.dev_addr,
+					      timeout_ms, addr_handler, id_priv);
+		}
+	}
 	if (ret)
 		goto err;
 
