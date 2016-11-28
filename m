From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 4/9] liquidio CN23XX: VF queue setup
Date: Mon, 28 Nov 2016 00:50:33 -0800
Message-ID: <1480323038-13702-5-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1480323038-13702-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-sn1nam02on0082.outbound.protection.outlook.com ([104.47.36.82]:36608
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754109AbcK1JFa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 04:05:30 -0500
In-Reply-To: <1480323038-13702-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for configuring VF input/output queues.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_vf_device.c    | 144 +++++++++++++++++++++
 .../ethernet/cavium/liquidio/cn23xx_vf_device.h    |   2 +
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |   6 +-
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c |   5 +
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  43 +++++-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   7 +-
 .../net/ethernet/cavium/liquidio/request_manager.c |   4 +-
 7 files changed, 207 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
index d683bda..60fd138 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
@@ -25,13 +25,134 @@
 #include "cn23xx_vf_device.h"
 #include "octeon_main.h"
 
+static int cn23xx_vf_reset_io_queues(struct octeon_device *oct, u32 num_queues)
+{
+	u32 loop = BUSY_READING_REG_VF_LOOP_COUNT;
+	int ret_val = 0;
+	u32 q_no;
+	u64 d64;
+
+	for (q_no = 0; q_no < num_queues; q_no++) {
+		/* set RST bit to 1. This bit applies to both IQ and OQ */
+		d64 = octeon_read_csr64(oct,
+					CN23XX_VF_SLI_IQ_PKT_CONTROL64(q_no));
+		d64 |= CN23XX_PKT_INPUT_CTL_RST;
+		octeon_write_csr64(oct, CN23XX_VF_SLI_IQ_PKT_CONTROL64(q_no),
+				   d64);
+	}
+
+	/* wait until the RST bit is clear or the RST and QUIET bits are set */
+	for (q_no = 0; q_no < num_queues; q_no++) {
+		u64 reg_val = octeon_read_csr64(oct,
+					CN23XX_VF_SLI_IQ_PKT_CONTROL64(q_no));
+		while ((READ_ONCE(reg_val) & CN23XX_PKT_INPUT_CTL_RST) &&
+		       !(READ_ONCE(reg_val) & CN23XX_PKT_INPUT_CTL_QUIET) &&
+		       loop) {
+			WRITE_ONCE(reg_val, octeon_read_csr64(
+			    oct, CN23XX_VF_SLI_IQ_PKT_CONTROL64(q_no)));
+			loop--;
+		}
+		if (!loop) {
+			dev_err(&oct->pci_dev->dev,
+				"clearing the reset reg failed or setting the quiet reg failed for qno: %u\n",
+				q_no);
+			return -1;
+		}
+		WRITE_ONCE(reg_val, READ_ONCE(reg_val) &
+			   ~CN23XX_PKT_INPUT_CTL_RST);
+		octeon_write_csr64(oct, CN23XX_VF_SLI_IQ_PKT_CONTROL64(q_no),
+				   READ_ONCE(reg_val));
+
+		WRITE_ONCE(reg_val, octeon_read_csr64(
+		    oct, CN23XX_VF_SLI_IQ_PKT_CONTROL64(q_no)));
+		if (READ_ONCE(reg_val) & CN23XX_PKT_INPUT_CTL_RST) {
+			dev_err(&oct->pci_dev->dev,
+				"clearing the reset failed for qno: %u\n",
+				q_no);
+			ret_val = -1;
+		}
+	}
+
+	return ret_val;
+}
+
+static int cn23xx_enable_vf_io_queues(struct octeon_device *oct)
+{
+	u32 q_no;
+
+	for (q_no = 0; q_no < oct->num_iqs; q_no++) {
+		u64 reg_val;
+
+		/* set the corresponding IQ IS_64B bit */
+		if (oct->io_qmask.iq64B & BIT_ULL(q_no)) {
+			reg_val = octeon_read_csr64(
+			    oct, CN23XX_VF_SLI_IQ_PKT_CONTROL64(q_no));
+			reg_val |= CN23XX_PKT_INPUT_CTL_IS_64B;
+			octeon_write_csr64(
+			    oct, CN23XX_VF_SLI_IQ_PKT_CONTROL64(q_no), reg_val);
+		}
+
+		/* set the corresponding IQ ENB bit */
+		if (oct->io_qmask.iq & BIT_ULL(q_no)) {
+			reg_val = octeon_read_csr64(
+			    oct, CN23XX_VF_SLI_IQ_PKT_CONTROL64(q_no));
+			reg_val |= CN23XX_PKT_INPUT_CTL_RING_ENB;
+			octeon_write_csr64(
+			    oct, CN23XX_VF_SLI_IQ_PKT_CONTROL64(q_no), reg_val);
+		}
+	}
+	for (q_no = 0; q_no < oct->num_oqs; q_no++) {
+		u32 reg_val;
+
+		/* set the corresponding OQ ENB bit */
+		if (oct->io_qmask.oq & BIT_ULL(q_no)) {
+			reg_val = octeon_read_csr(
+			    oct, CN23XX_VF_SLI_OQ_PKT_CONTROL(q_no));
+			reg_val |= CN23XX_PKT_OUTPUT_CTL_RING_ENB;
+			octeon_write_csr(
+			    oct, CN23XX_VF_SLI_OQ_PKT_CONTROL(q_no), reg_val);
+		}
+	}
+
+	return 0;
+}
+
+static void cn23xx_disable_vf_io_queues(struct octeon_device *oct)
+{
+	u32 num_queues = oct->num_iqs;
+
+	/* per HRM, rings can only be disabled via reset operation,
+	 * NOT via SLI_PKT()_INPUT/OUTPUT_CONTROL[ENB]
+	 */
+	if (num_queues < oct->num_oqs)
+		num_queues = oct->num_oqs;
+
+	cn23xx_vf_reset_io_queues(oct, num_queues);
+}
+
 int cn23xx_setup_octeon_vf_device(struct octeon_device *oct)
 {
 	struct octeon_cn23xx_vf *cn23xx = (struct octeon_cn23xx_vf *)oct->chip;
+	u32 rings_per_vf, ring_flag;
+	u64 reg_val;
 
 	if (octeon_map_pci_barx(oct, 0, 0))
 		return 1;
 
+	/* INPUT_CONTROL[RPVF] gives the VF IOq count */
+	reg_val = octeon_read_csr64(oct, CN23XX_VF_SLI_IQ_PKT_CONTROL64(0));
+
+	oct->pf_num = (reg_val >> CN23XX_PKT_INPUT_CTL_PF_NUM_POS) &
+		      CN23XX_PKT_INPUT_CTL_PF_NUM_MASK;
+	oct->vf_num = (reg_val >> CN23XX_PKT_INPUT_CTL_VF_NUM_POS) &
+		      CN23XX_PKT_INPUT_CTL_VF_NUM_MASK;
+
+	reg_val = reg_val >> CN23XX_PKT_INPUT_CTL_RPVF_POS;
+
+	rings_per_vf = reg_val & CN23XX_PKT_INPUT_CTL_RPVF_MASK;
+
+	ring_flag = 0;
+
 	cn23xx->conf  = oct_get_config_info(oct, LIO_23XX);
 	if (!cn23xx->conf) {
 		dev_err(&oct->pci_dev->dev, "%s No Config found for CN23XX\n",
@@ -40,5 +161,28 @@ int cn23xx_setup_octeon_vf_device(struct octeon_device *oct)
 		return 1;
 	}
 
+	if (oct->sriov_info.rings_per_vf > rings_per_vf) {
+		dev_warn(&oct->pci_dev->dev,
+			 "num_queues:%d greater than PF configured rings_per_vf:%d. Reducing to %d.\n",
+			 oct->sriov_info.rings_per_vf, rings_per_vf,
+			 rings_per_vf);
+		oct->sriov_info.rings_per_vf = rings_per_vf;
+	} else {
+		if (rings_per_vf > num_present_cpus()) {
+			dev_warn(&oct->pci_dev->dev,
+				 "PF configured rings_per_vf:%d greater than num_cpu:%d. Using rings_per_vf:%d equal to num cpus\n",
+				 rings_per_vf,
+				 num_present_cpus(),
+				 num_present_cpus());
+			oct->sriov_info.rings_per_vf =
+				num_present_cpus();
+		} else {
+			oct->sriov_info.rings_per_vf = rings_per_vf;
+		}
+	}
+
+	oct->fn_list.enable_io_queues = cn23xx_enable_vf_io_queues;
+	oct->fn_list.disable_io_queues = cn23xx_disable_vf_io_queues;
+
 	return 0;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
index 9e4fb50..6785796 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
@@ -32,5 +32,7 @@ struct octeon_cn23xx_vf {
 	struct octeon_config *conf;
 };
 
+#define BUSY_READING_REG_VF_LOOP_COUNT		10000
+
 int cn23xx_setup_octeon_vf_device(struct octeon_device *oct);
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 3d05b2f..39a9665 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -40,6 +40,7 @@
 MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_210SV_NAME LIO_FW_NAME_SUFFIX);
 MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_210NV_NAME LIO_FW_NAME_SUFFIX);
 MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_410NV_NAME LIO_FW_NAME_SUFFIX);
+MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_23XX_NAME LIO_FW_NAME_SUFFIX);
 
 static int ddr_timeout = 10000;
 module_param(ddr_timeout, int, 0644);
@@ -4484,7 +4485,10 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 	atomic_set(&octeon_dev->status, OCT_DEV_DISPATCH_INIT_DONE);
 
-	octeon_set_io_queues_off(octeon_dev);
+	if (octeon_set_io_queues_off(octeon_dev)) {
+		dev_err(&octeon_dev->pci_dev->dev, "setting io queues off failed\n");
+		return 1;
+	}
 
 	if (OCTEON_CN23XX_PF(octeon_dev)) {
 		ret = octeon_dev->fn_list.setup_device_regs(octeon_dev);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index dd1dad1..41fc9d2 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -236,6 +236,11 @@ static int octeon_device_init(struct octeon_device *oct)
 
 	atomic_set(&oct->status, OCT_DEV_PCI_MAP_DONE);
 
+	if (octeon_set_io_queues_off(oct)) {
+		dev_err(&oct->pci_dev->dev, "setting io queues off failed\n");
+		return 1;
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 7e6c8b8..fe84e90 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -860,12 +860,53 @@ int octeon_setup_output_queues(struct octeon_device *oct)
 	return 0;
 }
 
-void octeon_set_io_queues_off(struct octeon_device *oct)
+int octeon_set_io_queues_off(struct octeon_device *oct)
 {
+	int loop = BUSY_READING_REG_VF_LOOP_COUNT;
+
 	if (OCTEON_CN6XXX(oct)) {
 		octeon_write_csr(oct, CN6XXX_SLI_PKT_INSTR_ENB, 0);
 		octeon_write_csr(oct, CN6XXX_SLI_PKT_OUT_ENB, 0);
+	} else if (oct->chip_id == OCTEON_CN23XX_VF_VID) {
+		u32 q_no;
+
+		/* IOQs will already be in reset.
+		 * If RST bit is set, wait for quiet bit to be set.
+		 * Once quiet bit is set, clear the RST bit.
+		 */
+		for (q_no = 0; q_no < oct->sriov_info.rings_per_vf; q_no++) {
+			u64 reg_val = octeon_read_csr64(
+				oct, CN23XX_VF_SLI_IQ_PKT_CONTROL64(q_no));
+
+			while ((reg_val & CN23XX_PKT_INPUT_CTL_RST) &&
+			       !(reg_val &  CN23XX_PKT_INPUT_CTL_QUIET) &&
+			       loop) {
+				reg_val = octeon_read_csr64(
+					oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no));
+				loop--;
+			}
+			if (!loop) {
+				dev_err(&oct->pci_dev->dev,
+					"clearing the reset reg failed or setting the quiet reg failed for qno: %u\n",
+					q_no);
+				return -1;
+			}
+
+			reg_val = reg_val & ~CN23XX_PKT_INPUT_CTL_RST;
+			octeon_write_csr64(oct,
+					   CN23XX_SLI_IQ_PKT_CONTROL64(q_no),
+					   reg_val);
+
+			reg_val = octeon_read_csr64(
+					oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no));
+			if (reg_val & CN23XX_PKT_INPUT_CTL_RST) {
+				dev_err(&oct->pci_dev->dev,
+					"unable to reset qno %u\n", q_no);
+				return -1;
+			}
+		}
 	}
+	return 0;
 }
 
 void octeon_set_droq_pkt_op(struct octeon_device *oct,
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 5ce2048..1e6bfa1 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -401,8 +401,13 @@ struct octeon_device {
 
 	/** Octeon Chip type. */
 	u16 chip_id;
+
 	u16 rev_id;
+
 	u16 pf_num;
+
+	u16 vf_num;
+
 	/** This device's id - set by the driver. */
 	u32 octeon_id;
 
@@ -766,7 +771,7 @@ int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 /** Turns off the input and output queues for the device
  *  @param oct which octeon to disable
  */
-void octeon_set_io_queues_off(struct octeon_device *oct);
+int octeon_set_io_queues_off(struct octeon_device *oct);
 
 /** Turns on or off the given output queue for the device
  *  @param oct which octeon to change
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 8531a00..0e10e2a 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -235,7 +235,9 @@ int octeon_setup_iq(struct octeon_device *oct,
 	}
 
 	oct->num_iqs++;
-	oct->fn_list.enable_io_queues(oct);
+	if (oct->fn_list.enable_io_queues(oct))
+		return 1;
+
 	return 0;
 }
 
-- 
1.8.3.1
