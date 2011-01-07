From: jeffrey.t.kirsher@intel.com
Subject: [net-next 04/12] e1000e: use either_crc_le() rather than re-write it
Date: Thu,  6 Jan 2011 16:29:51 -0800
Message-ID: <1294360199-9860-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gosp@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:23661 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753863Ab1AGAar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 19:30:47 -0500
To: davem@davemloft.net
In-Reply-To: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

For the 82579 jumbo frame workaround, there is no need to re-write the CRC
calculation functionality already found in the kernel's ether_crc_le().

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/e1000.h   |    1 +
 drivers/net/e1000e/ich8lan.c |   19 +------------------
 2 files changed, 2 insertions(+), 18 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 2c913b8..4b3802a 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -38,6 +38,7 @@
 #include <linux/netdevice.h>
 #include <linux/pci.h>
 #include <linux/pci-aspm.h>
+#include <linux/crc32.h>
 
 #include "hw.h"
 
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 902e493..5328a292 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -1395,22 +1395,6 @@ void e1000_copy_rx_addrs_to_phy_ich8lan(struct e1000_hw *hw)
 	}
 }
 
-static u32 e1000_calc_rx_da_crc(u8 mac[])
-{
-	u32 poly = 0xEDB88320;	/* Polynomial for 802.3 CRC calculation */
-	u32 i, j, mask, crc;
-
-	crc = 0xffffffff;
-	for (i = 0; i < 6; i++) {
-		crc = crc ^ mac[i];
-		for (j = 8; j > 0; j--) {
-			mask = (crc & 1) * (-1);
-			crc = (crc >> 1) ^ (poly & mask);
-		}
-	}
-	return ~crc;
-}
-
 /**
  *  e1000_lv_jumbo_workaround_ich8lan - required for jumbo frame operation
  *  with 82579 PHY
@@ -1453,8 +1437,7 @@ s32 e1000_lv_jumbo_workaround_ich8lan(struct e1000_hw *hw, bool enable)
 			mac_addr[4] = (addr_high & 0xFF);
 			mac_addr[5] = ((addr_high >> 8) & 0xFF);
 
-			ew32(PCH_RAICC(i),
-					e1000_calc_rx_da_crc(mac_addr));
+			ew32(PCH_RAICC(i), ~ether_crc_le(ETH_ALEN, mac_addr));
 		}
 
 		/* Write Rx addresses to the PHY */
-- 
1.7.3.4

