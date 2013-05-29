From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v5 15/28] rdma/cm: Merge cma_get/save_net_info
Date: Wed, 29 May 2013 10:09:21 -0700
Message-ID: <1369847374-12176-16-git-send-email-sean.hefty@intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1369847374-12176-1-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

With the removal of SDP related code, we can merge
cma_get_net_info with cma_save_net_info, since we're
only ever dealing with a single header format.

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/cma.c |  126 +++++++++++++++++++++++------------------
 1 files changed, 70 insertions(+), 56 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index d53d056..69217f5 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -810,59 +810,87 @@ static inline int cma_any_port(struct sockaddr *addr)
 	return !cma_port(addr);
 }
 
-static int cma_get_net_info(void *hdr, enum rdma_port_space ps,
-			    u8 *ip_ver, __be16 *port,
-			    union cma_ip_addr **src, union cma_ip_addr **dst)
+static void cma_save_ib_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id,
+			     struct ib_sa_path_rec *path)
 {
-	if (((struct cma_hdr *) hdr)->cma_version != CMA_VERSION)
-		return -EINVAL;
+	struct sockaddr_ib *listen_ib, *ib;
 
-	*ip_ver	= cma_get_ip_ver(hdr);
-	*port	= ((struct cma_hdr *) hdr)->port;
-	*src	= &((struct cma_hdr *) hdr)->src_addr;
-	*dst	= &((struct cma_hdr *) hdr)->dst_addr;
+	listen_ib = (struct sockaddr_ib *) &listen_id->route.addr.src_addr;
+	ib = (struct sockaddr_ib *) &id->route.addr.src_addr;
+	ib->sib_family = listen_ib->sib_family;
+	ib->sib_pkey = path->pkey;
+	ib->sib_flowinfo = path->flow_label;
+	memcpy(&ib->sib_addr, &path->sgid, 16);
+	ib->sib_sid = listen_ib->sib_sid;
+	ib->sib_sid_mask = 0xFFFFFFFFFFFFFFFFULL;
+	ib->sib_scope_id = listen_ib->sib_scope_id;
 
-	if (*ip_ver != 4 && *ip_ver != 6)
-		return -EINVAL;
-	return 0;
+	ib = (struct sockaddr_ib *) &id->route.addr.dst_addr;
+	ib->sib_family = listen_ib->sib_family;
+	ib->sib_pkey = path->pkey;
+	ib->sib_flowinfo = path->flow_label;
+	memcpy(&ib->sib_addr, &path->dgid, 16);
 }
 
