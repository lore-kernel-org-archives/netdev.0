From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V3 for-next 05/11] IB/hns: Modify the condition of notifying hardware loopback
Date: Wed, 23 Nov 2016 19:41:03 +0000
Message-ID: <20161123194109.420760-6-salil.mehta@huawei.com>
References: <20161123194109.420760-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <xavier.huwei@huawei.com>,
        <oulijun@huawei.com>, <xushaobo2@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <lijun_nudt@163.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161123194109.420760-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lijun Ou <oulijun@huawei.com>

This patch modified the condition of notifying hardware loopback.

In hip06, RoCE Engine has several ports, one QP is related
to one port. hardware only support loopback in the same port,
not in the different ports.

So, If QP related to port N, the dmac in the QP context equals
the smac of the local port N or the loop_idc is 1, we should
set loopback bit in QP context to notify hardware.

Signed-off-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
Signed-off-by: Salil Mehta  <salil.mehta@huawei.com>
---
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c |   24 +++++++-----------------
 1 file changed, 7 insertions(+), 17 deletions(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index e080dd6..643a2ff 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -2244,24 +2244,14 @@ static int hns_roce_v1_m_qp(struct ib_qp *ibqp, const struct ib_qp_attr *attr,
 			     QP_CONTEXT_QPC_BYTE_32_SIGNALING_TYPE_S,
 			     hr_qp->sq_signal_bits);
 
-		for (port = 0; port < hr_dev->caps.num_ports; port++) {
-			smac = (u8 *)hr_dev->dev_addr[port];
-			dev_dbg(dev, "smac: %2x: %2x: %2x: %2x: %2x: %2x\n",
-				smac[0], smac[1], smac[2], smac[3], smac[4],
-				smac[5]);
-			if ((dmac[0] == smac[0]) && (dmac[1] == smac[1]) &&
-			    (dmac[2] == smac[2]) && (dmac[3] == smac[3]) &&
-			    (dmac[4] == smac[4]) && (dmac[5] == smac[5])) {
-				roce_set_bit(context->qpc_bytes_32,
-				    QP_CONTEXT_QPC_BYTE_32_LOOPBACK_INDICATOR_S,
-				    1);
-				break;
-			}
-		}
-
-		if (hr_dev->loop_idc == 0x1)
+		port = (attr_mask & IB_QP_PORT) ? (attr->port_num - 1) :
+			hr_qp->port;
+		smac = (u8 *)hr_dev->dev_addr[port];
+		/* when dmac equals smac or loop_idc is 1, it should loopback */
+		if (ether_addr_equal_unaligned(dmac, smac) ||
+		    hr_dev->loop_idc == 0x1)
 			roce_set_bit(context->qpc_bytes_32,
-				QP_CONTEXT_QPC_BYTE_32_LOOPBACK_INDICATOR_S, 1);
+			      QP_CONTEXT_QPC_BYTE_32_LOOPBACK_INDICATOR_S, 1);
 
 		roce_set_bit(context->qpc_bytes_32,
 			     QP_CONTEXT_QPC_BYTE_32_GLOBAL_HEADER_S,
-- 
1.7.9.5
