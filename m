From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 1/5] liquidio CN23XX: VF config support
Date: Fri, 9 Sep 2016 13:08:23 -0700
Message-ID: <1473451707-26397-2-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1473451707-26397-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0079.outbound.protection.outlook.com ([104.47.37.79]:60124
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753269AbcIIUXC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 16:23:02 -0400
In-Reply-To: <1473451707-26397-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for VF configuration. It also limits the number
of rings per VF based on total number of VFs configured.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 260 ++++++++++++++++-----
 .../net/ethernet/cavium/liquidio/cn66xx_device.c   |  13 +-
 .../net/ethernet/cavium/liquidio/octeon_config.h   |   5 +
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  10 +-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   9 +-
 5 files changed, 228 insertions(+), 69 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index bddb198..a2953d5 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -312,11 +312,12 @@ static void cn23xx_setup_global_mac_regs(struct octeon_device *oct)
 	u64 reg_val;
 	u16 mac_no = oct->pcie_port;
 	u16 pf_num = oct->pf_num;
+	u64 temp;
 
 	/* programming SRN and TRS for each MAC(0..3)  */
 
-	dev_dbg(&oct->pci_dev->dev, "%s:Using pcie port %d\n",
-		__func__, mac_no);
+	pr_devel("%s:Using pcie port %d\n",
+		 __func__, mac_no);
 	/* By default, mapping all 64 IOQs to  a single MACs */
 
 	reg_val =
@@ -333,13 +334,21 @@ static void cn23xx_setup_global_mac_regs(struct octeon_device *oct)
 	/* setting TRS <23:16> */
 	reg_val = reg_val |
 		  (oct->sriov_info.trs << CN23XX_PKT_MAC_CTL_RINFO_TRS_BIT_POS);
+	/* setting RPVF <39:32> */
+	temp = oct->sriov_info.rings_per_vf & 0xff;
+	reg_val |= (temp << CN23XX_PKT_MAC_CTL_RINFO_RPVF_BIT_POS);
+
+	/* setting NVFS <55:48> */
+	temp = oct->sriov_info.num_vfs & 0xff;
+	reg_val |= (temp << CN23XX_PKT_MAC_CTL_RINFO_NVFS_BIT_POS);
+
 	/* write these settings to MAC register */
 	octeon_write_csr64(oct, CN23XX_SLI_PKT_MAC_RINFO64(mac_no, pf_num),
 			   reg_val);
 
-	dev_dbg(&oct->pci_dev->dev, "SLI_PKT_MAC(%d)_PF(%d)_RINFO : 0x%016llx\n",
-		mac_no, pf_num, (u64)octeon_read_csr64
-		(oct, CN23XX_SLI_PKT_MAC_RINFO64(mac_no, pf_num)));
+	pr_devel("SLI_PKT_MAC(%d)_PF(%d)_RINFO : 0x%016llx\n",
+		 mac_no, pf_num, (u64)octeon_read_csr64
+		 (oct, CN23XX_SLI_PKT_MAC_RINFO64(mac_no, pf_num)));
 }
 
 static int cn23xx_reset_io_queues(struct octeon_device *oct)
@@ -404,6 +413,7 @@ static int cn23xx_pf_setup_global_input_regs(struct octeon_device *oct)
 	u64 intr_threshold, reg_val;
 	struct octeon_instr_queue *iq;
 	struct octeon_cn23xx_pf *cn23xx = (struct octeon_cn23xx_pf *)oct->chip;
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
@@ -590,8 +610,8 @@ static void cn23xx_setup_iq_regs(struct octeon_device *oct, u32 iq_no)
 	    (u8 *)oct->mmio[0].hw_addr + CN23XX_SLI_IQ_DOORBELL(iq_no);
 	iq->inst_cnt_reg =
 	    (u8 *)oct->mmio[0].hw_addr + CN23XX_SLI_IQ_INSTR_COUNT64(iq_no);
