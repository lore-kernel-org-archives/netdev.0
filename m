From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 2/2] net: thunderx: Fix TL4 configuration for secondary Qsets
Date: Mon, 27 Jun 2016 15:30:03 +0530
Message-ID: <1467021603-26226-3-git-send-email-sunil.kovvuri@gmail.com>
References: <1467021603-26226-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	robert.richter@caviumnetworks.com, Naveen.Reddy@cavium.com,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467021603-26226-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

TL4 calculation for a given SQ of secondary Qsets is incorrect
and goes out of bounds and also for some SQ's TL4 chosen will
transmit data via a different BGX interface and not same as
primary Qset's interface.

This patch fixes this issue.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 95f17f8..16ed203 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -499,6 +499,7 @@ static void nic_tx_channel_cfg(struct nicpf *nic, u8 vnic,
 	u32 rr_quantum;
 	u8 sq_idx = sq->sq_num;
 	u8 pqs_vnic;
+	int svf;
 
 	if (sq->sqs_mode)
 		pqs_vnic = nic->pqs_vf[vnic];
@@ -511,10 +512,19 @@ static void nic_tx_channel_cfg(struct nicpf *nic, u8 vnic,
 	/* 24 bytes for FCS, IPG and preamble */
 	rr_quantum = ((NIC_HW_MAX_FRS + 24) / 4);
 
-	tl4 = (lmac * NIC_TL4_PER_LMAC) + (bgx * NIC_TL4_PER_BGX);
+	if (!sq->sqs_mode) {
+		tl4 = (lmac * NIC_TL4_PER_LMAC) + (bgx * NIC_TL4_PER_BGX);
+	} else {
+		for (svf = 0; svf < MAX_SQS_PER_VF; svf++) {
+			if (nic->vf_sqs[pqs_vnic][svf] == vnic)
+				break;
+		}
+		tl4 = (MAX_LMAC_PER_BGX * NIC_TL4_PER_LMAC);
+		tl4 += (lmac * NIC_TL4_PER_LMAC * MAX_SQS_PER_VF);
+		tl4 += (svf * NIC_TL4_PER_LMAC);
+		tl4 += (bgx * NIC_TL4_PER_BGX);
+	}
 	tl4 += sq_idx;
-	if (sq->sqs_mode)
-		tl4 += vnic * 8;
 
 	tl3 = tl4 / (NIC_MAX_TL4 / NIC_MAX_TL3);
 	nic_reg_write(nic, NIC_PF_QSET_0_127_SQ_0_7_CFG2 |
-- 
2.7.4
