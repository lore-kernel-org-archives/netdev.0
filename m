From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 02/13] igb: make serdes power down available for
	82575 in addition to 82576 parts
Date: Thu, 23 Jul 2009 21:07:40 -0700
Message-ID: <20090724040739.30709.14892.stgit@localhost.localdomain>
References: <20090724040700.30709.31473.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:47940
	"EHLO QMTA15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751053AbZGXEH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 00:07:56 -0400
In-Reply-To: <20090724040700.30709.31473.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There was a serdes power down workaround that was originally added for
82576 fiber.  However it has also been found that this workaround is needed
for serdes connections as well.  In addition it is also needed for 82575
serdes so we we need to remove the checks restricting it to 82576.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |    7 +------
 drivers/net/igb/e1000_82575.h |    5 +++++
 drivers/net/igb/e1000_mac.c   |   14 +++++++++++---
 3 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index bd3efdb..fa4a762 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -866,8 +866,7 @@ void igb_shutdown_fiber_serdes_link_82575(struct e1000_hw *hw)
 {
 	u32 reg;
 
-	if (hw->mac.type != e1000_82576 ||
-	    hw->phy.media_type != e1000_media_type_internal_serdes)
+	if (hw->phy.media_type != e1000_media_type_internal_serdes)
 		return;
 
 	/* if the management interface is not enabled, then power down */
@@ -1228,10 +1227,6 @@ out:
 static bool igb_sgmii_active_82575(struct e1000_hw *hw)
 {
 	struct e1000_dev_spec_82575 *dev_spec = &hw->dev_spec._82575;
-
-	if (hw->mac.type != e1000_82575 && hw->mac.type != e1000_82576)
-		return false;
-
 	return dev_spec->sgmii_active;
 }
 
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index 0f16aba..b674417 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -32,6 +32,11 @@ void igb_update_mc_addr_list(struct e1000_hw*, u8*, u32, u32, u32);
 extern void igb_shutdown_fiber_serdes_link_82575(struct e1000_hw *hw);
 extern void igb_rx_fifo_flush_82575(struct e1000_hw *hw);
 
+#define ID_LED_DEFAULT_82575_SERDES ((ID_LED_DEF1_DEF2 << 12) | \
+                                     (ID_LED_DEF1_DEF2 <<  8) | \
+                                     (ID_LED_DEF1_DEF2 <<  4) | \
+                                     (ID_LED_OFF1_ON2))
+
 #define E1000_RAR_ENTRIES_82575   16
 #define E1000_RAR_ENTRIES_82576   24
 
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 37706d9..34f1a37 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -1064,9 +1064,17 @@ static s32 igb_valid_led_default(struct e1000_hw *hw, u16 *data)
 		goto out;
 	}
 
-	if (*data == ID_LED_RESERVED_0000 || *data == ID_LED_RESERVED_FFFF)
-		*data = ID_LED_DEFAULT;
-
+	if (*data == ID_LED_RESERVED_0000 || *data == ID_LED_RESERVED_FFFF) {
+		switch(hw->phy.media_type) {
+		case e1000_media_type_internal_serdes:
+			*data = ID_LED_DEFAULT_82575_SERDES;
+			break;
+		case e1000_media_type_copper:
+		default:
+			*data = ID_LED_DEFAULT;
+			break;
+		}
+	}
 out:
 	return ret_val;
 }

