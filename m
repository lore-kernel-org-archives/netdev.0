From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v4 6/9] rdma/cm: Do not modify sa_family when setting loopback address
Date: Tue, 22 Jan 2013 13:56:34 -0800
Message-ID: <1358891797-14625-7-git-send-email-sean.hefty@intel.com>
References: <1358891797-14625-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358891797-14625-1-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

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

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/cma.c |   31 ++++++++++++++++++-------------
 1 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index caea4ef3..bb22885 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1952,6 +1952,23 @@ err:
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
@@ -1992,6 +2009,7 @@ port_found:
 	ib_addr_set_pkey(&id_priv->id.route.addr.dev_addr, pkey);
 	id_priv->id.port_num = p;
 	cma_attach_to_dev(id_priv, cma_dev);
+	cma_set_loopback((struct sockaddr *) &id_priv->id.route.addr.src_addr);
 out:
 	mutex_unlock(&lock);
 	return ret;
@@ -2039,7 +2057,6 @@ out:
 static int cma_resolve_loopback(struct rdma_id_private *id_priv)
 {
 	struct cma_work *work;
-	struct sockaddr *src, *dst;
 	union ib_gid gid;
 	int ret;
 
@@ -2056,18 +2073,6 @@ static int cma_resolve_loopback(struct rdma_id_private *id_priv)
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
-- 
1.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
