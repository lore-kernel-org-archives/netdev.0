From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 2/5] liquidio CN23XX: sriov enable
Date: Fri, 9 Sep 2016 13:08:24 -0700
Message-ID: <1473451707-26397-3-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-by2nam03on0050.outbound.protection.outlook.com ([104.47.42.50]:62176
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754596AbcIIUIw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 16:08:52 -0400
In-Reply-To: <1473451707-26397-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for enabling sriov on CN23XX cards.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 257 +++++++++++----------
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 147 ++++++++----
 .../net/ethernet/cavium/liquidio/octeon_config.h   |   3 +
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   5 +
 4 files changed, 241 insertions(+), 171 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index a2953d5..deec869 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -19,7 +19,7 @@
 * This file may also be available under a different license from Cavium.
 * Contact Cavium, Inc. for more information
 **********************************************************************/
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/vmalloc.h>
@@ -52,174 +52,174 @@ void cn23xx_dump_pf_initialized_regs(struct octeon_device *oct)
 	struct octeon_cn23xx_pf *cn23xx = (struct octeon_cn23xx_pf *)oct->chip;
 
 	/*In cn23xx_soft_reset*/
-	dev_dbg(&oct->pci_dev->dev, "%s[%llx] : 0x%llx\n",
-		"CN23XX_WIN_WR_MASK_REG", CVM_CAST64(CN23XX_WIN_WR_MASK_REG),
-		CVM_CAST64(octeon_read_csr64(oct, CN23XX_WIN_WR_MASK_REG)));
-	dev_dbg(&oct->pci_dev->dev, "%s[%llx] : 0x%016llx\n",
-		"CN23XX_SLI_SCRATCH1", CVM_CAST64(CN23XX_SLI_SCRATCH1),
-		CVM_CAST64(octeon_read_csr64(oct, CN23XX_SLI_SCRATCH1)));
-	dev_dbg(&oct->pci_dev->dev, "%s[%llx] : 0x%016llx\n",
-		"CN23XX_RST_SOFT_RST", CN23XX_RST_SOFT_RST,
-		lio_pci_readq(oct, CN23XX_RST_SOFT_RST));
+	pr_devel("%s[%llx] : 0x%llx\n",
+		 "CN23XX_WIN_WR_MASK_REG", CVM_CAST64(CN23XX_WIN_WR_MASK_REG),
+		 CVM_CAST64(octeon_read_csr64(oct, CN23XX_WIN_WR_MASK_REG)));
+	pr_devel("%s[%llx] : 0x%016llx\n",
+		 "CN23XX_SLI_SCRATCH1", CVM_CAST64(CN23XX_SLI_SCRATCH1),
+		 CVM_CAST64(octeon_read_csr64(oct, CN23XX_SLI_SCRATCH1)));
+	pr_devel("%s[%llx] : 0x%016llx\n",
+		 "CN23XX_RST_SOFT_RST", CN23XX_RST_SOFT_RST,
+		 lio_pci_readq(oct, CN23XX_RST_SOFT_RST));
 
 	/*In cn23xx_set_dpi_regs*/
-	dev_dbg(&oct->pci_dev->dev, "%s[%llx] : 0x%016llx\n",
-		"CN23XX_DPI_DMA_CONTROL", CN23XX_DPI_DMA_CONTROL,
-		lio_pci_readq(oct, CN23XX_DPI_DMA_CONTROL));
+	pr_devel("%s[%llx] : 0x%016llx\n",
+		 "CN23XX_DPI_DMA_CONTROL", CN23XX_DPI_DMA_CONTROL,
+		 lio_pci_readq(oct, CN23XX_DPI_DMA_CONTROL));
 
 	for (i = 0; i < 6; i++) {
-		dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-			"CN23XX_DPI_DMA_ENG_ENB", i,
-			CN23XX_DPI_DMA_ENG_ENB(i),
-			lio_pci_readq(oct, CN23XX_DPI_DMA_ENG_ENB(i)));
-		dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-			"CN23XX_DPI_DMA_ENG_BUF", i,
-			CN23XX_DPI_DMA_ENG_BUF(i),
-			lio_pci_readq(oct, CN23XX_DPI_DMA_ENG_BUF(i)));
+		pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+			 "CN23XX_DPI_DMA_ENG_ENB", i,
+			 CN23XX_DPI_DMA_ENG_ENB(i),
+			 lio_pci_readq(oct, CN23XX_DPI_DMA_ENG_ENB(i)));
+		pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+			 "CN23XX_DPI_DMA_ENG_BUF", i,
+			 CN23XX_DPI_DMA_ENG_BUF(i),
+			 lio_pci_readq(oct, CN23XX_DPI_DMA_ENG_BUF(i)));
 	}
 
-	dev_dbg(&oct->pci_dev->dev, "%s[%llx] : 0x%016llx\n", "CN23XX_DPI_CTL",
-		CN23XX_DPI_CTL, lio_pci_readq(oct, CN23XX_DPI_CTL));
+	pr_devel("%s[%llx] : 0x%016llx\n", "CN23XX_DPI_CTL",
+		 CN23XX_DPI_CTL, lio_pci_readq(oct, CN23XX_DPI_CTL));
 
 	/*In cn23xx_setup_pcie_mps and cn23xx_setup_pcie_mrrs */
 	pci_read_config_dword(oct->pci_dev, CN23XX_CONFIG_PCIE_DEVCTL, &regval);
