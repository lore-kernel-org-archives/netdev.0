From: Zhangfei Gao <zhangfei.gao@linaro.org>
Subject: [PATCH] net: phy: resume phydev when PHY_RESUMING
Date: Tue, 13 May 2014 17:23:18 +0800
Message-ID: <1399972998-21772-1-git-send-email-zhangfei.gao@linaro.org>
Cc: netdev@vger.kernel.org, Zhangfei Gao <zhangfei.gao@linaro.org>,
	Jiancheng Xue <xuejiancheng@huawei.com>
To: sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:56374 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559AbaEMJXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 05:23:31 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so62110pad.16
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 02:23:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit be9dad1f9f26604fb suspend phydev when going to HALTED.
However not to resume phydev when going to RESUMING.
BMCR_PDOWN remains set "ifconfig eth0 down" -> "ifconfig eth0 up".
Unless phy_attach_direct is called in open function.

Fix the issue via phy_resume in PHY_RESUMING

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
