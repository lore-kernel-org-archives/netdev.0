From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next] cxgb4: Allow for backward compatibility with new VPD scheme.
Date: Fri,  8 Mar 2013 19:05:29 +0530
Message-ID: <1362749729-4532-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	abhishek@chelsio.com, Santosh Rastapur <santosh@chelsio.com>,
	Vipul Pandya <vipul@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13386 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932887Ab3CHNlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 08:41:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santosh Rastapur <santosh@chelsio.com>

New scheme calls for 3rd party VPD at offset 0x0 and Chelsio VPD at offset
0x400 of the function.  If no 3rd party VPD is present, then a copy of
Chelsio's VPD will be at offset 0x0 to keep in line with PCI spec which
requires the VPD to be present at offset 0x0.

Signed-off-by: Santosh Rastapur <santosh@chelsio.com>
Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 4ce6203..8049268 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -497,8 +497,9 @@ int t4_memory_write(struct adapter *adap, int mtype, u32 addr, u32 len,
 }
 
 #define EEPROM_STAT_ADDR   0x7bfc
-#define VPD_BASE           0
 #define VPD_LEN            512
+#define VPD_BASE           0x400
+#define VPD_BASE_OLD       0
 
 /**
  *	t4_seeprom_wp - enable/disable EEPROM write protection
@@ -524,7 +525,7 @@ int t4_seeprom_wp(struct adapter *adapter, bool enable)
 int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 {
 	u32 cclk_param, cclk_val;
-	int i, ret;
+	int i, ret, addr;
 	int ec, sn;
 	u8 *vpd, csum;
 	unsigned int vpdr_len, kw_offset, id_len;
@@ -533,7 +534,12 @@ int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 	if (!vpd)
 		return -ENOMEM;
 
-	ret = pci_read_vpd(adapter->pdev, VPD_BASE, VPD_LEN, vpd);
+	ret = pci_read_vpd(adapter->pdev, VPD_BASE, sizeof(u32), vpd);
+	if (ret < 0)
+		goto out;
+	addr = *vpd == 0x82 ? VPD_BASE : VPD_BASE_OLD;
+
+	ret = pci_read_vpd(adapter->pdev, addr, VPD_LEN, vpd);
 	if (ret < 0)
 		goto out;
 
-- 
1.7.1