-	dev_dbg(&oct->pci_dev->dev, "%s[%llx] : 0x%016llx\n",
-		"CN23XX_CONFIG_PCIE_DEVCTL",
-		CVM_CAST64(CN23XX_CONFIG_PCIE_DEVCTL), CVM_CAST64(regval));
+	pr_devel("%s[%llx] : 0x%016llx\n",
+		 "CN23XX_CONFIG_PCIE_DEVCTL",
+		 CVM_CAST64(CN23XX_CONFIG_PCIE_DEVCTL), CVM_CAST64(regval));
 
-	dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-		"CN23XX_DPI_SLI_PRTX_CFG", oct->pcie_port,
-		CN23XX_DPI_SLI_PRTX_CFG(oct->pcie_port),
-		lio_pci_readq(oct, CN23XX_DPI_SLI_PRTX_CFG(oct->pcie_port)));
+	pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+		 "CN23XX_DPI_SLI_PRTX_CFG", oct->pcie_port,
+		 CN23XX_DPI_SLI_PRTX_CFG(oct->pcie_port),
+		 lio_pci_readq(oct, CN23XX_DPI_SLI_PRTX_CFG(oct->pcie_port)));
 
 	/*In cn23xx_specific_regs_setup */
-	dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-		"CN23XX_SLI_S2M_PORTX_CTL", oct->pcie_port,
-		CVM_CAST64(CN23XX_SLI_S2M_PORTX_CTL(oct->pcie_port)),
-		CVM_CAST64(octeon_read_csr64(
-			oct, CN23XX_SLI_S2M_PORTX_CTL(oct->pcie_port))));
+	pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+		 "CN23XX_SLI_S2M_PORTX_CTL", oct->pcie_port,
+		 CVM_CAST64(CN23XX_SLI_S2M_PORTX_CTL(oct->pcie_port)),
+		 CVM_CAST64(octeon_read_csr64(
+			 oct, CN23XX_SLI_S2M_PORTX_CTL(oct->pcie_port))));
 
-	dev_dbg(&oct->pci_dev->dev, "%s[%llx] : 0x%016llx\n",
-		"CN23XX_SLI_RING_RST", CVM_CAST64(CN23XX_SLI_PKT_IOQ_RING_RST),
-		(u64)octeon_read_csr64(oct, CN23XX_SLI_PKT_IOQ_RING_RST));
+	pr_devel("%s[%llx] : 0x%016llx\n",
+		 "CN23XX_SLI_RING_RST", CVM_CAST64(CN23XX_SLI_PKT_IOQ_RING_RST),
+		 (u64)octeon_read_csr64(oct, CN23XX_SLI_PKT_IOQ_RING_RST));
 
 	/*In cn23xx_setup_global_mac_regs*/
 	for (i = 0; i < CN23XX_MAX_MACS; i++) {
-		dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-			"CN23XX_SLI_PKT_MAC_RINFO64", i,
-			CVM_CAST64(CN23XX_SLI_PKT_MAC_RINFO64(i, oct->pf_num)),
-			CVM_CAST64(octeon_read_csr64
-				(oct, CN23XX_SLI_PKT_MAC_RINFO64
-					(i, oct->pf_num))));
+		pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+			 "CN23XX_SLI_PKT_MAC_RINFO64", i,
+			 CVM_CAST64(CN23XX_SLI_PKT_MAC_RINFO64(i, oct->pf_num)),
+			 CVM_CAST64(octeon_read_csr64
+				 (oct, CN23XX_SLI_PKT_MAC_RINFO64
+					 (i, oct->pf_num))));
 	}
 
 	/*In cn23xx_setup_global_input_regs*/
 	for (i = 0; i < CN23XX_MAX_INPUT_QUEUES; i++) {
-		dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-			"CN23XX_SLI_IQ_PKT_CONTROL64", i,
-			CVM_CAST64(CN23XX_SLI_IQ_PKT_CONTROL64(i)),
-			CVM_CAST64(octeon_read_csr64
-				(oct, CN23XX_SLI_IQ_PKT_CONTROL64(i))));
+		pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+			 "CN23XX_SLI_IQ_PKT_CONTROL64", i,
+			 CVM_CAST64(CN23XX_SLI_IQ_PKT_CONTROL64(i)),
+			 CVM_CAST64(octeon_read_csr64
+				 (oct, CN23XX_SLI_IQ_PKT_CONTROL64(i))));
 	}
 
 	/*In cn23xx_setup_global_output_regs*/
