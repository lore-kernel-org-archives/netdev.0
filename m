From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 10/15] igb: change how we handle alternate mac
	addresses
Date: Mon, 05 Oct 2009 09:34:25 -0700
Message-ID: <20091005163424.32487.97223.stgit@localhost.localdomain>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:53335
	"EHLO QMTA13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753646AbZJEQgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 12:36:35 -0400
In-Reply-To: <20091005163058.32487.10125.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch allows us to treat the alternate mac address as though it is the
physical address on the adapter.  This is accomplished by letting the
alt_mac_address function to only fail on an NVM error.  If no errors occur
and the alternate mac address is not present then RAR0 is read as the
default mac address.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |   13 +++++++++++--
 drivers/net/igb/e1000_hw.h    |    2 ++
 drivers/net/igb/e1000_mac.c   |   17 +++++++++--------
 3 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index e07f66c..45063c2 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1152,9 +1152,18 @@ static s32 igb_read_mac_addr_82575(struct e1000_hw *hw)
 {
 	s32 ret_val = 0;
 
-	if (igb_check_alt_mac_addr(hw))
-		ret_val = igb_read_mac_addr(hw);
+	/*
+	 * If there's an alternate MAC address place it in RAR0
+	 * so that it will override the Si installed default perm
+	 * address.
+	 */
+	ret_val = igb_check_alt_mac_addr(hw);
+	if (ret_val)
+		goto out;
+
+	ret_val = igb_read_mac_addr(hw);
 
+out:
 	return ret_val;
 }
 
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 4e7850d..fad7cf5 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -54,6 +54,8 @@ struct e1000_hw;
 #define E1000_FUNC_0     0
 #define E1000_FUNC_1     1
 
+#define E1000_ALT_MAC_ADDRESS_OFFSET_LAN1   3
+
 enum e1000_mac_type {
 	e1000_undefined = 0,
 	e1000_82575,
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 986aa90..4969a5b 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -185,13 +185,12 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 	}
 
 	if (nvm_alt_mac_addr_offset == 0xFFFF) {
-		ret_val = -(E1000_NOT_IMPLEMENTED);
+		/* There is no Alternate MAC Address */
 		goto out;
 	}
 
 	if (hw->bus.func == E1000_FUNC_1)
-		nvm_alt_mac_addr_offset += ETH_ALEN/sizeof(u16);
-
+		nvm_alt_mac_addr_offset += E1000_ALT_MAC_ADDRESS_OFFSET_LAN1;
 	for (i = 0; i < ETH_ALEN; i += 2) {
 		offset = nvm_alt_mac_addr_offset + (i >> 1);
 		ret_val = hw->nvm.ops.read(hw, offset, 1, &nvm_data);
@@ -206,14 +205,16 @@ s32 igb_check_alt_mac_addr(struct e1000_hw *hw)
 
 	/* if multicast bit is set, the alternate address will not be used */
 	if (alt_mac_addr[0] & 0x01) {
-		ret_val = -(E1000_NOT_IMPLEMENTED);
+		hw_dbg("Ignoring Alternate Mac Address with MC bit set\n");
 		goto out;
 	}
 
-	for (i = 0; i < ETH_ALEN; i++)
-		hw->mac.addr[i] = hw->mac.perm_addr[i] = alt_mac_addr[i];
-
-	hw->mac.ops.rar_set(hw, hw->mac.perm_addr, 0);
+	/*
+	 * We have a valid alternate MAC address, and we want to treat it the
+	 * same as the normal permanent MAC address stored by the HW into the
+	 * RAR. Do this by mapping this address into RAR0.
+	 */
+	hw->mac.ops.rar_set(hw, alt_mac_addr, 0);
 
 out:
 	return ret_val;

