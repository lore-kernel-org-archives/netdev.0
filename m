From: Zhangfei Gao <zhangfei.gao@linaro.org>
Subject: [PATCH v1] net: phy: resume phydev when going to RESUMING
Date: Wed, 14 May 2014 09:31:38 +0800
Message-ID: <1400031098-19072-1-git-send-email-zhangfei.gao@linaro.org>
Cc: netdev@vger.kernel.org, Zhangfei Gao <zhangfei.gao@linaro.org>,
	Jiancheng Xue <xuejiancheng@huawei.com>
To: sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
	davem@davemloft.net, sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:43121 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbaENBbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 21:31:50 -0400
Received: by mail-pa0-f42.google.com with SMTP id rd3so970832pab.29
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 18:31:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"With commit be9dad1f9f26604fb ("net: phy: suspend phydev when going
to HALTED"), an unused PHY device will be put in a low-power mode
using BMCR_PDOWN. Some Ethernet drivers might be calling phy_start()
and phy_stop() from ndo_open and ndo_close() respectively, while
calling phy_connect() and phy_disconnect() from probe and remove.
In such a case, the PHY will be powered down during the phy_stop()
call, but will fail to be powered up in phy_start().
This patch fixes the following scenario."

Signed-off-by: Jiancheng Xue <xuejiancheng@huawei.com>
Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
---
 drivers/net/phy/phy.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 1b6d09a..be5d52e 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -715,7 +715,7 @@ void phy_state_machine(struct work_struct *work)
 	struct delayed_work *dwork = to_delayed_work(work);
 	struct phy_device *phydev =
 			container_of(dwork, struct phy_device, state_queue);
-	int needs_aneg = 0, do_suspend = 0;
+	int needs_aneg = 0, do_suspend = 0, do_resume = 0;
 	int err = 0;
 
 	mutex_lock(&phydev->lock);
@@ -865,6 +865,8 @@ void phy_state_machine(struct work_struct *work)
 			}
 			phydev->adjust_link(phydev->attached_dev);
 		}
+
+		do_resume = 1;
 		break;
 	}
 
@@ -876,6 +878,9 @@ void phy_state_machine(struct work_struct *work)
 	if (do_suspend)
 		phy_suspend(phydev);
 
+	if (do_resume)
+		phy_resume(phydev);
+
 	if (err < 0)
 		phy_error(phydev);
 
-- 
1.7.9.5
