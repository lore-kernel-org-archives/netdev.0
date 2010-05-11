From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 10/12] e1000e: move settting of flow control
	refresh timer to link setup code
Date: Mon, 10 May 2010 18:02:12 -0700
Message-ID: <20100511010210.30827.6899.stgit@localhost.localdomain>
References: <20100511005801.30827.50808.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:43878 "EHLO
	qmta06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757406Ab0EKBCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 21:02:30 -0400
In-Reply-To: <20100511005801.30827.50808.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The flow control refresh timer value needs to be saved off so that it can
be programmed into the approrpiate register when applicable but without a
reset, e.g. when changing flow control parameters via ethtool.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/hw.h      |    1 +
 drivers/net/e1000e/ich8lan.c |    2 ++
 drivers/net/e1000e/netdev.c  |    5 +----
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 287ee95..fa314b4 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -901,6 +901,7 @@ struct e1000_fc_info {
 	u32 high_water;          /* Flow control high-water mark */
 	u32 low_water;           /* Flow control low-water mark */
 	u16 pause_time;          /* Flow control pause timer */
+	u16 refresh_time;        /* Flow control refresh timer */
 	bool send_xon;           /* Flow control send XON */
 	bool strict_ieee;        /* Strict IEEE mode */
 	enum e1000_fc_mode current_mode; /* FC mode in effect */
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 8efe9a7..2b2cffc 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -2823,6 +2823,8 @@ static s32 e1000_setup_link_ich8lan(struct e1000_hw *hw)
 	ew32(FCTTV, hw->fc.pause_time);
 	if ((hw->phy.type == e1000_phy_82578) ||
 	    (hw->phy.type == e1000_phy_82577)) {
+		ew32(FCRTV_PCH, hw->fc.refresh_time);
+
 		ret_val = hw->phy.ops.write_reg(hw,
 		                             PHY_REG(BM_PORT_CTRL_PAGE, 27),
 		                             hw->fc.pause_time);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 16a03c5..d1f60c5 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3134,6 +3134,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 			fc->high_water = 0x5000;
 			fc->low_water  = 0x3000;
 		}
+		fc->refresh_time = 0x1000;
 	} else {
 		if ((adapter->flags & FLAG_HAS_ERT) &&
 		    (adapter->netdev->mtu > ETH_DATA_LEN))
@@ -3171,10 +3172,6 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	if (mac->ops.init_hw(hw))
 		e_err("Hardware Error\n");
 
-	/* additional part of the flow-control workaround above */
-	if (hw->mac.type == e1000_pchlan)
-		ew32(FCRTV_PCH, 0x1000);
-
 	e1000_update_mng_vlan(adapter);
 
 	/* Enable h/w to recognize an 802.1Q VLAN Ethernet packet */

