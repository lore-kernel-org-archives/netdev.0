From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH 2/2] net: thunderx: Enable CQE count threshold interrupt
Date: Wed,  9 Dec 2015 17:08:01 +0530
Message-ID: <1449661081-15435-3-git-send-email-sunil.kovvuri@gmail.com>
References: <y>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	p.fedin@samsung.com, Sunil.Goutham@caviumnetworks.com,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <y>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This feature is introduced in pass-2 chip and with this CQ interrupt
coalescing will work based on both timer and count.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h          |    2 ++
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |    2 +-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |    5 ++++-
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |    3 ++-
 4 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 02571f4..e782856 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -34,6 +34,8 @@
 /* NIC priv flags */
 #define	NIC_SRIOV_ENABLED		BIT(0)
 
+#define	VNIC_NAPI_WEIGHT		NAPI_POLL_WEIGHT
+
 /* Min/Max packet size */
 #define	NIC_HW_MIN_FRS			64
 #define	NIC_HW_MAX_FRS			9200 /* 9216 max packet including FCS */
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index c24cb2a..e06a7f8 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1155,7 +1155,7 @@ int nicvf_open(struct net_device *netdev)
 		cq_poll->cq_idx = qidx;
 		cq_poll->nicvf = nic;
 		netif_napi_add(netdev, &cq_poll->napi, nicvf_poll,
-			       NAPI_POLL_WEIGHT);
+			       VNIC_NAPI_WEIGHT);
 		napi_enable(&cq_poll->napi);
 		nic->napi[qidx] = cq_poll;
 	}
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index b11fc09..4e9709e 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -299,7 +299,10 @@ static int nicvf_init_cmp_queue(struct nicvf *nic,
 		return err;
 
 	cq->desc = cq->dmem.base;
-	cq->thresh = CMP_QUEUE_CQE_THRESH;
+	if (!pass1_silicon(nic->pdev))
+		cq->thresh = CMP_QUEUE_CQE_THRESH;
+	else
+		cq->thresh = 0;
 	nic->cq_coalesce_usecs = (CMP_QUEUE_TIMER_THRESH * 0.05) - 1;
 
 	return 0;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
index a4f6667..0fae6ad 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
@@ -10,6 +10,7 @@
 #define NICVF_QUEUES_H
 
 #include <linux/netdevice.h>
+#include "nic.h"
 #include "q_struct.h"
 
 #define MAX_QUEUE_SET			128
@@ -75,7 +76,7 @@
  */
 #define CMP_QSIZE		CMP_QUEUE_SIZE2
 #define CMP_QUEUE_LEN		(1ULL << (CMP_QSIZE + 10))
-#define CMP_QUEUE_CQE_THRESH	0
+#define CMP_QUEUE_CQE_THRESH	(VNIC_NAPI_WEIGHT / 2)
 #define CMP_QUEUE_TIMER_THRESH	80 /* ~2usec */
 
 #define RBDR_SIZE		RBDR_SIZE0
-- 
1.7.1
