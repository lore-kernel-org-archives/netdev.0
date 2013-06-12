From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH V2 4/4] RDMA/cxgb4: Add support for active and passive open connection with IPv6 address
Date: Wed, 12 Jun 2013 17:11:42 +0530
Message-ID: <1371037302-3586-5-git-send-email-vipul@chelsio.com>
References: <1371037302-3586-1-git-send-email-vipul@chelsio.com>
Cc: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1371037302-3586-1-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add new cpl messages, cpl_act_open_req6 and cpl_t5_act_open_req6, for
initiating active open connections.

Use LLD api cxgb4_create_server and cxgb4_create_server6 for initiating passive
open connections. Similarly use cxgb4_remove_server to remove the passive open
connections in place of listen_stop.

Add support for iWARP over VLAN device and enable IPv6 support on VLAN device.

Make use of import_ep in c4iw_reconnect.

Signed-off-by: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
V2: Used local variables instead of typecasting in patch 1/4.

 drivers/infiniband/hw/cxgb4/cm.c       | 805 ++++++++++++++++++++++-----------
 drivers/infiniband/hw/cxgb4/device.c   | 116 +++--
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h |   4 +-
 3 files changed, 626 insertions(+), 299 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 76d8812..0745ae4 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -44,6 +44,8 @@
 #include <net/netevent.h>
 #include <net/route.h>
 #include <net/tcp.h>
+#include <net/ip6_route.h>
+#include <net/addrconf.h>
 
 #include "iw_cxgb4.h"
 
@@ -333,19 +335,72 @@ static struct sk_buff *get_skb(struct sk_buff *skb, int len, gfp_t gfp)
 	return skb;
 }
 
