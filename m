From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] e1000e: refactor PHY ID detection workaround
Date: Wed, 02 Dec 2009 19:02:43 -0800
Message-ID: <20091203030242.2604.63835.stgit@localhost.localdomain>
References: <20091203030213.2604.86948.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:53814 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753757AbZLCDDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 22:03:12 -0500
In-Reply-To: <20091203030213.2604.86948.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The workaround that detects the correct PHY ID when an initial read of the
PHY ID registers returns an invalid one should retry up to ten times with
a small delay between attempts using a single PHY address and then repeat
using the remaining possible PHY addresses.  Do this instead of trying each
possible PHY address repeating that up to 100 times.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/hw.h  |    2 +-
 drivers/net/e1000e/phy.c |   26 ++++++++++++++++----------
 2 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 41609d5..a7d08da 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -219,7 +219,7 @@ enum e1e_registers {
 	E1000_HICR      = 0x08F00, /* Host Interface Control */
 };
 
-/* RSS registers */
+#define E1000_MAX_PHY_ADDR		4
 
 /* IGP01E1000 Specific Registers */
 #define IGP01E1000_PHY_PORT_CONFIG	0x10 /* Port Config */
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 0c69649..67a7188 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -2197,28 +2197,34 @@ enum e1000_phy_type e1000e_get_phy_type_from_id(u32 phy_id)
 s32 e1000e_determine_phy_address(struct e1000_hw *hw)
 {
 	s32 ret_val = -E1000_ERR_PHY_TYPE;
-	u32 phy_addr= 0;
-	u32 i = 0;
+	u32 phy_addr = 0;
+	u32 i;
 	enum e1000_phy_type phy_type = e1000_phy_unknown;
 
-	do {
-		for (phy_addr = 0; phy_addr < 4; phy_addr++) {
-			hw->phy.addr = phy_addr;
+	hw->phy.id = phy_type;
+
+	for (phy_addr = 0; phy_addr < E1000_MAX_PHY_ADDR; phy_addr++) {
+		hw->phy.addr = phy_addr;
+		i = 0;
+
+		do {
 			e1000e_get_phy_id(hw);
 			phy_type = e1000e_get_phy_type_from_id(hw->phy.id);
 
-			/* 
+			/*
 			 * If phy_type is valid, break - we found our
 			 * PHY address
 			 */
 			if (phy_type  != e1000_phy_unknown) {
 				ret_val = 0;
-				break;
+				goto out;
 			}
-		}
-		i++;
-	} while ((ret_val != 0) && (i < 100));
+			msleep(1);
+			i++;
+		} while (i < 10);
+	}
 
+out:
 	return ret_val;
 }
 

