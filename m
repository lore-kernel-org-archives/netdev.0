From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/3] bnx2x: Prevent probe as early as possible
Date: Sun, 29 Mar 2015 10:05:01 +0300
Message-ID: <1427612701-13469-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1427612701-13469-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:50746 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751057AbbC2HGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 03:06:11 -0400
In-Reply-To: <1427612701-13469-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's possible that due to errors [either on PCI or on device itself]
registers reads would fail, returning all-Fs.

This adds a check as early as possible so that driver will not read junk
values and make incorrect probe decisions according to them; instead,
gracefully fail the probe.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 98dcb03..c29bc8e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11650,6 +11650,13 @@ static int bnx2x_get_hwinfo(struct bnx2x *bp)
 	u32 val = 0, val2 = 0;
 	int rc = 0;
 
+	/* Validate that chip access is feasible */
+	if (REG_RD(bp, MISC_REG_CHIP_NUM) == 0xffffffff) {
+		dev_err(&bp->pdev->dev,
+			"Chip read returns all Fs. Preventing probe from continuing\n");
+		return -EINVAL;
+	}
+
 	bnx2x_get_common_hwinfo(bp);
 
 	/*
-- 
1.9.3