-	dev_dbg(&oct->pci_dev->dev, "%s[%llx] : 0x%016llx\n",
-		"CN23XX_SLI_OQ_WMARK", CVM_CAST64(CN23XX_SLI_OQ_WMARK),
-		CVM_CAST64(octeon_read_csr64(oct, CN23XX_SLI_OQ_WMARK)));
+	pr_devel("%s[%llx] : 0x%016llx\n",
+		 "CN23XX_SLI_OQ_WMARK", CVM_CAST64(CN23XX_SLI_OQ_WMARK),
+		 CVM_CAST64(octeon_read_csr64(oct, CN23XX_SLI_OQ_WMARK)));
 
 	for (i = 0; i < CN23XX_MAX_OUTPUT_QUEUES; i++) {
-		dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-			"CN23XX_SLI_OQ_PKT_CONTROL", i,
-			CVM_CAST64(CN23XX_SLI_OQ_PKT_CONTROL(i)),
-			CVM_CAST64(octeon_read_csr(
-				oct, CN23XX_SLI_OQ_PKT_CONTROL(i))));
-		dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-			"CN23XX_SLI_OQ_PKT_INT_LEVELS", i,
-			CVM_CAST64(CN23XX_SLI_OQ_PKT_INT_LEVELS(i)),
-			CVM_CAST64(octeon_read_csr64(
-				oct, CN23XX_SLI_OQ_PKT_INT_LEVELS(i))));
+		pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+			 "CN23XX_SLI_OQ_PKT_CONTROL", i,
+			 CVM_CAST64(CN23XX_SLI_OQ_PKT_CONTROL(i)),
+			 CVM_CAST64(octeon_read_csr(
+				 oct, CN23XX_SLI_OQ_PKT_CONTROL(i))));
+		pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+			 "CN23XX_SLI_OQ_PKT_INT_LEVELS", i,
+			 CVM_CAST64(CN23XX_SLI_OQ_PKT_INT_LEVELS(i)),
+			 CVM_CAST64(octeon_read_csr64(
+				 oct, CN23XX_SLI_OQ_PKT_INT_LEVELS(i))));
 	}
 
 	/*In cn23xx_enable_interrupt and cn23xx_disable_interrupt*/
-	dev_dbg(&oct->pci_dev->dev, "%s[%llx] : 0x%016llx\n",
-		"cn23xx->intr_enb_reg64",
-		CVM_CAST64((long)(cn23xx->intr_enb_reg64)),
-		CVM_CAST64(readq(cn23xx->intr_enb_reg64)));
+	pr_devel("%s[%llx] : 0x%016llx\n",
+		 "cn23xx->intr_enb_reg64",
+		 CVM_CAST64((long)(cn23xx->intr_enb_reg64)),
+		 CVM_CAST64(readq(cn23xx->intr_enb_reg64)));
 