-	dev_dbg(&oct->pci_dev->dev, "InstQ[%d]:dbell reg @ 0x%p instcnt_reg @ 0x%p\n",
-		iq_no, iq->doorbell_reg, iq->inst_cnt_reg);
+	pr_devel("InstQ[%d]:dbell reg @ 0x%p instcnt_reg @ 0x%p\n",
+		 iq_no, iq->doorbell_reg, iq->inst_cnt_reg);
 
 	/* Store the current instruction counter (used in flush_iq
 	 * calculation)
@@ -822,7 +842,7 @@ static u64 cn23xx_pf_msix_interrupt_handler(void *dev)
 	u64 ret = 0;
 	struct octeon_droq *droq = oct->droq[ioq_vector->droq_index];
 
-	dev_dbg(&oct->pci_dev->dev, "In %s octeon_dev @ %p\n", __func__, oct);
+	pr_devel("In %s octeon_dev @ %p\n", __func__, oct);
 
 	if (!droq) {
 		dev_err(&oct->pci_dev->dev, "23XX bringup FIXME: oct pfnum:%d ioq_vector->ioq_num :%d droq is NULL\n",
@@ -862,7 +882,7 @@ static irqreturn_t cn23xx_interrupt_handler(void *dev)
 	struct octeon_cn23xx_pf *cn23xx = (struct octeon_cn23xx_pf *)oct->chip;
 	u64 intr64;
 
-	dev_dbg(&oct->pci_dev->dev, "In %s octeon_dev @ %p\n", __func__, oct);
+	pr_devel("In %s octeon_dev @ %p\n", __func__, oct);
 	intr64 = readq(cn23xx->intr_sum_reg64);
 
 	oct->int_status = 0;
@@ -983,8 +1003,8 @@ static void cn23xx_get_pcie_qlmport(struct octeon_device *oct)
 {
 	oct->pcie_port = (octeon_read_csr(oct, CN23XX_SLI_MAC_NUMBER)) & 0xff;
 
-	dev_dbg(&oct->pci_dev->dev, "OCTEON: CN23xx uses PCIE Port %d\n",
-		oct->pcie_port);
+	pr_devel("OCTEON: CN23xx uses PCIE Port %d\n",
+		 oct->pcie_port);
 }
 
 static void cn23xx_get_pf_num(struct octeon_device *oct)
@@ -1046,11 +1066,27 @@ static void cn23xx_setup_reg_address(struct octeon_device *oct)
 	    CN23XX_SLI_MAC_PF_INT_ENB64(oct->pcie_port, oct->pf_num);
 }
 
+static u32 lower_pow(u32 num)
+{
+	u32 n = num > 0 ? num - 1 : 0;
+
+	n |= n >> 1;
+	n |= n >> 2;
+	n |= n >> 4;
+	n |= n >> 8;
+	n |= n >> 16;
+	n++;
+
+	return ((n > num) ? (n >> 1) : n);
+}
+
 static int cn23xx_sriov_config(struct octeon_device *oct)
 {
 	u32 total_rings;
 	struct octeon_cn23xx_pf *cn23xx = (struct octeon_cn23xx_pf *)oct->chip;
 	/* num_vfs is already filled for us */
+	u32 num_vfs = oct->sriov_info.num_vfs;
+	u32 rings_per_vf, max_vfs;
 	u32 pf_srn, num_pf_rings;
 
 	cn23xx->conf =
@@ -1058,40 +1094,150 @@ static int cn23xx_sriov_config(struct octeon_device *oct)
 	switch (oct->rev_id) {
 	case OCTEON_CN23XX_REV_1_0:
 		total_rings = CN23XX_MAX_RINGS_PER_PF_PASS_1_0;
+		max_vfs = CN23XX_MAX_VFS_PER_PF_PASS_1_0;
 		break;
 	case OCTEON_CN23XX_REV_1_1:
 		total_rings = CN23XX_MAX_RINGS_PER_PF_PASS_1_1;
+		max_vfs = CN23XX_MAX_VFS_PER_PF_PASS_1_1;
 		break;
 	default:
 		total_rings = CN23XX_MAX_RINGS_PER_PF;
+		max_vfs = CN23XX_MAX_VFS_PER_PF;
 		break;
 	}
