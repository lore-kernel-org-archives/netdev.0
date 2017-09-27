From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH v3 net-next 01/10] net: hns3: Support for dynamically assigning tx buffer to TC
Date: Wed, 27 Sep 2017 09:45:23 +0800
Message-ID: <1506476732-128130-2-git-send-email-linyunsheng@huawei.com>
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
Received: from szxga04-in.huawei.com ([45.249.212.190]:7007 "EHLO
        szxga04-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968882AbdI0BqA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 21:46:00 -0400
In-Reply-To: <1506476732-128130-1-git-send-email-linyunsheng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add support of dynamically assigning tx buffer to
TC when the TC is enabled.
It will save buffer for rx direction to avoid packet loss.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
V2:
	Fix for not defining variables in local loop.

V1:
	Initial submit.
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |  1 +
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 64 ++++++++++++++++++----
 2 files changed, 55 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
index 758cf39..a81c6cb 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
@@ -311,6 +311,7 @@ struct hclge_tc_thrd {
 struct hclge_priv_buf {
 	struct hclge_waterline wl;	/* Waterline for low and high*/
 	u32 buf_size;	/* TC private buffer size */
+	u32 tx_buf_size;
 	u32 enable;	/* Enable TC private buffer or not */
 };
 
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index d27618b..02da3d5 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -1324,7 +1324,7 @@ static int hclge_alloc_vport(struct hclge_dev *hdev)
 	return 0;
 }
 
-static int  hclge_cmd_alloc_tx_buff(struct hclge_dev *hdev, u16 buf_size)
+static int  hclge_cmd_alloc_tx_buff(struct hclge_dev *hdev)
 {
 /* TX buffer size is unit by 128 byte */
 #define HCLGE_BUF_SIZE_UNIT_SHIFT	7
@@ -1337,10 +1337,13 @@ static int  hclge_cmd_alloc_tx_buff(struct hclge_dev *hdev, u16 buf_size)
 	req = (struct hclge_tx_buff_alloc *)desc.data;
 
 	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_TX_BUFF_ALLOC, 0);
-	for (i = 0; i < HCLGE_TC_NUM; i++)
+	for (i = 0; i < HCLGE_TC_NUM; i++) {
+		u32 buf_size = hdev->priv_buf[i].tx_buf_size;
+
 		req->tx_pkt_buff[i] =
 			cpu_to_le16((buf_size >> HCLGE_BUF_SIZE_UNIT_SHIFT) |
 				     HCLGE_BUF_SIZE_UPDATE_EN_MSK);
+	}
 
 	ret = hclge_cmd_send(&hdev->hw, &desc, 1);
 	if (ret) {
@@ -1352,9 +1355,9 @@ static int  hclge_cmd_alloc_tx_buff(struct hclge_dev *hdev, u16 buf_size)
 	return 0;
 }
 
-static int hclge_tx_buffer_alloc(struct hclge_dev *hdev, u32 buf_size)
+static int hclge_tx_buffer_alloc(struct hclge_dev *hdev)
 {
-	int ret = hclge_cmd_alloc_tx_buff(hdev, buf_size);
+	int ret = hclge_cmd_alloc_tx_buff(hdev);
 
 	if (ret) {
 		dev_err(&hdev->pdev->dev,
@@ -1433,6 +1436,16 @@ static u32 hclge_get_rx_priv_buff_alloced(struct hclge_dev *hdev)
 	return rx_priv;
 }
 
+static u32 hclge_get_tx_buff_alloced(struct hclge_dev *hdev)
+{
+	u32 i, total_tx_size = 0;
+
+	for (i = 0; i < HCLGE_MAX_TC_NUM; i++)
+		total_tx_size += hdev->priv_buf[i].tx_buf_size;
+
+	return total_tx_size;
+}
+
 static bool  hclge_is_rx_buf_ok(struct hclge_dev *hdev, u32 rx_all)
 {
 	u32 shared_buf_min, shared_buf_tc, shared_std;
@@ -1477,18 +1490,43 @@ static bool  hclge_is_rx_buf_ok(struct hclge_dev *hdev, u32 rx_all)
 	return true;
 }
 
+static int hclge_tx_buffer_calc(struct hclge_dev *hdev)
+{
+	u32 i, total_size;
+
+	total_size = hdev->pkt_buf_size;
+
+	/* alloc tx buffer for all enabled tc */
+	for (i = 0; i < HCLGE_MAX_TC_NUM; i++) {
+		struct hclge_priv_buf *priv = &hdev->priv_buf[i];
+
+		if (total_size < HCLGE_DEFAULT_TX_BUF)
+			return -ENOMEM;
+
+		if (hdev->hw_tc_map & BIT(i))
+			priv->tx_buf_size = HCLGE_DEFAULT_TX_BUF;
+		else
+			priv->tx_buf_size = 0;
+
+		total_size -= priv->tx_buf_size;
+	}
+
+	return 0;
+}
+
 /* hclge_rx_buffer_calc: calculate the rx private buffer size for all TCs
  * @hdev: pointer to struct hclge_dev
- * @tx_size: the allocated tx buffer for all TCs
  * @return: 0: calculate sucessful, negative: fail
  */
-int hclge_rx_buffer_calc(struct hclge_dev *hdev, u32 tx_size)
+int hclge_rx_buffer_calc(struct hclge_dev *hdev)
 {
-	u32 rx_all = hdev->pkt_buf_size - tx_size;
+	u32 rx_all = hdev->pkt_buf_size;
 	int no_pfc_priv_num, pfc_priv_num;
 	struct hclge_priv_buf *priv;
 	int i;
 
+	rx_all -= hclge_get_tx_buff_alloced(hdev);
+
 	/* When DCB is not supported, rx private
 	 * buffer is not allocated.
 	 */
@@ -1771,7 +1809,6 @@ static int hclge_common_wl_config(struct hclge_dev *hdev)
 
 int hclge_buffer_alloc(struct hclge_dev *hdev)
 {
-	u32 tx_buf_size = HCLGE_DEFAULT_TX_BUF;
 	int ret;
 
 	hdev->priv_buf = devm_kmalloc_array(&hdev->pdev->dev, HCLGE_MAX_TC_NUM,
@@ -1780,14 +1817,21 @@ int hclge_buffer_alloc(struct hclge_dev *hdev)
 	if (!hdev->priv_buf)
 		return -ENOMEM;
 
-	ret = hclge_tx_buffer_alloc(hdev, tx_buf_size);
+	ret = hclge_tx_buffer_calc(hdev);
+	if (ret) {
+		dev_err(&hdev->pdev->dev,
+			"could not calc tx buffer size for all TCs %d\n", ret);
+		return ret;
+	}
+
+	ret = hclge_tx_buffer_alloc(hdev);
 	if (ret) {
 		dev_err(&hdev->pdev->dev,
 			"could not alloc tx buffers %d\n", ret);
 		return ret;
 	}
 
-	ret = hclge_rx_buffer_calc(hdev, tx_buf_size);
+	ret = hclge_rx_buffer_calc(hdev);
 	if (ret) {
 		dev_err(&hdev->pdev->dev,
 			"could not calc rx priv buffer size for all TCs %d\n",
-- 
1.9.1
