From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V6 1/9] liquidio CN23XX: HW config for VF support
Date: Mon, 14 Nov 2016 15:54:39 -0800
Message-ID: <1479167687-9904-2-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1479167687-9904-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-dm3nam03on0059.outbound.protection.outlook.com ([104.47.41.59]:11236
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S938595AbcKOA2z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 19:28:55 -0500
In-Reply-To: <1479167687-9904-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for configuring HW for creating VFs.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 90 ++++++++++++++--------
 .../net/ethernet/cavium/liquidio/octeon_config.h   |  6 ++
 .../net/ethernet/cavium/liquidio/octeon_device.h   | 12 ++-
 3 files changed, 74 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index 380a641..832d710 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -40,11 +40,6 @@
  */
 #define CN23XX_INPUT_JABBER 64600
 
-#define LIOLUT_RING_DISTRIBUTION 9
-const int liolut_num_vfs_to_rings_per_vf[LIOLUT_RING_DISTRIBUTION] = {
-	0, 8, 4, 2, 2, 2, 1, 1, 1
-};
-
 void cn23xx_dump_pf_initialized_regs(struct octeon_device *oct)
 {
 	int i = 0;
@@ -309,9 +304,10 @@ u32 cn23xx_pf_get_oq_ticks(struct octeon_device *oct, u32 time_intr_in_us)
 
 static void cn23xx_setup_global_mac_regs(struct octeon_device *oct)
 {
-	u64 reg_val;
 	u16 mac_no = oct->pcie_port;
 	u16 pf_num = oct->pf_num;
+	u64 reg_val;
+	u64 temp;
 
 	/* programming SRN and TRS for each MAC(0..3)  */
 
@@ -333,6 +329,14 @@ static void cn23xx_setup_global_mac_regs(struct octeon_device *oct)
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
@@ -399,11 +403,12 @@ static int cn23xx_reset_io_queues(struct octeon_device *oct)
 
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
 
@@ -420,6 +425,16 @@ static int cn23xx_pf_setup_global_input_regs(struct octeon_device *oct)
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
@@ -1048,50 +1063,59 @@ static void cn23xx_setup_reg_address(struct octeon_device *oct)
 
 static int cn23xx_sriov_config(struct octeon_device *oct)
 {
-	u32 total_rings;
 	struct octeon_cn23xx_pf *cn23xx = (struct octeon_cn23xx_pf *)oct->chip;
-	/* num_vfs is already filled for us */
+	u32 max_rings, total_rings, max_vfs, rings_per_vf;
 	u32 pf_srn, num_pf_rings;
+	u32 max_possible_vfs;
 
 	cn23xx->conf =
-	    (struct octeon_config *)oct_get_config_info(oct, LIO_23XX);
+		(struct octeon_config *)oct_get_config_info(oct, LIO_23XX);
 	switch (oct->rev_id) {
 	case OCTEON_CN23XX_REV_1_0:
-		total_rings = CN23XX_MAX_RINGS_PER_PF_PASS_1_0;
+		max_rings = CN23XX_MAX_RINGS_PER_PF_PASS_1_0;
+		max_possible_vfs = CN23XX_MAX_VFS_PER_PF_PASS_1_0;
 		break;
 	case OCTEON_CN23XX_REV_1_1:
-		total_rings = CN23XX_MAX_RINGS_PER_PF_PASS_1_1;
+		max_rings = CN23XX_MAX_RINGS_PER_PF_PASS_1_1;
+		max_possible_vfs = CN23XX_MAX_VFS_PER_PF_PASS_1_1;
 		break;
 	default:
-		total_rings = CN23XX_MAX_RINGS_PER_PF;
+		max_rings = CN23XX_MAX_RINGS_PER_PF;
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
-		}
-	}
+	if (max_rings <= num_present_cpus())
+		num_pf_rings = 1;
+	else
+		num_pf_rings = num_present_cpus();
+
+#ifdef CONFIG_PCI_IOV
+	max_vfs = min_t(u32,
+			(max_rings - num_pf_rings), max_possible_vfs);
+	rings_per_vf = 1;
+#else
+	max_vfs = 0;
+	rings_per_vf = 0;
+#endif
+
+	total_rings = num_pf_rings + max_vfs;
 
-	total_rings = num_pf_rings;
 	/* the first ring of the pf */
 	pf_srn = total_rings - num_pf_rings;
 
 	oct->sriov_info.trs = total_rings;
+	oct->sriov_info.max_vfs = max_vfs;
+	oct->sriov_info.rings_per_vf = rings_per_vf;
 	oct->sriov_info.pf_srn = pf_srn;
 	oct->sriov_info.num_pf_rings = num_pf_rings;
-	dev_dbg(&oct->pci_dev->dev, "trs:%d pf_srn:%d num_pf_rings:%d\n",
-		oct->sriov_info.trs, oct->sriov_info.pf_srn,
-		oct->sriov_info.num_pf_rings);
+	dev_notice(&oct->pci_dev->dev, "trs:%d max_vfs:%d rings_per_vf:%d pf_srn:%d num_pf_rings:%d\n",
+		   oct->sriov_info.trs, oct->sriov_info.max_vfs,
+		   oct->sriov_info.rings_per_vf, oct->sriov_info.pf_srn,
+		   oct->sriov_info.num_pf_rings);
+
+	oct->sriov_info.sriov_enabled = 0;
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_config.h b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
index c765568..512bca5 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_config.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
@@ -65,9 +65,15 @@
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
+#define   CN23XX_MAX_RINGS_PER_VF          8
 
 #define   CN23XX_MAX_INPUT_QUEUES	CN23XX_MAX_RINGS_PER_PF
 #define   CN23XX_MAX_IQ_DESCRIPTORS	2048
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
