From: Varun Prakash <varun@chelsio.com>
Subject: [net-next PATCH 03/11] libcxgb,iw_cxgb4,cxgbit: add cxgb_find_route6()
Date: Tue, 13 Sep 2016 21:23:58 +0530
Message-ID: <c1fe746311141c25fda314944f557550286a2d95.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        target-devel@vger.kernel.org, nab@linux-iscsi.org,
        dledford@redhat.com, swise@opengridcomputing.com,
        gerlitz.or@gmail.com, indranil@chelsio.com, varun@chelsio.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:52468 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1758563AbcIMP47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 11:56:59 -0400
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add cxgb_find_route6() in libcxgb_cm.c to remove
it's duplicate definitions from cxgb4/cm.c and
cxgbit/cxgbit_cm.c.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c                  | 70 ++++++-----------------
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c | 33 +++++++++++
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h |  4 ++
 drivers/target/iscsi/cxgbit/cxgbit_cm.c           | 51 ++---------------
 4 files changed, 61 insertions(+), 97 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 02f5e20..a08a748 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -465,46 +465,6 @@ static struct net_device *get_real_dev(struct net_device *egress_dev)
 	return rdma_vlan_dev_real_dev(egress_dev) ? : egress_dev;
 }
 
-static int our_interface(struct c4iw_dev *dev, struct net_device *egress_dev)
-{
-	int i;
-
-	egress_dev = get_real_dev(egress_dev);
-	for (i = 0; i < dev->rdev.lldi.nports; i++)
-		if (dev->rdev.lldi.ports[i] == egress_dev)
-			return 1;
-	return 0;
-}
-
-static struct dst_entry *find_route6(struct c4iw_dev *dev, __u8 *local_ip,
-				     __u8 *peer_ip, __be16 local_port,
-				     __be16 peer_port, u8 tos,
-				     __u32 sin6_scope_id)
-{
-	struct dst_entry *dst = NULL;
-
-	if (IS_ENABLED(CONFIG_IPV6)) {
-		struct flowi6 fl6;
-
-		memset(&fl6, 0, sizeof(fl6));
-		memcpy(&fl6.daddr, peer_ip, 16);
-		memcpy(&fl6.saddr, local_ip, 16);
-		if (ipv6_addr_type(&fl6.daddr) & IPV6_ADDR_LINKLOCAL)
-			fl6.flowi6_oif = sin6_scope_id;
-		dst = ip6_route_output(&init_net, NULL, &fl6);
-		if (!dst)
-			goto out;
-		if (!our_interface(dev, ip6_dst_idev(dst)->dev) &&
-		    !(ip6_dst_idev(dst)->dev->flags & IFF_LOOPBACK)) {
-			dst_release(dst);
-			dst = NULL;
-		}
-	}
-
-out:
-	return dst;
-}
-
 static void arp_failure_discard(void *handle, struct sk_buff *skb)
 {
 	pr_err(MOD "ARP failure\n");
@@ -2197,10 +2157,13 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 		iptype = 4;
 		ra = (__u8 *)&raddr->sin_addr;
 	} else {
-		ep->dst = find_route6(ep->com.dev, laddr6->sin6_addr.s6_addr,
-				      raddr6->sin6_addr.s6_addr,
-				      laddr6->sin6_port, raddr6->sin6_port, 0,
-				      raddr6->sin6_scope_id);
+		ep->dst = cxgb_find_route6(&ep->com.dev->rdev.lldi,
+					   get_real_dev,
+					   laddr6->sin6_addr.s6_addr,
+					   raddr6->sin6_addr.s6_addr,
+					   laddr6->sin6_port,
+					   raddr6->sin6_port, 0,
+					   raddr6->sin6_scope_id);
 		iptype = 6;
 		ra = (__u8 *)&raddr6->sin6_addr;
 	}
@@ -2540,10 +2503,11 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 		     , __func__, parent_ep, hwtid,
 		     local_ip, peer_ip, ntohs(local_port),
 		     ntohs(peer_port), peer_mss);