-	if (!oct->sriov_info.num_pf_rings) {
-		if (total_rings > num_present_cpus())
-			num_pf_rings = num_present_cpus();
-		else
-			num_pf_rings = total_rings;
+
+	if (num_vfs > min((total_rings - 1), max_vfs)) {
+		dev_warn(&oct->pci_dev->dev, "num_vfs requested %u is more than available rings. Reducing to %u\n",
+			 num_vfs, min((total_rings - 1), max_vfs));
+		num_vfs = min((total_rings - 1), max_vfs);
+	}
+
+	if (!num_vfs) {
+		pr_devel("num_vfs is zero, SRIOV is not enabled...\n");
+
+		if (oct->sriov_info.rings_per_vf > 0)
+			dev_warn(&oct->pci_dev->dev, "num_queues_per_vf is ignored because num_vfs=0.\n");
+
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
+		total_rings = num_pf_rings;
+
 	} else {
-		num_pf_rings = oct->sriov_info.num_pf_rings;
+		if (!oct->sriov_info.rings_per_vf) {
+			if (oct->sriov_info.num_pf_rings > 0) {
+				num_pf_rings = oct->sriov_info.num_pf_rings;
+				if (num_pf_rings > (total_rings - num_vfs)) {
+					num_pf_rings = total_rings - num_vfs;
+					dev_warn(&oct->pci_dev->dev,
+						 "num_queues_per_pf requested %u is more than available rings. Reducing to %u\n",
+						 oct->sriov_info.num_pf_rings,
+						 num_pf_rings);
+				}
+				rings_per_vf = lower_pow(
+						(total_rings - num_pf_rings) /
+						num_vfs);
+				rings_per_vf = min_t(u32, rings_per_vf,
+						     CN23XX_MAX_RINGS_PER_VF);
+			} else {
+				if ((oct->rev_id == OCTEON_CN23XX_REV_1_0) &&
+				    (num_vfs >= LIOLUT_RING_DISTRIBUTION)) {
+					rings_per_vf = 1;
+					total_rings = num_vfs + 1;
+				} else if (oct->rev_id ==
+					   OCTEON_CN23XX_REV_1_0) {
+					rings_per_vf =
+						liolut_num_vfs_to_rings_per_vf
+						[num_vfs];
+				} else {
+					rings_per_vf = lower_pow(total_rings /
+								 (num_vfs + 1));
+				}
+				rings_per_vf = min_t(u32, rings_per_vf,
+						     CN23XX_MAX_RINGS_PER_VF);
+				num_pf_rings = total_rings -
+					(rings_per_vf * num_vfs);
+
+				if (num_pf_rings > num_present_cpus()) {
+					num_pf_rings = num_present_cpus();
+					total_rings = num_pf_rings +
+						rings_per_vf * num_vfs;
+				}
+			}
+		} else {
+			u32 i;
+
+			i = lower_pow((total_rings - 1) / num_vfs);
+
+			if (oct->sriov_info.rings_per_vf >
+			    min_t(u32, i, CN23XX_MAX_RINGS_PER_VF)) {
+				rings_per_vf = min_t(u32, i,
+						     CN23XX_MAX_RINGS_PER_VF);
+				dev_warn(&oct->pci_dev->dev,
+					 "num_queues_per_vf requested %u is more than available rings. Reducing to %u\n",
+					 oct->sriov_info.rings_per_vf,
+					 rings_per_vf);
+			} else {
+				rings_per_vf = lower_pow(
+						oct->sriov_info.rings_per_vf);
+
+				if (rings_per_vf !=
+				    oct->sriov_info.rings_per_vf) {
+					dev_warn(&oct->pci_dev->dev,
+						 "num_queues_per_vf requested %u is not power of two. Reducing to %u\n",
+						 oct->sriov_info.rings_per_vf,
+						 rings_per_vf);
+				}
+			}
 
-		if (num_pf_rings > total_rings) {
-			dev_warn(&oct->pci_dev->dev,
-				 "num_queues_per_pf requested %u is more than available rings. Reducing to %u\n",
-				 num_pf_rings, total_rings);
-			num_pf_rings = total_rings;
+			if (!oct->sriov_info.num_pf_rings) {
+				num_pf_rings = total_rings -
+					(rings_per_vf * num_vfs);
+			} else {
+				num_pf_rings = oct->sriov_info.num_pf_rings;
+
+				if ((num_pf_rings + (num_vfs * rings_per_vf)) >
+				    total_rings) {
+					num_pf_rings = total_rings -
+						(rings_per_vf * num_vfs);
+					dev_warn(&oct->pci_dev->dev,
+						 "num_queues_per_pf requested %u is more than available rings. Reducing to %u\n",
+						 oct->sriov_info.num_pf_rings,
+						 num_pf_rings);
+				}
+			}
 		}
 	}
 
-	total_rings = num_pf_rings;
+	total_rings = num_pf_rings + (num_vfs * rings_per_vf);
+
 	/* the first ring of the pf */
 	pf_srn = total_rings - num_pf_rings;
 
 	oct->sriov_info.trs = total_rings;
+	oct->sriov_info.num_vfs = num_vfs;
+	oct->sriov_info.rings_per_vf = rings_per_vf;
 	oct->sriov_info.pf_srn = pf_srn;
 	oct->sriov_info.num_pf_rings = num_pf_rings;
-	dev_dbg(&oct->pci_dev->dev, "trs:%d pf_srn:%d num_pf_rings:%d\n",
-		oct->sriov_info.trs, oct->sriov_info.pf_srn,
-		oct->sriov_info.num_pf_rings);
+	pr_devel("trs:%d num_vfs:%d rings_per_vf:%d pf_srn:%d num_pf_rings:%d\n",
+		 oct->sriov_info.trs, oct->sriov_info.num_vfs,
+		 oct->sriov_info.rings_per_vf, oct->sriov_info.pf_srn,
+		 oct->sriov_info.num_pf_rings);
 	return 0;
 }
 
@@ -1187,45 +1333,45 @@ void cn23xx_dump_iq_regs(struct octeon_device *oct)
 {
 	u32 regval, q_no;
 
-	dev_dbg(&oct->pci_dev->dev, "SLI_IQ_DOORBELL_0 [0x%x]: 0x%016llx\n",
-		CN23XX_SLI_IQ_DOORBELL(0),
-		CVM_CAST64(octeon_read_csr64
-			(oct, CN23XX_SLI_IQ_DOORBELL(0))));
+	pr_devel("SLI_IQ_DOORBELL_0 [0x%x]: 0x%016llx\n",
+		 CN23XX_SLI_IQ_DOORBELL(0),
+		 CVM_CAST64(octeon_read_csr64
+			 (oct, CN23XX_SLI_IQ_DOORBELL(0))));
 
-	dev_dbg(&oct->pci_dev->dev, "SLI_IQ_BASEADDR_0 [0x%x]: 0x%016llx\n",
-		CN23XX_SLI_IQ_BASE_ADDR64(0),
-		CVM_CAST64(octeon_read_csr64
-			(oct, CN23XX_SLI_IQ_BASE_ADDR64(0))));
+	pr_devel("SLI_IQ_BASEADDR_0 [0x%x]: 0x%016llx\n",
+		 CN23XX_SLI_IQ_BASE_ADDR64(0),
+		 CVM_CAST64(octeon_read_csr64
+			 (oct, CN23XX_SLI_IQ_BASE_ADDR64(0))));
 
-	dev_dbg(&oct->pci_dev->dev, "SLI_IQ_FIFO_RSIZE_0 [0x%x]: 0x%016llx\n",
-		CN23XX_SLI_IQ_SIZE(0),
-		CVM_CAST64(octeon_read_csr64(oct, CN23XX_SLI_IQ_SIZE(0))));
+	pr_devel("SLI_IQ_FIFO_RSIZE_0 [0x%x]: 0x%016llx\n",
+		 CN23XX_SLI_IQ_SIZE(0),
+		 CVM_CAST64(octeon_read_csr64(oct, CN23XX_SLI_IQ_SIZE(0))));
 
-	dev_dbg(&oct->pci_dev->dev, "SLI_CTL_STATUS [0x%x]: 0x%016llx\n",
-		CN23XX_SLI_CTL_STATUS,
-		CVM_CAST64(octeon_read_csr64(oct, CN23XX_SLI_CTL_STATUS)));
+	pr_devel("SLI_CTL_STATUS [0x%x]: 0x%016llx\n",
+		 CN23XX_SLI_CTL_STATUS,
+		 CVM_CAST64(octeon_read_csr64(oct, CN23XX_SLI_CTL_STATUS)));
 
 	for (q_no = 0; q_no < CN23XX_MAX_INPUT_QUEUES; q_no++) {
-		dev_dbg(&oct->pci_dev->dev, "SLI_PKT[%d]_INPUT_CTL [0x%x]: 0x%016llx\n",
-			q_no, CN23XX_SLI_IQ_PKT_CONTROL64(q_no),
-			CVM_CAST64(octeon_read_csr64
-				(oct,
-					CN23XX_SLI_IQ_PKT_CONTROL64(q_no))));
+		pr_devel("SLI_PKT[%d]_INPUT_CTL [0x%x]: 0x%016llx\n",
+			 q_no, CN23XX_SLI_IQ_PKT_CONTROL64(q_no),
+			 CVM_CAST64(octeon_read_csr64
+				 (oct,
+					 CN23XX_SLI_IQ_PKT_CONTROL64(q_no))));
 	}
 
 	pci_read_config_dword(oct->pci_dev, CN23XX_CONFIG_PCIE_DEVCTL, &regval);
-	dev_dbg(&oct->pci_dev->dev, "Config DevCtl [0x%x]: 0x%08x\n",
-		CN23XX_CONFIG_PCIE_DEVCTL, regval);
-
-	dev_dbg(&oct->pci_dev->dev, "SLI_PRT[%d]_CFG [0x%llx]: 0x%016llx\n",
-		oct->pcie_port, CN23XX_DPI_SLI_PRTX_CFG(oct->pcie_port),
-		CVM_CAST64(lio_pci_readq(
-			oct, CN23XX_DPI_SLI_PRTX_CFG(oct->pcie_port))));
-
-	dev_dbg(&oct->pci_dev->dev, "SLI_S2M_PORT[%d]_CTL [0x%x]: 0x%016llx\n",
-		oct->pcie_port, CN23XX_SLI_S2M_PORTX_CTL(oct->pcie_port),
-		CVM_CAST64(octeon_read_csr64(
-			oct, CN23XX_SLI_S2M_PORTX_CTL(oct->pcie_port))));
+	pr_devel("Config DevCtl [0x%x]: 0x%08x\n",
+		 CN23XX_CONFIG_PCIE_DEVCTL, regval);
+
+	pr_devel("SLI_PRT[%d]_CFG [0x%llx]: 0x%016llx\n",
+		 oct->pcie_port, CN23XX_DPI_SLI_PRTX_CFG(oct->pcie_port),
+		 CVM_CAST64(lio_pci_readq(
+			 oct, CN23XX_DPI_SLI_PRTX_CFG(oct->pcie_port))));
+
+	pr_devel("SLI_S2M_PORT[%d]_CTL [0x%x]: 0x%016llx\n",
+		 oct->pcie_port, CN23XX_SLI_S2M_PORTX_CTL(oct->pcie_port),
+		 CVM_CAST64(octeon_read_csr64(
+			 oct, CN23XX_SLI_S2M_PORTX_CTL(oct->pcie_port))));
 }
 
 int cn23xx_fw_loaded(struct octeon_device *oct)
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
index e779af8..9fb788d 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
@@ -19,6 +19,7 @@
 * This file may also be available under a different license from Cavium.
 * Contact Cavium, Inc. for more information
 **********************************************************************/
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include "liquidio_common.h"
@@ -34,7 +35,7 @@ int lio_cn6xxx_soft_reset(struct octeon_device *oct)
 {
 	octeon_write_csr64(oct, CN6XXX_WIN_WR_MASK_REG, 0xFF);
 
-	dev_dbg(&oct->pci_dev->dev, "BIST enabled for soft reset\n");
+	pr_devel("BIST enabled for soft reset\n");
 
 	lio_pci_writeq(oct, 1, CN6XXX_CIU_SOFT_BIST);
 	octeon_write_csr64(oct, CN6XXX_SLI_SCRATCH1, 0x1234ULL);
@@ -53,7 +54,7 @@ int lio_cn6xxx_soft_reset(struct octeon_device *oct)
 		return 1;
 	}
 
-	dev_dbg(&oct->pci_dev->dev, "Reset completed\n");
+	pr_devel("Reset completed\n");
 	octeon_write_csr64(oct, CN6XXX_WIN_WR_MASK_REG, 0xFF);
 
 	return 0;
@@ -71,7 +72,7 @@ void lio_cn6xxx_enable_error_reporting(struct octeon_device *oct)
 
 	val |= 0xf;          /* Enable Link error reporting */
 
-	dev_dbg(&oct->pci_dev->dev, "Enabling PCI-E error reporting..\n");
+	pr_devel("Enabling PCI-E error reporting..\n");
 	pci_write_config_dword(oct->pci_dev, CN6XXX_PCIE_DEVCTL, val);
 }
 
