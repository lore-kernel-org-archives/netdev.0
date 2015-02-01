From: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 05/10] IB/cm,cma: Move RDMA IP CM private-data parsing code from ib_cma to ib_cm
Date: Sun,  1 Feb 2015 13:28:48 +0200
Message-ID: <1422790133-28725-6-git-send-email-raindel@mellanox.com>
References: <1422790133-28725-1-git-send-email-raindel@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422790133-28725-1-git-send-email-raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

When receiving a connection request, ib_cm needs to associate the request with
a network namespace. To do this, it needs to know the request's destination
IP. For this the RDMA IP CM packet formatting functionality needs to be
exposed to ib_cm.

This patch merely moves the RDMA IP CM data formatting and parsing functions
to be part of ib_cm. The following patch will utilize the new knowledge to
look-up the appropriate namespace. Each namespace maintains an independent
table of RDMA CM service IDs, allowing isolation and separation between the
network namespaces.

When creating a new incoming connection ID, the code in cm_save_ip_info can no
longer rely on the listener's private data to find the port number, so it
reads it from the requested service ID. This required saving the service ID in
cm_format_paths_from_req.

Signed-off-by: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

---
 drivers/infiniband/core/cm.c  | 167 ++++++++++++++++++++++++++++++++++++++++++
 drivers/infiniband/core/cma.c | 166 +++++------------------------------------
 include/rdma/ib_cm.h          |  46 ++++++++++++
 3 files changed, 231 insertions(+), 148 deletions(-)

diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index 5a45cb76c43e..5cc1a4aa9728 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -51,6 +51,7 @@
 
 #include <rdma/ib_cache.h>
 #include <rdma/ib_cm.h>
+#include <rdma/ib.h>
 #include "cm_msgs.h"
 
 MODULE_AUTHOR("Sean Hefty");
@@ -701,6 +702,170 @@ static void cm_reject_sidr_req(struct cm_id_private *cm_id_priv,
 	ib_send_cm_sidr_rep(&cm_id_priv->id, &param);
 }
 
