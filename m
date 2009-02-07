From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 07/26] igb: read address from RAH/RAL instead of from
	EEPROM
Date: Sat, 07 Feb 2009 01:17:06 -0800
Message-ID: <20090207091706.15697.11008.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:38379 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752436AbZBGJR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:17:26 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Instead of pulling the mac address from EEPROM it is easier to pull it from
the RAL/RAH registers and then just copy it into the address structures.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_defines.h |    2 ++
 drivers/net/igb/e1000_nvm.c     |   28 +++++++++++-----------------
 2 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 40d0342..54a1489 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -481,6 +481,8 @@
  * manageability enabled, allowing us room for 15 multicast addresses.
  */
 #define E1000_RAH_AV  0x80000000        /* Receive descriptor valid */
+#define E1000_RAL_MAC_ADDR_LEN 4
+#define E1000_RAH_MAC_ADDR_LEN 2
 
 /* Error Codes */
 #define E1000_ERR_NVM      1
diff --git a/drivers/net/igb/e1000_nvm.c b/drivers/net/igb/e1000_nvm.c
index a84e4e4..5942da1 100644
--- a/drivers/net/igb/e1000_nvm.c
+++ b/drivers/net/igb/e1000_nvm.c
@@ -515,29 +515,23 @@ out:
  **/
 s32 igb_read_mac_addr(struct e1000_hw *hw)
 {
-	s32  ret_val = 0;
-	u16 offset, nvm_data, i;
+	u32 rar_high;
+	u32 rar_low;
+	u16 i;
 
-	for (i = 0; i < ETH_ALEN; i += 2) {
-		offset = i >> 1;
-		ret_val = hw->nvm.ops.read_nvm(hw, offset, 1, &nvm_data);
-		if (ret_val) {
-			hw_dbg("NVM Read Error\n");
-			goto out;
-		}
-		hw->mac.perm_addr[i] = (u8)(nvm_data & 0xFF);
-		hw->mac.perm_addr[i+1] = (u8)(nvm_data >> 8);
-	}
+	rar_high = rd32(E1000_RAH(0));
+	rar_low = rd32(E1000_RAL(0));
+
+	for (i = 0; i < E1000_RAL_MAC_ADDR_LEN; i++)
+		hw->mac.perm_addr[i] = (u8)(rar_low >> (i*8));
 
-	/* Flip last bit of mac address if we're on second port */
-	if (hw->bus.func == E1000_FUNC_1)
-		hw->mac.perm_addr[5] ^= 1;
+	for (i = 0; i < E1000_RAH_MAC_ADDR_LEN; i++)
+		hw->mac.perm_addr[i+4] = (u8)(rar_high >> (i*8));
 
 	for (i = 0; i < ETH_ALEN; i++)
 		hw->mac.addr[i] = hw->mac.perm_addr[i];
 
-out:
-	return ret_val;
+	return 0;
 }
 
 /**

