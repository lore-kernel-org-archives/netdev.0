From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/15] igb: When GbE link up, wait for Remote receiver status condition
Date: Wed, 24 Feb 2016 18:14:53 -0800
Message-ID: <1456366502-132841-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Takuma Ueba <t.ueba11@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20522 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759194AbcBYC0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 21:26:00 -0500
In-Reply-To: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index af46fcf..1aa0180 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4357,6 +4357,7 @@ static void igb_watchdog_task(struct work_struct *work)
 	u32 link;
 	int i;
 	u32 connsw;
+	u16 phy_data, retry_count = 20;
 
 	link = igb_has_link(adapter);
 
@@ -4435,6 +4436,25 @@ static void igb_watchdog_task(struct work_struct *work)
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
