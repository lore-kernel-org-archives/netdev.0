From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V7 6/8] IB/rdma_cm: TOS <=> UP mapping for IBoE
Date: Thu,  5 Apr 2012 10:33:29 +0300
Message-ID: <1333611211-1032-7-git-send-email-amirv@mellanox.com>
References: <1333611211-1032-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>,
	Sean Hefty <sean.hefty@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:44452 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754358Ab2DEHdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 03:33:46 -0400
In-Reply-To: <1333611211-1032-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both tagged traffic and untagged traffic use tc tool mapping.
Treat RDMA TOS same as IP TOS when mapping to SL

Signed-off-by: Amir Vadai <amirv@mellanox.com>
CC: Sean Hefty <sean.hefty@intel.com>
---
 drivers/infiniband/core/cma.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index e3e470f..59fbd70 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -42,6 +42,7 @@
 #include <linux/inetdevice.h>
 #include <linux/slab.h>
 #include <linux/module.h>
+#include <net/route.h>
 
 #include <net/tcp.h>
 #include <net/ipv6.h>
@@ -1826,7 +1827,10 @@ static int cma_resolve_iboe_route(struct rdma_id_private *id_priv)
 	route->path_rec->reversible = 1;
 	route->path_rec->pkey = cpu_to_be16(0xffff);
 	route->path_rec->mtu_selector = IB_SA_EQ;
-	route->path_rec->sl = id_priv->tos >> 5;
+	route->path_rec->sl = netdev_get_prio_tc_map(
+			ndev->priv_flags & IFF_802_1Q_VLAN ?
+				vlan_dev_real_dev(ndev) : ndev,
+			rt_tos2priority(id_priv->tos));
 
 	route->path_rec->mtu = iboe_get_mtu(ndev->mtu);
 	route->path_rec->rate_selector = IB_SA_EQ;
-- 
1.7.8.2
