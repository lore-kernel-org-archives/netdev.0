From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH v3 net-next 08/10] net: hns3: Add dcb netlink interface for the support of DCB feature
Date: Wed, 27 Sep 2017 09:45:30 +0800
Message-ID: <1506476732-128130-9-git-send-email-linyunsheng@huawei.com>
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
Received: from szxga05-in.huawei.com ([45.249.212.191]:7035 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033082AbdI0BqF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 21:46:05 -0400
In-Reply-To: <1506476732-128130-1-git-send-email-linyunsheng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add dcb netlink interface by calling the interface from
hclge_dcb module.

This patch also update Makefile in order to build hns3_dcbnl module.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 .../net/ethernet/hisilicon/hns3/hns3pf/Makefile    |   2 +
 .../ethernet/hisilicon/hns3/hns3pf/hns3_dcbnl.c    | 106 +++++++++++++++++++++
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c |   2 +
 .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |   7 ++
 4 files changed, 117 insertions(+)
 create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_dcbnl.c

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile b/drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile
index 7023dc87..d2b20d0 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/Makefile
@@ -11,3 +11,5 @@ hclge-$(CONFIG_HNS3_DCB) += hclge_dcb.o
 
 obj-$(CONFIG_HNS3_ENET) += hns3.o
 hns3-objs = hns3_enet.o hns3_ethtool.o
+
+hns3-$(CONFIG_HNS3_DCB) += hns3_dcbnl.o
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_dcbnl.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_dcbnl.c
new file mode 100644
index 0000000..9832172
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_dcbnl.c
@@ -0,0 +1,106 @@
+/*
+ * Copyright (c) 2016-2017 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include "hnae3.h"
+#include "hns3_enet.h"
+
+static
+int hns3_dcbnl_ieee_getets(struct net_device *ndev, struct ieee_ets *ets)
+{
+	struct hns3_nic_priv *priv = netdev_priv(ndev);
+	struct hnae3_handle *h = priv->ae_handle;
+
+	if (h->kinfo.dcb_ops->ieee_getets)
+		return h->kinfo.dcb_ops->ieee_getets(h, ets);
+
+	return -EOPNOTSUPP;
+}
+
+static
+int hns3_dcbnl_ieee_setets(struct net_device *ndev, struct ieee_ets *ets)
+{
+	struct hns3_nic_priv *priv = netdev_priv(ndev);
+	struct hnae3_handle *h = priv->ae_handle;
+
+	if (h->kinfo.dcb_ops->ieee_setets)
+		return h->kinfo.dcb_ops->ieee_setets(h, ets);
+
+	return -EOPNOTSUPP;
+}
+
+static
+int hns3_dcbnl_ieee_getpfc(struct net_device *ndev, struct ieee_pfc *pfc)
+{
+	struct hns3_nic_priv *priv = netdev_priv(ndev);
+	struct hnae3_handle *h = priv->ae_handle;
+
+	if (h->kinfo.dcb_ops->ieee_getpfc)
+		return h->kinfo.dcb_ops->ieee_getpfc(h, pfc);
+
+	return -EOPNOTSUPP;
+}
+
+static
+int hns3_dcbnl_ieee_setpfc(struct net_device *ndev, struct ieee_pfc *pfc)
+{
+	struct hns3_nic_priv *priv = netdev_priv(ndev);
+	struct hnae3_handle *h = priv->ae_handle;
+
+	if (h->kinfo.dcb_ops->ieee_setpfc)
+		return h->kinfo.dcb_ops->ieee_setpfc(h, pfc);
+
+	return -EOPNOTSUPP;
+}
+
+/* DCBX configuration */
+static u8 hns3_dcbnl_getdcbx(struct net_device *ndev)
+{
+	struct hns3_nic_priv *priv = netdev_priv(ndev);
+	struct hnae3_handle *h = priv->ae_handle;
+
+	if (h->kinfo.dcb_ops->getdcbx)
+		return h->kinfo.dcb_ops->getdcbx(h);
+
+	return 0;
+}
+
+/* return 0 if successful, otherwise fail */
+static u8 hns3_dcbnl_setdcbx(struct net_device *ndev, u8 mode)
+{
+	struct hns3_nic_priv *priv = netdev_priv(ndev);
+	struct hnae3_handle *h = priv->ae_handle;
+
+	if (h->kinfo.dcb_ops->setdcbx)
+		return h->kinfo.dcb_ops->setdcbx(h, mode);
+
+	return 1;
+}
+
+static const struct dcbnl_rtnl_ops hns3_dcbnl_ops = {
+	.ieee_getets	= hns3_dcbnl_ieee_getets,
+	.ieee_setets	= hns3_dcbnl_ieee_setets,
+	.ieee_getpfc	= hns3_dcbnl_ieee_getpfc,
+	.ieee_setpfc	= hns3_dcbnl_ieee_setpfc,
+	.getdcbx	= hns3_dcbnl_getdcbx,
+	.setdcbx	= hns3_dcbnl_setdcbx,
+};
+
+/* hclge_dcbnl_setup - DCBNL setup
+ * @handle: the corresponding vport handle
+ * Set up DCBNL
+ */
+void hns3_dcbnl_setup(struct hnae3_handle *handle)
+{
+	struct net_device *dev = handle->kinfo.netdev;
+
+	if (!handle->kinfo.dcb_ops)
+		return;
+
+	dev->dcbnl_ops = &hns3_dcbnl_ops;
+}
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 35369e1..11dab26 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -2790,6 +2790,8 @@ static int hns3_client_init(struct hnae3_handle *handle)
 		goto out_reg_netdev_fail;
 	}
 
+	hns3_dcbnl_setup(handle);
+
 	/* MTU range: (ETH_MIN_MTU(kernel default) - 9706) */
 	netdev->max_mtu = HNS3_MAX_MTU - (ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);
 
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
index 7e87461..481eada 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
@@ -590,4 +590,11 @@ static inline void hns3_write_reg(void __iomem *base, u32 reg, u32 value)
 void hns3_ethtool_set_ops(struct net_device *netdev);
 
 int hns3_clean_tx_ring(struct hns3_enet_ring *ring, int budget);
+
+#ifdef CONFIG_HNS3_DCB
+void hns3_dcbnl_setup(struct hnae3_handle *handle);
+#else
+static inline void hns3_dcbnl_setup(struct hnae3_handle *handle) {}
+#endif
+
 #endif
-- 
1.9.1
