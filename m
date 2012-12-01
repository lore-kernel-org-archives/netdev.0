From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/9] igb: Unset sigdetect for SERDES loopback on 82580 and i350
Date: Sat,  1 Dec 2012 03:53:34 -0800
Message-ID: <1354362817-26168-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1354362817-26168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21302 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035Ab2LALx7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2012 06:53:59 -0500
In-Reply-To: <1354362817-26168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch unsets the sigdetect bit for SERDES loopback tests on 82580 and
i350 parts.  The loopback test can fail on these parts without this
setting.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |  2 ++
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 14 ++++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index c15a481..17f1686 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -42,6 +42,8 @@
 
 struct igb_adapter;
 
+#define E1000_PCS_CFG_IGN_SD               1
+
 /* Interrupt defines */
 #define IGB_START_ITR                    648 /* ~6000 ints/sec */
 #define IGB_4K_ITR                       980
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index e2288b5..bfe9208 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1624,6 +1624,20 @@ static int igb_setup_loopback_test(struct igb_adapter *adapter)
 		reg &= ~E1000_CONNSW_ENRGSRC;
 		wr32(E1000_CONNSW, reg);
 
+		/* Unset sigdetect for SERDES loopback on
+		 * 82580 and i350 devices.
+		 */
+		switch (hw->mac.type) {
+		case e1000_82580:
+		case e1000_i350:
+			reg = rd32(E1000_PCS_CFG0);
+			reg |= E1000_PCS_CFG_IGN_SD;
+			wr32(E1000_PCS_CFG0, reg);
+			break;
+		default:
+			break;
+		}
+
 		/* Set PCS register for forced speed */
 		reg = rd32(E1000_PCS_LCTL);
 		reg &= ~E1000_PCS_LCTL_AN_ENABLE;     /* Disable Autoneg*/
-- 
1.7.11.7
