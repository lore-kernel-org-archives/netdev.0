From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH 6/8] IB/rdma_cm: TOS <=> UP mapping for IBoE
Date: Tue, 13 Mar 2012 19:22:01 +0200
Message-ID: <1331659323-12904-7-git-send-email-amirv@mellanox.com>
References: <1331659323-12904-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>,
	Sean Hefty <sean.hefty@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:40073 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758603Ab2CMRXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 13:23:10 -0400
In-Reply-To: <1331659323-12904-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

Both tagged traffic and untagged traffic use tc tool mapping.
Treat RDMA TOS same as IP TOS when mapping to SL

Since IP TOS to priority mapping is not exported, had to borrow the code from
net/ipv4/route.c

Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
CC: Sean Hefty <sean.hefty@intel.com>

---

We can export IP TOS to priority mapping if the networking maintainers will say
where they want it.
---
 drivers/infiniband/core/cma.c |   35 ++++++++++++++++++++++++++++++++++-
 1 files changed, 34 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index e3e470f..c0eeb2c 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -42,6 +42,7 @@
 #include <linux/inetdevice.h>
 #include <linux/slab.h>
 #include <linux/module.h>
+#include <linux/pkt_sched.h>
 
 #include <net/tcp.h>
 #include <net/ipv6.h>
@@ -1781,6 +1782,32 @@ static int cma_resolve_iw_route(struct rdma_id_private *id_priv, int timeout_ms)
 	return 0;
 }
 
+#define ECN_OR_COST(class)	TC_PRIO_##class
+
+static const __u8 tos2prio[16] = {
+	TC_PRIO_BESTEFFORT,
+	ECN_OR_COST(BESTEFFORT),
+	TC_PRIO_BESTEFFORT,
+	ECN_OR_COST(BESTEFFORT),
+	TC_PRIO_BULK,
+	ECN_OR_COST(BULK),
+	TC_PRIO_BULK,
+	ECN_OR_COST(BULK),
+	TC_PRIO_INTERACTIVE,
+	ECN_OR_COST(INTERACTIVE),
+	TC_PRIO_INTERACTIVE,
+	ECN_OR_COST(INTERACTIVE),
+	TC_PRIO_INTERACTIVE_BULK,
+	ECN_OR_COST(INTERACTIVE_BULK),
+	TC_PRIO_INTERACTIVE_BULK,
+	ECN_OR_COST(INTERACTIVE_BULK)
+};
+
+static inline char cma_tos2priority(u8 tos)
+{
+	return tos2prio[IPTOS_TOS(tos)>>1];
+}
+
 static int cma_resolve_iboe_route(struct rdma_id_private *id_priv)
 {
 	struct rdma_route *route = &id_priv->id.route;
@@ -1826,7 +1853,13 @@ static int cma_resolve_iboe_route(struct rdma_id_private *id_priv)
 	route->path_rec->reversible = 1;
 	route->path_rec->pkey = cpu_to_be16(0xffff);
 	route->path_rec->mtu_selector = IB_SA_EQ;
-	route->path_rec->sl = id_priv->tos >> 5;
+	if (ndev->priv_flags & IFF_802_1Q_VLAN)
+		route->path_rec->sl =
+			netdev_get_prio_tc_map(vlan_dev_real_dev(ndev),
+					cma_tos2priority(id_priv->tos));
+	else
+		route->path_rec->sl = netdev_get_prio_tc_map(ndev,
+				cma_tos2priority(id_priv->tos));
 
 	route->path_rec->mtu = iboe_get_mtu(ndev->mtu);
 	route->path_rec->rate_selector = IB_SA_EQ;
-- 
1.7.8.2
