From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 for-next 1/8] net: hns: fix port unavailable after hnae_reserve_buffer_map fail
Date: Thu, 29 Sep 2016 18:09:09 +0100
Message-ID: <20160929170916.631972-2-salil.mehta@huawei.com>
References: <20160929170916.631972-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <xavier.huwei@huawei.com>, <oulijun@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <linux-rdma@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, lipeng <lipeng321@huawei.com>
To: <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:41342 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934341AbcI2RLI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 13:11:08 -0400
In-Reply-To: <20160929170916.631972-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lipeng <lipeng321@huawei.com>

When hnae_reserve_buffer_map fail, it will break cycle and some
buffer description has no available memory, therefore the port will
be unavailable.

Signed-off-by: Peng Li <lipeng321@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c |   23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index d7e1f8c..32ff270 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -747,6 +747,14 @@ static void hns_nic_rx_up_pro(struct hns_nic_ring_data *ring_data,
 	ndev->last_rx = jiffies;
 }
 
+static int hns_desc_unused(struct hnae_ring *ring)
+{
+	int ntc = ring->next_to_clean;
+	int ntu = ring->next_to_use;
+
+	return ((ntc >= ntu) ? 0 : ring->desc_num) + ntc - ntu;
+}
+
 static int hns_nic_rx_poll_one(struct hns_nic_ring_data *ring_data,
 			       int budget, void *v)
 {
@@ -755,17 +763,21 @@ static int hns_nic_rx_poll_one(struct hns_nic_ring_data *ring_data,
 	int num, bnum, ex_num;
 #define RCB_NOF_ALLOC_RX_BUFF_ONCE 16
 	int recv_pkts, recv_bds, clean_count, err;
+	int unused_count = hns_desc_unused(ring);
 
 	num = readl_relaxed(ring->io_base + RCB_REG_FBDNUM);
 	rmb(); /* make sure num taken effect before the other data is touched */
 
 	recv_pkts = 0, recv_bds = 0, clean_count = 0;
+	num -= unused_count;
 recv:
 	while (recv_pkts < budget && recv_bds < num) {
 		/* reuse or realloc buffers */
-		if (clean_count >= RCB_NOF_ALLOC_RX_BUFF_ONCE) {
-			hns_nic_alloc_rx_buffers(ring_data, clean_count);
+		if (clean_count + unused_count >= RCB_NOF_ALLOC_RX_BUFF_ONCE) {
+			hns_nic_alloc_rx_buffers(ring_data,
+						 clean_count + unused_count);
 			clean_count = 0;
+			unused_count = hns_desc_unused(ring);
 		}
 
 		/* poll one pkt */
@@ -789,7 +801,7 @@ recv:
 	/* make all data has been write before submit */
 	if (recv_pkts < budget) {
 		ex_num = readl_relaxed(ring->io_base + RCB_REG_FBDNUM);
-
+		ex_num -= unused_count;
 		if (ex_num > clean_count) {
 			num += ex_num - clean_count;
 			rmb(); /*complete read rx ring bd number*/
@@ -799,8 +811,9 @@ recv:
 
 out:
 	/* make all data has been write before submit */
-	if (clean_count > 0)
-		hns_nic_alloc_rx_buffers(ring_data, clean_count);
+	if (clean_count + unused_count > 0)
+		hns_nic_alloc_rx_buffers(ring_data,
+					 clean_count + unused_count);
 
 	return recv_pkts;
 }
-- 
1.7.9.5
