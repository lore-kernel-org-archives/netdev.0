From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 8/8] net: hns3: reimplemmentation of pkt buffer allocation
Date: Thu, 31 Aug 2017 21:39:09 +0800
Message-ID: <1504186749-8926-9-git-send-email-lipeng321@huawei.com>
References: <1504186749-8926-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504186749-8926-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current implemmentation of buffer allocation in SSU do not meet
the requirement to do the buffer reallocation. This patch fixs
that in order to support buffer reallocation between Mac and
PFC pause.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |  32 +-
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 368 +++++++++++----------
 .../ethernet/hisilicon/hns3/hns3pf/hclge_main.h    |   5 +-
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c  |  84 ++++-
 .../net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h  |   9 +
 5 files changed, 308 insertions(+), 190 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
index 5887418..26e8ca6 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h
@@ -141,7 +141,7 @@ enum hclge_opcode_type {
 
 	/* Packet buffer allocate command */
 	HCLGE_OPC_TX_BUFF_ALLOC		= 0x0901,
-	HCLGE_OPC_RX_PRIV_BUFF_ALLOC	= 0x0902,
+	HCLGE_OPC_RX_BUFF_ALLOC		= 0x0902,
 	HCLGE_OPC_RX_PRIV_WL_ALLOC	= 0x0903,
 	HCLGE_OPC_RX_COM_THRD_ALLOC	= 0x0904,
 	HCLGE_OPC_RX_COM_WL_ALLOC	= 0x0905,
@@ -264,14 +264,15 @@ struct hclge_ctrl_vector_chain {
 #define HCLGE_TC_NUM		8
 #define HCLGE_TC0_PRI_BUF_EN_B	15 /* Bit 15 indicate enable or not */
 #define HCLGE_BUF_UNIT_S	7  /* Buf size is united by 128 bytes */
-struct hclge_tx_buff_alloc {
-	__le16 tx_pkt_buff[HCLGE_TC_NUM];
-	u8 tx_buff_rsv[8];
+struct hclge_tx_buf_alloc {
+	__le16 buf[HCLGE_TC_NUM];
+	u8 rsv[8];
 };
 
-struct hclge_rx_priv_buff {
-	__le16 buf_num[HCLGE_TC_NUM];
-	u8 rsv[8];
+struct hclge_rx_buf_alloc {
+	__le16 priv_buf[HCLGE_TC_NUM];
+	__le16 shared_buf;
+	u8 rsv[6];
 };
 
 struct hclge_query_version {
@@ -308,19 +309,24 @@ struct hclge_tc_thrd {
 	u32 high;
 };
 
-struct hclge_priv_buf {
+struct hclge_rx_priv_buf {
 	struct hclge_waterline wl;	/* Waterline for low and high*/
 	u32 buf_size;	/* TC private buffer size */
-	u32 enable;	/* Enable TC private buffer or not */
 };
 
 #define HCLGE_MAX_TC_NUM	8
-struct hclge_shared_buf {
+struct hclge_rx_shared_buf {
 	struct hclge_waterline self;
 	struct hclge_tc_thrd tc_thrd[HCLGE_MAX_TC_NUM];
 	u32 buf_size;
 };
 
+struct hclge_pkt_buf_alloc {
+	u32 tx_buf_size[HCLGE_MAX_TC_NUM];
+	struct hclge_rx_priv_buf rx_buf[HCLGE_MAX_TC_NUM];
+	struct hclge_rx_shared_buf s_buf;
+};
+
 #define HCLGE_RX_COM_WL_EN_B	15
 struct hclge_rx_com_wl_buf {
 	__le16 high_wl;
@@ -707,9 +713,9 @@ struct hclge_reset_tqp_queue {
 	u8 rsv[20];
 };
 
-#define HCLGE_DEFAULT_TX_BUF		0x4000	 /* 16k  bytes */
-#define HCLGE_TOTAL_PKT_BUF		0x108000 /* 1.03125M bytes */
-#define HCLGE_DEFAULT_DV		0xA000	 /* 40k byte */
+#define HCLGE_DEFAULT_TX_BUF		0x4000	/* 16k  bytes */
+#define HCLGE_DEFAULT_DV		0xA000	/* 40k byte */
+#define HCLGE_DEFAULT_NON_DCB_DV	0x7800	/* 30K byte */
 
 #define HCLGE_TYPE_CRQ			0
 #define HCLGE_TYPE_CSQ			1
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index d0a30f5..61073c2 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -1094,8 +1094,18 @@ static int hclge_configure(struct hclge_dev *hdev)
 		hdev->tm_info.num_tc = 1;
 	}
 
+	/* non-DCB supported dev */
+	if (!hnae_get_bit(hdev->ae_dev->flag,
+			  HNAE_DEV_SUPPORT_DCB_B)) {
+		hdev->tc_cap = 1;
+		hdev->pfc_cap = 0;
+	} else {
+		hdev->tc_cap = hdev->tm_info.num_tc;
+		hdev->pfc_cap = hdev->tm_info.num_tc;
+	}
+
 	/* Currently not support uncontiuous tc */
-	for (i = 0; i < cfg.tc_num; i++)
+	for (i = 0; i < hdev->tc_cap; i++)
 		hnae_set_bit(hdev->hw_tc_map, i, 1);
 
 	if (!hdev->num_vmdq_vport && !hdev->num_req_vfs)
@@ -1344,45 +1354,32 @@ static int hclge_alloc_vport(struct hclge_dev *hdev)
 	return 0;
 }
 
-static int  hclge_cmd_alloc_tx_buff(struct hclge_dev *hdev, u16 buf_size)
+static int hclge_tx_buffer_alloc(struct hclge_dev *hdev,
+				 struct hclge_pkt_buf_alloc *buf_alloc)
 {
-/* TX buffer size is unit by 128 byte */
-#define HCLGE_BUF_SIZE_UNIT_SHIFT	7
-#define HCLGE_BUF_SIZE_UPDATE_EN_MSK	BIT(15)
-	struct hclge_tx_buff_alloc *req;
 	struct hclge_desc desc;
-	int ret;
+	struct hclge_tx_buf_alloc *req =
+		(struct hclge_tx_buf_alloc *)desc.data;
+	enum hclge_cmd_status status;
 	u8 i;
 
-	req = (struct hclge_tx_buff_alloc *)desc.data;
-
 	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_TX_BUFF_ALLOC, 0);
-	for (i = 0; i < HCLGE_TC_NUM; i++)
-		req->tx_pkt_buff[i] =
-			cpu_to_le16((buf_size >> HCLGE_BUF_SIZE_UNIT_SHIFT) |
-				     HCLGE_BUF_SIZE_UPDATE_EN_MSK);
+	for (i = 0; i < HCLGE_TC_NUM; i++) {
+		u32 buf_size = buf_alloc->tx_buf_size[i];
 
-	ret = hclge_cmd_send(&hdev->hw, &desc, 1);
-	if (ret) {
-		dev_err(&hdev->pdev->dev, "tx buffer alloc cmd failed %d.\n",
-			ret);
-		return ret;
+		req->buf[i] =
+			cpu_to_le16((buf_size >> HCLGE_BUF_UNIT_S) |
+				    1 << HCLGE_TC0_PRI_BUF_EN_B);
 	}
 
-	return 0;
-}
-
-static int hclge_tx_buffer_alloc(struct hclge_dev *hdev, u32 buf_size)
-{
-	int ret = hclge_cmd_alloc_tx_buff(hdev, buf_size);
+	status = hclge_cmd_send(&hdev->hw, &desc, 1);
 
-	if (ret) {
+	if (status) {
 		dev_err(&hdev->pdev->dev,
-			"tx buffer alloc failed %d\n", ret);
-		return ret;
+			"Allocat tx buff fail, ret = %d\n", status);
 	}
 
-	return 0;
+	return status;
 }
 
 static int hclge_get_tc_num(struct hclge_dev *hdev)
@@ -1407,15 +1404,16 @@ static int hclge_get_pfc_enalbe_num(struct hclge_dev *hdev)
 }
 
 /* Get the number of pfc enabled TCs, which have private buffer */
-static int hclge_get_pfc_priv_num(struct hclge_dev *hdev)
+static int hclge_get_pfc_priv_num(struct hclge_dev *hdev,
+				  struct hclge_pkt_buf_alloc *buf_alloc)
 {
-	struct hclge_priv_buf *priv;
+	struct hclge_rx_priv_buf *priv;
 	int i, cnt = 0;
 
 	for (i = 0; i < HCLGE_MAX_TC_NUM; i++) {
-		priv = &hdev->priv_buf[i];
+		priv = &buf_alloc->rx_buf[i];
 		if ((hdev->tm_info.hw_pfc_map & BIT(i)) &&
-		    priv->enable)
+		    priv->buf_size > 0)
 			cnt++;
 	}
 
@@ -1423,37 +1421,40 @@ static int hclge_get_pfc_priv_num(struct hclge_dev *hdev)
 }
 
 /* Get the number of pfc disabled TCs, which have private buffer */
-static int hclge_get_no_pfc_priv_num(struct hclge_dev *hdev)
+static int hclge_get_no_pfc_priv_num(struct hclge_dev *hdev,
+				     struct hclge_pkt_buf_alloc *buf_alloc)
 {
-	struct hclge_priv_buf *priv;
+	struct hclge_rx_priv_buf *priv;
 	int i, cnt = 0;
 
 	for (i = 0; i < HCLGE_MAX_TC_NUM; i++) {
-		priv = &hdev->priv_buf[i];
+		priv = &buf_alloc->rx_buf[i];
 		if (hdev->hw_tc_map & BIT(i) &&
 		    !(hdev->tm_info.hw_pfc_map & BIT(i)) &&
-		    priv->enable)
+		    priv->buf_size > 0)
 			cnt++;
 	}
 
 	return cnt;
 }
 
-static u32 hclge_get_rx_priv_buff_alloced(struct hclge_dev *hdev)
+static u32 hclge_get_rx_priv_buff_alloced(struct hclge_dev *hdev,
+					  struct hclge_pkt_buf_alloc *buf_alloc)
 {
-	struct hclge_priv_buf *priv;
+	struct hclge_rx_priv_buf *priv;
 	u32 rx_priv = 0;
 	int i;
 
 	for (i = 0; i < HCLGE_MAX_TC_NUM; i++) {
-		priv = &hdev->priv_buf[i];
-		if (priv->enable)
-			rx_priv += priv->buf_size;
+		priv = &buf_alloc->rx_buf[i];
+		rx_priv += priv->buf_size;
 	}
 	return rx_priv;
 }
 
-static bool  hclge_is_rx_buf_ok(struct hclge_dev *hdev, u32 rx_all)
+static bool  hclge_is_rx_buf_ok(struct hclge_dev *hdev,
+				struct hclge_pkt_buf_alloc *buf_alloc,
+				u32 rx_all)
 {
 	u32 shared_buf_min, shared_buf_tc, shared_std;
 	int tc_num, pfc_enable_num;
@@ -1464,52 +1465,85 @@ static bool  hclge_is_rx_buf_ok(struct hclge_dev *hdev, u32 rx_all)
 	tc_num = hclge_get_tc_num(hdev);
 	pfc_enable_num = hclge_get_pfc_enalbe_num(hdev);
 
-	shared_buf_min = 2 * hdev->mps + HCLGE_DEFAULT_DV;
+	if (hnae_get_bit(hdev->ae_dev->flag,
+			 HNAE_DEV_SUPPORT_DCB_B))
+		shared_buf_min = 2 * hdev->mps + HCLGE_DEFAULT_DV;
+	else
+		shared_buf_min = 2 * hdev->mps + HCLGE_DEFAULT_NON_DCB_DV;
+
 	shared_buf_tc = pfc_enable_num * hdev->mps +
 			(tc_num - pfc_enable_num) * hdev->mps / 2 +
 			hdev->mps;
 	shared_std = max_t(u32, shared_buf_min, shared_buf_tc);
 
-	rx_priv = hclge_get_rx_priv_buff_alloced(hdev);
-	if (rx_all <= rx_priv + shared_std)
+	rx_priv = hclge_get_rx_priv_buff_alloced(hdev, buf_alloc);
+	if (rx_all <= rx_priv + shared_std) {
+		dev_err(&hdev->pdev->dev,
+			"pkt buffer allocted failed, total:%u, rx_all:%u\n",
+			hdev->pkt_buf_size, rx_all);
 		return false;
+	}
 
 	shared_buf = rx_all - rx_priv;
-	hdev->s_buf.buf_size = shared_buf;
-	hdev->s_buf.self.high = shared_buf;
-	hdev->s_buf.self.low =  2 * hdev->mps;
-
+	buf_alloc->s_buf.buf_size = shared_buf;
+	buf_alloc->s_buf.self.high = shared_buf;
+	buf_alloc->s_buf.self.low =  2 * hdev->mps;
 	for (i = 0; i < HCLGE_MAX_TC_NUM; i++) {
 		if ((hdev->hw_tc_map & BIT(i)) &&
 		    (hdev->tm_info.hw_pfc_map & BIT(i))) {
-			hdev->s_buf.tc_thrd[i].low = hdev->mps;
-			hdev->s_buf.tc_thrd[i].high = 2 * hdev->mps;
+			buf_alloc->s_buf.tc_thrd[i].low = hdev->mps;
+			buf_alloc->s_buf.tc_thrd[i].high = 2 * hdev->mps;
 		} else {
-			hdev->s_buf.tc_thrd[i].low = 0;
-			hdev->s_buf.tc_thrd[i].high = hdev->mps;
+			buf_alloc->s_buf.tc_thrd[i].low = 0;
+			buf_alloc->s_buf.tc_thrd[i].high = hdev->mps;
 		}
 	}
 
 	return true;
 }
 
-/* hclge_rx_buffer_calc: calculate the rx private buffer size for all TCs
+/**
+ * hclge_buffer_calc: calculate the private buffer size for all TCs
  * @hdev: pointer to struct hclge_dev
  * @tx_size: the allocated tx buffer for all TCs
  * @return: 0: calculate sucessful, negative: fail
  */
-int hclge_rx_buffer_calc(struct hclge_dev *hdev, u32 tx_size)
+int hclge_buffer_calc(struct hclge_dev *hdev,
+		      struct hclge_pkt_buf_alloc *buf_alloc,
+		      u32 tx_size)
 {
-	u32 rx_all = hdev->pkt_buf_size - tx_size;
+	u32 rx_all = hdev->pkt_buf_size;
 	int no_pfc_priv_num, pfc_priv_num;
-	struct hclge_priv_buf *priv;
+	struct hclge_rx_priv_buf *priv;
 	int i;
 
-	/* step 1, try to alloc private buffer for all enabled tc */
+	/* alloc tx buffer for all enabled tc */
+	for (i = 0; i < HCLGE_MAX_TC_NUM; i++) {
+		if (rx_all < tx_size)
+			return -ENOMEM;
+
+		if (hdev->hw_tc_map & BIT(i)) {
+			buf_alloc->tx_buf_size[i] = tx_size;
+			rx_all -= tx_size;
+		} else {
+			buf_alloc->tx_buf_size[i] = 0;
+		}
+	}
+
+	/* If pfc is not supported, rx private
+	 * buffer is not allocated.
+	 */
+	if (hdev->pfc_cap == 0) {
+		if (!hclge_is_rx_buf_ok(hdev, buf_alloc, rx_all))
+			return -ENOMEM;
+
+		return 0;
+	}
+
+	/* Step 1, try to alloc private buffer for all enabled tc */
 	for (i = 0; i < HCLGE_MAX_TC_NUM; i++) {
-		priv = &hdev->priv_buf[i];
+		priv = &buf_alloc->rx_buf[i];
 		if (hdev->hw_tc_map & BIT(i)) {
-			priv->enable = 1;
 			if (hdev->tm_info.hw_pfc_map & BIT(i)) {
 				priv->wl.low = hdev->mps;
 				priv->wl.high = priv->wl.low + hdev->mps;
@@ -1520,128 +1554,133 @@ int hclge_rx_buffer_calc(struct hclge_dev *hdev, u32 tx_size)
 				priv->wl.high = 2 * hdev->mps;
 				priv->buf_size = priv->wl.high;
 			}
+		} else {
+			priv->wl.low = 0;
+			priv->wl.high = 0;
+			priv->buf_size = 0;
 		}
 	}
 
-	if (hclge_is_rx_buf_ok(hdev, rx_all))
+	if (hclge_is_rx_buf_ok(hdev, buf_alloc, rx_all))
 		return 0;
 
-	/* step 2, try to decrease the buffer size of
+	/**
+	 * Step 2, try to decrease the buffer size of
 	 * no pfc TC's private buffer
-	 */
+	 **/
 	for (i = 0; i < HCLGE_MAX_TC_NUM; i++) {
-		priv = &hdev->priv_buf[i];
-
-		if (hdev->hw_tc_map & BIT(i))
-			priv->enable = 1;
-
-		if (hdev->tm_info.hw_pfc_map & BIT(i)) {
-			priv->wl.low = 128;
-			priv->wl.high = priv->wl.low + hdev->mps;
-			priv->buf_size = priv->wl.high + HCLGE_DEFAULT_DV;
+		priv = &buf_alloc->rx_buf[i];
+		if (hdev->hw_tc_map & BIT(i)) {
+			if (hdev->tm_info.hw_pfc_map & BIT(i)) {
+				priv->wl.low = 128;
+				priv->wl.high = priv->wl.low + hdev->mps;
+				priv->buf_size = priv->wl.high
+					+ HCLGE_DEFAULT_DV;
+			} else {
+				priv->wl.low = 0;
+				priv->wl.high = hdev->mps;
+				priv->buf_size = priv->wl.high;
+			}
 		} else {
 			priv->wl.low = 0;
-			priv->wl.high = hdev->mps;
-			priv->buf_size = priv->wl.high;
+			priv->wl.high = 0;
+			priv->buf_size = 0;
 		}
 	}
 
-	if (hclge_is_rx_buf_ok(hdev, rx_all))
+	if (hclge_is_rx_buf_ok(hdev, buf_alloc, rx_all))
 		return 0;
 
-	/* step 3, try to reduce the number of pfc disabled TCs,
+	/**
+	 * Step 3, try to reduce the number of pfc disabled TCs,
 	 * which have private buffer
-	 */
-	/* get the total no pfc enable TC number, which have private buffer */
-	no_pfc_priv_num = hclge_get_no_pfc_priv_num(hdev);
+	 **/
 
-	/* let the last to be cleared first */
+	/* Get the total no pfc enable TC number, which have private buffer */
+	no_pfc_priv_num = hclge_get_no_pfc_priv_num(hdev, buf_alloc);
+	/* Let the last to be cleared first */
 	for (i = HCLGE_MAX_TC_NUM - 1; i >= 0; i--) {
-		priv = &hdev->priv_buf[i];
-
+		priv = &buf_alloc->rx_buf[i];
 		if (hdev->hw_tc_map & BIT(i) &&
 		    !(hdev->tm_info.hw_pfc_map & BIT(i))) {
 			/* Clear the no pfc TC private buffer */
 			priv->wl.low = 0;
 			priv->wl.high = 0;
 			priv->buf_size = 0;
-			priv->enable = 0;
 			no_pfc_priv_num--;
 		}
-
-		if (hclge_is_rx_buf_ok(hdev, rx_all) ||
+		if (hclge_is_rx_buf_ok(hdev, buf_alloc, rx_all) ||
 		    no_pfc_priv_num == 0)
 			break;
 	}
-
-	if (hclge_is_rx_buf_ok(hdev, rx_all))
+	if (hclge_is_rx_buf_ok(hdev, buf_alloc, rx_all))
 		return 0;
 
-	/* step 4, try to reduce the number of pfc enabled TCs
+	/**
+	 * Step 4, try to reduce the number of pfc enabled TCs
 	 * which have private buffer.
-	 */
-	pfc_priv_num = hclge_get_pfc_priv_num(hdev);
-
-	/* let the last to be cleared first */
+	 **/
+	pfc_priv_num = hclge_get_pfc_priv_num(hdev, buf_alloc);
+	/* Let the last to be cleared first */
 	for (i = HCLGE_MAX_TC_NUM - 1; i >= 0; i--) {
-		priv = &hdev->priv_buf[i];
-
+		priv = &buf_alloc->rx_buf[i];
 		if (hdev->hw_tc_map & BIT(i) &&
 		    hdev->tm_info.hw_pfc_map & BIT(i)) {
 			/* Reduce the number of pfc TC with private buffer */
 			priv->wl.low = 0;
-			priv->enable = 0;
 			priv->wl.high = 0;
 			priv->buf_size = 0;
 			pfc_priv_num--;
 		}
-
-		if (hclge_is_rx_buf_ok(hdev, rx_all) ||
+		if (hclge_is_rx_buf_ok(hdev, buf_alloc, rx_all) ||
 		    pfc_priv_num == 0)
 			break;
 	}
-	if (hclge_is_rx_buf_ok(hdev, rx_all))
+	if (hclge_is_rx_buf_ok(hdev, buf_alloc, rx_all))
 		return 0;
 
 	return -ENOMEM;
 }
 
-static int hclge_rx_priv_buf_alloc(struct hclge_dev *hdev)
+static int hclge_rx_buf_alloc(struct hclge_dev *hdev,
+			      struct hclge_pkt_buf_alloc *buf_alloc)
 {
-	struct hclge_rx_priv_buff *req;
 	struct hclge_desc desc;
+	struct hclge_rx_buf_alloc *req =
+			(struct hclge_rx_buf_alloc *)desc.data;
+	struct hclge_rx_shared_buf *s_buf = &buf_alloc->s_buf;
 	int ret;
 	int i;
 
-	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_RX_PRIV_BUFF_ALLOC, false);
-	req = (struct hclge_rx_priv_buff *)desc.data;
+	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_RX_BUFF_ALLOC, false);
 
 	/* Alloc private buffer TCs */
 	for (i = 0; i < HCLGE_MAX_TC_NUM; i++) {
-		struct hclge_priv_buf *priv = &hdev->priv_buf[i];
+		struct hclge_rx_priv_buf *priv = &buf_alloc->rx_buf[i];
 
-		req->buf_num[i] =
+		req->priv_buf[i] =
 			cpu_to_le16(priv->buf_size >> HCLGE_BUF_UNIT_S);
-		req->buf_num[i] |=
-			cpu_to_le16(true << HCLGE_TC0_PRI_BUF_EN_B);
+		req->priv_buf[i] |=
+			cpu_to_le16(1 << HCLGE_TC0_PRI_BUF_EN_B);
 	}
 
+	req->shared_buf = cpu_to_le16(s_buf->buf_size >> HCLGE_BUF_UNIT_S);
+	req->shared_buf |= cpu_to_le16(1 << HCLGE_TC0_PRI_BUF_EN_B);
+
 	ret = hclge_cmd_send(&hdev->hw, &desc, 1);
-	if (ret) {
+	if (ret)
 		dev_err(&hdev->pdev->dev,
-			"rx private buffer alloc cmd failed %d\n", ret);
-		return ret;
-	}
+			"Set rx private buffer fail, status = %d\n", ret);
 
-	return 0;
+	return ret;
 }
 
 #define HCLGE_PRIV_ENABLE(a) ((a) > 0 ? 1 : 0)
-
-static int hclge_rx_priv_wl_config(struct hclge_dev *hdev)
+static int hclge_rx_priv_wl_config(struct hclge_dev *hdev,
+				   struct hclge_pkt_buf_alloc *buf_alloc)
 {
 	struct hclge_rx_priv_wl_buf *req;
-	struct hclge_priv_buf *priv;
+	struct hclge_rx_priv_buf *priv;
 	struct hclge_desc desc[2];
 	int i, j;
 	int ret;
@@ -1658,7 +1697,9 @@ static int hclge_rx_priv_wl_config(struct hclge_dev *hdev)
 			desc[i].flag &= ~cpu_to_le16(HCLGE_CMD_FLAG_NEXT);
 
 		for (j = 0; j < HCLGE_TC_NUM_ONE_DESC; j++) {
-			priv = &hdev->priv_buf[i * HCLGE_TC_NUM_ONE_DESC + j];
+			u32 idx = i * HCLGE_TC_NUM_ONE_DESC + j;
+
+			priv = &buf_alloc->rx_buf[idx];
 			req->tc_wl[j].high =
 				cpu_to_le16(priv->wl.high >> HCLGE_BUF_UNIT_S);
 			req->tc_wl[j].high |=
@@ -1674,18 +1715,17 @@ static int hclge_rx_priv_wl_config(struct hclge_dev *hdev)
 
 	/* Send 2 descriptor at one time */
 	ret = hclge_cmd_send(&hdev->hw, desc, 2);
-	if (ret) {
+	if (ret)
 		dev_err(&hdev->pdev->dev,
-			"rx private waterline config cmd failed %d\n",
-			ret);
-		return ret;
-	}
-	return 0;
+			"Set rx private waterline fail, status %d\n", ret);
+
+	return ret;
 }
 
-static int hclge_common_thrd_config(struct hclge_dev *hdev)
+static int hclge_common_thrd_config(struct hclge_dev *hdev,
+				    struct hclge_pkt_buf_alloc *buf_alloc)
 {
-	struct hclge_shared_buf *s_buf = &hdev->s_buf;
+	struct hclge_rx_shared_buf *s_buf = &buf_alloc->s_buf;
 	struct hclge_rx_com_thrd *req;
 	struct hclge_desc desc[2];
 	struct hclge_tc_thrd *tc;
@@ -1721,104 +1761,100 @@ static int hclge_common_thrd_config(struct hclge_dev *hdev)
 
 	/* Send 2 descriptors at one time */
 	ret = hclge_cmd_send(&hdev->hw, desc, 2);
-	if (ret) {
+	if (ret)
 		dev_err(&hdev->pdev->dev,
-			"common threshold config cmd failed %d\n", ret);
-		return ret;
-	}
-	return 0;
+			"Set rx private waterline fail, status %d\n", ret);
+
+	return ret;
 }
 
-static int hclge_common_wl_config(struct hclge_dev *hdev)
+static int hclge_common_wl_config(struct hclge_dev *hdev,
+				  struct hclge_pkt_buf_alloc *buf_alloc)
 {
-	struct hclge_shared_buf *buf = &hdev->s_buf;
-	struct hclge_rx_com_wl *req;
 	struct hclge_desc desc;
+	struct hclge_rx_com_wl *req = (struct hclge_rx_com_wl *)desc.data;
+	struct hclge_rx_shared_buf *s_buf = &buf_alloc->s_buf;
 	int ret;
 
 	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_RX_COM_WL_ALLOC, false);
 
-	req = (struct hclge_rx_com_wl *)desc.data;
-	req->com_wl.high = cpu_to_le16(buf->self.high >> HCLGE_BUF_UNIT_S);
+	req->com_wl.high = cpu_to_le16(s_buf->self.high >> HCLGE_BUF_UNIT_S);
 	req->com_wl.high |=
-		cpu_to_le16(HCLGE_PRIV_ENABLE(buf->self.high) <<
+		cpu_to_le16(HCLGE_PRIV_ENABLE(s_buf->self.high) <<
 			    HCLGE_RX_PRIV_EN_B);
 
-	req->com_wl.low = cpu_to_le16(buf->self.low >> HCLGE_BUF_UNIT_S);
+	req->com_wl.low = cpu_to_le16(s_buf->self.low >> HCLGE_BUF_UNIT_S);
 	req->com_wl.low |=
-		cpu_to_le16(HCLGE_PRIV_ENABLE(buf->self.low) <<
+		cpu_to_le16(HCLGE_PRIV_ENABLE(s_buf->self.low) <<
 			    HCLGE_RX_PRIV_EN_B);
 
 	ret = hclge_cmd_send(&hdev->hw, &desc, 1);
-	if (ret) {
+	if (ret)
 		dev_err(&hdev->pdev->dev,
-			"common waterline config cmd failed %d\n", ret);
-		return ret;
-	}
+			"Set rx private waterline fail, status %d\n", ret);
 
-	return 0;
+	return ret;
 }
 
 int hclge_buffer_alloc(struct hclge_dev *hdev)
 {
+	struct hclge_pkt_buf_alloc *pkt_buf;
 	u32 tx_buf_size = HCLGE_DEFAULT_TX_BUF;
 	int ret;
 
-	hdev->priv_buf = devm_kmalloc_array(&hdev->pdev->dev, HCLGE_MAX_TC_NUM,
-					    sizeof(struct hclge_priv_buf),
-					    GFP_KERNEL | __GFP_ZERO);
-	if (!hdev->priv_buf)
+	pkt_buf = kzalloc(sizeof(*pkt_buf), GFP_KERNEL);
+	if (!pkt_buf)
 		return -ENOMEM;
 
-	ret = hclge_tx_buffer_alloc(hdev, tx_buf_size);
+	ret = hclge_buffer_calc(hdev, pkt_buf, tx_buf_size);
 	if (ret) {
 		dev_err(&hdev->pdev->dev,
-			"could not alloc tx buffers %d\n", ret);
-		return ret;
+			"Calculate Rx buffer error ret =%d.\n", ret);
+		goto err;
 	}
 
-	ret = hclge_rx_buffer_calc(hdev, tx_buf_size);
+	ret = hclge_tx_buffer_alloc(hdev, pkt_buf);
 	if (ret) {
 		dev_err(&hdev->pdev->dev,
-			"could not calc rx priv buffer size for all TCs %d\n",
-			ret);
-		return ret;
+			"Allocate Tx buffer fail, ret =%d\n", ret);
+		goto err;
 	}
 
-	ret = hclge_rx_priv_buf_alloc(hdev);
+	ret = hclge_rx_buf_alloc(hdev, pkt_buf);
 	if (ret) {
-		dev_err(&hdev->pdev->dev, "could not alloc rx priv buffer %d\n",
-			ret);
-		return ret;
+		dev_err(&hdev->pdev->dev,
+			"Private buffer config fail, ret = %d\n", ret);
+		goto err;
 	}
 
 	if (hnae_get_bit(hdev->ae_dev->flag,
 			 HNAE_DEV_SUPPORT_DCB_B)) {
-		ret = hclge_rx_priv_wl_config(hdev);
+		ret = hclge_rx_priv_wl_config(hdev, pkt_buf);
 		if (ret) {
 			dev_err(&hdev->pdev->dev,
-				"could not configure rx private waterline %d\n",
+				"Private waterline config fail, ret = %d\n",
 				ret);
-			return ret;
+			goto err;
 		}
 
-		ret = hclge_common_thrd_config(hdev);
+		ret = hclge_common_thrd_config(hdev, pkt_buf);
 		if (ret) {
 			dev_err(&hdev->pdev->dev,
-				"could not configure common threshold %d\n",
+				"Common threshold config fail, ret = %d\n",
 				ret);
-			return ret;
+			goto err;
 		}
 	}
 
-	ret = hclge_common_wl_config(hdev);
+	ret = hclge_common_wl_config(hdev, pkt_buf);
 	if (ret) {
 		dev_err(&hdev->pdev->dev,
-			"could not configure common waterline %d\n", ret);
-		return ret;
+			"Common waterline config fail, ret = %d\n", ret);
 	}
 
