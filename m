From: Takuma Ueba <t.ueba11@gmail.com>
Subject: [PATCH] igb: When GbE link up, wait for Remote receiver status condition.
Date: Wed, 30 Dec 2015 21:09:41 +0900
Message-ID: <1451477381-64480-1-git-send-email-t.ueba11@gmail.com>
Cc: Takuma Ueba <t.ueba11@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:32868 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754253AbbL3MKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 07:10:31 -0500
Received: by mail-pf0-f179.google.com with SMTP id q63so105521546pfb.0
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 04:10:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 drivers/net/ethernet/intel/igb/igb_main.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 31e5f39..bc1e83d 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4227,6 +4227,7 @@ static void igb_watchdog_task(struct work_struct *work)
 	u32 link;
 	int i;
 	u32 connsw;
+	u16 phy_data, retry_count = 20;
 
 	link = igb_has_link(adapter);
 
@@ -4305,6 +4306,25 @@ static void igb_watchdog_task(struct work_struct *work)
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
1.9.1
