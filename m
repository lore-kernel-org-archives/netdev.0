From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH 09/16] netxen: clean up unnecessary MSI/MSI-X capability find
Date: Thu, 8 Aug 2013 21:02:56 +0800
Message-ID: <1375966976-33428-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hanjun Guo <guohanjun@huawei.com>, <jiang.liu@huawei.com>,
	Yijing Wang <wangyijing@huawei.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	<netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:57690 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757824Ab3HHNDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 09:03:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI core will initialize device MSI/MSI-X capability in
pci_msi_init_pci_dev(). So device driver should use
pci_dev->msi_cap/msix_cap to determine whether the device
support MSI/MSI-X instead of using
pci_find_capability(pci_dev, PCI_CAP_ID_MSI/MSIX).
Access to PCIe device config space again will consume more time.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
Cc: Manish Chopra <manish.chopra@qlogic.com>
Cc: Sony Chacko <sony.chacko@qlogic.com>
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>
Cc: netdev@vger.kernel.org
---
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index c401b0b..1046e94 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -459,16 +459,14 @@ static void netxen_pcie_strap_init(struct netxen_adapter *adapter)
 static void netxen_set_msix_bit(struct pci_dev *pdev, int enable)
 {
 	u32 control;
-	int pos;
 
-	pos = pci_find_capability(pdev, PCI_CAP_ID_MSIX);
-	if (pos) {
-		pci_read_config_dword(pdev, pos, &control);
+	if (pdev->msix_cap) {
+		pci_read_config_dword(pdev, pdev->msix_cap, &control);
 		if (enable)
 			control |= PCI_MSIX_FLAGS_ENABLE;
 		else
 			control = 0;
-		pci_write_config_dword(pdev, pos, control);
+		pci_write_config_dword(pdev, pdev->msix_cap, control);
 	}
 }
 
-- 
1.7.1
