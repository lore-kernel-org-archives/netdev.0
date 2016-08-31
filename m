From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V4 08/10] liquidio: CN23XX queue manipulation
Date: Wed, 31 Aug 2016 11:03:27 -0700
Message-ID: <1472666609-19503-9-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1472666609-19503-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-by2nam01on0076.outbound.protection.outlook.com ([104.47.34.76]:42304
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932635AbcHaSS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 Aug 2016 14:18:58 -0400
In-Reply-To: <1472666609-19503-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for cn23xx queue manipulation.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 213 +++++++++++++++++++++
 .../net/ethernet/cavium/liquidio/cn66xx_device.c   |   4 +-
 .../net/ethernet/cavium/liquidio/cn66xx_device.h   |   2 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  12 +-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   2 +-
 5 files changed, 225 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index d614b0a..7e932a3 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -311,6 +311,61 @@ static void cn23xx_setup_global_mac_regs(struct octeon_device *oct)
 		(oct, CN23XX_SLI_PKT_MAC_RINFO64(mac_no, pf_num)));
 }
 
+static int cn23xx_reset_io_queues(struct octeon_device *oct)
+{
+	int ret_val = 0;
+	u64 d64;
+	u32 q_no, srn, ern;
+	u32 loop = 1000;
+
+	srn = oct->sriov_info.pf_srn;
+	ern = srn + oct->sriov_info.num_pf_rings;
+
+	/*As per HRM reg description, s/w cant write 0 to ENB. */
+	/*to make the queue off, need to set the RST bit. */
+
+	/* Reset the Enable bit for all the 64 IQs.  */
+	for (q_no = srn; q_no < ern; q_no++) {
+		/* set RST bit to 1. This bit applies to both IQ and OQ */
+		d64 = octeon_read_csr64(oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no));
+		d64 = d64 | CN23XX_PKT_INPUT_CTL_RST;
+		octeon_write_csr64(oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no), d64);
+	}
+
+	/*wait until the RST bit is clear or the RST and quite bits are set*/
+	for (q_no = srn; q_no < ern; q_no++) {
+		u64 reg_val = octeon_read_csr64(oct,
+					CN23XX_SLI_IQ_PKT_CONTROL64(q_no));
+		while ((READ_ONCE(reg_val) & CN23XX_PKT_INPUT_CTL_RST) &&
+		       !(READ_ONCE(reg_val) & CN23XX_PKT_INPUT_CTL_QUIET) &&
+		       loop--) {
+			WRITE_ONCE(reg_val, octeon_read_csr64(
+			    oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no)));
+		}
+		if (!loop) {
+			dev_err(&oct->pci_dev->dev,
+				"clearing the reset reg failed or setting the quiet reg failed for qno: %u\n",
+				q_no);
+			return -1;
+		}
+		WRITE_ONCE(reg_val, READ_ONCE(reg_val) &
+			~CN23XX_PKT_INPUT_CTL_RST);
+		octeon_write_csr64(oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no),
+				   READ_ONCE(reg_val));
+
+		WRITE_ONCE(reg_val, octeon_read_csr64(
+			   oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no)));
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
 static int cn23xx_pf_setup_global_input_regs(struct octeon_device *oct)
 {
 	u32 q_no, ern, srn;
@@ -324,6 +379,9 @@ static int cn23xx_pf_setup_global_input_regs(struct octeon_device *oct)
 	srn = oct->sriov_info.pf_srn;
 	ern = srn + oct->sriov_info.num_pf_rings;
 
+	if (cn23xx_reset_io_queues(oct))
+		return -1;
+
 	/** Set the MAC_NUM and PVF_NUM in IQ_PKT_CONTROL reg
 	* for all queues.Only PF can set these bits.
 	* bits 29:30 indicate the MAC num.
@@ -552,6 +610,158 @@ static void cn23xx_setup_oq_regs(struct octeon_device *oct, u32 oq_no)
 			 reg_val);
 }
 
+static int cn23xx_enable_io_queues(struct octeon_device *oct)
+{
+	u64 reg_val;
+	u32 srn, ern, q_no;
+	u32 loop = 1000;
+
+	srn = oct->sriov_info.pf_srn;
+	ern = srn + oct->num_iqs;
+
+	for (q_no = srn; q_no < ern; q_no++) {
+		/* set the corresponding IQ IS_64B bit */
+		if (oct->io_qmask.iq64B & BIT_ULL(q_no - srn)) {
+			reg_val = octeon_read_csr64(
+			    oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no));
+			reg_val = reg_val | CN23XX_PKT_INPUT_CTL_IS_64B;
+			octeon_write_csr64(
+			    oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no), reg_val);
+		}
+
+		/* set the corresponding IQ ENB bit */
+		if (oct->io_qmask.iq & BIT_ULL(q_no - srn)) {
+			/* IOQs are in reset by default in PEM2 mode,
+			 * clearing reset bit
+			 */
+			reg_val = octeon_read_csr64(
+			    oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no));
+
+			if (reg_val & CN23XX_PKT_INPUT_CTL_RST) {
+				while ((reg_val & CN23XX_PKT_INPUT_CTL_RST) &&
+				       !(reg_val &
+					 CN23XX_PKT_INPUT_CTL_QUIET) &&
+				       loop--) {
+					reg_val = octeon_read_csr64(
+					    oct,
+					    CN23XX_SLI_IQ_PKT_CONTROL64(q_no));
+				}
+				if (!loop) {
+					dev_err(&oct->pci_dev->dev,
+						"clearing the reset reg failed or setting the quiet reg failed for qno: %u\n",
+						q_no);
+					return -1;
+				}
+				reg_val = reg_val & ~CN23XX_PKT_INPUT_CTL_RST;
+				octeon_write_csr64(
+				    oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no),
+				    reg_val);
+
+				reg_val = octeon_read_csr64(
+				    oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no));
+				if (reg_val & CN23XX_PKT_INPUT_CTL_RST) {
+					dev_err(&oct->pci_dev->dev,
+						"clearing the reset failed for qno: %u\n",
+						q_no);
+					return -1;
+				}
+			}
+			reg_val = octeon_read_csr64(
+			    oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no));
+			reg_val = reg_val | CN23XX_PKT_INPUT_CTL_RING_ENB;
+			octeon_write_csr64(
+			    oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no), reg_val);
+		}
+	}
+	for (q_no = srn; q_no < ern; q_no++) {
+		u32 reg_val;
+		/* set the corresponding OQ ENB bit */
+		if (oct->io_qmask.oq & BIT_ULL(q_no - srn)) {
+			reg_val = octeon_read_csr(
+			    oct, CN23XX_SLI_OQ_PKT_CONTROL(q_no));
+			reg_val = reg_val | CN23XX_PKT_OUTPUT_CTL_RING_ENB;
+			octeon_write_csr(oct, CN23XX_SLI_OQ_PKT_CONTROL(q_no),
+					 reg_val);
+		}
+	}
+	return 0;
+}
+
+static void cn23xx_disable_io_queues(struct octeon_device *oct)
+{
+	int q_no, loop;
+	u64 d64;
+	u32 d32;
+	u32 srn, ern;
+
+	srn = oct->sriov_info.pf_srn;
+	ern = srn + oct->num_iqs;
+
+	/*** Disable Input Queues. ***/
+	for (q_no = srn; q_no < ern; q_no++) {
+		loop = HZ;
+
+		/* start the Reset for a particular ring */
+		WRITE_ONCE(d64, octeon_read_csr64(
+			   oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no)));
+		WRITE_ONCE(d64, READ_ONCE(d64) &
+					(~(CN23XX_PKT_INPUT_CTL_RING_ENB)));
+		WRITE_ONCE(d64, READ_ONCE(d64) | CN23XX_PKT_INPUT_CTL_RST);
+		octeon_write_csr64(oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no),
+				   READ_ONCE(d64));
+
+		/* Wait until hardware indicates that the particular IQ
+		 * is out of reset.
+		 */
+		WRITE_ONCE(d64, octeon_read_csr64(
+					oct, CN23XX_SLI_PKT_IOQ_RING_RST));
+		while (!(READ_ONCE(d64) & BIT_ULL(q_no)) && loop--) {
+			WRITE_ONCE(d64, octeon_read_csr64(
+					oct, CN23XX_SLI_PKT_IOQ_RING_RST));
+			schedule_timeout_uninterruptible(1);
+		}
+
+		/* Reset the doorbell register for this Input Queue. */
+		octeon_write_csr(oct, CN23XX_SLI_IQ_DOORBELL(q_no), 0xFFFFFFFF);
+		while (octeon_read_csr64(oct, CN23XX_SLI_IQ_DOORBELL(q_no)) &&
+		       loop--) {
+			schedule_timeout_uninterruptible(1);
+		}
+	}
+
+	/*** Disable Output Queues. ***/
+	for (q_no = srn; q_no < ern; q_no++) {
+		loop = HZ;
+
+		/* Wait until hardware indicates that the particular IQ
+		 * is out of reset.It given that SLI_PKT_RING_RST is
+		 * common for both IQs and OQs
+		 */
+		WRITE_ONCE(d64, octeon_read_csr64(
+					oct, CN23XX_SLI_PKT_IOQ_RING_RST));
+		while (!(READ_ONCE(d64) & BIT_ULL(q_no)) && loop--) {
+			WRITE_ONCE(d64, octeon_read_csr64(
+					oct, CN23XX_SLI_PKT_IOQ_RING_RST));
+			schedule_timeout_uninterruptible(1);
+		}
+
+		/* Reset the doorbell register for this Output Queue. */
+		octeon_write_csr(oct, CN23XX_SLI_OQ_PKTS_CREDIT(q_no),
+				 0xFFFFFFFF);
+		while (octeon_read_csr64(oct,
+					 CN23XX_SLI_OQ_PKTS_CREDIT(q_no)) &&
+		       loop--) {
+			schedule_timeout_uninterruptible(1);
+		}
+
+		/* clear the SLI_PKT(0..63)_CNTS[CNT] reg value */
+		WRITE_ONCE(d32, octeon_read_csr(
+					oct, CN23XX_SLI_OQ_PKTS_SENT(q_no)));
+		octeon_write_csr(oct, CN23XX_SLI_OQ_PKTS_SENT(q_no),
+				 READ_ONCE(d32));
+	}
+}
+
 static void cn23xx_get_pcie_qlmport(struct octeon_device *oct)
 {
 	oct->pcie_port = (octeon_read_csr(oct, CN23XX_SLI_MAC_NUMBER)) & 0xff;
@@ -693,6 +903,9 @@ int setup_cn23xx_octeon_pf_device(struct octeon_device *oct)
 	oct->fn_list.setup_oq_regs = cn23xx_setup_oq_regs;
 	oct->fn_list.setup_device_regs = cn23xx_setup_pf_device_regs;
 
+	oct->fn_list.enable_io_queues = cn23xx_enable_io_queues;
+	oct->fn_list.disable_io_queues = cn23xx_disable_io_queues;
+
 	cn23xx_setup_reg_address(oct);
 
 	oct->coproc_clock_rate = 1000000ULL * cn23xx_coprocessor_clock(oct);
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
index dc5d14a..7ff7247 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
@@ -338,7 +338,7 @@ void lio_cn6xxx_setup_oq_regs(struct octeon_device *oct, u32 oq_no)
 	octeon_write_csr(oct, CN6XXX_SLI_PKT_CNT_INT_ENB, intr);
 }
 
