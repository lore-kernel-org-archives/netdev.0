From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 1/6] qede: Don't try removing unconfigured vlans
Date: Wed, 27 Jul 2016 14:45:19 +0300
Message-ID: <1469619924-12806-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1469619924-12806-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:59984 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753245AbcG0Lpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 07:45:35 -0400
In-Reply-To: <1469619924-12806-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As part of ndo_vlan_rx_kill_vid() implementation,
qede is requesting firmware to remove the vlan filter.
This currently happens even if the vlan wasn't previously
added [In case device ran out of vlan credits].

For PFs this doesn't cause any issues as the firmware
would simply ignore the removal request. But for VFs their
parent PF is holding an accounting of the configured vlans,
and such a request would cause the PF to fail the VF's
removal request.

Simply fix this for both PFs & VFs and don't remove filters
that were not previously added.

Fixes: 7c1bfcad9f3c8 ("qede: Add vlan filtering offload support")
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index f8e11f9..8fe3cc1 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2050,10 +2050,13 @@ static int qede_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
 	}
 
 	/* Remove vlan */
-	rc = qede_set_ucast_rx_vlan(edev, QED_FILTER_XCAST_TYPE_DEL, vid);
-	if (rc) {
-		DP_ERR(edev, "Failed to remove VLAN %d\n", vid);
-		return -EINVAL;
+	if (vlan->configured) {
+		rc = qede_set_ucast_rx_vlan(edev, QED_FILTER_XCAST_TYPE_DEL,
+					    vid);
+		if (rc) {
+			DP_ERR(edev, "Failed to remove VLAN %d\n", vid);
+			return -EINVAL;
+		}
 	}
 
 	qede_del_vlan_from_list(edev, vlan);
-- 
1.9.3
