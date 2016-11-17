From: Chris Lesiak <chris.lesiak@licor.com>
Subject: [PATCH] net: fec: Detect and recover receive queue hangs
Date: Thu, 17 Nov 2016 15:14:42 -0600
Message-ID: <1479417282-15540-1-git-send-email-chris.lesiak@licor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        "Jaccon Bastiaansen" <jaccon.bastiaansen@gmail.com>,
        <chris.lesiak@licor.com>
To: Fugang Duan <fugang.duan@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This corrects a problem that appears to be similar to ERR006358.  But
while ERR006358 is a race when the tx queue transitions from empty to
not empty, this problem is a race when the rx queue transitions from
full to not full.

The symptom is a receive queue that is stuck.  The ENET_RDAR register
will read 0, indicating that there are no empty receive descriptors in
the receive ring.  Since no additional frames can be queued, no RXF
interrupts occur.

This problem can be triggered with a 1 Gb link and about 400 Mbps of
traffic.

This patch detects this condition, sets the work_rx bit, and
reschedules the poll method.

Signed-off-by: Chris Lesiak <chris.lesiak@licor.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index fea0f33..8a87037 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1588,6 +1588,34 @@ fec_enet_interrupt(int irq, void *dev_id)
 	return ret;
 }
 
+static inline bool
+fec_enet_recover_rxq(struct fec_enet_private *fep, u16 queue_id)
+{
+	int work_bit = (queue_id == 0) ? 2 : ((queue_id == 1) ? 0 : 1);
+
+	if (readl(fep->rx_queue[queue_id]->bd.reg_desc_active))
+		return false;
+
+	dev_notice_once(&fep->pdev->dev, "Recovered rx queue\n");
+
+	fep->work_rx |= 1 << work_bit;
+
+	return true;
+}
+
+static inline bool fec_enet_recover_rxqs(struct fec_enet_private *fep)
+{
+	unsigned int q;
+	bool ret = false;
+
+	for (q = 0; q < fep->num_rx_queues; q++) {
+		if (fec_enet_recover_rxq(fep, q))
+			ret = true;
+	}
+
+	return ret;
+}
+
 static int fec_enet_rx_napi(struct napi_struct *napi, int budget)
 {
 	struct net_device *ndev = napi->dev;
@@ -1601,6 +1629,9 @@ static int fec_enet_rx_napi(struct napi_struct *napi, int budget)
 	if (pkts < budget) {
 		napi_complete(napi);
 		writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+
+		if (fec_enet_recover_rxqs(fep) && napi_reschedule(napi))
+			writel(FEC_NAPI_IMASK, fep->hwp + FEC_IMASK);
 	}
 	return pkts;
 }
-- 
2.5.5
