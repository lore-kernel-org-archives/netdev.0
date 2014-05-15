From: Zhangfei Gao <zhangfei.gao@linaro.org>
Subject: [PATCH v2] net: phy: resume phydev when going to RESUMING
Date: Thu, 15 May 2014 13:35:34 +0800
Message-ID: <1400132134-19490-1-git-send-email-zhangfei.gao@linaro.org>
Cc: netdev@vger.kernel.org, Zhangfei Gao <zhangfei.gao@linaro.org>,
	Jiancheng Xue <xuejiancheng@huawei.com>
To: sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
	davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
	joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:60161 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbaEOFgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 01:36:13 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so603774pab.20
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 22:36:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With commit be9dad1f9f26604fb ("net: phy: suspend phydev when going
to HALTED"), an unused PHY device will be put in a low-power mode
using BMCR_PDOWN. Some Ethernet drivers might be calling phy_start()
and phy_stop() from ndo_open and ndo_close() respectively, while
calling phy_connect() and phy_disconnect() from probe and remove.
In such a case, the PHY will be powered down during the phy_stop()
call, but will fail to be powered up in phy_start().
This patch fixes this scenario.

Signed-off-by: Jiancheng Xue <xuejiancheng@huawei.com>
Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
---
 drivers/net/phy/phy.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 1b6d09a..8bf6c3d 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -715,7 +715,7 @@ void phy_state_machine(struct work_struct *work)
 	struct delayed_work *dwork = to_delayed_work(work);
 	struct phy_device *phydev =
 			container_of(dwork, struct phy_device, state_queue);
-	int needs_aneg = 0, do_suspend = 0;
+	bool needs_aneg = false, do_suspend = false, do_resume = false;
 	int err = 0;
 
 	mutex_lock(&phydev->lock);
@@ -727,7 +727,7 @@ void phy_state_machine(struct work_struct *work)
 	case PHY_PENDING:
 		break;
 	case PHY_UP:
-		needs_aneg = 1;
+		needs_aneg = true;
 
 		phydev->link_timeout = PHY_AN_TIMEOUT;
 
@@ -757,7 +757,7 @@ void phy_state_machine(struct work_struct *work)
 			phydev->adjust_link(phydev->attached_dev);
 
 		} else if (0 == phydev->link_timeout--)
-			needs_aneg = 1;
+			needs_aneg = true;
 		break;
 	case PHY_NOLINK:
 		err = phy_read_status(phydev);
@@ -780,7 +780,7 @@ void phy_state_machine(struct work_struct *work)
 			netif_carrier_on(phydev->attached_dev);
 		} else {
 			if (0 == phydev->link_timeout--)
-				needs_aneg = 1;
+				needs_aneg = true;
 		}
 
 		phydev->adjust_link(phydev->attached_dev);
@@ -816,7 +816,7 @@ void phy_state_machine(struct work_struct *work)
 			phydev->link = 0;
 			netif_carrier_off(phydev->attached_dev);
 			phydev->adjust_link(phydev->attached_dev);
-			do_suspend = 1;
+			do_suspend = true;
 		}
 		break;
 	case PHY_RESUMING:
@@ -865,6 +865,7 @@ void phy_state_machine(struct work_struct *work)
 			}
 			phydev->adjust_link(phydev->attached_dev);
 		}
+		do_resume = true;
 		break;
 	}
 
@@ -872,9 +873,10 @@ void phy_state_machine(struct work_struct *work)
 
 	if (needs_aneg)
 		err = phy_start_aneg(phydev);
-
-	if (do_suspend)
+	else if (do_suspend)
 		phy_suspend(phydev);
+	else if (do_resume)
+		phy_resume(phydev);
 
 	if (err < 0)
 		phy_error(phydev);
-- 
1.7.9.5
