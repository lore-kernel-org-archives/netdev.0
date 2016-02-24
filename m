From: sunil.kovvuri@gmail.com
Subject: [PATCH] net: thunderx: Fix for Qset error due to CQ full
Date: Wed, 24 Feb 2016 16:40:50 +0530
Message-ID: <1456312250-25694-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sgoutham@cavium.com, robert.richter@caviumnetworks.com,
	jerin.jacob@caviumnetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

On Thunderx pass 1.x and pass2 due to a HW errata default CQ
DROP_LEVEL of 0x80 is not sufficient to avoid CQ_WR_FULL Qset
error when packets are being received at >20Mpps resulting in
complete stall of packet reception.

This patch will configure it to 0x100 which is what is expected
by HW on Thunderx. On future passes of thunderx and other chips
HW default/reset value will be 0x100 or higher hence not overwritten.

Signed-off-by: Jerin Jacob <jerin.jacob@caviumnetworks.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h      |    9 +++++++++
 drivers/net/ethernet/cavium/thunder/nic_main.c |    6 ++++++
 drivers/net/ethernet/cavium/thunder/nic_reg.h  |    2 +-
 3 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 6888288..34e9ace 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -116,6 +116,15 @@
 #define NIC_PF_INTR_ID_MBOX0		8
 #define NIC_PF_INTR_ID_MBOX1		9
 
+/* Minimum FIFO level before all packets for the CQ are dropped
+ *
+ * This value ensures that once a packet has been "accepted"
+ * for reception it will not get dropped due to non-availability
+ * of CQ descriptor. An errata in HW mandates this value to be
+ * atleast 0x100.
+ */
+#define NICPF_CQM_MIN_DROP_LEVEL       0x100
+
 /* Global timer for CQ timer thresh interrupts
  * Calculated for SCLK of 700Mhz
  * value written should be a 1/16th of what is expected
diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 4dded90..95f17f8 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -304,6 +304,7 @@ static void nic_set_lmac_vf_mapping(struct nicpf *nic)
 static void nic_init_hw(struct nicpf *nic)
 {
 	int i;
+	u64 cqm_cfg;
 
 	/* Enable NIC HW block */
 	nic_reg_write(nic, NIC_PF_CFG, 0x3);
@@ -340,6 +341,11 @@ static void nic_init_hw(struct nicpf *nic)
 	/* Enable VLAN ethertype matching and stripping */
 	nic_reg_write(nic, NIC_PF_RX_ETYPE_0_7,
 		      (2 << 19) | (ETYPE_ALG_VLAN_STRIP << 16) | ETH_P_8021Q);
+
+	/* Check if HW expected value is higher (could be in future chips) */
+	cqm_cfg = nic_reg_read(nic, NIC_PF_CQM_CFG);
+	if (cqm_cfg < NICPF_CQM_MIN_DROP_LEVEL)
+		nic_reg_write(nic, NIC_PF_CQM_CFG, NICPF_CQM_MIN_DROP_LEVEL);
 }
 
 /* Channel parse index configuration */
diff --git a/drivers/net/ethernet/cavium/thunder/nic_reg.h b/drivers/net/ethernet/cavium/thunder/nic_reg.h
index dd536be..afb10e3 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_reg.h
+++ b/drivers/net/ethernet/cavium/thunder/nic_reg.h
@@ -21,7 +21,7 @@
 #define   NIC_PF_TCP_TIMER			(0x0060)
 #define   NIC_PF_BP_CFG				(0x0080)
 #define   NIC_PF_RRM_CFG			(0x0088)
-#define   NIC_PF_CQM_CF				(0x00A0)
+#define   NIC_PF_CQM_CFG			(0x00A0)
 #define   NIC_PF_CNM_CF				(0x00A8)
 #define   NIC_PF_CNM_STATUS			(0x00B0)
 #define   NIC_PF_CQ_AVG_CFG			(0x00C0)
-- 
1.7.1
