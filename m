From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] igb: clean up code for setting MAC address
Date: Mon, 15 Feb 2016 19:21:45 -0800
Message-ID: <1455592915-82261-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455592915-82261-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14083 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753318AbcBPDWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2016 22:22:02 -0500
In-Reply-To: <1455592915-82261-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

Drop a bunch of hand written byte swapping code in favor of just doing the
byte swapping ourselves.  The registers are little endian registers storing
a big endian value so if we read the MAC address array as little endian
then we will get the CPU registers into the proper layout.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 85c47aa..02f19e4 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7698,15 +7698,14 @@ static void igb_io_resume(struct pci_dev *pdev)
 static void igb_rar_set_qsel(struct igb_adapter *adapter, u8 *addr, u32 index,
 			     u8 qsel)
 {
-	u32 rar_low, rar_high;
 	struct e1000_hw *hw = &adapter->hw;
+	u32 rar_low, rar_high;
 
 	/* HW expects these in little endian so we reverse the byte order
-	 * from network order (big endian) to little endian
+	 * from network order (big endian) to CPU endian
 	 */
-	rar_low = ((u32) addr[0] | ((u32) addr[1] << 8) |
-		   ((u32) addr[2] << 16) | ((u32) addr[3] << 24));
-	rar_high = ((u32) addr[4] | ((u32) addr[5] << 8));
+	rar_low = le32_to_cpup((__be32 *)(addr));
+	rar_high = le16_to_cpup((__be16 *)(addr + 4));
 
 	/* Indicate to hardware the Address is Valid. */
 	rar_high |= E1000_RAH_AV;
-- 
2.5.0