+static inline u8 cm_get_ip_ver(struct cm_hdr *hdr)
+{
+	return hdr->ip_version >> 4;
+}
+
+void cm_set_ip_ver(struct cm_hdr *hdr, u8 ip_ver)
+{
+	hdr->ip_version = (ip_ver << 4) | (hdr->ip_version & 0xF);
+}
+EXPORT_SYMBOL(cm_set_ip_ver);
+
+int cm_format_hdr(void *hdr, int family,
+		  struct sockaddr *src_addr,
+		  struct sockaddr *dst_addr)
+{
+	struct cm_hdr *cm_hdr;
+
+	cm_hdr = hdr;
+	cm_hdr->cm_version = RDMA_IP_CM_VERSION;
+	if (family == AF_INET) {
+		struct sockaddr_in *src4, *dst4;
+
+		src4 = (struct sockaddr_in *)src_addr;
+		dst4 = (struct sockaddr_in *)dst_addr;
+
+		cm_set_ip_ver(cm_hdr, 4);
+		cm_hdr->src_addr.ip4.addr = src4->sin_addr.s_addr;
+		cm_hdr->dst_addr.ip4.addr = dst4->sin_addr.s_addr;
+		cm_hdr->port = src4->sin_port;
+	} else if (family == AF_INET6) {
+		struct sockaddr_in6 *src6, *dst6;
+
+		src6 = (struct sockaddr_in6 *)src_addr;
+		dst6 = (struct sockaddr_in6 *)dst_addr;
+
+		cm_set_ip_ver(cm_hdr, 6);
+		cm_hdr->src_addr.ip6 = src6->sin6_addr;
+		cm_hdr->dst_addr.ip6 = dst6->sin6_addr;
+		cm_hdr->port = src6->sin6_port;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(cm_format_hdr);
+
+static void cm_save_ib_info(struct sockaddr *src_addr,
+			    struct sockaddr *dst_addr,
+			    struct ib_sa_path_rec *path)
+{
+	struct sockaddr_ib  *ib;
+
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
+}
+
+static void cm_save_ip6_info(struct sockaddr *src_addr,
+			     struct sockaddr *dst_addr,
+			     struct cm_hdr *hdr,
+			     __be16 local_port)
+{
+	struct sockaddr_in6 *ip6;
+
+	if (src_addr) {
+		ip6 = (struct sockaddr_in6 *)src_addr;
+		ip6->sin6_family = AF_INET6;
+		ip6->sin6_addr = hdr->dst_addr.ip6;
+		ip6->sin6_port = local_port;
+	}
+
+	if (dst_addr) {
+		ip6 = (struct sockaddr_in6 *)dst_addr;
+		ip6->sin6_family = AF_INET6;
+		ip6->sin6_addr = hdr->src_addr.ip6;
+		ip6->sin6_port = hdr->port;
+	}
+}
+
+static void cm_save_ip4_info(struct sockaddr *src_addr,
+			     struct sockaddr *dst_addr,
+			     struct cm_hdr *hdr,
+			     __be16 local_port)
+{
+	struct sockaddr_in *ip4;
+
+	if (src_addr) {
+		ip4 = (struct sockaddr_in *)src_addr;
+		ip4->sin_family = AF_INET;
+		ip4->sin_addr.s_addr = hdr->dst_addr.ip4.addr;
+		ip4->sin_port = local_port;
+	}
+
+	if (dst_addr) {
+		ip4 = (struct sockaddr_in *)dst_addr;
+		ip4->sin_family = AF_INET;
+		ip4->sin_addr.s_addr = hdr->src_addr.ip4.addr;
+		ip4->sin_port = hdr->port;
+	}
+}
+
+static __be16 cm_port_from_service_id(__be64 service_id)
+{
+	return htons(be64_to_cpu(service_id));
+}
+
+static int cm_save_ip_info(struct sockaddr *src_addr,
+			   struct sockaddr *dst_addr,
+			   struct cm_work *work)
+{
+	struct cm_hdr *hdr;
+	__be16 port;
+
+	hdr = work->cm_event.private_data;
+	if (hdr->cm_version != RDMA_IP_CM_VERSION)
+		return -EINVAL;
+
+	port = cm_port_from_service_id(work->path->service_id);
+
+	switch (cm_get_ip_ver(hdr)) {
+	case 4:
+		cm_save_ip4_info(src_addr, dst_addr, hdr, port);
+		break;
+	case 6:
+		cm_save_ip6_info(src_addr, dst_addr, hdr, port);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+int cm_save_net_info(struct sockaddr *src_addr,
+		     struct sockaddr *dst_addr,
+		     struct ib_cm_event *ib_event)
+{
+	struct cm_work *work = container_of(ib_event, struct cm_work, cm_event);
+
+	if ((rdma_port_get_link_layer(work->port->cm_dev->ib_device,
+				      work->port->port_num) ==
+	     IB_LINK_LAYER_INFINIBAND) &&
+	    (ib_event->event == IB_CM_REQ_RECEIVED)) {
+		cm_save_ib_info(src_addr, dst_addr,
+				ib_event->param.req_rcvd.primary_path);
+		return 0;
+	}
+
+	return cm_save_ip_info(src_addr, dst_addr, work);
+}
+EXPORT_SYMBOL(cm_save_net_info);
+
 struct ib_cm_id *ib_create_cm_id(struct ib_device *device,
 				 ib_cm_handler cm_handler,
 				 void *context)
@@ -1260,6 +1425,7 @@ static void cm_format_paths_from_req(struct cm_req_msg *req_msg,
 	primary_path->packet_life_time =
 		cm_req_get_primary_local_ack_timeout(req_msg);
 	primary_path->packet_life_time -= (primary_path->packet_life_time > 0);
+	primary_path->service_id = req_msg->service_id;
 
 	if (req_msg->alt_local_lid) {
 		memset(alt_path, 0, sizeof *alt_path);
@@ -1281,6 +1447,7 @@ static void cm_format_paths_from_req(struct cm_req_msg *req_msg,
 		alt_path->packet_life_time =
 			cm_req_get_alt_local_ack_timeout(req_msg);
 		alt_path->packet_life_time -= (alt_path->packet_life_time > 0);
+		alt_path->service_id = req_msg->service_id;
 	}
 }
 
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index aeb2417ec928..9f6faeb1de5f 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -179,23 +179,8 @@ struct iboe_mcast_work {
 	struct cma_multicast	*mc;
 };
 
-union cma_ip_addr {
-	struct in6_addr ip6;
-	struct {
-		__be32 pad[3];
-		__be32 addr;
-	} ip4;
-};
 
-struct cma_hdr {
-	u8 cma_version;
-	u8 ip_version;	/* IP version: 7:4 */
-	__be16 port;
-	union cma_ip_addr src_addr;
-	union cma_ip_addr dst_addr;
-};
 
-#define CMA_VERSION 0x00
 
 static int cma_comp(struct rdma_id_private *id_priv, enum rdma_cm_state comp)
 {
@@ -234,16 +219,6 @@ static enum rdma_cm_state cma_exch(struct rdma_id_private *id_priv,
 	return old;
 }
 
-static inline u8 cma_get_ip_ver(struct cma_hdr *hdr)
-{
-	return hdr->ip_version >> 4;
-}
-
-static inline void cma_set_ip_ver(struct cma_hdr *hdr, u8 ip_ver)
-{
-	hdr->ip_version = (ip_ver << 4) | (hdr->ip_version & 0xF);
-}
-
 static void cma_attach_to_dev(struct rdma_id_private *id_priv,
 			      struct cma_device *cma_dev)
 {
@@ -839,93 +814,9 @@ static inline int cma_any_port(struct sockaddr *addr)
 	return !cma_port(addr);
 }
 
-static void cma_save_ib_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id,
-			     struct ib_sa_path_rec *path)
-{
-	struct sockaddr_ib *listen_ib, *ib;
-
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
-static void cma_save_ip4_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id,
-			      struct cma_hdr *hdr)
-{
-	struct sockaddr_in *listen4, *ip4;
-
-	listen4 = (struct sockaddr_in *) &listen_id->route.addr.src_addr;
-	ip4 = (struct sockaddr_in *) &id->route.addr.src_addr;
-	ip4->sin_family = AF_INET;
-	ip4->sin_addr.s_addr = hdr->dst_addr.ip4.addr;
-	ip4->sin_port = listen4->sin_port;
-
-	ip4 = (struct sockaddr_in *) &id->route.addr.dst_addr;
-	ip4->sin_family = AF_INET;
-	ip4->sin_addr.s_addr = hdr->src_addr.ip4.addr;
-	ip4->sin_port = hdr->port;
-}
-
-static void cma_save_ip6_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id,
-			      struct cma_hdr *hdr)
-{
-	struct sockaddr_in6 *listen6, *ip6;
-
-	listen6 = (struct sockaddr_in6 *) &listen_id->route.addr.src_addr;
-	ip6 = (struct sockaddr_in6 *) &id->route.addr.src_addr;
-	ip6->sin6_family = AF_INET6;
-	ip6->sin6_addr = hdr->dst_addr.ip6;
-	ip6->sin6_port = listen6->sin6_port;
-
-	ip6 = (struct sockaddr_in6 *) &id->route.addr.dst_addr;
-	ip6->sin6_family = AF_INET6;
-	ip6->sin6_addr = hdr->src_addr.ip6;
-	ip6->sin6_port = hdr->port;
-}
-
-static int cma_save_net_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id,
-			     struct ib_cm_event *ib_event)
-{
-	struct cma_hdr *hdr;
-
-	if ((listen_id->route.addr.src_addr.ss_family == AF_IB) &&
-	    (ib_event->event == IB_CM_REQ_RECEIVED)) {
-		cma_save_ib_info(id, listen_id, ib_event->param.req_rcvd.primary_path);
-		return 0;
-	}
-
-	hdr = ib_event->private_data;
-	if (hdr->cma_version != CMA_VERSION)
-		return -EINVAL;
-
-	switch (cma_get_ip_ver(hdr)) {
-	case 4:
-		cma_save_ip4_info(id, listen_id, hdr);
-		break;
-	case 6:
-		cma_save_ip6_info(id, listen_id, hdr);
-		break;
-	default:
-		return -EINVAL;
-	}
-	return 0;
-}
-
 static inline int cma_user_data_offset(struct rdma_id_private *id_priv)
 {
-	return cma_family(id_priv) == AF_IB ? 0 : sizeof(struct cma_hdr);
+	return cma_family(id_priv) == AF_IB ? 0 : sizeof(struct cm_hdr);
 }
 
 static void cma_cancel_route(struct rdma_id_private *id_priv)
@@ -1195,7 +1086,9 @@ static struct rdma_id_private *cma_new_conn_id(struct rdma_cm_id *listen_id,
 		return NULL;
 
 	id_priv = container_of(id, struct rdma_id_private, id);
-	if (cma_save_net_info(id, listen_id, ib_event))
+	if (cm_save_net_info((struct sockaddr *)&id->route.addr.src_addr,
+			     (struct sockaddr *)&id->route.addr.dst_addr,
+			     ib_event))
 		goto err;
 
 	rt = &id->route;
@@ -1241,7 +1134,9 @@ static struct rdma_id_private *cma_new_udp_id(struct rdma_cm_id *listen_id,
 		return NULL;
 
 	id_priv = container_of(id, struct rdma_id_private, id);
-	if (cma_save_net_info(id, listen_id, ib_event))
+	if (cm_save_net_info((struct sockaddr *)&id->route.addr.src_addr,
+			     (struct sockaddr *)&id->route.addr.dst_addr,
+			     ib_event))
 		goto err;
 
 	if (!cma_any_addr((struct sockaddr *) &id->route.addr.src_addr)) {
@@ -1369,7 +1264,7 @@ EXPORT_SYMBOL(rdma_get_service_id);
 static void cma_set_compare_data(enum rdma_port_space ps, struct sockaddr *addr,
 				 struct ib_cm_compare_data *compare)
 {
-	struct cma_hdr *cma_data, *cma_mask;
+	struct cm_hdr *cma_data, *cma_mask;
 	__be32 ip4_addr;
 	struct in6_addr ip6_addr;
 
@@ -1380,8 +1275,8 @@ static void cma_set_compare_data(enum rdma_port_space ps, struct sockaddr *addr,
 	switch (addr->sa_family) {
 	case AF_INET:
 		ip4_addr = ((struct sockaddr_in *) addr)->sin_addr.s_addr;
-		cma_set_ip_ver(cma_data, 4);
-		cma_set_ip_ver(cma_mask, 0xF);
+		cm_set_ip_ver(cma_data, 4);
+		cm_set_ip_ver(cma_mask, 0xF);
 		if (!cma_any_addr(addr)) {
 			cma_data->dst_addr.ip4.addr = ip4_addr;
 			cma_mask->dst_addr.ip4.addr = htonl(~0);
@@ -1389,8 +1284,8 @@ static void cma_set_compare_data(enum rdma_port_space ps, struct sockaddr *addr,
 		break;
 	case AF_INET6:
 		ip6_addr = ((struct sockaddr_in6 *) addr)->sin6_addr;
-		cma_set_ip_ver(cma_data, 6);
-		cma_set_ip_ver(cma_mask, 0xF);
+		cm_set_ip_ver(cma_data, 6);
+		cm_set_ip_ver(cma_mask, 0xF);
 		if (!cma_any_addr(addr)) {
 			cma_data->dst_addr.ip6 = ip6_addr;
 			memset(&cma_mask->dst_addr.ip6, 0xFF,
@@ -2615,35 +2510,6 @@ err1:
 }
 EXPORT_SYMBOL(rdma_bind_addr);
 
-static int cma_format_hdr(void *hdr, struct rdma_id_private *id_priv)
-{
-	struct cma_hdr *cma_hdr;
-
-	cma_hdr = hdr;
-	cma_hdr->cma_version = CMA_VERSION;
-	if (cma_family(id_priv) == AF_INET) {
-		struct sockaddr_in *src4, *dst4;
-
-		src4 = (struct sockaddr_in *) cma_src_addr(id_priv);
-		dst4 = (struct sockaddr_in *) cma_dst_addr(id_priv);
-
-		cma_set_ip_ver(cma_hdr, 4);
-		cma_hdr->src_addr.ip4.addr = src4->sin_addr.s_addr;
-		cma_hdr->dst_addr.ip4.addr = dst4->sin_addr.s_addr;
-		cma_hdr->port = src4->sin_port;
-	} else if (cma_family(id_priv) == AF_INET6) {
-		struct sockaddr_in6 *src6, *dst6;
-
-		src6 = (struct sockaddr_in6 *) cma_src_addr(id_priv);
-		dst6 = (struct sockaddr_in6 *) cma_dst_addr(id_priv);
-
-		cma_set_ip_ver(cma_hdr, 6);
-		cma_hdr->src_addr.ip6 = src6->sin6_addr;
-		cma_hdr->dst_addr.ip6 = dst6->sin6_addr;
-		cma_hdr->port = src6->sin6_port;
-	}
-	return 0;
-}
 
 static int cma_sidr_rep_handler(struct ib_cm_id *cm_id,
 				struct ib_cm_event *ib_event)
@@ -2731,7 +2597,9 @@ static int cma_resolve_ib_udp(struct rdma_id_private *id_priv,
 		       conn_param->private_data_len);
 
 	if (private_data) {
-		ret = cma_format_hdr(private_data, id_priv);
+		ret = cm_format_hdr(private_data, cma_family(id_priv),
+				    cma_src_addr(id_priv),
+				    cma_dst_addr(id_priv));
 		if (ret)
 			goto out;
 		req.private_data = private_data;
@@ -2796,7 +2664,9 @@ static int cma_connect_ib(struct rdma_id_private *id_priv,
 
 	route = &id_priv->id.route;
 	if (private_data) {
-		ret = cma_format_hdr(private_data, id_priv);
+		ret = cm_format_hdr(private_data, cma_family(id_priv),
+				    cma_src_addr(id_priv),
+				    cma_dst_addr(id_priv));
 		if (ret)
 			goto out;
 		req.private_data = private_data;
diff --git a/include/rdma/ib_cm.h b/include/rdma/ib_cm.h
index 0e3ff30647d5..e418a11afcfe 100644
--- a/include/rdma/ib_cm.h
+++ b/include/rdma/ib_cm.h
@@ -274,6 +274,52 @@ struct ib_cm_event {
 #define CM_LAP_ATTR_ID		cpu_to_be16(0x0019)
 #define CM_APR_ATTR_ID		cpu_to_be16(0x001A)
 
+union cm_ip_addr {
+	struct in6_addr ip6;
+	struct {
+		__be32 pad[3];
+		__be32 addr;
+	} ip4;
+};
+
+struct cm_hdr {
+	u8 cm_version;
+	u8 ip_version;	/* IP version: 7:4 */
+	__be16 port;
+	union cm_ip_addr src_addr;
+	union cm_ip_addr dst_addr;
+};
+
+#define RDMA_IP_CM_VERSION 0x00
+
+/**
+ * cm_format_hdr - Fill in a cm_hdr struct according to connection details
+ * @hdr:      cm_hdr struct to fill
+ * @family:   ip family of the addresses - AF_INET or AF_INTET6
+ * @src_addr: source address of the connection
+ * @dst_addr: destination address of the connection
+ **/
+int cm_format_hdr(void *hdr, int family,
+		  struct sockaddr *src_addr,
+		  struct sockaddr *dst_addr);
+
+/**
+ * cm_save_net_info - saves ib connection event details
+ * @src_addr: source address of the connection
+ * @dst_addr: destination address of the connection
+ * @ib_event: ib event to take connection details from
+ **/
+int cm_save_net_info(struct sockaddr *src_addr,
+		     struct sockaddr *dst_addr,
+		     struct ib_cm_event *ib_event);
+
+/**
+ * cm_set_ip_ver - sets the ip version of a cm_hdr struct
+ * @hdr:    cm_hdr struct to change
+ * @ip_ver: ip version to set - a 4 bit value
+ **/
+void cm_set_ip_ver(struct cm_hdr *hdr, u8 ip_ver);
+
 /**
  * ib_cm_handler - User-defined callback to process communication events.
  * @cm_id: Communication identifier associated with the reported event.
-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
