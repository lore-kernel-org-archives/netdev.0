From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v5 06/28] rdma/cm: Allow user to specify AF_IB when binding
Date: Wed, 29 May 2013 10:09:12 -0700
Message-ID: <1369847374-12176-7-git-send-email-sean.hefty@intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1369847374-12176-1-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Modify rdma_bind_addr to allow the user to specify AF_IB when
binding to a device.  AF_IB indicates that the user is not
mapping an IP address to the native IB addressing.  (The mapping
may have already been done, or is not needed.)

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/cma.c |   34 ++++++++++++++++++++++++++++------
 1 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index f56c62a..92dcdfe 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -359,6 +359,27 @@ static int find_gid_port(struct ib_device *device, union ib_gid *gid, u8 port_nu
 	return -EADDRNOTAVAIL;
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
@@ -1136,8 +1157,8 @@ static struct rdma_id_private *cma_new_conn_id(struct rdma_cm_id *listen_id,
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
@@ -1176,8 +1197,8 @@ static struct rdma_id_private *cma_new_udp_id(struct rdma_cm_id *listen_id,
 			  ip_ver, port, src, dst);
 
 	if (!cma_any_addr((struct sockaddr *) &id->route.addr.src_addr)) {
-		ret = rdma_translate_ip((struct sockaddr *) &id->route.addr.src_addr,
-					&id->route.addr.dev_addr);
+		ret = cma_translate_addr((struct sockaddr *) &id->route.addr.src_addr,
+					 &id->route.addr.dev_addr);
 		if (ret)
 			goto err;
 	}
@@ -2443,7 +2464,8 @@ int rdma_bind_addr(struct rdma_cm_id *id, struct sockaddr *addr)
 	struct rdma_id_private *id_priv;
 	int ret;
 
-	if (addr->sa_family != AF_INET && addr->sa_family != AF_INET6)
+	if (addr->sa_family != AF_INET && addr->sa_family != AF_INET6 &&
+	    addr->sa_family != AF_IB)
 		return -EAFNOSUPPORT;
 
 	id_priv = container_of(id, struct rdma_id_private, id);
@@ -2455,7 +2477,7 @@ int rdma_bind_addr(struct rdma_cm_id *id, struct sockaddr *addr)
 		goto err1;
 
 	if (!cma_any_addr(addr)) {
-		ret = rdma_translate_ip(addr, &id->route.addr.dev_addr);
+		ret = cma_translate_addr(addr, &id->route.addr.dev_addr);
 		if (ret)
 			goto err1;
 
-- 
1.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