-static void cma_save_net_info(struct rdma_addr *addr,
-			      struct rdma_addr *listen_addr,
-			      u8 ip_ver, __be16 port,
-			      union cma_ip_addr *src, union cma_ip_addr *dst)
+static void cma_save_ip4_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id,
+			      struct cma_hdr *hdr)
 {
 	struct sockaddr_in *listen4, *ip4;
+
+	listen4 = (struct sockaddr_in *) &listen_id->route.addr.src_addr;
+	ip4 = (struct sockaddr_in *) &id->route.addr.src_addr;
+	ip4->sin_family = listen4->sin_family;
+	ip4->sin_addr.s_addr = hdr->dst_addr.ip4.addr;
+	ip4->sin_port = listen4->sin_port;
+
+	ip4 = (struct sockaddr_in *) &id->route.addr.dst_addr;
+	ip4->sin_family = listen4->sin_family;
+	ip4->sin_addr.s_addr = hdr->src_addr.ip4.addr;
+	ip4->sin_port = hdr->port;
+}
+
+static void cma_save_ip6_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id,
+			      struct cma_hdr *hdr)
+{
 	struct sockaddr_in6 *listen6, *ip6;
 
-	switch (ip_ver) {
+	listen6 = (struct sockaddr_in6 *) &listen_id->route.addr.src_addr;
+	ip6 = (struct sockaddr_in6 *) &id->route.addr.src_addr;
+	ip6->sin6_family = listen6->sin6_family;
+	ip6->sin6_addr = hdr->dst_addr.ip6;
+	ip6->sin6_port = listen6->sin6_port;
+
+	ip6 = (struct sockaddr_in6 *) &id->route.addr.dst_addr;
+	ip6->sin6_family = listen6->sin6_family;
+	ip6->sin6_addr = hdr->src_addr.ip6;
+	ip6->sin6_port = hdr->port;
+}
+
+static int cma_save_net_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id,
+			     struct ib_cm_event *ib_event)
+{
+	struct cma_hdr *hdr;
+
+	if (listen_id->route.addr.src_addr.ss_family == AF_IB) {
+		cma_save_ib_info(id, listen_id, ib_event->param.req_rcvd.primary_path);
+		return 0;
+	}
+
+	hdr = ib_event->private_data;
+	if (hdr->cma_version != CMA_VERSION)
+		return -EINVAL;
+
+	switch (cma_get_ip_ver(hdr)) {
 	case 4:
-		listen4 = (struct sockaddr_in *) &listen_addr->src_addr;
-		ip4 = (struct sockaddr_in *) &addr->src_addr;
-		ip4->sin_family = listen4->sin_family;
-		ip4->sin_addr.s_addr = dst->ip4.addr;
-		ip4->sin_port = listen4->sin_port;
-
-		ip4 = (struct sockaddr_in *) &addr->dst_addr;
-		ip4->sin_family = listen4->sin_family;
-		ip4->sin_addr.s_addr = src->ip4.addr;
-		ip4->sin_port = port;
+		cma_save_ip4_info(id, listen_id, hdr);
 		break;
 	case 6:
-		listen6 = (struct sockaddr_in6 *) &listen_addr->src_addr;
-		ip6 = (struct sockaddr_in6 *) &addr->src_addr;
-		ip6->sin6_family = listen6->sin6_family;
-		ip6->sin6_addr = dst->ip6;
-		ip6->sin6_port = listen6->sin6_port;
-
-		ip6 = (struct sockaddr_in6 *) &addr->dst_addr;
-		ip6->sin6_family = listen6->sin6_family;
-		ip6->sin6_addr = src->ip6;
-		ip6->sin6_port = port;
+		cma_save_ip6_info(id, listen_id, hdr);
 		break;
 	default:
-		break;
+		return -EINVAL;
 	}
+	return 0;
 }
 
 static inline int cma_user_data_offset(enum rdma_port_space ps)
@@ -1129,23 +1157,16 @@ static struct rdma_id_private *cma_new_conn_id(struct rdma_cm_id *listen_id,
 	struct rdma_id_private *id_priv;
 	struct rdma_cm_id *id;
 	struct rdma_route *rt;
-	union cma_ip_addr *src, *dst;
-	__be16 port;
-	u8 ip_ver;
 	int ret;
 
-	if (cma_get_net_info(ib_event->private_data, listen_id->ps,
-			     &ip_ver, &port, &src, &dst))
-		return NULL;
-
 	id = rdma_create_id(listen_id->event_handler, listen_id->context,
 			    listen_id->ps, ib_event->param.req_rcvd.qp_type);
 	if (IS_ERR(id))
 		return NULL;
 
 	id_priv = container_of(id, struct rdma_id_private, id);
-	cma_save_net_info(&id->route.addr, &listen_id->route.addr,
-			  ip_ver, port, src, dst);
+	if (cma_save_net_info(id, listen_id, ib_event))
+		goto err;
 
 	rt = &id->route;
 	rt->num_paths = ib_event->param.req_rcvd.alternate_path ? 2 : 1;
@@ -1182,9 +1203,6 @@ static struct rdma_id_private *cma_new_udp_id(struct rdma_cm_id *listen_id,
 {
 	struct rdma_id_private *id_priv;
 	struct rdma_cm_id *id;
-	union cma_ip_addr *src, *dst;
-	__be16 port;
-	u8 ip_ver;
 	int ret;
 
 	id = rdma_create_id(listen_id->event_handler, listen_id->context,
@@ -1193,13 +1211,9 @@ static struct rdma_id_private *cma_new_udp_id(struct rdma_cm_id *listen_id,
 		return NULL;
 
 	id_priv = container_of(id, struct rdma_id_private, id);
-	if (cma_get_net_info(ib_event->private_data, listen_id->ps,
-			     &ip_ver, &port, &src, &dst))
+	if (cma_save_net_info(id, listen_id, ib_event))
 		goto err;
 
-	cma_save_net_info(&id->route.addr, &listen_id->route.addr,
-			  ip_ver, port, src, dst);
-
 	if (!cma_any_addr((struct sockaddr *) &id->route.addr.src_addr)) {
 		ret = cma_translate_addr(cma_src_addr(id_priv), &id->route.addr.dev_addr);
 		if (ret)
-- 
1.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
