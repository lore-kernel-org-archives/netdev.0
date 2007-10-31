From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/4] e1000e: alternate MAC address support
Date: Wed, 31 Oct 2007 15:21:52 -0700
Message-ID: <20071031222152.17411.20977.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:29287 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753886AbXJaWZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 18:25:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bill Hayes <bill.hayes@hp.com>

Port alternate MAC address support from the sourceforge
e1000 driver to the upstream e1000e driver.

Signed-off-by: Bill Hayes <bill.hayes@hp.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/82571.c   |    4 ++++
 drivers/net/e1000e/defines.h |    1 +
 drivers/net/e1000e/hw.h      |    1 +
 drivers/net/e1000e/lib.c     |   39 +++++++++++++++++++++++++++++++++++++--
 4 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 14141a5..b6401ab 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -752,6 +752,10 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 	ew32(IMC, 0xffffffff);
 	icr = er32(ICR);
 
+	if (hw->mac.type == e1000_82571 &&
+		hw->dev_spec.e82571.alt_mac_addr_is_present)
+			e1000e_set_laa_state_82571(hw, true);
+
 	return 0;
 }
 
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index b32ed45..f2175ea 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -557,6 +557,7 @@
 #define NVM_INIT_3GIO_3            0x001A
 #define NVM_INIT_CONTROL3_PORT_A   0x0024
 #define NVM_CFG                    0x0012
+#define NVM_ALT_MAC_ADDR_PTR       0x0037
 #define NVM_CHECKSUM_REG           0x003F
 
 #define E1000_NVM_CFG_DONE_PORT_0  0x40000 /* MNG config cycle done */
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 6451578..1bb2052 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -816,6 +816,7 @@ struct e1000_bus_info {
 
 struct e1000_dev_spec_82571 {
 	bool laa_is_present;
+	bool alt_mac_addr_is_present;
 };
 
 struct e1000_shadow_ram {
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 0bdeca3..16f35fa 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -2059,9 +2059,44 @@ s32 e1000e_read_mac_addr(struct e1000_hw *hw)
 {
 	s32 ret_val;
 	u16 offset, nvm_data, i;
+	u16 mac_addr_offset = 0;
+
+	if (hw->mac.type == e1000_82571) {
+		/* Check for an alternate MAC address.  An alternate MAC
+		 * address can be setup by pre-boot software and must be
+		 * treated like a permanent address and must override the
+		 * actual permanent MAC address. */
+		ret_val = e1000_read_nvm(hw, NVM_ALT_MAC_ADDR_PTR, 1,
+						&mac_addr_offset);
+		if (ret_val) {
+			hw_dbg(hw, "NVM Read Error\n");
+			return ret_val;
+		}
+		if (mac_addr_offset == 0xFFFF)
+			mac_addr_offset = 0;
+
+		if (mac_addr_offset) {
+			if (hw->bus.func == E1000_FUNC_1)
+				mac_addr_offset += ETH_ALEN/sizeof(u16);
+
+			/* make sure we have a valid mac address here
+			 * before using it */
+			ret_val = e1000_read_nvm(hw, mac_addr_offset, 1,
+						 &nvm_data);
+			if (ret_val) {
+				hw_dbg(hw, "NVM Read Error\n");
+				return ret_val;
+			}
+			if (nvm_data & 0x0001)
+				mac_addr_offset = 0;
+		}
+
+		if (mac_addr_offset)
+			hw->dev_spec.e82571.alt_mac_addr_is_present = 1;
+	}
 
 	for (i = 0; i < ETH_ALEN; i += 2) {
-		offset = i >> 1;
+		offset = mac_addr_offset + (i >> 1);
 		ret_val = e1000_read_nvm(hw, offset, 1, &nvm_data);
 		if (ret_val) {
 			hw_dbg(hw, "NVM Read Error\n");
@@ -2072,7 +2107,7 @@ s32 e1000e_read_mac_addr(struct e1000_hw *hw)
 	}
 
 	/* Flip last bit of mac address if we're on second port */
-	if (hw->bus.func == E1000_FUNC_1)
+	if (!mac_addr_offset && hw->bus.func == E1000_FUNC_1)
 		hw->mac.perm_addr[5] ^= 1;
 
 	for (i = 0; i < ETH_ALEN; i++)