-		dst = find_route6(dev, local_ip, peer_ip, local_port, peer_port,
-				  PASS_OPEN_TOS_G(ntohl(req->tos_stid)),
-				  ((struct sockaddr_in6 *)
-				  &parent_ep->com.local_addr)->sin6_scope_id);
+		dst = cxgb_find_route6(&dev->rdev.lldi, get_real_dev,
+				local_ip, peer_ip, local_port, peer_port,
+				PASS_OPEN_TOS_G(ntohl(req->tos_stid)),
+				((struct sockaddr_in6 *)
+				 &parent_ep->com.local_addr)->sin6_scope_id);
 	}
 	if (!dst) {
 		printk(KERN_ERR MOD "%s - failed to find dst entry!\n",
@@ -3339,10 +3303,12 @@ int c4iw_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 		     __func__, laddr6->sin6_addr.s6_addr,
 		     ntohs(laddr6->sin6_port),
 		     raddr6->sin6_addr.s6_addr, ntohs(raddr6->sin6_port));
-		ep->dst = find_route6(dev, laddr6->sin6_addr.s6_addr,
-				      raddr6->sin6_addr.s6_addr,
-				      laddr6->sin6_port, raddr6->sin6_port, 0,
-				      raddr6->sin6_scope_id);
+		ep->dst = cxgb_find_route6(&dev->rdev.lldi, get_real_dev,
+					   laddr6->sin6_addr.s6_addr,
+					   raddr6->sin6_addr.s6_addr,
+					   laddr6->sin6_port,
+					   raddr6->sin6_port, 0,
+					   raddr6->sin6_scope_id);
 	}
 	if (!ep->dst) {
 		printk(KERN_ERR MOD "%s - cannot find route.\n", __func__);
diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c
index a318412..0f0de5b 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.c
@@ -33,6 +33,7 @@
 #include <linux/tcp.h>
 #include <linux/ipv6.h>
 #include <net/route.h>
+#include <net/ip6_route.h>
 
 #include "libcxgb_cm.h"
 
@@ -114,3 +115,35 @@ cxgb_find_route(struct cxgb4_lld_info *lldi,
 	return &rt->dst;
 }
 EXPORT_SYMBOL(cxgb_find_route);
+
+struct dst_entry *
+cxgb_find_route6(struct cxgb4_lld_info *lldi,
+		 struct net_device *(*get_real_dev)(struct net_device *),
+		 __u8 *local_ip, __u8 *peer_ip, __be16 local_port,
+		 __be16 peer_port, u8 tos, __u32 sin6_scope_id)
+{
+	struct dst_entry *dst = NULL;
+
+	if (IS_ENABLED(CONFIG_IPV6)) {
+		struct flowi6 fl6;
+
+		memset(&fl6, 0, sizeof(fl6));
+		memcpy(&fl6.daddr, peer_ip, 16);
+		memcpy(&fl6.saddr, local_ip, 16);
+		if (ipv6_addr_type(&fl6.daddr) & IPV6_ADDR_LINKLOCAL)
+			fl6.flowi6_oif = sin6_scope_id;
+		dst = ip6_route_output(&init_net, NULL, &fl6);
+		if (!dst)
+			goto out;
+		if (!cxgb_our_interface(lldi, get_real_dev,
+					ip6_dst_idev(dst)->dev) &&
+		    !(ip6_dst_idev(dst)->dev->flags & IFF_LOOPBACK)) {
+			dst_release(dst);
+			dst = NULL;
+		}
+	}
+
+out:
+	return dst;
+}
+EXPORT_SYMBOL(cxgb_find_route6);
diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
index fe69161..c4df04a 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
@@ -43,4 +43,8 @@ struct dst_entry *
 cxgb_find_route(struct cxgb4_lld_info *,
 		struct net_device *(*)(struct net_device *),
 		__be32, __be32, __be16,	__be16, u8);
+struct dst_entry *
+cxgb_find_route6(struct cxgb4_lld_info *,
+		 struct net_device *(*)(struct net_device *),
+		 __u8 *, __u8 *, __be16, __be16, u8, __u32);
 #endif
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_cm.c b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
index 49b24b9..e961ac4 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_cm.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
@@ -790,46 +790,6 @@ void _cxgbit_free_csk(struct kref *kref)
 	kfree(csk);
 }
 
-static int
-cxgbit_our_interface(struct cxgbit_device *cdev, struct net_device *egress_dev)
-{
-	u8 i;
-
-	egress_dev = cxgbit_get_real_dev(egress_dev);
-	for (i = 0; i < cdev->lldi.nports; i++)
-		if (cdev->lldi.ports[i] == egress_dev)
-			return 1;
-	return 0;
-}
-
-static struct dst_entry *
-cxgbit_find_route6(struct cxgbit_device *cdev, __u8 *local_ip, __u8 *peer_ip,
-		   __be16 local_port, __be16 peer_port, u8 tos,
-		   __u32 sin6_scope_id)
-{
-	struct dst_entry *dst = NULL;
-
-	if (IS_ENABLED(CONFIG_IPV6)) {
-		struct flowi6 fl6;
-
-		memset(&fl6, 0, sizeof(fl6));
-		memcpy(&fl6.daddr, peer_ip, 16);
-		memcpy(&fl6.saddr, local_ip, 16);
-		if (ipv6_addr_type(&fl6.daddr) & IPV6_ADDR_LINKLOCAL)
-			fl6.flowi6_oif = sin6_scope_id;
-		dst = ip6_route_output(&init_net, NULL, &fl6);
-		if (!dst)
-			goto out;
-		if (!cxgbit_our_interface(cdev, ip6_dst_idev(dst)->dev) &&
-		    !(ip6_dst_idev(dst)->dev->flags & IFF_LOOPBACK)) {
-			dst_release(dst);
-			dst = NULL;
-		}
-	}
-out:
-	return dst;
-}
-
 static void cxgbit_set_tcp_window(struct cxgbit_sock *csk, struct port_info *pi)
 {
 	unsigned int linkspeed;
@@ -1299,11 +1259,12 @@ cxgbit_pass_accept_req(struct cxgbit_device *cdev, struct sk_buff *skb)
 			 , __func__, cnp, tid,
 			 local_ip, peer_ip, ntohs(local_port),
 			 ntohs(peer_port), peer_mss);
-		dst = cxgbit_find_route6(cdev, local_ip, peer_ip,
-					 local_port, peer_port,
-					 PASS_OPEN_TOS_G(ntohl(req->tos_stid)),
-					 ((struct sockaddr_in6 *)
-					 &cnp->com.local_addr)->sin6_scope_id);
+		dst = cxgb_find_route6(&cdev->lldi, cxgbit_get_real_dev,
+				       local_ip, peer_ip,
+				       local_port, peer_port,
+				       PASS_OPEN_TOS_G(ntohl(req->tos_stid)),
+				       ((struct sockaddr_in6 *)
+					&cnp->com.local_addr)->sin6_scope_id);
 	}
 	if (!dst) {
 		pr_err("%s - failed to find dst entry!\n",
-- 
2.0.2
