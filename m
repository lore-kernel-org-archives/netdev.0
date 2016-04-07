From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/8] igb: Fix sparse warning about passing __beXX into leXX_to_cpup
Date: Wed,  6 Apr 2016 21:37:26 -0700
Message-ID: <1460003853-133949-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460003853-133949-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7189 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751802AbcDGEhg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 00:37:36 -0400
In-Reply-To: <1460003853-133949-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

We were casting the addr as __beXX and then passing it into le32_to_cpu
because the device expects the MAC address to be in network order even
though the register set is little endian.  Instead of casting it as __beXX
we can just cast it as __leXX in order to maintain consistency since the
region of memory is already in little endian order as far as we are
concerned.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 55a1405c..36814a2 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7845,11 +7845,13 @@ static void igb_rar_set_qsel(struct igb_adapter *adapter, u8 *addr, u32 index,
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rar_low, rar_high;
 
-	/* HW expects these in little endian so we reverse the byte order
-	 * from network order (big endian) to CPU endian
+	/* HW expects these to be in network order when they are plugged
+	 * into the registers which are little endian.  In order to guarantee
+	 * that ordering we need to do an leXX_to_cpup here in order to be
+	 * ready for the byteswap that occurs with writel
 	 */
-	rar_low = le32_to_cpup((__be32 *)(addr));
-	rar_high = le16_to_cpup((__be16 *)(addr + 4));
+	rar_low = le32_to_cpup((__le32 *)(addr));
+	rar_high = le16_to_cpup((__le16 *)(addr + 4));
 
 	/* Indicate to hardware the Address is Valid. */
 	rar_high |= E1000_RAH_AV;
-- 
2.5.5
