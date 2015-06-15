From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 06/11] IB/cma: Refactor RDMA IP CM private-data parsing code
Date: Mon, 15 Jun 2015 11:47:11 +0300
Message-ID: <1434358036-15526-7-git-send-email-haggaie@mellanox.com>
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

When receiving a connection request, rdma_cm needs to associate the request
with a network device, in order to disambiguate requests. To do this, it
needs to know the request's destination IP. For this the module needs to
allow getting this information from the private data in the request packet,
instead of relying on the information already being in the listening RDMA
CM ID.

When creating a new incoming connection ID, the code in
cma_save_ip{4,6}_info can no longer rely on the listener's private data to
find the port number, so it reads it from the requested service ID.

Signed-off-by: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/cma.c | 150 ++++++++++++++++++++++++++----------------
 1 file changed, 92 insertions(+), 58 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 3b943b700a63..bc061987485d 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -870,97 +870,122 @@ static inline int cma_any_port(struct sockaddr *addr)
 	return !cma_port(addr);
 }
 
-static void cma_save_ib_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id,
+static void cma_save_ib_info(struct sockaddr *src_addr,
+			     struct sockaddr *dst_addr,
 			     struct ib_sa_path_rec *path)
 {
-	struct sockaddr_ib *listen_ib, *ib;
+	struct sockaddr_ib *ib;
 
-	listen_ib = (struct sockaddr_ib *) &listen_id->route.addr.src_addr;
-	ib = (struct sockaddr_ib *) &id->route.addr.src_addr;
-	ib->sib_family = listen_ib->sib_family;
-	ib->sib_pkey = path->pkey;
-	ib->sib_flowinfo = path->flow_label;
-	memcpy(&ib->sib_addr, &path->sgid, 16);
-	ib->sib_sid = listen_ib->sib_sid;
-	ib->sib_sid_mask = cpu_to_be64(0xffffffffffffffffULL);
-	ib->sib_scope_id = listen_ib->sib_scope_id;
-
-	ib = (struct sockaddr_ib *) &id->route.addr.dst_addr;
-	ib->sib_family = listen_ib->sib_family;
-	ib->sib_pkey = path->pkey;
-	ib->sib_flowinfo = path->flow_label;
-	memcpy(&ib->sib_addr, &path->dgid, 16);
-}
-
-static __be16 ss_get_port(const struct sockaddr_storage *ss)
-{
-	if (ss->ss_family == AF_INET)
-		return ((struct sockaddr_in *)ss)->sin_port;
-	else if (ss->ss_family == AF_INET6)
-		return ((struct sockaddr_in6 *)ss)->sin6_port;
-	BUG();
+	if (src_addr) {
+		ib = (struct sockaddr_ib *)src_addr;
+		ib->sib_family = AF_IB;
+		ib->sib_pkey = path->pkey;
+		ib->sib_flowinfo = path->flow_label;
+		memcpy(&ib->sib_addr, &path->sgid, 16);
+		ib->sib_sid = path->service_id;
+		ib->sib_sid_mask = cpu_to_be64(0xffffffffffffffffULL);
+		ib->sib_scope_id = 0;
+	}
+	if (dst_addr) {
+		ib = (struct sockaddr_ib *)dst_addr;
+		ib->sib_family = AF_IB;
+		ib->sib_pkey = path->pkey;
+		ib->sib_flowinfo = path->flow_label;
+		memcpy(&ib->sib_addr, &path->dgid, 16);
+	}
 }
 
-static void cma_save_ip4_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id,
-			      struct cma_hdr *hdr)
+static void cma_save_ip4_info(struct sockaddr *src_addr,
+			      struct sockaddr *dst_addr,
+			      struct cma_hdr *hdr,
+			      __be16 local_port)
 {
 	struct sockaddr_in *ip4;
 
-	ip4 = (struct sockaddr_in *) &id->route.addr.src_addr;
-	ip4->sin_family = AF_INET;
-	ip4->sin_addr.s_addr = hdr->dst_addr.ip4.addr;
-	ip4->sin_port = ss_get_port(&listen_id->route.addr.src_addr);
+	if (src_addr) {
+		ip4 = (struct sockaddr_in *)src_addr;
+		ip4->sin_family = AF_INET;
+		ip4->sin_addr.s_addr = hdr->dst_addr.ip4.addr;
+		ip4->sin_port = local_port;
+	}
 
-	ip4 = (struct sockaddr_in *) &id->route.addr.dst_addr;
-	ip4->sin_family = AF_INET;
-	ip4->sin_addr.s_addr = hdr->src_addr.ip4.addr;
-	ip4->sin_port = hdr->port;
+	if (dst_addr) {
+		ip4 = (struct sockaddr_in *)dst_addr;
+		ip4->sin_family = AF_INET;
+		ip4->sin_addr.s_addr = hdr->src_addr.ip4.addr;
+		ip4->sin_port = hdr->port;
+	}
 }
 
