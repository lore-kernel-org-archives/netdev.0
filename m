From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net 5/9] net: hns3: Fix for rx_priv_buf_alloc not setting rx shared buffer
Date: Wed, 20 Sep 2017 18:52:54 +0800
Message-ID: <1505904778-53217-6-git-send-email-linyunsheng@huawei.com>
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

rx_priv_buf_alloc is used to tell hardware how much buffer is
used for rx direction, right now only the private buffer is
assigned.
For ae_dev that doesn't support DCB, private rx buffer is assigned
to zero, only shared rx buffer is used. So not setting the shared
rx buffer cause dropping of packet in SSU.

Fixes: 46a3df9f9718 ("net: hns3: Add HNS3 Acceleration Engine & Compatibility Layer Support")
Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h  | 3 ++-
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 4 ++++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
index 30e2ad5..758cf39 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
@@ -270,7 +270,8 @@ struct hclge_tx_buff_alloc {
 
 struct hclge_rx_priv_buff {
 	__le16 buf_num[HCLGE_TC_NUM];
-	u8 rsv[8];
+	__le16 shared_buf;
+	u8 rsv[6];
 };
 
 struct hclge_query_version {
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index bf3179a..c08c41f 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -1622,6 +1622,10 @@ static int hclge_rx_priv_buf_alloc(struct hclge_dev *hdev)
 			cpu_to_le16(true << HCLGE_TC0_PRI_BUF_EN_B);
 	}
 
+	req->shared_buf =
+		cpu_to_le16((hdev->s_buf.buf_size >> HCLGE_BUF_UNIT_S) |
+			    (1 << HCLGE_TC0_PRI_BUF_EN_B));
+
 	ret = hclge_cmd_send(&hdev->hw, &desc, 1);
 	if (ret) {
 		dev_err(&hdev->pdev->dev,
-- 
1.9.1
