From: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCHv6 06/10] ib_core: CMA device binding
Date: Mon, 16 Nov 2009 17:53:48 +0200
Message-ID: <20091116155348.GG2463@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux RDMA list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ewg <ewg-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <ewg-bounces-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/ewg>,
	<mailto:ewg-request-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/ewg>
List-Post: <mailto:ewg-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
List-Help: <mailto:ewg-request-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/ewg>,
	<mailto:ewg-request-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org?subject=subscribe>
Sender: ewg-bounces-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org
Errors-To: ewg-bounces-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org
List-Id: netdev.vger.kernel.org

Add support for RDMAoE device binding and IP --> GID resolution. Path resolving
and multicast joining are implemented within cma.c by filling the responses and
pushing the callbacks to the cma work queue. IP->GID resolution always yields
IPv6 link local addresses - remote GIDs are derived from the destination MAC
address of the remote port. Multicast GIDs are always mapped to multicast MACs
as is done in IPv6. Some helper functions are added to ib_addr.h.  IPv4
multicast is enabled by translating IPv4 multicast addresses to IPv6 multicast
as described in
http://www.mail-archive.com/ipng-Va8kgSFw1KyzQ7sTrsxvMkEOCMrvLtNR@public.gmane.org/msg02134.html.

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/infiniband/core/cma.c  |  218 ++++++++++++++++++++++++++++++++++++++-
 drivers/infiniband/core/ucma.c |   31 ++++++
 include/rdma/ib_addr.h         |   92 +++++++++++++++++
 3 files changed, 335 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 8dc3472..ad1cd75 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -58,6 +58,7 @@ MODULE_LICENSE("Dual BSD/GPL");
 #define CMA_CM_RESPONSE_TIMEOUT 20
 #define CMA_MAX_CM_RETRIES 15
 #define CMA_CM_MRA_SETTING (IB_CM_MRA_FLAG_DELAY | 24)
+#define RDMAOE_PACKET_LIFETIME 18
 
 static void cma_add_one(struct ib_device *device);
 static void cma_remove_one(struct ib_device *device);
