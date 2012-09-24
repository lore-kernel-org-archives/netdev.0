From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: [PATCH 5/26 v3] rdma/cm: Allow user to specify AF_IB when binding
Date: Mon, 24 Sep 2012 23:55:29 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F0BE@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma@vger.kernel.org)"
	<linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:25822 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752014Ab2IXXz4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 19:55:56 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modify rdma_bind_addr to allow the user to specify AF_IB when
binding to a device.  AF_IB indicates that the user is not
mapping an IP address to the native IB addressing.  (The mapping
may have already been done, or is not needed.)

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
resending with netdev copied

 drivers/infiniband/core/cma.c |   34 ++++++++++++++++++++++++++++------
 1 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index f569127..f09450e 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -353,6 +353,27 @@ static int find_gid_port(struct ib_device *device, union ib_gid *gid, u8 port_nu
 	return -EAGAIN;
 }
 
+static void cma_translate_ib(struct sockaddr_ib *sib, struct rdma_dev_addr *dev_addr)
+{
+	dev_addr->dev_type = ARPHRD_INFINIBAND;
+	rdma_addr_set_sgid(dev_addr, (union ib_gid *) &sib->sib_addr);
+	ib_addr_set_pkey(dev_addr, ntohs(sib->sib_pkey));
+}
+
+static int cma_translate_addr(struct sockaddr *addr, struct rdma_dev_addr *dev_addr)
+{
+	int ret;
+
+	if (addr->sa_family != AF_IB) {
+		ret = rdma_translate_ip(addr, dev_addr);
+	} else {
+		cma_translate_ib((struct sockaddr_ib *) addr, dev_addr);
+		ret = 0;
+	}
+
+	return ret;
+}
+
 static int cma_acquire_dev(struct rdma_id_private *id_priv)
 {
 	struct rdma_dev_addr *dev_addr = &id_priv->id.route.addr.dev_addr;
@@ -1131,8 +1152,8 @@ static struct rdma_id_private *cma_new_conn_id(struct rdma_cm_id *listen_id,
 		rdma_addr_set_sgid(&rt->addr.dev_addr, &rt->path_rec[0].sgid);
 		ib_addr_set_pkey(&rt->addr.dev_addr, be16_to_cpu(rt->path_rec[0].pkey));
 	} else {
-		ret = rdma_translate_ip((struct sockaddr *) &rt->addr.src_addr,
-					&rt->addr.dev_addr);
+		ret = cma_translate_addr((struct sockaddr *) &rt->addr.src_addr,
+					 &rt->addr.dev_addr);
 		if (ret)
 			goto err;
 	}
@@ -1171,8 +1192,8 @@ static struct rdma_id_private *cma_new_udp_id(struct rdma_cm_id *listen_id,
 			  ip_ver, port, src, dst);
 
 	if (!cma_any_addr((struct sockaddr *) &id->route.addr.src_addr)) {
-		ret = rdma_translate_ip((struct sockaddr *) &id->route.addr.src_addr,
-					&id->route.addr.dev_addr);
+		ret = cma_translate_addr((struct sockaddr *) &id->route.addr.src_addr,
+					 &id->route.addr.dev_addr);
 		if (ret)
 			goto err;
 	}
@@ -2422,7 +2443,8 @@ int rdma_bind_addr(struct rdma_cm_id *id, struct sockaddr *addr)
 	struct rdma_id_private *id_priv;
 	int ret;
 
-	if (addr->sa_family != AF_INET && addr->sa_family != AF_INET6)
+	if (addr->sa_family != AF_INET && addr->sa_family != AF_INET6 &&
+	    addr->sa_family != AF_IB)
 		return -EAFNOSUPPORT;
 
 	id_priv = container_of(id, struct rdma_id_private, id);
@@ -2434,7 +2456,7 @@ int rdma_bind_addr(struct rdma_cm_id *id, struct sockaddr *addr)
 		goto err1;
 
 	if (!cma_any_addr(addr)) {
-		ret = rdma_translate_ip(addr, &id->route.addr.dev_addr);
+		ret = cma_translate_addr(addr, &id->route.addr.dev_addr);
 		if (ret)
 			goto err1;
 