-static void cma_save_ip6_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id,
-			      struct cma_hdr *hdr)
+static void cma_save_ip6_info(struct sockaddr *src_addr,
+			      struct sockaddr *dst_addr,
+			      struct cma_hdr *hdr,
+			      __be16 local_port)
 {
 	struct sockaddr_in6 *ip6;
 
-	ip6 = (struct sockaddr_in6 *) &id->route.addr.src_addr;
-	ip6->sin6_family = AF_INET6;
-	ip6->sin6_addr = hdr->dst_addr.ip6;
-	ip6->sin6_port = ss_get_port(&listen_id->route.addr.src_addr);
+	if (src_addr) {
+		ip6 = (struct sockaddr_in6 *)src_addr;
+		ip6->sin6_family = AF_INET6;
+		ip6->sin6_addr = hdr->dst_addr.ip6;
+		ip6->sin6_port = local_port;
+	}
 
-	ip6 = (struct sockaddr_in6 *) &id->route.addr.dst_addr;
-	ip6->sin6_family = AF_INET6;
-	ip6->sin6_addr = hdr->src_addr.ip6;
-	ip6->sin6_port = hdr->port;
+	if (dst_addr) {
+		ip6 = (struct sockaddr_in6 *)dst_addr;
+		ip6->sin6_family = AF_INET6;
+		ip6->sin6_addr = hdr->src_addr.ip6;
+		ip6->sin6_port = hdr->port;
+	}
 }
 
-static int cma_save_net_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id,
-			     struct ib_cm_event *ib_event)
+static u16 cma_port_from_service_id(__be64 service_id)
 {
-	struct cma_hdr *hdr;
+	return be64_to_cpu(service_id);
+}
 
-	if ((listen_id->route.addr.src_addr.ss_family == AF_IB) &&
-	    (ib_event->event == IB_CM_REQ_RECEIVED)) {
-		cma_save_ib_info(id, listen_id, ib_event->param.req_rcvd.primary_path);
-		return 0;
-	}
+static int cma_save_ip_info(struct sockaddr *src_addr,
+			    struct sockaddr *dst_addr,
+			    struct ib_cm_event *ib_event,
+			    __be64 service_id)
+{
+	struct cma_hdr *hdr;
+	__be16 port;
 
 	hdr = ib_event->private_data;
 	if (hdr->cma_version != CMA_VERSION)
 		return -EINVAL;
 
+	port = htons(cma_port_from_service_id(service_id));
+
 	switch (cma_get_ip_ver(hdr)) {
 	case 4:
-		cma_save_ip4_info(id, listen_id, hdr);
+		cma_save_ip4_info(src_addr, dst_addr, hdr, port);
 		break;
 	case 6:
-		cma_save_ip6_info(id, listen_id, hdr);
+		cma_save_ip6_info(src_addr, dst_addr, hdr, port);
 		break;
 	default:
 		return -EINVAL;
 	}
+
 	return 0;
 }
 
+static int cma_save_net_info(struct sockaddr *src_addr,
+			     struct sockaddr *dst_addr,
+			     struct ib_cm_event *ib_event,
+			     sa_family_t sa_family, __be64 service_id)
+{
+	if (sa_family == AF_IB && ib_event->event == IB_CM_REQ_RECEIVED) {
+		cma_save_ib_info(src_addr, dst_addr,
+				 ib_event->param.req_rcvd.primary_path);
+		return 0;
+	}
+
+	return cma_save_ip_info(src_addr, dst_addr, ib_event, service_id);
+}
+
 static inline int cma_user_data_offset(struct rdma_id_private *id_priv)
 {
 	return cma_family(id_priv) == AF_IB ? 0 : sizeof(struct cma_hdr);
@@ -1211,6 +1236,9 @@ static struct rdma_id_private *cma_new_conn_id(struct rdma_cm_id *listen_id,
 	struct rdma_id_private *id_priv;
 	struct rdma_cm_id *id;
 	struct rdma_route *rt;
+	const sa_family_t ss_family = listen_id->route.addr.src_addr.ss_family;
+	const __be64 service_id =
+		      ib_event->param.req_rcvd.primary_path->service_id;
 	int ret;
 
 	id = rdma_create_id(listen_id->event_handler, listen_id->context,
@@ -1219,7 +1247,9 @@ static struct rdma_id_private *cma_new_conn_id(struct rdma_cm_id *listen_id,
 		return NULL;
 
 	id_priv = container_of(id, struct rdma_id_private, id);
-	if (cma_save_net_info(id, listen_id, ib_event))
+	if (cma_save_net_info((struct sockaddr *)&id->route.addr.src_addr,
+			      (struct sockaddr *)&id->route.addr.dst_addr,
+			      ib_event, ss_family, service_id))
 		goto err;
 
 	rt = &id->route;
@@ -1265,7 +1295,11 @@ static struct rdma_id_private *cma_new_udp_id(struct rdma_cm_id *listen_id,
 		return NULL;
 
 	id_priv = container_of(id, struct rdma_id_private, id);
-	if (cma_save_net_info(id, listen_id, ib_event))
+	if (cma_save_net_info((struct sockaddr *)&id->route.addr.src_addr,
+			      (struct sockaddr *)&id->route.addr.dst_addr,
+			      ib_event,
+			      listen_id->route.addr.src_addr.ss_family,
+			      ib_event->param.sidr_req_rcvd.service_id))
 		goto err;
 
 	if (!cma_any_addr((struct sockaddr *) &id->route.addr.src_addr)) {
-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