@@ -289,8 +290,8 @@ void lio_cn6xxx_setup_iq_regs(struct octeon_device *oct, u32 iq_no)
 	iq->doorbell_reg = oct->mmio[0].hw_addr + CN6XXX_SLI_IQ_DOORBELL(iq_no);
 	iq->inst_cnt_reg = oct->mmio[0].hw_addr
 			   + CN6XXX_SLI_IQ_INSTR_COUNT(iq_no);
-	dev_dbg(&oct->pci_dev->dev, "InstQ[%d]:dbell reg @ 0x%p instcnt_reg @ 0x%p\n",
-		iq_no, iq->doorbell_reg, iq->inst_cnt_reg);
+	pr_devel("InstQ[%d]:dbell reg @ 0x%p instcnt_reg @ 0x%p\n",
+		 iq_no, iq->doorbell_reg, iq->inst_cnt_reg);
 
 	/* Store the current instruction counter
 	 * (used in flush_iq calculation)
@@ -508,7 +509,7 @@ static void lio_cn6xxx_get_pcie_qlmport(struct octeon_device *oct)
 	 */
 	oct->pcie_port = octeon_read_csr(oct, CN6XXX_SLI_MAC_NUMBER) & 0xff;
 
-	dev_dbg(&oct->pci_dev->dev, "Using PCIE Port %d\n", oct->pcie_port);
+	pr_devel("Using PCIE Port %d\n", oct->pcie_port);
 }
 
 static void
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
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 586b688..03a4eac 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -19,6 +19,7 @@
 * This file may also be available under a different license from Cavium.
 * Contact Cavium, Inc. for more information
 **********************************************************************/
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/vmalloc.h>
@@ -1028,8 +1029,7 @@ octeon_register_dispatch_fn(struct octeon_device *oct,
 	if (!pfn) {
 		struct octeon_dispatch *dispatch;
 
-		dev_dbg(&oct->pci_dev->dev,
-			"Adding opcode to dispatch list linked list\n");
+		pr_devel("Adding opcode to dispatch list linked list\n");
 		dispatch = (struct octeon_dispatch *)
 			   vmalloc(sizeof(struct octeon_dispatch));
 		if (!dispatch) {
@@ -1113,9 +1113,9 @@ int octeon_core_drv_init(struct octeon_recv_info *recv_info, void *buf)
 	cs = &core_setup[oct->octeon_id];
 
 	if (recv_pkt->buffer_size[0] != sizeof(*cs)) {
-		dev_dbg(&oct->pci_dev->dev, "Core setup bytes expected %u found %d\n",
-			(u32)sizeof(*cs),
-			recv_pkt->buffer_size[0]);
+		pr_devel("Core setup bytes expected %u found %d\n",
+			 (u32)sizeof(*cs),
+			 recv_pkt->buffer_size[0]);
 	}
 
 	memcpy(cs, get_rbd(recv_pkt->buffer_ptr[0]), sizeof(*cs));
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index da15c2a..89381ba 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -322,11 +322,18 @@ struct octeon_pf_vf_hs_word {
 };
 
 struct octeon_sriov_info {
+	/* Number of rings assigned to VF */
+	u32	rings_per_vf;
+
+	/* Number of VF devices enabled */
+	u32	num_vfs;
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