-	return 0;
+err:
+	kfree(pkt_buf);
+	return ret;
 }
 
 static int hclge_init_roce_base_info(struct hclge_vport *vport)
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
index 0905ae5..4bdec1f 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.h
@@ -430,6 +430,9 @@ struct hclge_dev {
 #define HCLGE_FLAG_TC_BASE_SCH_MODE		1
 #define HCLGE_FLAG_VNET_BASE_SCH_MODE		2
 	u8 tx_sch_mode;
+	u8 pg_cap;
+	u8 tc_cap;
+	u8 pfc_cap;
 
 	u8 default_up;
 	struct hclge_tm_info tm_info;
@@ -472,8 +475,6 @@ struct hclge_dev {
 
 	u32 pkt_buf_size; /* Total pf buf size for tx/rx */
 	u32 mps; /* Max packet size */
-	struct hclge_priv_buf *priv_buf;
-	struct hclge_shared_buf s_buf;
 
 	enum hclge_mta_dmac_sel_type mta_mac_sel_type;
 	bool enable_mta; /* Mutilcast filter enable */
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
index 1c577d2..59b0cfb 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.c
@@ -364,7 +364,8 @@ static int hclge_tm_qs_schd_mode_cfg(struct hclge_dev *hdev, u16 qs_id)
 	return hclge_cmd_send(&hdev->hw, &desc, 1);
 }
 
-static int hclge_tm_qs_bp_cfg(struct hclge_dev *hdev, u8 tc)
+static int hclge_tm_qs_bp_cfg(struct hclge_dev *hdev,
+			      u8 tc, u8 grp_id, u32 bit_map)
 {
 	struct hclge_bp_to_qs_map_cmd *bp_to_qs_map_cmd;
 	struct hclge_desc desc;
@@ -375,9 +376,8 @@ static int hclge_tm_qs_bp_cfg(struct hclge_dev *hdev, u8 tc)
 	bp_to_qs_map_cmd = (struct hclge_bp_to_qs_map_cmd *)desc.data;
 
 	bp_to_qs_map_cmd->tc_id = tc;
-
-	/* Qset and tc is one by one mapping */
-	bp_to_qs_map_cmd->qs_bit_map = cpu_to_le32(1 << tc);
+	bp_to_qs_map_cmd->qs_group_id = grp_id;
+	bp_to_qs_map_cmd->qs_bit_map = cpu_to_le32(bit_map);
 
 	return hclge_cmd_send(&hdev->hw, &desc, 1);
 }
@@ -836,6 +836,10 @@ static int hclge_tm_map_cfg(struct hclge_dev *hdev)
 {
 	int ret;
 
+	ret = hclge_up_to_tc_map(hdev);
+	if (ret)
+		return ret;
+
 	ret = hclge_tm_pg_to_pri_map(hdev);
 	if (ret)
 		return ret;
@@ -966,23 +970,85 @@ static int hclge_tm_schd_setup_hw(struct hclge_dev *hdev)
 	return hclge_tm_schd_mode_hw(hdev);
 }
 
+/* Each Tc has a 1024 queue sets to backpress, it divides to
+ * 32 group, each group contains 32 queue sets, which can be
+ * represented by u32 bitmap.
+ */
+static int hclge_bp_setup_hw(struct hclge_dev *hdev, u8 tc)
+{
+	struct hclge_vport *vport = hdev->vport;
+	u32 i, k, qs_bitmap;
+	int ret;
+
+	for (i = 0; i < HCLGE_BP_GRP_NUM; i++) {
+		qs_bitmap = 0;
+
+		for (k = 0; k < hdev->num_alloc_vport; k++) {
+			u16 qs_id = vport->qs_offset + tc;
+			u8 grp, sub_grp;
+
+			grp = hnae_get_field(qs_id, HCLGE_BP_GRP_ID_M,
+					     HCLGE_BP_GRP_ID_S);
+			sub_grp = hnae_get_field(qs_id, HCLGE_BP_SUB_GRP_ID_M,
+						 HCLGE_BP_SUB_GRP_ID_S);
+			if (i == grp)
+				qs_bitmap |= (1 << sub_grp);
+
+			vport++;
+		}
+
+		ret = hclge_tm_qs_bp_cfg(hdev, tc, i, qs_bitmap);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
 int hclge_pause_setup_hw(struct hclge_dev *hdev)
 {
-	bool en = hdev->tm_info.fc_mode != HCLGE_FC_PFC;
 	int ret;
 	u8 i;
 
-	ret = hclge_mac_pause_en_cfg(hdev, en, en);
-	if (ret)
+	if (hdev->tm_info.fc_mode != HCLGE_FC_PFC) {
+		bool tx_en, rx_en;
+
+		switch (hdev->tm_info.fc_mode) {
+		case HCLGE_FC_NONE:
+			tx_en = false;
+			rx_en = false;
+			break;
+		case HCLGE_FC_RX_PAUSE:
+			tx_en = false;
+			rx_en = true;
+			break;
+		case HCLGE_FC_TX_PAUSE:
+			tx_en = true;
+			rx_en = false;
+			break;
+		case HCLGE_FC_FULL:
+			tx_en = true;
+			rx_en = true;
+			break;
+		default:
+			tx_en = true;
+			rx_en = true;
+		}
+		ret = hclge_mac_pause_en_cfg(hdev, tx_en, rx_en);
 		return ret;
+	}
+
+	/* Only DCB-supported port supports qset back pressure setting */
+	if (!hnae_get_bit(hdev->ae_dev->flag, HNAE_DEV_SUPPORT_DCB_B))
+		return 0;
 
 	for (i = 0; i < hdev->tm_info.num_tc; i++) {
-		ret = hclge_tm_qs_bp_cfg(hdev, i);
+		ret = hclge_bp_setup_hw(hdev, i);
 		if (ret)
 			return ret;
 	}
 
-	return hclge_up_to_tc_map(hdev);
+	return 0;
 }
 
 int hclge_tm_init_hw(struct hclge_dev *hdev)
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h
index 7e67337..dbaa3b5 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_tm.h
@@ -86,6 +86,15 @@ struct hclge_pg_shapping_cmd {
 	__le32 pg_shapping_para;
 };
 
+struct hclge_port_shapping_cmd {
+	__le32 port_shapping_para;
+};
+
+#define HCLGE_BP_GRP_NUM		32
+#define HCLGE_BP_SUB_GRP_ID_S		0
+#define HCLGE_BP_SUB_GRP_ID_M		GENMASK(4, 0)
+#define HCLGE_BP_GRP_ID_S		5
+#define HCLGE_BP_GRP_ID_M		GENMASK(9, 5)
 struct hclge_bp_to_qs_map_cmd {
 	u8 tc_id;
 	u8 rsvd[2];
-- 
1.9.1