-	dev_dbg(&oct->pci_dev->dev, "%s[%llx] : 0x%016llx\n",
-		"cn23xx->intr_sum_reg64",
-		CVM_CAST64((long)(cn23xx->intr_sum_reg64)),
-		CVM_CAST64(readq(cn23xx->intr_sum_reg64)));
+	pr_devel("%s[%llx] : 0x%016llx\n",
+		 "cn23xx->intr_sum_reg64",
+		 CVM_CAST64((long)(cn23xx->intr_sum_reg64)),
+		 CVM_CAST64(readq(cn23xx->intr_sum_reg64)));
 
 	/*In cn23xx_setup_iq_regs*/
 	for (i = 0; i < CN23XX_MAX_INPUT_QUEUES; i++) {
-		dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-			"CN23XX_SLI_IQ_BASE_ADDR64", i,
-			CVM_CAST64(CN23XX_SLI_IQ_BASE_ADDR64(i)),
-			CVM_CAST64(octeon_read_csr64(
-				oct, CN23XX_SLI_IQ_BASE_ADDR64(i))));
-		dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-			"CN23XX_SLI_IQ_SIZE", i,
-			CVM_CAST64(CN23XX_SLI_IQ_SIZE(i)),
-			CVM_CAST64(octeon_read_csr
-				(oct, CN23XX_SLI_IQ_SIZE(i))));
-		dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-			"CN23XX_SLI_IQ_DOORBELL", i,
-			CVM_CAST64(CN23XX_SLI_IQ_DOORBELL(i)),
-			CVM_CAST64(octeon_read_csr64(
-				oct, CN23XX_SLI_IQ_DOORBELL(i))));
-		dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-			"CN23XX_SLI_IQ_INSTR_COUNT64", i,
-			CVM_CAST64(CN23XX_SLI_IQ_INSTR_COUNT64(i)),
-			CVM_CAST64(octeon_read_csr64(
-				oct, CN23XX_SLI_IQ_INSTR_COUNT64(i))));
+		pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+			 "CN23XX_SLI_IQ_BASE_ADDR64", i,
+			 CVM_CAST64(CN23XX_SLI_IQ_BASE_ADDR64(i)),
+			 CVM_CAST64(octeon_read_csr64(
+				 oct, CN23XX_SLI_IQ_BASE_ADDR64(i))));
+		pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+			 "CN23XX_SLI_IQ_SIZE", i,
+			 CVM_CAST64(CN23XX_SLI_IQ_SIZE(i)),
+			 CVM_CAST64(octeon_read_csr
+				 (oct, CN23XX_SLI_IQ_SIZE(i))));
+		pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+			 "CN23XX_SLI_IQ_DOORBELL", i,
+			 CVM_CAST64(CN23XX_SLI_IQ_DOORBELL(i)),
+			 CVM_CAST64(octeon_read_csr64(
+				 oct, CN23XX_SLI_IQ_DOORBELL(i))));
+		pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+			 "CN23XX_SLI_IQ_INSTR_COUNT64", i,
+			 CVM_CAST64(CN23XX_SLI_IQ_INSTR_COUNT64(i)),
+			 CVM_CAST64(octeon_read_csr64(
+				 oct, CN23XX_SLI_IQ_INSTR_COUNT64(i))));
 	}
 
 	/*In cn23xx_setup_oq_regs*/
 	for (i = 0; i < CN23XX_MAX_OUTPUT_QUEUES; i++) {
-		dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-			"CN23XX_SLI_OQ_BASE_ADDR64", i,
-			CVM_CAST64(CN23XX_SLI_OQ_BASE_ADDR64(i)),
-			CVM_CAST64(octeon_read_csr64(
-				oct, CN23XX_SLI_OQ_BASE_ADDR64(i))));
-		dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-			"CN23XX_SLI_OQ_SIZE", i,
-			CVM_CAST64(CN23XX_SLI_OQ_SIZE(i)),
-			CVM_CAST64(octeon_read_csr
-				(oct, CN23XX_SLI_OQ_SIZE(i))));
-		dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-			"CN23XX_SLI_OQ_BUFF_INFO_SIZE", i,
-			CVM_CAST64(CN23XX_SLI_OQ_BUFF_INFO_SIZE(i)),
-			CVM_CAST64(octeon_read_csr(
-				oct, CN23XX_SLI_OQ_BUFF_INFO_SIZE(i))));
-		dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-			"CN23XX_SLI_OQ_PKTS_SENT", i,
-			CVM_CAST64(CN23XX_SLI_OQ_PKTS_SENT(i)),
-			CVM_CAST64(octeon_read_csr64(
-				oct, CN23XX_SLI_OQ_PKTS_SENT(i))));
-		dev_dbg(&oct->pci_dev->dev, "%s(%d)[%llx] : 0x%016llx\n",
-			"CN23XX_SLI_OQ_PKTS_CREDIT", i,
-			CVM_CAST64(CN23XX_SLI_OQ_PKTS_CREDIT(i)),
-			CVM_CAST64(octeon_read_csr64(
-				oct, CN23XX_SLI_OQ_PKTS_CREDIT(i))));
+		pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+			 "CN23XX_SLI_OQ_BASE_ADDR64", i,
+			 CVM_CAST64(CN23XX_SLI_OQ_BASE_ADDR64(i)),
+			 CVM_CAST64(octeon_read_csr64(
+				 oct, CN23XX_SLI_OQ_BASE_ADDR64(i))));
+		pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+			 "CN23XX_SLI_OQ_SIZE", i,
+			 CVM_CAST64(CN23XX_SLI_OQ_SIZE(i)),
+			 CVM_CAST64(octeon_read_csr
+				 (oct, CN23XX_SLI_OQ_SIZE(i))));
+		pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+			 "CN23XX_SLI_OQ_BUFF_INFO_SIZE", i,
+			 CVM_CAST64(CN23XX_SLI_OQ_BUFF_INFO_SIZE(i)),
+			 CVM_CAST64(octeon_read_csr(
+				 oct, CN23XX_SLI_OQ_BUFF_INFO_SIZE(i))));
+		pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+			 "CN23XX_SLI_OQ_PKTS_SENT", i,
+			 CVM_CAST64(CN23XX_SLI_OQ_PKTS_SENT(i)),
+			 CVM_CAST64(octeon_read_csr64(
+				 oct, CN23XX_SLI_OQ_PKTS_SENT(i))));
+		pr_devel("%s(%d)[%llx] : 0x%016llx\n",
+			 "CN23XX_SLI_OQ_PKTS_CREDIT", i,
+			 CVM_CAST64(CN23XX_SLI_OQ_PKTS_CREDIT(i)),
+			 CVM_CAST64(octeon_read_csr64(
+				 oct, CN23XX_SLI_OQ_PKTS_CREDIT(i))));
 	}
 
-	dev_dbg(&oct->pci_dev->dev, "%s[%llx] : 0x%016llx\n",
-		"CN23XX_SLI_PKT_TIME_INT",
-		CVM_CAST64(CN23XX_SLI_PKT_TIME_INT),
-		CVM_CAST64(octeon_read_csr64(oct, CN23XX_SLI_PKT_TIME_INT)));
-	dev_dbg(&oct->pci_dev->dev, "%s[%llx] : 0x%016llx\n",
-		"CN23XX_SLI_PKT_CNT_INT",
-		CVM_CAST64(CN23XX_SLI_PKT_CNT_INT),
-		CVM_CAST64(octeon_read_csr64(oct, CN23XX_SLI_PKT_CNT_INT)));
+	pr_devel("%s[%llx] : 0x%016llx\n",
+		 "CN23XX_SLI_PKT_TIME_INT",
+		 CVM_CAST64(CN23XX_SLI_PKT_TIME_INT),
+		 CVM_CAST64(octeon_read_csr64(oct, CN23XX_SLI_PKT_TIME_INT)));
+	pr_devel("%s[%llx] : 0x%016llx\n",
+		 "CN23XX_SLI_PKT_CNT_INT",
+		 CVM_CAST64(CN23XX_SLI_PKT_CNT_INT),
+		 CVM_CAST64(octeon_read_csr64(oct, CN23XX_SLI_PKT_CNT_INT)));
 }
 
 static int cn23xx_pf_soft_reset(struct octeon_device *oct)
 {
 	octeon_write_csr64(oct, CN23XX_WIN_WR_MASK_REG, 0xFF);
 
-	dev_dbg(&oct->pci_dev->dev, "OCTEON[%d]: BIST enabled for CN23XX soft reset\n",
-		oct->octeon_id);
+	pr_devel("OCTEON[%d]: BIST enabled for CN23XX soft reset\n",
+		 oct->octeon_id);
 
 	octeon_write_csr64(oct, CN23XX_SLI_SCRATCH1, 0x1234ULL);
 
@@ -236,8 +236,8 @@ static int cn23xx_pf_soft_reset(struct octeon_device *oct)
 		return 1;
 	}
 
