From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net V1 3/4] IB/mlx4: Saturate RoCE port PMA counters in case of overflow
Date: Wed, 18 Mar 2015 16:51:37 +0200
Message-ID: <1426690298-10567-4-git-send-email-ogerlitz@mellanox.com>
References: <1426690298-10567-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49371 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754789AbbCROvt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2015 10:51:49 -0400
In-Reply-To: <1426690298-10567-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

For RoCE ports, we set the u32 PMA values based on u64 HCA counters. In case of
overflow, according to the IB spec, we have to saturate a counter to its
max value, do that.

Fixes: c37791349cc7 ('IB/mlx4: Support PMA counters for IBoE')
Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/mad.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
index c761971..5904026 100644
--- a/drivers/infiniband/hw/mlx4/mad.c
+++ b/drivers/infiniband/hw/mlx4/mad.c
@@ -64,6 +64,14 @@ enum {
 #define GUID_TBL_BLK_NUM_ENTRIES 8
 #define GUID_TBL_BLK_SIZE (GUID_TBL_ENTRY_SIZE * GUID_TBL_BLK_NUM_ENTRIES)
 
+/* Counters should be saturate once they reach their maximum value */
+#define ASSIGN_32BIT_COUNTER(counter, value) do {\
+	if ((value) > U32_MAX)			 \
+		counter = cpu_to_be32(U32_MAX); \
+	else					 \
+		counter = cpu_to_be32(value);	 \
+} while (0)
+
 struct mlx4_mad_rcv_buf {
 	struct ib_grh grh;
 	u8 payload[256];
@@ -806,10 +814,14 @@ static int ib_process_mad(struct ib_device *ibdev, int mad_flags, u8 port_num,
 static void edit_counter(struct mlx4_counter *cnt,
 					struct ib_pma_portcounters *pma_cnt)
 {
-	pma_cnt->port_xmit_data = cpu_to_be32((be64_to_cpu(cnt->tx_bytes)>>2));
-	pma_cnt->port_rcv_data  = cpu_to_be32((be64_to_cpu(cnt->rx_bytes)>>2));
-	pma_cnt->port_xmit_packets = cpu_to_be32(be64_to_cpu(cnt->tx_frames));
-	pma_cnt->port_rcv_packets  = cpu_to_be32(be64_to_cpu(cnt->rx_frames));
+	ASSIGN_32BIT_COUNTER(pma_cnt->port_xmit_data,
+			     (be64_to_cpu(cnt->tx_bytes) >> 2));
+	ASSIGN_32BIT_COUNTER(pma_cnt->port_rcv_data,
+			     (be64_to_cpu(cnt->rx_bytes) >> 2));
+	ASSIGN_32BIT_COUNTER(pma_cnt->port_xmit_packets,
+			     be64_to_cpu(cnt->tx_frames));
+	ASSIGN_32BIT_COUNTER(pma_cnt->port_rcv_packets,
+			     be64_to_cpu(cnt->rx_frames));
 }
 
 static int iboe_process_mad(struct ib_device *ibdev, int mad_flags, u8 port_num,
-- 
1.7.1
