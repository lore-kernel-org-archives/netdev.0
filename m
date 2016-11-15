From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 for-next 04/11] IB/hns: add self loopback for CM
Date: Tue, 15 Nov 2016 18:10:46 +0000
Message-ID: <20161115181053.399568-5-salil.mehta@huawei.com>
References: <20161115181053.399568-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <xavier.huwei@huawei.com>,
        <oulijun@huawei.com>, <xushaobo2@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <lijun_nudt@163.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Peter Chen <luck.chen@huawei.com>
To: <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:32924 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933236AbcKOSME (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:12:04 -0500
In-Reply-To: <20161115181053.399568-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lijun Ou <oulijun@huawei.com>

This patch mainly adds self loopback support for CM.

Signed-off-by: Lijun Ou <oulijun@huawei.com>
Signed-off-by: Peter Chen <luck.chen@huawei.com>
Reviewed-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
Signed-off-by: Salil Mehta  <salil.mehta@huawei.com>
---
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c |   11 +++++++++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h |    2 ++
 2 files changed, 13 insertions(+)

diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index 959d5ca..e080dd6 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -32,6 +32,7 @@
 
 #include <linux/platform_device.h>
 #include <linux/acpi.h>
+#include <linux/etherdevice.h>
 #include <rdma/ib_umem.h>
 #include "hns_roce_common.h"
 #include "hns_roce_device.h"
@@ -72,6 +73,8 @@ int hns_roce_v1_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 	int nreq = 0;
 	u32 ind = 0;
 	int ret = 0;
+	u8 *smac;
+	int loopback;
 
 	if (unlikely(ibqp->qp_type != IB_QPT_GSI &&
 		ibqp->qp_type != IB_QPT_RC)) {
@@ -129,6 +132,14 @@ int hns_roce_v1_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 				       UD_SEND_WQE_U32_8_DMAC_5_M,
 				       UD_SEND_WQE_U32_8_DMAC_5_S,
 				       ah->av.mac[5]);
+
+			smac = (u8 *)hr_dev->dev_addr[qp->port];
+			loopback = ether_addr_equal_unaligned(ah->av.mac,
+							      smac) ? 1 : 0;
+			roce_set_bit(ud_sq_wqe->u32_8,
+				     UD_SEND_WQE_U32_8_LOOPBACK_INDICATOR_S,
+				     loopback);
+
 			roce_set_field(ud_sq_wqe->u32_8,
 				       UD_SEND_WQE_U32_8_OPERATION_TYPE_M,
 				       UD_SEND_WQE_U32_8_OPERATION_TYPE_S,
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
index 6004c7f..cf28f1b 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
@@ -440,6 +440,8 @@ struct hns_roce_ud_send_wqe {
 #define UD_SEND_WQE_U32_8_DMAC_5_M   \
 	(((1UL << 8) - 1) << UD_SEND_WQE_U32_8_DMAC_5_S)
 
+#define UD_SEND_WQE_U32_8_LOOPBACK_INDICATOR_S 22
+
 #define UD_SEND_WQE_U32_8_OPERATION_TYPE_S 16
 #define UD_SEND_WQE_U32_8_OPERATION_TYPE_M   \
 	(((1UL << 4) - 1) << UD_SEND_WQE_U32_8_OPERATION_TYPE_S)
-- 
1.7.9.5
