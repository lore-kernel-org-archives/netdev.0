From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH 02/16] bnx2x: clean up unnecessary MSI/MSI-X capability find
Date: Thu, 8 Aug 2013 21:02:36 +0800
Message-ID: <1375966956-36436-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hanjun Guo <guohanjun@huawei.com>, <jiang.liu@huawei.com>,
	Yijing Wang <wangyijing@huawei.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	<netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:41385 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757822Ab3HHNCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 09:02:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI core will initialize device MSI/MSI-X capability in
pci_msi_init_pci_dev(). So device driver should use
pci_dev->msi_cap/msix_cap to determine whether the device
support MSI/MSI-X instead of using
pci_find_capability(pci_dev, PCI_CAP_ID_MSI/MSIX).
Access to PCIe device config space again will consume more time.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e06186c..fb5e054 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12534,16 +12534,14 @@ static int bnx2x_set_qm_cid_count(struct bnx2x *bp)
 static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev,
 				     int cnic_cnt, bool is_vf)
 {
-	int pos, index;
+	int index;
 	u16 control = 0;
 
-	pos = pci_find_capability(pdev, PCI_CAP_ID_MSIX);
-
 	/*
 	 * If MSI-X is not supported - return number of SBs needed to support
 	 * one fast path queue: one FP queue + SB for CNIC
 	 */
-	if (!pos) {
+	if (!pdev->msix_cap) {
 		dev_info(&pdev->dev, "no msix capability found\n");
 		return 1 + cnic_cnt;
 	}
@@ -12556,7 +12554,7 @@ static int bnx2x_get_num_non_def_sbs(struct pci_dev *pdev,
 	 * without the default SB.
 	 * For VFs there is no default SB, then we return (index+1).
 	 */
-	pci_read_config_word(pdev, pos  + PCI_MSI_FLAGS, &control);
+	pci_read_config_word(pdev, pdev->msix_cap + PCI_MSI_FLAGS, &control);
 
 	index = control & PCI_MSIX_FLAGS_QSIZE;
 
-- 
1.7.1
