From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [RESEND PATCH 3/3] infiniband: hns: avoid gcc-7.0.1 warning for uninitialized data
Date: Fri, 24 Mar 2017 23:02:48 +0100
Message-ID: <20170324220250.2193128-2-arnd@arndb.de>
References: <20170324220250.2193128-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "Wei Hu(Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Daode Huang <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
        Kejian Yan <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Qianqian Xie <xieqianqian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Wei Yongjun <weiyongjun1-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170324220250.2193128-1-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

hns_roce_v1_cq_set_ci() calls roce_set_bit() on an uninitialized field,
which will then change only a few of its bits, causing a warning with
the latest gcc:

infiniband/hw/hns/hns_roce_hw_v1.c: In function 'hns_roce_v1_cq_set_ci':
infiniband/hw/hns/hns_roce_hw_v1.c:1854:23: error: 'doorbell[1]' is used uninitialized in this function [-Werror=uninitialized]
  roce_set_bit(doorbell[1], ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_HW_SYNS_S, 1);

The code is actually correct since we always set all bits of the
port_vlan field, but gcc correctly points out that the first
access does contain uninitialized data.

This initializes the field to zero first before setting the
individual bits.

Fixes: 9a4435375cd1 ("IB/hns: Add driver files for hns RoCE driver")
Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index ec68f56e8ee5..882073a6ec77 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -1851,6 +1851,7 @@ void hns_roce_v1_cq_set_ci(struct hns_roce_cq *hr_cq, u32 cons_index)
 	u32 doorbell[2];
 
 	doorbell[0] = cons_index & ((hr_cq->cq_depth << 1) - 1);
+	doorbell[1] = 0;
 	roce_set_bit(doorbell[1], ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_HW_SYNS_S, 1);
 	roce_set_field(doorbell[1], ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_M,
 		       ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_S, 3);
-- 
2.9.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
