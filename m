From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net 3/9] net: hns3: Fix for DEFAULT_DV when dev doesn't support DCB
Date: Wed, 20 Sep 2017 18:52:52 +0800
Message-ID: <1505904778-53217-4-git-send-email-linyunsheng@huawei.com>
References: <1505904778-53217-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505904778-53217-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When ae_dev doesn't support DCB, DEFAULT_DV must be set to
a lower value, otherwise the buffer allocation process will
fail.
This patch fix it by setting it to 30K bytes.

Fixes: 46a3df9f9718 ("net: hns3: Add HNS3 Acceleration Engine & Compatibility Layer Support")
Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h  | 1 +
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 6 +++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
index c2b613b..30e2ad5 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
@@ -688,6 +688,7 @@ struct hclge_reset_tqp_queue {
 #define HCLGE_DEFAULT_TX_BUF		0x4000	 /* 16k  bytes */
 #define HCLGE_TOTAL_PKT_BUF		0x108000 /* 1.03125M bytes */
 #define HCLGE_DEFAULT_DV		0xA000	 /* 40k byte */
+#define HCLGE_DEFAULT_NON_DCB_DV	0x7800	/* 30K byte */
 
 #define HCLGE_TYPE_CRQ			0
 #define HCLGE_TYPE_CSQ			1
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index c515b84..1876418 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -1444,7 +1444,11 @@ static bool  hclge_is_rx_buf_ok(struct hclge_dev *hdev, u32 rx_all)
 	tc_num = hclge_get_tc_num(hdev);
 	pfc_enable_num = hclge_get_pfc_enalbe_num(hdev);
 
-	shared_buf_min = 2 * hdev->mps + HCLGE_DEFAULT_DV;
+	if (hnae3_dev_dcb_supported(hdev))
+		shared_buf_min = 2 * hdev->mps + HCLGE_DEFAULT_DV;
+	else
+		shared_buf_min = 2 * hdev->mps + HCLGE_DEFAULT_NON_DCB_DV;
+
 	shared_buf_tc = pfc_enable_num * hdev->mps +
 			(tc_num - pfc_enable_num) * hdev->mps / 2 +
 			hdev->mps;
-- 
1.9.1
