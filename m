From: Varun Prakash <varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [net-next PATCH 02/11] libcxgb,iw_cxgb4,cxgbit: add cxgb_find_route()
Date: Tue, 13 Sep 2016 21:23:57 +0530
Message-ID: <109658fdf85a08113aa425eefe3ff4dab7249a11.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
        gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, indranil-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1473781521.git.varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
In-Reply-To: <cover.1473781521.git.varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
References: <cover.1473781521.git.varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add cxgb_find_route() in libcxgb_cm.c to remove
it's duplicate definitions from cxgb4/cm.c and
cxgbit/cxgbit_cm.c.

Signed-off-by: Varun Prakash <varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cm.c                  | 53 +++++++----------------
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c | 44 +++++++++++++++++++
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h |  4 ++
 drivers/target/iscsi/cxgbit/cxgbit_cm.c           | 36 +++------------
 4 files changed, 69 insertions(+), 68 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index e591f61..02f5e20 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -505,32 +505,6 @@ out:
 	return dst;
 }
 
-static struct dst_entry *find_route(struct c4iw_dev *dev, __be32 local_ip,
-				 __be32 peer_ip, __be16 local_port,
-				 __be16 peer_port, u8 tos)
-{
-	struct rtable *rt;
-	struct flowi4 fl4;
-	struct neighbour *n;
-
-	rt = ip_route_output_ports(&init_net, &fl4, NULL, peer_ip, local_ip,
-				   peer_port, local_port, IPPROTO_TCP,
-				   tos, 0);
-	if (IS_ERR(rt))
-		return NULL;
-	n = dst_neigh_lookup(&rt->dst, &peer_ip);
-	if (!n)
-		return NULL;
-	if (!our_interface(dev, n->dev) &&
-	    !(n->dev->flags & IFF_LOOPBACK)) {
-		neigh_release(n);
-		dst_release(&rt->dst);
-		return NULL;
-	}
-	neigh_release(n);
-	return &rt->dst;
-}
-
 static void arp_failure_discard(void *handle, struct sk_buff *skb)
 {
 	pr_err(MOD "ARP failure\n");
@@ -2215,9 +2189,11 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 
 	/* find a route */
 	if (ep->com.cm_id->m_local_addr.ss_family == AF_INET) {
-		ep->dst = find_route(ep->com.dev, laddr->sin_addr.s_addr,
-				     raddr->sin_addr.s_addr, laddr->sin_port,
-				     raddr->sin_port, ep->com.cm_id->tos);
+		ep->dst = cxgb_find_route(&ep->com.dev->rdev.lldi, get_real_dev,
+					  laddr->sin_addr.s_addr,
+					  raddr->sin_addr.s_addr,
+					  laddr->sin_port,
+					  raddr->sin_port, ep->com.cm_id->tos);
 		iptype = 4;
 		ra = (__u8 *)&raddr->sin_addr;
 	} else {
@@ -2556,9 +2532,9 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 		     , __func__, parent_ep, hwtid,
 		     local_ip, peer_ip, ntohs(local_port),
 		     ntohs(peer_port), peer_mss);
-		dst = find_route(dev, *(__be32 *)local_ip, *(__be32 *)peer_ip,
-				 local_port, peer_port,
-				 tos);
+		dst = cxgb_find_route(&dev->rdev.lldi, get_real_dev,
+				      *(__be32 *)local_ip, *(__be32 *)peer_ip,
+				      local_port, peer_port, tos);
 	} else {
 		PDBG("%s parent ep %p hwtid %u laddr %pI6 raddr %pI6 lport %d rport %d peer_mss %d\n"
 		     , __func__, parent_ep, hwtid,
@@ -3340,9 +3316,11 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 		PDBG("%s saddr %pI4 sport 0x%x raddr %pI4 rport 0x%x\n",
 		     __func__, &laddr->sin_addr, ntohs(laddr->sin_port),
 		     ra, ntohs(raddr->sin_port));
-		ep->dst = find_route(dev, laddr->sin_addr.s_addr,
-				     raddr->sin_addr.s_addr, laddr->sin_port,
-				     raddr->sin_port, cm_id->tos);
+		ep->dst = cxgb_find_route(&dev->rdev.lldi, get_real_dev,
+					  laddr->sin_addr.s_addr,
+					  raddr->sin_addr.s_addr,
+					  laddr->sin_port,
+					  raddr->sin_port, cm_id->tos);
 	} else {
 		iptype = 6;
 		ra = (__u8 *)&raddr6->sin6_addr;
@@ -4006,8 +3984,9 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
 	     ntohl(iph->daddr), ntohs(tcph->dest), ntohl(iph->saddr),
 	     ntohs(tcph->source), iph->tos);
 
-	dst = find_route(dev, iph->daddr, iph->saddr, tcph->dest, tcph->source,
-			 iph->tos);
+	dst = cxgb_find_route(&dev->rdev.lldi, get_real_dev,
+			      iph->daddr, iph->saddr, tcph->dest,
+			      tcph->source, iph->tos);
 	if (!dst) {
 		pr_err("%s - failed to find dst entry!\n",
 		       __func__);
diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c
index d7342bb..a318412 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c
@@ -32,6 +32,7 @@
 
 #include <linux/tcp.h>
 #include <linux/ipv6.h>
+#include <net/route.h>
 
 #include "libcxgb_cm.h"
 
@@ -70,3 +71,46 @@ cxgb_get_4tuple(struct cpl_pass_accept_req *req, enum chip_type type,
 	*local_port = tcp->dest;
 }
 EXPORT_SYMBOL(cxgb_get_4tuple);
+
+static bool
+cxgb_our_interface(struct cxgb4_lld_info *lldi,
+		   struct net_device *(*get_real_dev)(struct net_device *),
+		   struct net_device *egress_dev)
+{
+	int i;
+
+	egress_dev = get_real_dev(egress_dev);
+	for (i = 0; i < lldi->nports; i++)
+		if (lldi->ports[i] == egress_dev)
+			return true;
+	return false;
+}
+
+struct dst_entry *
+cxgb_find_route(struct cxgb4_lld_info *lldi,
+		struct net_device *(*get_real_dev)(struct net_device *),
+		__be32 local_ip, __be32 peer_ip, __be16 local_port,
+		__be16 peer_port, u8 tos)
+{
+	struct rtable *rt;
+	struct flowi4 fl4;
+	struct neighbour *n;
+
+	rt = ip_route_output_ports(&init_net, &fl4, NULL, peer_ip, local_ip,
+				   peer_port, local_port, IPPROTO_TCP,
+				   tos, 0);
+	if (IS_ERR(rt))
+		return NULL;
+	n = dst_neigh_lookup(&rt->dst, &peer_ip);
+	if (!n)
+		return NULL;
+	if (!cxgb_our_interface(lldi, get_real_dev, n->dev) &&
+	    !(n->dev->flags & IFF_LOOPBACK)) {
+		neigh_release(n);
+		dst_release(&rt->dst);
+		return NULL;
+	}
+	neigh_release(n);
+	return &rt->dst;
+}
+EXPORT_SYMBOL(cxgb_find_route);
diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
index 2ab8d9b..fe69161 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
@@ -39,4 +39,8 @@
 void
 cxgb_get_4tuple(struct cpl_pass_accept_req *, enum chip_type,
 		int *, __u8 *, __u8 *, __be16 *, __be16 *);
+struct dst_entry *
+cxgb_find_route(struct cxgb4_lld_info *,
+		struct net_device *(*)(struct net_device *),
+		__be32, __be32, __be16,	__be16, u8);
 #endif
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_cm.c b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
index 8bb5a25..49b24b9 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_cm.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
@@ -830,33 +830,6 @@ out:
 	return dst;
 }
 
-static struct dst_entry *
-cxgbit_find_route(struct cxgbit_device *cdev, __be32 local_ip, __be32 peer_ip,
-		  __be16 local_port, __be16 peer_port, u8 tos)
-{
-	struct rtable *rt;
-	struct flowi4 fl4;
-	struct neighbour *n;
-
-	rt = ip_route_output_ports(&init_net, &fl4, NULL, peer_ip,
-				   local_ip,
-				   peer_port, local_port, IPPROTO_TCP,
-				   tos, 0);
-	if (IS_ERR(rt))
-		return NULL;
-	n = dst_neigh_lookup(&rt->dst, &peer_ip);
-	if (!n)
-		return NULL;
-	if (!cxgbit_our_interface(cdev, n->dev) &&
-	    !(n->dev->flags & IFF_LOOPBACK)) {
-		neigh_release(n);
-		dst_release(&rt->dst);
-		return NULL;
-	}
-	neigh_release(n);
-	return &rt->dst;
-}
-
 static void cxgbit_set_tcp_window(struct cxgbit_sock *csk, struct port_info *pi)
 {
 	unsigned int linkspeed;
@@ -1315,10 +1288,11 @@ cxgbit_pass_accept_req(struct cxgbit_device *cdev, struct sk_buff *skb)
 			 , __func__, cnp, tid,
 			 local_ip, peer_ip, ntohs(local_port),
 			 ntohs(peer_port), peer_mss);
-		dst = cxgbit_find_route(cdev, *(__be32 *)local_ip,
-					*(__be32 *)peer_ip,
-					local_port, peer_port,
-					PASS_OPEN_TOS_G(ntohl(req->tos_stid)));
+		dst = cxgb_find_route(&cdev->lldi, cxgbit_get_real_dev,
+				      *(__be32 *)local_ip,
+				      *(__be32 *)peer_ip,
+				      local_port, peer_port,
+				      PASS_OPEN_TOS_G(ntohl(req->tos_stid)));
 	} else {
 		pr_debug("%s parent sock %p tid %u laddr %pI6 raddr %pI6 "
 			 "lport %d rport %d peer_mss %d\n"
-- 
2.0.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