-void lio_cn6xxx_enable_io_queues(struct octeon_device *oct)
+int lio_cn6xxx_enable_io_queues(struct octeon_device *oct)
 {
 	u32 mask;
 
@@ -353,6 +353,8 @@ void lio_cn6xxx_enable_io_queues(struct octeon_device *oct)
 	mask = octeon_read_csr(oct, CN6XXX_SLI_PKT_OUT_ENB);
 	mask |= oct->io_qmask.oq;
 	octeon_write_csr(oct, CN6XXX_SLI_PKT_OUT_ENB, mask);
+
+	return 0;
 }
 
 void lio_cn6xxx_disable_io_queues(struct octeon_device *oct)
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
index 2e4bc25..5286f9e 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
@@ -80,7 +80,7 @@ void lio_cn6xxx_setup_global_input_regs(struct octeon_device *oct);
 void lio_cn6xxx_setup_global_output_regs(struct octeon_device *oct);
 void lio_cn6xxx_setup_iq_regs(struct octeon_device *oct, u32 iq_no);
 void lio_cn6xxx_setup_oq_regs(struct octeon_device *oct, u32 oq_no);
-void lio_cn6xxx_enable_io_queues(struct octeon_device *oct);
+int lio_cn6xxx_enable_io_queues(struct octeon_device *oct);
 void lio_cn6xxx_disable_io_queues(struct octeon_device *oct);
 irqreturn_t lio_cn6xxx_process_interrupt_regs(void *dev);
 void lio_cn6xxx_bar1_idx_setup(struct octeon_device *oct, u64 core_addr,
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index a00bd6c..cb58381 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2094,10 +2094,8 @@ static inline int setup_io_queues(struct octeon_device *octeon_dev,
 
 		droq = octeon_dev->droq[q_no];
 		napi = &droq->napi;
-		dev_dbg(&octeon_dev->pci_dev->dev,
-			"netif_napi_add netdev:%llx oct:%llx\n",
-			(u64)netdev,
-			(u64)octeon_dev);
+		dev_dbg(&octeon_dev->pci_dev->dev, "netif_napi_add netdev:%llx oct:%llx pf_num:%d\n",
+			(u64)netdev, (u64)octeon_dev, octeon_dev->pf_num);
 		netif_napi_add(netdev, napi, liquidio_napi_poll, 64);
 
 		/* designate a CPU for this droq */
@@ -3766,7 +3764,11 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 	octeon_dev->fn_list.enable_interrupt(octeon_dev->chip);
 
 	/* Enable the input and output queues for this Octeon device */
-	octeon_dev->fn_list.enable_io_queues(octeon_dev);
+	ret = octeon_dev->fn_list.enable_io_queues(octeon_dev);
+	if (ret) {
+		dev_err(&octeon_dev->pci_dev->dev, "Failed to enable input/output queues");
+		return ret;
+	}
 
 	atomic_set(&octeon_dev->status, OCT_DEV_IO_QUEUES_DONE);
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index c120613..2439cc5 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -217,7 +217,7 @@ struct octeon_fn_list {
 	void (*enable_interrupt)(void *);
 	void (*disable_interrupt)(void *);
 
-	void (*enable_io_queues)(struct octeon_device *);
+	int (*enable_io_queues)(struct octeon_device *);
 	void (*disable_io_queues)(struct octeon_device *);
 };
 
-- 
1.8.3.1
