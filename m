From: Yankejian <yankejian@huawei.com>
Subject: [PATCH net v4 1/3] net: hns: support deferred probe when can not obtain irq
Date: Thu, 27 Apr 2017 10:44:11 +0800
Message-ID: <1493261053-68197-2-git-send-email-yankejian@huawei.com>
References: <1493261053-68197-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <salil.mehta@huawei.com>,
        <yisen.zhuang@huawei.com>, <matthias.bgg@gmail.com>,
        <yankejian@huawei.com>, <lipeng321@huawei.com>,
        <zhouhuiru@huawei.com>, <huangdaode@hisilicon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:5805 "EHLO
        dggrg01-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1033567AbdD0CYT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 22:24:19 -0400
In-Reply-To: <1493261053-68197-1-git-send-email-yankejian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lipeng <lipeng321@huawei.com>

In the hip06 and hip07 SoCs, the interrupt lines from the
DSAF controllers are connected to mbigen hw module.
The mbigen module is probed with module_init, and, as such,
is not guaranteed to probe before the HNS driver. So we need
to support deferred probe.

Signed-off-by: lipeng <lipeng321@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Reviewed-by: Matthias Brugger <mbrugger@suse.com>
---
change log:
V3 -> V4:
1. Delete redundant commit message;
2. add Reviewed-by: Matthias Brugger <mbrugger@suse.com>;

V2 -> V3:
1. Check return value when  platform_get_irq in hns_rcb_get_cfg;
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c | 4 +++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c | 8 +++++++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h | 2 +-
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index 6ea8722..a41cf95 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -510,7 +510,9 @@ int hns_ppe_init(struct dsaf_device *dsaf_dev)
 
 		hns_ppe_get_cfg(dsaf_dev->ppe_common[i]);
 
-		hns_rcb_get_cfg(dsaf_dev->rcb_common[i]);
+		ret = hns_rcb_get_cfg(dsaf_dev->rcb_common[i]);
+		if (ret)
+			goto get_rcb_cfg_fail;
 	}
 
 	for (i = 0; i < HNS_PPE_COM_NUM; i++)
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index f0ed80d6..673a5d3 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -452,7 +452,7 @@ static int hns_rcb_get_base_irq_idx(struct rcb_common_cb *rcb_common)
  *hns_rcb_get_cfg - get rcb config
  *@rcb_common: rcb common device
  */
-void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
+int hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
 {
 	struct ring_pair_cb *ring_pair_cb;
 	u32 i;
@@ -477,10 +477,16 @@ void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
 		ring_pair_cb->virq[HNS_RCB_IRQ_IDX_RX] =
 		is_ver1 ? platform_get_irq(pdev, base_irq_idx + i * 2 + 1) :
 			  platform_get_irq(pdev, base_irq_idx + i * 3);
+		if ((ring_pair_cb->virq[HNS_RCB_IRQ_IDX_TX] == -EPROBE_DEFER) ||
+		    (ring_pair_cb->virq[HNS_RCB_IRQ_IDX_RX] == -EPROBE_DEFER))
+			return -EPROBE_DEFER;
+
 		ring_pair_cb->q.phy_base =
 			RCB_COMM_BASE_TO_RING_BASE(rcb_common->phy_base, i);
 		hns_rcb_ring_pair_get_cfg(ring_pair_cb);
 	}
+
+	return 0;
 }
 
 /**
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
index 99b4e1b..3d7b484 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
@@ -110,7 +110,7 @@ struct rcb_common_cb {
 void hns_rcb_common_free_cfg(struct dsaf_device *dsaf_dev, u32 comm_index);
 int hns_rcb_common_init_hw(struct rcb_common_cb *rcb_common);
 void hns_rcb_start(struct hnae_queue *q, u32 val);
-void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common);
+int hns_rcb_get_cfg(struct rcb_common_cb *rcb_common);
 void hns_rcb_get_queue_mode(enum dsaf_mode dsaf_mode,
 			    u16 *max_vfn, u16 *max_q_per_vf);
 
-- 
1.9.1
