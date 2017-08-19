From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix use of pf in pass-through mode in a
 virtual machine
Date: Fri, 18 Aug 2017 18:21:49 -0700
Message-ID: <20170819012149.GA4838@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0086.outbound.protection.outlook.com ([104.47.32.86]:38918
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751054AbdHSBVi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 21:21:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Fix problem when PF is used in pass-through mode in a VM (w/embedded f/w).

If host error reading PF num from CN23XX_PCIE_SRIOV_FDL reg,
try to retrieve PF num from SLI_PKT(0)_INPUT_CONTROL (initialized by f/w).

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 47 +++++++++++++++++++---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  2 +
 2 files changed, 44 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index 4b0ca9f..fbc0d4e 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -1150,14 +1150,50 @@ static void cn23xx_get_pcie_qlmport(struct octeon_device *oct)
 		oct->pcie_port);
 }
 
-static void cn23xx_get_pf_num(struct octeon_device *oct)
+static int cn23xx_get_pf_num(struct octeon_device *oct)
 {
 	u32 fdl_bit = 0;
+	u64 pkt0_in_ctl, d64;
+	int pfnum, mac, trs, ret;
+
+	ret = 0;
 
 	/** Read Function Dependency Link reg to get the function number */
-	pci_read_config_dword(oct->pci_dev, CN23XX_PCIE_SRIOV_FDL, &fdl_bit);
-	oct->pf_num = ((fdl_bit >> CN23XX_PCIE_SRIOV_FDL_BIT_POS) &
-		       CN23XX_PCIE_SRIOV_FDL_MASK);
+	if (pci_read_config_dword(oct->pci_dev, CN23XX_PCIE_SRIOV_FDL,
+				  &fdl_bit) == 0) {
+		oct->pf_num = ((fdl_bit >> CN23XX_PCIE_SRIOV_FDL_BIT_POS) &
+			       CN23XX_PCIE_SRIOV_FDL_MASK);
+	} else {
+		ret = EINVAL;
+
+		/* Under some virtual environments, extended PCI regs are
+		 * inaccessible, in which case the above read will have failed.
+		 * In this case, read the PF number from the
+		 * SLI_PKT0_INPUT_CONTROL reg (written by f/w)
+		 */
+		pkt0_in_ctl = octeon_read_csr64(oct,
+						CN23XX_SLI_IQ_PKT_CONTROL64(0));
+		pfnum = (pkt0_in_ctl >> CN23XX_PKT_INPUT_CTL_PF_NUM_POS) &
+			CN23XX_PKT_INPUT_CTL_PF_NUM_MASK;
+		mac = (octeon_read_csr(oct, CN23XX_SLI_MAC_NUMBER)) & 0xff;
+
+		/* validate PF num by reading RINFO; f/w writes RINFO.trs == 1*/
+		d64 = octeon_read_csr64(oct,
+					CN23XX_SLI_PKT_MAC_RINFO64(mac, pfnum));
+		trs = (int)(d64 >> CN23XX_PKT_MAC_CTL_RINFO_TRS_BIT_POS) & 0xff;
+		if (trs == 1) {
+			dev_err(&oct->pci_dev->dev,
+				"OCTEON: error reading PCI cfg space pfnum, re-read %u\n",
+				pfnum);
+			oct->pf_num = pfnum;
+			ret = 0;
+		} else {
+			dev_err(&oct->pci_dev->dev,
+				"OCTEON: error reading PCI cfg space pfnum; could not ascertain PF number\n");
+		}
+	}
+
+	return ret;
 }
 
 static void cn23xx_setup_reg_address(struct octeon_device *oct)
@@ -1279,7 +1315,8 @@ int setup_cn23xx_octeon_pf_device(struct octeon_device *oct)
 		return 1;
 	}
 
-	cn23xx_get_pf_num(oct);
+	if (cn23xx_get_pf_num(oct) != 0)
+		return 1;
 
 	if (cn23xx_sriov_config(oct)) {
 		octeon_unmap_pci_barx(oct, 0);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index cbd6287..1a4fc17 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1848,6 +1848,8 @@ static int octeon_chip_specific_setup(struct octeon_device *oct)
 	case OCTEON_CN23XX_PCIID_PF:
 		oct->chip_id = OCTEON_CN23XX_PF_VID;
 		ret = setup_cn23xx_octeon_pf_device(oct);
+		if (ret)
+			break;
 #ifdef CONFIG_PCI_IOV
 		if (!ret)
 			pci_sriov_set_totalvfs(oct->pci_dev,
-- 
1.8.3.1