-	dev_dbg(&oct->pci_dev->dev, "OCTEON[%d]: Reset completed\n",
-		oct->octeon_id);
+	pr_devel("OCTEON[%d]: Reset completed\n",
+		 oct->octeon_id);
 
 	/* restore the  reset value*/
 	octeon_write_csr64(oct, CN23XX_WIN_WR_MASK_REG, 0xFF);
@@ -1238,6 +1238,9 @@ static int cn23xx_sriov_config(struct octeon_device *oct)
 		 oct->sriov_info.trs, oct->sriov_info.num_vfs,
 		 oct->sriov_info.rings_per_vf, oct->sriov_info.pf_srn,
 		 oct->sriov_info.num_pf_rings);
+
+	oct->sriov_info.sriov_enabled = 0;
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index afc6f9d..438d32f 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -19,6 +19,7 @@
 * This file may also be available under a different license from Cavium.
 * Contact Cavium, Inc. for more information
 **********************************************************************/
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/version.h>
 #include <linux/pci.h>
 #include <linux/firmware.h>
@@ -69,6 +70,18 @@ static int conf_type;
 module_param(conf_type, int, 0);
 MODULE_PARM_DESC(conf_type, "select octeon configuration 0 default 1 ovs");
 
+static unsigned int num_vfs[2] = { 0, 0 };
+module_param_array(num_vfs, uint, NULL, 0444);
+MODULE_PARM_DESC(num_vfs, "two comma-separated unsigned integers that specify number of VFs for PF0 (left of the comma) and PF1 (right of the comma); for 23xx only");
+
+static unsigned int num_queues_per_pf[2] = { 0, 0 };
+module_param_array(num_queues_per_pf, uint, NULL, 0444);
+MODULE_PARM_DESC(num_queues_per_pf, "two comma-separated unsigned integers that specify number of queues per PF0 (left of the comma) and PF1 (right of the comma); for 23xx only");
+
+static unsigned int num_queues_per_vf[2] = { 0, 0 };
+module_param_array(num_queues_per_vf, uint, NULL, 0444);
+MODULE_PARM_DESC(num_queues_per_vf, "two comma-separated unsigned integers that specify number of queues per VFs for PF0 (left of the comma) and PF1 (right of the comma); for 23xx only");
+
 static int ptp_enable = 1;
 
 /* Bit mask values for lio->ifstate */
@@ -379,8 +392,8 @@ static void stop_pci_io(struct octeon_device *oct)
 	if (oct->flags & LIO_FLAG_MSI_ENABLED)
 		pci_disable_msi(oct->pci_dev);
 
-	dev_dbg(&oct->pci_dev->dev, "Device state is now %s\n",
-		lio_get_state_string(&oct->status));
+	pr_devel("Device state is now %s\n",
+		 lio_get_state_string(&oct->status));
 
 	/* cn63xx_cleanup_aer_uncorrect_error_status(oct->pci_dev); */
 	/* making it a common function for all OCTEON models */
@@ -1111,7 +1124,7 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
 			oct->msix_entries = NULL;
 			return 1;
 		}
-		dev_dbg(&oct->pci_dev->dev, "OCTEON: Enough MSI-X interrupts are allocated...\n");
+		pr_devel("OCTEON: Enough MSI-X interrupts are allocated...\n");
 
 		num_ioq_vectors = oct->num_msix_irqs;
 
@@ -1161,8 +1174,8 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
 					msix_entries[i].vector,
 					(&oct->ioq_vector[i].affinity_mask));
 		}
-		dev_dbg(&oct->pci_dev->dev, "OCTEON[%d]: MSI-X enabled\n",
-			oct->octeon_id);
+		pr_devel("OCTEON[%d]: MSI-X enabled\n",
+			 oct->octeon_id);
 	} else {
 		err = pci_enable_msi(oct->pci_dev);
 		if (err)
@@ -1353,7 +1366,7 @@ liquidio_probe(struct pci_dev *pdev,
 	oct_dev->rx_pause = 1;
 	oct_dev->tx_pause = 1;
 
-	dev_dbg(&oct_dev->pci_dev->dev, "Device is ready\n");
+	pr_devel("Device is ready\n");
 
 	return 0;
 }
@@ -1380,8 +1393,8 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 		atomic_set(&oct->status, OCT_DEV_IN_RESET);
 
 		oct->app_mode = CVM_DRV_INVALID_APP;
-		dev_dbg(&oct->pci_dev->dev, "Device state is now %s\n",
-			lio_get_state_string(&oct->status));
+		pr_devel("Device state is now %s\n",
+			 lio_get_state_string(&oct->status));
 
 		schedule_timeout_uninterruptible(HZ / 10);
 
@@ -1472,6 +1485,8 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 				continue;
 			octeon_delete_instr_queue(oct, i);
 		}
