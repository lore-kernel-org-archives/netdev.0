From: Samuel Williams <sam8641@gmail.com>
Subject: [PATCH] sky2: detect and prevent kernel panic from a possible faulty hardware
Date: Sat, 27 Jul 2013 15:35:54 -0500
Message-ID: <1374957354-10142-1-git-send-email-sam8641@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Samuel Williams <sam8641@gmail.com>
To: mlindner@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A possible faulty hardware might interrupt with a status of 0xffffffff which
may kernel panic if sky2 driver tries to handle it. Detecting this problem
may avoid kernel panic.

Signed-off-by: Samuel Williams <sam8641@gmail.com>
---
 drivers/net/ethernet/marvell/sky2.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index e09a8c6..43fe2f3 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -3049,8 +3049,17 @@ static int sky2_poll(struct napi_struct *napi, int work_limit)
 	int work_done = 0;
 	u16 idx;
 
-	if (unlikely(status & Y2_IS_ERROR))
+	if (unlikely(status & Y2_IS_ERROR)) {
+		if (status == 0xFFFFFFFF) {
+			dev_err(&hw->pdev->dev,
+				"fatal hardware inturrupt error\n");
+			napi_complete(napi);
+			napi_disable(&hw->napi);
+			return 0;
+		}
 		sky2_err_intr(hw, status);
+	}
+
 
 	if (status & Y2_IS_IRQ_PHY1)
 		sky2_phy_intr(hw, 0);
-- 
1.7.10.4
