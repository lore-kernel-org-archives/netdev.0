From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v2 4/8] enic: alloc/free rx_cpu_rmap
Date: Wed, 18 Jun 2014 13:08:04 +0530
Message-ID: <1403077088-4818-5-git-send-email-_govind@gmx.com>
References: <1403077088-4818-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:57807 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964781AbaFRHjt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 03:39:49 -0400
In-Reply-To: <1403077088-4818-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rx_cpu_rmap provides the reverse irq cpu affinity. This patch allocates and
sets drivers netdev->rx_cpu_rmap accordingly.

rx_cpu_rmap is set in enic_request_intr() which is called by enic_open and
rx_cpu_rmap is freed in enic_free_intr() which is called by enic_stop.

This is used by Accelerated RFS.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 43 +++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index f32f828..151b375 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -39,6 +39,9 @@
 #include <linux/prefetch.h>
 #include <net/ip6_checksum.h>
 #include <linux/ktime.h>
+#ifdef CONFIG_RFS_ACCEL
+#include <linux/cpu_rmap.h>
+#endif
 
 #include "cq_enet_desc.h"
 #include "vnic_dev.h"
@@ -1192,6 +1195,44 @@ static void enic_calc_int_moderation(struct enic *enic, struct vnic_rq *rq)
 	pkt_size_counter->small_pkt_bytes_cnt = 0;
 }
 
+#ifdef CONFIG_RFS_ACCEL
+static void enic_free_rx_cpu_rmap(struct enic *enic)
+{
+	free_irq_cpu_rmap(enic->netdev->rx_cpu_rmap);
+	enic->netdev->rx_cpu_rmap = NULL;
+}
+
+static void enic_set_rx_cpu_rmap(struct enic *enic)
+{
+	int i, res;
+
+	if (vnic_dev_get_intr_mode(enic->vdev) == VNIC_DEV_INTR_MODE_MSIX) {
+		enic->netdev->rx_cpu_rmap = alloc_irq_cpu_rmap(enic->rq_count);
+		if (unlikely(!enic->netdev->rx_cpu_rmap))
+			return;
+		for (i = 0; i < enic->rq_count; i++) {
+			res = irq_cpu_rmap_add(enic->netdev->rx_cpu_rmap,
+					       enic->msix_entry[i].vector);
+			if (unlikely(res)) {
+				enic_free_rx_cpu_rmap(enic);
+				return;
+			}
+		}
+	}
+}
+
+#else
+
+static void enic_free_rx_cpu_rmap(struct enic *enic)
+{
+}
+
+static void enic_set_rx_cpu_rmap(struct enic *enic)
+{
+}
+
+#endif /* CONFIG_RFS_ACCEL */
+
 static int enic_poll_msix(struct napi_struct *napi, int budget)
 {
 	struct net_device *netdev = napi->dev;
@@ -1267,6 +1308,7 @@ static void enic_free_intr(struct enic *enic)
 	struct net_device *netdev = enic->netdev;
 	unsigned int i;
 
+	enic_free_rx_cpu_rmap(enic);
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
 	case VNIC_DEV_INTR_MODE_INTX:
 		free_irq(enic->pdev->irq, netdev);
@@ -1291,6 +1333,7 @@ static int enic_request_intr(struct enic *enic)
 	unsigned int i, intr;
 	int err = 0;
 
+	enic_set_rx_cpu_rmap(enic);
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
 
 	case VNIC_DEV_INTR_MODE_INTX:
-- 
2.0.0
