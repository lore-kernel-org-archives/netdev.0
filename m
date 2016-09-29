From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 for-next 4/8] net: hns: delete repeat read fbd num after while
Date: Thu, 29 Sep 2016 18:09:12 +0100
Message-ID: <20160929170916.631972-5-salil.mehta@huawei.com>
References: <20160929170916.631972-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <xavier.huwei@huawei.com>, <oulijun@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <linux-rdma@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, Daode Huang <huangdaode@hisilicon.com>
To: <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:53822 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755637AbcI2RLR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 13:11:17 -0400
In-Reply-To: <20160929170916.631972-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daode Huang <huangdaode@hisilicon.com>

Because we handle the received packets after napi, so delete the checking
before submitting. It delete the code of read the fbd number register,
which reduces the cpu usages while receiving packets

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c |   15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index e6bfc51..09ed237 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -760,7 +760,7 @@ static int hns_nic_rx_poll_one(struct hns_nic_ring_data *ring_data,
 {
 	struct hnae_ring *ring = ring_data->ring;
 	struct sk_buff *skb;
-	int num, bnum, ex_num;
+	int num, bnum;
 #define RCB_NOF_ALLOC_RX_BUFF_ONCE 16
 	int recv_pkts, recv_bds, clean_count, err;
 	int unused_count = hns_desc_unused(ring);
@@ -770,7 +770,7 @@ static int hns_nic_rx_poll_one(struct hns_nic_ring_data *ring_data,
 
 	recv_pkts = 0, recv_bds = 0, clean_count = 0;
 	num -= unused_count;
-recv:
+
 	while (recv_pkts < budget && recv_bds < num) {
 		/* reuse or realloc buffers */
 		if (clean_count + unused_count >= RCB_NOF_ALLOC_RX_BUFF_ONCE) {
@@ -798,17 +798,6 @@ recv:
 		recv_pkts++;
 	}
 
-	/* make all data has been write before submit */
-	if (recv_pkts < budget) {
-		ex_num = readl_relaxed(ring->io_base + RCB_REG_FBDNUM);
-		ex_num -= unused_count;
-		if (ex_num > clean_count) {
-			num += ex_num - clean_count;
-			rmb(); /*complete read rx ring bd number*/
-			goto recv;
-		}
-	}
-
 out:
 	/* make all data has been write before submit */
 	if (clean_count + unused_count > 0)
-- 
1.7.9.5
