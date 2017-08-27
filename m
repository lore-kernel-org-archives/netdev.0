From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH net-next] net-next/hinic: fix comparison of a uint16_t type with -1
Date: Mon, 28 Aug 2017 01:35:30 +0800
Message-ID: <1503855330-84810-1-git-send-email-aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <zhaochen6@huawei.com>, <colin.king@canonical.com>,
        <dan.carpenter@oracle.com>,
        Aviad Krawczyk <aviad.krawczyk@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the search for index of constant buffer size

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c | 37 +-----------------------
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h  | 21 ++++++++++++++
 2 files changed, 22 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
index 09dec6d..79b5674 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
@@ -69,31 +69,6 @@ struct hinic_dev_cap {
 	u8      rsvd3[208];
 };
 
-struct rx_buf_sz {
-	int     idx;
-	size_t  sz;
-};
-
-static struct rx_buf_sz rx_buf_sz_table[] = {
-	{0, 32},
-	{1, 64},
-	{2, 96},
-	{3, 128},
-	{4, 192},
-	{5, 256},
-	{6, 384},
-	{7, 512},
-	{8, 768},
-	{9, 1024},
-	{10, 1536},
-	{11, 2048},
-	{12, 3072},
-	{13, 4096},
-	{14, 8192},
-	{15, 16384},
-	{-1, -1},
-};
-
 /**
  * get_capability - convert device capabilities to NIC capabilities
  * @hwdev: the HW device to set and convert device capabilities for
@@ -330,7 +305,6 @@ static int set_hw_ioctxt(struct hinic_hwdev *hwdev, unsigned int rq_depth,
 	struct hinic_cmd_hw_ioctxt hw_ioctxt;
 	struct pci_dev *pdev = hwif->pdev;
 	struct hinic_pfhwdev *pfhwdev;
-	int i;
 
 	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
 		dev_err(&pdev->dev, "Unsupported PCI Function type\n");
@@ -344,16 +318,7 @@ static int set_hw_ioctxt(struct hinic_hwdev *hwdev, unsigned int rq_depth,
 
 	hw_ioctxt.rq_depth  = ilog2(rq_depth);
 
-	for (i = 0; ; i++) {
-		if ((rx_buf_sz_table[i].sz == HINIC_RX_BUF_SZ) ||
-		    (rx_buf_sz_table[i].sz == -1)) {
-			hw_ioctxt.rx_buf_sz_idx = rx_buf_sz_table[i].idx;
-			break;
-		}
-	}
-
-	if (hw_ioctxt.rx_buf_sz_idx == -1)
-		return -EINVAL;
+	hw_ioctxt.rx_buf_sz_idx = HINIC_RX_BUF_SZ_IDX;
 
 	hw_ioctxt.sq_depth  = ilog2(sq_depth);
 
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
index e642a8a..df729a1 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
@@ -53,7 +53,9 @@
 #define HINIC_SQ_DEPTH                          SZ_4K
 #define HINIC_RQ_DEPTH                          SZ_4K
 
+/* In any change to HINIC_RX_BUF_SZ, HINIC_RX_BUF_SZ_IDX must be changed */
 #define HINIC_RX_BUF_SZ                         2048
+#define HINIC_RX_BUF_SZ_IDX			HINIC_RX_BUF_SZ_2048_IDX
 
 #define HINIC_MIN_TX_WQE_SIZE(wq)               \
 		ALIGN(HINIC_SQ_WQE_SIZE(1), (wq)->wqebb_size)
@@ -61,6 +63,25 @@
 #define HINIC_MIN_TX_NUM_WQEBBS(sq)             \
 		(HINIC_MIN_TX_WQE_SIZE((sq)->wq) / (sq)->wq->wqebb_size)
 
+enum hinic_rx_buf_sz_idx {
+	HINIC_RX_BUF_SZ_32_IDX,
+	HINIC_RX_BUF_SZ_64_IDX,
+	HINIC_RX_BUF_SZ_96_IDX,
+	HINIC_RX_BUF_SZ_128_IDX,
+	HINIC_RX_BUF_SZ_192_IDX,
+	HINIC_RX_BUF_SZ_256_IDX,
+	HINIC_RX_BUF_SZ_384_IDX,
+	HINIC_RX_BUF_SZ_512_IDX,
+	HINIC_RX_BUF_SZ_768_IDX,
+	HINIC_RX_BUF_SZ_1024_IDX,
+	HINIC_RX_BUF_SZ_1536_IDX,
+	HINIC_RX_BUF_SZ_2048_IDX,
+	HINIC_RX_BUF_SZ_3072_IDX,
+	HINIC_RX_BUF_SZ_4096_IDX,
+	HINIC_RX_BUF_SZ_8192_IDX,
+	HINIC_RX_BUF_SZ_16384_IDX,
+};
+
 struct hinic_sq {
 	struct hinic_hwif       *hwif;
 
-- 
1.9.1