-static struct rtable *find_route(struct c4iw_dev *dev, __be32 local_ip,
+static struct net_device *get_real_dev(struct net_device *egress_dev)
+{
+	struct net_device *phys_dev = egress_dev;
+	if (egress_dev->priv_flags & IFF_802_1Q_VLAN)
+		phys_dev = vlan_dev_real_dev(egress_dev);
+	return phys_dev;
+}
+
+static int our_interface(struct c4iw_dev *dev, struct net_device *egress_dev)
+{
+	int i;
+
+	egress_dev = get_real_dev(egress_dev);
+	for (i = 0; i < dev->rdev.lldi.nports; i++)
+		if (dev->rdev.lldi.ports[i] == egress_dev)
+			return 1;
+	return 0;
+}
+
+static struct dst_entry *find_route6(struct c4iw_dev *dev, __u8 *local_ip,
+				     __u8 *peer_ip, __be16 local_port,
+				     __be16 peer_port, u8 tos,
+				     __u32 sin6_scope_id)
+{
+	struct flowi6 fl6;
+	struct dst_entry *dst;
+
+	memset(&fl6, 0, sizeof(fl6));
+	memcpy(&fl6.daddr, peer_ip, 16);
+	memcpy(&fl6.saddr, local_ip, 16);
+	if (ipv6_addr_type(&fl6.daddr) & IPV6_ADDR_LINKLOCAL)
+		fl6.flowi6_oif = sin6_scope_id;
+	dst = ip6_route_output(&init_net, NULL, &fl6);
+	if (!dst)
+		goto out;
+	if (!our_interface(dev, ip6_dst_idev(dst)->dev) &&
+	    !(ip6_dst_idev(dst)->dev->flags & IFF_LOOPBACK)) {
+		dst_release(dst);
+		dst = NULL;
+	}
+out:
+	return dst;
+}
+
+static struct dst_entry *find_route(struct c4iw_dev *dev, __be32 local_ip,
 				 __be32 peer_ip, __be16 local_port,
 				 __be16 peer_port, u8 tos)
 {
 	struct rtable *rt;
 	struct flowi4 fl4;
+	struct neighbour *n;
 
 	rt = ip_route_output_ports(&init_net, &fl4, NULL, peer_ip, local_ip,
 				   peer_port, local_port, IPPROTO_TCP,
 				   tos, 0);
 	if (IS_ERR(rt))
 		return NULL;
-	return rt;
+	n = dst_neigh_lookup(&rt->dst, &peer_ip);
+	if (!n)
+		return NULL;
+	if (!our_interface(dev, n->dev)) {
+		dst_release(&rt->dst);
+		return NULL;
+	}
+	neigh_release(n);
+	return &rt->dst;
 }
 
 static void arp_failure_discard(void *handle, struct sk_buff *skb)
@@ -512,15 +567,28 @@ static int send_connect(struct c4iw_ep *ep)
 {
 	struct cpl_act_open_req *req;
 	struct cpl_t5_act_open_req *t5_req;
+	struct cpl_act_open_req6 *req6;
+	struct cpl_t5_act_open_req6 *t5_req6;
 	struct sk_buff *skb;
 	u64 opt0;
 	u32 opt2;
 	unsigned int mtu_idx;
 	int wscale;
-	int size = is_t4(ep->com.dev->rdev.lldi.adapter_type) ?
-		sizeof(struct cpl_act_open_req) :
-		sizeof(struct cpl_t5_act_open_req);
-	int wrlen = roundup(size, 16);
+	int wrlen;
+	int sizev4 = is_t4(ep->com.dev->rdev.lldi.adapter_type) ?
+				sizeof(struct cpl_act_open_req) :
+				sizeof(struct cpl_t5_act_open_req);
+	int sizev6 = is_t4(ep->com.dev->rdev.lldi.adapter_type) ?
+				sizeof(struct cpl_act_open_req6) :
+				sizeof(struct cpl_t5_act_open_req6);
+	struct sockaddr_in *la = (struct sockaddr_in *)&ep->com.local_addr;
+	struct sockaddr_in *ra = (struct sockaddr_in *)&ep->com.remote_addr;
+	struct sockaddr_in6 *la6 = (struct sockaddr_in6 *)&ep->com.local_addr;
+	struct sockaddr_in6 *ra6 = (struct sockaddr_in6 *)&ep->com.remote_addr;
+
+	wrlen = (ep->com.remote_addr.ss_family == AF_INET) ?
+			roundup(sizev4, 16) :
+			roundup(sizev6, 16);
 
 	PDBG("%s ep %p atid %u\n", __func__, ep, ep->atid);
 
@@ -557,33 +625,82 @@ static int send_connect(struct c4iw_ep *ep)
 	t4_set_arp_err_handler(skb, NULL, act_open_req_arp_failure);
 
 	if (is_t4(ep->com.dev->rdev.lldi.adapter_type)) {
-		req = (struct cpl_act_open_req *) skb_put(skb, wrlen);
-		INIT_TP_WR(req, 0);
-		OPCODE_TID(req) = cpu_to_be32(
-				MK_OPCODE_TID(CPL_ACT_OPEN_REQ,
-				((ep->rss_qid << 14) | ep->atid)));
-		req->local_port = ep->com.local_addr.sin_port;
-		req->peer_port = ep->com.remote_addr.sin_port;
-		req->local_ip = ep->com.local_addr.sin_addr.s_addr;
-		req->peer_ip = ep->com.remote_addr.sin_addr.s_addr;
-		req->opt0 = cpu_to_be64(opt0);
-		req->params = cpu_to_be32(select_ntuple(ep->com.dev,
-					ep->dst, ep->l2t));
-		req->opt2 = cpu_to_be32(opt2);
+		if (ep->com.remote_addr.ss_family == AF_INET) {
+			req = (struct cpl_act_open_req *) skb_put(skb, wrlen);
+			INIT_TP_WR(req, 0);
+			OPCODE_TID(req) = cpu_to_be32(
+					MK_OPCODE_TID(CPL_ACT_OPEN_REQ,
+					((ep->rss_qid << 14) | ep->atid)));
+			req->local_port = la->sin_port;
+			req->peer_port = ra->sin_port;
+			req->local_ip = la->sin_addr.s_addr;
+			req->peer_ip = ra->sin_addr.s_addr;
+			req->opt0 = cpu_to_be64(opt0);
+			req->params = cpu_to_be32(select_ntuple(ep->com.dev,
+						ep->dst, ep->l2t));
+			req->opt2 = cpu_to_be32(opt2);
+		} else {
+			req6 = (struct cpl_act_open_req6 *)skb_put(skb, wrlen);
+
+			INIT_TP_WR(req6, 0);
+			OPCODE_TID(req6) = cpu_to_be32(
+					   MK_OPCODE_TID(CPL_ACT_OPEN_REQ6,
+					   ((ep->rss_qid<<14)|ep->atid)));
+			req6->local_port = la6->sin6_port;
+			req6->peer_port = ra6->sin6_port;
+			req6->local_ip_hi = *((__be64 *)
+						(la6->sin6_addr.s6_addr));
+			req6->local_ip_lo = *((__be64 *)
+						(la6->sin6_addr.s6_addr + 8));
+			req6->peer_ip_hi = *((__be64 *)
+						(ra6->sin6_addr.s6_addr));
+			req6->peer_ip_lo = *((__be64 *)
+						(ra6->sin6_addr.s6_addr + 8));
+			req6->opt0 = cpu_to_be64(opt0);
+			req6->params = cpu_to_be32(
+					select_ntuple(ep->com.dev, ep->dst,
+						      ep->l2t));
+			req6->opt2 = cpu_to_be32(opt2);
+		}
 	} else {
-		t5_req = (struct cpl_t5_act_open_req *) skb_put(skb, wrlen);
-		INIT_TP_WR(t5_req, 0);
-		OPCODE_TID(t5_req) = cpu_to_be32(
+		if (ep->com.remote_addr.ss_family == AF_INET) {
+			t5_req = (struct cpl_t5_act_open_req *)
+				 skb_put(skb, wrlen);
+			INIT_TP_WR(t5_req, 0);
+			OPCODE_TID(t5_req) = cpu_to_be32(
 					MK_OPCODE_TID(CPL_ACT_OPEN_REQ,
 					((ep->rss_qid << 14) | ep->atid)));
-		t5_req->local_port = ep->com.local_addr.sin_port;
-		t5_req->peer_port = ep->com.remote_addr.sin_port;
-		t5_req->local_ip = ep->com.local_addr.sin_addr.s_addr;
-		t5_req->peer_ip = ep->com.remote_addr.sin_addr.s_addr;
-		t5_req->opt0 = cpu_to_be64(opt0);
-		t5_req->params = cpu_to_be64(V_FILTER_TUPLE(
-				select_ntuple(ep->com.dev, ep->dst, ep->l2t)));
-		t5_req->opt2 = cpu_to_be32(opt2);
+			t5_req->local_port = la->sin_port;
+			t5_req->peer_port = ra->sin_port;
+			t5_req->local_ip = la->sin_addr.s_addr;
+			t5_req->peer_ip = ra->sin_addr.s_addr;
+			t5_req->opt0 = cpu_to_be64(opt0);
+			t5_req->params = cpu_to_be64(V_FILTER_TUPLE(
+						select_ntuple(ep->com.dev,
+						ep->dst, ep->l2t)));
+			t5_req->opt2 = cpu_to_be32(opt2);
+		} else {
+			t5_req6 = (struct cpl_t5_act_open_req6 *)
+				  skb_put(skb, wrlen);
+			INIT_TP_WR(t5_req6, 0);
+			OPCODE_TID(t5_req6) = cpu_to_be32(
+					      MK_OPCODE_TID(CPL_ACT_OPEN_REQ6,
+					      ((ep->rss_qid<<14)|ep->atid)));
+			t5_req6->local_port = la6->sin6_port;
+			t5_req6->peer_port = ra6->sin6_port;
+			t5_req6->local_ip_hi = *((__be64 *)
+						(la6->sin6_addr.s6_addr));
+			t5_req6->local_ip_lo = *((__be64 *)
+						(la6->sin6_addr.s6_addr + 8));
+			t5_req6->peer_ip_hi = *((__be64 *)
+						(ra6->sin6_addr.s6_addr));
+			t5_req6->peer_ip_lo = *((__be64 *)
+						(ra6->sin6_addr.s6_addr + 8));
+			t5_req6->opt0 = cpu_to_be64(opt0);
+			t5_req6->params = cpu_to_be32(select_ntuple
+					(ep->com.dev, ep->dst, ep->l2t));
+			t5_req6->opt2 = cpu_to_be32(opt2);
+		}
 	}
 
 	set_bit(ACT_OPEN_REQ, &ep->com.history);
@@ -1502,6 +1619,7 @@ static void send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 	struct fw_ofld_connection_wr *req;
 	unsigned int mtu_idx;
 	int wscale;
+	struct sockaddr_in *sin;
 
 	skb = get_skb(NULL, sizeof(*req), GFP_KERNEL);
 	req = (struct fw_ofld_connection_wr *)__skb_put(skb, sizeof(*req));
@@ -1510,10 +1628,12 @@ static void send_fw_act_open_req(struct c4iw_ep *ep, unsigned int atid)
 	req->len16_pkd = htonl(FW_WR_LEN16(DIV_ROUND_UP(sizeof(*req), 16)));
 	req->le.filter = cpu_to_be32(select_ntuple(ep->com.dev, ep->dst,
 				     ep->l2t));
-	req->le.lport = ep->com.local_addr.sin_port;
-	req->le.pport = ep->com.remote_addr.sin_port;
-	req->le.u.ipv4.lip = ep->com.local_addr.sin_addr.s_addr;
-	req->le.u.ipv4.pip = ep->com.remote_addr.sin_addr.s_addr;
+	sin = (struct sockaddr_in *)&ep->com.local_addr;
+	req->le.lport = sin->sin_port;
+	req->le.u.ipv4.lip = sin->sin_addr.s_addr;
+	sin = (struct sockaddr_in *)&ep->com.remote_addr;
+	req->le.pport = sin->sin_port;
+	req->le.u.ipv4.pip = sin->sin_addr.s_addr;
 	req->tcb.t_state_to_astid =
 			htonl(V_FW_OFLD_CONNECTION_WR_T_STATE(TCP_SYN_SENT) |
 			V_FW_OFLD_CONNECTION_WR_ASTID(atid));
@@ -1564,18 +1684,95 @@ static inline int act_open_has_tid(int status)
 
 #define ACT_OPEN_RETRY_COUNT 2
 
+static int import_ep(struct c4iw_ep *ep, int iptype, __u8 *peer_ip,
+		     struct dst_entry *dst, struct c4iw_dev *cdev,
+		     bool clear_mpa_v1)
+{
+	struct neighbour *n;
+	int err, step;
+	struct net_device *pdev;
+
+	n = dst_neigh_lookup(dst, peer_ip);
+	if (!n)
+		return -ENODEV;
+
+	rcu_read_lock();
+	err = -ENOMEM;
+	if (n->dev->flags & IFF_LOOPBACK) {
+		if (iptype == 4)
+			pdev = ip_dev_find(&init_net, *(__be32 *)peer_ip);
+		else
+			for_each_netdev(&init_net, pdev) {
+				if (ipv6_chk_addr(&init_net,
+						  (struct in6_addr *)peer_ip,
+						  pdev, 1))
+					break;
+			}
+		if (!pdev) {
+			err = -ENODEV;
+			goto out;
+		}
+		ep->l2t = cxgb4_l2t_get(cdev->rdev.lldi.l2t,
+					n, pdev, 0);
+		if (!ep->l2t)
+			goto out;
+		ep->mtu = pdev->mtu;
+		ep->tx_chan = cxgb4_port_chan(pdev);
+		ep->smac_idx = (cxgb4_port_viid(pdev) & 0x7F) << 1;
+		step = cdev->rdev.lldi.ntxq /
+			cdev->rdev.lldi.nchan;
+		ep->txq_idx = cxgb4_port_idx(pdev) * step;
+		step = cdev->rdev.lldi.nrxq /
+			cdev->rdev.lldi.nchan;
+		ep->ctrlq_idx = cxgb4_port_idx(pdev);
+		ep->rss_qid = cdev->rdev.lldi.rxq_ids[
+			cxgb4_port_idx(pdev) * step];
+		dev_put(pdev);
+	} else {
+		pdev = get_real_dev(n->dev);
+		ep->l2t = cxgb4_l2t_get(cdev->rdev.lldi.l2t,
+					n, pdev, 0);
+		if (!ep->l2t)
+			goto out;
+		ep->mtu = dst_mtu(dst);
+		ep->tx_chan = cxgb4_port_chan(n->dev);
+		ep->smac_idx = (cxgb4_port_viid(n->dev) & 0x7F) << 1;
+		step = cdev->rdev.lldi.ntxq /
+			cdev->rdev.lldi.nchan;
+		ep->txq_idx = cxgb4_port_idx(n->dev) * step;
+		ep->ctrlq_idx = cxgb4_port_idx(n->dev);
+		step = cdev->rdev.lldi.nrxq /
+			cdev->rdev.lldi.nchan;
+		ep->rss_qid = cdev->rdev.lldi.rxq_ids[
+			cxgb4_port_idx(n->dev) * step];
+
+		if (clear_mpa_v1) {
+			ep->retry_with_mpa_v1 = 0;
+			ep->tried_with_mpa_v1 = 0;
+		}
+	}
+	err = 0;
+out:
+	rcu_read_unlock();
+
+	neigh_release(n);
+
+	return err;
+}
+
 static int c4iw_reconnect(struct c4iw_ep *ep)
 {
 	int err = 0;
-	struct rtable *rt;
-	struct port_info *pi;
-	struct net_device *pdev;
-	int step;
-	struct neighbour *neigh;
 	struct sockaddr_in *laddr = (struct sockaddr_in *)
 				    &ep->com.cm_id->local_addr;
 	struct sockaddr_in *raddr = (struct sockaddr_in *)
 				    &ep->com.cm_id->remote_addr;
+	struct sockaddr_in6 *laddr6 = (struct sockaddr_in6 *)
+				      &ep->com.cm_id->local_addr;
+	struct sockaddr_in6 *raddr6 = (struct sockaddr_in6 *)
+				      &ep->com.cm_id->remote_addr;
+	int iptype;
+	__u8 *ra;
 
 	PDBG("%s qp %p cm_id %p\n", __func__, ep->com.qp, ep->com.cm_id);
 	init_timer(&ep->timer);
@@ -1592,53 +1789,28 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 	insert_handle(ep->com.dev, &ep->com.dev->atid_idr, ep, ep->atid);
 
 	/* find a route */
-	rt = find_route(ep->com.dev,
-			laddr->sin_addr.s_addr, raddr->sin_addr.s_addr,
-			laddr->sin_port, raddr->sin_port, 0);
-	if (!rt) {
+	if (ep->com.cm_id->local_addr.ss_family == AF_INET) {
+		ep->dst = find_route(ep->com.dev, laddr->sin_addr.s_addr,
+				     raddr->sin_addr.s_addr, laddr->sin_port,
+				     raddr->sin_port, 0);
+		iptype = 4;
+		ra = (__u8 *)&raddr->sin_addr;
+	} else {
+		ep->dst = find_route6(ep->com.dev, laddr6->sin6_addr.s6_addr,
+				      raddr6->sin6_addr.s6_addr,
+				      laddr6->sin6_port, raddr6->sin6_port, 0,
+				      raddr6->sin6_scope_id);
+		iptype = 6;
+		ra = (__u8 *)&raddr6->sin6_addr;
+	}
+	if (!ep->dst) {
 		pr_err("%s - cannot find route.\n", __func__);
 		err = -EHOSTUNREACH;
 		goto fail3;
 	}
-	ep->dst = &rt->dst;
-
-	neigh = dst_neigh_lookup(ep->dst, &raddr->sin_addr.s_addr);
-	if (!neigh) {
-		pr_err("%s - cannot alloc neigh.\n", __func__);
-		err = -ENOMEM;
-		goto fail4;
-	}
-
-	/* get a l2t entry */
-	if (neigh->dev->flags & IFF_LOOPBACK) {
-		PDBG("%s LOOPBACK\n", __func__);
-		pdev = ip_dev_find(&init_net, raddr->sin_addr.s_addr);
-		ep->l2t = cxgb4_l2t_get(ep->com.dev->rdev.lldi.l2t,
-				neigh, pdev, 0);
-		pi = (struct port_info *)netdev_priv(pdev);
-		ep->mtu = pdev->mtu;
-		ep->tx_chan = cxgb4_port_chan(pdev);
-		ep->smac_idx = (cxgb4_port_viid(pdev) & 0x7F) << 1;
-		dev_put(pdev);
-	} else {
-		ep->l2t = cxgb4_l2t_get(ep->com.dev->rdev.lldi.l2t,
-				neigh, neigh->dev, 0);
-		pi = (struct port_info *)netdev_priv(neigh->dev);
-		ep->mtu = dst_mtu(ep->dst);
-		ep->tx_chan = cxgb4_port_chan(neigh->dev);
-		ep->smac_idx = (cxgb4_port_viid(neigh->dev) &
-				0x7F) << 1;
-	}
-
-	step = ep->com.dev->rdev.lldi.ntxq / ep->com.dev->rdev.lldi.nchan;
-	ep->txq_idx = pi->port_id * step;
-	ep->ctrlq_idx = pi->port_id;
-	step = ep->com.dev->rdev.lldi.nrxq / ep->com.dev->rdev.lldi.nchan;
-	ep->rss_qid = ep->com.dev->rdev.lldi.rxq_ids[pi->port_id * step];
-
-	if (!ep->l2t) {
+	err = import_ep(ep, iptype, ra, ep->dst, ep->com.dev, false);
+	if (err) {
 		pr_err("%s - cannot alloc l2e.\n", __func__);
-		err = -ENOMEM;
 		goto fail4;
 	}
 
@@ -1681,6 +1853,12 @@ static int act_open_rpl(struct c4iw_dev *dev, struct sk_buff *skb)
 					ntohl(rpl->atid_status)));
 	struct tid_info *t = dev->rdev.lldi.tids;
 	int status = GET_AOPEN_STATUS(ntohl(rpl->atid_status));
+	struct sockaddr_in *la = (struct sockaddr_in *)&ep->com.local_addr;
+	struct sockaddr_in *ra = (struct sockaddr_in *)&ep->com.remote_addr;
+	struct sockaddr_in6 *la6 = (struct sockaddr_in6 *)&ep->com.local_addr;
+	struct sockaddr_in6 *ra6 = (struct sockaddr_in6 *)&ep->com.remote_addr;
+
+
 
 	ep = lookup_atid(t, atid);
 
@@ -1703,10 +1881,11 @@ static int act_open_rpl(struct c4iw_dev *dev, struct sk_buff *skb)
 	case CPL_ERR_CONN_TIMEDOUT:
 		break;
 	case CPL_ERR_TCAM_FULL:
+		mutex_lock(&dev->rdev.stats.lock);
 		dev->rdev.stats.tcam_full++;
-		if (dev->rdev.lldi.enable_fw_ofld_conn) {
-			mutex_lock(&dev->rdev.stats.lock);
-			mutex_unlock(&dev->rdev.stats.lock);
+		mutex_unlock(&dev->rdev.stats.lock);
+		if (ep->com.local_addr.ss_family == AF_INET &&
+		    dev->rdev.lldi.enable_fw_ofld_conn) {
 			send_fw_act_open_req(ep,
 					     GET_TID_TID(GET_AOPEN_ATID(
 					     ntohl(rpl->atid_status))));
@@ -1726,13 +1905,17 @@ static int act_open_rpl(struct c4iw_dev *dev, struct sk_buff *skb)
 		}
 		break;
 	default:
-		printk(KERN_INFO MOD "Active open failure - "
-		       "atid %u status %u errno %d %pI4:%u->%pI4:%u\n",
-		       atid, status, status2errno(status),
-		       &ep->com.local_addr.sin_addr.s_addr,
-		       ntohs(ep->com.local_addr.sin_port),
-		       &ep->com.remote_addr.sin_addr.s_addr,
-		       ntohs(ep->com.remote_addr.sin_port));
+		if (ep->com.local_addr.ss_family == AF_INET) {
+			pr_info("Active open failure - atid %u status %u errno %d %pI4:%u->%pI4:%u\n",
+				atid, status, status2errno(status),
+				&la->sin_addr.s_addr, ntohs(la->sin_port),
+				&ra->sin_addr.s_addr, ntohs(ra->sin_port));
+		} else {
+			pr_info("Active open failure - atid %u status %u errno %d %pI6:%u->%pI6:%u\n",
+				atid, status, status2errno(status),
+				la6->sin6_addr.s6_addr, ntohs(la6->sin6_port),
+				ra6->sin6_addr.s6_addr, ntohs(ra6->sin6_port));
+		}
 		break;
 	}
 
@@ -1770,27 +1953,6 @@ out:
 	return 0;
 }
 
-static int listen_stop(struct c4iw_listen_ep *ep)
-{
-	struct sk_buff *skb;
-	struct cpl_close_listsvr_req *req;
-
-	PDBG("%s ep %p\n", __func__, ep);
-	skb = get_skb(NULL, sizeof(*req), GFP_KERNEL);
-	if (!skb) {
-		printk(KERN_ERR MOD "%s - failed to alloc skb\n", __func__);
-		return -ENOMEM;
-	}
-	req = (struct cpl_close_listsvr_req *) skb_put(skb, sizeof(*req));
-	INIT_TP_WR(req, 0);
-	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_CLOSE_LISTSRV_REQ,
-						    ep->stid));
-	req->reply_ctrl = cpu_to_be16(
-			  QUEUENO(ep->com.dev->rdev.lldi.rxq_ids[0]));
-	set_wr_txq(skb, CPL_PRIORITY_SETUP, 0);
-	return c4iw_ofld_send(&ep->com.dev->rdev, skb);
-}
-
 static int close_listsrv_rpl(struct c4iw_dev *dev, struct sk_buff *skb)
 {
 	struct cpl_close_listsvr_rpl *rpl = cplhdr(skb);
@@ -1803,7 +1965,7 @@ static int close_listsrv_rpl(struct c4iw_dev *dev, struct sk_buff *skb)
 	return 0;
 }
 
-static void accept_cr(struct c4iw_ep *ep, __be32 peer_ip, struct sk_buff *skb,
+static void accept_cr(struct c4iw_ep *ep, struct sk_buff *skb,
 		      struct cpl_pass_accept_req *req)
 {
 	struct cpl_pass_accept_rpl *rpl;
@@ -1860,11 +2022,9 @@ static void accept_cr(struct c4iw_ep *ep, __be32 peer_ip, struct sk_buff *skb,
 	return;
 }
 
-static void reject_cr(struct c4iw_dev *dev, u32 hwtid, __be32 peer_ip,
-		      struct sk_buff *skb)
+static void reject_cr(struct c4iw_dev *dev, u32 hwtid, struct sk_buff *skb)
 {
-	PDBG("%s c4iw_dev %p tid %u peer_ip %x\n", __func__, dev, hwtid,
-	     peer_ip);
+	PDBG("%s c4iw_dev %p tid %u\n", __func__, dev, hwtid);
 	BUG_ON(skb_cloned(skb));
 	skb_trim(skb, sizeof(struct cpl_tid_release));
 	skb_get(skb);
@@ -1872,95 +2032,38 @@ static void reject_cr(struct c4iw_dev *dev, u32 hwtid, __be32 peer_ip,
 	return;
 }
 
-static void get_4tuple(struct cpl_pass_accept_req *req,
-		       __be32 *local_ip, __be32 *peer_ip,
+static void get_4tuple(struct cpl_pass_accept_req *req, int *iptype,
+		       __u8 *local_ip, __u8 *peer_ip,
 		       __be16 *local_port, __be16 *peer_port)
 {
 	int eth_len = G_ETH_HDR_LEN(be32_to_cpu(req->hdr_len));
 	int ip_len = G_IP_HDR_LEN(be32_to_cpu(req->hdr_len));
 	struct iphdr *ip = (struct iphdr *)((u8 *)(req + 1) + eth_len);
+	struct ipv6hdr *ip6 = (struct ipv6hdr *)((u8 *)(req + 1) + eth_len);
 	struct tcphdr *tcp = (struct tcphdr *)
 			     ((u8 *)(req + 1) + eth_len + ip_len);
 
-	PDBG("%s saddr 0x%x daddr 0x%x sport %u dport %u\n", __func__,
-	     ntohl(ip->saddr), ntohl(ip->daddr), ntohs(tcp->source),
-	     ntohs(tcp->dest));
-
-	*peer_ip = ip->saddr;
-	*local_ip = ip->daddr;
+	if (ip->version == 4) {
+		PDBG("%s saddr 0x%x daddr 0x%x sport %u dport %u\n", __func__,
+		     ntohl(ip->saddr), ntohl(ip->daddr), ntohs(tcp->source),
+		     ntohs(tcp->dest));
+		*iptype = 4;
+		memcpy(peer_ip, &ip->saddr, 4);
+		memcpy(local_ip, &ip->daddr, 4);
+	} else {
+		PDBG("%s saddr %pI6 daddr %pI6 sport %u dport %u\n", __func__,
+		     ip6->saddr.s6_addr, ip6->daddr.s6_addr, ntohs(tcp->source),
+		     ntohs(tcp->dest));
+		*iptype = 6;
+		memcpy(peer_ip, ip6->saddr.s6_addr, 16);
+		memcpy(local_ip, ip6->daddr.s6_addr, 16);
+	}
 	*peer_port = tcp->source;
 	*local_port = tcp->dest;
 
 	return;
 }
 
-static int import_ep(struct c4iw_ep *ep, __be32 peer_ip, struct dst_entry *dst,
-		     struct c4iw_dev *cdev, bool clear_mpa_v1)
-{
-	struct neighbour *n;
-	int err, step;
-
-	n = dst_neigh_lookup(dst, &peer_ip);
-	if (!n)
-		return -ENODEV;
-
-	rcu_read_lock();
-	err = -ENOMEM;
-	if (n->dev->flags & IFF_LOOPBACK) {
-		struct net_device *pdev;
-
-		pdev = ip_dev_find(&init_net, peer_ip);
-		if (!pdev) {
-			err = -ENODEV;
-			goto out;
-		}
-		ep->l2t = cxgb4_l2t_get(cdev->rdev.lldi.l2t,
-					n, pdev, 0);
-		if (!ep->l2t)
-			goto out;
-		ep->mtu = pdev->mtu;
-		ep->tx_chan = cxgb4_port_chan(pdev);
-		ep->smac_idx = (cxgb4_port_viid(pdev) & 0x7F) << 1;
-		step = cdev->rdev.lldi.ntxq /
-			cdev->rdev.lldi.nchan;
-		ep->txq_idx = cxgb4_port_idx(pdev) * step;
-		step = cdev->rdev.lldi.nrxq /
-			cdev->rdev.lldi.nchan;
-		ep->ctrlq_idx = cxgb4_port_idx(pdev);
-		ep->rss_qid = cdev->rdev.lldi.rxq_ids[
-			cxgb4_port_idx(pdev) * step];
-		dev_put(pdev);
-	} else {
-		ep->l2t = cxgb4_l2t_get(cdev->rdev.lldi.l2t,
-					n, n->dev, 0);
-		if (!ep->l2t)
-			goto out;
-		ep->mtu = dst_mtu(dst);
-		ep->tx_chan = cxgb4_port_chan(n->dev);
-		ep->smac_idx = (cxgb4_port_viid(n->dev) & 0x7F) << 1;
-		step = cdev->rdev.lldi.ntxq /
-			cdev->rdev.lldi.nchan;
-		ep->txq_idx = cxgb4_port_idx(n->dev) * step;
-		ep->ctrlq_idx = cxgb4_port_idx(n->dev);
-		step = cdev->rdev.lldi.nrxq /
-			cdev->rdev.lldi.nchan;
-		ep->rss_qid = cdev->rdev.lldi.rxq_ids[
-			cxgb4_port_idx(n->dev) * step];
-
-		if (clear_mpa_v1) {
-			ep->retry_with_mpa_v1 = 0;
-			ep->tried_with_mpa_v1 = 0;
-		}
-	}
-	err = 0;
-out:
-	rcu_read_unlock();
-
-	neigh_release(n);
-
-	return err;
-}
-
 static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 {
 	struct c4iw_ep *child_ep = NULL, *parent_ep;
@@ -1969,23 +2072,17 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 	struct tid_info *t = dev->rdev.lldi.tids;
 	unsigned int hwtid = GET_TID(req);
 	struct dst_entry *dst;
-	struct rtable *rt;
-	__be32 local_ip, peer_ip = 0;
+	__u8 local_ip[16], peer_ip[16];
 	__be16 local_port, peer_port;
 	int err;
 	u16 peer_mss = ntohs(req->tcpopt.mss);
+	int iptype;
 
 	parent_ep = lookup_stid(t, stid);
 	if (!parent_ep) {
 		PDBG("%s connect request on invalid stid %d\n", __func__, stid);
 		goto reject;
 	}
-	get_4tuple(req, &local_ip, &peer_ip, &local_port, &peer_port);
-
-	PDBG("%s parent ep %p hwtid %u laddr 0x%x raddr 0x%x lport %d " \
-	     "rport %d peer_mss %d\n", __func__, parent_ep, hwtid,
-	     ntohl(local_ip), ntohl(peer_ip), ntohs(local_port),
-	     ntohs(peer_port), peer_mss);
 
 	if (state_read(&parent_ep->com) != LISTEN) {
 		printk(KERN_ERR "%s - listening ep not in LISTEN\n",
@@ -1993,15 +2090,32 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 		goto reject;
 	}
 
+	get_4tuple(req, &iptype, local_ip, peer_ip, &local_port, &peer_port);
+
 	/* Find output route */
-	rt = find_route(dev, local_ip, peer_ip, local_port, peer_port,
-			GET_POPEN_TOS(ntohl(req->tos_stid)));
-	if (!rt) {
+	if (iptype == 4)  {
+		PDBG("%s parent ep %p hwtid %u laddr %pI4 raddr %pI4 lport %d rport %d peer_mss %d\n"
+		     , __func__, parent_ep, hwtid,
+		     local_ip, peer_ip, ntohs(local_port),
+		     ntohs(peer_port), peer_mss);
+		dst = find_route(dev, *(__be32 *)local_ip, *(__be32 *)peer_ip,
+				 local_port, peer_port,
+				 GET_POPEN_TOS(ntohl(req->tos_stid)));
+	} else {
+		PDBG("%s parent ep %p hwtid %u laddr %pI6 raddr %pI6 lport %d rport %d peer_mss %d\n"
+		     , __func__, parent_ep, hwtid,
+		     local_ip, peer_ip, ntohs(local_port),
+		     ntohs(peer_port), peer_mss);
+		dst = find_route6(dev, local_ip, peer_ip, local_port, peer_port,
+				  PASS_OPEN_TOS(ntohl(req->tos_stid)),
+				  ((struct sockaddr_in6 *)
+				  &parent_ep->com.local_addr)->sin6_scope_id);
+	}
+	if (!dst) {
 		printk(KERN_ERR MOD "%s - failed to find dst entry!\n",
 		       __func__);
 		goto reject;
 	}
-	dst = &rt->dst;
 
 	child_ep = alloc_ep(sizeof(*child_ep), GFP_KERNEL);
 	if (!child_ep) {
@@ -2011,7 +2125,7 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 		goto reject;
 	}
 
-	err = import_ep(child_ep, peer_ip, dst, dev, false);
+	err = import_ep(child_ep, iptype, peer_ip, dst, dev, false);
 	if (err) {
 		printk(KERN_ERR MOD "%s - failed to allocate l2t entry!\n",
 		       __func__);
@@ -2026,12 +2140,27 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 	state_set(&child_ep->com, CONNECTING);
 	child_ep->com.dev = dev;
 	child_ep->com.cm_id = NULL;
-	child_ep->com.local_addr.sin_family = PF_INET;
-	child_ep->com.local_addr.sin_port = local_port;
-	child_ep->com.local_addr.sin_addr.s_addr = local_ip;
-	child_ep->com.remote_addr.sin_family = PF_INET;
-	child_ep->com.remote_addr.sin_port = peer_port;
-	child_ep->com.remote_addr.sin_addr.s_addr = peer_ip;
+	if (iptype == 4) {
+		struct sockaddr_in *sin = (struct sockaddr_in *)
+			&child_ep->com.local_addr;
+		sin->sin_family = PF_INET;
+		sin->sin_port = local_port;
+		sin->sin_addr.s_addr = *(__be32 *)local_ip;
+		sin = (struct sockaddr_in *)&child_ep->com.remote_addr;
+		sin->sin_family = PF_INET;
+		sin->sin_port = peer_port;
+		sin->sin_addr.s_addr = *(__be32 *)peer_ip;
+	} else {
+		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)
+			&child_ep->com.local_addr;
+		sin6->sin6_family = PF_INET6;
+		sin6->sin6_port = local_port;
+		memcpy(sin6->sin6_addr.s6_addr, local_ip, 16);
+		sin6 = (struct sockaddr_in6 *)&child_ep->com.remote_addr;
+		sin6->sin6_family = PF_INET6;
+		sin6->sin6_port = peer_port;
+		memcpy(sin6->sin6_addr.s6_addr, peer_ip, 16);
+	}
 	c4iw_get_ep(&parent_ep->com);
 	child_ep->parent_ep = parent_ep;
 	child_ep->tos = GET_POPEN_TOS(ntohl(req->tos_stid));
@@ -2044,11 +2173,11 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 	init_timer(&child_ep->timer);
 	cxgb4_insert_tid(t, child_ep, hwtid);
 	insert_handle(dev, &dev->hwtid_idr, child_ep, child_ep->hwtid);
-	accept_cr(child_ep, peer_ip, skb, req);
+	accept_cr(child_ep, skb, req);
 	set_bit(PASS_ACCEPT_REQ, &child_ep->com.history);
 	goto out;
 reject:
-	reject_cr(dev, hwtid, peer_ip, skb);
+	reject_cr(dev, hwtid, skb);
 out:
 	return 0;
 }
@@ -2516,14 +2645,79 @@ err:
 	return err;
 }
 
+static int pick_local_ipaddrs(struct c4iw_dev *dev, struct iw_cm_id *cm_id)
+{
+	struct in_device *ind;
+	int found = 0;
+	struct sockaddr_in *laddr = (struct sockaddr_in *)&cm_id->local_addr;
+	struct sockaddr_in *raddr = (struct sockaddr_in *)&cm_id->remote_addr;
+
+	ind = in_dev_get(dev->rdev.lldi.ports[0]);
+	if (!ind)
+		return -EADDRNOTAVAIL;
+	for_primary_ifa(ind) {
+		laddr->sin_addr.s_addr = ifa->ifa_address;
+		raddr->sin_addr.s_addr = ifa->ifa_address;
+		found = 1;
+		break;
+	}
+	endfor_ifa(ind);
+	in_dev_put(ind);
+	return found ? 0 : -EADDRNOTAVAIL;
+}
+
+static int get_lladdr(struct net_device *dev, struct in6_addr *addr,
+		      unsigned char banned_flags)
+{
+	struct inet6_dev *idev;
+	int err = -EADDRNOTAVAIL;
+
+	rcu_read_lock();
+	idev = __in6_dev_get(dev);
+	if (idev != NULL) {
+		struct inet6_ifaddr *ifp;
+
+		read_lock_bh(&idev->lock);
+		list_for_each_entry(ifp, &idev->addr_list, if_list) {
+			if (ifp->scope == IFA_LINK &&
+			    !(ifp->flags & banned_flags)) {
+				memcpy(addr, &ifp->addr, 16);
+				err = 0;
+				break;
+			}
+		}
+		read_unlock_bh(&idev->lock);
+	}
+	rcu_read_unlock();
+	return err;
+}
+
+static int pick_local_ip6addrs(struct c4iw_dev *dev, struct iw_cm_id *cm_id)
+{
+	struct in6_addr uninitialized_var(addr);
+	struct sockaddr_in6 *la6 = (struct sockaddr_in6 *)&cm_id->local_addr;
+	struct sockaddr_in6 *ra6 = (struct sockaddr_in6 *)&cm_id->remote_addr;
+
+	if (get_lladdr(dev->rdev.lldi.ports[0], &addr, IFA_F_TENTATIVE)) {
+		memcpy(la6->sin6_addr.s6_addr, &addr, 16);
+		memcpy(ra6->sin6_addr.s6_addr, &addr, 16);
+		return 0;
+	}
+	return -EADDRNOTAVAIL;
+}
+
 int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 {
 	struct c4iw_dev *dev = to_c4iw_dev(cm_id->device);
 	struct c4iw_ep *ep;
-	struct rtable *rt;
 	int err = 0;
 	struct sockaddr_in *laddr = (struct sockaddr_in *)&cm_id->local_addr;
 	struct sockaddr_in *raddr = (struct sockaddr_in *)&cm_id->remote_addr;
+	struct sockaddr_in6 *laddr6 = (struct sockaddr_in6 *)&cm_id->local_addr;
+	struct sockaddr_in6 *raddr6 = (struct sockaddr_in6 *)
+				      &cm_id->remote_addr;
+	__u8 *ra;
+	int iptype;
 
 	if ((conn_param->ord > c4iw_max_read_depth) ||
 	    (conn_param->ird > c4iw_max_read_depth)) {
@@ -2551,7 +2745,11 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	ep->com.dev = dev;
 	ep->com.cm_id = cm_id;
 	ep->com.qp = get_qhp(dev, conn_param->qpn);
-	BUG_ON(!ep->com.qp);
+	if (!ep->com.qp) {
+		PDBG("%s qpn 0x%x not found!\n", __func__, conn_param->qpn);
+		err = -EINVAL;
+		goto fail2;
+	}
 	ref_qp(ep);
 	PDBG("%s qpn 0x%x qp %p cm_id %p\n", __func__, conn_param->qpn,
 	     ep->com.qp, cm_id);
@@ -2567,21 +2765,56 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	}
 	insert_handle(dev, &dev->atid_idr, ep, ep->atid);
 
-	PDBG("%s saddr 0x%x sport 0x%x raddr 0x%x rport 0x%x\n", __func__,
-	     ntohl(laddr->sin_addr.s_addr), ntohs(laddr->sin_port),
-	     ntohl(raddr->sin_addr.s_addr), ntohs(raddr->sin_port));
+	if (cm_id->remote_addr.ss_family == AF_INET) {
+		iptype = 4;
+		ra = (__u8 *)&raddr->sin_addr;
 
-	/* find a route */
-	rt = find_route(dev, laddr->sin_addr.s_addr, raddr->sin_addr.s_addr,
-			laddr->sin_port, raddr->sin_port, 0);
-	if (!rt) {
+		/*
+		 * Handle loopback requests to INADDR_ANY.
+		 */
+		if (raddr->sin_addr.s_addr == INADDR_ANY) {
+			err = pick_local_ipaddrs(dev, cm_id);
+			if (err)
+				goto fail2;
+		}
+
+		/* find a route */
+		PDBG("%s saddr %pI4 sport 0x%x raddr %pI4 rport 0x%x\n",
+		     __func__, &laddr->sin_addr, ntohs(laddr->sin_port),
+		     ra, ntohs(raddr->sin_port));
+		ep->dst = find_route(dev, laddr->sin_addr.s_addr,
+				     raddr->sin_addr.s_addr, laddr->sin_port,
+				     raddr->sin_port, 0);
+	} else {
+		iptype = 6;
+		ra = (__u8 *)&raddr6->sin6_addr;
+
+		/*
+		 * Handle loopback requests to INADDR_ANY.
+		 */
+		if (ipv6_addr_type(&raddr6->sin6_addr) == IPV6_ADDR_ANY) {
+			err = pick_local_ip6addrs(dev, cm_id);
+			if (err)
+				goto fail2;
+		}
+
+		/* find a route */
+		PDBG("%s saddr %pI6 sport 0x%x raddr %pI6 rport 0x%x\n",
+		     __func__, laddr6->sin6_addr.s6_addr,
+		     ntohs(laddr6->sin6_port),
+		     raddr6->sin6_addr.s6_addr, ntohs(raddr6->sin6_port));
+		ep->dst = find_route6(dev, laddr6->sin6_addr.s6_addr,
+				      raddr6->sin6_addr.s6_addr,
+				      laddr6->sin6_port, raddr6->sin6_port, 0,
+				      raddr6->sin6_scope_id);
+	}
+	if (!ep->dst) {
 		printk(KERN_ERR MOD "%s - cannot find route.\n", __func__);
 		err = -EHOSTUNREACH;
 		goto fail3;
 	}
-	ep->dst = &rt->dst;
 
-	err = import_ep(ep, raddr->sin_addr.s_addr, ep->dst, ep->com.dev, true);
+	err = import_ep(ep, iptype, ra, ep->dst, ep->com.dev, true);
 	if (err) {
 		printk(KERN_ERR MOD "%s - cannot alloc l2e.\n", __func__);
 		goto fail4;
@@ -2616,6 +2849,60 @@ out:
 	return err;
 }
 
+static int create_server6(struct c4iw_dev *dev, struct c4iw_listen_ep *ep)
+{
+	int err;
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&ep->com.local_addr;
+
+	c4iw_init_wr_wait(&ep->com.wr_wait);
+	err = cxgb4_create_server6(ep->com.dev->rdev.lldi.ports[0],
+				   ep->stid, &sin6->sin6_addr,
+				   sin6->sin6_port,
+				   ep->com.dev->rdev.lldi.rxq_ids[0]);
+	if (!err)
+		err = c4iw_wait_for_reply(&ep->com.dev->rdev,
+					  &ep->com.wr_wait,
+					  0, 0, __func__);
+	if (err)
+		pr_err("cxgb4_create_server6/filter failed err %d stid %d laddr %pI6 lport %d\n",
+		       err, ep->stid,
+		       sin6->sin6_addr.s6_addr, ntohs(sin6->sin6_port));
+	return err;
+}
+
+static int create_server4(struct c4iw_dev *dev, struct c4iw_listen_ep *ep)
+{
+	int err;
+	struct sockaddr_in *sin = (struct sockaddr_in *)&ep->com.local_addr;
+
+	if (dev->rdev.lldi.enable_fw_ofld_conn) {
+		do {
+			err = cxgb4_create_server_filter(
+				ep->com.dev->rdev.lldi.ports[0], ep->stid,
+				sin->sin_addr.s_addr, sin->sin_port, 0,
+				ep->com.dev->rdev.lldi.rxq_ids[0], 0, 0);
+			if (err == -EBUSY) {
+				set_current_state(TASK_UNINTERRUPTIBLE);
+				schedule_timeout(usecs_to_jiffies(100));
+			}
+		} while (err == -EBUSY);
+	} else {
+		c4iw_init_wr_wait(&ep->com.wr_wait);
+		err = cxgb4_create_server(ep->com.dev->rdev.lldi.ports[0],
+				ep->stid, sin->sin_addr.s_addr, sin->sin_port,
+				0, ep->com.dev->rdev.lldi.rxq_ids[0]);
+		if (!err)
+			err = c4iw_wait_for_reply(&ep->com.dev->rdev,
+						  &ep->com.wr_wait,
+						  0, 0, __func__);
+	}
+	if (err)
+		pr_err("cxgb4_create_server/filter failed err %d stid %d laddr %pI4 lport %d\n"
+		       , err, ep->stid,
+		       &sin->sin_addr, ntohs(sin->sin_port));
+	return err;
+}
+
 int c4iw_create_listen(struct iw_cm_id *cm_id, int backlog)
 {
 	int err = 0;
@@ -2642,9 +2929,11 @@ int c4iw_create_listen(struct iw_cm_id *cm_id, int backlog)
 	 * Allocate a server TID.
 	 */
 	if (dev->rdev.lldi.enable_fw_ofld_conn)
-		ep->stid = cxgb4_alloc_sftid(dev->rdev.lldi.tids, PF_INET, ep);
+		ep->stid = cxgb4_alloc_sftid(dev->rdev.lldi.tids,
+					     cm_id->local_addr.ss_family, ep);
 	else
-		ep->stid = cxgb4_alloc_stid(dev->rdev.lldi.tids, PF_INET, ep);
+		ep->stid = cxgb4_alloc_stid(dev->rdev.lldi.tids,
+					    cm_id->local_addr.ss_family, ep);
 
 	if (ep->stid == -1) {
 		printk(KERN_ERR MOD "%s - cannot alloc stid.\n", __func__);
@@ -2653,43 +2942,16 @@ int c4iw_create_listen(struct iw_cm_id *cm_id, int backlog)
 	}
 	insert_handle(dev, &dev->stid_idr, ep, ep->stid);
 	state_set(&ep->com, LISTEN);
-	if (dev->rdev.lldi.enable_fw_ofld_conn) {
-		do {
-			err = cxgb4_create_server_filter(
-				ep->com.dev->rdev.lldi.ports[0], ep->stid,
-				ep->com.local_addr.sin_addr.s_addr,
-				ep->com.local_addr.sin_port,
-				0,
-				ep->com.dev->rdev.lldi.rxq_ids[0],
-				0,
-				0);
-			if (err == -EBUSY) {
-				set_current_state(TASK_UNINTERRUPTIBLE);
-				schedule_timeout(usecs_to_jiffies(100));
-			}
-		} while (err == -EBUSY);
-	} else {
-		c4iw_init_wr_wait(&ep->com.wr_wait);
-		err = cxgb4_create_server(ep->com.dev->rdev.lldi.ports[0],
-				ep->stid, ep->com.local_addr.sin_addr.s_addr,
-				ep->com.local_addr.sin_port,
-				0,
-				ep->com.dev->rdev.lldi.rxq_ids[0]);
-		if (!err)
-			err = c4iw_wait_for_reply(&ep->com.dev->rdev,
-						  &ep->com.wr_wait,
-						  0, 0, __func__);
-	}
+	if (ep->com.local_addr.ss_family == AF_INET)
+		err = create_server4(dev, ep);
+	else
+		err = create_server6(dev, ep);
 	if (!err) {
 		cm_id->provider_data = ep;
 		goto out;
 	}
-	pr_err("%s cxgb4_create_server/filter failed err %d " \
-	       "stid %d laddr %08x lport %d\n", \
-	       __func__, err, ep->stid,
-	       ntohl(ep->com.local_addr.sin_addr.s_addr),
-	       ntohs(ep->com.local_addr.sin_port));
-	cxgb4_free_stid(ep->com.dev->rdev.lldi.tids, ep->stid, PF_INET);
+	cxgb4_free_stid(ep->com.dev->rdev.lldi.tids, ep->stid,
+			ep->com.local_addr.ss_family);
 fail2:
 	cm_id->rem_ref(cm_id);
 	c4iw_put_ep(&ep->com);
@@ -2707,20 +2969,24 @@ int c4iw_destroy_listen(struct iw_cm_id *cm_id)
 
 	might_sleep();
 	state_set(&ep->com, DEAD);
-	if (ep->com.dev->rdev.lldi.enable_fw_ofld_conn) {
+	if (ep->com.dev->rdev.lldi.enable_fw_ofld_conn &&
+	    ep->com.local_addr.ss_family == AF_INET) {
 		err = cxgb4_remove_server_filter(
 			ep->com.dev->rdev.lldi.ports[0], ep->stid,
 			ep->com.dev->rdev.lldi.rxq_ids[0], 0);
 	} else {
 		c4iw_init_wr_wait(&ep->com.wr_wait);
-		err = listen_stop(ep);
+		err = cxgb4_remove_server(
+				ep->com.dev->rdev.lldi.ports[0], ep->stid,
+				ep->com.dev->rdev.lldi.rxq_ids[0], 0);
 		if (err)
 			goto done;
 		err = c4iw_wait_for_reply(&ep->com.dev->rdev, &ep->com.wr_wait,
 					  0, 0, __func__);
 	}
 	remove_handle(ep->com.dev, &ep->com.dev->stid_idr, ep->stid);
-	cxgb4_free_stid(ep->com.dev->rdev.lldi.tids, ep->stid, PF_INET);
+	cxgb4_free_stid(ep->com.dev->rdev.lldi.tids, ep->stid,
+			ep->com.local_addr.ss_family);
 done:
 	cm_id->rem_ref(cm_id);
 	c4iw_put_ep(&ep->com);
@@ -3024,7 +3290,6 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
 	struct cpl_pass_accept_req *req = (void *)(rss + 1);
 	struct l2t_entry *e;
 	struct dst_entry *dst;
-	struct rtable *rt;
 	struct c4iw_ep *lep;
 	u16 window;
 	struct port_info *pi;
@@ -3082,14 +3347,13 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
 	     ntohl(iph->daddr), ntohs(tcph->dest), ntohl(iph->saddr),
 	     ntohs(tcph->source), iph->tos);
 
-	rt = find_route(dev, iph->daddr, iph->saddr, tcph->dest, tcph->source,
-			iph->tos);
-	if (!rt) {
+	dst = find_route(dev, iph->daddr, iph->saddr, tcph->dest, tcph->source,
+			 iph->tos);
+	if (!dst) {
 		pr_err("%s - failed to find dst entry!\n",
 		       __func__);
 		goto reject;
 	}
-	dst = &rt->dst;
 	neigh = dst_neigh_lookup_skb(dst, skb);
 
 	if (!neigh) {
@@ -3106,10 +3370,11 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
 		tx_chan = cxgb4_port_chan(pdev);
 		dev_put(pdev);
 	} else {
+		pdev = get_real_dev(neigh->dev);
 		e = cxgb4_l2t_get(dev->rdev.lldi.l2t, neigh,
-					neigh->dev, 0);
-		pi = (struct port_info *)netdev_priv(neigh->dev);
-		tx_chan = cxgb4_port_chan(neigh->dev);
+					pdev, 0);
+		pi = (struct port_info *)netdev_priv(pdev);
+		tx_chan = cxgb4_port_chan(pdev);
 	}
 	if (!e) {
 		pr_err("%s - failed to allocate l2t entry!\n",
diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index ae65601..33d2cc6 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -103,18 +103,43 @@ static int dump_qp(int id, void *p, void *data)
 	if (space == 0)
 		return 1;
 
-	if (qp->ep)
-		cc = snprintf(qpd->buf + qpd->pos, space,
-			     "qp sq id %u rq id %u state %u onchip %u "
-			     "ep tid %u state %u %pI4:%u->%pI4:%u\n",
-			     qp->wq.sq.qid, qp->wq.rq.qid, (int)qp->attr.state,
-			     qp->wq.sq.flags & T4_SQ_ONCHIP,
-			     qp->ep->hwtid, (int)qp->ep->com.state,
-			     &qp->ep->com.local_addr.sin_addr.s_addr,
-			     ntohs(qp->ep->com.local_addr.sin_port),
-			     &qp->ep->com.remote_addr.sin_addr.s_addr,
-			     ntohs(qp->ep->com.remote_addr.sin_port));
-	else
+	if (qp->ep) {
+		if (qp->ep->com.local_addr.ss_family == AF_INET) {
+			struct sockaddr_in *lsin = (struct sockaddr_in *)
+				&qp->ep->com.local_addr;
+			struct sockaddr_in *rsin = (struct sockaddr_in *)
+				&qp->ep->com.remote_addr;
+
+			cc = snprintf(qpd->buf + qpd->pos, space,
+				      "rc qp sq id %u rq id %u state %u "
+				      "onchip %u ep tid %u state %u "
+				      "%pI4:%u->%pI4:%u\n",
+				      qp->wq.sq.qid, qp->wq.rq.qid,
+				      (int)qp->attr.state,
+				      qp->wq.sq.flags & T4_SQ_ONCHIP,
+				      qp->ep->hwtid, (int)qp->ep->com.state,
+				      &lsin->sin_addr, ntohs(lsin->sin_port),
+				      &rsin->sin_addr, ntohs(rsin->sin_port));
+		} else {
+			struct sockaddr_in6 *lsin6 = (struct sockaddr_in6 *)
+				&qp->ep->com.local_addr;
+			struct sockaddr_in6 *rsin6 = (struct sockaddr_in6 *)
+				&qp->ep->com.remote_addr;
+
+			cc = snprintf(qpd->buf + qpd->pos, space,
+				      "rc qp sq id %u rq id %u state %u "
+				      "onchip %u ep tid %u state %u "
+				      "%pI6:%u->%pI6:%u\n",
+				      qp->wq.sq.qid, qp->wq.rq.qid,
+				      (int)qp->attr.state,
+				      qp->wq.sq.flags & T4_SQ_ONCHIP,
+				      qp->ep->hwtid, (int)qp->ep->com.state,
+				      &lsin6->sin6_addr,
+				      ntohs(lsin6->sin6_port),
+				      &rsin6->sin6_addr,
+				      ntohs(rsin6->sin6_port));
+		}
+	} else
 		cc = snprintf(qpd->buf + qpd->pos, space,
 			     "qp sq id %u rq id %u state %u onchip %u\n",
 			      qp->wq.sq.qid, qp->wq.rq.qid,
@@ -351,15 +376,37 @@ static int dump_ep(int id, void *p, void *data)
 	if (space == 0)
 		return 1;
 
-	cc = snprintf(epd->buf + epd->pos, space,
-			"ep %p cm_id %p qp %p state %d flags 0x%lx history 0x%lx "
-			"hwtid %d atid %d %pI4:%d <-> %pI4:%d\n",
-			ep, ep->com.cm_id, ep->com.qp, (int)ep->com.state,
-			ep->com.flags, ep->com.history, ep->hwtid, ep->atid,
-			&ep->com.local_addr.sin_addr.s_addr,
-			ntohs(ep->com.local_addr.sin_port),
-			&ep->com.remote_addr.sin_addr.s_addr,
-			ntohs(ep->com.remote_addr.sin_port));
+	if (ep->com.local_addr.ss_family == AF_INET) {
+		struct sockaddr_in *lsin = (struct sockaddr_in *)
+			&ep->com.local_addr;
+		struct sockaddr_in *rsin = (struct sockaddr_in *)
+			&ep->com.remote_addr;
+
+		cc = snprintf(epd->buf + epd->pos, space,
+			      "ep %p cm_id %p qp %p state %d flags 0x%lx "
+			      "history 0x%lx hwtid %d atid %d "
+			      "%pI4:%d <-> %pI4:%d\n",
+			      ep, ep->com.cm_id, ep->com.qp,
+			      (int)ep->com.state, ep->com.flags,
+			      ep->com.history, ep->hwtid, ep->atid,
+			      &lsin->sin_addr, ntohs(lsin->sin_port),
+			      &rsin->sin_addr, ntohs(rsin->sin_port));
+	} else {
+		struct sockaddr_in6 *lsin6 = (struct sockaddr_in6 *)
+			&ep->com.local_addr;
+		struct sockaddr_in6 *rsin6 = (struct sockaddr_in6 *)
+			&ep->com.remote_addr;
+
+		cc = snprintf(epd->buf + epd->pos, space,
+			      "ep %p cm_id %p qp %p state %d flags 0x%lx "
+			      "history 0x%lx hwtid %d atid %d "
+			      "%pI6:%d <-> %pI6:%d\n",
+			      ep, ep->com.cm_id, ep->com.qp,
+			      (int)ep->com.state, ep->com.flags,
+			      ep->com.history, ep->hwtid, ep->atid,
+			      &lsin6->sin6_addr, ntohs(lsin6->sin6_port),
+			      &rsin6->sin6_addr, ntohs(rsin6->sin6_port));
+	}
 	if (cc < space)
 		epd->pos += cc;
 	return 0;
@@ -376,12 +423,27 @@ static int dump_listen_ep(int id, void *p, void *data)
 	if (space == 0)
 		return 1;
 
-	cc = snprintf(epd->buf + epd->pos, space,
-			"ep %p cm_id %p state %d flags 0x%lx stid %d backlog %d "
-			"%pI4:%d\n", ep, ep->com.cm_id, (int)ep->com.state,
-			ep->com.flags, ep->stid, ep->backlog,
-			&ep->com.local_addr.sin_addr.s_addr,
-			ntohs(ep->com.local_addr.sin_port));
+	if (ep->com.local_addr.ss_family == AF_INET) {
+		struct sockaddr_in *lsin = (struct sockaddr_in *)
+			&ep->com.local_addr;
+
+		cc = snprintf(epd->buf + epd->pos, space,
+			      "ep %p cm_id %p state %d flags 0x%lx stid %d "
+			      "backlog %d %pI4:%d\n",
+			      ep, ep->com.cm_id, (int)ep->com.state,
+			      ep->com.flags, ep->stid, ep->backlog,
+			      &lsin->sin_addr, ntohs(lsin->sin_port));
+	} else {
+		struct sockaddr_in6 *lsin6 = (struct sockaddr_in6 *)
+			&ep->com.local_addr;
+
+		cc = snprintf(epd->buf + epd->pos, space,
+			      "ep %p cm_id %p state %d flags 0x%lx stid %d "
+			      "backlog %d %pI6:%d\n",
+			      ep, ep->com.cm_id, (int)ep->com.state,
+			      ep->com.flags, ep->stid, ep->backlog,
+			      &lsin6->sin6_addr, ntohs(lsin6->sin6_port));
+	}
 	if (cc < space)
 		epd->pos += cc;
 	return 0;
diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index 485183a..b3cae9f 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -752,8 +752,8 @@ struct c4iw_ep_common {
 	enum c4iw_ep_state state;
 	struct kref kref;
 	struct mutex mutex;
-	struct sockaddr_in local_addr;
-	struct sockaddr_in remote_addr;
+	struct sockaddr_storage local_addr;
+	struct sockaddr_storage remote_addr;
 	struct c4iw_wr_wait wr_wait;
 	unsigned long flags;
 	unsigned long history;
-- 
1.8.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
