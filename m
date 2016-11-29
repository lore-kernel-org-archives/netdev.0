From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH for-next 3/6] IB/hns: Fix the bug of setting port mtu
Date: Tue, 29 Nov 2016 23:10:27 +0000
Message-ID: <20161129231030.1105600-4-salil.mehta@huawei.com>
References: <20161129231030.1105600-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xushaobo2-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <lijun_nudt-9Onoh4P/yGk@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161129231030.1105600-1-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

In hns_roce driver, we need not call iboe_get_mtu to reduce
IB headers from effective IBoE MTU because hr_dev->caps.max_mtu
has already been reduced.

Signed-off-by: Wei Hu (Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/hw/hns/hns_roce_main.c |   16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 0cedec0..5e620f9 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -72,18 +72,6 @@ static void hns_roce_set_mac(struct hns_roce_dev *hr_dev, u8 port, u8 *addr)
 	hr_dev->hw->set_mac(hr_dev, phy_port, addr);
 }
 
-static void hns_roce_set_mtu(struct hns_roce_dev *hr_dev, u8 port, int mtu)
-{
-	u8 phy_port = hr_dev->iboe.phy_port[port];
-	enum ib_mtu tmp;
-
-	tmp = iboe_get_mtu(mtu);
-	if (!tmp)
-		tmp = IB_MTU_256;
-
-	hr_dev->hw->set_mtu(hr_dev, phy_port, tmp);
-}
-
 static int hns_roce_add_gid(struct ib_device *device, u8 port_num,
 			    unsigned int index, const union ib_gid *gid,
 			    const struct ib_gid_attr *attr, void **context)
@@ -188,8 +176,8 @@ static int hns_roce_setup_mtu_mac(struct hns_roce_dev *hr_dev)
 	u8 i;
 
 	for (i = 0; i < hr_dev->caps.num_ports; i++) {
-		hns_roce_set_mtu(hr_dev, i,
-				 ib_mtu_enum_to_int(hr_dev->caps.max_mtu));
+		hr_dev->hw->set_mtu(hr_dev, hr_dev->iboe.phy_port[i],
+				    hr_dev->caps.max_mtu);
 		hns_roce_set_mac(hr_dev, i, hr_dev->iboe.netdevs[i]->dev_addr);
 	}
 
-- 
1.7.9.5


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
