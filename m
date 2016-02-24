From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/20] igb: When GbE link up, wait for Remote receiver status condition
Date: Tue, 23 Feb 2016 20:26:15 -0800
Message-ID: <1456287984-10459-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Takuma Ueba <t.ueba11@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51525 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757409AbcBXE0e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 23:26:34 -0500
In-Reply-To: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Takuma Ueba <t.ueba11@gmail.com>

I210 device IPv6 autoconf test sometimes fails,
because DAD NS for link-local is not transmitted.
This packet is silently dropped.
This problem is seen only GbE environment.

igb_watchdog_task link up detection continues to the following process.
The following cases are observed:
1.PHY 1000BASE-T Status Register Remote receiver status bit is NG.
(NG status becomes OK after about 200 - 700ms)
2.In this case, the transfer packet is silently dropped.

1000BASE-T Status register
[Expected]: 0x3800 or 0x7800
[problem occurred]: 0x2800 or 0x6800
Frequency of occurrence: approx 1/10 - 1/40 observed

In order to avoid this problem,
wait until 1000BASE-T Status register "Remote receiver status OK"

After applying this patch, at least 400 runs succeed with no problems.

Signed-off-by: Takuma Ueba <t.ueba11@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 0d501a8..0f7805c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4449,6 +4449,7 @@ static void igb_watchdog_task(struct work_struct *work)
 	u32 link;
 	int i;
 	u32 connsw;
+	u16 phy_data, retry_count = 20;
 
 	link = igb_has_link(adapter);
 
@@ -4527,6 +4528,25 @@ static void igb_watchdog_task(struct work_struct *work)
 				break;
 			}
 
+			if (adapter->link_speed != SPEED_1000)
+				goto no_wait;
+
+			/* wait for Remote receiver status OK */
+retry_read_status:
+			if (!igb_read_phy_reg(hw, PHY_1000T_STATUS,
+					      &phy_data)) {
+				if (!(phy_data & SR_1000T_REMOTE_RX_STATUS) &&
+				    retry_count) {
+					msleep(100);
+					retry_count--;
+					goto retry_read_status;
+				} else if (!retry_count) {
+					dev_err(&adapter->pdev->dev, "exceed max 2 second\n");
+				}
+			} else {
+				dev_err(&adapter->pdev->dev, "read 1000Base-T Status Reg\n");
+			}
+no_wait:
 			netif_carrier_on(netdev);
 
 			igb_ping_all_vfs(adapter);
-- 
2.5.0