@@ -157,6 +158,7 @@ struct cma_multicast {
 	struct list_head	list;
 	void			*context;
 	struct sockaddr_storage	addr;
+	struct kref		mcref;
 };
 
 struct cma_work {
@@ -173,6 +175,12 @@ struct cma_ndev_work {
 	struct rdma_cm_event	event;
 };
 
+struct rdmaoe_mcast_work {
+	struct work_struct	 work;
+	struct rdma_id_private	*id;
+	struct cma_multicast	*mc;
+};
+
 union cma_ip_addr {
 	struct in6_addr ip6;
 	struct {
@@ -290,6 +298,14 @@ static inline void cma_deref_dev(struct cma_device *cma_dev)
 		complete(&cma_dev->comp);
 }
 
+static inline void release_mc(struct kref *kref)
+{
+	struct cma_multicast *mc = container_of(kref, struct cma_multicast, mcref);
+
+	kfree(mc->multicast.ib);
+	kfree(mc);
+}
+
 static void cma_detach_from_dev(struct rdma_id_private *id_priv)
 {
 	list_del(&id_priv->list);
@@ -340,6 +356,9 @@ static int cma_acquire_dev(struct rdma_id_private *id_priv)
 			case RDMA_TRANSPORT_IWARP:
 				iw_addr_get_sgid(dev_addr, &gid);
 				break;
+			case RDMA_TRANSPORT_RDMAOE:
+				rdmaoe_addr_get_sgid(dev_addr, &gid);
+				break;
 			default:
 				return -ENODEV;
 			}
@@ -568,10 +587,16 @@ static int cma_ib_init_qp_attr(struct rdma_id_private *id_priv,
 {
 	struct rdma_dev_addr *dev_addr = &id_priv->id.route.addr.dev_addr;
 	int ret;
+	u16 pkey;
+
+	if (rdma_port_get_transport(id_priv->id.device, id_priv->id.port_num) ==
+	    RDMA_TRANSPORT_IB)
+		pkey = ib_addr_get_pkey(dev_addr);
+	else
+		pkey = 0xffff;
 
 	ret = ib_find_cached_pkey(id_priv->id.device, id_priv->id.port_num,
-				  ib_addr_get_pkey(dev_addr),
-				  &qp_attr->pkey_index);
+				  pkey, &qp_attr->pkey_index);
 	if (ret)
 		return ret;
 
@@ -601,6 +626,7 @@ int rdma_init_qp_attr(struct rdma_cm_id *id, struct ib_qp_attr *qp_attr,
 	id_priv = container_of(id, struct rdma_id_private, id);
 	switch (rdma_port_get_transport(id_priv->id.device, id_priv->id.port_num)) {
 	case RDMA_TRANSPORT_IB:
+	case RDMA_TRANSPORT_RDMAOE:
 		if (!id_priv->cm_id.ib || cma_is_ud_ps(id_priv->id.ps))
 			ret = cma_ib_init_qp_attr(id_priv, qp_attr, qp_attr_mask);
 		else
@@ -828,8 +854,17 @@ static void cma_leave_mc_groups(struct rdma_id_private *id_priv)
 		mc = container_of(id_priv->mc_list.next,
 				  struct cma_multicast, list);
 		list_del(&mc->list);
-		ib_sa_free_multicast(mc->multicast.ib);
-		kfree(mc);
+		switch (rdma_port_get_transport(id_priv->cma_dev->device, id_priv->id.port_num)) {
+		case RDMA_TRANSPORT_IB:
+			ib_sa_free_multicast(mc->multicast.ib);
+			kfree(mc);
+			break;
+		case RDMA_TRANSPORT_RDMAOE:
+			kref_put(&mc->mcref, release_mc);
+			break;
+		default:
+			break;
+		}
 	}
 }
 
@@ -847,6 +882,7 @@ void rdma_destroy_id(struct rdma_cm_id *id)
 		mutex_unlock(&lock);
 		switch (rdma_port_get_transport(id_priv->id.device, id_priv->id.port_num)) {
 		case RDMA_TRANSPORT_IB:
+		case RDMA_TRANSPORT_RDMAOE:
 			if (id_priv->cm_id.ib && !IS_ERR(id_priv->cm_id.ib))
 				ib_destroy_cm_id(id_priv->cm_id.ib);
 			break;
@@ -1504,6 +1540,7 @@ int rdma_listen(struct rdma_cm_id *id, int backlog)
 	if (id->device) {
 		switch (rdma_port_get_transport(id->device, id->port_num)) {
 		case RDMA_TRANSPORT_IB:
+		case RDMA_TRANSPORT_RDMAOE:
 			ret = cma_ib_listen(id_priv);
 			if (ret)
 				goto err;
@@ -1719,6 +1756,66 @@ static int cma_resolve_iw_route(struct rdma_id_private *id_priv, int timeout_ms)
 	return 0;
 }
 
+static int cma_resolve_rdmaoe_route(struct rdma_id_private *id_priv)
+{
+	struct rdma_route *route = &id_priv->id.route;
+	struct rdma_addr *addr = &route->addr;
+	struct cma_work *work;
+	int ret;
+	struct sockaddr_in *src_addr = (struct sockaddr_in *)&route->addr.src_addr;
+	struct sockaddr_in *dst_addr = (struct sockaddr_in *)&route->addr.dst_addr;
+
+	if (src_addr->sin_family != dst_addr->sin_family)
+		return -EINVAL;
+
+	work = kzalloc(sizeof *work, GFP_KERNEL);
+	if (!work)
+		return -ENOMEM;
+
+	work->id = id_priv;
+	INIT_WORK(&work->work, cma_work_handler);
+
+	route->path_rec = kzalloc(sizeof *route->path_rec, GFP_KERNEL);
+	if (!route->path_rec) {
+		ret = -ENOMEM;
+		goto err1;
+	}
+
+	route->num_paths = 1;
+
+	rdmaoe_mac_to_ll(&route->path_rec->sgid, addr->dev_addr.src_dev_addr);
+	rdmaoe_mac_to_ll(&route->path_rec->dgid, addr->dev_addr.dst_dev_addr);
+
+	route->path_rec->hop_limit = 2;
+	route->path_rec->reversible = 1;
+	route->path_rec->pkey = cpu_to_be16(0xffff);
+	route->path_rec->mtu_selector = 2;
+	route->path_rec->mtu = rdmaoe_get_mtu(addr->dev_addr.src_dev->mtu);
+	route->path_rec->rate_selector = 2;
+	route->path_rec->rate = rdmaoe_get_rate(addr->dev_addr.src_dev);
+	route->path_rec->packet_life_time_selector = 2;
+	route->path_rec->packet_life_time = RDMAOE_PACKET_LIFETIME;
+	if (!route->path_rec->mtu) {
+		ret = -EINVAL;
+		goto err2;
+	}
+
+	work->old_state = CMA_ROUTE_QUERY;
+	work->new_state = CMA_ROUTE_RESOLVED;
+	work->event.event = RDMA_CM_EVENT_ROUTE_RESOLVED;
+	work->event.status = 0;
+
+	queue_work(cma_wq, &work->work);
+
+	return 0;
+
+err2:
+	kfree(route->path_rec);
+err1:
+	kfree(work);
+	return ret;
+}
+
 int rdma_resolve_route(struct rdma_cm_id *id, int timeout_ms)
 {
 	struct rdma_id_private *id_priv;
@@ -1736,6 +1833,9 @@ int rdma_resolve_route(struct rdma_cm_id *id, int timeout_ms)
 	case RDMA_TRANSPORT_IWARP:
 		ret = cma_resolve_iw_route(id_priv, timeout_ms);
 		break;
+	case RDMA_TRANSPORT_RDMAOE:
+		ret = cma_resolve_rdmaoe_route(id_priv);
+		break;
 	default:
 		ret = -ENOSYS;
 		break;
@@ -2411,6 +2511,7 @@ int rdma_connect(struct rdma_cm_id *id, struct rdma_conn_param *conn_param)
 
 	switch (rdma_port_get_transport(id->device, id->port_num)) {
 	case RDMA_TRANSPORT_IB:
+	case RDMA_TRANSPORT_RDMAOE:
 		if (cma_is_ud_ps(id->ps))
 			ret = cma_resolve_ib_udp(id_priv, conn_param);
 		else
@@ -2524,6 +2625,7 @@ int rdma_accept(struct rdma_cm_id *id, struct rdma_conn_param *conn_param)
 
 	switch (rdma_port_get_transport(id->device, id->port_num)) {
 	case RDMA_TRANSPORT_IB:
+	case RDMA_TRANSPORT_RDMAOE:
 		if (cma_is_ud_ps(id->ps))
 			ret = cma_send_sidr_rep(id_priv, IB_SIDR_SUCCESS,
 						conn_param->private_data,
@@ -2585,6 +2687,7 @@ int rdma_reject(struct rdma_cm_id *id, const void *private_data,
 
 	switch (rdma_port_get_transport(id->device, id->port_num)) {
 	case RDMA_TRANSPORT_IB:
+	case RDMA_TRANSPORT_RDMAOE:
 		if (cma_is_ud_ps(id->ps))
 			ret = cma_send_sidr_rep(id_priv, IB_SIDR_REJECT,
 						private_data, private_data_len);
@@ -2616,6 +2719,7 @@ int rdma_disconnect(struct rdma_cm_id *id)
 
 	switch (rdma_port_get_transport(id->device, id->port_num)) {
 	case RDMA_TRANSPORT_IB:
+	case RDMA_TRANSPORT_RDMAOE:
 		ret = cma_modify_qp_err(id_priv);
 		if (ret)
 			goto out;
@@ -2742,6 +2846,94 @@ static int cma_join_ib_multicast(struct rdma_id_private *id_priv,
 	return 0;
 }
 
+
+static void rdmaoe_mcast_work_handler(struct work_struct *work)
+{
+	struct rdmaoe_mcast_work *mw = container_of(work, struct rdmaoe_mcast_work, work);
+	struct cma_multicast *mc = mw->mc;
+	struct ib_sa_multicast *m = mc->multicast.ib;
+
+	mc->multicast.ib->context = mc;
+	cma_ib_mc_handler(0, m);
+	kref_put(&mc->mcref, release_mc);
+	kfree(mw);
+}
+
+static void cma_rdmaoe_set_mgid(struct sockaddr *addr, union ib_gid *mgid)
+{
+	struct sockaddr_in *sin = (struct sockaddr_in *)addr;
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)addr;
+
+	if (cma_any_addr(addr)) {
+		memset(mgid, 0, sizeof *mgid);
+	} else if (addr->sa_family == AF_INET6)
+		memcpy(mgid, &sin6->sin6_addr, sizeof *mgid);
+	else {
+		mgid->raw[0] = 0xff;
+		mgid->raw[1] = 0x0e;
+		mgid->raw[2] = 0xff;
+		mgid->raw[3] = 0xff;
+		mgid->raw[4] = 0;
+		mgid->raw[5] = 0;
+		mgid->raw[6] = 0;
+		mgid->raw[7] = 0;
+		mgid->raw[8] = 0;
+		mgid->raw[9] = 0;
+		mgid->raw[10] = 0xff;
+		mgid->raw[11] = 0xff;
+		*(__be32 *)(&mgid->raw[12]) = sin->sin_addr.s_addr;
+	}
+}
+
+static int cma_rdmaoe_join_multicast(struct rdma_id_private *id_priv,
+				     struct cma_multicast *mc)
+{
+	struct rdmaoe_mcast_work *work;
+	struct rdma_dev_addr *dev_addr = &id_priv->id.route.addr.dev_addr;
+	int err;
+	struct sockaddr *addr = (struct sockaddr *)&mc->addr;
+
+	if (cma_zero_addr((struct sockaddr *)&mc->addr))
+		return -EINVAL;
+
+	work = kzalloc(sizeof *work, GFP_KERNEL);
+	if (!work)
+		return -ENOMEM;
+
+	mc->multicast.ib = kzalloc(sizeof(struct ib_sa_multicast), GFP_KERNEL);
+	if (!mc->multicast.ib) {
+		err = -ENOMEM;
+		goto out1;
+	}
+
+	cma_rdmaoe_set_mgid(addr, &mc->multicast.ib->rec.mgid);
+
+	mc->multicast.ib->rec.pkey = cpu_to_be16(0xffff);
+	if (id_priv->id.ps == RDMA_PS_UDP)
+		mc->multicast.ib->rec.qkey = cpu_to_be32(RDMA_UDP_QKEY);
+	mc->multicast.ib->rec.rate = rdmaoe_get_rate(dev_addr->src_dev);
+	mc->multicast.ib->rec.hop_limit = 1;
+	mc->multicast.ib->rec.mtu = rdmaoe_get_mtu(dev_addr->src_dev->mtu);
+	if (!mc->multicast.ib->rec.mtu) {
+		err = -EINVAL;
+		goto out2;
+	}
+	rdmaoe_addr_get_sgid(dev_addr, &mc->multicast.ib->rec.port_gid);
+	work->id = id_priv;
+	work->mc = mc;
+	INIT_WORK(&work->work, rdmaoe_mcast_work_handler);
+	kref_get(&mc->mcref);
+	queue_work(cma_wq, &work->work);
+
+	return 0;
+
+out2:
+	kfree(mc->multicast.ib);
+out1:
+	kfree(work);
+	return err;
+}
+
 int rdma_join_multicast(struct rdma_cm_id *id, struct sockaddr *addr,
 			void *context)
 {
@@ -2770,6 +2962,10 @@ int rdma_join_multicast(struct rdma_cm_id *id, struct sockaddr *addr,
 	case RDMA_TRANSPORT_IB:
 		ret = cma_join_ib_multicast(id_priv, mc);
 		break;
+	case RDMA_TRANSPORT_RDMAOE:
+		kref_init(&mc->mcref);
+		ret = cma_rdmaoe_join_multicast(id_priv, mc);
+		break;
 	default:
 		ret = -ENOSYS;
 		break;
@@ -2781,6 +2977,7 @@ int rdma_join_multicast(struct rdma_cm_id *id, struct sockaddr *addr,
 		spin_unlock_irq(&id_priv->lock);
 		kfree(mc);
 	}
+
 	return ret;
 }
 EXPORT_SYMBOL(rdma_join_multicast);
@@ -2801,8 +2998,17 @@ void rdma_leave_multicast(struct rdma_cm_id *id, struct sockaddr *addr)
 				ib_detach_mcast(id->qp,
 						&mc->multicast.ib->rec.mgid,
 						mc->multicast.ib->rec.mlid);
-			ib_sa_free_multicast(mc->multicast.ib);
-			kfree(mc);
+			switch (rdma_port_get_transport(id_priv->cma_dev->device, id_priv->id.port_num)) {
+			case RDMA_TRANSPORT_IB:
+				ib_sa_free_multicast(mc->multicast.ib);
+				kfree(mc);
+				break;
+			case RDMA_TRANSPORT_RDMAOE:
+				kref_put(&mc->mcref, release_mc);
+				break;
+			default:
+				break;
+			}
 			return;
 		}
 	}
diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index fd831fd..71d6d66 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -582,6 +582,34 @@ static void ucma_copy_ib_route(struct rdma_ucm_query_route_resp *resp,
 	}
 }
 
+static void ucma_copy_rdmaoe_route(struct rdma_ucm_query_route_resp *resp,
+				   struct rdma_route *route)
+{
+	struct rdma_dev_addr *dev_addr;
+
+	resp->num_paths = route->num_paths;
+	switch (route->num_paths) {
+	case 0:
+		dev_addr = &route->addr.dev_addr;
+		rdmaoe_mac_to_ll((union ib_gid *) &resp->ib_route[0].dgid,
+				 dev_addr->dst_dev_addr);
+		rdmaoe_addr_get_sgid(dev_addr,
+				 (union ib_gid *) &resp->ib_route[0].sgid);
+		resp->ib_route[0].pkey = cpu_to_be16(0xffff);
+		break;
+	case 2:
+		ib_copy_path_rec_to_user(&resp->ib_route[1],
+					 &route->path_rec[1]);
+		/* fall through */
+	case 1:
+		ib_copy_path_rec_to_user(&resp->ib_route[0],
+					 &route->path_rec[0]);
+		break;
+	default:
+		break;
+	}
+}
+
 static ssize_t ucma_query_route(struct ucma_file *file,
 				const char __user *inbuf,
 				int in_len, int out_len)
@@ -620,6 +648,9 @@ static ssize_t ucma_query_route(struct ucma_file *file,
 	case RDMA_TRANSPORT_IB:
 		ucma_copy_ib_route(&resp, &ctx->cm_id->route);
 		break;
+	case RDMA_TRANSPORT_RDMAOE:
+		ucma_copy_rdmaoe_route(&resp, &ctx->cm_id->route);
+		break;
 	default:
 		break;
 	}
diff --git a/include/rdma/ib_addr.h b/include/rdma/ib_addr.h
index 483057b..ab06fe9 100644
--- a/include/rdma/ib_addr.h
+++ b/include/rdma/ib_addr.h
@@ -39,6 +39,8 @@
 #include <linux/netdevice.h>
 #include <linux/socket.h>
 #include <rdma/ib_verbs.h>
+#include <linux/ethtool.h>
+#include <rdma/ib_pack.h>
 
 struct rdma_addr_client {
 	atomic_t refcount;
@@ -157,4 +159,94 @@ static inline void iw_addr_get_dgid(struct rdma_dev_addr *dev_addr,
 	memcpy(gid, dev_addr->dst_dev_addr, sizeof *gid);
 }
 
+static inline void rdmaoe_mac_to_ll(union ib_gid *gid, u8 *mac)
+{
+	memset(gid->raw, 0, 16);
+	*((u32 *)gid->raw) = cpu_to_be32(0xfe800000);
+	gid->raw[12] = 0xfe;
+	gid->raw[11] = 0xff;
+	memcpy(gid->raw + 13, mac + 3, 3);
+	memcpy(gid->raw + 8, mac, 3);
+	gid->raw[8] ^= 2;
+}
+
+static inline void rdmaoe_addr_get_sgid(struct rdma_dev_addr *dev_addr,
+					union ib_gid *gid)
+{
+	rdmaoe_mac_to_ll(gid, dev_addr->src_dev_addr);
+}
+
+static inline enum ib_mtu rdmaoe_get_mtu(int mtu)
+{
+	/*
+	 * reduce IB headers from effective RDMAoE MTU. 28 stands for
+	 * atomic header which is the biggest possible header after BTH
+	 */
+	mtu = mtu - IB_GRH_BYTES - IB_BTH_BYTES - 28;
+
+	if (mtu >= ib_mtu_enum_to_int(IB_MTU_4096))
+		return IB_MTU_4096;
+	else if (mtu >= ib_mtu_enum_to_int(IB_MTU_2048))
+		return IB_MTU_2048;
+	else if (mtu >= ib_mtu_enum_to_int(IB_MTU_1024))
+		return IB_MTU_1024;
+	else if (mtu >= ib_mtu_enum_to_int(IB_MTU_512))
+		return IB_MTU_512;
+	else if (mtu >= ib_mtu_enum_to_int(IB_MTU_256))
+		return IB_MTU_256;
+	else
+		return 0;
+}
+
+static inline int rdmaoe_get_rate(struct net_device *dev)
+{
+	struct ethtool_cmd cmd;
+
+	if (!dev->ethtool_ops || !dev->ethtool_ops->get_settings ||
+	    dev->ethtool_ops->get_settings(dev, &cmd))
+		return IB_RATE_PORT_CURRENT;
+
+	if (cmd.speed >= 40000)
+		return IB_RATE_40_GBPS;
+	else if (cmd.speed >= 30000)
+		return IB_RATE_30_GBPS;
+	else if (cmd.speed >= 20000)
+		return IB_RATE_20_GBPS;
+	else if (cmd.speed >= 10000)
+		return IB_RATE_10_GBPS;
+	else
+		return IB_RATE_PORT_CURRENT;
+}
+
+static inline int rdma_link_local_addr(struct in6_addr *addr)
+{
+	if (addr->s6_addr32[0] == cpu_to_be32(0xfe800000) &&
+	    addr->s6_addr32[1] == 0)
+		return 1;
+
+	return 0;
+}
+
+static inline void rdma_get_ll_mac(struct in6_addr *addr, u8 *mac)
+{
+	memcpy(mac, &addr->s6_addr[8], 3);
+	memcpy(mac + 3, &addr->s6_addr[13], 3);
+	mac[0] ^= 2;
+}
+
+static inline int rdma_is_multicast_addr(struct in6_addr *addr)
+{
+	return addr->s6_addr[0] == 0xff ? 1 : 0;
+}
+
+static inline void rdma_get_mcast_mac(struct in6_addr *addr, u8 *mac)
+{
+	int i;
+
+	mac[0] = 0x33;
+	mac[1] = 0x33;
+	for (i = 2; i < 6; ++i)
+		mac[i] = addr->s6_addr[i + 10];
+}
+
 #endif /* IB_ADDR_H */
-- 
1.6.5.2
