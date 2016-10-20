From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 1/9] liquidio CN23XX: HW config for VF support
Date: Wed, 19 Oct 2016 22:40:38 -0700
Message-ID: <1476942046-18789-2-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1476942046-18789-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0056.outbound.protection.outlook.com ([104.47.33.56]:51168
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752106AbcJTHNO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 03:13:14 -0400
In-Reply-To: <1476942046-18789-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for configuring HW for creating VFs.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 125 +++++++++++++++++----
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  18 +++
 .../net/ethernet/cavium/liquidio/octeon_config.h   |   5 +
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  12 +-
 4 files changed, 137 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index 380a641..c7257ed 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -309,9 +309,10 @@ u32 cn23xx_pf_get_oq_ticks(struct octeon_device *oct, u32 time_intr_in_us)
 
 static void cn23xx_setup_global_mac_regs(struct octeon_device *oct)
 {
-	u64 reg_val;
 	u16 mac_no = oct->pcie_port;
 	u16 pf_num = oct->pf_num;
+	u64 reg_val;
+	u64 temp;
 
 	/* programming SRN and TRS for each MAC(0..3)  */
 
@@ -333,6 +334,14 @@ static void cn23xx_setup_global_mac_regs(struct octeon_device *oct)
 	/* setting TRS <23:16> */
 	reg_val = reg_val |
 		  (oct->sriov_info.trs << CN23XX_PKT_MAC_CTL_RINFO_TRS_BIT_POS);
+	/* setting RPVF <39:32> */
+	temp = oct->sriov_info.rings_per_vf & 0xff;
+	reg_val |= (temp << CN23XX_PKT_MAC_CTL_RINFO_RPVF_BIT_POS);
+
+	/* setting NVFS <55:48> */
+	temp = oct->sriov_info.max_vfs & 0xff;
+	reg_val |= (temp << CN23XX_PKT_MAC_CTL_RINFO_NVFS_BIT_POS);
+
 	/* write these settings to MAC register */
 	octeon_write_csr64(oct, CN23XX_SLI_PKT_MAC_RINFO64(mac_no, pf_num),
 			   reg_val);
@@ -399,11 +408,12 @@ static int cn23xx_reset_io_queues(struct octeon_device *oct)
 
 static int cn23xx_pf_setup_global_input_regs(struct octeon_device *oct)
 {
+	struct octeon_cn23xx_pf *cn23xx = (struct octeon_cn23xx_pf *)oct->chip;
+	struct octeon_instr_queue *iq;
+	u64 intr_threshold, reg_val;
 	u32 q_no, ern, srn;
 	u64 pf_num;
-	u64 intr_threshold, reg_val;
-	struct octeon_instr_queue *iq;
-	struct octeon_cn23xx_pf *cn23xx = (struct octeon_cn23xx_pf *)oct->chip;
+	u64 vf_num;
 
 	pf_num = oct->pf_num;
 
@@ -420,6 +430,16 @@ static int cn23xx_pf_setup_global_input_regs(struct octeon_device *oct)
 	*/
 	for (q_no = 0; q_no < ern; q_no++) {
 		reg_val = oct->pcie_port << CN23XX_PKT_INPUT_CTL_MAC_NUM_POS;
+
+		/* for VF assigned queues. */
+		if (q_no < oct->sriov_info.pf_srn) {
+			vf_num = q_no / oct->sriov_info.rings_per_vf;
+			vf_num += 1; /* VF1, VF2,........ */
+		} else {
+			vf_num = 0;
+		}
+
+		reg_val |= vf_num << CN23XX_PKT_INPUT_CTL_VF_NUM_POS;
 		reg_val |= pf_num << CN23XX_PKT_INPUT_CTL_PF_NUM_POS;
 
 		octeon_write_csr64(oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no),
@@ -1048,49 +1068,110 @@ static void cn23xx_setup_reg_address(struct octeon_device *oct)
 
 static int cn23xx_sriov_config(struct octeon_device *oct)
 {
-	u32 total_rings;
 	struct octeon_cn23xx_pf *cn23xx = (struct octeon_cn23xx_pf *)oct->chip;
-	/* num_vfs is already filled for us */
+	u32 max_vfs = oct->sriov_info.max_vfs;
+	u32 rings_per_vf, max_possible_vfs;
 	u32 pf_srn, num_pf_rings;
+	u32 total_rings;
 
 	cn23xx->conf =
-	    (struct octeon_config *)oct_get_config_info(oct, LIO_23XX);
+		(struct octeon_config *)oct_get_config_info(oct, LIO_23XX);
 	switch (oct->rev_id) {
 	case OCTEON_CN23XX_REV_1_0:
 		total_rings = CN23XX_MAX_RINGS_PER_PF_PASS_1_0;
+		max_possible_vfs = CN23XX_MAX_VFS_PER_PF_PASS_1_0;
 		break;
 	case OCTEON_CN23XX_REV_1_1:
 		total_rings = CN23XX_MAX_RINGS_PER_PF_PASS_1_1;
+		max_possible_vfs = CN23XX_MAX_VFS_PER_PF_PASS_1_1;
 		break;
 	default:
 		total_rings = CN23XX_MAX_RINGS_PER_PF;
+		max_possible_vfs = CN23XX_MAX_VFS_PER_PF;
 		break;
 	}
-	if (!oct->sriov_info.num_pf_rings) {
-		if (total_rings > num_present_cpus())
-			num_pf_rings = num_present_cpus();
-		else
-			num_pf_rings = total_rings;
-	} else {
-		num_pf_rings = oct->sriov_info.num_pf_rings;
 
-		if (num_pf_rings > total_rings) {
-			dev_warn(&oct->pci_dev->dev,
-				 "num_queues_per_pf requested %u is more than available rings. Reducing to %u\n",
-				 num_pf_rings, total_rings);
-			num_pf_rings = total_rings;
+	if (max_vfs > min((total_rings - 1), max_possible_vfs)) {
+		dev_warn(&oct->pci_dev->dev, "max_vfs requested %u is more than available rings. Reducing to %u\n",
+			 max_vfs, min((total_rings - 1), max_possible_vfs));
+		max_vfs = min((total_rings - 1), max_possible_vfs);
+	}
+
+	if (!max_vfs) {
+		dev_dbg(&oct->pci_dev->dev, "max_vfs is zero, will derive max_vfs based on number of pf rings\n");
+		rings_per_vf = 0;
+
+		if (!oct->sriov_info.num_pf_rings) {
+			if (total_rings > num_present_cpus())
+				num_pf_rings = num_present_cpus();
+			else
+				num_pf_rings = total_rings;
+		} else {
+			num_pf_rings = oct->sriov_info.num_pf_rings;
+
+			if (num_pf_rings > total_rings) {
+				dev_warn(&oct->pci_dev->dev,
+					 "num_queues_per_pf requested %u is more than available rings. Reducing to %u\n",
+					 num_pf_rings, total_rings);
+				num_pf_rings = total_rings;
+			}
+		}
+
+		max_vfs = total_rings - num_pf_rings;
+
+		if (max_vfs)
+			rings_per_vf = 1;
+	} else {
+		if (oct->sriov_info.num_pf_rings > 0) {
+			num_pf_rings = oct->sriov_info.num_pf_rings;
+			if (num_pf_rings > (total_rings - max_vfs)) {
+				num_pf_rings = total_rings - max_vfs;
+				dev_warn(&oct->pci_dev->dev,
+					 "num_queues_per_pf requested %u is more than available rings. Reducing to %u\n",
+					 oct->sriov_info.num_pf_rings,
+					 num_pf_rings);
+			}
+			rings_per_vf = rounddown_pow_of_two((total_rings -
+						num_pf_rings) / max_vfs);
+			rings_per_vf = min_t(u32, rings_per_vf,
+					     CN23XX_MAX_RINGS_PER_VF);
+		} else {
+			if ((oct->rev_id == OCTEON_CN23XX_REV_1_0) &&
+			    (max_vfs >= LIOLUT_RING_DISTRIBUTION)) {
+				rings_per_vf = 1;
+				total_rings = max_vfs + 1;
+			} else if (oct->rev_id == OCTEON_CN23XX_REV_1_0) {
+				rings_per_vf = liolut_num_vfs_to_rings_per_vf
+					[max_vfs];
+			} else {
+				rings_per_vf = rounddown_pow_of_two(
+						total_rings / (max_vfs + 1));
+			}
+			rings_per_vf = min_t(u32, rings_per_vf,
+					     CN23XX_MAX_RINGS_PER_VF);
+			num_pf_rings = total_rings - (rings_per_vf * max_vfs);
+
+			if (num_pf_rings > num_present_cpus()) {
+				num_pf_rings = num_present_cpus();
+				total_rings = num_pf_rings +
+					rings_per_vf * max_vfs;
+			}
 		}
 	}
 
-	total_rings = num_pf_rings;
+	total_rings = num_pf_rings + (max_vfs * rings_per_vf);
+
 	/* the first ring of the pf */
 	pf_srn = total_rings - num_pf_rings;
 
 	oct->sriov_info.trs = total_rings;
+	oct->sriov_info.max_vfs = max_vfs;
+	oct->sriov_info.rings_per_vf = rings_per_vf;
 	oct->sriov_info.pf_srn = pf_srn;
 	oct->sriov_info.num_pf_rings = num_pf_rings;
-	dev_dbg(&oct->pci_dev->dev, "trs:%d pf_srn:%d num_pf_rings:%d\n",
-		oct->sriov_info.trs, oct->sriov_info.pf_srn,
+	dev_dbg(&oct->pci_dev->dev, "trs:%d max_vfs:%d rings_per_vf:%d pf_srn:%d num_pf_rings:%d\n",
+		oct->sriov_info.trs, oct->sriov_info.max_vfs,
+		oct->sriov_info.rings_per_vf, oct->sriov_info.pf_srn,
 		oct->sriov_info.num_pf_rings);
 	return 0;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 71d01a7..016b7aa 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -69,6 +69,19 @@
 module_param(conf_type, int, 0);
 MODULE_PARM_DESC(conf_type, "select octeon configuration 0 default 1 ovs");
 
+/* Default behaviour of Liquidio is to provide one queue per VF. But Liquidio
+ * can also provide multiple queues to each VF. If user wants to change the
+ * default behaviour HW should be provided configuration info at init time,
+ * based on which it will create control queues for communicating with FW.
+ */
+static u32 max_vfs[2] = { 0, 0 };
+module_param_array(max_vfs, int, NULL, 0444);
+MODULE_PARM_DESC(max_vfs, "Assign two comma-separated unsigned integers that specify max number of VFs for PF0 (left of the comma) and PF1 (right of the comma); for 23xx only. By default HW will configure as many VFs as queues after allocating PF queues.To increase queues for VF use this parameter. Use sysfs to create these VFs.");
+
+static unsigned int num_queues_per_pf[2] = { 0, 0 };
+module_param_array(num_queues_per_pf, uint, NULL, 0444);
+MODULE_PARM_DESC(num_queues_per_pf, "two comma-separated unsigned integers that specify number of queues per PF0 (left of the comma) and PF1 (right of the comma); for 23xx only");
+
 static int ptp_enable = 1;
 
 /* Bit mask values for lio->ifstate */
@@ -1730,6 +1743,11 @@ static int octeon_chip_specific_setup(struct octeon_device *oct)
 
 	case OCTEON_CN23XX_PCIID_PF:
 		oct->chip_id = OCTEON_CN23XX_PF_VID;
+		oct->sriov_info.max_vfs = max_vfs[oct->pci_dev->devfn];
+		if (num_queues_per_pf[oct->pci_dev->devfn] > 0) {
+			oct->sriov_info.num_pf_rings =
+			    num_queues_per_pf[oct->pci_dev->devfn];
+		}
 		ret = setup_cn23xx_octeon_pf_device(oct);
 		s = "CN23XX";
 		break;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_config.h b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
index c765568..0127a0e 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_config.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
@@ -65,6 +65,11 @@
 #define   DEFAULT_NUM_NIC_PORTS_68XX_210NV  2
 
 /* CN23xx  IQ configuration macros */
+#define   CN23XX_MAX_VFS_PER_PF_PASS_1_0 8
+#define   CN23XX_MAX_VFS_PER_PF_PASS_1_1 31
+#define   CN23XX_MAX_VFS_PER_PF          63
+#define   CN23XX_MAX_RINGS_PER_VF        8
+
 #define   CN23XX_MAX_RINGS_PER_PF_PASS_1_0 12
 #define   CN23XX_MAX_RINGS_PER_PF_PASS_1_1 32
 #define   CN23XX_MAX_RINGS_PER_PF          64
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index da15c2a..751d3b6 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -322,11 +322,21 @@ struct octeon_pf_vf_hs_word {
 };
 
 struct octeon_sriov_info {
+	/* Number of rings assigned to VF */
+	u32	rings_per_vf;
+
+	/** Max Number of VF devices that can be enabled. This variable can
+	 *  specified during load time or it will be derived after allocating
+	 *  PF queues. When max_vfs is derived then each VF will get one queue
+	 **/
+	u32	max_vfs;
+
 	/* Actual rings left for PF device */
 	u32	num_pf_rings;
 
-	/* SRN of PF usable IO queues   */
+	/* SRN of PF usable IO queues */
 	u32	pf_srn;
+
 	/* total pf rings */
 	u32	trs;
 
-- 
1.8.3.1