+		if (oct->sriov_info.sriov_enabled)
+			pci_disable_sriov(oct->pci_dev);
 		/* fallthrough */
 	case OCT_DEV_SC_BUFF_POOL_INIT_DONE:
 		octeon_free_sc_buffer_pool(oct);
@@ -1610,7 +1625,7 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 
 	lio = GET_LIO(netdev);
 
-	dev_dbg(&oct->pci_dev->dev, "NIC device cleanup\n");
+	pr_devel("NIC device cleanup\n");
 
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_RUNNING)
 		liquidio_stop(netdev);
@@ -1648,7 +1663,7 @@ static int liquidio_stop_nic_module(struct octeon_device *oct)
 	int i, j;
 	struct lio *lio;
 
-	dev_dbg(&oct->pci_dev->dev, "Stopping network interfaces\n");
+	pr_devel("Stopping network interfaces\n");
 	if (!oct->ifcount) {
 		dev_err(&oct->pci_dev->dev, "Init for Octeon was not completed\n");
 		return 1;
@@ -1668,7 +1683,7 @@ static int liquidio_stop_nic_module(struct octeon_device *oct)
 	for (i = 0; i < oct->ifcount; i++)
 		liquidio_destroy_nic_device(oct, i);
 
-	dev_dbg(&oct->pci_dev->dev, "Network interfaces stopped\n");
+	pr_devel("Network interfaces stopped\n");
 	return 0;
 }
 
