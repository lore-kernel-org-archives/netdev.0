From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: [PATCH 6/26 v3] rdma/cm: Do not modify sa_family when setting
 loopback address
Date: Mon, 24 Sep 2012 23:55:30 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F0C4@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma@vger.kernel.org)"
	<linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:7555 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751651Ab2IXXzd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 19:55:33 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cma_resolve_loopback is called after an rdma_cm_id has been
bound to a specific sa_family and port.  Once the
source sa_family for the id has been set, do not modify it.
Only the actual IP address portion of the source address
needs to be set.

As part of this fix, we can simplify setting the source address
by moving the loopback address assignment from cma_resolve_loopback
to cma_bind_loopback.  cma_bind_loopback is only invoked when
the source address is the loopback address.

Finally, add loopback support for AF_IB as part of the change.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
resending with netdev copied

 drivers/infiniband/core/cma.c |   31 ++++++++++++++++++-------------
 1 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index f09450e..4aee89a 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1942,6 +1942,23 @@ err:
 }
 EXPORT_SYMBOL(rdma_resolve_route);
 
+static void cma_set_loopback(struct sockaddr *addr)
+{
+	switch (addr->sa_family) {
+	case AF_INET:
+		((struct sockaddr_in *) addr)->sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+		break;
+	case AF_INET6:
+		ipv6_addr_set(&((struct sockaddr_in6 *) addr)->sin6_addr,
+			      0, 0, 0, htonl(1));
+		break;
+	default:
+		ib_addr_set(&((struct sockaddr_ib *) addr)->sib_addr,
+			    0, 0, 0, htonl(1));
+		break;
+	}
+}
+
 static int cma_bind_loopback(struct rdma_id_private *id_priv)
 {
 	struct cma_device *cma_dev;
@@ -1982,6 +1999,7 @@ port_found:
 	ib_addr_set_pkey(&id_priv->id.route.addr.dev_addr, pkey);
 	id_priv->id.port_num = p;
 	cma_attach_to_dev(id_priv, cma_dev);
+	cma_set_loopback((struct sockaddr *) &id_priv->id.route.addr.src_addr);
 out:
 	mutex_unlock(&lock);
 	return ret;
@@ -2029,7 +2047,6 @@ out:
 static int cma_resolve_loopback(struct rdma_id_private *id_priv)
 {
 	struct cma_work *work;
-	struct sockaddr *src, *dst;
 	union ib_gid gid;
 	int ret;
 
@@ -2046,18 +2063,6 @@ static int cma_resolve_loopback(struct rdma_id_private *id_priv)
 	rdma_addr_get_sgid(&id_priv->id.route.addr.dev_addr, &gid);
 	rdma_addr_set_dgid(&id_priv->id.route.addr.dev_addr, &gid);
 
-	src = (struct sockaddr *) &id_priv->id.route.addr.src_addr;
-	if (cma_zero_addr(src)) {
-		dst = (struct sockaddr *) &id_priv->id.route.addr.dst_addr;
-		if ((src->sa_family = dst->sa_family) == AF_INET) {
-			((struct sockaddr_in *)src)->sin_addr =
-				((struct sockaddr_in *)dst)->sin_addr;
-		} else {
-			((struct sockaddr_in6 *)src)->sin6_addr =
-				((struct sockaddr_in6 *)dst)->sin6_addr;
-		}
-	}
-
 	work->id = id_priv;
 	INIT_WORK(&work->work, cma_work_handler);
 	work->old_state = RDMA_CM_ADDR_QUERY;
