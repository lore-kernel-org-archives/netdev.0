From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 1/7] net: ethernet: ti: cpsw: fix bad register access in probe error path
Date: Wed, 16 Nov 2016 15:35:10 +0100
Message-ID: <1479306916-27673-2-git-send-email-johan@kernel.org>
References: <1479306916-27673-1-git-send-email-johan@kernel.org>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34325 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753537AbcKPOfc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:35:32 -0500
In-Reply-To: <1479306916-27673-1-git-send-email-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure to resume the platform device to enable clocks before
accessing the CPSW registers in the probe error path (e.g. for deferred
probe).

Unhandled fault: external abort on non-linefetch (0x1008) at 0xd0872d08
...
[<c04fabcc>] (cpsw_ale_control_set) from [<c04fb8b4>] (cpsw_ale_destroy+0x2c/0x44)
[<c04fb8b4>] (cpsw_ale_destroy) from [<c04fea58>] (cpsw_probe+0xbd0/0x10c4)
[<c04fea58>] (cpsw_probe) from [<c047b2a0>] (platform_drv_probe+0x5c/0xc0)

Note that in the unlikely event of a runtime-resume failure, we'll leak
the ale struct.

Fixes: df828598a755 ("netdev: driver: ethernet: Add TI CPSW driver")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/ti/cpsw.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c6cff3d2ff05..5bc5e6189661 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2818,7 +2818,12 @@ static int cpsw_probe(struct platform_device *pdev)
 	return 0;
 
 clean_ale_ret:
-	cpsw_ale_destroy(cpsw->ale);
+	if (pm_runtime_get_sync(&pdev->dev) < 0) {
+		pm_runtime_put_noidle(&pdev->dev);
+	} else {
+		cpsw_ale_destroy(cpsw->ale);
+		pm_runtime_put_sync(&pdev->dev);
+	}
 clean_dma_ret:
 	cpdma_ctlr_destroy(cpsw->dma);
 clean_runtime_disable_ret:
-- 
2.7.3