@@ -1680,7 +1695,7 @@ static void liquidio_remove(struct pci_dev *pdev)
 {
 	struct octeon_device *oct_dev = pci_get_drvdata(pdev);
 
-	dev_dbg(&oct_dev->pci_dev->dev, "Stopping device\n");
+	pr_devel("Stopping device\n");
 
 	if (oct_dev->watchdog_task)
 		kthread_stop(oct_dev->watchdog_task);
@@ -1730,6 +1745,15 @@ static int octeon_chip_specific_setup(struct octeon_device *oct)
 
 	case OCTEON_CN23XX_PCIID_PF:
 		oct->chip_id = OCTEON_CN23XX_PF_VID;
+		oct->sriov_info.num_vfs = num_vfs[oct->pci_dev->devfn];
+		if (num_queues_per_vf[oct->pci_dev->devfn] > 0) {
+			oct->sriov_info.rings_per_vf =
+			    num_queues_per_vf[oct->pci_dev->devfn];
+		}
+		if (num_queues_per_pf[oct->pci_dev->devfn] > 0) {
+			oct->sriov_info.num_pf_rings =
+			    num_queues_per_pf[oct->pci_dev->devfn];
+		}
 		ret = setup_cn23xx_octeon_pf_device(oct);
 		s = "CN23XX";
 		break;
@@ -2146,14 +2170,14 @@ static int octeon_setup_droq(struct octeon_device *oct, int q_no, int num_descs,
 {
 	int ret_val = 0;
 
-	dev_dbg(&oct->pci_dev->dev, "Creating Droq: %d\n", q_no);
+	pr_devel("Creating Droq: %d\n", q_no);
 	/* droq creation and local register settings. */
 	ret_val = octeon_create_droq(oct, q_no, num_descs, desc_size, app_ctx);
 	if (ret_val < 0)
 		return ret_val;
 
 	if (ret_val == 1) {
-		dev_dbg(&oct->pci_dev->dev, "Using default droq %d\n", q_no);
+		pr_devel("Using default droq %d\n", q_no);
 		return 0;
 	}
 	/* tasklet creation for the droq */
@@ -2481,9 +2505,8 @@ static inline int setup_io_queues(struct octeon_device *octeon_dev,
 	/* set up DROQs. */
 	for (q = 0; q < lio->linfo.num_rxpciq; q++) {
 		q_no = lio->linfo.rxpciq[q].s.q_no;
-		dev_dbg(&octeon_dev->pci_dev->dev,
-			"setup_io_queues index:%d linfo.rxpciq.s.q_no:%d\n",
-			q, q_no);
+		pr_devel("setup_io_queues index:%d linfo.rxpciq.s.q_no:%d\n",
+			 q, q_no);
 		retval = octeon_setup_droq(octeon_dev, q_no,
 					   CFG_GET_NUM_RX_DESCS_NIC_IF
 						   (octeon_get_conf(octeon_dev),
@@ -2500,8 +2523,8 @@ static inline int setup_io_queues(struct octeon_device *octeon_dev,
 
 		droq = octeon_dev->droq[q_no];
 		napi = &droq->napi;
-		dev_dbg(&octeon_dev->pci_dev->dev, "netif_napi_add netdev:%llx oct:%llx pf_num:%d\n",
-			(u64)netdev, (u64)octeon_dev, octeon_dev->pf_num);
+		pr_devel("netif_napi_add netdev:%llx oct:%llx pf_num:%d\n",
+			 (u64)netdev, (u64)octeon_dev, octeon_dev->pf_num);
 		netif_napi_add(netdev, napi, liquidio_napi_poll, 64);
 
 		/* designate a CPU for this droq */
@@ -3744,9 +3767,8 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			ifidx_or_pfnum = i;
 		}
 
-		dev_dbg(&octeon_dev->pci_dev->dev,
-			"requesting config for interface %d, iqs %d, oqs %d\n",
-			ifidx_or_pfnum, num_iqueues, num_oqueues);
+		pr_devel("requesting config for interface %d, iqs %d, oqs %d\n",
+			 ifidx_or_pfnum, num_iqueues, num_oqueues);
 		WRITE_ONCE(ctx->cond, 0);
 		ctx->octeon_id = lio_get_device_id(octeon_dev);
 		init_waitqueue_head(&ctx->wc);
@@ -3803,10 +3825,9 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 				resp->cfg_info.oqmask);
 			goto setup_nic_dev_fail;
 		}
-		dev_dbg(&octeon_dev->pci_dev->dev,
-			"interface %d, iqmask %016llx, oqmask %016llx, numiqueues %d, numoqueues %d\n",
-			i, resp->cfg_info.iqmask, resp->cfg_info.oqmask,
-			num_iqueues, num_oqueues);
+		pr_devel("interface %d, iqmask %016llx, oqmask %016llx, numiqueues %d, numoqueues %d\n",
+			 i, resp->cfg_info.iqmask, resp->cfg_info.oqmask,
+			 num_iqueues, num_oqueues);
 		netdev = alloc_etherdev_mq(LIO_SIZE, num_iqueues);
 
 		if (!netdev) {
@@ -3898,9 +3919,8 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		lio->octprops = props;
 		lio->netdev = netdev;
 
-		dev_dbg(&octeon_dev->pci_dev->dev,
-			"if%d gmx: %d hw_addr: 0x%llx\n", i,
-			lio->linfo.gmxport, CVM_CAST64(lio->linfo.hw_addr));
+		pr_devel("if%d gmx: %d hw_addr: 0x%llx\n", i,
+			 lio->linfo.gmxport, CVM_CAST64(lio->linfo.hw_addr));
 
 		/* 64-bit swap required on LE machines */
 		octeon_swap_8B_data(&lio->linfo.hw_addr, 1);
@@ -3958,9 +3978,8 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			goto setup_nic_dev_fail;
 		}
 
-		dev_dbg(&octeon_dev->pci_dev->dev,
-			"Setup NIC ifidx:%d mac:%02x%02x%02x%02x%02x%02x\n",
-			i, mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
+		pr_devel("Setup NIC ifidx:%d mac:%02x%02x%02x%02x%02x%02x\n",
+			 i, mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
 		netif_carrier_off(netdev);
 		lio->link_changes++;
 
@@ -3975,8 +3994,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		liquidio_set_feature(netdev, OCTNET_CMD_TNL_TX_CSUM_CTL,
 				     OCTNET_CMD_TXCSUM_ENABLE);
 
-		dev_dbg(&octeon_dev->pci_dev->dev,
-			"NIC ifidx:%d Setup successful\n", i);
+		pr_devel("NIC ifidx:%d Setup successful\n", i);
 
 		octeon_free_soft_command(octeon_dev, sc);
 	}
@@ -3997,6 +4015,43 @@ setup_nic_wait_intr:
 	return -ENODEV;
 }
 
+static int octeon_enable_sriov(struct octeon_device *oct)
+{
+	int err;
+	unsigned int num_vfs = oct->sriov_info.num_vfs;
+	struct pci_dev *vfdev;
+	u32 u;
+
+	if (OCTEON_CN23XX_PF(oct) && num_vfs) {
+		err = pci_enable_sriov(oct->pci_dev, oct->sriov_info.num_vfs);
+		if (err) {
+			dev_err(&oct->pci_dev->dev,
+				"OCTEON: Failed to enable PCI sriov: %d\n",
+				err);
+			return err;
+		}
+		oct->sriov_info.sriov_enabled = 1;
+
+		/* init lookup table that maps DPI ring number to VF pci_dev
+		 * struct pointer
+		 */
+		u = 0;
+		vfdev = pci_get_device(PCI_VENDOR_ID_CAVIUM,
+				       OCTEON_CN23XX_VF_VID, NULL);
+		while (vfdev) {
+			if (vfdev->is_virtfn &&
+			    (vfdev->physfn == oct->pci_dev)) {
+				oct->sriov_info.dpiring_to_vfpcidev_lut[u] =
+					vfdev;
+				u += oct->sriov_info.rings_per_vf;
+			}
+			vfdev = pci_get_device(PCI_VENDOR_ID_CAVIUM,
+					       OCTEON_CN23XX_VF_VID, vfdev);
+		}
+	}
+	return 0;
+}
+
 /**
  * \brief initialize the NIC
  * @param oct octeon device
@@ -4010,7 +4065,7 @@ static int liquidio_init_nic_module(struct octeon_device *oct)
 	int i, retval = 0;
 	int num_nic_ports = CFG_GET_NUM_NIC_PORTS(octeon_get_conf(oct));
 
-	dev_dbg(&oct->pci_dev->dev, "Initializing network interfaces\n");
+	pr_devel("Initializing network interfaces\n");
 
 	/* only default iq and oq were initialized
 	 * initialize the rest as well
@@ -4047,7 +4102,7 @@ static int liquidio_init_nic_module(struct octeon_device *oct)
 	intrmod_cfg->rx_frames = CFG_GET_OQ_INTR_PKT(octeon_get_conf(oct));
 	intrmod_cfg->rx_usecs = CFG_GET_OQ_INTR_TIME(octeon_get_conf(oct));
 	intrmod_cfg->tx_frames = CFG_GET_IQ_INTR_PKT(octeon_get_conf(oct));
-	dev_dbg(&oct->pci_dev->dev, "Network interfaces ready\n");
+	pr_devel("Network interfaces ready\n");
 
 	return retval;
 
@@ -4087,12 +4142,16 @@ static void nic_starter(struct work_struct *work)
 	atomic_set(&oct->status, OCT_DEV_RUNNING);
 
 	if (oct->app_mode && oct->app_mode == CVM_DRV_NIC_APP) {
-		dev_dbg(&oct->pci_dev->dev, "Starting NIC module\n");
+		pr_devel("Starting NIC module\n");
 
-		if (liquidio_init_nic_module(oct))
+		if (liquidio_init_nic_module(oct)) {
 			dev_err(&oct->pci_dev->dev, "NIC initialization failed\n");
-		else
-			handshake[oct->octeon_id].started_ok = 1;
+		} else {
+			if (octeon_enable_sriov(oct))
+				handshake[oct->octeon_id].started_ok = 0;
+			else
+				handshake[oct->octeon_id].started_ok = 1;
+		}
 	} else {
 		dev_err(&oct->pci_dev->dev,
 			"Unexpected application running on NIC (%d). Check firmware.\n",
@@ -4235,7 +4294,7 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 	}
 
 	/* Initialize the tasklet that handles output queue packet processing.*/
-	dev_dbg(&octeon_dev->pci_dev->dev, "Initializing droq tasklet\n");
+	pr_devel("Initializing droq tasklet\n");
 	tasklet_init(&oct_priv->droq_tasklet, octeon_droq_bh,
 		     (unsigned long)octeon_dev);
 
@@ -4257,7 +4316,7 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 	atomic_set(&octeon_dev->status, OCT_DEV_IO_QUEUES_DONE);
 
 	if ((!OCTEON_CN23XX_PF(octeon_dev)) || !fw_loaded) {
-		dev_dbg(&octeon_dev->pci_dev->dev, "Waiting for DDR initialization...\n");
+		pr_devel("Waiting for DDR initialization...\n");
 		if (!ddr_timeout) {
 			dev_info(&octeon_dev->pci_dev->dev,
 				 "WAITING. Set ddr_timeout to non-zero value to proceed with initialization.\n");
@@ -4289,7 +4348,7 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 		/* Divert uboot to take commands from host instead. */
 		ret = octeon_console_send_cmd(octeon_dev, bootcmd, 50);
 
-		dev_dbg(&octeon_dev->pci_dev->dev, "Initializing consoles\n");
+		pr_devel("Initializing consoles\n");
 		ret = octeon_init_consoles(octeon_dev);
 		if (ret) {
 			dev_err(&octeon_dev->pci_dev->dev, "Could not access board consoles\n");
@@ -4303,7 +4362,7 @@ static int octeon_device_init(struct octeon_device *octeon_dev)
 
 		atomic_set(&octeon_dev->status, OCT_DEV_CONSOLE_INIT_DONE);
 
-		dev_dbg(&octeon_dev->pci_dev->dev, "Loading firmware\n");
+		pr_devel("Loading firmware\n");
 		ret = load_firmware(octeon_dev);
 		if (ret) {
 			dev_err(&octeon_dev->pci_dev->dev, "Could not load firmware to board\n");
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_config.h b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
index 0127a0e..8871fb5 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_config.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
@@ -471,4 +471,7 @@ struct octeon_config {
 
 #define MAX_POSSIBLE_OCTEON_INSTR_QUEUES	CN23XX_MAX_INPUT_QUEUES
 #define MAX_POSSIBLE_OCTEON_OUTPUT_QUEUES	CN23XX_MAX_OUTPUT_QUEUES
+
+#define MAX_POSSIBLE_VFS			64
+
 #endif /* __OCTEON_CONFIG_H__  */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 89381ba..18e3050 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -38,6 +38,7 @@
 #define  OCTEON_CN68XX                0x0091
 #define  OCTEON_CN66XX                0x0092
 #define  OCTEON_CN23XX_PF_VID         0x9702
+#define  OCTEON_CN23XX_VF_VID         0x9712
 
 /**RevisionId for the chips */
 #define  OCTEON_CN23XX_REV_1_0        0x00
@@ -337,6 +338,10 @@ struct octeon_sriov_info {
 	/* total pf rings */
 	u32	trs;
 
+	u32	sriov_enabled;
+
+	/*lookup table that maps DPI ring number to VF pci_dev struct pointer*/
+	struct pci_dev *dpiring_to_vfpcidev_lut[MAX_POSSIBLE_VFS];
 };
 
 struct octeon_ioq_vector {
-- 
1.8.3.1
