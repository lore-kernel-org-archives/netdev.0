From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH v3 net-next 09/10] net: hns3: Setting for fc_mode and dcb enable flag in TM module
Date: Wed, 27 Sep 2017 09:45:31 +0800
Message-ID: <1506476732-128130-10-git-send-email-linyunsheng@huawei.com>
References: <1506476732-128130-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:7037 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033094AbdI0BqG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 21:46:06 -0400
In-Reply-To: <1506476732-128130-1-git-send-email-linyunsheng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the DCB feature is supported, fc_mode and dcb enable flag
must be set according to the DCB parameter.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c  | 34 +++++++++++++++++++---
 1 file changed, 30 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
index 8295684..359ee67 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
@@ -486,7 +486,11 @@ static void hclge_tm_tc_info_init(struct hclge_dev *hdev)
 		hdev->tm_info.prio_tc[i] =
 			(i >= hdev->tm_info.num_tc) ? 0 : i;
 
-	hdev->flag &= ~HCLGE_FLAG_DCB_ENABLE;
+	/* DCB is enabled if we have more than 1 TC */
+	if (hdev->tm_info.num_tc > 1)
+		hdev->flag |= HCLGE_FLAG_DCB_ENABLE;
+	else
+		hdev->flag &= ~HCLGE_FLAG_DCB_ENABLE;
 }
 
 static void hclge_tm_pg_info_init(struct hclge_dev *hdev)
@@ -512,6 +516,24 @@ static void hclge_tm_pg_info_init(struct hclge_dev *hdev)
 	}
 }
 
+static void hclge_pfc_info_init(struct hclge_dev *hdev)
+{
+	if (!(hdev->flag & HCLGE_FLAG_DCB_ENABLE)) {
+		if (hdev->fc_mode_last_time == HCLGE_FC_PFC)
+			dev_warn(&hdev->pdev->dev,
+				 "DCB is disable, but last mode is FC_PFC\n");
+
+		hdev->tm_info.fc_mode = hdev->fc_mode_last_time;
+	} else if (hdev->tm_info.fc_mode != HCLGE_FC_PFC) {
+		/* fc_mode_last_time record the last fc_mode when
+		 * DCB is enabled, so that fc_mode can be set to
+		 * the correct value when DCB is disabled.
+		 */
+		hdev->fc_mode_last_time = hdev->tm_info.fc_mode;
+		hdev->tm_info.fc_mode = HCLGE_FC_PFC;
+	}
+}
+
 static int hclge_tm_schd_info_init(struct hclge_dev *hdev)
 {
 	if ((hdev->tx_sch_mode != HCLGE_FLAG_TC_BASE_SCH_MODE) &&
@@ -524,8 +546,7 @@ static int hclge_tm_schd_info_init(struct hclge_dev *hdev)
 
 	hclge_tm_vport_info_update(hdev);
 
-	hdev->tm_info.fc_mode = HCLGE_FC_NONE;
-	hdev->fc_mode_last_time = hdev->tm_info.fc_mode;
+	hclge_pfc_info_init(hdev);
 
 	return 0;
 }
@@ -1158,8 +1179,13 @@ int hclge_tm_init_hw(struct hclge_dev *hdev)
 
 int hclge_tm_schd_init(struct hclge_dev *hdev)
 {
-	int ret = hclge_tm_schd_info_init(hdev);
+	int ret;
+
+	/* fc_mode is HCLGE_FC_FULL on reset */
+	hdev->tm_info.fc_mode = HCLGE_FC_FULL;
+	hdev->fc_mode_last_time = hdev->tm_info.fc_mode;
 
+	ret = hclge_tm_schd_info_init(hdev);
 	if (ret)
 		return ret;
 
-- 
1.9.1
