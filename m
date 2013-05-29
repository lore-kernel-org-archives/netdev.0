From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v5 14/28] rdma/cm: Remove unused SDP related code
Date: Wed, 29 May 2013 10:09:20 -0700
Message-ID: <1369847374-12176-15-git-send-email-sean.hefty@intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1369847374-12176-1-git-send-email-sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

The SDP protocol was never merged upstream.  Remove unused
SDP related code from the RDMA CM.

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/cma.c |  176 +++++++---------------------------------
 1 files changed, 31 insertions(+), 145 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index d307c94..d53d056 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -80,7 +80,6 @@ static LIST_HEAD(dev_list);
 static LIST_HEAD(listen_any_list);
 static DEFINE_MUTEX(lock);
 static struct workqueue_struct *cma_wq;
-static DEFINE_IDR(sdp_ps);
 static DEFINE_IDR(tcp_ps);
 static DEFINE_IDR(udp_ps);
 static DEFINE_IDR(ipoib_ps);
@@ -196,24 +195,7 @@ struct cma_hdr {
 	union cma_ip_addr dst_addr;
 };
 
-struct sdp_hh {
-	u8 bsdh[16];
-	u8 sdp_version; /* Major version: 7:4 */
-	u8 ip_version;	/* IP version: 7:4 */
-	u8 sdp_specific1[10];
-	__be16 port;
-	__be16 sdp_specific2;
-	union cma_ip_addr src_addr;
-	union cma_ip_addr dst_addr;
-};
-
-struct sdp_hah {
-	u8 bsdh[16];
-	u8 sdp_version;
-};
-
 #define CMA_VERSION 0x00
-#define SDP_MAJ_VERSION 0x2
 
 static int cma_comp(struct rdma_id_private *id_priv, enum rdma_cm_state comp)
 {
@@ -262,21 +244,6 @@ static inline void cma_set_ip_ver(struct cma_hdr *hdr, u8 ip_ver)
 	hdr->ip_version = (ip_ver << 4) | (hdr->ip_version & 0xF);
 }
 
