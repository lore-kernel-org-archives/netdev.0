From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: Disallow SFP 1G modules in the SFP+ cages
	for 82598 and 82599
Date: Thu, 23 Apr 2009 14:31:37 -0700
Message-ID: <20090423213136.29824.81597.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:37086
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757398AbZDWVcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 17:32:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com>

82598 and 82599 do not support SFP 1G modules.  Instead of allowing the
driver to load, but never get link, rejecting the module and displaying
a useful message is more preferrable.  The framework for displaying the
failure message already exists, now we just need to detect and reject the
SFP modules.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_phy.c  |   22 +++++++++++++++++-----
 drivers/net/ixgbe/ixgbe_type.h |    1 +
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index f3258ec..2543c32 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -673,11 +673,22 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 				break;
 			}
 		}
-		if (hw->mac.type == ixgbe_mac_82598EB ||
-		    (hw->phy.sfp_type != ixgbe_sfp_type_sr &&
-		     hw->phy.sfp_type != ixgbe_sfp_type_lr &&
-		     hw->phy.sfp_type != ixgbe_sfp_type_srlr_core0 &&
-		     hw->phy.sfp_type != ixgbe_sfp_type_srlr_core1)) {
+
+		/* All DA cables are supported */
+		if (transmission_media & IXGBE_SFF_TWIN_AX_CAPABLE) {
+			status = 0;
+			goto out;
+		}
+
+		/* 1G SFP modules are not supported */
+		if (comp_codes_10g == 0) {
+			hw->phy.type = ixgbe_phy_sfp_unsupported;
+			status = IXGBE_ERR_SFP_NOT_SUPPORTED;
+			goto out;
+		}
+
+		/* Anything else 82598-based is supported */
+		if (hw->mac.type == ixgbe_mac_82598EB) {
 			status = 0;
 			goto out;
 		}
@@ -690,6 +701,7 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 				status = 0;
 			} else {
 				hw_dbg(hw, "SFP+ module not supported\n");
+				hw->phy.type = ixgbe_phy_sfp_unsupported;
 				status = IXGBE_ERR_SFP_NOT_SUPPORTED;
 			}
 		} else {
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index a3317d8..375f0d4 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1904,6 +1904,7 @@ enum ixgbe_phy_type {
 	ixgbe_phy_sfp_ftl,
 	ixgbe_phy_sfp_unknown,
 	ixgbe_phy_sfp_intel,
+	ixgbe_phy_sfp_unsupported,
 	ixgbe_phy_generic
 };
 

