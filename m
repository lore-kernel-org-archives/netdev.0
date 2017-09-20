From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net 6/9] net: hns3: Fix for rx priv buf allocation when DCB is not supported
Date: Wed, 20 Sep 2017 18:52:55 +0800
Message-ID: <1505904778-53217-7-git-send-email-linyunsheng@huawei.com>
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

When hdev doesn't support DCB, rx private buffer is not allocated,
otherwise there is not enough buffer for rx shared buffer, causing
buffer allocation process to fail.
This patch fixes by checking the dcb capability in
hclge_rx_buffer_calc.

Fixes: 46a3df9f9718 ("net: hns3: Add HNS3 Acceleration Engine & Compatibility Layer Support")
Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index c08c41f..1e15ce1 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -1489,6 +1489,16 @@ int hclge_rx_buffer_calc(struct hclge_dev *hdev, u32 tx_size)
 	struct hclge_priv_buf *priv;
 	int i;
 
+	/* When DCB is not supported, rx private
+	 * buffer is not allocated.
+	 */
+	if (!hnae3_dev_dcb_supported(hdev)) {
+		if (!hclge_is_rx_buf_ok(hdev, rx_all))
+			return -ENOMEM;
+
+		return 0;
+	}
+
 	/* step 1, try to alloc private buffer for all enabled tc */
 	for (i = 0; i < HCLGE_MAX_TC_NUM; i++) {
 		priv = &hdev->priv_buf[i];
-- 
1.9.1
