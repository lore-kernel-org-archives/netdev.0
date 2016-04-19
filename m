From: sunil.kovvuri@gmail.com
Subject: [PATCH 4/4] net: thunderx: Improvement for MBX interface debug messages
Date: Tue, 19 Apr 2016 19:03:32 +0530
Message-ID: <1461072812-44239-5-git-send-email-sunil.kovvuri@gmail.com>
References: <1461072812-44239-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sgoutham@cavium.com, robert.richter@caviumnetworks.com,
	Radoslaw Biernacki <rad@semihalf.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461072812-44239-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Radoslaw Biernacki <rad@semihalf.com>

Adding debug messages in case of NACK for a mailbox message, also
did small cleanups.

Signed-off-by: Radoslaw Biernacki <rad@semihalf.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c   |   16 ++++++++++------
 drivers/net/ethernet/cavium/thunder/nicvf_main.c |    8 ++++++--
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index e2d8db9..550a950 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -820,7 +820,7 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 		mbx_addr += sizeof(u64);
 	}
 
-	dev_dbg(&nic->pdev->dev, "%s: Mailbox msg %d from VF%d\n",
+	dev_dbg(&nic->pdev->dev, "%s: Mailbox msg 0x%02x from VF%d\n",
 		__func__, mbx.msg.msg, vf);
 	switch (mbx.msg.msg) {
 	case NIC_MBOX_MSG_READY:
@@ -830,8 +830,7 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 			nic->duplex[vf] = 0;
 			nic->speed[vf] = 0;
 		}
-		ret = 1;
-		break;
+		goto unlock;
 	case NIC_MBOX_MSG_QS_CFG:
 		reg_addr = NIC_PF_QSET_0_127_CFG |
 			   (mbx.qs.num << NIC_QS_ID_SHIFT);
@@ -873,8 +872,10 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 		nic_tx_channel_cfg(nic, mbx.qs.num, &mbx.sq);
 		break;
 	case NIC_MBOX_MSG_SET_MAC:
-		if (vf >= nic->num_vf_en)
+		if (vf >= nic->num_vf_en) {
+			ret = -1; /* NACK */
 			break;
+		}
 		lmac = mbx.mac.vf_id;
 		bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[lmac]);
 		lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[lmac]);
@@ -934,10 +935,13 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 		break;
 	}
 
-	if (!ret)
+	if (!ret) {
 		nic_mbx_send_ack(nic, vf);
-	else if (mbx.msg.msg != NIC_MBOX_MSG_READY)
+	} else if (mbx.msg.msg != NIC_MBOX_MSG_READY) {
+		dev_err(&nic->pdev->dev, "NACK for MBOX 0x%02x from VF %d\n",
+			mbx.msg.msg, vf);
 		nic_mbx_send_nack(nic, vf);
+	}
 unlock:
 	nic->mbx_lock[vf] = false;
 }
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 87d0f56..12ea73a 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -134,15 +134,19 @@ int nicvf_send_msg_to_pf(struct nicvf *nic, union nic_mbx *mbx)
 
 	/* Wait for previous message to be acked, timeout 2sec */
 	while (!nic->pf_acked) {
-		if (nic->pf_nacked)
+		if (nic->pf_nacked) {
+			netdev_err(nic->netdev,
+				   "PF NACK to mbox msg 0x%02x from VF%d\n",
+				   (mbx->msg.msg & 0xFF), nic->vf_id);
 			return -EINVAL;
+		}
 		msleep(sleep);
 		if (nic->pf_acked)
 			break;
 		timeout -= sleep;
 		if (!timeout) {
 			netdev_err(nic->netdev,
-				   "PF didn't ack to mbox msg %d from VF%d\n",
+				   "PF didn't ACK to mbox msg 0x%02x from VF%d\n",
 				   (mbx->msg.msg & 0xFF), nic->vf_id);
 			return -EBUSY;
 		}
-- 
1.7.1
