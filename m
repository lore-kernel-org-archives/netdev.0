From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 3/6] atl1: read MAC address from register
Date: Wed, 14 Feb 2007 20:14:55 -0600
Message-ID: <20070215021455.GD9753@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	xiong.huang@atheros.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf16aec.mail.bellsouth.net ([205.152.59.64]:60049 "EHLO
	imf16aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964842AbXBOCO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 21:14:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Cliburn <jacliburn@bellsouth.net>

On some Asus motherboards containing the L1 NIC, the MAC address is
written by the BIOS directly to the MAC register during POST, and is
not stored in eeprom.  If we don't succeed in fetching the MAC address
from eeprom or spi, try reading it directly from the MAC register.
Suggested by Xiong Huang.

And do some cleanup while we've got the hood up...

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
Signed-off-by: Chris Snook <csnook@redhat.com>
---

 drivers/net/atl1/atl1_hw.c |   35 ++++++++++++++++++++---------------
 1 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/drivers/net/atl1/atl1_hw.c b/drivers/net/atl1/atl1_hw.c
index e28707a..314dbaa 100644
--- a/drivers/net/atl1/atl1_hw.c
+++ b/drivers/net/atl1/atl1_hw.c
@@ -243,14 +243,8 @@ static int atl1_get_permanent_address(struct atl1_hw *hw)
 			i += 4;
 		}
 
-/*
- * The following 2 lines are the Attansic originals.  Saving for posterity.
- *		*(u32 *) & eth_addr[2] = LONGSWAP(addr[0]);
- *		*(u16 *) & eth_addr[0] = SHORTSWAP(*(u16 *) & addr[1]);
- */
-		*(u32 *) & eth_addr[2] = swab32(addr[0]);
-		*(u16 *) & eth_addr[0] = swab16(*(u16 *) & addr[1]);
-
+		*(u32 *) &eth_addr[2] = swab32(addr[0]);
+		*(u16 *) &eth_addr[0] = swab16(*(u16 *) &addr[1]);
 		if (is_valid_ether_addr(eth_addr)) {
 			memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
 			return 0;
@@ -281,17 +275,28 @@ static int atl1_get_permanent_address(struct atl1_hw *hw)
 		i += 4;
 	}
 
-/*
- * The following 2 lines are the Attansic originals.  Saving for posterity.
- *	*(u32 *) & eth_addr[2] = LONGSWAP(addr[0]);
- *	*(u16 *) & eth_addr[0] = SHORTSWAP(*(u16 *) & addr[1]);
- */
-	*(u32 *) & eth_addr[2] = swab32(addr[0]);
-	*(u16 *) & eth_addr[0] = swab16(*(u16 *) & addr[1]);
+	*(u32 *) &eth_addr[2] = swab32(addr[0]);
+	*(u16 *) &eth_addr[0] = swab16(*(u16 *) &addr[1]);
 	if (is_valid_ether_addr(eth_addr)) {
 		memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
 		return 0;
 	}
+
+	/*
+	 * On some motherboards, the MAC address is written by the
+	 * BIOS directly to the MAC register during POST, and is
+	 * not stored in eeprom.  If all else thus far has failed
+	 * to fetch the permanent MAC address, try reading it directly.
+	 */
+	addr[0] = ioread32(hw->hw_addr + REG_MAC_STA_ADDR);
+	addr[1] = ioread16(hw->hw_addr + (REG_MAC_STA_ADDR + 4));
+	*(u32 *) &eth_addr[2] = swab32(addr[0]);
+	*(u16 *) &eth_addr[0] = swab16(*(u16 *) &addr[1]);
+	if (is_valid_ether_addr(eth_addr)) {
+		memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
+		return 0;
+	}
+
 	return 1;
 }
 
