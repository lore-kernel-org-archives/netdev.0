From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix crash in presence of zeroed-out base
 address regs
Date: Wed, 30 Aug 2017 16:19:53 -0700
Message-ID: <20170830231953.GA14744@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0077.outbound.protection.outlook.com ([104.47.32.77]:59328
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751155AbdH3XSw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Aug 2017 19:18:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Fix crash in linux PF driver when BARs have been cleared/de-programmed;
fail early init (prior to mapping BARs) if the BAR0 or
BAR1 registers are zero.

This situation can arise when the PF is added to a VM (PCI pass-through),
then a PF FLR is issued (in the VM).  After this occurs, the BAR registers
will be zero. If we attempt to load the PF driver in the host
(after VM has been shutdown), the host can reset.

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 .../net/ethernet/cavium/liquidio/cn23xx_pf_device.c  | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index 4b0ca9f..8705e23 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -1269,6 +1269,26 @@ static int cn23xx_sriov_config(struct octeon_device *oct)
 
 int setup_cn23xx_octeon_pf_device(struct octeon_device *oct)
 {
+	u32 data32;
+	u64 BAR0, BAR1;
+
+	pci_read_config_dword(oct->pci_dev, PCI_BASE_ADDRESS_0, &data32);
+	BAR0 = (u64)(data32 & ~0xf);
+	pci_read_config_dword(oct->pci_dev, PCI_BASE_ADDRESS_1, &data32);
+	BAR0 |= ((u64)data32 << 32);
+	pci_read_config_dword(oct->pci_dev, PCI_BASE_ADDRESS_2, &data32);
+	BAR1 = (u64)(data32 & ~0xf);
+	pci_read_config_dword(oct->pci_dev, PCI_BASE_ADDRESS_3, &data32);
+	BAR1 |= ((u64)data32 << 32);
+
+	if (!BAR0 || !BAR1) {
+		if (!BAR0)
+			dev_err(&oct->pci_dev->dev, "device BAR0 unassigned\n");
+		if (!BAR1)
+			dev_err(&oct->pci_dev->dev, "device BAR1 unassigned\n");
+		return 1;
+	}
+
 	if (octeon_map_pci_barx(oct, 0, 0))
 		return 1;
 
-- 
1.8.3.1