-static inline u8 sdp_get_majv(u8 sdp_version)
-{
-	return sdp_version >> 4;
-}
-
-static inline u8 sdp_get_ip_ver(struct sdp_hh *hh)
-{
-	return hh->ip_version >> 4;
-}
-
-static inline void sdp_set_ip_ver(struct sdp_hh *hh, u8 ip_ver)
-{
-	hh->ip_version = (ip_ver << 4) | (hh->ip_version & 0xF);
-}
-
 static void cma_attach_to_dev(struct rdma_id_private *id_priv,
 			      struct cma_device *cma_dev)
 {
@@ -847,27 +814,13 @@ static int cma_get_net_info(void *hdr, enum rdma_port_space ps,
 			    u8 *ip_ver, __be16 *port,
 			    union cma_ip_addr **src, union cma_ip_addr **dst)
 {
-	switch (ps) {
-	case RDMA_PS_SDP:
-		if (sdp_get_majv(((struct sdp_hh *) hdr)->sdp_version) !=
-		    SDP_MAJ_VERSION)
-			return -EINVAL;
-
-		*ip_ver	= sdp_get_ip_ver(hdr);
-		*port	= ((struct sdp_hh *) hdr)->port;
-		*src	= &((struct sdp_hh *) hdr)->src_addr;
-		*dst	= &((struct sdp_hh *) hdr)->dst_addr;
-		break;
-	default:
-		if (((struct cma_hdr *) hdr)->cma_version != CMA_VERSION)
-			return -EINVAL;
+	if (((struct cma_hdr *) hdr)->cma_version != CMA_VERSION)
+		return -EINVAL;
 
-		*ip_ver	= cma_get_ip_ver(hdr);
-		*port	= ((struct cma_hdr *) hdr)->port;
-		*src	= &((struct cma_hdr *) hdr)->src_addr;
-		*dst	= &((struct cma_hdr *) hdr)->dst_addr;
-		break;
-	}
+	*ip_ver	= cma_get_ip_ver(hdr);
+	*port	= ((struct cma_hdr *) hdr)->port;
+	*src	= &((struct cma_hdr *) hdr)->src_addr;
+	*dst	= &((struct cma_hdr *) hdr)->dst_addr;
 
 	if (*ip_ver != 4 && *ip_ver != 6)
 		return -EINVAL;
@@ -914,12 +867,7 @@ static void cma_save_net_info(struct rdma_addr *addr,
 
 static inline int cma_user_data_offset(enum rdma_port_space ps)
 {
-	switch (ps) {
-	case RDMA_PS_SDP:
-		return 0;
-	default:
-		return sizeof(struct cma_hdr);
-	}
+	return sizeof(struct cma_hdr);
 }
 
 static void cma_cancel_route(struct rdma_id_private *id_priv)
@@ -1085,16 +1033,6 @@ reject:
 	return ret;
 }
 
-static int cma_verify_rep(struct rdma_id_private *id_priv, void *data)
-{
-	if (id_priv->id.ps == RDMA_PS_SDP &&
-	    sdp_get_majv(((struct sdp_hah *) data)->sdp_version) !=
-	    SDP_MAJ_VERSION)
-		return -EINVAL;
-
-	return 0;
-}
-
 static void cma_set_rep_event_data(struct rdma_cm_event *event,
 				   struct ib_cm_rep_event_param *rep_data,
 				   void *private_data)
@@ -1129,15 +1067,13 @@ static int cma_ib_handler(struct ib_cm_id *cm_id, struct ib_cm_event *ib_event)
 		event.status = -ETIMEDOUT;
 		break;
 	case IB_CM_REP_RECEIVED:
-		event.status = cma_verify_rep(id_priv, ib_event->private_data);
-		if (event.status)
-			event.event = RDMA_CM_EVENT_CONNECT_ERROR;
-		else if (id_priv->id.qp && id_priv->id.ps != RDMA_PS_SDP) {
+		if (id_priv->id.qp) {
 			event.status = cma_rep_recv(id_priv);
 			event.event = event.status ? RDMA_CM_EVENT_CONNECT_ERROR :
 						     RDMA_CM_EVENT_ESTABLISHED;
-		} else
+		} else {
 			event.event = RDMA_CM_EVENT_CONNECT_RESPONSE;
+		}
 		cma_set_rep_event_data(&event, &ib_event->param.rep_rcvd,
 				       ib_event->private_data);
 		break;
@@ -1389,49 +1325,31 @@ static void cma_set_compare_data(enum rdma_port_space ps, struct sockaddr *addr,
 				 struct ib_cm_compare_data *compare)
 {
 	struct cma_hdr *cma_data, *cma_mask;
-	struct sdp_hh *sdp_data, *sdp_mask;
 	__be32 ip4_addr;
 	struct in6_addr ip6_addr;
 
 	memset(compare, 0, sizeof *compare);
 	cma_data = (void *) compare->data;
 	cma_mask = (void *) compare->mask;
-	sdp_data = (void *) compare->data;
-	sdp_mask = (void *) compare->mask;
 
 	switch (addr->sa_family) {
 	case AF_INET:
 		ip4_addr = ((struct sockaddr_in *) addr)->sin_addr.s_addr;
-		if (ps == RDMA_PS_SDP) {
-			sdp_set_ip_ver(sdp_data, 4);
-			sdp_set_ip_ver(sdp_mask, 0xF);
-			sdp_data->dst_addr.ip4.addr = ip4_addr;
-			sdp_mask->dst_addr.ip4.addr = htonl(~0);
-		} else {
-			cma_set_ip_ver(cma_data, 4);
-			cma_set_ip_ver(cma_mask, 0xF);
-			if (!cma_any_addr(addr)) {
-				cma_data->dst_addr.ip4.addr = ip4_addr;
-				cma_mask->dst_addr.ip4.addr = htonl(~0);
-			}
+		cma_set_ip_ver(cma_data, 4);
+		cma_set_ip_ver(cma_mask, 0xF);
+		if (!cma_any_addr(addr)) {
+			cma_data->dst_addr.ip4.addr = ip4_addr;
+			cma_mask->dst_addr.ip4.addr = htonl(~0);
 		}
 		break;
 	case AF_INET6:
 		ip6_addr = ((struct sockaddr_in6 *) addr)->sin6_addr;
-		if (ps == RDMA_PS_SDP) {
-			sdp_set_ip_ver(sdp_data, 6);
-			sdp_set_ip_ver(sdp_mask, 0xF);
-			sdp_data->dst_addr.ip6 = ip6_addr;
-			memset(&sdp_mask->dst_addr.ip6, 0xFF,
-			       sizeof sdp_mask->dst_addr.ip6);
-		} else {
-			cma_set_ip_ver(cma_data, 6);
-			cma_set_ip_ver(cma_mask, 0xF);
-			if (!cma_any_addr(addr)) {
-				cma_data->dst_addr.ip6 = ip6_addr;
-				memset(&cma_mask->dst_addr.ip6, 0xFF,
-				       sizeof cma_mask->dst_addr.ip6);
-			}
+		cma_set_ip_ver(cma_data, 6);
+		cma_set_ip_ver(cma_mask, 0xF);
+		if (!cma_any_addr(addr)) {
+			cma_data->dst_addr.ip6 = ip6_addr;
+			memset(&cma_mask->dst_addr.ip6, 0xFF,
+			       sizeof cma_mask->dst_addr.ip6);
 		}
 		break;
 	default:
@@ -2452,8 +2370,6 @@ static int cma_bind_listen(struct rdma_id_private *id_priv)
 static struct idr *cma_select_inet_ps(struct rdma_id_private *id_priv)
 {
 	switch (id_priv->id.ps) {
-	case RDMA_PS_SDP:
-		return &sdp_ps;
 	case RDMA_PS_TCP:
 		return &tcp_ps;
 	case RDMA_PS_UDP:
@@ -2642,58 +2558,29 @@ EXPORT_SYMBOL(rdma_bind_addr);
 static int cma_format_hdr(void *hdr, struct rdma_id_private *id_priv)
 {
 	struct cma_hdr *cma_hdr;
-	struct sdp_hh *sdp_hdr;
 
+	cma_hdr = hdr;
+	cma_hdr->cma_version = CMA_VERSION;
 	if (cma_family(id_priv) == AF_INET) {
 		struct sockaddr_in *src4, *dst4;
 
 		src4 = (struct sockaddr_in *) cma_src_addr(id_priv);
 		dst4 = (struct sockaddr_in *) cma_dst_addr(id_priv);
 
-		switch (id_priv->id.ps) {
-		case RDMA_PS_SDP:
-			sdp_hdr = hdr;
-			if (sdp_get_majv(sdp_hdr->sdp_version) != SDP_MAJ_VERSION)
-				return -EINVAL;
-			sdp_set_ip_ver(sdp_hdr, 4);
-			sdp_hdr->src_addr.ip4.addr = src4->sin_addr.s_addr;
-			sdp_hdr->dst_addr.ip4.addr = dst4->sin_addr.s_addr;
-			sdp_hdr->port = src4->sin_port;
-			break;
-		default:
-			cma_hdr = hdr;
-			cma_hdr->cma_version = CMA_VERSION;
-			cma_set_ip_ver(cma_hdr, 4);
-			cma_hdr->src_addr.ip4.addr = src4->sin_addr.s_addr;
-			cma_hdr->dst_addr.ip4.addr = dst4->sin_addr.s_addr;
-			cma_hdr->port = src4->sin_port;
-			break;
-		}
+		cma_set_ip_ver(cma_hdr, 4);
+		cma_hdr->src_addr.ip4.addr = src4->sin_addr.s_addr;
+		cma_hdr->dst_addr.ip4.addr = dst4->sin_addr.s_addr;
+		cma_hdr->port = src4->sin_port;
 	} else {
 		struct sockaddr_in6 *src6, *dst6;
 
 		src6 = (struct sockaddr_in6 *) cma_src_addr(id_priv);
 		dst6 = (struct sockaddr_in6 *) cma_dst_addr(id_priv);
 
-		switch (id_priv->id.ps) {
-		case RDMA_PS_SDP:
-			sdp_hdr = hdr;
-			if (sdp_get_majv(sdp_hdr->sdp_version) != SDP_MAJ_VERSION)
-				return -EINVAL;
-			sdp_set_ip_ver(sdp_hdr, 6);
-			sdp_hdr->src_addr.ip6 = src6->sin6_addr;
-			sdp_hdr->dst_addr.ip6 = dst6->sin6_addr;
-			sdp_hdr->port = src6->sin6_port;
-			break;
-		default:
-			cma_hdr = hdr;
-			cma_hdr->cma_version = CMA_VERSION;
-			cma_set_ip_ver(cma_hdr, 6);
-			cma_hdr->src_addr.ip6 = src6->sin6_addr;
-			cma_hdr->dst_addr.ip6 = dst6->sin6_addr;
-			cma_hdr->port = src6->sin6_port;
-			break;
-		}
+		cma_set_ip_ver(cma_hdr, 6);
+		cma_hdr->src_addr.ip6 = src6->sin6_addr;
+		cma_hdr->dst_addr.ip6 = dst6->sin6_addr;
+		cma_hdr->port = src6->sin6_port;
 	}
 	return 0;
 }
@@ -3747,7 +3634,6 @@ static void __exit cma_cleanup(void)
 	rdma_addr_unregister_client(&addr_client);
 	ib_sa_unregister_client(&sa_client);
 	destroy_workqueue(cma_wq);
-	idr_destroy(&sdp_ps);
 	idr_destroy(&tcp_ps);
 	idr_destroy(&udp_ps);
 	idr_destroy(&ipoib_ps);
-- 
1.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
