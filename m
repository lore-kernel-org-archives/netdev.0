From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 2/2] net: hns: set-coalesce-usecs returns errno by dsaf.ko
Date: Mon, 28 Mar 2016 18:40:57 +0800
Message-ID: <1459161657-151406-3-git-send-email-Yisen.Zhuang@huawei.com>
References: <1459161657-151406-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <charles.chenxin@huawei.com>, <haifeng.wei@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <liguozhu@huawei.com>,
	<huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<geliangtang@163.com>, <ivecera@redhat.com>,
	<lisheng011@huawei.com>, <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459161657-151406-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lisheng <lisheng011@huawei.com>

It may fail to set coalesce usecs to HW, and Ethtool needs to know if it
is successful to cfg the parameter or not. So it needs return the errno by
dsaf.ko.

Signed-off-by: Lisheng <lisheng011@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.h         | 2 +-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c | 6 +++---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  | 6 ++++--
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 37d0cce..e8d36aa 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -469,7 +469,7 @@ struct hnae_ae_ops {
 				   u32 *tx_usecs, u32 *rx_usecs);
 	void (*get_rx_max_coalesced_frames)(struct hnae_handle *handle,
 					    u32 *tx_frames, u32 *rx_frames);
-	void (*set_coalesce_usecs)(struct hnae_handle *handle, u32 timeout);
+	int (*set_coalesce_usecs)(struct hnae_handle *handle, u32 timeout);
 	int (*set_coalesce_frames)(struct hnae_handle *handle,
 				   u32 coalesce_frames);
 	void (*set_promisc_mode)(struct hnae_handle *handle, u32 en);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 1dd1d69..a1cb461 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -469,13 +469,13 @@ static void hns_ae_get_rx_max_coalesced_frames(struct hnae_handle *handle,
 						  ring_pair->port_id_in_comm);
 }
 
-static void hns_ae_set_coalesce_usecs(struct hnae_handle *handle,
-				      u32 timeout)
+static int hns_ae_set_coalesce_usecs(struct hnae_handle *handle,
+				     u32 timeout)
 {
 	struct ring_pair_cb *ring_pair =
 		container_of(handle->qs[0], struct ring_pair_cb, q);
 
-	(void)hns_rcb_set_coalesce_usecs(
+	return hns_rcb_set_coalesce_usecs(
 		ring_pair->rcb_common, ring_pair->port_id_in_comm, timeout);
 }
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 9c3ba65..b138181 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -794,8 +794,10 @@ static int hns_set_coalesce(struct net_device *net_dev,
 	    (!ops->set_coalesce_frames))
 		return -ESRCH;
 
-	ops->set_coalesce_usecs(priv->ae_handle,
-					ec->rx_coalesce_usecs);
+	ret = ops->set_coalesce_usecs(priv->ae_handle,
+				      ec->rx_coalesce_usecs);
+	if (ret)
+		return ret;
 
 	ret = ops->set_coalesce_frames(
 		priv->ae_handle,
-- 
1.9.1
