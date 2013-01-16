From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH 1/2] igb: display a warning message when SmartSpeed works
Date: Wed, 16 Jan 2013 11:21:47 +0900
Message-ID: <50F60EBB.4000800@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	tushar.n.dave@intel.com, e1000-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:37476 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756013Ab3APCVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 21:21:50 -0500
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4AA5D3EE0AE
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 11:21:49 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3505345DE58
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 11:21:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BF0545DE56
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 11:21:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A6671DB8047
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 11:21:49 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B44171DB8043
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 11:21:48 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current igb driver doesn't tell nothing when Link Speed is downgraded due to
SmartSpeed.  As a result, users suspect that there is something wrong with
NIC.  If the cause of it is SmartSpeed, there is no means to replace NIC. This
patch make igb notify users that SmartSpeed worked.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a0a31b5..71f9088 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3647,6 +3647,7 @@ static void igb_watchdog_task(struct work_struct *work)
 	                                           struct igb_adapter,
                                                    watchdog_task);
 	struct e1000_hw *hw = &adapter->hw;
+	struct e1000_phy_info *phy = &hw->phy;
 	struct net_device *netdev = adapter->netdev;
 	u32 link;
 	int i;
@@ -3675,6 +3676,12 @@ static void igb_watchdog_task(struct work_struct *work)
 			       (ctrl & E1000_CTRL_RFCE) ?  "RX" :
 			       (ctrl & E1000_CTRL_TFCE) ?  "TX" : "None");
 
+			/* check if SmartSpeed worked */
+			igb_check_downshift(hw);
+			if (phy->speed_downgraded)
+				netdev_warn(netdev, "Link Speed was "
+					"downgraded by SmartSpeed\n");
+
 			/* check for thermal sensor event */
 			if (igb_thermal_sensor_event(hw,
 			    E1000_THSTAT_LINK_THROTTLE)) {
