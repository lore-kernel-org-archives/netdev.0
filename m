From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net 4/9] net: hns3: Fix for not setting rx private buffer size to zero
Date: Wed, 20 Sep 2017 18:52:53 +0800
Message-ID: <1505904778-53217-5-git-send-email-linyunsheng@huawei.com>
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

When rx private buffer is disabled, there may be some case that
the rx private buffer is not set to zero, which may cause buffer
allocation process to fail.
This patch fixes this problem by setting priv->enable to 0 and
priv->buf_size to zero when rx private buffer is disabled.

Fixes: 46a3df9f9718 ("net: hns3: Add HNS3 Acceleration Engine & Compatibility Layer Support")
Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index 1876418..bf3179a 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -1504,6 +1504,11 @@ int hclge_rx_buffer_calc(struct hclge_dev *hdev, u32 tx_size)
 				priv->wl.high = 2 * hdev->mps;
 				priv->buf_size = priv->wl.high;
 			}
+		} else {
+			priv->enable = 0;
+			priv->wl.low = 0;
+			priv->wl.high = 0;
+			priv->buf_size = 0;
 		}
 	}
 
@@ -1516,8 +1521,15 @@ int hclge_rx_buffer_calc(struct hclge_dev *hdev, u32 tx_size)
 	for (i = 0; i < HCLGE_MAX_TC_NUM; i++) {
 		priv = &hdev->priv_buf[i];
 
-		if (hdev->hw_tc_map & BIT(i))
-			priv->enable = 1;
+		priv->enable = 0;
+		priv->wl.low = 0;
+		priv->wl.high = 0;
+		priv->buf_size = 0;
+
+		if (!(hdev->hw_tc_map & BIT(i)))
+			continue;
+
+		priv->enable = 1;
 
 		if (hdev->tm_info.hw_pfc_map & BIT(i)) {
 			priv->wl.low = 128;
-- 
1.9.1
