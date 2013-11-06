From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/2] RDMA/cma: Set IBoE SL (user-priority) by egress map when using vlans
Date: Wed,  6 Nov 2013 15:37:24 +0200
Message-ID: <1383745044-32575-3-git-send-email-ogerlitz@mellanox.com>
References: <1383745044-32575-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, sean.hefty@intel.com,
	eyalpe@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:45613 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756580Ab3KFNhf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Nov 2013 08:37:35 -0500
In-Reply-To: <1383745044-32575-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

On top of commit 366cddb40 "IB/rdma_cm: TOS <=> UP mapping for IBoE", add
support for case vlan egress map is used.

When the IBoE session is being set over a vlan, inherit the socket priority
to vlan priority mapping which was configured for the vlan device egress map.

Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/core/cma.c |   26 +++++++++++++++++++++-----
 1 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index a082fd9..d2172e7 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1848,6 +1848,26 @@ static int cma_resolve_iw_route(struct rdma_id_private *id_priv, int timeout_ms)
 	return 0;
 }
 
+static int iboe_tos_to_sl(struct net_device *ndev, int tos)
+{
+	int prio;
+	struct net_device *dev;
+
+	prio = rt_tos2priority(tos);
+	dev = ndev->priv_flags & IFF_802_1Q_VLAN ?
+		vlan_dev_real_dev(ndev) : ndev;
+
+	if (dev->num_tc)
+		return netdev_get_prio_tc_map(dev, prio);
+
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
+	if (ndev->priv_flags & IFF_802_1Q_VLAN)
+		return (vlan_dev_get_egress_qos_mask(ndev, prio) &
+			VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
+#endif
+	return 0;
+}
+
 static int cma_resolve_iboe_route(struct rdma_id_private *id_priv)
 {
 	struct rdma_route *route = &id_priv->id.route;
@@ -1888,11 +1908,7 @@ static int cma_resolve_iboe_route(struct rdma_id_private *id_priv)
 	route->path_rec->reversible = 1;
 	route->path_rec->pkey = cpu_to_be16(0xffff);
 	route->path_rec->mtu_selector = IB_SA_EQ;
-	route->path_rec->sl = netdev_get_prio_tc_map(
-			ndev->priv_flags & IFF_802_1Q_VLAN ?
-				vlan_dev_real_dev(ndev) : ndev,
-			rt_tos2priority(id_priv->tos));
-
+	route->path_rec->sl = iboe_tos_to_sl(ndev, id_priv->tos);
 	route->path_rec->mtu = iboe_get_mtu(ndev->mtu);
 	route->path_rec->rate_selector = IB_SA_EQ;
 	route->path_rec->rate = iboe_get_rate(ndev);
-- 
1.7.1
