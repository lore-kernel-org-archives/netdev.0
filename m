From: sunil.kovvuri@gmail.com
Subject: [PATCH 15/21] net: thunderx: Improvement for MBX interface debug
 messages
Date: Wed, 10 Aug 2016 12:12:47 +0530
Message-ID: <1470811373-28277-16-git-send-email-sunil.kovvuri@gmail.com>
References: <1470811373-28277-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, Radoslaw Biernacki <rad@semihalf.com>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1470811373-28277-1-git-send-email-sunil.kovvuri@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Radoslaw Biernacki <rad@semihalf.com>

Adding debug messages in case of NACK for a mailbox message, also
did small cleanups.

Signed-off-by: Radoslaw Biernacki <rad@semihalf.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c   | 16 ++++++++++------
 drivers/net/ethernet/cavium/thunder/nicvf_main.c |  8 ++++++--
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 8ed8ecd..668cfd9 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -831,7 +831,7 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 		mbx_addr += sizeof(u64);
 	}
 
-	dev_dbg(&nic->pdev->dev, "%s: Mailbox msg %d from VF%d\n",
+	dev_dbg(&nic->pdev->dev, "%s: Mailbox msg 0x%02x from VF%d\n",
 		__func__, mbx.msg.msg, vf);
 	switch (mbx.msg.msg) {
 	case NIC_MBOX_MSG_READY:
@@ -841,8 +841,7 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 			nic->duplex[vf] = 0;
 			nic->speed[vf] = 0;
 		}
-		ret = 1;
-		break;
+		goto unlock;
 	case NIC_MBOX_MSG_QS_CFG:
 		reg_addr = NIC_PF_QSET_0_127_CFG |
 			   (mbx.qs.num << NIC_QS_ID_SHIFT);
@@ -891,8 +890,10 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
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
@@ -947,10 +948,13 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
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
index dbb61a8..300416a 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -144,15 +144,19 @@ int nicvf_send_msg_to_pf(struct nicvf *nic, union nic_mbx *mbx)
 
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
2.7.4
