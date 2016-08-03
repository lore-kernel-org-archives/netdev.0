From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next  08/18] liquidio support for new device cn23xx
Date: Wed, 3 Aug 2016 11:55:39 -0700
Message-ID: <1470250549-10993-9-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1470250549-10993-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-bn3nam01on0065.outbound.protection.outlook.com ([104.47.33.65]:7087
	"EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932831AbcHCUbv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2016 16:31:51 -0400
In-Reply-To: <1470250549-10993-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for queue manipulation routines
for cn23xx.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 193 +++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |   6 +-
 2 files changed, 195 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index cecf608..67d350f 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -315,6 +315,52 @@ static void cn23xx_setup_global_mac_regs(struct octeon_device *oct)
 		(oct, CN23XX_SLI_PKT_MAC_RINFO64(mac_no, pf_num)));
 }
 
+static int cn23xx_reset_io_queues(struct octeon_device *oct)
+{
+	int ret_val = 0;
+	u64 d64 = 0ULL, q_no = 0ULL, srn = 0ULL, ern = 0ULL;
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
+		       !(READ_ONCE(reg_val) & CN23XX_PKT_INPUT_CTL_QUIET)) {
+			WRITE_ONCE(reg_val, octeon_read_csr64(
+			    oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no)));
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
+				"clearing the reset failed for qno: %llu\n",
+				q_no);
+			ret_val = -1;
+		}
+	}
+
+	return ret_val;
+}
+
 static void cn23xx_pf_setup_global_input_regs(struct octeon_device *oct)
 {
 	u64 q_no = 0ULL, ern, srn = 0ULL, pf_num = 0ULL;
@@ -327,6 +373,8 @@ static void cn23xx_pf_setup_global_input_regs(struct octeon_device *oct)
 	srn = oct->sriov_info.pf_srn;
 	ern = srn + oct->sriov_info.num_pf_rings;
 
+	cn23xx_reset_io_queues(oct);
+
 	/** Set the MAC_NUM and PVF_NUM in IQ_PKT_CONTROL reg
 	* for all queues.Only PF can set these bits.
 	* bits 29:30 indicate the MAC num.
@@ -552,6 +600,148 @@ static void cn23xx_setup_oq_regs(struct octeon_device *oct, u32 oq_no)
 			 reg_val);
 }
 
+static void cn23xx_enable_io_queues(struct octeon_device *oct)
+{
+	u64 q_no = 0, reg_val = 0ULL;
+	s32 srn = 0, ern = 0;
+
+	srn = oct->sriov_info.pf_srn;
+	ern = srn + oct->num_iqs;
+
+	for (q_no = srn; q_no < ern; q_no++) {
+		/* set the corresponding IQ IS_64B bit */
+		if (oct->io_qmask.iq64B & (1ULL << (q_no - srn))) {
+			reg_val = octeon_read_csr64(
+			    oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no));
+			reg_val = reg_val | CN23XX_PKT_INPUT_CTL_IS_64B;
+			octeon_write_csr64(
+			    oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no), reg_val);
+		}
+
+		/* set the corresponding IQ ENB bit */
+		if (oct->io_qmask.iq & (1ULL << (q_no - srn))) {
+			/* IOQs are in reset by default in PEM2 mode,
+			 * clearing reset bit
+			 */
+			reg_val = octeon_read_csr64(
+			    oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no));
+
+			if (reg_val & CN23XX_PKT_INPUT_CTL_RST) {
+				while (
+				    (reg_val & CN23XX_PKT_INPUT_CTL_RST) &&
+				    !(reg_val & CN23XX_PKT_INPUT_CTL_QUIET)) {
+					reg_val = octeon_read_csr64(
+					    oct,
+					    CN23XX_SLI_IQ_PKT_CONTROL64(q_no));
+				}
+				reg_val = reg_val & ~CN23XX_PKT_INPUT_CTL_RST;
+				octeon_write_csr64(
+				    oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no),
+				    reg_val);
+
+				reg_val = octeon_read_csr64(
+				    oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no));
+				if (reg_val & CN23XX_PKT_INPUT_CTL_RST) {
+					dev_err(&oct->pci_dev->dev, "clearing the reset failed for qno: %lld\n",
+						q_no);
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
+		if (oct->io_qmask.oq & (1ULL << (q_no - srn))) {
+			reg_val = octeon_read_csr(
+			    oct, CN23XX_SLI_OQ_PKT_CONTROL(q_no));
+			reg_val = reg_val | CN23XX_PKT_OUTPUT_CTL_RING_ENB;
+			octeon_write_csr(oct, CN23XX_SLI_OQ_PKT_CONTROL(q_no),
+					 reg_val);
+		}
+	}
+}
+
+static void cn23xx_disable_io_queues(struct octeon_device *oct)
+{
+	int q_no = 0, loop = HZ;
+	u64 d64 = 0ULL;
+	u32 d32 = 0ULL;
+	s32 srn = 0, ern = 0;
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
+		while (!(READ_ONCE(d64) & (0x1ULL << q_no)) && loop--) {
+			WRITE_ONCE(d64, octeon_read_csr64(
+					oct, CN23XX_SLI_PKT_IOQ_RING_RST));
+			schedule_timeout_uninterruptible(1);
+		}
+
+		/* Reset the doorbell register for this Input Queue. */
+		octeon_write_csr(oct, CN23XX_SLI_IQ_DOORBELL(q_no), 0xFFFFFFFF);
+		while (((octeon_read_csr64(
+			    oct, CN23XX_SLI_IQ_DOORBELL(q_no))) != 0ULL) &&
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
+		while (!(READ_ONCE(d64) & (0x1ULL << q_no)) && loop--) {
+			WRITE_ONCE(d64, octeon_read_csr64(
+					oct, CN23XX_SLI_PKT_IOQ_RING_RST));
+			schedule_timeout_uninterruptible(1);
+		}
+
+		/* Reset the doorbell register for this Output Queue. */
+		octeon_write_csr(oct, CN23XX_SLI_OQ_PKTS_CREDIT(q_no),
+				 0xFFFFFFFF);
+		while (((octeon_read_csr64(
+			    oct, CN23XX_SLI_OQ_PKTS_CREDIT(q_no))) != 0ULL) &&
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
 static void cn23xx_reinit_regs(struct octeon_device *oct)
 {
 	u32 i;
@@ -729,6 +919,9 @@ int setup_cn23xx_octeon_pf_device(struct octeon_device *oct)
 	oct->fn_list.setup_device_regs = cn23xx_setup_pf_device_regs;
 	oct->fn_list.reinit_regs = cn23xx_reinit_regs;
 
+	oct->fn_list.enable_io_queues = cn23xx_enable_io_queues;
+	oct->fn_list.disable_io_queues = cn23xx_disable_io_queues;
+
 	cn23xx_setup_reg_address(oct);
 
 	oct->coproc_clock_rate = 1000000ULL * cn23xx_coprocessor_clock(oct);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index b0a97d2..397ef1d 100644
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
-- 
1.8.3.1
